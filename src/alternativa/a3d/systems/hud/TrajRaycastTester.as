package alternativa.a3d.systems.hud
{
	import alternativa.engine3d.core.RayIntersectionData;
	import arena.views.hud.ArenaHUD;
	import ash.core.System;
	import components.Pos;
	import flash.geom.Vector3D;
	import alternativa.a3d.rayorcollide.ITrajRaycastImpl;
	import haxe.Log;
	import util.geom.Vec3;
	
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class TrajRaycastTester extends System
	{
		private var impl:ITrajRaycastImpl;
		public var direction:Vector3D;
		public var origin:Vector3D;
		
		
		public function TrajRaycastTester(impl:ITrajRaycastImpl, origin:Vector3D, direction:Vector3D)
		{
			this.origin = origin;
			this.direction = direction;
			this.impl = impl;
		}
		
		
		
		
		override public function update(t:Number):void
		{
		
			var data:RayIntersectionData = impl.intersectRayTraj(origin, direction, 20.4318 * ArenaHUD.METER_UNIT_SCALE * .5, 255);
			if (data != null) {
				//Log.trace(data.time);
				
			}
			else {
			//	Log.trace("No hit");
			}
			
		}
	}

}