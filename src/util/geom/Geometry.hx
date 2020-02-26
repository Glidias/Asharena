package util.geom;

/**
 * Basic geometry class to support collision detection/raycasting/etc., or some basic 3D
 * @author Glenn Ko
 */
 import altern.culling.CullingPlane;
 import altern.culling.DefaultCulling;
 import altern.culling.IFrustumCollectTri;
 import altern.geom.Face;
 import altern.geom.Vertex;
 import altern.geom.Wrapper;
 import altern.ray.IRaycastImpl;
 import components.Transform3D;
 import systems.collisions.EllipsoidCollider;
 import systems.collisions.IECollidable;
 import systems.collisions.ITCollidable;
 import util.TypeDefs;
 
 #if alternExpose @:expose #end
class Geometry implements ITECollidable implements IRaycastImpl implements IFrustumCollectTri
{
	public var vertices:Vector<Float>;
	
	public var indices:Vector<UInt>;
	
	//public var normals:Vector<Float>;
	public var numVertices:Int;
	public var numIndices:Int;
	static public  var IDENTITY:Transform3D = new Transform3D();

	public function new() 
	{
		vertices = new Vector<Float>();
		indices = new Vector<UInt>();
		//normals = [];
		numVertices = 0;
		numIndices = 0;
	}
	
	/*
	public inline function addVertex(x:Float, y:Float, z:Float):Int {
		
		var b:Int = numVertices * 3;
		vertices[b] = x; b++;
		vertices[b] = y; b++;
		vertices[b] = z;
		b = numVertices;
		numVertices++;
		return b;
	}
	
	public function pushVertices(values:Vector<Float>):Void {
		var len:Int= values.length;
		var numVF:Float = len / 3;
		len = Math.floor( numVF);
		if (len != numVF) {
			trace("Invalid push vertices. Values not divisible by 3!");
			return;
		}
		numVertices += len;
		len = values.length;
		for (i in 0...len) {
			vertices.push(values[i]);
			
		}
	}
	*/

	public inline function setVertices(val:Vector<Float>):Void {
		vertices = val;
		numVertices = Std.int( val.length / 3);
	}
	
	public inline function setIndices(val:Vector<UInt>):Void {
		indices = val;
		numIndices = val.length;
	}
	
	/*
	public inline function addTriFaces(indices:Vector<UInt>, d:Int=-1):Void {
		var i:Int = 0;
		var addFaceBuffer:Vector<UInt> = TypeDefs.createUIntVector(3, true);
		var len:Int = indices.length;
		while ( i < len) {
			addFaceBuffer[0] = indices[i];
			addFaceBuffer[1] = indices[i + 1];
			addFaceBuffer[2] = indices[i + 2];
			
			addFace(addFaceBuffer, d);
			i += 3;
		}
	}
	
	public inline function addFace(valIndices:Vector<UInt>, d:Int=-1):Void {
		//if (valIndices.length < 3) trace("Invalid n-gon length:" + valIndices.length);

		if (d < 0) d = indices.length;
		var d:Int = indices.length;
		var len:Int = valIndices.length;
	
		var header:Int = ( (valIndices.length << A3DConst._NSHIFT) | valIndices[0] ); 
		indices[d++] = header;  
		for (i in 1...len) {
			indices[d++] = valIndices[i];
		}
		
		numIndices = d;
		
	}
	*/
	
	/* INTERFACE systems.collisions.IECollidable */
	
	public function collectGeometry(collider:EllipsoidCollider):Void 
	{
		collider.addGeometry(this, collider.inverseMatrix);
	}
	
	/* INTERFACE systems.collisions.ITCollidable */
	
	public function collectGeometryAndTransforms(collider:EllipsoidCollider, baseTransform:Transform3D):Void 
	{
		collider.addGeometry(this, baseTransform);
	}
	
	
	/* INTERFACE altern.ray.IRaycastImpl */
	
