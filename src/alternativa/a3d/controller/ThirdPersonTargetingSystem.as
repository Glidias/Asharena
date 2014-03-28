package alternativa.a3d.controller 
{
	import alternativa.engine3d.controllers.OrbitCameraMan;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.alternativa3d;
	import systems.player.PlayerTargetingSystem;
	import systems.player.PlayerTargetNode;
	use namespace alternativa3d;
	
	/**
	 * ...
	 * @author ...
	 */
	public class ThirdPersonTargetingSystem extends PlayerTargetingSystem
	{
		public var thirdPerson:OrbitCameraMan;
		
		private var maxRangeSquared:Number = Number.MAX_VALUE;
		public function setMaxRange(val:Number):void {
			
		}
		
		public function ThirdPersonTargetingSystem(thirdPerson:OrbitCameraMan) 
		{
			this.thirdPerson = thirdPerson;
		}
		
		override public function isValidTarget(node:PlayerTargetNode):Boolean {

			return node.obj != thirdPerson._followTarget;
		}
		
		override public function calculateRay():void {
		
			ray_origin.x = thirdPerson.controller._target._x;
			ray_origin.y = thirdPerson.controller._target._y;
			ray_origin.z = thirdPerson.controller._target._z;
			
			ray_travel.x = thirdPerson.cameraForward.x;
			ray_travel.y = thirdPerson.cameraForward.y;
			ray_travel.z = thirdPerson.cameraForward.z;
		}
	}

}