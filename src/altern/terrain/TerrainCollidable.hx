package altern.terrain;
import altern.ray.IRaycastImpl;
import components.Transform3D;
import systems.collisions.EllipsoidCollider;
import systems.collisions.ITCollidable;
import util.TypeDefs.Vector3D;
import util.geom.Geometry;

/**
 * ...
 * @author Glidias
 */
class TerrainCollidable implements ITCollidable implements IRaycastImpl
{
	public var terrain:TerrainLOD;
	public var terrainGeom(default, null):Geometry = new Geometry();

	public function new(terrain:TerrainLOD) 
	{
		this.terrain = terrain;
		
	}
	
	
	/* INTERFACE systems.collisions.ITCollidable */
	
	public function collectGeometryAndTransforms(collider:EllipsoidCollider, baseTransform:Transform3D):Void 
	{
		this.terrain.setupCollisionGeometry(collider.sphere, terrainGeom.vertices, terrainGeom.indices, 0, 0);
		terrainGeom.numVertices = terrainGeom.numIndices = terrain.numCollisionTriangles * 3;
		collider.addGeometry(terrainGeom, baseTransform);
	}
	
	
	/* INTERFACE altern.ray.IRaycastImpl */
	
	public function intersectRay(origin:Vector3D, direction:Vector3D, output:Vector3D):Vector3D 
	{
		return terrain.intersectRay(origin, direction, output);
	}
	
}