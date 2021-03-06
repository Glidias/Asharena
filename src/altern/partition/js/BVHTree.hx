package altern.partition.js;
import altern.culling.CullingPlane;
import altern.culling.DefaultCulling;
import altern.culling.IFrustumCollectTri;
import altern.geom.Face;
import altern.geom.Vertex;
import altern.geom.Wrapper;
import altern.ray.IRaycastImpl;
import components.BoundBox;
import components.Transform3D;
import de.polygonal.ds.NativeInt32Array;
import de.polygonal.ds.tools.NativeInt32ArrayTools;
import systems.collisions.EllipsoidCollider;
import systems.collisions.ITCollidable;
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
#if alternExpose @:expose #end
class BVHTree 
#if js
	implements ITCollidable
	implements IRaycastImpl
	implements IFrustumCollectTri
#end
{
	#if js
	var bvh:BVH;
	var _result:Vector3D = new Vector3D();
	var geom(default, null):Geometry = new Geometry();
	var _stack:Array<BVHNode> = [];
	var _stackCulling:Array<Int> = [];
	
	var allResults:Array<IntersectionResult>;
	var lastResult:IntersectionResult;
	
	static inline var FLOAT_MAX:Float = 3.40282346638528e+38;

	public function new(bvh:BVH) 
	{
		this.bvh = bvh;
	}
	
	
	var aabbTris:NativeInt32Array = NativeInt32ArrayTools.alloc(64);
	var aabbTriCount:Int = 0;
	public function setBufferAlloc(amt:Int):Void {
		aabbTris = NativeInt32ArrayTools.alloc(amt);
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
		aabbTriCount = 0;
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
					aabbTris[aabbTriCount++] = triIndex;
					triIndex *= 9;
					geom.vertices[vi++] = triArray[triIndex++];
					geom.vertices[vi++] = triArray[triIndex++]; 
					geom.vertices[vi++] = triArray[triIndex++]; geom.indices[ii] = ii++;
					
					geom.vertices[vi++] = triArray[triIndex++]; 
					geom.vertices[vi++] = triArray[triIndex++];
					geom.vertices[vi++] = triArray[triIndex++]; geom.indices[ii] = ii++;
					
					geom.vertices[vi++] = triArray[triIndex++];
					geom.vertices[vi++] = triArray[triIndex++]; 
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
					geom.vertices[vi++] = triArray[triIndex++]; 
					geom.vertices[vi++] = triArray[triIndex++]; 
					geom.vertices[vi++] = triArray[triIndex++]; geom.indices[ii] = ii++;
					
					geom.vertices[vi++] = triArray[triIndex++]; 
					geom.vertices[vi++] = triArray[triIndex++]; 
					geom.vertices[vi++] = triArray[triIndex++]; geom.indices[ii] = ii++;
					
					geom.vertices[vi++] = triArray[triIndex++];
					geom.vertices[vi++] = triArray[triIndex++]; 
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
	
	
	/* INTERFACE altern.culling.IFrustumCollectTri */
	
	public function collectTrisForFrustum(frustum:CullingPlane, culling:Int, frustumCorners:Vector<Vector3D>, vertices:Vector<Float>, indices:Vector<UInt>):Void 
	{
		var vi:Int = vertices.length;
		var ii:Int = indices.length;
		
		var s:Int = 0;
		var stack = _stack;
		var stackCulling = _stackCulling;
		stack[s] = this.bvh._rootNode;
		stackCulling[s] = culling;
		s++;
		var bboxArray = this.bvh._bboxArray;
		var triArray = this.bvh._trianglesArray;
		geom.numIndices = 0;
		geom.numVertices = 0;
		
		
		
		

		aabbTriCount = 0;
		while ( --s >= 0) {
			var node = stack[s];
			var nodeCulling:Int = stackCulling[s];
			if ( (nodeCulling = DefaultCulling.cullingInFrustumOf(frustum, nodeCulling, node._extentsMin.x, node._extentsMin.y, node._extentsMin.z, node._extentsMax.x, node._extentsMax.y, node._extentsMax.z)) >= 0 ) {
				if (node._node0!=null) {
					stack[s] = node._node0;
					stackCulling[s] = nodeCulling;
					s++;
				}

				if (node._node1!=null) {
					stack[s] = node._node1;
					stackCulling[s] = nodeCulling;
					s++;
				}
				
				for (i in node._startIndex...node._endIndex) {
					var triIndex:Int = bboxArray[i * 7];
					triIndex *= 9;
					
					// test individual triangle in frustum based off exit of: all points outside a frustum plane 
					// OR/AND all frustum points lie on one side of the plane
					
					var ax:Float= triArray[triIndex++];
					var ay:Float= triArray[triIndex++];
					var az:Float= triArray[triIndex++];
					
					var bx:Float= triArray[triIndex++];
					var by:Float= triArray[triIndex++];
					var bz:Float= triArray[triIndex++];
					
					var cx:Float= triArray[triIndex++];
					var cy:Float= triArray[triIndex++];
					var cz:Float= triArray[triIndex++];
		
					var triFrustumCover:Int;
					if (DefaultCulling.isInFrontOfFrustum(ax, ay, az, bx, by, bz, cx, cy, cz, frustumCorners) && (triFrustumCover = DefaultCulling.triInFrustumCover(frustum, ax, ay, az, bx, by, bz, cx, cy, cz)) >= 0) {
						if (triFrustumCover == 0) {	
							vertices[vi++] = ax;
							vertices[vi++] = ay; 
							vertices[vi++] = az; indices[ii] = ii++;
							
							vertices[vi++] = bx; 
							vertices[vi++] = by; 
							vertices[vi++] = bz; indices[ii] = ii++;
							
							vertices[vi++] = cx; 
							vertices[vi++] = cy; 
							vertices[vi++] = cz; indices[ii] = ii++;
						}
						else  {	// need to clip farPlane/nearclip, fan out from clip face for tris
							var w:Wrapper;
							var f:Face;
							var a:Vertex;
							var wn:Wrapper;
							var b:Vertex;
							var c:Vertex;
							
							f = DefaultCulling.clippedFace;
							if ((triFrustumCover & 1)!=0 && f!=null) {
								a = f.wrapper.vertex;
								w = f.wrapper.next;
								wn = w.next;
								while (wn != null) {
									b = w.vertex;
									c = wn.vertex;
									vertices[vi++] = a.x;
									vertices[vi++] = a.y;
									vertices[vi++] = a.z; indices[ii] = ii++;
									
									vertices[vi++] = b.x; 
									vertices[vi++] = b.y; 
									vertices[vi++] = b.z; indices[ii] = ii++;
									
									vertices[vi++] = c.x; 
									vertices[vi++] = c.y; 
									vertices[vi++] = c.z; indices[ii] = ii++;
									w = w.next;
									wn = wn.next;
								}
								DefaultCulling.collectClippedFace();
							}
							f = DefaultCulling.clippedFace2;
							if ((triFrustumCover & 2)!=0 && f!=null) {
								a = f.wrapper.vertex;
								w = f.wrapper.next;
								wn = w.next;
								while (wn != null) {
									b = w.vertex;
									c = wn.vertex;
									vertices[vi++] = a.x; 
									vertices[vi++] = a.y; 
									vertices[vi++] = a.z; indices[ii] = ii++;
									
									vertices[vi++] = b.x; 
									vertices[vi++] = b.y; 
									vertices[vi++] = b.z; indices[ii] = ii++;
									
									vertices[vi++] = c.x; 
									vertices[vi++] = c.y;
									vertices[vi++] = c.z; indices[ii] = ii++;
									w = w.next;
									wn = wn.next;
								}
								DefaultCulling.collectClippedFace2();
							}
							
						}
						
					}
				}
			}
		}
	}
	#end
	
}