package util.geom;
import components.Transform3D;
import util.TypeDefs;
 
/**
 * General utilities to manage 3d geometric data and transforms
 * @author Glidias
 */
class GeomUtil 
{	
	public static function transformVertices(vertices:Vector<Float>, t:Transform3D):Void {
		var len:Int = vertices.length;
		var i:Int = 0;
		while ( i < len) {
			var x:Float = vertices[i];
			var y:Float = vertices[i+1];
			var z:Float = vertices[i + 2];
			vertices[i] = t.a * x + t.b * y + t.c * z + t.d;
			vertices[i+1] = t.e * x + t.f * y + t.g * z + t.h;
			vertices[i+2] = t.i * x + t.j * y + t.k * z + t.l;
			i += 3;
		}
	}
	
	public static inline function boundIntersectSphere(sphere:Vector3D, minX:Float, minY:Float, minZ:Float, maxX:Float, maxY:Float, maxZ:Float):Bool {
		return sphere.x + sphere.w > minX && sphere.x - sphere.w < maxX && sphere.y + sphere.w > minY && sphere.y - sphere.w < maxY && sphere.z + sphere.w > minZ && sphere.z - sphere.w < maxZ;
	}
	
	public static function boundIntersectRay(origin:Vector3D, direction:Vector3D, minX:Float, minY:Float, minZ:Float, maxX:Float, maxY:Float, maxZ:Float, result:Vector3D):Bool {
				
		/*
		var temp:Float = minZ;
		minZ = -maxZ;
		maxZ = -temp;
		*/
		
		if (origin.x >= minX && origin.x <= maxX && origin.y >= minY && origin.y <= maxY && origin.z >= minZ && origin.z <= maxZ) return true;
		if (origin.x < minX && direction.x <= 0) return false;
		if (origin.x > maxX && direction.x >= 0) return false;
		if (origin.y < minY && direction.y <= 0) return false;
		if (origin.y > maxY && direction.y >= 0) return false;
		if (origin.z < minZ && direction.z <= 0) return false;
		if (origin.z > maxZ && direction.z >= 0) return false;
		var a:Float;
		var b:Float;
		var c:Float;
		var d:Float;
		var threshold:Float = 0.000001;
		// Intersection of X and Y projection
		if (direction.x > threshold) {
			a = (minX - origin.x) / direction.x;
			b = (maxX - origin.x) / direction.x;
		} else if (direction.x < -threshold) {
			a = (maxX - origin.x) / direction.x;
			b = (minX - origin.x) / direction.x;
		} else {
			a = -1e+22;
			b = 1e+22;
		}
		if (direction.y > threshold) {
			c = (minY - origin.y) / direction.y;
			d = (maxY - origin.y) / direction.y;
		} else if (direction.y < -threshold) {
			c = (maxY - origin.y) / direction.y;
			d = (minY - origin.y) / direction.y;
		} else {
			c = -1e+22;
			d = 1e+22;
		}
		if (c >= b || d <= a) return false;
		if (c < a) {
			if (d < b) b = d;
		} else {
			a = c;
			if (d < b) b = d;
		}
		// Intersection of XY and Z projections
		if (direction.z > threshold) {
			c = (minZ - origin.z) / direction.z;
			d = (maxZ - origin.z) / direction.z;
		} else if (direction.z < -threshold) {
			c = (maxZ - origin.z) / direction.z;
			d = (minZ - origin.z) / direction.z;
		} else {
			c = -1e+22;
			d = 1e+22;
		}
		
		c = c > a ? c : a;  // added to ensure reference is correct!
		d = d < b ? d : b;
		//if (c === Infinity) throw new Error("LOWER ZERO C!");

		if ( (direction.w > 0 && c >= direction.w) || (result.w > 0 && c>=result.w) ) return false;
		
		if (c >= b || d <= a) return false;
		return true;
	}
	public static function intersectRayTri(result:Vector3D, ox:Float, oy:Float, oz:Float, dx:Float, dy:Float, dz:Float, ax:Float, ay:Float, az:Float, bx:Float, by:Float, bz:Float, cx:Float, cy:Float, cz:Float):Bool {
		
		var abx:Float = bx - ax;
		var aby:Float = by - ay;
		var abz:Float = bz - az;
		var acx:Float = cx - ax;
		var acy:Float = cy - ay;
		var acz:Float = cz - az;
		var normalX:Float = acz*aby - acy*abz;
		var normalY:Float = acx*abz - acz*abx;
		var normalZ:Float = acy * abx - acx * aby;
		
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
								//if (time < minTime) {
								result.w = time;// + _boundRayTime;
								result.x = rx;
								result.y = ry;
								result.z = rz;
								return true;
								
								//	}
						}
					}
				}
			}
					
					
		}
				
		return false;
	}
	
}