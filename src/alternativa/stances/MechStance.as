package alternativa.stances 
{
	import alternativa.engine3d.animation.AnimationClip;
	import alternativa.engine3d.animation.AnimationController;
	import alternativa.engine3d.animation.AnimationCouple;
	import alternativa.engine3d.objects.Joint;
	import alternativa.engine3d.objects.Skin;
	import components.Vel;
	import systems.animation.IAnimatable;
	import systems.player.a3d.AnimationManager;
	import alternativa.engine3d.alternativa3d;
	use namespace alternativa3d;
	
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class MechStance implements IAnimatable 
	{
		private var animManager:AnimationManager;
		private var anim_walk:AnimationClip;
		private var vel:Vel;
		private var controller:AnimationController;
		private var couple:AnimationCouple;
		private var _turretJoint:Joint;
		
		public function MechStance(animManager:AnimationManager, vel:Vel, skin:Skin) 
		{
			this.animManager = animManager;
			this.vel = vel;
			var index:int = animManager.getAnimationIndexByName("walk");
			if (index < 0) index = 0;
			anim_walk = animManager.animClips[index];
			controller = new AnimationController();
			
			
			couple = new AnimationCouple();
			controller.root = couple;
			couple.left = anim_walk;
			couple.right = new AnimationClip();
			_turretJoint = findJointByName(skin._renderedJoints, "Bip01 Spine3");
			

		}
		
		private function findJointByName(joints:Vector.<Joint>, str:String):Joint {
			
			var i:int = joints.length;
			while (--i > -1) {
				if (joints[i].name === str) return joints[i];
			}
			return null;
		}
		
		/* INTERFACE systems.animation.IAnimatable */
		public static var RANGE:Number = 1/44;
		public function animate(time:Number):void 
		{
			var d:Number = Math.sqrt(vel.x * vel.x + vel.y * vel.y + vel.z * vel.z);
			couple.balance = 1 -  d  * RANGE * 1;
			controller.update();
		
		//	anim_walk.update(time, 1);
			//_turretJoint._rotationY += .05;
			//_turretJoint.transformChanged = true;
		}
		
	}

}