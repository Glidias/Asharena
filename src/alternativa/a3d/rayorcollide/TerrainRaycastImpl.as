package alternativa.a3d.rayorcollide 
{
	import alternativa.engine3d.alternativa3d;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.RayIntersectionData;
	import alternterrain.objects.TerrainLOD;
	import flash.geom.Vector3D;
use namespace alternativa3d;
	
public class TerrainRaycastImpl extends Object3D implements ITrajRaycastImpl {
	

	public var childOrigin:Vector3D = new Vector3D();
	public var childDirection:Vector3D = new Vector3D();
	public var terrainLOD:TerrainLOD;
	
	public var ddaMaxRange:Number = 8192;
	
	public function TerrainRaycastImpl(terrainLOD:TerrainLOD) {
		this.terrainLOD = terrainLOD;
		
		transformChanged = false;
	}
				
	override public function intersectRay(origin:Vector3D, direction:Vector3D):RayIntersectionData {
		
			if (terrainLOD.transformChanged) terrainLOD.composeTransforms();
				
			
			//direction.w = direction.w == 0 ?  1e22  : direction.w;
			var child:Object3D = terrainLOD;
			childOrigin.x = child.inverseTransform.a*origin.x + child.inverseTransform.b*origin.y + child.inverseTransform.c*origin.z + child.inverseTransform.d;
			childOrigin.y = child.inverseTransform.e*origin.x + child.inverseTransform.f*origin.y + child.inverseTransform.g*origin.z + child.inverseTransform.h;
			childOrigin.z = child.inverseTransform.i*origin.x + child.inverseTransform.j*origin.y + child.inverseTransform.k*origin.z + child.inverseTransform.l;
			childDirection.x = child.inverseTransform.a*direction.x + child.inverseTransform.b*direction.y + child.inverseTransform.c*direction.z;
			childDirection.y = child.inverseTransform.e*direction.x + child.inverseTransform.f*direction.y + child.inverseTransform.g*direction.z;
			childDirection.z = child.inverseTransform.i * direction.x + child.inverseTransform.j * direction.y + child.inverseTransform.k * direction.z;
			childDirection.w = direction.w;
			
			var waterData:RayIntersectionData = terrainLOD.intersectRayWater(childOrigin, childDirection);
			var data:RayIntersectionData = direction.w !=0 && direction.w <= ddaMaxRange ? terrainLOD.intersectRayDDA(childOrigin, childDirection) : terrainLOD.intersectRay(childOrigin, childDirection);
			
			if (data != null || waterData != null) {
				//if (waterData) throw new Error(waterData.time + ", "+childOrigin + ", "+childDirection);
				if (data != null) {
					// TODO: time in TerrainLOD is a bit wrong at the moment. Need to check. FOr now, use this temp dotProduct fix!
					data.time = (data.point.x - childOrigin.x) * direction.x + (data.point.y - childOrigin.y) * direction.y + (data.point.z - childOrigin.z) * direction.z;
					
				}

				return data != null ? waterData == null || data.time < waterData.time ? data : waterData : waterData;
			}
			
		
			return null;
			
	}
	
	/* INTERFACE alternativa.a3d.rayorcollide.ITrajRaycastImpl */
	
	public function intersectRayTraj(origin:Vector3D, direction:Vector3D, strength:Number, gravity:Number):RayIntersectionData 
	{
		if (terrainLOD.transformChanged) terrainLOD.composeTransforms();
				
			//direction.w = 256 * 32 * 3;

			//direction.w = direction.w == 0 ?  1e22  : direction.w;
			var child:Object3D = terrainLOD;
			childOrigin.x = child.inverseTransform.a*origin.x + child.inverseTransform.b*origin.y + child.inverseTransform.c*origin.z + child.inverseTransform.d;
			childOrigin.y = child.inverseTransform.e*origin.x + child.inverseTransform.f*origin.y + child.inverseTransform.g*origin.z + child.inverseTransform.h;
			childOrigin.z = child.inverseTransform.i*origin.x + child.inverseTransform.j*origin.y + child.inverseTransform.k*origin.z + child.inverseTransform.l;
			childDirection.x = child.inverseTransform.a*direction.x + child.inverseTransform.b*direction.y + child.inverseTransform.c*direction.z;
			childDirection.y = child.inverseTransform.e*direction.x + child.inverseTransform.f*direction.y + child.inverseTransform.g*direction.z;
			childDirection.z = child.inverseTransform.i * direction.x + child.inverseTransform.j * direction.y + child.inverseTransform.k * direction.z;
			childDirection.w = direction.w;
			
			
		
		
		return terrainLOD.intersectRayTrajectoryDDA(childOrigin, childDirection, strength, gravity);
	}
	
	
	public function transformChildVectors(origin:Vector3D, direction:Vector3D):void 
	{
		if (terrainLOD.transformChanged) terrainLOD.composeTransforms();
				
			//direction.w = 256 * 32 * 3;

			//direction.w = direction.w == 0 ?  1e22  : direction.w;
			var child:Object3D = terrainLOD;
			childOrigin.x = child.inverseTransform.a*origin.x + child.inverseTransform.b*origin.y + child.inverseTransform.c*origin.z + child.inverseTransform.d;
			childOrigin.y = child.inverseTransform.e*origin.x + child.inverseTransform.f*origin.y + child.inverseTransform.g*origin.z + child.inverseTransform.h;
			childOrigin.z = child.inverseTransform.i*origin.x + child.inverseTransform.j*origin.y + child.inverseTransform.k*origin.z + child.inverseTransform.l;
			childDirection.x = child.inverseTransform.a*direction.x + child.inverseTransform.b*direction.y + child.inverseTransform.c*direction.z;
			childDirection.y = child.inverseTransform.e*direction.x + child.inverseTransform.f*direction.y + child.inverseTransform.g*direction.z;
			childDirection.z = child.inverseTransform.i * direction.x + child.inverseTransform.j * direction.y + child.inverseTransform.k * direction.z;
			childDirection.w = direction.w;
			
			
		
	}
	
	
	
	public function intersectRayEdges(origin:Vector3D, direction:Vector3D):RayIntersectionData 
	{
		if (terrainLOD.transformChanged) terrainLOD.composeTransforms();
				
			//direction.w = 256 * 32 * 3;

			//direction.w = direction.w == 0 ?  1e22  : direction.w;
			var child:Object3D = terrainLOD;
			childOrigin.x = child.inverseTransform.a*origin.x + child.inverseTransform.b*origin.y + child.inverseTransform.c*origin.z + child.inverseTransform.d;
			childOrigin.y = child.inverseTransform.e*origin.x + child.inverseTransform.f*origin.y + child.inverseTransform.g*origin.z + child.inverseTransform.h;
			childOrigin.z = child.inverseTransform.i*origin.x + child.inverseTransform.j*origin.y + child.inverseTransform.k*origin.z + child.inverseTransform.l;
			childDirection.x = child.inverseTransform.a*direction.x + child.inverseTransform.b*direction.y + child.inverseTransform.c*direction.z;
			childDirection.y = child.inverseTransform.e*direction.x + child.inverseTransform.f*direction.y + child.inverseTransform.g*direction.z;
			childDirection.z = child.inverseTransform.i * direction.x + child.inverseTransform.j * direction.y + child.inverseTransform.k * direction.z;
			childDirection.w = direction.w;
			
			//childDirection.scaleBy(1 / child.scaleX);
		
		return terrainLOD.intersectRayEdgesDDA(childOrigin, childDirection);
	}
	
	
	
}
}