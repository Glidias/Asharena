/*
 *                            _/                                                    _/
 *       _/_/_/      _/_/    _/  _/    _/    _/_/_/    _/_/    _/_/_/      _/_/_/  _/
 *      _/    _/  _/    _/  _/  _/    _/  _/    _/  _/    _/  _/    _/  _/    _/  _/
 *     _/    _/  _/    _/  _/  _/    _/  _/    _/  _/    _/  _/    _/  _/    _/  _/
 *    _/_/_/      _/_/    _/    _/_/_/    _/_/_/    _/_/    _/    _/    _/_/_/  _/
 *   _/                            _/        _/
 *  _/                        _/_/      _/_/
 *
 * POLYGONAL - A HAXE LIBRARY FOR GAME DEVELOPERS
 * Copyright (c) 2009 Michael Baczynski, http://www.polygonal.de
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
package de.polygonal.core.math;

import de.polygonal.ds.ArrayUtil;
import haxe.ds.Vector;

/**
 * <p>The Ziggurat method for generating pseudo random normal and exponential variates.</p>
 * @see http://www.jstatsoft.org/v05/i08/paper
 */
class RNORREXP
{
	var _iz:UInt;
	var _jz:UInt;
	var _hz:Int;

	var _kn:Vector<Float>;
	var _ke:Vector<Float>;
	var _wn:Vector<Float>;
	var _we:Vector<Float>;
	var _fn:Vector<Float>;
	var _fe:Vector<Float>;

	var _jsr:Int;

	public function new(seed:Int)
	{
		_kn = new Vector<Float>(128);
		_ke = new Vector<Float>(256);
		_wn = new Vector<Float>(128);
		_we = new Vector<Float>(256);
		_fn = new Vector<Float>(128);
		_fe = new Vector<Float>(256);
		_jsr = 123456789;
		initLUT(seed);
	}
	
	/**
	 * Generate a standard normal variate with mean zero and variance 1.<br/>
	 * The required variate is returned some 99% of the time after two table fetches and a test on magnitude.
	 */
	public function RNOR():Float
	{
		_hz = sh3();
		_iz = _hz & 127;
		if ((_hz < 0 ? -_hz : _hz) < _kn[_iz])
			return _hz * _wn[_iz];
		else
		{
			var x:Float, y:Float;
			while (true)
			{
				x = _hz * _wn[_iz];
				if (_iz == 0)
				{
					do
					{
						x = -Math.log(.5 + uni()) * 0.2904764;
						y = -Math.log(.5 + uni());
					}
					while (y + y < x * x);
					return (_hz > 0) ? (3.442620 + x) : (-3.442620 - x);
				}
				
				if (_fn[_iz] + (.5 + uni()) * (_fn[_iz - 1] - _fn[_iz]) < Math.exp(-.5 * x * x)) return x;
				_hz = sh3();
				_iz = _hz & 127;
				if ((_hz < 0 ? -_hz : _hz) < _kn[_iz]) return (_hz * _wn[_iz]);
			}
		}
		return Math.NaN;
	}
	
	/**
	 * Generate an exponential variate with density exp(-x), x > 0.
	 */
	public function REXP():Float
	{
		_jz = sh3();
		_iz = _jz & 255;
		if (_jz < _ke[_iz])
			return _jz * _we[_iz];
		else
		{
			var x:Float;
			while (true)
			{
				if (_iz == 0) return (7.69711 - Math.log(uni()));
				x = _jz * _we[_iz];
				if (_fe[_iz] + uni() * (_fe[_iz - 1] - _fe[_iz]) < Math.exp(-x)) return x;
				_jz = sh3();
				_iz = _jz & 255;
				if (_jz < _ke[_iz]) return (_jz * _we[_iz]);
			}
		}
		return Math.NaN;
	}
	
	inline function uni():Float
	{
		return (.5 + sh3() * 0.2328306e-9);
	}
	
	inline function sh3():Int
	{
		_jz = _jsr;
		_jsr ^= (_jsr << 13);
		_jsr ^= (_jsr >>> 17);
		_jsr ^= (_jsr << 5);
		return _jz + _jsr;
	}
	
	function initLUT(jsrseed:Int):Void
	{
		var m1 = 2147483648.;
		var m2 = 4294967296.;
		var dn = 3.442619855899;
		var tn = dn;
		var vn = 9.91256303526217e-3;
		var de = 7.697117470131487;
		var te = de;
		var ve = 3.949659822581572e-3;
		var q = vn / Math.exp(-.5 * dn * dn);
		
		_jsr ^= jsrseed;
		
		var t:Float = Std.int((dn / q) * m1);
		if (t < 0) t += 4294967296.;
		
		_kn[0]   = t;
		_kn[1]   = 0;
		_wn[0]   = q / m1;
		_wn[127] = dn / m1;
		_fn[0]   = 1;
		_fn[127] = Math.exp(-.5 * dn * dn);
		
		var i = 126;
		while (i >= 1)
		{
			dn = Math.sqrt(-2 * Math.log(vn / dn + Math.exp(-.5 * dn * dn)));
			
			var t:Float = Std.int((dn / tn) * m1);
			if (t < 0) t += 4294967296.;
			
			_kn[i + 1] = t;
			tn = dn;
			_fn[i] = Math.exp(-.5 * dn * dn);
			_wn[i] = dn / m1;
			i--;
		}
		
		var t:Float = Std.int((de / q) * m2);
		if (t < 0) t += 4294967296.;
		
		q = ve / Math.exp(-de);
		_ke[0]   = t;
		_ke[1]   = 0;
		_we[0]   = q / m2;
		_we[255] = de / m2;
		_fe[0]   = 1;
		_fe[255] = Math.exp(-de);
		
		var i = 254;
		while (i >= 1)
		{
			de = -Math.log(ve / de + Math.exp(-de));
			
			var t:Float = Std.int((de / te) * m2);
			if (t < 0) t += 4294967296.;
			_ke[i + 1] = t;
			
			te = de;
			_fe[i] = Math.exp(-de);
			_we[i] = de / m2;
			i--;
		}
	}
}