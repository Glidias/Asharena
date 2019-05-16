package altern.culling;
import altern.collisions.dbvt.AbstractAABB;
import altern.ds.DBVHTree;
import altern.terrain.ICuller;
import components.BoundBox;
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
	public var lodBatches:Array<LODBatch>;
	var lodTimestamp:Int = 0;
	
	public var tree:DBVHTree<LODNodeData> = new DBVHTree<LODNodeData>();
	public var culler:ICuller;
	
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

	public function new(culler:ICuller, lodDists:Array<Float>=null, lodBoundSizes:Array<Float>=null) 
	{
		this.culler = culler;
		tree.nodeDataFactoryMethod = LODNodeData.create;
		lodBatches = [];
		if (lodDists != null) {
			for (i in 0...lodDists.length) {
				lodBatches[i] = new LODBatch();
			}
			if (lodBoundSizes != null) {
				
			}
		} else {
			lodBatches[0] = new LODBatch();
		}
	}
	
	public inline function getLeafWithAABB(aabb:BoundBox, leafInstance:Int):DBVHNode<LODNodeData> {
		var n = new DBVHNode<LODNodeData>();
		n.aabb.init(aabb.minX, aabb.maxX, aabb.minY, aabb.maxY, aabb.minZ, aabb.maxZ);
		n.data = new LODNodeData();
		n.data.instance = leafInstance;
		return n;
	}
	
	var sampleAABB:BoundBox = new BoundBox();

	
	// Create tree
	public function createWithAABBAndPositions(aabb:AbstractAABB, positions:Array<Float>):Void {
		var len:Int = positions.length;
		var i:Int = 0;
		while (i < len) {
			var x:Float = positions[i];
			var y:Float = positions[i + 1];
			var z:Float = positions[i + 2];
			sampleAABB.minX = x + aabb.minX;
			sampleAABB.minY = y + aabb.minY;
			sampleAABB.minZ = z + aabb.minZ;
			sampleAABB.maxX = x + aabb.maxX;
			sampleAABB.maxY = y + aabb.maxY;
			sampleAABB.maxZ = z + aabb.maxZ;
			tree.insertLeaf(getLeafWithAABB(sampleAABB, i));
			i += 3;
		}
		

	}
	public function createWithAABBAndPositionAndRots(aabb:AbstractAABB, posRots:Array<Float>, processAABBTransform:Bool=true):Void {
		
	}
	public function createWithAABBAndTransforms(aabb:AbstractAABB, transforms:Array<Float>, processAABBTransform:Bool=true, fourByFour:Bool = false):Void {
		
	}
	
	/*
	function insertLeaves(leaves:Array<DBVHNode<LODNodeData>>):Void {
		for (i in 0...leaves.length) {
			tree.insertLeaf(leaves[i]);
		}
	}
	*/
	
	public function cull(culling:Int):Void {
		//culler.cullingInFrustum(culling,
		for (i in 0...lodBatches.length) {
			lodBatches[i].reset();
		}
		
	}
	
	
	public function updateLOD():Void {
		var timestamp:Int = lodTimestamp++;
		
		for (i in 0...lodBatches.length) {
			lodBatches[i].reset();
		}
	}
	
}

/**
 * ...
 * @author Glidias
 */
class LODNodeData {
	
	// Assumption, everything starts from -1 hidden from camera at lowest lod 0
	// CUlling runs first before LOD
	public var culling:Int = -1;
	public var maxLOD:Int = 0;
	public var lodTimestamp:Int = -1;
	public var instance:Int;
	
	public function new() {

	}
	
	public static function create():LODNodeData {
		return new LODNodeData();
	}
}

/*
class LODInstance {
	public var index:Int;
	public var indices:Array<Int>;
	public var raycastable
	public var collidable
}
*/

class LODBatch {
	public var addCount:Int = 0;
	public var removeCount:Int = 0;
	
	public var addIndices:Array<Int>;
	public var removeIndices:Array<Int>;
	

	public inline function reset():Void {
		addCount = 0;
		removeCount = 0;
	}
	
	public inline function addInstance(instance:Int):Void {
		addIndices[addCount++] = instance;
	}
	public inline function removeInstance(instance:Int):Void {
		removeIndices[removeCount++] = instance;
	}
	
	public function new() {
		addIndices = [];
		removeIndices = [];
	}
}