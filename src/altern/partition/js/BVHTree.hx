package altern.partition.js;
import altern.partition.js.BVHTree.IntersectionResult;
import altern.ray.IRaycastImpl;
import components.BoundBox;
import components.Transform3D;
import systems.collisions.EllipsoidCollider;
import systems.collisions.ITCollidable;
import util.TypeDefs.Vector3D;
import util.geom.AABBUtils;
import util.geom.GeomUtil;
import util.geom.Geometry;
import util.TypeDefs;

#if js
import js.html.Float32Array;

// https://github.com/benraziel/bvh-tree/

typedef IntersectionResult = {
	var triangle:Array<BVHVector3>;
	var triangleIndex:Int;
	var intersectionPoint:{x:Float, y:Float, z:Float};
}

@:native("bvhtree.BVH")
extern class BVH {
	function new(triangles:Array<{x:Float,y:Float,z:Float}>, ?maxTrianglesPerNode:Int);
	var _rootNode:BVHNode;
	var _trianglesArray:Float32Array;
	var _bboxArray:Array<Dynamic>;	// it's mixed index and floats... should be Float32Array
	function intersectRay(rayOrigin:{x:Float, y:Float, z:Float}, rayDirection:{x:Float, y:Float, z:Float}, backfaceCulling:Bool):Array<IntersectionResult>;
}

@:native("bvhtree.BVHVector3")
extern class BVHVector3 {
	function new(?x:Float, ?y:Float, ?z:Float);
	var x:Float;
	var y:Float;
	var z:Float;
	//todo: not complete
	//function copy(v:BVHVector3):BVHVector3;
	//function set(x:Float, y:Float, z:Float):BVHVector3;
	
}

@:native("bvhtree.BVHNode")
extern class BVHNode {
	
	var _extentsMin:{x:Float, y:Float, z:Float};
	var _extentsMax:{x:Float, y:Float, z:Float};
	var _startIndex:Int;
    var _endIndex:Int;
    var _level:Int;
	var _node0:BVHNode;
	var _node1:BVHNode;
	
}
#end

/**
 * ...
 * @author Glidias
 */
class BVHTree 
#if js
	implements ITCollidable
	implements IRaycastImpl
