package alternativa.a3d.rayorcollide 
{
	import alternativa.engine3d.core.RayIntersectionData;
	import flash.geom.Vector3D;
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public interface  ITrajRaycastImpl 
	{
		
		function intersectRayTraj(origin:Vector3D, direction:Vector3D, strength:Number, gravity:Number):RayIntersectionData;
		
		
	}

}