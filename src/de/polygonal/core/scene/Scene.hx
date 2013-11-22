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
 * Copyright (c) 2013 Michael Baczynski, http://www.polygonal.de
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
package de.polygonal.core.scene;

import de.polygonal.core.sys.Entity;

class Scene extends Entity
{
	public function new(id:String = null)
	{
		super(id);
	}
	
	override public function free():Void
	{
		L.i('$id.free()');
		super.free();
	}
	
	public function onShowStart(other:Scene):Void
	{
		var otherId = other != null ? other.id : "null";
		L.i('$id.onShowStart($otherId)');
	}
	
	public function onShowEnd(other:Scene):Void
	{
		var otherId = other != null ? other.id : "null";
		L.i('$id.onShowEnd($otherId)');
	}
	
	public function onHideStart(other:Scene):Void
	{
		var otherId = other != null ? other.id : "null";
		L.i('$id.onHideStart($otherId)');
	}
	
	public function onHideEnd(other:Scene):Void
	{
		var otherId = other != null ? other.id : "null";
		L.i('$id.onHideEnd($otherId)');
	}
	
	override function onFree():Void
	{
		L.i('$id.onFree()');
	}
}