	static var sampleRayPoint:Vector3D = new Vector3D();
	#if triOnly
	public function intersectRay(origin:Vector3D, direction:Vector3D, res:Vector3D):Vector3D 
	{
		var ox:Float = origin.x;
		var oy:Float = origin.y;
		var oz:Float = origin.z;
		var dx:Float = direction.x;
		var dy:Float = direction.y;
		var dz:Float = direction.z;

		var nax:Float;
		var nay:Float;
		var naz:Float;

		var nbx:Float;
		var nby:Float;
		var nbz:Float;

		var ncx:Float;
		var ncy:Float;
		var ncz:Float;

		var nrmX:Float;
		var nrmY:Float;
		var nrmZ:Float;

		var point:Vector3D = null;
		var minTime:Float = res.w != 0 ? res.w : direction.w != 0 ? direction.w : 1e+22;
		var numTriangles:Int = Math.floor(numIndices / 3);
		var count:Int =  numTriangles * 3;
		var pIndex:Int = 0;
		var i:Int = 0;
		while ( i < count) {
			var indexA:UInt = indices[i];
			var indexB:UInt = indices[(i + 1)];
			var indexC:UInt = indices[(i + 2)];
		
			pIndex = indexA*3;
			var ax:Float = vertices[pIndex++];
			var ay:Float = vertices[pIndex++];
			var az:Float = vertices[pIndex];
			
			pIndex = indexB*3;
			var bx:Float = vertices[pIndex++];
			var by:Float = vertices[pIndex++];
			var bz:Float = vertices[pIndex];

			pIndex = indexC*3;
			var cx:Float = vertices[pIndex++];
			var cy:Float = vertices[pIndex++];
			var cz:Float = vertices[pIndex];

			var abx:Float = bx - ax;
			var aby:Float = by - ay;
			var abz:Float = bz - az;
			var acx:Float = cx - ax;
			var acy:Float = cy - ay;
			var acz:Float = cz - az;
			var normalX:Float = acz*aby - acy*abz;
			var normalY:Float = acx*abz - acz*abx;
			var normalZ:Float = acy*abx - acx*aby;
			var len:Float = normalX*normalX + normalY*normalY + normalZ*normalZ;
			if (len > 0.001) {
				len = 1/Math.sqrt(len);
				normalX *= len;
				normalY *= len;
				normalZ *= len;
			}
			var dot:Float = dx*normalX + dy*normalY + dz*normalZ;
			if (dot < 0) {
				var offset:Float = ox*normalX + oy*normalY + oz*normalZ - (ax*normalX + ay*normalY + az*normalZ);
				if (offset > 0) {
					var time:Float = -offset/dot;
					if (point == null || time < minTime) {
						var rx:Float = ox + dx*time;
						var ry:Float = oy + dy*time;
						var rz:Float = oz + dz*time;
						abx = bx - ax;
						aby = by - ay;
						abz = bz - az;
						acx = rx - ax;
						acy = ry - ay;
						acz = rz - az;
						if ((acz*aby - acy*abz)*normalX + (acx*abz - acz*abx)*normalY + (acy*abx - acx*aby)*normalZ >= 0) {
							abx = cx - bx;
							aby = cy - by;
							abz = cz - bz;
							acx = rx - bx;
							acy = ry - by;
							acz = rz - bz;
							if ((acz*aby - acy*abz)*normalX + (acx*abz - acz*abx)*normalY + (acy*abx - acx*aby)*normalZ >= 0) {
								abx = ax - cx;
								aby = ay - cy;
								abz = az - cz;
								acx = rx - cx;
								acy = ry - cy;
								acz = rz - cz;
								if ((acz*aby - acy*abz)*normalX + (acx*abz - acz*abx)*normalY + (acy*abx - acx*aby)*normalZ >= 0) {
									if (time < minTime) {
										minTime = time;
										if (point == null) point = sampleRayPoint;
										point.x = rx;
										point.y = ry;
										point.z = rz;
										nax = ax;
										nay = ay;
										naz = az;
										
										nrmX = normalX;
										nbx = bx;
										nby = by;
										nbz = bz;
								
										nrmY = normalY;
										ncx = cx;
										ncy = cy;
										ncz = cz;
										
										nrmZ = normalZ;
									}
								}
							}
						}
					}
				}
			}
			
			i += 3;
		}
		if (point != null) {
			res.x = point.x;
			res.y = point.y;
			res.z = point.z; 
			res.w = minTime;
			return res;
		} else {
			return null;
		}
	}
	#else
	public function intersectRay(origin:Vector3D, direction:Vector3D, res:Vector3D):Vector3D 
	{
		throw "Sorry, not implemented yet for n-gon (non-tri) interesctRay! Compile haxe build with triOnly.";
		return null;
	}
	
	#end
	
	

	/*
	public inline function pushNFaces(indices:Vector<Int>, nSides:Int):Void {
		
	}
	*/
	
	
	/* INTERFACE altern.culling.IFrustumCollectTri */
	
