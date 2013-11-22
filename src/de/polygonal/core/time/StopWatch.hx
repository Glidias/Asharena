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
package de.polygonal.core.time;

import de.polygonal.core.math.Mean;
import de.polygonal.ds.DA;
import de.polygonal.core.util.Assert;

class StopWatch
{
	static var _nextSlot = 0;
	public static function getNextFreeSlot():Int
	{
		return _nextSlot++;
	}
	
	static function init():Void
	{
		_initialized = true;
		
		_time = new DA(32, 32);
		_time.fill(0, 32);
		
		_mean = new DA<Mean>(32, 32);
		_mean.assign(Mean, [10], 32);
	}
	
	public static function free():Void
	{
		for (i in _mean) i.free();
		
		_time.free();
		_mean.free();
		
		_time = null;
		_mean = null;
		
		_initialized = false;
	}
	
	static var _initialized:Bool;
	static var _bits:Int;
	static var _time:DA<Float>;
	static var _mean:DA<Mean>;
	
	inline public static function clock(slot:Int):Void
	{
		if (!_initialized) init();
		var now = haxe.Timer.stamp();
		if (_bits & (1 << slot) > 0)
		{
			_mean.get(slot).add(now - _time.get(slot));
			_bits &= ~(1 << slot);
		}
		else
		{
			_time.set(slot, now);
			_bits |= (1 << slot);
		}
	}
	
	inline public static function query(slot:Int):Float
	{
		if (!_initialized) init();
		return _mean.get(slot).val();
	}
	
	inline public static function reset(slot:Int):Void
	{
		if (!_initialized) init();
		_bits &= ~(1 << slot);
		_mean.get(slot).clear();
	}
	
	inline public static function total():Float
	{
		if (!_initialized) init();
		var t = 0.;
		for (i in 0...32) t += _mean.get(i).val();
		return t;
	}
	
	inline public static function clear():Void
	{
		if (!_initialized) init();
		_bits = 0;
	}
}