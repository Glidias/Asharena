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
package de.polygonal.core.util;

import haxe.rtti.CType.TypeTree;

class ClassUtil
{
	/**
	 * Returns the unqualified class name of <code>x</code>.
	 */
	public static function getUnqualifiedClassName(x:Dynamic):String
	{
		if (Std.is(x, Class))
		{
			var s = Type.getClassName(x);
			return s.substr(s.lastIndexOf(".") + 1);
		}
		else
		if (Type.getClass(x) != null)
			return getUnqualifiedClassName(Type.getClass(x));
		else
			return "";
	}
	
	/**
	 * Extracts the package name from <code>x</code>.
	 */
	public static function getPackageName(x:Dynamic):String
	{
		if (Std.is(x, String))
		{
			var s:String = x;
			var i = s.lastIndexOf(".");
			if (i != -1)
				return s.substr(0, i);
			else
				return "";
		}
		else
		if (Std.is(x, Class))
		{
			var s = Type.getClassName(x);
			var i = s.lastIndexOf(".");
			if (i != -1)
				return s.substr(0, i);
			else
				return "";
		}
		else
		if (Type.getClass(x) != null)
			return getPackageName(Type.getClass(x));
		else
			throw "invalid argument";
	}
}