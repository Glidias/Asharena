package systems.player.a3d 
{
	import alternativa.engine3d.animation.AnimationClip;
	import alternativa.engine3d.animation.AnimationController;
	import alternativa.engine3d.animation.AnimationCouple;
	import alternativa.engine3d.animation.AnimationSwitcher;
	import alternativa.engine3d.objects.Joint;
	import alternativa.engine3d.objects.Skin;
	import components.controller.SurfaceMovement;
	import components.Pos;
	import flash.Boot;
	import flash.utils.Dictionary;
	import systems.animation.IAnimatable;
	import systems.player.PlayerAction;
	import alternativa.engine3d.alternativa3d;
	use namespace alternativa3d;
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class GladiatorStance implements IAnimatable
	{
		private var skin:Skin;
		private var anims:AnimationManager;
		
		public static var ANIM_MANAGER:AnimationManager = new AnimationManager();
		public static var ANIM_GROUPS:Object; 
		
		private var fullBody:AnimationSwitcher = new AnimationSwitcher();
		private var fullBodyController:AnimationController = new AnimationController();
		private var fullBodyAnims:Dictionary = new Dictionary();
		
		private var upperBody:AnimationSwitcher = new AnimationSwitcher();
		private var upperBodyController:AnimationController = new AnimationController();
		private var upperBodyAnims:Dictionary = new Dictionary();
		
		private var lowerBody:AnimationSwitcher = new AnimationSwitcher();
		private var lowerBodyController:AnimationController = new AnimationController();
		private var lowerBodyAnims:Dictionary =  new Dictionary();
		
		private var _curController:AnimationController;
		//public var upperBodyCouple:AnimationCouple = new AnimationCouple();  // for blending 2 animations
		
		private var _stance:int = 0;
		private var _stanceString:String = "stand";
		
		
		public static const SPEED_BACKWARDS:Number = 60;
		public static const SPEED_JOG:Number = 112;
		public static const SPEED_RUN:Number = 170;
		
		public static const SPEED_STRAFE:Number = 34;
		
		private static const I_SPEED_BACKWARDS:Number =1/SPEED_BACKWARDS;
		private static const I_SPEED_JOG:Number = 1/SPEED_JOG;
		private static const I_SPEED_RUN:Number = 1/SPEED_RUN;
		private static const I_SPEED_STRAFE:Number = 1 / SPEED_STRAFE;
		
	
		
		private var speed_backwards_fast:Number = 65;
		private var speed_backwards:Number = 34;
		
		private var speed_jog:Number = 111;
		private var speed_run:Number = 150;
		private var speed_strafe_fast:Number = 58;
		private var speed_strafe:Number = 36;
		public var SPEED_RUN_MULTIPLIER:Number = speed_run / speed_jog;
		
		
		
		private static const MASK_STRAFE:int = ( (1 << PlayerAction.STRAFE_LEFT_FAST) | (1 << PlayerAction.STRAFE_RIGHT_FAST) | (1 << PlayerAction.STRAFE_LEFT) | (1 << PlayerAction.STRAFE_RIGHT));
		private static const MASK_WALK:int = ( (1<<PlayerAction.MOVE_FORWARD) | (1<<PlayerAction.MOVE_FORWARD_FAST) | (1<<PlayerAction.MOVE_BACKWARD) | (1<<PlayerAction.MOVE_BACKWARD_FAST));
		private static const MASK_WALK_FORWARD:int = ( (1 << PlayerAction.MOVE_FORWARD) | (1 << PlayerAction.MOVE_FORWARD_FAST) );
		private static const MASK_STRAFE_FAST:int = ( (1 << PlayerAction.STRAFE_LEFT_FAST) | (1 << PlayerAction.STRAFE_RIGHT_FAST) );
		
		private var rootJoint:Joint;
		
		
		public function GladiatorStance(skin:Skin, surfaceMovement:SurfaceMovement) 
		{
				this.surfaceMovement = surfaceMovement;
				
			this.skin = skin;
			anims = ANIM_MANAGER.cloneFor(skin);
			
			rootJoint = getJoint("Bip01");
			surfaceMovement.setStrafeSpeed(speed_strafe);
		
			init();
		}
		
		public function getJoint(name:String):Joint {
			var i:int = skin._renderedJoints.length;
			while (--i > -1) {
				if ( skin._renderedJoints[i].name === name) return skin._renderedJoints[i];
			}
			return null;
		}
		
		private function init():void {
			
			var groups:Object = ANIM_GROUPS;
			for (var p:String in groups) {
				var switcher:AnimationSwitcher = p === "upperbody" ? upperBody : p === "lowerbody" ? lowerBody : fullBody;
				var dict:Dictionary = p === "upperbody" ? upperBodyAnims : p === "lowerbody" ? lowerBodyAnims : fullBodyAnims;
				var arr:Array = groups[p];
				for each( var str:String in arr) {
					var anim:AnimationClip;
					dict[str] = anim = anims.getAnimationByName(str);
					switcher.addAnimation(anim);
				}
			}
			
			fullBodyController.root = fullBody;
			upperBodyController.root = upperBody;
			lowerBodyController.root = lowerBody;
			
			_curController = fullBodyController;
			fullBody.activate( fullBodyAnims["standing_idle"], 0);
		}
		
		public function switchAnimation(anim:AnimationClip, controller:AnimationController, switcher:AnimationSwitcher, time:Number):void {
			switcher.activate(anim, time);
			_curController = controller;
		}
		
		public function setAnimation(anim:AnimationClip, controller:AnimationController, switcher:AnimationSwitcher, time:Number):AnimationClip {
			anim.time = 0;
			switcher.activate(anim, time);
			_curController = controller;
			if (_skinRotated) {
				skin.rotationZ = Math.PI;
				_skinRotated = false;
			}
			return anim;
		}
				

		
		
		public function setAccelerate(boo:Boolean):void {
			// set surfacemovement speed to match
			surfaceMovement.setWalkSpeeds(boo ? speed_run : speed_jog, speed_backwards);
		}
		
		public function setJoggingSpeed(speed:Number):void {
			speed_jog = speed;
			speed_run = speed * SPEED_RUN_MULTIPLIER;
		}
		

		// handles any changes in action!
		public function handleAction(val:int):void {
			
			if (val === PlayerAction.STATE_JUMP) {
				setAnimation(fullBodyAnims["jump"], fullBodyController, fullBody, 0).speed = 1;
				//(fullBodyAnims["jump"] as AnimationClip).time = .5;
				_curController = fullBodyController;
				_curController.update();
				return;
			}	
			else if (val === PlayerAction.IDLE) {
				skin._rotationZ = Math.PI;
				skin.transformChanged = true;
				setAnimation(fullBodyAnims[(_stance == 0 ? "standing" : _stanceString)+"_idle"], fullBodyController, fullBody, .2);
				_curController = fullBodyController;
				return;
			}
			
			var mask:uint = (1 << val);
			if ( mask & MASK_STRAFE ) {
					// always do fast turn run animation
					// Am i in runmode or not and is it fast enough to warrant a fast move??
					
					// Else
					//Log.trace(val === PlayerAction.STRAFE_LEFT);
					surfaceMovement.setStrafeSpeed( (mask & MASK_STRAFE_FAST) ? speed_strafe_fast : speed_strafe );
					setAnimation(lowerBodyAnims["combat" + ( mask & (1 << PlayerAction.STRAFE_LEFT) ? "_moveleft" : "_moveright")], lowerBodyController, lowerBody, .3).speed = surfaceMovement.STRAFE_SPEED * I_SPEED_STRAFE;
				setAnimation(upperBodyAnims["ref_melee_aim"], upperBodyController, upperBody, .3);
					_curController = null;
			}
			else if (mask & MASK_WALK) {
				if (mask & MASK_WALK_FORWARD  ) {
					
					if (val != PlayerAction.MOVE_FORWARD_FAST) {
						setAnimation(fullBodyAnims["jog"], fullBodyController, fullBody, .2).speed = speed_jog * I_SPEED_JOG;
						_curController = fullBodyController;
						setAccelerate(false);
					}
					else {
						_skinRotated = false;
						setAnimation(fullBodyAnims["run"], fullBodyController, fullBody, .1).speed = speed_run * I_SPEED_RUN;
						_curController = fullBodyController; 
						skin._rotationZ = Math.PI + .22;
						skin.transformChanged = true;
						_skinRotated = true;
						setAccelerate(true);
						
					}
				}
				else {
					surfaceMovement.WALKBACK_SPEED =  val != PlayerAction.MOVE_BACKWARD_FAST ? speed_backwards : speed_backwards_fast;
					setAnimation(lowerBodyAnims["combat_walkback"], lowerBodyController, lowerBody, .3).speed = surfaceMovement.WALKBACK_SPEED * I_SPEED_BACKWARDS;
					setAnimation(upperBodyAnims["ref_melee_aim"], upperBodyController, upperBody, .3);
				
					_curController = null;
				}
				
			}
		}
		
		private var surfaceMovement:SurfaceMovement;
		private var _skinRotated:Boolean = true;
		
		/* INTERFACE systems.animation.IAnimatable */
		
		public function animate(time:Number):void 
		{
			if (_curController != null) _curController.update();  // TODO: inject time into modifed clas
			else {
				lowerBodyController.update();
				upperBodyController.update();
			}
			rootJoint._x = 0;
			rootJoint._y = 0;
			rootJoint._z = 0;
		}
			
		
	}

}