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
import de.polygonal.core.time.Interval;

class SceneTransition extends Entity
{
	public var a:Scene = null;
	public var b:Scene = null;
	
	var _interval:Interval;
	var _mode:SceneTransitionMode;
	var _duration:Float;
	var _phase:Int;
	
	function new(mode:SceneTransitionMode, duration:Float)
	{
		super();
		
		_mode = mode;
		_duration = duration;
		_interval = new Interval(_duration);
		
		if (mode == SceneTransitionMode.Sequential) _duration /= 2;
	}
	
	override function onFree():Void
	{
		a = null;
		b = null;
		_interval = null;
		_mode = null;
	}
	
	override function onAdd(parent:Entity):Void
	{
		switch (_mode) 
		{
			case Sequential:
				_phase = 0;
				if (a == null)
				{
					b.onShowStart(null);
					onStart(a, b);
					return;
				}
				
				a.onHideStart(b);
				onStart(a, b);
			
			case Simultaneous:
				if (a != null) a.onHideStart(b);
				b.onShowStart(a);
				onStart(a, b);
		}
	}
	
	override function onTick(dt:Float, parent:Entity):Void
	{
		switch (_mode) 
		{
			case Sequential:
				var alpha = _interval.alpha;
				_interval.advance(dt);
				if (_phase == 0)
				{
					if (alpha >= 1)
					{
						if (a == null)
						{
							remove();
							onAdvance(b, 1, 1);
							onComplete(b);
							b.onShowEnd(null);
							return;
						}
						
						onAdvance(a, 1, -1);
						onComplete(a);
						
						_phase = 1;
						_interval.reset();
						
						a.onHideEnd(b);
						b.onShowStart(a);
					}
					else
					{
						if (a != null)
							onAdvance(a, alpha, -1);
						else
							onAdvance(b, alpha, 1);
					}
				}
				else
				if (_phase == 1)
				{
					if (alpha >= 1)
					{
						remove();
						onAdvance(b, 1, 1);
						onComplete(b);
						b.onShowEnd(a);
					}
					else
						onAdvance(b, alpha, 1);
				}
			
			case Simultaneous:
				var alpha = _interval.alpha;
				_interval.advance(dt);
				if (alpha >= 1)
				{
					remove();
					if (a != null)
					{
						onAdvance(a, 1, -1);
						onComplete(a);
						a.onHideEnd(b);
					}
					onAdvance(b, 1, 1);
					onComplete(b);
					b.onShowEnd(a);
					return;
				}
				if (a != null) onAdvance(a, alpha, -1);
				onAdvance(b, alpha, 1);
		}
	}
	
	function onStart(a:Scene, b:Scene):Void {}
	
	function onAdvance(scene:Scene, x:Float, dir:Int):Void {}
	
	function onComplete(scene:Scene):Void {}
}