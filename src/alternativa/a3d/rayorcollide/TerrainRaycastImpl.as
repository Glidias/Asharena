package alternativa.a3d.rayorcollide 
{
	import alternativa.engine3d.alternativa3d;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.RayIntersectionData;
	import alternterrain.objects.TerrainLOD;
	import flash.geom.Vector3D;
use namespace alternativa3d;
	
public class TerrainRaycastImpl extends Object3D {
	

	private var childOrigin:Vector3D = new Vector3D();
	private var childDirection:Vector3D = new Vector3D();
	private var terrainLOD:TerrainLOD;
	
	public var ddaMaxRange:Number = 8192;
	
	public function TerrainRaycastImpl(terrainLOD:TerrainLOD) {
		this.terrainLOD = terrainLOD;
		
		transformChanged = false;
	}
				
	override public function intersectRay(origin:Vector3D, direction:Vector3D):RayIntersectionData {
		
			if (terrainLOD.transformChanged) terrainLOD.composeTransforms();
					
			var child:Object3D = terrainLOD;
			childOrigin.x = child.inverseTransform.a*origin.x + child.inverseTransform.b*origin.y + child.inverseTransform.c*origin.z + child.inverseTransform.d;
			childOrigin.y = child.inverseTransform.e*origin.x + child.inverseTransform.f*origin.y + child.inverseTransform.g*origin.z + child.inverseTransform.h;
			childOrigin.z = child.inverseTransform.i*origin.x + child.inverseTransform.j*origin.y + child.inverseTransform.k*origin.z + child.inverseTransform.l;
			childDirection.x = child.inverseTransform.a*direction.x + child.inverseTransform.b*direction.y + child.inverseTransform.c*direction.z;
			childDirection.y = child.inverseTransform.e*direction.x + child.inverseTransform.f*direction.y + child.inverseTransform.g*direction.z;
			childDirection.z = child.inverseTransform.i * direction.x + child.inverseTransform.j * direction.y + child.inverseTransform.k * direction.z;
			
			var waterData:RayIntersectionData = terrainLOD.intersectRayWater(childOrigin, childDirection);
			var data:RayIntersectionData = direction.w <= ddaMaxRange ? terrainLOD.intersectRayDDA(childOrigin, childDirection) : terrainLOD.intersectRay(childOrigin, childDirection);
			
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
	
}
}