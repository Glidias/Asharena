package altern.culling;
import altern.collisions.dbvt.AbstractAABB;
import altern.collisions.dbvt.DBVT;
import altern.collisions.dbvt.DBVTNode;
import altern.collisions.dbvt.DBVTProxy;
import altern.terrain.ICuller;
import de.polygonal.ds.NativeFloat32Array;

/**
 * Integrated LOD/Culling solution targeted for 3D engine platforms
 * https://github.com/Glidias/Asharena/wiki/Game-3D-rendering-generation-systems#integrated-batchinglodculling-system
 * @author Glidias
 */
class LODBatchHierachy 
{
	//public var tree:BVHTree
	var lodDistances:NativeFloat32Array;
	var lodGroupBoundSizes:NativeFloat32Array;
	public var tree:DBVT;
	public var culler:ICuller;
	
	public var culling:Int;
	
	// may assume 4x4 matrix pallette array for batching? (<- Playcanvas engine uses this)
	// Or seperate it out to differnet function references:
	
	// DynamicClones.prototype.getPositionAtIndex = function(i, pos) 
	// DynamicClones.prototype.setPositionAtIndex = function(i, pos) 
	// DynamicClones.prototype.setTransformDataAtIndex = f unction(i, pe)
	// DynamicClones.prototype.deleteTransformDataAtIndex = function(i)
	// DynamicClones.prototype.deletePositionAtIndex = function(i)
	// DynamicClones.prototype.popClone = function(i)
	// DynamicClones.prototype.updateMatrixPaletteAtWithPos = function(i, pe)
	// DynamicClones.prototype.invalidateMatrixPalette = ...

	
	// need to notify if matrix palllete invalidationn for refresh as well
	
	public function new(culler:ICuller, lodDistances:NativeFloat32Array=null, lodGroupBoundSizes:NativeFloat32Array=null) 
	{
		this.lodDistances = lodDistances;
		this.lodGroupBoundSizes = lodGroupBoundSizes;
		tree = new DBVT();
		
		culling = -1;
	}
	
	
	// Clone placements
	public function insertWithAABBAndPositions(aabb:AbstractAABB, positions:NativeFloat32Array, obj:Dynamic):Void {
		
	}
	public function insertWithAABBAndPositionAndRots(aabb:AbstractAABB, posRots:NativeFloat32Array, obj:Dynamic):Void {
		
	}
	public function insertWithAABBAndTransforms(aabb:AbstractAABB, posRots:NativeFloat32Array, obj:Dynamic):Void {
		
	}
	
	public function insertLeaves(leaves:Array<DBVTNode>):Void {
		
	}
	
	public function cull(culling:Int):Void {
		//culler.cullingInFrustum(culling,
	}
	
	
	public function update():Void {
		
	}
	
}