#end
{
	#if js
	var bvh:BVH;
	var _result:Vector3D = new Vector3D();
	var geom(default, null):Geometry = new Geometry();
	var _stack:Array<BVHNode> = [];
	
	var allResults:Array<IntersectionResult>;
	var lastResult:IntersectionResult;
	
	static inline var FLOAT_MAX:Float = 3.40282346638528e+38;

	public function new(bvh:BVH) 
	{
		this.bvh = bvh;
	}
	
	
	
	public function collectGeometryFromAABB(aabb:BoundBox):Geometry 
	{
		var s:Int = 0;
		var stack = _stack;
		stack[s++] = this.bvh._rootNode;
		var bboxArray = this.bvh._bboxArray;
		var triArray = this.bvh._trianglesArray;
		geom.numIndices = 0;
		geom.numVertices = 0;
		var ii:Int = 0;
		var vi:Int = 0;
		while ( --s >= 0) {
			var node = stack[s];
			if ( AABBUtils.intersectsBoundValues(aabb, node._extentsMin.x, node._extentsMin.y, node._extentsMin.z, node._extentsMax.x, node._extentsMax.y, node._extentsMax.z) ) {
				if (node._node0!=null) {
					stack[s++] = node._node0;
				}

				if (node._node1!=null) {
					stack[s++] = node._node1;
				}
				
				for (i in node._startIndex...node._endIndex) {
					var triIndex:Int = bboxArray[i * 7];
					triIndex *= 9;
					geom.vertices[vi++] = triArray[triIndex++]; geom.indices[ii] = ii++;
					geom.vertices[vi++] = triArray[triIndex++]; geom.indices[ii] = ii++;
					geom.vertices[vi++] = triArray[triIndex++]; geom.indices[ii] = ii++;
					
					geom.vertices[vi++] = triArray[triIndex++]; geom.indices[ii] = ii++;
					geom.vertices[vi++] = triArray[triIndex++]; geom.indices[ii] = ii++;
					geom.vertices[vi++] = triArray[triIndex++]; geom.indices[ii] = ii++;
					
					geom.vertices[vi++] = triArray[triIndex++]; geom.indices[ii] = ii++;
					geom.vertices[vi++] = triArray[triIndex++]; geom.indices[ii] = ii++;
					geom.vertices[vi++] = triArray[triIndex++]; geom.indices[ii] = ii++;
				}
			}
		}
		if (ii > 0) {
			geom.numVertices = geom.numIndices = ii;
		}
		return geom;
	}
	
	/* INTERFACE systems.collisions.ITCollidable */

	
	public function collectGeometryAndTransforms(collider:EllipsoidCollider, baseTransform:Transform3D):Void 
	{
		var s:Int = 0;
		var stack = _stack;
		stack[s++] = this.bvh._rootNode;
		var bboxArray = this.bvh._bboxArray;
		var triArray = this.bvh._trianglesArray;
		geom.numIndices = 0;
		geom.numVertices = 0;
		var ii:Int = 0;
		var vi:Int = 0;
		while ( --s >= 0) {
			var node = stack[s];
			if ( GeomUtil.boundIntersectSphere(collider.sphere, node._extentsMin.x, node._extentsMin.y, node._extentsMin.z, node._extentsMax.x, node._extentsMax.y, node._extentsMax.z) ) {
				if (node._node0!=null) {
					stack[s++] = node._node0;
				}

				if (node._node1!=null) {
					stack[s++] = node._node1;
				}
				
				for (i in node._startIndex...node._endIndex) {
					var triIndex:Int = bboxArray[i * 7];
					triIndex *= 9;
					geom.vertices[vi++] = triArray[triIndex++]; geom.indices[ii] = ii++;
					geom.vertices[vi++] = triArray[triIndex++]; geom.indices[ii] = ii++;
					geom.vertices[vi++] = triArray[triIndex++]; geom.indices[ii] = ii++;
					
					geom.vertices[vi++] = triArray[triIndex++]; geom.indices[ii] = ii++;
					geom.vertices[vi++] = triArray[triIndex++]; geom.indices[ii] = ii++;
					geom.vertices[vi++] = triArray[triIndex++]; geom.indices[ii] = ii++;
					
					geom.vertices[vi++] = triArray[triIndex++]; geom.indices[ii] = ii++;
					geom.vertices[vi++] = triArray[triIndex++]; geom.indices[ii] = ii++;
					geom.vertices[vi++] = triArray[triIndex++]; geom.indices[ii] = ii++;
				}
			}
		}
		if (ii > 0) {
			geom.numVertices = geom.numIndices = ii;
			collider.addGeometry(geom, baseTransform);
		}
	}
	
	public function purge() {
		TypeDefs.setVectorLen(_stack, 0);
		
	}
	
	/* INTERFACE altern.ray.IRaycastImpl */
	
	public function intersectRay(origin:Vector3D, direction:Vector3D, output:Vector3D):Vector3D 
	{
		// for now: use lazy/ use native library function approach...
		var res:Array<IntersectionResult> = bvh.intersectRay(origin, direction, true);
		if (res != null && res.length != 0) {
			var directionLength = direction.length;
			var highestResult:IntersectionResult = null;
			var cd:Float = direction.w != 0 ? direction.w : 1e+22;
			cd *= cd;
			for (i in 0...res.length) {
				var r:IntersectionResult = res[i];
				var dx:Float = r.intersectionPoint.x - origin.x;
				var dy:Float = r.intersectionPoint.y - origin.y;
				var dz:Float = r.intersectionPoint.z - origin.z;
				var d:Float = dx * dx + dy * dy + dz * dz;
				if (d <= cd) {
					highestResult = r;
					cd = d;
				}
			}
			if (highestResult != null) {
				_result.x = highestResult.intersectionPoint.x;
				_result.y = highestResult.intersectionPoint.y;
				_result.z = highestResult.intersectionPoint.z;
				_result.w = Math.sqrt(cd) / directionLength;
				allResults = res;
				lastResult = highestResult;
				return _result;
			}
		}
		return null;
	}
	#end
	
}