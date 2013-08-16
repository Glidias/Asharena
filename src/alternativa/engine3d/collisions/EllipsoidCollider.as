package alternativa.engine3d.collisions {
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.VertexAttributes;
	import alternativa.engine3d.core.VertexStream;
	import alternativa.engine3d.resources.Geometry;
	import flash.geom.Vector3D;
	import alternativa.engine3d.core.Transform3D;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	import systems.collisions.CollisionEvent;
	import systems.collisions.IECollidable;
	import alternativa.engine3d.alternativa3d;
	use namespace alternativa3d;

	public class EllipsoidCollider {
		public function EllipsoidCollider(radiusX : Number = NaN,radiusY : Number = NaN,radiusZ : Number = NaN,threshold : Number = 0.001) : void { 
			this.threshold = threshold;
			this.timestamp = 0;
			this.radiusX = radiusX;
			this.radiusY = radiusY;
			this.radiusZ = radiusZ;
			this.matrix = new alternativa.engine3d.core.Transform3D();
			this.inverseMatrix = new alternativa.engine3d.core.Transform3D();
			this.sphere = new flash.geom.Vector3D();
			this.cornerA = new flash.geom.Vector3D();
			this.cornerB = new flash.geom.Vector3D();
			this.cornerC = new flash.geom.Vector3D();
			this.cornerD = new flash.geom.Vector3D();
			this.collisionPoint = new flash.geom.Vector3D();
			this.collisionPlane = new flash.geom.Vector3D();
			this.resCollisionPoint = new flash.geom.Vector3D();
			this.resCollisionPlane = new flash.geom.Vector3D();
			this.geometries = new Vector.<alternativa.engine3d.resources.Geometry>();
			this.transforms = new Vector.<alternativa.engine3d.core.Transform3D>();
			this.numGeometries = 0;
			this.vertices = new Vector.<Number>();
			this.normals = new Vector.<Number>();
			this.indices = new Vector.<int>();
			this.numI = 0;
			this.displ = new flash.geom.Vector3D();
			this.dest = new flash.geom.Vector3D();
			this.src = new flash.geom.Vector3D();
		}
		
		protected function checkCollision() : Number {
			var minTime:Number = 1;
			var displacementLength:Number = displ.length;
			// Loop triangles
			var indicesLength:int = numFaces*3;
			for (var i:int = 0, j:int = 0; i < indicesLength;) {
				// Points
				var index:int = indices[i]*3; i++;
				var ax:Number = vertices[index]; index++;
				var ay:Number = vertices[index]; index++;
				var az:Number = vertices[index];
				index = indices[i]*3; i++;
				var bx:Number = vertices[index]; index++;
				var by:Number = vertices[index]; index++;
				var bz:Number = vertices[index];
				index = indices[i]*3; i++;
				var cx:Number = vertices[index]; index++;
				var cy:Number = vertices[index]; index++;
				var cz:Number = vertices[index];
				// Normal
				var normalX:Number = normals[j]; j++;
				var normalY:Number = normals[j]; j++;
				var normalZ:Number = normals[j]; j++;
				var offset:Number = normals[j]; j++;
				var distance:Number = src.x*normalX + src.y*normalY + src.z*normalZ - offset;
				// The intersection of plane and sphere
				var pointX:Number;
				var pointY:Number;
				var pointZ:Number;
				if (distance < radius) {
					pointX = src.x - normalX*distance;
					pointY = src.y - normalY*distance;
					pointZ = src.z - normalZ*distance;
				} else {
					var t:Number = (distance - radius)/(distance - dest.x*normalX - dest.y*normalY - dest.z*normalZ + offset);
					pointX = src.x + displ.x*t - normalX*radius;
					pointY = src.y + displ.y*t - normalY*radius;
					pointZ = src.z + displ.z*t - normalZ*radius;
				}
				// Closest polygon vertex
				var faceX:Number;
				var faceY:Number;
				var faceZ:Number;
				var min:Number = 1e+22;
				// Loop edges
				var inside:Boolean = true;
				for (var k:int = 0; k < 3; k++) {
					var p1x:Number;
					var p1y:Number;
					var p1z:Number;
					var p2x:Number;
					var p2y:Number;
					var p2z:Number;
					if (k == 0) {
						p1x = ax;
						p1y = ay;
						p1z = az;
						p2x = bx;
						p2y = by;
						p2z = bz;
					} else if (k == 1) {
						p1x = bx;
						p1y = by;
						p1z = bz;
						p2x = cx;
						p2y = cy;
						p2z = cz;
					} else {
						p1x = cx;
						p1y = cy;
						p1z = cz;
						p2x = ax;
						p2y = ay;
						p2z = az;
					}
					var abx:Number = p2x - p1x;
					var aby:Number = p2y - p1y;
					var abz:Number = p2z - p1z;
					var acx:Number = pointX - p1x;
					var acy:Number = pointY - p1y;
					var acz:Number = pointZ - p1z;
					var crx:Number = acz*aby - acy*abz;
					var cry:Number = acx*abz - acz*abx;
					var crz:Number = acy*abx - acx*aby;
					// Case of the point is outside of the polygon
					if (crx*normalX + cry*normalY + crz*normalZ < 0) {
						var edgeLength:Number = abx*abx + aby*aby + abz*abz;
						var edgeDistanceSqr:Number = (crx*crx + cry*cry + crz*crz)/edgeLength;
						if (edgeDistanceSqr < min) {
							// Edge normalization
							edgeLength = Math.sqrt(edgeLength);
							abx /= edgeLength;
							aby /= edgeLength;
							abz /= edgeLength;
							// Distance to intersecion of normal along theedge
							t = abx*acx + aby*acy + abz*acz;
							var acLen:Number;
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
				}
				// Case of point is inside polygon
				if (inside) {
					faceX = pointX;
					faceY = pointY;
					faceZ = pointZ;
				}
				// Vector pointed from closest point to the center of sphere
				var deltaX:Number = src.x - faceX;
				var deltaY:Number = src.y - faceY; 
				var deltaZ:Number = src.z - faceZ;
				// If movement directed to point
				if (deltaX*displ.x + deltaY*displ.y + deltaZ*displ.z <= 0) {
					// reversed vector
					var backX:Number = -displ.x/displacementLength;
					var backY:Number = -displ.y/displacementLength;
					var backZ:Number = -displ.z/displacementLength;
					// Length of Vector pointed from closest point to the center of sphere
					var deltaLength:Number = deltaX*deltaX + deltaY*deltaY + deltaZ*deltaZ;
					// Projection Vector pointed from closest point to the center of sphere  on reversed vector
					var projectionLength:Number = deltaX*backX + deltaY*backY + deltaZ*backZ;
					var projectionInsideLength:Number = radius*radius - deltaLength + projectionLength*projectionLength;
					if (projectionInsideLength > 0) {
						// Time of the intersection
						var time:Number = (projectionLength - Math.sqrt(projectionInsideLength))/displacementLength;
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
			return minTime;
		}
		
		public function getCollision(source : flash.geom.Vector3D,displacement : flash.geom.Vector3D,resCollisionPoint : flash.geom.Vector3D,resCollisionPlane : flash.geom.Vector3D) : Boolean {
			if(displacement.length <= this.threshold) return false;
			this.prepare(source,displacement,null);
			if(this.numFaces > 0) {
				if(this.checkCollision() < 1) {
					resCollisionPoint.x = this.matrix.a * this.collisionPoint.x + this.matrix.b * this.collisionPoint.y + this.matrix.c * this.collisionPoint.z + this.matrix.d;
					resCollisionPoint.y = this.matrix.e * this.collisionPoint.x + this.matrix.f * this.collisionPoint.y + this.matrix.g * this.collisionPoint.z + this.matrix.h;
					resCollisionPoint.z = this.matrix.i * this.collisionPoint.x + this.matrix.j * this.collisionPoint.y + this.matrix.k * this.collisionPoint.z + this.matrix.l;
					var abx : Number;
					var aby : Number;
					var abz : Number;
					if(this.collisionPlane.x < this.collisionPlane.y) {
						if(this.collisionPlane.x < this.collisionPlane.z) {
							abx = 0;
							aby = -this.collisionPlane.z;
							abz = this.collisionPlane.y;
						}
						else {
							abx = -this.collisionPlane.y;
							aby = this.collisionPlane.x;
							abz = 0;
						}
					}
					else if(this.collisionPlane.y < this.collisionPlane.z) {
						abx = this.collisionPlane.z;
						aby = 0;
						abz = -this.collisionPlane.x;
					}
					else {
						abx = -this.collisionPlane.y;
						aby = this.collisionPlane.x;
						abz = 0;
					}
					var acx : Number = this.collisionPlane.z * aby - this.collisionPlane.y * abz;
					var acy : Number = this.collisionPlane.x * abz - this.collisionPlane.z * abx;
					var acz : Number = this.collisionPlane.y * abx - this.collisionPlane.x * aby;
					var abx2 : Number = this.matrix.a * abx + this.matrix.b * aby + this.matrix.c * abz;
					var aby2 : Number = this.matrix.e * abx + this.matrix.f * aby + this.matrix.g * abz;
					var abz2 : Number = this.matrix.i * abx + this.matrix.j * aby + this.matrix.k * abz;
					var acx2 : Number = this.matrix.a * acx + this.matrix.b * acy + this.matrix.c * acz;
					var acy2 : Number = this.matrix.e * acx + this.matrix.f * acy + this.matrix.g * acz;
					var acz2 : Number = this.matrix.i * acx + this.matrix.j * acy + this.matrix.k * acz;
					resCollisionPlane.x = abz2 * acy2 - aby2 * acz2;
					resCollisionPlane.y = abx2 * acz2 - abz2 * acx2;
					resCollisionPlane.z = aby2 * acx2 - abx2 * acy2;
					resCollisionPlane.normalize();
					resCollisionPlane.w = resCollisionPoint.x * resCollisionPlane.x + resCollisionPoint.y * resCollisionPlane.y + resCollisionPoint.z * resCollisionPlane.z;
					return true;
				}
				else return false;
			}
			return false;
		}
		
		public function calculateDestination(source : flash.geom.Vector3D,displacement : flash.geom.Vector3D, object:Object3D, excluded:Dictionary=null) : flash.geom.Vector3D {
			if (displacement.length <= threshold) return source.clone();
			
			prepare(source, displacement, object);
			loopGeometries();
			
			if (numFaces > 0) {
				var limit:int = 50;
				for (var i:int = 0; i < limit; i++) {
					if (checkCollision()) {
						// Offset destination point from behind collision plane by radius of the sphere over plane, along the normal
						var offset:Number = radius + threshold + collisionPlane.w - dest.x*collisionPlane.x - dest.y*collisionPlane.y - dest.z*collisionPlane.z;
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
				return new Vector3D(matrix.a*dest.x + matrix.b*dest.y + matrix.c*dest.z + matrix.d, matrix.e*dest.x + matrix.f*dest.y + matrix.g*dest.z + matrix.h, matrix.i*dest.x + matrix.j*dest.y + matrix.k*dest.z + matrix.l);
			} else {
				return new Vector3D(source.x + displacement.x, source.y + displacement.y, source.z + displacement.z);
			}
		}
		
		public function addGeometry(geometry : Geometry,transform : alternativa.engine3d.core.Transform3D) : void {
			this.geometries[this.numGeometries] = geometry;
			this.transforms[this.numGeometries] = transform;
			this.numGeometries++;
		}
		
		protected function loopGeometries() : void {
			this.numFaces = 0;
	
			var indicesLength:int = 0;
			var normalsLength:int = 0;
			// Loop geometries
			var j:int;
			var mapOffset:int = 0;
			var verticesLength:int = 0;
			var geometriesLength:int = geometries.length;
			
			for (var i:int = 0; i < geometriesLength; i++) {
				var geometry:Geometry = geometries[i];
				var transform:Transform3D = transforms[i];
				var geometryIndicesLength:int = geometry._indices.length;
				if (geometry._numVertices == 0 || geometryIndicesLength == 0) continue;
				// Transform vertices
				var vBuffer:VertexStream = (VertexAttributes.POSITION < geometry._attributesStreams.length) ? geometry._attributesStreams[VertexAttributes.POSITION] : null;
				if (vBuffer != null) {
					var attributesOffset:int = geometry._attributesOffsets[VertexAttributes.POSITION];
					var numMappings:int = vBuffer.attributes.length;
					var data:ByteArray = vBuffer.data;
					for (j = 0; j < geometry._numVertices; j++) {
						data.position = 4*(numMappings*j + attributesOffset);
						var vx:Number = data.readFloat();
						var vy:Number = data.readFloat();
						var vz:Number = data.readFloat();
						vertices[verticesLength] = transform.a*vx + transform.b*vy + transform.c*vz + transform.d; verticesLength++;
						vertices[verticesLength] = transform.e*vx + transform.f*vy + transform.g*vz + transform.h; verticesLength++;
						vertices[verticesLength] = transform.i*vx + transform.j*vy + transform.k*vz + transform.l; verticesLength++;
					}
				}
				// Loop triangles
				var geometryIndices:Vector.<uint> = geometry._indices;
				for (j = 0; j < geometryIndicesLength;) {
					var a:int = geometryIndices[j] + mapOffset; j++;
					var index:int = a*3;
					var ax:Number = vertices[index]; index++;
					var ay:Number = vertices[index]; index++;
					var az:Number = vertices[index];
					var b:int = geometryIndices[j] + mapOffset; j++;
					index = b*3;
					var bx:Number = vertices[index]; index++;
					var by:Number = vertices[index]; index++;
					var bz:Number = vertices[index];
					var c:int = geometryIndices[j] + mapOffset; j++;
					index = c*3;
					var cx:Number = vertices[index]; index++;
					var cy:Number = vertices[index]; index++;
					var cz:Number = vertices[index];
					// Exclusion by bound
					if (ax > radius && bx > radius && cx > radius || ax < -radius && bx < -radius && cx < -radius) continue;
					if (ay > radius && by > radius && cy > radius || ay < -radius && by < -radius && cy < -radius) continue;
					if (az > radius && bz > radius && cz > radius || az < -radius && bz < -radius && cz < -radius) continue;
					// The normal
					var abx:Number = bx - ax;
					var aby:Number = by - ay;
					var abz:Number = bz - az;
					var acx:Number = cx - ax;
					var acy:Number = cy - ay;
					var acz:Number = cz - az;
					var normalX:Number = acz*aby - acy*abz;
					var normalY:Number = acx*abz - acz*abx;
					var normalZ:Number = acy*abx - acx*aby;
					var len:Number = normalX*normalX + normalY*normalY + normalZ*normalZ;
					if (len < 0.001) continue;
					len = 1/Math.sqrt(len);
					normalX *= len;
					normalY *= len;
					normalZ *= len;
					var offset:Number = ax*normalX + ay*normalY + az*normalZ;
					if (offset > radius || offset < -radius) continue;
					indices[indicesLength] = a; indicesLength++;
					indices[indicesLength] = b; indicesLength++;
					indices[indicesLength] = c; indicesLength++;
					normals[normalsLength] = normalX; normalsLength++;
					normals[normalsLength] = normalY; normalsLength++;
					normals[normalsLength] = normalZ; normalsLength++;
					normals[normalsLength] = offset; normalsLength++;
					numFaces++;
				}
				// Offset by nomber of vertices
				mapOffset += geometry._numVertices;
			}
			
			this.numGeometries = 0;
			this.geometries.length = 0;
			this.transforms.length = 0;
			this.numI = indicesLength;
		}
		
		protected function prepare(source : flash.geom.Vector3D,displacement : flash.geom.Vector3D, object:Object3D) : void {
			this.radius = this.radiusX;
			if(this.radiusY > this.radius) this.radius = this.radiusY;
			if(this.radiusZ > this.radius) this.radius = this.radiusZ;
			this.matrix.compose(source.x,source.y,source.z,0,0,0,this.radiusX / this.radius,this.radiusY / this.radius,this.radiusZ / this.radius);
			this.inverseMatrix.copy(this.matrix);
			this.inverseMatrix.invert();
			this.src.x = 0;
			this.src.y = 0;
			this.src.z = 0;
			this.displ.x = this.inverseMatrix.a * displacement.x + this.inverseMatrix.b * displacement.y + this.inverseMatrix.c * displacement.z;
			this.displ.y = this.inverseMatrix.e * displacement.x + this.inverseMatrix.f * displacement.y + this.inverseMatrix.g * displacement.z;
			this.displ.z = this.inverseMatrix.i * displacement.x + this.inverseMatrix.j * displacement.y + this.inverseMatrix.k * displacement.z;
			this.dest.x = this.src.x + this.displ.x;
			this.dest.y = this.src.y + this.displ.y;
			this.dest.z = this.src.z + this.displ.z;
			var radius : Number = this.radius + this.displ.length;
			this.cornerA.x = -radius;
			this.cornerA.y = -radius;
			this.cornerA.z = -radius;
			this.cornerB.x = radius;
			this.cornerB.y = -radius;
			this.cornerB.z = -radius;
			this.cornerC.x = radius;
			this.cornerC.y = radius;
			this.cornerC.z = -radius;
			this.cornerD.x = -radius;
			this.cornerD.y = radius;
			this.cornerD.z = -radius;
			
			
			
			// Gathering the faces which with collision can occur
			
				if (object.transformChanged) object.composeTransforms();
				object.globalToLocalTransform.combine(object.inverseTransform, matrix);
				// Check collision with the bound
				var intersects:Boolean = true;
				if (object.boundBox != null) {
					calculateSphere(object.globalToLocalTransform);
					intersects = object.boundBox.checkSphere(sphere);
				}
				if (intersects) {
					object.localToGlobalTransform.combine(inverseMatrix, object.transform);
					object.localToGlobalTransform.copy(inverseMatrix);
					object.collectGeometry(this,null);
				}
				// Check children
				if (object.childrenList != null) object.collectChildrenGeometry(this,null );
			
		}
		
		alternativa3d function calculateSphere(transform : alternativa.engine3d.core.Transform3D) : void {
			this.sphere.x = transform.d;
			this.sphere.y = transform.h;
			this.sphere.z = transform.l;
			var sax : Number = transform.a * this.cornerA.x + transform.b * this.cornerA.y + transform.c * this.cornerA.z + transform.d;
			var say : Number = transform.e * this.cornerA.x + transform.f * this.cornerA.y + transform.g * this.cornerA.z + transform.h;
			var saz : Number = transform.i * this.cornerA.x + transform.j * this.cornerA.y + transform.k * this.cornerA.z + transform.l;
			var sbx : Number = transform.a * this.cornerB.x + transform.b * this.cornerB.y + transform.c * this.cornerB.z + transform.d;
			var sby : Number = transform.e * this.cornerB.x + transform.f * this.cornerB.y + transform.g * this.cornerB.z + transform.h;
			var sbz : Number = transform.i * this.cornerB.x + transform.j * this.cornerB.y + transform.k * this.cornerB.z + transform.l;
			var scx : Number = transform.a * this.cornerC.x + transform.b * this.cornerC.y + transform.c * this.cornerC.z + transform.d;
			var scy : Number = transform.e * this.cornerC.x + transform.f * this.cornerC.y + transform.g * this.cornerC.z + transform.h;
			var scz : Number = transform.i * this.cornerC.x + transform.j * this.cornerC.y + transform.k * this.cornerC.z + transform.l;
			var sdx : Number = transform.a * this.cornerD.x + transform.b * this.cornerD.y + transform.c * this.cornerD.z + transform.d;
			var sdy : Number = transform.e * this.cornerD.x + transform.f * this.cornerD.y + transform.g * this.cornerD.z + transform.h;
			var sdz : Number = transform.i * this.cornerD.x + transform.j * this.cornerD.y + transform.k * this.cornerD.z + transform.l;
			var dx : Number = sax - this.sphere.x;
			var dy : Number = say - this.sphere.y;
			var dz : Number = saz - this.sphere.z;
			this.sphere.w = dx * dx + dy * dy + dz * dz;
			dx = sbx - this.sphere.x;
			dy = sby - this.sphere.y;
			dz = sbz - this.sphere.z;
			var dxyz : Number = dx * dx + dy * dy + dz * dz;
			if(dxyz > this.sphere.w) this.sphere.w = dxyz;
			dx = scx - this.sphere.x;
			dy = scy - this.sphere.y;
			dz = scz - this.sphere.z;
			dxyz = dx * dx + dy * dy + dz * dz;
			if(dxyz > this.sphere.w) this.sphere.w = dxyz;
			dx = sdx - this.sphere.x;
			dy = sdy - this.sphere.y;
			dz = sdz - this.sphere.z;
			dxyz = dx * dx + dy * dy + dz * dz;
			if(dxyz > this.sphere.w) this.sphere.w = dxyz;
			this.sphere.w = Math.sqrt(this.sphere.w);
		}
		
		public var collisions : systems.collisions.CollisionEvent;
		public var timestamp : int;
		protected var gotMoved : Boolean;
		protected var cornerD : flash.geom.Vector3D;
		protected var cornerC : flash.geom.Vector3D;
		protected var cornerB : flash.geom.Vector3D;
		protected var cornerA : flash.geom.Vector3D;
		alternativa3d var sphere : flash.geom.Vector3D;
		protected var resCollisionPlane : flash.geom.Vector3D;
		protected var resCollisionPoint : flash.geom.Vector3D;
		protected var collisionPlane : flash.geom.Vector3D;
		protected var collisionPoint : flash.geom.Vector3D;
		protected var dest : flash.geom.Vector3D;
		protected var displ : flash.geom.Vector3D;
		protected var src : flash.geom.Vector3D;
		protected var radius : Number;
		protected var numI : int;
		protected var numFaces : int;
		protected var indices : Vector.<int>;
		protected var normals : Vector.<Number>;
		protected var vertices : Vector.<Number>;
		alternativa3d var transforms : Vector.<alternativa.engine3d.core.Transform3D>;
		protected var numGeometries : int;
		alternativa3d var geometries : Vector.<alternativa.engine3d.resources.Geometry>;
		public var inverseMatrix : alternativa.engine3d.core.Transform3D;
		public var matrix : alternativa.engine3d.core.Transform3D;
		public var threshold : Number;
		public var radiusZ : Number;
		public var radiusY : Number;
		public var radiusX : Number;
		static protected function isNaN2(a : Number) : Boolean {
			return a != a;
		}
		
	}
}
