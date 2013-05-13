/*
 *                            _/                                          _/   
 *       _/_/_/      _/_/    _/  _/    _/    _/_/_/    _/_/    _/_/_/    _/    
 *      _/    _/  _/    _/  _/  _/    _/  _/    _/  _/    _/  _/    _/  _/     
 *     _/    _/  _/    _/  _/  _/    _/  _/    _/  _/    _/  _/    _/  _/      
 *    _/_/_/      _/_/    _/    _/_/_/    _/_/_/    _/_/    _/    _/  _/       
 *   _/                            _/        _/                                
 *  _/                        _/_/      _/_/
 *
 * POLYGONAL - A HAXE LIBRARY FOR GAME DEVELOPERS
 * Copyright (c) 2009-2010 Michael Baczynski, http://www.polygonal.de
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
package util.geom;



/**
 * Fast and accurate sine/cosine approximations.<br/>
 * See <a href="http://lab.polygonal.de/2007/07/18/fast-and-accurate-sinecosine-approximation/" target="_blank">http://lab.polygonal.de/2007/07/18/fast-and-accurate-sinecosine-approximation/</a>
 * <br/>
 * Example:
 * <pre>
 * var sin = TrigApprox.hqSin(angle);
 * var cos = TrigApprox.hqCos(sine);
 * </pre>
 */
class TrigApprox
{
	inline static var B =  4 / PMath.PI;
	inline static var C = -4 / (PMath.PI * PMath.PI);
	inline static var Q = .775;
    inline static var P = .225;
	
	/**
	 * Computes a low-precision sine approximation from an angle <i>x</i> measured in radians.
	 * The input angle has to be in the range &#091;-PI,PI&#093;.
	 * @throws de.polygonal.core.util.AssertionError <i>x</i> out of range (<i>if debug flag is set</i>).
	 */
	inline public static function lqSin(x:Float):Float
	{
		//#if debug
		//de.polygonal.core.util.Assert.assert(x >= -Math.PI && x <= Math.PI, Sprintf.format("x out of range (%.3f)", [x]));
		//#end
		
		if (x < 0)
			return 1.27323954 * x + .405284735 * x * x;
		else
			return 1.27323954 * x - .405284735 * x * x;
	}
	
	/** Computes a low-precision cosine approximation from a sine value <i>x</i> (<i>sin(x + PI/2) = cos(x)</i>). */
	inline public static function lqCos(x:Float):Float
	{
		x += PMath.PIHALF; if (x > PMath.PI) x -= PMath.PI2;
		if (x < 0)
			return 1.27323954 * x + .405284735 * x * x
		else
			return 1.27323954 * x - .405284735 * x * x;
	}
	
	/**
	 * Computes a high-precision sine approximation from an angle <i>x</i> measured in radians.
	 * The input angle has to be in the range &#091;-PI,PI&#093;.
	 * @throws de.polygonal.core.util.AssertionError <i>x</i> out of range (<i>if debug flag is set</i>).
	 */
	inline public static function hqSin(x:Float):Float
	{
		//#if debug
		//de.polygonal.core.util.Assert.assert(x >= -Math.PI && x <= Math.PI, Sprintf.format("x out of range (%.3f)", [x]));
		//#end
		
		if (x <= 0)
		{
			var s = 1.27323954 * x + .405284735 * x * x;
			if (s < 0)
				return .225 * (s *-s - s) + s;
			else
				return .225 * (s * s - s) + s;
		}
		else
		{
			var s = 1.27323954 * x - .405284735 * x * x;
			if (s < 0)
				return .225 * (s *-s - s) + s;
			else
				return .225 * (s * s - s) + s;
		}
	}
	
	/** Computes a high-precision cosine approximation from a sine value <i>x</i> (<i>sin(x + PI/2) = cos(x)</i>). */
	inline public static function hqCos(x:Float):Float
	{
		x += PMath.PIHALF; if (x > PMath.PI) x -= PMath.PI2;
		
		if (x < 0)
		{
			var c = 1.27323954 * x + .405284735 * x * x;
			if (c < 0)
				return .225 * (c *-c - c) + c;
			else
				return .225 * (c * c - c) + c;
		}
		else
		{
			var c = 1.27323954 * x - .405284735 * x * x;
			if (c < 0)
				return .225 * (c *-c - c) + c;
			else
				return .225 * (c * c - c) + c;
		}
	}	
	
	/**
	 * Fast arctan2 approximation.
	 * See http://www.dspguru.com/dsp/tricks/fixed-point-atan2-with-self-normalization.
	 */
	inline public static function arctan2(y:Float, x:Float):Float
	{
		/*
		#if debug
		de.polygonal.core.util.Assert.assert(!(PMath.cmpZero(x, 1e-6) && PMath.cmpZero(y, 1e-6)), "PMath.compareZero(x, 1e-6) && PMath.compareZero(y, 1e-6);");
		#end
		*/
		
		var t = PMath.fabs(y);
		if (x >= .0)
		{
			if (y < .0)
				return-((PMath.PI / 4) - (PMath.PI / 4) * ((x - t) / (x + t)));
			else
				return ((PMath.PI / 4) - (PMath.PI / 4) * ((x - t) / (x + t)));
		}
		else
		{
			if (y < .0)
				return-((3. * (PMath.PI / 4)) - (PMath.PI / 4) * ((x + t) / (t - x)));
			else
				return ((3. * (PMath.PI / 4)) - (PMath.PI / 4) * ((x + t) / (t - x)));
		}
	}
}