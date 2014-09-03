package systems.player.a3d 
{
	
	import alternativa.engine3d.alternativa3d;
	import alternativa.engine3d.core.Camera3D;
	import alternativa.engine3d.core.Object3D;
	import arena.components.weapon.Weapon;
	import arena.systems.player.IStance;
	import ash.core.Entity;
	import ash.core.System;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import haxe.Log;
	import util.geom.Ray;
	use namespace alternativa3d;
	/**
	 * ...
	 * @author Glidias
	 */
	public class ThirdPersonAiming extends System
	{
		public var cameraRay:Ray = new Ray();
		public var stance:IStance;
		public var maxRange:Number = 9999999;
		public var minPitch:Number = -Math.PI * .5;
		public var maxPitch:Number = Math.PI * .5;
		private const ORIGIN:Vector3D = new Vector3D();
		private var camera:Camera3D;
		private var followObject:Object3D;
		private var offsetX:Number = 0;
		private var offsetY:Number = 0;
		private var offsetZ:Number = 0;
		private var spherePos:Vector3D = new Vector3D();
		private var sphereSideOffset:Number;
		private var sphereHeightOffset:Number;
		private var camForward:Vector3D;
		
		public function setEntity(entity:Entity):void {
			stance = entity.get(IStance) as IStance;
			var weapon:Weapon = entity.get(Weapon) as Weapon;
			maxRange = weapon.range;
			minPitch = weapon.minPitch;
			maxPitch = weapon.maxPitch;
			if (maxPitch == minPitch) maxPitch++;
			
			sphereSideOffset = weapon.sideOffset;
			sphereHeightOffset = weapon.heightOffset;
			
		}
		
		
		
		public function setCameraParameters(followObject:Object3D, camera:Camera3D, camForward:Vector3D, offsetX:Number=0, offsetY:Number=0, offsetZ:Number=0):void {
			this.followObject = followObject;
			this.camera = camera;
			this.camForward = camForward;
			
		}
		
		public function ThirdPersonAiming() 
		{
			
		}
		
		override public function update(time:Number):void {
			//stance.setPitchAim();
			
			if (stance == null || camera == null) return;
			
			cameraRay._orig.x = camera._x;
			cameraRay._orig.y = camera._y;
			cameraRay._orig.z = camera._z;
			
			cameraRay._orig.x = camForward.x;
			cameraRay._orig.y = camForward.y;
			cameraRay._orig.z = camForward.z;
			
			spherePos.x = followObject._x;
			spherePos.y = followObject._y;
			spherePos.z = followObject._z;

			
			var vec:Vector3D = cameraRay.getRayToSphereIntersection(cameraRay._orig, cameraRay._dir, spherePos, maxRange);
				
			var dx:Number = vec.x - spherePos.x;
			var dy:Number = vec.y - spherePos.y;
			var dz:Number = vec.z - spherePos.z;
			
		
			var diffAngle:Number = Math.atan2(dz, Math.sqrt( dx * dx + dy * dz) );
			
			diffAngle  = diffAngle < minPitch ? minPitch : diffAngle > maxPitch ? maxPitch : diffAngle;
			
			stance.setPitchAim((diffAngle-minPitch) / (maxPitch - minPitch), time)
			//if (vec.x*vec.x + vec.y*vec.y + vec.z*vec.z <=
		}
		
	}

}