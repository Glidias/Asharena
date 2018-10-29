package altern.geom;

import de.polygonal.ds.NativeArray;
import de.polygonal.ds.NativeFloat32Array;
import de.polygonal.ds.NativeInt32Array;
import de.polygonal.ds.tools.NativeArrayTools;
//import de.polygonal.ds.tools.NativeInt32ArrayTools;
import util.TypeDefs;

/**
 * Utility to help calculate trajecotry-based intersections along 3d tri-slopes.
 * @author Glenn Ko
 */
class IntersectSlopeUtil
{
	
	public var startPt:Vector3D = new Vector3D(30, 60);
	public var endPt:Vector3D = new Vector3D();
	
	public var pt2:Vector3D = new Vector3D(90, 60, 80);
	public var pt1:Vector3D = new Vector3D(100, 60, 60);
	public var pt3:Vector3D = new Vector3D(70, 180, 100);
	private var r:Float;
	private var s:Float;
	public var velocity:Vector3D = new Vector3D();
	public var startPosition:Vector3D = new Vector3D();
	
	public var intersectSides:NativeArray<Int> = NativeArrayTools.alloc(2);
	#if js
	public var intersectTimes:NativeFloat32Array = new NativeFloat32Array(2);
	public var intersectZ:NativeFloat32Array = new NativeFloat32Array(2);
	#else
	public var intersectTimes:NativeArray<Float> = NativeArrayTools.alloc(2);
	public var intersectZ:NativeArray<Float> = NativeArrayTools.alloc(2);
	#end
	
	
	
	public var gradient:Float;
	
	public static inline var RESULT_NONE:Int = 0;
	public static inline var RESULT_SLOPE:Int = 1;
	public static inline var RESULT_WALL:Int = -1;
	public static inline var RESULT_COLLINEAR:Int = -2;
	public static inline var RESULT_COLLINEAR_VALID:Int = 2;
	public static inline var RESULT_ERROR:Int = -3;
	public var _unitDist:Float;
	
	private var _tRise:Float;
	private var _h:Float;
	
	public inline function sqDistBetween2DVector(a:Vector3D, b:Vector3D):Float
	{
		var dx:Float = b.x - a.x;
		var dy:Float = b.y - a.y;
		return dx * dx + dy * dy;
	}
	
	public inline function rBetween2DVec(a:Vector3D, b:Vector3D, c:Vector3D):Float
	{
		var dx:Float = b.x - a.x;
		var dy:Float = b.y - a.y;
		var dx2:Float = c.x - a.x;
		var dy2:Float = c.y - a.y;
		return dx * dx2 + dy * dy2;
	}
	
	// sets up 2d ray direciton and 3d start point
	public function setupRay(origin:Vector3D, direction:Vector3D):Void
	{
		startPt.x = origin.x;
		startPt.y = origin.y;
		startPt.z = origin.z;
		
		//var dx:Float = direction.x;
		//var dy:Float = direction.y;
	

		velocity.x = direction.x;
		velocity.y = direction.y;
		velocity.z = 0;
	//	velocity.normalize();
		
		endPt.x = startPt.x + velocity.x;
		endPt.y = startPt.y +  velocity.y;
		endPt.z = 0;// startPt.z + velocity.y;
	
	}
	
		
	public function getTriSlopeTrajTime(direction:Vector3D, gravity:Float, strength:Float):Float
	{
		var unitDist:Float = Math.sqrt(direction.x * direction.x + direction.y * direction.y);
		_unitDist = unitDist;
		velocity.x = unitDist;
		velocity.y = direction.z;
		velocity.z = 0;
		velocity.normalize();
		velocity.x *= strength;
		velocity.y *= strength;
		
		startPosition.x = -intersectTimes[0]; //   2D Distance before start of slope....  startPt.x * direction.x + startPt.y * direction.y;
		
		startPosition.y = startPt.z - intersectZ[0]; //  height from start of slope ..  startPt.z;
		
		//return getTrajectoryTimeOfFlight(startPosition.y, velocity.y, g);
		return getTrajectoryTimeOfFlight2(startPosition.y, velocity.y, gravity);
	}
	
