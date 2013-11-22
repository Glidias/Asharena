package de.polygonal.core.math;

/**
 * <p>Utility functions to find cubic, quadric and quartic roots.</p>
 * <p>See Graphics Gems: Schwarze, Jochen, Cubic and Quartic Roots, p. 404-407, code: p. 738-786, <a href="http://tog.acm.org/resources/GraphicsGems/gems/Roots3And4.c">Roots3And4.c</a></p>
 */
class RootSolver
{
	inline static var EQN_EPS        = 1e-10;
	
	inline static var INV3           = .3333333333333333;
	inline static var INV2           = .5;
	inline static var INV4           = .25;
	inline static var INV8           = .125;
	inline static var INV16          = .0625;
	inline static var PI_OVER_3      = 1.0471975511965976;
	inline static var TWO_OVER_27    = .07407407407407407;
	inline static var THREE_OVER_8   = .375;
	inline static var THREE_OVER_256 = 0.01171875;
	
	inline static function cbrt(x:Float):Float 
	{
		return (x < 0 ? -1. : 1.) * Math.pow(Math.abs(x), INV3);
	}
	
	inline static function isZero(n:Float):Bool
	{
		return (n > -EQN_EPS) && (n < EQN_EPS);
	}
	
	public var roots:Array<Float>;
	
	var _scratchArray:Array<Float>;
	
	public function new()
	{
		roots = new Array<Float>();
		_scratchArray = [];
	}
	
	public function free():Void
	{
		roots = null;
		_scratchArray = null;
	}
	
	/**
	 * Solves the quadric equation <code>c0</code> + <code>c1</code>*x + <code>c2</code>*x^2 = 0 and puts the solution into <em>roots</em>.
	 * @return The total number of non-complex roots or 0 if no solution was found.
	 */
	public function solveQuadric(c0:Float, c1:Float, c2:Float):Int
	{
		var p = c1 / (2 * c2);
		var q = c0 / c2;
		var d = p * p - q; 
		
		//normal form: x^2 + px + q = 0
		if (isZero(d))
		{
			roots[0] = -p;
			return 1;
		}
		else
		if (d < 0)
			return 0;
		else
		{
			var sqrt = Math.sqrt(d);
			roots[0] = sqrt - p;
			roots[1] =-sqrt - p;
			return 2;
		}
	}
	
	/**
	 * Solves the cubic equation <code>c0</code> + <code>c1</code>*x + <code>c2</code>*x^2 + <code>c3</code>*x^3 = 0 and puts the solution into <em>roots</em>.
	 * @return The total number of non-complex roots or 0 if no solution was found.
	 */
	public function solveCubic(c0:Float, c1:Float, c2:Float, c3:Float):Int
	{
		var k = 0;
		
		//normal form: x^3 + Ax^2 + Bx + C = 0
		var a = c2 / c3;
		var b = c1 / c3;
		var c = c0 / c3;
		
		//substitute x = y - a/3 to eliminate quadric term
		var sqa = a * a;
		var p = INV3 * (-INV3 * sqa + b);
		var q = INV2 * (TWO_OVER_27 * a * sqa - INV3 * a * b + c);
		
		//use Cardano's formula
		var cbp = p * p * p;
		var d = q * q + cbp;
		
		if (isZero(d))
		{
			if (isZero(q)) //one triple solution
			{
				roots[0] = 0;
				k = 1;
			}
			else //one single and one double solution
			{
				var u = cbrt(-q);
				roots[0] = 2 * u;
				roots[1] =-u;
				k = 2;		
			}
		}
		else
		if (d < 0.) //casus irreducibilis: three real solutions
		{
			var m = Math;
			var phi = INV3 * m.acos(-q / m.sqrt(-cbp));
			var t = 2 * m.sqrt(-p);
			roots[0] =  t * m.cos(phi);
			roots[1] = -t * m.cos(phi + PI_OVER_3);
			roots[2] = -t * m.cos(phi - PI_OVER_3);
			k = 3;
		}
		else //one real solution
		{
			var m = Math;
			var rtD = m.sqrt(d);
			var u = cbrt(m.sqrt(d) - q);
			var v =-cbrt(m.sqrt(d) + q);
			roots[0] = u + v;
			k = 1;
		}
		
		var sub = INV3 * a;
		for (i in 0...k) roots[i] -= sub;
		return k;
	}
	
	/**
	 * Solves the quartic equation <code>c0</code> + <code>c1</code>*x + <code>c2</code>*x^2 + <code>c3</code>*x^3 + <code>c4</code>*x^4 = 0 and puts the solution into <em>roots</em>.
	 * @return The total number of non-complex roots or 0 if no solution was found.
	 */
	public function solveQuartic(c0:Float, c1:Float, c2:Float, c3:Float, c4:Float):Int
	{
		var tc0:Float, tc1:Float, tc2:Float, tc3:Float, k:Int;
		
		//normal form: x^4 + Ax^3 + Bx^2 + Cx + D = 0
		var a = c3 / c4;
		var b = c2 / c4;
		var c = c1 / c4;
		var d = c0 / c4;
		
		//substitute x = y - A/4 to eliminate cubic term: x^4 + px^2 + qx + r = 0
		var sqa = a * a;
		var p = -THREE_OVER_8 * sqa + b;
		var q = INV8 * sqa * a - INV2 * a * b + c;
		var r = -THREE_OVER_256 * sqa * sqa + INV16 * sqa * b - INV4 * a * c + d;
		
		if (isZero(r))
		{
			//no absolute term: y(y^3 + py + q) = 0
			tc0 = q;
			tc1 = p;
			tc2 = 0;
			tc3 = 1;
			k = solveCubic(tc0, tc1, tc2, tc3);
			roots[k++] = 0;
		}
		else
		{
			//solve the resolvent cubic...
			tc0 = INV2 * r * p - INV8 * q * q;
			tc1 = -r;
			tc2 = -INV2 * p;
			tc3 = 1;
			
			solveCubic(tc0, tc1, tc2, tc3);
			
			//and take the one real solution...
			var z = roots[0];
			
			//...to build two quadric equations
			var u = z * z - r;
			var v = 2 * z - p;
			
			if (isZero(u))
				u = 0;
			else
			if (u > 0)
				u = Math.sqrt(u);
			else
				return 0;
			
			if (isZero(v))
				v = 0;
			else
			if (v > 0)
				v = Math.sqrt(v);
			else
				return 0;
			
			tc0 = z - u;
			tc1 = q < 0 ? -v : v;
			tc2 = 1;
			k = solveQuadric(tc0, tc1, tc2);
			
			tc0 = z + u;
			tc1 = q < 0 ? v : -v;
			tc2 = 1;
			
			var tmp = _scratchArray;
			for (i in 0...k) tmp[i] = roots[i];
			
			var j = solveQuadric(tc0, tc1, tc2);
			
			for (i in 0...j)
			{
				roots[i + j] = roots[i];
				roots[i] = tmp[i];
			}
			
			k += j;
		}
		
		//resubstitute
		var sub = INV4 * a;
		for (i in 0...k) roots[i] -= sub;
		return k;
	}
}