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

import de.polygonal.core.event.IObserver;
import de.polygonal.core.event.Observable;
import de.polygonal.core.util.Assert;
import de.polygonal.core.math.Mathematics;

/**
 * A Timebase is a constantly ticking source of time.
 */
class Timebase
{
	public static function attach(o:IObserver, mask:Int = 0):Void
	{
		D.assert(_initialized, "call Timebase.init() first");
		observable.attach(o, mask);
	}
	
	public static function detach(o:IObserver, mask:Int = 0):Void
	{
		D.assert(_initialized, "call Timebase.init() first");
		observable.detach(o, mask);
	}
	
	/**
	 * Converts <code>x</code> seconds to ticks.
	 */
	inline public static function secondsToTicks(x:Float):Int
	{
		return M.round(x / tickRate);
	}
	
	/**
	 * Converts <code>x</code> ticks to seconds.
	 */
	inline public static function ticksToSeconds(x:Int):Float
	{
		return x * tickRate;
	}
	
	/**
	 * If true, time is consumed using a fixed time step (see <em>Timebase.get().getTickRate()</em>).<br/>
	 * Default is true.
	 */
	public static var useFixedTimeStep = true;
	
	/**
	 * The update rate measured in seconds per tick.<br/>
	 * The default update rate is 60 ticks per second (or ~16.6ms per step).
	 */
	public static var tickRate(default, null):Float = 0.01666666;
	
	/**
	 * Processed time in seconds.
	 */
	public static var realTime(default, null) = 0.;
	
	/**
	 * Processed "virtual" time in seconds (includes scaling).
	 */
	public static var gameTime(default, null) = 0.;
	
	/**
	 * Frame delta time in seconds.
	 */
	public static var realTimeDelta(default, null) = 0.;
	
	/**
	 * "Virtual" frame delta time in seconds (includes scaling).
	 */
	public static var gameTimeDelta(default, null) = 0.;
	
	/**
	 * The current time scale.<br/>
	 * Only positive values are allowed.
	 */
	public static var timeScale(default, null) = 1.;
	
	/**
	 * The total number of processed ticks since the first observer received a <em>TimebaseEvent.TICK</em> update.
	 */
	public static var processedTicks(default, null) = 0;
	
	/**
	 * The total number of rendered frames since the first observer received a <em>TimebaseEvent.RENDER</em> update.
	 */
	public static var processedFrames(default, null) = 0;
	
	/**
	 * Frames per second (how many frames were rendered in 1 second).
	 */
	public static var fps(default, null) = 60;
	
	public static var observable(default, null):Observable = null;
	
	static var _freezeDelay:Float;
	static var _halted:Bool;
	
	static var _accumulator:Float;
	static var _accumulatorLimit:Float;
	
	static var _fpsTicks:Int;
	static var _fpsTime:Float;
	static var _past:Float;
	
	static var _initialized:Bool;
	
	#if js
	static var _requestAnimFrame:Dynamic;
	#end
	
	public static function init():Void
	{
		if (_initialized) return;
		_initialized = true;
		
		observable = new Observable(100);
		
		useFixedTimeStep = true;
		tickRate = 1 / 60;
		processedTicks = 0;
		processedFrames = 0;
		timeScale = 1;
		realTime = 0;
		realTimeDelta = 0;
		gameTime = 0;
		gameTimeDelta = 0;
		fps = 60;
		
		_accumulator = 0;
		_accumulatorLimit = tickRate * 10;
		_fpsTicks = 0;
		_fpsTime = 0;
		_past = stamp();
		
		#if (flash || cpp)
		flash.Lib.current.addEventListener(flash.events.Event.ENTER_FRAME, onEnterFrame);
		#elseif js
		_requestAnimFrame = function(cb:Dynamic):Void
		{
			var w:Dynamic = js.Browser.window;
			var f:Dynamic =
			if (w.requestAnimationFrame != null)
				w.requestAnimationFrame;
			else
			if (w.webkitRequestAnimationFrame != null)
				w.webkitRequestAnimationFrame;
			else
			if (w.mozRequestAnimationFrame != null)
				w.mozRequestAnimationFrame;
			else
			if (w.oRequestAnimationFrame != null)
				w.oRequestAnimationFrame;
			else
			if (w.msRequestAnimationFrame != null)
				w.msRequestAnimationFrame;
			else
				function(x) { w.setTimeout(x, tickRate * 1000); };
			f(cb);
		}
		step();
		#end
	}
	
	/**
	 * Destroys the system by removing all registered observers and explicitly nullifying all references for GC'ing used resources.
	 * The system is automatically reinitialized once an observer is attached.
	 */	
	public static function free():Void
	{
		if (!_initialized) return;
		_initialized = false;
		
		observable.free();
		observable = null;
		
		#if (flash || cpp)
		flash.Lib.current.removeEventListener(flash.events.Event.ENTER_FRAME, onEnterFrame);
		#elseif js
		_requestAnimFrame = null;
		#end
	}
	
