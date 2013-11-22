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
package de.polygonal.core.sys;

import de.polygonal.core.event.IObservable;
import de.polygonal.core.sys.Entity;
import de.polygonal.core.time.Timebase;
import de.polygonal.core.time.TimebaseEvent;
import de.polygonal.core.time.Timeline;

class MainLoop extends Entity
{
	static var _instance:MainLoop = null;
	inline public static function get():MainLoop
	{
		return _instance == null ? (_instance = new MainLoop()) : _instance;
	}
	
	public static var onTick0:Void->Void = function() {};
	public static var onTick1:Void->Void = function() {};
	
	public static var onDraw0:Void->Void = function() {};
	public static var onDraw1:Void->Void = function() {};
	
	public var paused = false;
	
	function new()
	{
		super();
		
		Timebase.init();
		Timebase.attach(this);
		Timeline.init();
	}
	
	override function onFree():Void
	{
		Timebase.detach(this);
	}
	
	override public function onUpdate(type:Int, source:IObservable, userData:Dynamic):Void
	{
		switch (type)
		{
			case TimebaseEvent.TICK:
				onTick0();
				
				if (paused) return;
				
				Timeline.advance();
				commit();
				
				var timeDelta:Float = userData;
				propagateTick(timeDelta, this);
				
				onTick1();
			
			case TimebaseEvent.RENDER:
				onDraw0();
				
				if (paused) return;
				
				var alpha:Float = userData;
				propagateDraw(alpha, this);
				
				onDraw1();
		}
	}
}