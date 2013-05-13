package systems.player.a3d 
{
	import alternativa.engine3d.animation.AnimationClip;
	import alternativa.engine3d.animation.AnimationController;
	import alternativa.engine3d.animation.AnimationCouple;
	import alternativa.engine3d.animation.AnimationSwitcher;
	import alternativa.engine3d.objects.Skin;
	import flash.utils.Dictionary;
	import systems.animation.IAnimatable;
	import systems.player.PlayerAction;
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
		
		//public var standMeleeCouple:AnimationCouple = new AnimationCouple();
		
		private var _crouching:Boolean = false;
		private var _isCombat:Boolean = false;

		
		public var priority:int;
		public var strafeFirst:Boolean;
		private const MASK_STRAFE:int = (PlayerAction.STRAFE_LEFT_FAST | PlayerAction.STRAFE_RIGHT_FAST | PlayerAction.STRAFE_LEFT | PlayerAction.STRAFE_RIGHT);
		
		
		public function GladiatorStance(skin:Skin) 
		{
			strafeFirst = false;

			
			this.skin = skin;
			anims = ANIM_MANAGER.cloneFor(skin);
			init();
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
		
		
		// handles any changes in action!
		public function handleAction(val:int):void {
			
			if (val === PlayerAction.STATE_JUMP) {
				fullBody.activate(fullBodyAnims["jump"], .1);
				_curController = fullBodyController;
				return;
			}
			
			if (val === PlayerAction.IDLE) {
				return;
			}
			
			
			var mask:uint = (1 << val);
				if (mask & MASK_STRAFE ) {
						
					// always do fast turn run animation
				}
		}
		
		/* INTERFACE systems.animation.IAnimatable */
		
		public function animate(time:Number):void 
		{
			_curController.update();  // TODO: inject time into modifed clas
		}
			

			
		
		
	}

}