	public function collectTrisForFrustum(frustum:CullingPlane, culling:Int, frustumCorners:Vector<Vector3D>, vertices:Vector<Float>, indices:Vector<UInt>):Void 
	{
		var vi:Int = vertices.length;
		var ii:Int = indices.length;
		
		var len:Int = numIndices;
		var i:Int = 0;
		var pIndex:Int;
		while (i < len) {
			var indexA:UInt = this.indices[i];
			var indexB:UInt = this.indices[(i + 1)];
			var indexC:UInt = this.indices[(i + 2)];
		
			pIndex = indexA*3;
			var ax:Float = this.vertices[pIndex++];
			var ay:Float = this.vertices[pIndex++];
			var az:Float = this.vertices[pIndex];
			
			pIndex = indexB*3;
			var bx:Float = this.vertices[pIndex++];
			var by:Float = this.vertices[pIndex++];
			var bz:Float = this.vertices[pIndex];

			pIndex = indexC*3;
			var cx:Float = this.vertices[pIndex++];
			var cy:Float = this.vertices[pIndex++];
			var cz:Float = this.vertices[pIndex];

			var triFrustumCover:Int;
			if (DefaultCulling.isInFrontOfFrustum(ax, ay, az, bx, by, bz, cx, cy, cz, frustumCorners) && (triFrustumCover = DefaultCulling.triInFrustumCover(frustum, ax, ay, az, bx, by, bz, cx, cy, cz)) >= 0) {
				if (triFrustumCover == 0) {	
					vertices[vi++] = ax; indices[ii] = ii++;
					vertices[vi++] = ay; indices[ii] = ii++;
					vertices[vi++] = az; indices[ii] = ii++;
					
					vertices[vi++] = bx; indices[ii] = ii++;
					vertices[vi++] = by; indices[ii] = ii++;
					vertices[vi++] = bz; indices[ii] = ii++;
					
					vertices[vi++] = cx; indices[ii] = ii++;
					vertices[vi++] = cy; indices[ii] = ii++;
					vertices[vi++] = cz; indices[ii] = ii++;
				}
				else  {	// need to clip nearPlane/farPlane, fan out from clip face for tris
					var w:Wrapper;
					var f:Face;
					var a:Vertex;
					var b:Vertex;
					var c:Vertex ;
					var wn:Wrapper;
					
					f = DefaultCulling.clippedFace;
					if ((triFrustumCover & 1)!=0 && f != null) {
						
						a = f.wrapper.vertex;
						w = f.wrapper.next;
						wn = w.next;
						while (wn != null) {
							b = w.vertex;
							c = wn.vertex;
							vertices[vi++] = a.x; indices[ii] = ii++;
							vertices[vi++] = a.y; indices[ii] = ii++;
							vertices[vi++] = a.z; indices[ii] = ii++;
							
							vertices[vi++] = b.x; indices[ii] = ii++;
							vertices[vi++] = b.y; indices[ii] = ii++;
							vertices[vi++] = b.z; indices[ii] = ii++;
							
							vertices[vi++] = c.x; indices[ii] = ii++;
							vertices[vi++] = c.y; indices[ii] = ii++;
							vertices[vi++] = c.z; indices[ii] = ii++;
							w = w.next;
							wn = wn.next;
						}
						DefaultCulling.collectClippedFace();
					}
					
					f = DefaultCulling.clippedFace2;
					if ((triFrustumCover & 2)!=0 && f != null) {
						
						a = f.wrapper.vertex;
						w = f.wrapper.next;
						wn = w.next;
						while (wn != null) {
							b = w.vertex;
							c = wn.vertex;
							vertices[vi++] = a.x; indices[ii] = ii++;
							vertices[vi++] = a.y; indices[ii] = ii++;
							vertices[vi++] = a.z; indices[ii] = ii++;
							
							vertices[vi++] = b.x; indices[ii] = ii++;
							vertices[vi++] = b.y; indices[ii] = ii++;
							vertices[vi++] = b.z; indices[ii] = ii++;
							
							vertices[vi++] = c.x; indices[ii] = ii++;
							vertices[vi++] = c.y; indices[ii] = ii++;
							vertices[vi++] = c.z; indices[ii] = ii++;
							w = w.next;
							wn = wn.next;
						}
						DefaultCulling.collectClippedFace2();
					}
					
					
					
				}
				
			}
			i += 3;
		}
			
	}
	
}


interface ITECollidable extends IECollidable extends ITCollidable {
}
