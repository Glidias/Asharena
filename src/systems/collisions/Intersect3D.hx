package systems.collisions;
import components.Ellipsoid;
import components.Pos;
import components.Vel;
import util.geom.Vec3;


/**
 * ...
 * @author ...
 */
class Intersect3D
{

	public function new() 
	{
		
	}
	private static var TEMP:Vec3 = new Vec3();
	
		///*
	public static inline function ellipsoidHitsEllipsoidMoving(ray_origin:Vec3, ray_travel:Vec3, pos:Pos, pos2:Pos, vel:Vel, vel2:Vel, ellipsoid:Ellipsoid, ellipsoid2:Ellipsoid):Float {
			
			// This is a C1 ray hit test against....
			ray_origin.x = pos.x - pos2.x;
			ray_origin.y = pos.y - pos2.y;
			ray_origin.z = pos.z - pos2.z;
			
			// ...inflated ellipsoid (sum of radii)
			var ellipsoid_radius:Vec3 = TEMP;
			ellipsoid_radius.x = ellipsoid.x + ellipsoid2.x;
			ellipsoid_radius.y = ellipsoid.y + ellipsoid2.y;
			ellipsoid_radius.z = ellipsoid.z + ellipsoid2.z;
			
			// ...based on relative velocities of c1/c2.
			ray_travel.x = vel.x - vel2.x;
			ray_travel.y = vel.y- vel2.y;
			ray_travel.z = vel.z - vel2.z;
		
			// Find "d" in normalized unit time. 
			// Quadratic formula (to consider: simplified to 1 solution: b^2-ac. instead)
			var a:Float = ((ray_travel.x*ray_travel.x)/(ellipsoid_radius.x*ellipsoid_radius.x))
					+ ((ray_travel.y*ray_travel.y)/(ellipsoid_radius.y*ellipsoid_radius.y))
					+ ((ray_travel.z*ray_travel.z)/(ellipsoid_radius.z*ellipsoid_radius.z));
				var b:Float = ((2*ray_origin.x*ray_travel.x)/(ellipsoid_radius.x*ellipsoid_radius.x))
						+ ((2*ray_origin.y*ray_travel.y)/(ellipsoid_radius.y*ellipsoid_radius.y))
						+ ((2*ray_origin.z*ray_travel.z)/(ellipsoid_radius.z*ellipsoid_radius.z));
				var c:Float = ((ray_origin.x*ray_origin.x)/(ellipsoid_radius.x*ellipsoid_radius.x))
						+ ((ray_origin.y*ray_origin.y)/(ellipsoid_radius.y*ellipsoid_radius.y))
						+ ((ray_origin.z*ray_origin.z)/(ellipsoid_radius.z*ellipsoid_radius.z))
						- 1;

				var d:Float = b*b-4*a*c;
				if (d >= 0) {
				
					d = Math.sqrt(d);
					
					var multiplier:Float = 1/(2*a);
					var hit:Float = (-b + d)*multiplier;
					var hitsecond:Float = (-b - d)*multiplier;
					d = hit < hitsecond ? hit : hitsecond;  // 2 solutions, bah...
	
				}
				
				return d;   // collision happened within timeframe
		}
		//*/
	
	public static inline function rayIntersectsEllipsoid(ray_origin:Vec3, ray_travel:Vec3, ellipsoid_radius:Vec3):Float {
			var a:Float = ((ray_travel.x*ray_travel.x)/(ellipsoid_radius.x*ellipsoid_radius.x))
			+ ((ray_travel.y*ray_travel.y)/(ellipsoid_radius.y*ellipsoid_radius.y))
			+ ((ray_travel.z*ray_travel.z)/(ellipsoid_radius.z*ellipsoid_radius.z));
			var b:Float = ((2*ray_origin.x*ray_travel.x)/(ellipsoid_radius.x*ellipsoid_radius.x))
			+ ((2*ray_origin.y*ray_travel.y)/(ellipsoid_radius.y*ellipsoid_radius.y))
			+ ((2*ray_origin.z*ray_travel.z)/(ellipsoid_radius.z*ellipsoid_radius.z));
			var c:Float = ((ray_origin.x*ray_origin.x)/(ellipsoid_radius.x*ellipsoid_radius.x))
			+ ((ray_origin.y*ray_origin.y)/(ellipsoid_radius.y*ellipsoid_radius.y))
			+ ((ray_origin.z*ray_origin.z)/(ellipsoid_radius.z*ellipsoid_radius.z))
			- 1;

			var d:Float = b*b-4*a*c;
			////if ( d < 0 ) { // no real roots
			//	return d;
		//	}

			if (d>=0) {
				d = Math.sqrt(d);
				var multiplier:Float = 1/(2*a);
				var hit:Float = (-b + d)*multiplier;
				var hitsecond:Float = (-b - d)*multiplier;
				d = hit < hitsecond ? hit : hitsecond; // 2 solutions, bah...
				
				//if (d < 0) {
				//	return false;
				//}
			}

			return d;
		}
		
		

		/**
		 * Overlap/touching test between 2 ellipsoids
		 * @param	posA
		 * @param	radiusA
		 * @param	posB
		 * @param	radiusB
		 * @return
		 */
		public static inline function ellipsoidIntersectsEllipsoid(posA:Vec3, radiusA:Vec3, posB:Vec3, radiusB:Vec3):Bool {
			var temp:Vec3  = TEMP;
			temp.x = posA.x - posB.x;
			temp.y = posA.y - posB.y;
			temp.z = posA.z - posB.z;
			var sqDist:Float = temp.x*temp.x + temp.y*temp.y + temp.z*temp.z;
			
			temp.normalize();
			
			var radA:Float = temp.x * radiusA.x + temp.y * radiusA.y + temp.z * radiusA.z;
			if (radA < 0 )  radA = -radA;
			var radB:Float =  temp.x * radiusB.x + temp.y * radiusB.y + temp.z * radiusB.z;
			if (radB < 0 )  radB = -radB;
			// radA = radiusA.x;
			 //radB = radiusB.x;
			return sqDist - ((radA*radA) + (radB*radB)) < 0;
		}
		
		
		
	
	
}