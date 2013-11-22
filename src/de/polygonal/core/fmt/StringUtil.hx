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
package de.polygonal.core.fmt;

import de.polygonal.core.fmt.ASCII;
import de.polygonal.core.math.random.Random;
import de.polygonal.core.util.Assert;

/**
 * <p>Various utility functions for formatting numbers.</p>
 */
class StringUtil
{
	/**
	 * Returns true if the string <code>x</code> consists of whitespace characters only.
	 */
	public static function isWhite(x:String):Bool
	{
		return ~/\S/.match(x) == false;
	}
	
	/**
	 * Reverses the string <code>x</code>.
	 */
	public static function reverse(x:String):String
	{
		var t = "";
		var i = x.length;
		while (--i >= 0) t += x.charAt(i);
		return t;
	}
	
	/**
	 * Trims the string <code>str</code> to <code>maxLength</code> by replacing surplus characters with the ellipsis character (U+2026).
	 * @param useThreeDots if true, uses three dots (...) instead of the ellipsis character.
	 * @param <code>mode</code>=0: prepend ellipsis, <code>mode</code>=1: append ellipsis, <code>mode</code>=2: center ellipsis.
	 */
	public static function ellipsis(str:String, maxLength:Int, mode:Int, useThreeDots = false):String
	{
		var l = str.length;
		
		#if debug
		D.assert(maxLength > 0, "maxLength > 0");
		#end
		
		if (useThreeDots)
			if (maxLength < 4) return "...";
		
		switch (mode)
		{
			case 0:
				if (l > maxLength)
				{
					var ellipsisCharacter = useThreeDots ? "..." : "…";
					return ellipsisCharacter + str.substr(l + ellipsisCharacter.length - maxLength);
				}
				else
					return str;
			
			case 1:
				if (l > maxLength)
				{
					var ellipsisCharacter = useThreeDots ? "..." : "…";
					return str.substr(0, maxLength - ellipsisCharacter.length) + ellipsisCharacter;
				}
				else
					return str;
			
			case 2:
				var l = str.length;
				var a = str.split("");
				if (useThreeDots)
				{
					a[(l >> 1) - 1] = ".";
					a[(l >> 1)    ] = ".";
					a[(l >> 1) + 1] = ".";
					var side = 1;
					while (l > maxLength)
					{
						side *= -1;
						a.splice((l >> 1) + side, 1);
						a[(l >> 1) + side] = ".";
						l--;
					}
				}
				else
				{
					while (l > maxLength)
					{
						a.splice(l >> 1, 1);
						l--;
					}
					a[l >> 1] = "…";
				}
				return a.join("");
		}
		
		return null;
	}
	
	/**
	 * Prepends <code>n</code> - <code>x</code>.length zeros to the string <code>x</code>.
	 */
	public static function fill0(x:String, n:Int):String
	{
		var s = "";
		for (i in 0...n - x.length) s += "0";
		return s + x;
	}
	
	/**
	 * Converts the string <code>x</code> in binary format into a decimal number.
	 */
	public static function parseBin(x:String):Int
	{
		var b = 0;
		var j = 0;
		var i = x.length;
		while (i-- > 0)
		{
			var s = x.charAt(i);
			if (s == "0")
				j++;
			else
			if (s == "1")
			{
				b += 1 << j;
				j++;
			}
		}
		return b;
	}
	
	/**
	 * Converts the string <code>x</code> in hexadecimal format into a decimal number.
	 */
	public static function parseHex(x:String):Int
	{
		var h = 0;
		var j = 0;
		var i = x.length;
		while (i-- > 0)
		{
			var c = x.charCodeAt(i);
			if (c == 88 || c == 120) break;
			
			if (ASCII.isDigit(c))
			{
				h += (c - ASCII.ZERO) * (1 << j);
				j += 4;
			}
			else
			if (c >= ASCII.A && c <= ASCII.F)
			{
				h += (c - ASCII.F + 15) * (1 << j);
				j += 4;
			}
			else
			if (c >= ASCII.a && c <= ASCII.f)
			{
				h += (c - ASCII.f + 15) * (1 << j);
				j += 4;
			}
		}
		return h;
	}
	
	/**
	 * Generates a random key of given <code>chars</code> and <code>length</code>.
	 */
	public static function generateRandomKey(chars:String, length:Int):String
	{
		var s = "";
		for (i in 0...length)
			s += chars.charAt(Random.randRange(0, chars.length - 1));
		return s;
	}
	
	/**
	 * Returns true if <code>x</code> is latin script only.
	 */
	public static function isLatin(x:String):Bool
	{
		for (i in 0...x.length)
			if (x.charCodeAt(i) > 0x036F)
				return false;
		return true;
	}
}