	/**
	 * Sets the update rate measured in ticks per second, e.g. a value of 60 indicates that <em>TimebaseEvent.TICK</em> is fired 60 times per second (or every ~16.6ms).
	 * @param max The accumulator limit in seconds. If omitted, <code>max</code> is set to ten times <code>ticksPerSecond</code>.
	 */
	public static function setTickRate(ticksPerSecond:Int, max = -1.):Void
	{
		tickRate = 1 / ticksPerSecond;
		_accumulator = 0;
		_accumulatorLimit = (max == -1. ? 10 : max * tickRate);
	}
	
	/**
	 * Stops the flow of time.<br/>
	 * Triggers a <em>TimebaseEvent.HALT</em> update.
	 */
	public static function halt():Void
	{
		D.assert(_initialized, "call Timebase.init() first");
		if (!_halted)
		{
			_halted = true;
			observable.notify(TimebaseEvent.HALT);
		}
	}
	
	/**
	 * Resumes the flow of time.<br/>
	 * Triggers a <em>TimebaseEvent.RESUME</em> update.
	 */
	public static function resume():Void
	{
		D.assert(_initialized, "call Timebase.init() first");
		if (_halted)
		{
			_halted = false;
			_accumulator = 0.;
			_past = stamp();
			observable.notify(TimebaseEvent.RESUME);
		}
	}
	
	/**
	 * Toggles (halt/resume) the flow of time.<br/>
	 * Triggers a <em>TimebaseEvent.HALT</em> or em>TimebaseEvent.RESUME</em> update.
	 */
	public static function toggleHalt():Void
	{
		_halted ? resume() : halt();
	}
	
	/**
	 * Freezes the flow of time for <code>x</code> seconds.<br/>
	 * Triggers a <em>TimebaseEvent.FREEZE_BEGIN</em> update.
	 */
	public static function freeze(x:Float):Void
	{
		D.assert(_initialized, "call Timebase.init() first");
		_freezeDelay = x;
		_accumulator = 0;
		observable.notify(TimebaseEvent.FREEZE_BEGIN);
	}
	
	/**
	 * Performs a manual update step.
	 */
	public static function manualStep():Void
	{
		D.assert(_initialized, "call Timebase.init() first");
		realTimeDelta = tickRate;
		realTime += realTimeDelta;
		
		gameTimeDelta = tickRate * timeScale;
		gameTime += gameTimeDelta;
		
		observable.notify(TimebaseEvent.TICK, tickRate);
		processedTicks++;
		
		observable.notify(TimebaseEvent.RENDER, 1);
		processedFrames++;
	}
	
	static function step():Void
	{
		#if js
		if (_requestAnimFrame == null) return;
		_requestAnimFrame(step);
		#end
		
		if (_halted) return;
		
		var now = stamp();
		var dt = (now - _past);
		_past = now;
		
		realTimeDelta = dt;
		realTime += dt;
		
		_fpsTicks++;
		_fpsTime += dt;
		if (_fpsTime >= 1)
		{
			_fpsTime -= 1;
			fps = _fpsTicks;
			_fpsTicks = 0;
		}
		
		if (_freezeDelay > 0.)
		{
			_freezeDelay -= realTimeDelta;
			observable.notify(TimebaseEvent.TICK  , 0.);
			observable.notify(TimebaseEvent.RENDER, 1.);
			
			if (_freezeDelay <= 0.)
				observable.notify(TimebaseEvent.FREEZE_END);
			return;
		}
		
		if (useFixedTimeStep)
		{
			_accumulator += realTimeDelta * timeScale;
			
			//clamp accumulator to prevent "spiral of death"
			if (_accumulator > _accumulatorLimit)
			{
				#if verbose
				L.w(Printf.format("accumulator clamped from %.2f to %.2f seconds", [_accumulator, _accumulatorLimit]));
				#end
				observable.notify(TimebaseEvent.CLAMP, _accumulator);
				_accumulator = _accumulatorLimit;
			}
			
			gameTimeDelta = tickRate * timeScale;
			while (_accumulator >= tickRate)
			{
				_accumulator -= tickRate;
				gameTime += gameTimeDelta;
				observable.notify(TimebaseEvent.TICK, tickRate);
				processedTicks++;
			}
			
			var alpha = _accumulator / tickRate;
			observable.notify(TimebaseEvent.RENDER, alpha);
			processedFrames++;
		}
		else
		{
			_accumulator = 0;
			gameTimeDelta = dt * timeScale;
			gameTime += gameTimeDelta;
			observable.notify(TimebaseEvent.TICK, gameTimeDelta);
			processedTicks++;
			observable.notify(TimebaseEvent.RENDER, 1.);
			processedFrames++;
		}
	}
	
	#if (flash || cpp)
	static function onEnterFrame(e:flash.events.Event):Void
	{
		step();
	}
	#end
	
	inline static function stamp():Float
	{
		return
		#if flash
		Date.now().getTime() / 1000
		#else
		haxe.Timer.stamp()
		#end
		;
	}
}