	public inline function setupTri(ax:Float, ay:Float, az:Float, bx:Float, by:Float, bz:Float, cx:Float, cy:Float, cz:Float):Void
	{
		pt1.x = ax;
		pt1.y = ay;
		pt1.z = az;
		
		pt2.x = bx;
		pt2.y = by;
		pt2.z = bz;
		
		pt3.x = cx;
		pt3.y = cy;
		pt3.z = cz;
	}
	

	
	public inline function getTrajHeightAtTime(velocity:Vector3D, gravity:Float, t:Float):Float
	{
		return startPt.z - .5 * gravity * t * t + velocity.y * t;
	}
	
	public inline function getTrajHeightAtTime2(direction:Vector3D, gravity:Float, strength:Float, t:Float):Float
	{
		return startPt.z - .5 * gravity * t * t + direction.y * strength * t;
	}
	
	public inline function getGradHeightAtTime(t:Float):Float
	{
		return intersectZ[0] + (t - intersectTimes[0]) * gradient;
	}

	
	public  function getFlatTrajTime(direction:Vector3D, gravity:Float, strength:Float, grad:Float = 0):Float
	{
		
		velocity.x = Math.sqrt(direction.x * direction.x + direction.y * direction.y);
		velocity.y = direction.z;
		velocity.z = 0;
		velocity.normalize();
		velocity.x *= strength;
		velocity.y *= strength;
		
		startPosition.x = 0; //   2D Distance before start of slope....  startPt.x * direction.x + startPt.y * direction.y;
		startPosition.y = 0; //  height from start of slope ..  startPt.z;
		
		gradient = grad;
		
		//return getTrajectoryTimeOfFlight(startPosition.y, velocity.y, g);
		return getTrajectoryTimeOfFlight2(startPosition.y, velocity.y, gravity);
	}
	
	private function getTrajectoryTimeOfFlight2(yo:Float, vyo:Float, g:Float):Float
	{
		
		//y(t) = yo + (vyo)*t - (g/2)t2
		//x(t) = vxo*t,
		
		var t1:Float = vyo / g;
		var t2:Float = Math.sqrt(vyo * vyo + g * 2 * yo) / g;
		_tRise = t1;
		_h = yo + vyo * vyo / (2 * g);
		//    return t1 + t2;
		//y = yo +  (vyo * t - g / 2 * t * t);
		//x = vxo * t;    
		
		var slope:Float = gradient; // 0.0; // For line.
		var yIntercept:Float = -startPosition.x * gradient;
		
		//y = Ax2 + Bx + C
		var A:Float = g / 2; // For parabolla, quadratic function coefficients.
		var B:Float = -vyo;
		var C:Float = -yo;
		
		var a:Float = 0.0; // For solving quadratic formula.
		var b:Float = 0.0;
		var c:Float = 0.0;
		
		var x1:Float = 0.0; // Point(s) of intersection.
		var y1:Float = 0.0;
		var x2:Float = 0.0;
		var y2:Float = 0.0;
		
		a = A;
		b = B + slope * velocity.x;
		c = C - yIntercept;
		
		var discriminant:Float = b * b - 4 * a * c;
		
		if (discriminant > 0.0)
		{
			x1 = (-b + Math.sqrt(discriminant)) / (2.0 * a);
			x2 = (-b - Math.sqrt(discriminant)) / (2.0 * a);
			
			y1 = slope * x1 + yIntercept;
			y2 = slope * x2 + yIntercept;
			
			return x1 > x2 ? x1 : x2;
			
		}
		else if (discriminant == 0.0)
		{
			x1 = (-b) / (2.0 * a);
			
			y1 = slope * x1 + yIntercept;
			return x1;
		}
		
		//  throw new Error("A:" + [yo, vyo, g] + ", " + velocity + ", " + startPosition  + ", " + gradient);
		// A:1309.5262287828373,-0.07232929302656285,200, Vector3D(0.9973808065981006, -0.07232929302656285, 0), Vector3D(17979.298412078024, 1309.5262287828373, 0), 0.278275705392896
		return -1;
	
	}
	
