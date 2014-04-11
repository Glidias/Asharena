package systems.player.a3d 
{
	import alternativa.engine3d.animation.AnimationClip;
	import alternativa.engine3d.animation.AnimationController;
	import alternativa.engine3d.animation.AnimationCouple;
	import alternativa.engine3d.animation.AnimationNode;
	import alternativa.engine3d.animation.AnimationNotify;
	import alternativa.engine3d.animation.AnimationSwitcher;
	import alternativa.engine3d.animation.events.NotifyEvent;
	import alternativa.engine3d.objects.Joint;
	import alternativa.engine3d.objects.Skin;
	import arena.components.weapon.PlayerAttack;
	import ash.signals.Signal1;
	import com.greensock.TweenLite;
	import components.controller.SurfaceMovement;
	import components.Ellipsoid;
	import components.Pos;
	import flash.Boot;
	import flash.events.IEventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;
	import input.KeyBindings;
	import systems.animation.IAnimatable;
	import systems.player.PlayerAction;
	import alternativa.engine3d.alternativa3d;
	import util.geom.PMath;
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
		
		private var attackAnimCouple:AnimationCouple = new AnimationCouple();
		private var melee_thrust_up:AnimationClip;
		private var melee_thrust_down:AnimationClip;
		private var melee_swing_up:AnimationClip;
		private var melee_swing_down:AnimationClip;
		
		//private 
		
		private var _stance:int = 0;
		private var _lastStance:int = 0;
		private var _stanceString:String = "stand";
		public var CROUCH_TIME:Number = .25;
		
		public static var ON_STANCE_CHANGE:Signal1 = new Signal1();
		
		private var _stanceTemp:Boolean = false;
		
		public function set stance(val:int):void {
			_stanceTemp = false;
			var lastStance:int = _stance;
			_lastStance = lastStance;
			_stanceString = val === 0 ? "stand" : val === 1 ? "combat" : "crouch";
			_stance = val;
			if (lastStance != val) {
				ON_STANCE_CHANGE.dispatch(val);
				crouchTime = crouchTime >= CROUCH_TIME?  0 : CROUCH_TIME - crouchTime;
				crouchDirection = lastStance < val ? 1 : -1;
			}
			
		}
		
		public function get stance():int 
		{
			return _stance;
		}
	
		
		public static const SPEED_BACKWARDS:Number = 60;
		public static const SPEED_FORWARDS:Number = 60;
		public static const SPEED_JOG:Number = 112;
		public static const SPEED_RUN:Number = 170;
		public static const SPEED_CROUCH:Number = 38;
		
		public static const SPEED_STRAFE_LOWER:Number = 54;
		public static const SPEED_STRAFE_UPPER:Number = 34;
		
		private static const I_SPEED_FORWARDS:Number =1/SPEED_FORWARDS;
		private static const I_SPEED_BACKWARDS:Number =1/SPEED_BACKWARDS;
		private static const I_SPEED_JOG:Number = 1/SPEED_JOG;
		private static const I_SPEED_RUN:Number = 1/SPEED_RUN;
		private static const I_SPEED_STRAFE_UPPER:Number = 1 / SPEED_STRAFE_UPPER;
		private static const I_SPEED_STRAFE_LOWER:Number = 1 / SPEED_STRAFE_LOWER;
		private static const I_SPEED_CROUCH:Number =1 / SPEED_CROUCH;
	
		private static const SPEED_SCALE:Number = 1.5;
		private var speed_backwards_fast:Number = 45*SPEED_SCALE;
		private var speed_backwards:Number = 30*SPEED_SCALE;
		
		private var speed_jog:Number = 100*SPEED_SCALE;
		private var speed_run:Number = 160*SPEED_SCALE;
		
		private var speed_strafe_fast:Number = 52*SPEED_SCALE;
		private var speed_strafe:Number = 38 * SPEED_SCALE;
		
	//	private static const UPPER_BODY_PENALTY:Number = .75;
		public var SPEED_RUN_MULTIPLIER:Number = speed_run / speed_jog;
		public var SPEED_CROUCH_MULTIPLIER:Number = SPEED_CROUCH / SPEED_JOG;
		public var SPEED_CROUCHSTRAFE_MULTIPLIER:Number = SPEED_CROUCH / SPEED_STRAFE_LOWER;
		public var SPEED_CROUCHBACK_MULTIPLIER:Number = SPEED_CROUCH / SPEED_BACKWARDS;
		public var playerSpeedCrouchRatio:Number = .7;
		public var playerSpeedCombatRatio:Number = .55;
		public var upperBodyDominant:Boolean = false;
		public var ellipsoid:Ellipsoid;
		
		private static const MASK_STRAFE:int = ( (1 << PlayerAction.STRAFE_LEFT_FAST) | (1 << PlayerAction.STRAFE_RIGHT_FAST) | (1 << PlayerAction.STRAFE_LEFT) | (1 << PlayerAction.STRAFE_RIGHT));
		private static const MASK_STRAFE_LEFT:int = ((1 << PlayerAction.STRAFE_LEFT_FAST) | (1 << PlayerAction.STRAFE_LEFT));
		private static const MASK_WALK:int = ( (1<<PlayerAction.MOVE_FORWARD) | (1<<PlayerAction.MOVE_FORWARD_FAST) | (1<<PlayerAction.MOVE_BACKWARD) | (1<<PlayerAction.MOVE_BACKWARD_FAST));
		private static const MASK_WALK_FORWARD:int = ( (1 << PlayerAction.MOVE_FORWARD) | (1 << PlayerAction.MOVE_FORWARD_FAST) );
		private static const MASK_STRAFE_FAST:int = ( (1 << PlayerAction.STRAFE_LEFT_FAST) | (1 << PlayerAction.STRAFE_RIGHT_FAST) );
		
		private var rootJoint:Joint;
		
		private static const FLINCHES:Array = [
		"flinch_gut","flinch_leftarm","flinch_rightarm","flinch_head","flinch_leftleg","flinch_rightleg"
		]
		private var flinches:Array;
		
		public function GladiatorStance(skin:Skin, surfaceMovement:SurfaceMovement, ellipsoid:Ellipsoid) 
		{
				this.surfaceMovement = surfaceMovement;
				this.ellipsoid = ellipsoid;
				
			this.skin = skin;
			anims = ANIM_MANAGER.cloneFor(skin);
			
			rootJoint = skin.childrenList as Joint;//getJoint("Bip01");
			surfaceMovement.setStrafeSpeed(speed_strafe);
			
			setupAnimations();
			
			
			//throw new Error(anims.getAnimGroups());
			
		
			init();
		}
		
		private function setupAnimations():void 
		{
			melee_swing_up = anims.getAnimationByName("ref_melee_swing1").clone();
			melee_swing_down = anims.getAnimationByName("ref_melee_swing2").clone();
			
			melee_thrust_up = anims.getAnimationByName("ref_melee_thrust1").clone();
			melee_thrust_down = anims.getAnimationByName("ref_melee_thrust2").clone();
			
			flinches = [];
			var len:int = FLINCHES.length;
			for (var i:int = 0; i < len; i++) {
				var f:AnimationClip;
				flinches[i] = f = anims.getAnimationByName( FLINCHES[i] );
				var fa:AnimationNotify;
				 fa = f.addNotifyAtEnd(0);
				fa.addEventListener(NotifyEvent.NOTIFY, onEndFullBodyAnim, false,0,true);
				
				
			}
			
			
		//	melee_swing_up.addNotifyAtEnd(0).addEventListener(NotifyEvent.NOTIFY, onEndSwingAnim);
		//	melee_thrust_up.addNotifyAtEnd(0).addEventListener(NotifyEvent.NOTIFY, onEndSwingAnim);
			
			upperBody.addAnimation(attackAnimCouple);
			
		}
		
		private function onEndSwingAnim(e:NotifyEvent):void {
			
				if (_stanceTemp) {
					stance = 0;
					
					handleAction(lastAction);
					_stanceTemp = false;
				}
		}
		
		private function onEndFullBodyAnim(e:NotifyEvent):void 
		{
			handleAction(lastAction);
		}
		
		
		
		public function swing(altBalance:Number = .5):void {
			
			attackAnimCouple.left = melee_swing_down;
			attackAnimCouple.right = melee_swing_up;
			melee_swing_down.time = 0;
			melee_swing_up.time = 0;
			attackAnimCouple.balance = altBalance;// 1; altBalance;
			
			if (_stance == 0) {
				
				setStanceAndRefresh(1);
				_stanceTemp = true;
				
			}
			initiateUpperBodyAttack();
			
			
		}
		
		public function thrust(altBalance:Number = .5):void {
			
			attackAnimCouple.left = melee_thrust_down;
			attackAnimCouple.right = melee_thrust_up;
			melee_thrust_down.time = 0;
			melee_thrust_up.time = 0;
			attackAnimCouple.balance =  altBalance;
			if (_stance == 0) {
				
				setStanceAndRefresh(1);
				_stanceTemp = true;
			}
			initiateUpperBodyAttack();
			
			
		}
		
		public function initiateUpperBodyAttack():void {
			
			//setAnimationNode(attackAnimCouple, upperBodyController, upperBody, .3);
			if (!upperBodyDominant) {
				setAnimationNode( _stance < 2 ? fullBodyAnims[ "combat_idle"] : fullBodyAnims["crouch_idle"], fullBodyController, fullBody, 0);
				fullBodyController.update(0);
			}
			
			setAnimationNode( attackAnimCouple, upperBodyController, upperBody, .3);
			//_curController = null;
			if (upperBodyDominant) _curController = null;
			//upperBodyDominant = true;
			
			
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
			
			
			//lowerBodyAnims["combat_idle"] = fullBodyAnims["combat_idle"].clone();
			//lowerBodyAnims["crouch_idle"] = fullBodyAnims["crouch_idle"].clone();
			
			//lowerBody.addAnimation(lowerBodyAnims["combat_idle"] );
			//lowerBody.addAnimation(lowerBodyAnims["crouch_idle"]);
			
			fullBodyController.root = fullBody;
			upperBodyController.root = upperBody;
			lowerBodyController.root = lowerBody;
			
			_curController = fullBodyController;
			fullBody.activate( fullBodyAnims["standing_idle"], 0);
			upperBody.activate( upperBodyAnims["ref_melee_aim"], 0);
			//lowerBody.activate( lowerBodyAnims[""], 0);
			
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
		
		public function setAnimationNode(anim:AnimationNode, controller:AnimationController, switcher:AnimationSwitcher, time:Number):void {
			
			switcher.activate(anim, time);
			_curController = controller;
			if (_skinRotated) {
				skin.rotationZ = Math.PI;
				_skinRotated = false;
			}

			
		}
				

		public function bindKeys(stage:IEventDispatcher):void {
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false, 0, true);
			//stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown, false,0,true);
		}
		public function unbindKeys(stage:IEventDispatcher):void {
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		}
		
		public function handleAttack(attack:uint):void {
			if (attack === PlayerAttack.SWING) {
				swing();
			}
			else if (attack === PlayerAttack.THRUST) {
				thrust();
			}
		}
		
		
		private function onMouseDown(e:MouseEvent):void 
		{
			if (_stance === 0) {
				lowerStanceToggle();
			}
		}
		
		public function lowerStanceToggle():void {
			var tryStance:int = _stance+1;
	
			stance = tryStance > 2 ? 1 : tryStance;
			handleAction(lastAction);
		}
		
		public function raiseStanceToggle():void {
			var tryStance:int = _stance-1;
			
			stance = tryStance < (standEnabled ? 0 : 1) ? 1 : tryStance;
			handleAction(lastAction);
		}
		
		private function onKeyDown(e:KeyboardEvent):void 
		{
			//if (lastAction != 0) return; // only allow switching stance when character is idle (ie. non-moving)
			
			var keyCode:uint = e.keyCode;
		
			
			if (keyCode === Keyboard.Q ) {
				raiseStanceToggle();
			}
			else if (keyCode === Keyboard.CONTROL) {
				lowerStanceToggle();
			}
			else if (_stance ==1  && keyCode === KeyBindings.ACCELERATE) {
				raiseStanceToggle();
			}
		}

		
		public function setJoggingSpeed(speed:Number):void {
			speed_jog = speed;
			speed_run = speed * SPEED_RUN_MULTIPLIER;
		}
		
		private var lastAction:int = PlayerAction.IDLE;
		
		// handles any changes in action!
			public function handleAction(val:int):void {
				var myLastAction:int = lastAction;
				lastAction = val;
				upperBodyDominant = false;
			_running = false;
			_idle = false;
			if (val === PlayerAction.STATE_JUMP) {
				setAnimation(fullBodyAnims["jump"], fullBodyController, fullBody, 0).speed = 1;
			
			//setAnimation(fullBodyAnims["tumbleleft"], fullBodyController, fullBody, 0).speed = 1;
				//(fullBodyAnims["jump"] as AnimationClip).time = .5;
				_curController = fullBodyController;
				_curController.update(0);
				return;
			}	
			else if (val === PlayerAction.IDLE) {
				skin._rotationZ = Math.PI;
				skin.transformChanged = true;
				
				setAnimation(fullBodyAnims[(_stance == 0 ? "standing" : _stanceString) + "_idle"], fullBodyController, fullBody,   myLastAction == 0 ? CROUCH_TIME : 0);  //_lastStance < 3 && _stance < 3 && 
				
					crouchTime =  myLastAction != 0 ? 9999999 : 0;
				
			

				_curController = fullBodyController;
				_idle = true;
				return;
			}
			
			var mask:uint = (1 << val);
			// TODO:: 0 or some blend time >0, depending on whether stance change was changed earlier (crouching to combat/combat to crouching currently set to zero to avoid height discrepancies!)
			
			if ( mask & MASK_STRAFE ) {
					// always do fast turn run animation
					// Am i in runmode or not and is it fast enough to warrant a fast move??
					
					// Else
					//Log.trace(val === PlayerAction.STRAFE_LEFT);
					if (_stance != 2 && !(mask & MASK_STRAFE_FAST)) upperBodyDominant = true;
					
					if (_stance != 2) surfaceMovement.setStrafeSpeed( (mask & MASK_STRAFE_FAST) ? speed_strafe_fast : speed_strafe );
else surfaceMovement.setStrafeSpeed( (mask & MASK_STRAFE_FAST) ? speed_strafe*playerSpeedCrouchRatio*SPEED_CROUCHSTRAFE_MULTIPLIER : speed_strafe*playerSpeedCrouchRatio*SPEED_CROUCHSTRAFE_MULTIPLIER );
surfaceMovement.setWalkSpeeds(speed_strafe*.5 * playerSpeedCrouchRatio*SPEED_CROUCHSTRAFE_MULTIPLIER);
	// TODO: do full body turn run for speed_strafe_fast instead!
					setAnimation(lowerBodyAnims[ (_stance != 2 ?  "combat" : _stanceString) + ( val===PlayerAction.STRAFE_LEFT || val === PlayerAction.STRAFE_LEFT_FAST ? "_moveleft" : "_moveright")], lowerBodyController, lowerBody, 0).speed = surfaceMovement.STRAFE_SPEED * (upperBodyDominant ? I_SPEED_STRAFE_UPPER : I_SPEED_STRAFE_LOWER);
				setAnimation(upperBodyAnims["ref_melee_aim"], upperBodyController, upperBody, .3);
					_curController = null;
					
					
			}
			else if (mask & MASK_WALK) {
				if (mask & MASK_WALK_FORWARD  ) {
					
					if (_stance=== 2 || val != PlayerAction.MOVE_FORWARD_FAST || !standEnabled) {
					
						if (_stance != 2) {
							if (_stance != 1) {  // stance 0
								surfaceMovement.setWalkSpeeds(speed_jog);
								surfaceMovement.setStrafeSpeed(speed_strafe*.5);
								setAnimation(fullBodyAnims["jog"], fullBodyController, fullBody, .3).speed = surfaceMovement.WALK_SPEED * I_SPEED_JOG;
								_curController = fullBodyController;
							}
							else {  // stance 1
								surfaceMovement.setStrafeSpeed(speed_strafe * .5);
					surfaceMovement.WALK_SPEED = (val != PlayerAction.MOVE_FORWARD_FAST ? speed_jog : speed_run) * playerSpeedCombatRatio;
					
					setAnimation(lowerBodyAnims[(_stance != 0 ? _stanceString : "combat")+"_walkforward"], lowerBodyController, lowerBody, 0).speed = surfaceMovement.WALK_SPEED * (I_SPEED_FORWARDS);  // todo: use different walk forward speed for combat
					setAnimation(upperBodyAnims["ref_melee_aim"], upperBodyController, upperBody, .3);
								_curController = null;
								upperBodyDominant = true;
							}
						}
						else {
							//ref_melee_aim
								surfaceMovement.setAllSpeeds( (val != PlayerAction.MOVE_FORWARD_FAST ? speed_jog : speed_run)*SPEED_CROUCH_MULTIPLIER* playerSpeedCrouchRatio );
								setAnimation(lowerBodyAnims["crouch_walkforward"], lowerBodyController, lowerBody, 0).speed = surfaceMovement.WALK_SPEED *  I_SPEED_CROUCH; 
							setAnimation(upperBodyAnims["ref_melee_aim"], upperBodyController, upperBody, .3);
							_curController = null;
							upperBodyDominant = true;
						}
						//setAccelerate(false);
						
						//_running = true;
					}
					else { // sprinting

						_skinRotated = false;
						_running = true;
						setAnimation(fullBodyAnims["run"], fullBodyController, fullBody, .1).speed = speed_run * I_SPEED_RUN;
						_curController = fullBodyController; 
						//skin._rotationZ = Math.PI + (_stance != 2 ? .0 : .02);
						//skin.transformChanged = true;
						//_skinRotated = true;
						surfaceMovement.setWalkSpeeds(speed_jog*SPEED_RUN_MULTIPLIER);
						surfaceMovement.setStrafeSpeed(speed_strafe*.5);
					}
				}
				else {
					surfaceMovement.setStrafeSpeed(speed_strafe * CROUCH_TIME);
					surfaceMovement.WALKBACK_SPEED = _stance != 2 ? (val != PlayerAction.MOVE_BACKWARD_FAST ? speed_backwards : speed_backwards_fast) : speed_backwards * playerSpeedCrouchRatio * SPEED_CROUCHBACK_MULTIPLIER;
					setAnimation(lowerBodyAnims[(_stance != 0 ? _stanceString : "combat")+"_walkback"], lowerBodyController, lowerBody, 0).speed = surfaceMovement.WALKBACK_SPEED * (_stance != 2 ? I_SPEED_BACKWARDS : I_SPEED_CROUCH);
					setAnimation(upperBodyAnims["ref_melee_aim"], upperBodyController, upperBody, .3);
				
				
					_curController = null;
					upperBodyDominant = true; 
				}
				
			}
		}
		
		private var surfaceMovement:SurfaceMovement;
		private var _skinRotated:Boolean = true;
		private var _running:Boolean;
		private var _idle:Boolean;
		public var standEnabled:Boolean = true;
		private var crouchDirection:int = 1;
		
		/* INTERFACE systems.animation.IAnimatable */
		
		private var crouchTime:Number = Number.MAX_VALUE;
	
		public function animate(time:Number):void 
		{
			if (_curController != null) {
				_curController.update(time);  // TODO: inject time into modifed clas
			}
			else {
				if (!upperBodyDominant) {
					upperBodyController.update(time);
					lowerBodyController.update(time);
				}
				else {
					lowerBodyController.update(time);
					upperBodyController.update(time);
				}
			}
			if (!_idle) {
				rootJoint._x = 0;
			//	rootJoint._y = 0;
				rootJoint._z = 0;
			}
			//
			
			/*
			if (_running || stance != 2) {
				ellipsoid.z = 36;
			}
			else {
					ellipsoid.z = 16;
					
			}
			*/
			
			
			var tarSkinZ:Number;
			if ( lastAction == 0) {
				if ((_running || stance != 2) && _lastStance != 2 ) {
					tarSkinZ =  0;
					//ellipsoid.z = 36;
				}
				else {
					if (crouchTime <= CROUCH_TIME) {
						tarSkinZ = crouchDirection > 0 ? PMath.lerp(0, -17, crouchTime / CROUCH_TIME) :  PMath.lerp(-17, 0, crouchTime / CROUCH_TIME);
						crouchTime += time;
					}
					else {
						tarSkinZ = crouchDirection > 0 ? -17 : 0;
					}
					//	ellipsoid.z = 16;	
				}
			}
			else {
				tarSkinZ = _running || _stance != 2  ? 0 : -17;
				
			}
			
			if (tarSkinZ != skin._z) {   // above as well
				skin._z = tarSkinZ;
				skin.transform.l = tarSkinZ;
				skin.inverseTransform.l = -tarSkinZ;
				skin.transformChanged = true;  // this is required for water plane update notification
			}
		}
		

		public function setStanceAndRefresh(val:int):void 
		{
			stance = val;
			handleAction(lastAction);
		}
		
		public function setIdleStance(val:int):void 
		{
			stance = val;
			handleAction(PlayerAction.IDLE);
		}
		
		public function flinch():Number 
		{
			var clip:AnimationClip = fullBodyAnims[ FLINCHES[int(Math.random() * FLINCHES.length)] ];
			clip.time = 0;
			setAnimation(clip, fullBodyController, fullBody, .1);
			//throw new Error(clip.length);
			// temrpoary delayedCall atm
			//TweenLite.delayedCall(clip.length, handleAction, [PlayerAction.IDLE] );
			return clip.length;
		}
			
		
	}

}