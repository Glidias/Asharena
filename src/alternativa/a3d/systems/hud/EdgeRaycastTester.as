package alternativa.a3d.systems.hud
{
	import alternativa.a3d.controller.ThirdPersonController;
	import alternativa.a3d.rayorcollide.TerrainRaycastImpl;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.RayIntersectionData;
	import alternterrain.objects.TerrainLOD;
	import arena.views.hud.ArenaHUD;
	import ash.core.System;
	import components.Pos;
	import flash.geom.Vector3D;
	import alternativa.a3d.rayorcollide.ITrajRaycastImpl;
	import haxe.Log;
	import util.geom.Vec3;
	import alternativa.engine3d.alternativa3d;
	use namespace alternativa3d;
	
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class EdgeRaycastTester extends System
	{
		private var impl:TerrainRaycastImpl;
		private var thirdPersonController:ThirdPersonController;
		
		public var direction:Vector3D = new Vector3D();
		public var origin:Vector3D = new Vector3D();
		
		
		public function EdgeRaycastTester(impl:TerrainRaycastImpl, thirdPersonController:ThirdPersonController)
		{
			this.thirdPersonController = thirdPersonController;
			
			
			this.impl = impl;
		}
		
		
		
		
		override public function update(t:Number):void
		{
			
		//	impl.intersectRayEdgesDDA(origin, direction,);
		//	20.4318 * ArenaHUD.METER_UNIT_SCALE * .5, 255
			 var followTarget:Object3D = thirdPersonController.thirdPerson.followTarget;
			origin.x = followTarget._x;
			origin.y = followTarget._y;
			origin.z = followTarget._z;
			
			direction.w = 128 + 16;
			var rot:Number = followTarget._rotationZ + Math.PI*.5;
			
			direction.x = Math.cos(rot);
			direction.y = Math.sin(rot);
			direction.z = 0;
			
			
			var data:RayIntersectionData = impl.intersectRayEdges(origin, direction);
			if (data != null) {
				Log.trace(data.time);
				
			}
			else {
				Log.trace("No hit");
			}
			
		}
	}

}