	public function getTriIntersections():Int
	{
		var rd:Float;
		var gotIntersect:Bool;
		
		var count:Int = 0;
		
		_coincident = false;
		
		gotIntersect = IsIntersecting(startPt, endPt, pt1, pt2);
		if (gotIntersect)
		{
		
			intersectTimes[count] = r;
			intersectZ[count] = pt2.z * s - pt1.z * s + pt1.z;
			intersectSides[count] = 1|2;
			count++;
			
		}
		gotIntersect = IsIntersecting(startPt, endPt, pt2, pt3);
		if (gotIntersect)
		{
			
			intersectTimes[count] = r;
			intersectZ[count] = pt3.z * s - pt2.z * s + pt2.z;
			intersectSides[count] = 2|4;
			count++;
		}
		
		gotIntersect = IsIntersecting(startPt, endPt, pt3, pt1);
		if (gotIntersect)
		{
			if (count < 2)
			{
				
				intersectTimes[count] = r;
				intersectZ[count] = pt1.z * s - pt3.z * s + pt3.z;
				intersectSides[count] = 1|4;
				count++;
			}
		}
		
		var dx:Float = endPt.x - startPt.x;
		var dy:Float = endPt.y - startPt.y;
		
		var temp:Float = intersectTimes[0];
		var temp2:Float = intersectZ[0];
		var temp3:Int = intersectSides[0];
		
		if (intersectTimes[1] < temp)
		{
			intersectTimes[0] = intersectTimes[1];
			intersectZ[0] = intersectZ[1];
			intersectSides[0] = intersectSides[1];
			
			intersectTimes[1] = temp;
			intersectZ[1] = temp2;
			intersectSides[1] = temp3;
		}
		
		 if (intersectTimes[0] < 0) {  // start dot from inside instead mod
				
			 intersectZ[0] -= intersectTimes[0]/(intersectTimes[1]-intersectTimes[0])*(intersectZ[1] - intersectZ[0]);
			 intersectTimes[0]  = 0;
			
		  }
		
		if (_coincident)
		{
			if (count > 1) {
				rd = (intersectTimes[1] - intersectTimes[0]);
				gradient = (intersectZ[1] - intersectZ[0]) / rd;
				return RESULT_COLLINEAR_VALID;
			}
			else {
				return RESULT_COLLINEAR;
			}
			
			
		}
		else if (count != 0)
		{
			
			rd = (intersectTimes[1] - intersectTimes[0]);
			
			//if (rd < 0)	throw new Error("Should not be negative times..");
			
			// dx *= rd;
			// dy *= rd;
			//  rd  = Math.sqrt( dx * dx + dy * dy ); 
			if (count > 1)
			{ // count is 2
				if (rd > 0)
				{
					gradient = (intersectZ[1] - intersectZ[0]) / rd;
					//  debugField.text = "penetrate dist:" + rd + ", gradient:"+gradient + ", "+intersectTimes;
					
					return RESULT_SLOPE;
				}
				else
				{
					//gradient = 1;
					//throw new Error("Should not happen");
					//  debugField.text = "Hit a fully vertical wall!:"+intersectTimes[0];
					return RESULT_WALL;
				}
			}
			else
			{ // shuold not happen
				
				//debugField.text = "Collinear case";
				return RESULT_ERROR;
			}
			
		}
		else
		{
			// debugField.text = "No penetrate";
			return RESULT_NONE;
		}
	}
	
	private var _coincident:Bool;
	
	public function IsIntersecting(a:Vector3D, b:Vector3D, c:Vector3D, d:Vector3D):Bool
	{
		var denominator:Float = ((b.x - a.x) * (d.y - c.y)) - ((b.y - a.y) * (d.x - c.x));
		var numerator1:Float = ((a.y - c.y) * (d.x - c.x)) - ((a.x - c.x) * (d.y - c.y));
		var numerator2:Float = ((a.y - c.y) * (b.x - a.x)) - ((a.x - c.x) * (b.y - a.y));
		
		// Detect coincident lines (has a problem, read below)
		if (denominator == 0)
		{
			// find between c and d, which is closer to a, clamp to s to 1 and 0, set r to c/d
			s = sqDistBetween2DVector(a, c) < sqDistBetween2DVector(a, d) ? 0 : 1;
			r = s != 0 ? rBetween2DVec(a, b, d) : rBetween2DVec(a, b, c);
			// throw new Error("DETECT");
			_coincident = true;
			return false; // (r >= 0) && (s >= 0 && s <= 1);
				//  return numerator1 == 0 && numerator2 == 0;
		}
		
		r = numerator1 / denominator;
		s = numerator2 / denominator;
		// && r <= 1  // (r >= 0) &&
		return (s >= 0 && s <= 1);
	}

}