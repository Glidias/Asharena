/**
 * This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
 * If it is not possible or desirable to put the notice in a particular file, then You may include the notice in a location (such as a LICENSE file in a relevant directory) where a recipient would be likely to look for such a notice.
 * You may add additional accurate notices of copyright ownership.
 *
 * It is desirable to notify that Covered Software was "Powered by AlternativaPlatform" with link to http://www.alternativaplatform.com/ 
 * */

 /**
  * This source code is modified and re-factored in Haxe to support varied situations across different target platforms, including n-gons.
  */
package systems.collisions;



	import components.Transform3D;
	import jeash.geom.Vector3D;
	import util.geom.Geometry;
	import util.geom.ITransform3D;
	import util.TypeDefs;

	 
 #if (flash9 || flash9doc || js )
typedef UInt = Int
typedef Vector<T> = Array<T>
#end

	/**
	 * The class implements the algorithm of the continuous collision of an ellipsoid with the faces.
	 */
	class EllipsoidCollider {
		
		/**
		 * Ellipsoid radius along X axis.
		 */
		public var radiusX:Float;
		
		/**
		 * Ellipsoid radius along Y axis.
		 */
		public var radiusY:Float;
		
		/**
		 * Ellipsoid radius along Z axis.
		 */
		public var radiusZ:Float;
		
		/**
		 * Geometric error. Minimum absolute difference between two values
		 * when they are considered to be different. Default value is 0.001.
		 */
		public var threshold:Float;
		
		private var matrix:Transform3D;
		private var inverseMatrix:Transform3D;
		
		// flag header 4 bits in 32 bit integer, for determining number of sides for convex n-gons. (up to 16 sides), leaving behind 28 bits (up to 268435456) possible vertex indices per geometry. 
		// You can add /reduce space if required in the inline variable, but 16 sides should be sufficient for most cases.

		
		private var geometries:Vector<Geometry>;
		
		private var vertices:Vector<Float>;
		
		
		private var normals:Vector<Float>;
		private var indices:Vector<Int>;
		private var numFaces:Int;
		private var numI:Int;
		
		private var radius:Float;
		private var src:Vector3D;
		private var displ:Vector3D;
		private var dest:Vector3D;
		
		private var collisionPoint:Vector3D;
		private var collisionPlane:Vector3D;
		
		/**
		 * @private 
		 */
		public var sphere:Vector3D;
		private var cornerA:Vector3D;
		private var cornerB:Vector3D;
		private var cornerC:Vector3D;
		private var cornerD:Vector3D;
		private var gotMoved:Bool;
		
		public var timestamp:Int;
		
		
		
		/**
		 * Creates a EllipsoidCollider object.
		 *
		 *  @param radiusX Ellipsoid radius along X axis.
		 * @param radiusY Ellipsoid radius along Y axis.
		 * @param radiusZ Ellipsoid radius along Z axis.
		 */
		public function new(radiusX:Float, radiusY:Float, radiusZ:Float, threshold:Float=0.001) {
			this.threshold = threshold;
			
			this.timestamp = 0;
			
			this.radiusX = radiusX;
			this.radiusY = radiusY;
			this.radiusZ = radiusZ;
			
			matrix = new Transform3D();
			inverseMatrix = new Transform3D();
			sphere = new Vector3D();
			cornerA = new Vector3D();
			cornerB = new Vector3D();
			cornerC = new Vector3D();
			cornerD = new Vector3D();
			
			collisionPoint = new Vector3D();
			collisionPlane = new Vector3D();
			
			geometries = new Vector<Geometry>();
			vertices =   new Vector<Float>();
			normals =  new Vector<Float>();
			indices = new Vector<Int>();
			numI = 0;
			
			displ =  new Vector3D();
			dest = new Vector3D();
			
			src =  new Vector3D();
			

		}

		
		/**
		 * @private 
		 */
		public function calculateSphere(transform:ITransform3D):Void {
			sphere.x = transform.d;
			sphere.y = transform.h;
			sphere.z = transform.l; 
			var sax:Float = transform.a*cornerA.x + transform.b*cornerA.y + transform.c*cornerA.z + transform.d;
			var say:Float = transform.e*cornerA.x + transform.f*cornerA.y + transform.g*cornerA.z + transform.h;
			var saz:Float = transform.i*cornerA.x + transform.j*cornerA.y + transform.k*cornerA.z + transform.l; 
			var sbx:Float = transform.a*cornerB.x + transform.b*cornerB.y + transform.c*cornerB.z + transform.d;
			var sby:Float = transform.e*cornerB.x + transform.f*cornerB.y + transform.g*cornerB.z + transform.h;
			var sbz:Float = transform.i*cornerB.x + transform.j*cornerB.y + transform.k*cornerB.z + transform.l; 
			var scx:Float = transform.a*cornerC.x + transform.b*cornerC.y + transform.c*cornerC.z + transform.d;
			var scy:Float = transform.e*cornerC.x + transform.f*cornerC.y + transform.g*cornerC.z + transform.h;
			var scz:Float = transform.i*cornerC.x + transform.j*cornerC.y + transform.k*cornerC.z + transform.l; 
			var sdx:Float = transform.a*cornerD.x + transform.b*cornerD.y + transform.c*cornerD.z + transform.d;
			var sdy:Float = transform.e*cornerD.x + transform.f*cornerD.y + transform.g*cornerD.z + transform.h;
			var sdz:Float = transform.i*cornerD.x + transform.j*cornerD.y + transform.k*cornerD.z + transform.l;
			var dx:Float = sax - sphere.x;
			var dy:Float = say - sphere.y;
			var dz:Float = saz - sphere.z;
			sphere.w = dx*dx + dy*dy + dz*dz;
			dx = sbx - sphere.x;
			dy = sby - sphere.y;
			dz = sbz - sphere.z;
			var dxyz:Float = dx*dx + dy*dy + dz*dz;
			if (dxyz > sphere.w) sphere.w = dxyz;
			dx = scx - sphere.x;
			dy = scy - sphere.y;
			dz = scz - sphere.z;
			dxyz = dx*dx + dy*dy + dz*dz;
			if (dxyz > sphere.w) sphere.w = dxyz;
			dx = sdx - sphere.x;
			dy = sdy - sphere.y;
			dz = sdz - sphere.z;
			dxyz = dx*dx + dy*dy + dz*dz;
			if (dxyz > sphere.w) sphere.w = dxyz;
			sphere.w = Math.sqrt(sphere.w);
		}
		
		public function prepare(source:Vector3D, displacement:Vector3D):Void {
			
			// Radius of the sphere
			radius = radiusX;
			if (radiusY > radius) radius = radiusY;
			if (radiusZ > radius) radius = radiusZ;
			
			// The matrix of the collider
		
			matrix.compose(source.x, source.y, source.z, 0, 0, 0, radiusX/radius, radiusY/radius, radiusZ/radius);
			inverseMatrix.copy(matrix);
			inverseMatrix.invert();
			
			// Local coordinates
			src.x = 0;
			src.y = 0;
			src.z = 0;
			// Local offset
			displ.x = inverseMatrix.a*displacement.x + inverseMatrix.b*displacement.y + inverseMatrix.c*displacement.z;
			displ.y = inverseMatrix.e*displacement.x + inverseMatrix.f*displacement.y + inverseMatrix.g*displacement.z;
			displ.z = inverseMatrix.i*displacement.x + inverseMatrix.j*displacement.y + inverseMatrix.k*displacement.z;
			// Local destination point
			dest.x = src.x + displ.x;
			dest.y = src.y + displ.y;
			dest.z = src.z + displ.z;
			
			// Bound defined by movement of the sphere
			var rad:Float = radius + displ.length;
			cornerA.x = -rad;
			cornerA.y = -rad;
			cornerA.z = -rad;
			cornerB.x = rad;
			cornerB.y = -rad;
			cornerB.z = -rad;
			cornerC.x = rad;
			cornerC.y = rad;
			cornerC.z = -rad;
			cornerD.x = -rad;
			cornerD.y = rad;
			cornerD.z = -rad;

			// Gathering the faces which with collision can occur
			calculateSphere(matrix);
		}
		
		
		
		public function loopGeometries():Void {
			var rad:Float = radius + displ.length;
			numI = 0;
			
			numFaces = 0;
			var indicesLength:Int = 0;
			var normalsLength:Int = 0;
			
			// Loop geometries
			var j:Int;
		
			var verticesLength:Int = 0;
			var geometriesLength:Int = geometries.length;
			var transform:Transform3D = inverseMatrix;
			var vx:Float;
			var vy:Float;
			var vz:Float;
			var oa;
			var numVertices:Int;
			var geometryIndicesLength:Int;
			var verts:Vector<Float>;
			var geometry:Geometry;
			var nSides:Int;
			var geometryIndices:Vector<UInt>;
			
			if (geometriesLength > 400) {
				trace("Too much geometries!"+geometriesLength);
				return;
			}
			for (i in 0...geometriesLength) {
				geometry = geometries[i];	
				geometryIndices = geometry.indices;
				 geometryIndicesLength = geometryIndices.length;
				 
					verts = geometry.vertices;
					numVertices = geometry.numVertices;
					for (j in 0...numVertices) {
						vx = verts[j * 3];
						vy= verts[j * 3 + 1];
						vz = verts[j * 3 + 2];
						vertices[verticesLength] = transform.a*vx + transform.b*vy + transform.c*vz + transform.d; verticesLength++;
						vertices[verticesLength] = transform.e*vx + transform.f*vy + transform.g*vz + transform.h; verticesLength++;
						vertices[verticesLength] = transform.i*vx + transform.j*vy + transform.k*vz + transform.l; verticesLength++;
					}
					
				// Loop faces  
				j = 0;
				var k:Int = 0;
				//var maxIterations:Int = 400;
				//var count:Int = 0;
			
			//	trace("Total processed vertices"+verticesLength);
				
				while (k < geometryIndicesLength) {   
					j = k;
					var a:Int = geometryIndices[j]; j++;
					nSides = ((a & A3DConst._NMASK_) >> A3DConst._NSHIFT);
					/*
					if (nSides != 4) {
						trace("Invalid nsides:" + nSides);
						nSides = 4;
						return;
					}
			
					
					if (count++ > maxIterations) {
						trace("BREAK OTU!");
						return;
					}
					*/
					
					k += nSides;

					oa = a;  // temp fix
					a &= A3DConst._FMASK_;
					
					var index:Int = a*3;
					var ax:Float = vertices[index]; index++;
					var ay:Float = vertices[index]; index++;
					var az:Float = vertices[index];
					var b:Int = geometryIndices[j]; j++;
					index = b*3;
					var bx:Float = vertices[index]; index++;
					var by:Float = vertices[index]; index++;
					var bz:Float = vertices[index];
					var c:Int = geometryIndices[j]; j++;
					index = c*3;
					var cx:Float = vertices[index]; index++;
					var cy:Float = vertices[index]; index++;
					var cz:Float = vertices[index];
			
	
					
					// Exclusion by bound   // TODO: does n-gons allow for exclusion by bound without looping?  Else remove this test
					
					
					if (nSides == 3) {
						
						if (ax > rad && bx > rad && cx > rad || ax < -rad && bx < -rad && cx < -rad) continue;
						if (ay > rad && by > rad && cy > rad || ay < -rad && by < -rad && cy < -rad) continue;
						if (az > rad && bz > rad && cz > rad || az < -rad && bz < -rad && cz < -rad) continue;
					}
					// The normal
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
					if (len < 0.001) continue;  
					len = 1/Math.sqrt(len);
					normalX *= len;
					normalY *= len;
					normalZ *= len;
					var offset:Float = ax*normalX + ay*normalY + az*normalZ;
					if (offset > rad || offset < -rad) continue;
					indices[indicesLength] = oa; indicesLength++;
					indices[indicesLength] = b; indicesLength++;
					indices[indicesLength] = c; indicesLength++;
					normals[normalsLength] = normalX; normalsLength++;
					normals[normalsLength] = normalY; normalsLength++;
					normals[normalsLength] = normalZ; normalsLength++;
					normals[normalsLength] = offset; normalsLength++;
					for (n in 3...nSides) {  // add more indices if required
						
						c =  geometryIndices[j]; j++;
						indices[indicesLength] = c; indicesLength++;
					}
					numFaces++;
				}
				
				
			
			}
			
				#if (cpp||php)
					geometries.splice(0,arr.length);    
					
				#else
					untyped geometries.length = 0;
				#end
				
				numI = indicesLength;
				
			
		}
		
		
		/**
		 * Calculates destination point from given start position and displacement vector.
		 * @param source Starting point.
		 * @param displacement Displacement vector.
		 * @param collidable An IECollidable implementation responsible for collecting geometry for this instance.
		 * @return Destination point.
		 */
		///*
		public function calculateDestination(source:Vector3D, displacement:Vector3D, collidable:IECollidable):Vector3D {
			
			if (displacement.length <= threshold) {
				gotMoved = false;
				return source.clone();
			}
			gotMoved = true;
			
			timestamp++;
			prepare(source, displacement);
			collidable.collectGeometry(this);
			loopGeometries();
			
			var result:Vector3D;
			if (numFaces > 0) {
			//	var limit:Int = 50;  // Max tries before timing out
				for (i in 0...50) {
					if (checkCollision()) {
						// Offset destination point from behind collision plane by radius of the sphere over plane, along the normal
						var offset:Float = radius + threshold + collisionPlane.w - dest.x*collisionPlane.x - dest.y*collisionPlane.y - dest.z*collisionPlane.z;
						dest.x += collisionPlane.x*offset;
						dest.y += collisionPlane.y*offset;
						dest.z += collisionPlane.z*offset;
						// Fixing up the current sphere coordinates for the next iteration
						src.x = collisionPoint.x + collisionPlane.x*(radius + threshold);
						src.y = collisionPoint.y + collisionPlane.y*(radius + threshold);
						src.z = collisionPoint.z + collisionPlane.z*(radius + threshold);
						// Fixing up velocity vector. The result ordered along plane of collision.
						displ.x = dest.x - src.x;
						displ.y = dest.y - src.y;
						displ.z = dest.z - src.z;
						if (displ.length < threshold) break;
					} else break;
				}
				// Setting the coordinates
				result = new Vector3D(matrix.a*dest.x + matrix.b*dest.y + matrix.c*dest.z + matrix.d, matrix.e*dest.x + matrix.f*dest.y + matrix.g*dest.z + matrix.h, matrix.i*dest.x + matrix.j*dest.y + matrix.k*dest.z + matrix.l);
			} else {
				result = new Vector3D(source.x + displacement.x, source.y + displacement.y, source.z + displacement.z);
			}
			return isNaN2(result.x) ? source.clone() : result;
			//return result;
		}
		
		private static inline function isNaN2(a:Float):Bool {
return a != a;
}
		
		public inline function addGeometry(g:Geometry) 
		{
			geometries.push(g);
		}
	//	*/
		
		/**
		 * Finds first collision from given starting point aling displacement vector.
		 * @param source Starting point.
		 * @param displacement Displacement vector.
		 * @param resCollisionPoint Collision point will be written into this variable.
		 * @param resCollisionPlane Collision plane (defines by normal) parameters will be written into this variable.
		 * @param object The object to use in collision detection. If a container is specified, all its children will be tested for collison with ellipsoid.
		 * @param excludedObjects An associative array whose keys are instances of <code>Object3D</code> and its children.
		 * @return <code>true</code> if collision detected and <code>false</code> otherwise.
		 */
	//	/*
		public function getCollision(source:Vector3D, displacement:Vector3D, resCollisionPoint:Vector3D, resCollisionPlane:Vector3D):Bool {
			
			if (displacement.length <= threshold) return false;
			
			prepare(source, displacement);
			
			if (numFaces > 0) {
				if (checkCollision()) {
					
					// Transform the point to the global space
					resCollisionPoint.x = matrix.a*collisionPoint.x + matrix.b*collisionPoint.y + matrix.c*collisionPoint.z + matrix.d;
					resCollisionPoint.y = matrix.e*collisionPoint.x + matrix.f*collisionPoint.y + matrix.g*collisionPoint.z + matrix.h;
					resCollisionPoint.z = matrix.i*collisionPoint.x + matrix.j*collisionPoint.y + matrix.k*collisionPoint.z + matrix.l;
					
					// Transform the plane to the global space
					var abx:Float;
					var aby:Float;
					var abz:Float;
					if (collisionPlane.x < collisionPlane.y) {
						if (collisionPlane.x < collisionPlane.z) {
							abx = 0;
							aby = -collisionPlane.z;
							abz = collisionPlane.y;
						} else {
							abx = -collisionPlane.y;
							aby = collisionPlane.x;
							abz = 0;
						}
					} else {
						if (collisionPlane.y < collisionPlane.z) {
							abx = collisionPlane.z;
							aby = 0;
							abz = -collisionPlane.x;
						} else {
							abx = -collisionPlane.y;
							aby = collisionPlane.x;
							abz = 0;
						}
					}
					var acx:Float = collisionPlane.z*aby - collisionPlane.y*abz;
					var acy:Float = collisionPlane.x*abz - collisionPlane.z*abx;
					var acz:Float = collisionPlane.y*abx - collisionPlane.x*aby;
					
					var abx2:Float = matrix.a*abx + matrix.b*aby + matrix.c*abz;
					var aby2:Float = matrix.e*abx + matrix.f*aby + matrix.g*abz;
					var abz2:Float = matrix.i*abx + matrix.j*aby + matrix.k*abz;
					var acx2:Float = matrix.a*acx + matrix.b*acy + matrix.c*acz;
					var acy2:Float = matrix.e*acx + matrix.f*acy + matrix.g*acz;
					var acz2:Float = matrix.i*acx + matrix.j*acy + matrix.k*acz;
					
					resCollisionPlane.x = abz2*acy2 - aby2*acz2;
					resCollisionPlane.y = abx2*acz2 - abz2*acx2;
					resCollisionPlane.z = aby2*acx2 - abx2*acy2;
					resCollisionPlane.normalize();
					resCollisionPlane.w = resCollisionPoint.x*resCollisionPlane.x + resCollisionPoint.y*resCollisionPlane.y + resCollisionPoint.z*resCollisionPlane.z;
					
					return true;
				} else {
					return false;
				}
			}
			return false;
		}
		//*/
		
		private function checkCollision():Bool {
			var minTime:Float = 1;
			var displacementLength:Float = displ.length;
			var t:Float;

			// Loop triangles
			var indicesLength:Int = numI;
			var j:Int = 0;
			var i:Int = 0;
			
			var p1x:Float;
			var p1y:Float;
			var p1z:Float;
			var p2x:Float;
			var p2y:Float;
			var p2z:Float;
		
			var nSides:Int;
			
			var locI:Int;
			var k:Int = 0;
			
			//var maxIterations:Int = 400;
		//	var count:Int = 0;
			
			while (k < indicesLength) {
				// Points
				locI = i = k;
				/*
				if (count++ >= maxIterations) {
					
					trace("Brreak out!");
					return false;
				}
				*/
				
				var index:Int = indices[i]; i++;
				nSides = ((index & A3DConst._NMASK_) >> A3DConst._NSHIFT); 	// get number of n-sides from header
				nSides = nSides != 0  ? nSides : 3;   // handle default zero case to 3 sides
				
				/*
				if (nSides != 4) {
					trace("Invalid nsides:" + nSides);
					nSides = 4;
					return false;
				}
				*/
			
				k += nSides;
				
				
				index &= A3DConst._FMASK_;  			// flag out first point header n-side value
				index *= 3; 
				var ax:Float = vertices[index]; index++;
				var ay:Float = vertices[index]; index++;
				var az:Float = vertices[index];
				index = indices[i]*3; i++;
				var bx:Float = vertices[index]; index++;
				var by:Float = vertices[index]; index++;
				var bz:Float = vertices[index];
				index = indices[i]*3; i++;
				var cx:Float = vertices[index]; index++;
				var cy:Float = vertices[index]; index++;
				var cz:Float = vertices[index];
				
				
				
				// Normal
				var normalX:Float = normals[j]; j++;
				var normalY:Float = normals[j]; j++;
				var normalZ:Float = normals[j]; j++;
				var offset:Float = normals[j]; j++;
				var distance:Float = src.x*normalX + src.y*normalY + src.z*normalZ - offset;
				// The intersection of plane and sphere
				var pointX:Float;
				var pointY:Float;
				var pointZ:Float;
				if (distance < radius) {
					pointX = src.x - normalX*distance;
					pointY = src.y - normalY*distance;
					pointZ = src.z - normalZ*distance;
				} else {
					var t:Float = (distance - radius)/(distance - dest.x*normalX - dest.y*normalY - dest.z*normalZ + offset);
					pointX = src.x + displ.x*t - normalX*radius;
					pointY = src.y + displ.y*t - normalY*radius;
					pointZ = src.z + displ.z*t - normalZ*radius;
				}
				// Closest polygon vertex
				var faceX:Float = 0;
				var faceY:Float = 0;
				var faceZ:Float = 0;
				
				var min:Float = 1e+22;
				
				// Loop edges
				//indices.reverse();
				var inside:Bool = true;
				p1x = ax;
				p1y = ay;
				p1z = az;
				
				
				var startI:Int = locI;
				locI++;
				var count:Int = 0;
				for (n in 0...nSides) {
					count++;

					index = count != nSides ? indices[locI] * 3 : (indices[startI] & A3DConst._FMASK_) * 3;
					p2x = vertices[index]; index++; 
					p2y = vertices[index]; index++;
					p2z = vertices[index]; 
				
					locI++;		
					
					var abx:Float = p2x - p1x;
					var aby:Float = p2y - p1y;
					var abz:Float = p2z - p1z;
					var acx:Float = pointX - p1x;
					var acy:Float = pointY - p1y;
					var acz:Float = pointZ - p1z;
					var crx:Float = acz*aby - acy*abz;
					var cry:Float = acx*abz - acz*abx;
					var crz:Float = acy*abx - acx*aby;
					// Case of the point is outside of the polygon
					if (crx*normalX + cry*normalY + crz*normalZ < 0) {
						var edgeLength:Float = abx*abx + aby*aby + abz*abz;
						var edgeDistanceSqr:Float = (crx*crx + cry*cry + crz*crz)/edgeLength;
						if (edgeDistanceSqr < min) {
							// Edge normalization
							edgeLength = Math.sqrt(edgeLength);
							abx /= edgeLength;
							aby /= edgeLength;
							abz /= edgeLength;
							// Distance to intersecion of normal along theedge
							t = abx*acx + aby*acy + abz*acz;
							var acLen:Float;
							if (t < 0) {
								// Closest point is the first one
								acLen = acx*acx + acy*acy + acz*acz;
								if (acLen < min) {
									min = acLen;
									faceX = p1x;
									faceY = p1y;
									faceZ = p1z;
								}
							} else if (t > edgeLength) {
								// Closest point is the second one
								acx = pointX - p2x;
								acy = pointY - p2y;
								acz = pointZ - p2z;
								acLen = acx*acx + acy*acy + acz*acz;
								if (acLen < min) {
									min = acLen;
									faceX = p2x;
									faceY = p2y;
									faceZ = p2z;
								}
							} else {
								// Closest point is on edge
								min = edgeDistanceSqr;
								faceX = p1x + abx*t;
								faceY = p1y + aby*t;
								faceZ = p1z + abz*t;
							}
							
						}
						inside = false;
					}
					
					p1x = p2x;
					p1y = p2y;
					p1z = p2z;
				}
				// Case of point is inside polygon
				if (inside) {
					faceX = pointX;
					faceY = pointY;
					faceZ = pointZ;
				}
				// Vector pointed from closest point to the center of sphere
				var deltaX:Float = src.x - faceX;
				var deltaY:Float = src.y - faceY; 
				var deltaZ:Float = src.z - faceZ;
				// If movement directed to point
				if (deltaX*displ.x + deltaY*displ.y + deltaZ*displ.z <= 0) {
					// reversed vector
					var backX:Float = -displ.x/displacementLength;
					var backY:Float = -displ.y/displacementLength;
					var backZ:Float = -displ.z/displacementLength;
					// Length of Vector pointed from closest point to the center of sphere
					var deltaLength:Float = deltaX*deltaX + deltaY*deltaY + deltaZ*deltaZ;
					// Projection Vector pointed from closest point to the center of sphere  on reversed vector
					var projectionLength:Float = deltaX*backX + deltaY*backY + deltaZ*backZ;
					var projectionInsideLength:Float = radius*radius - deltaLength + projectionLength*projectionLength;
					if (projectionInsideLength > 0) {
						// Time of the intersection
						var time:Float = (projectionLength - Math.sqrt(projectionInsideLength))/displacementLength;
						// Collision with closest point occurs
						if (time < minTime) {
							minTime = time;
							collisionPoint.x = faceX;
							collisionPoint.y = faceY;
							collisionPoint.z = faceZ;
							if (inside) {
								collisionPlane.x = normalX;
								collisionPlane.y = normalY;
								collisionPlane.z = normalZ;
								collisionPlane.w = offset;
							} else {
								deltaLength = Math.sqrt(deltaLength);
								collisionPlane.x = deltaX/deltaLength;
								collisionPlane.y = deltaY/deltaLength;
								collisionPlane.z = deltaZ/deltaLength;
								collisionPlane.w = collisionPoint.x*collisionPlane.x + collisionPoint.y*collisionPlane.y + collisionPoint.z*collisionPlane.z;
							}
						}
					}
				}
				
		
			}
		
			return minTime < 1;
		}
		
		
		
		
	}
//}
