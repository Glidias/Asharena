package altern.terrain;
import components.Transform3D;
import systems.collisions.EllipsoidCollider;
import systems.collisions.ITCollidable;

/**
 * ...
 * @author Glidias
 */
class TerrainCollidable implements ITCollidable
{
	public var terrain:TerrainLOD;

	public function new(terrain:TerrainLOD) 
	{
		this.terrain = terrain;
		
	}
	
	
	/* INTERFACE systems.collisions.ITCollidable */
	
	public function collectGeometryAndTransforms(collider:EllipsoidCollider, baseTransform:Transform3D):Void 
	{
		this.terrain.setupCollisionGeometry(collider.sphere, collider.vertices, collider.indices, collider, 0, 0);
		terrainGeom.numVertices = terrainGeom.numIndices = terrain.numCollisionTriangles * 3;
		//collider.addGeometry(terrainGeom, baseTransform);
	}
	
}