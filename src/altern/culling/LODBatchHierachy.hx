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
	
	var _stack:Array<DBVHNode<LODNodeData>> = [];
	var _stack2:Array<DBVHNode<LODNodeData>> = [];  // stack to remove
	
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
		var leafCount:Int = 0;
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
			tree.insertLeaf(getLeafWithAABB(sampleAABB, leafCount++));
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
	
	public function cull():Void {
		//culler.cullingInFrustum(culling,
		
		for (i in 0...lodBatches.length) {
			lodBatches[i].reset();
		}
		
		var s:Int = 0;
		var s2:Int = 0;
		var stack = _stack;
		var stack2 = _stack2;
		//stack[s++] = tree.root;
		

		var culling:Int = 63;
		
		var node:DBVHNode<LODNodeData>;
		
		node = tree.root;
		culling = culler.cullingInFrustum(culling, node.aabb.minX, node.aabb.minY, node.aabb.minZ, node.aabb.maxX, node.aabb.maxY, node.aabb.maxZ);
		
		node.data.culling = culling;
		if (culling >= 0) {
			stack[s++] = tree.root;
		} else {
			stack2[s2++] = tree.root;
		}
		
		var batch:LODBatch;
		var child;
		var cCulling:Int;
		while (--s >= 0) {
			node = stack[s];

			child = node.child1;
			cCulling = culler.cullingInFrustum(node.data.culling, child.aabb.minX, child.aabb.minY, child.aabb.minZ, child.aabb.maxX, child.aabb.maxY, child.aabb.maxZ);
			if (child.data.culling != cCulling || cCulling >= 1) {
				
				if (cCulling >= 0) {
					if (!child.isLeaf()) {
						stack[s++] = child;
					} else if (child.data.culling == -1) {
						if (child.data.lodTimestamp != lodTimestamp) {
							child.data.lodTimestamp = lodTimestamp;
						}
						batch = lodBatches[child.data.maxLOD];
						batch.addInstance(child.data.instance);
					}
					child.data.culling = cCulling;
				} else {
					stack2[s2++] = child;
				}
			}
			
			
			child = node.child2;
			cCulling = culler.cullingInFrustum(node.data.culling, child.aabb.minX, child.aabb.minY, child.aabb.minZ, child.aabb.maxX, child.aabb.maxY, child.aabb.maxZ);
			if (child.data.culling != cCulling || cCulling >= 1) {
				if (cCulling >= 0) {
					if (!child.isLeaf()) {
						stack[s++] = child;
					} else if (child.data.culling == -1) {
						if (child.data.lodTimestamp != lodTimestamp) {
							child.data.lodTimestamp = lodTimestamp;
						}
						batch = lodBatches[child.data.maxLOD];
						batch.addInstance(child.data.instance);
					}
					child.data.culling = cCulling;
				} else {
					stack2[s2++] = child;
				}
				
			}
			
		}
		
		
		while (--s2 >= 0) {
			node = stack2[s2];
			var lastCulling:Int = node.data.culling;
			node.data.culling = -1;
			
			if (node.isLeaf()) {
				if (lastCulling >= 0) {
					batch = lodBatches[node.data.maxLOD];
					batch.removeInstance(node.data.instance);
				}
				continue;
			}
			//if (node.child1!=null) {
			stack2[s2++] = node.child1;
			//}
			//if (node.child2!=null) {
			stack2[s2++] = node.child2;
		}
		
		for (i in 0...lodBatches.length) {
			lodBatches[i].updateInstanceLen();
		}

	}
	

	
	
	public function updateLOD():Void {
		var timestamp:Int = lodTimestamp++;
		
		var s:Int = 0;
		var stack = _stack;
		stack[s++] = tree.root;
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
	
	public var lastInstanceLen:Int = 0;
	public var instanceLen:Int = 0;
	public inline function updateInstanceLen():Void {
		lastInstanceLen = instanceLen;
		instanceLen += (addCount - removeCount);
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