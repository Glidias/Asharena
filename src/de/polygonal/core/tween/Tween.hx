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
package de.polygonal.core.tween;

import de.polygonal.core.event.IObservable;
import de.polygonal.core.event.IObserver;
import de.polygonal.core.event.Observable;
import de.polygonal.core.math.interpolation.Interpolation;
import de.polygonal.core.math.interpolation.Mapping;
import de.polygonal.core.math.Mathematics;
import de.polygonal.core.time.Timebase;
import de.polygonal.core.time.TimebaseEvent;
import de.polygonal.core.time.Timeline;
import de.polygonal.core.time.TimelineListener;
import de.polygonal.core.tween.ease.Ease;
import de.polygonal.core.tween.ease.EaseFactory;
import de.polygonal.core.util.Assert;
import de.polygonal.ds.DA;
import haxe.ds.StringMap;

/**
 * <p>Interpolates between two states by using an easing equation.</p>
 */
class Tween implements IObservable implements IObserver implements TimelineListener
{
	static var _activeTweens:DA<Tween>;
	static var _map:StringMap<Tween>;
	
	/**
	 * Stops and destroys all running tweens.
	 */
	public static function stopActiveTweens():Void
	{
		for (i in _activeTweens) i.free();
		if (_activeTweens.isEmpty()) _activeTweens = null;
	}
	
	/**
	 * Returns the <em>Tween</em> object mapped to <code>key</code> or null if no such <em>Tween</em> exists.
	 */
	public static function get(key:String):Tween
	{
		if (_map == null) return null;
		return _map.get(key);
	}
	
	/**
	 * Removes all non-running <em>Tween</em> objects with assigned keys.
	 */
	public static function purge():Void
	{
		for (i in _map.keys())
		{
			var tween = _map.get(i);
			if (tween._id == -1)
				tween.free();
		}
	}
	
	public static function createEaseFunc(from:Float, to:Float, ease:Ease):Float->Float
	{
		var ease = EaseFactory.create(ease);
		return function (alpha:Float):Float return M.lerp(from, to, ease.interpolate(alpha));
	}
	
	/**
	 * Helper function for tweening any <code>fields</code> of an <code>object</code>.
	 */
	public static function create(key:String = null, object:Dynamic, fields:Dynamic, ease:Ease, to:Float, duration:Float, interpolateState = false):Tween
	{
		return new GenericTween(key, object, fields, ease, to , duration, interpolateState).run();
	}
	
	var _id:Int;
	var _key:String;
	var _target:TweenTarget;
	var _a:Float;
	var _b:Float;
	var _min:Float;
	var _max:Float;
	var _ease:Interpolation<Float>;
	var _interpolate:Bool;
	var _duration:Float;
	var _delay:Float;
	var _yoyo:Bool;
	var _repeat:Int;
	var _onComplete:Void->Void;
	var _observable:Observable;
	
	/**
	 * @param key assigning a key makes it possible to reuse this <em>Tween</em> object later on by calling <em>Tween</em>.getKey(<code>key</code>).<br/>
	 * To fully remove a <em>Tween</em> object call <em>Tween.free()</em>.
	 * @param target the object that gets tweened.
	 * @param ease the easing method. If null, no easing is applied and <em>Ease.None</em> is used instead.
	 * @param to the target value.
	 * @param duration the duration in seconds.
	 * @param interpolateState if true, applies the tweened value in a separate rendering step.
	 */
	public function new(key:String = null, target:TweenTarget, ease:Ease, to:Float, duration:Float, interpolateState = false)
	{
		if (ease == null) ease = Ease.None;
		
		#if debug
		D.assert(target != null, "target is null");
		#end
		
		_id          = -1;
		_key         = key;
		_target      = target;
		_ease        = EaseFactory.create(ease);
		_min         = target.get();
		_max         = to;
		_duration    = duration;
		_delay       = 0;
		_interpolate = interpolateState;
		_observable  = null;
		_yoyo        = false;
		_repeat      = 0;
	}
	
	public function free():Void
	{
		if (_observable == null) return;
		if (_activeTweens != null) _activeTweens.remove(this);
		Timeline.detach(this);
		Timeline.cancel(_id);
		if (_interpolate) Timebase.detach(this);
		if (_key != null && _map != null) _map.remove(_key);
		if (_observable != null) _observable.free();
		_id         = -1;
		_key        = null;
		_target     = null;
		_ease       = null;
		_onComplete = null;
		_observable = null;
	}
	
	/**
	 * The tween progress in the interval <arg>&#091;0, 1&#093;</arg>.
	 */
	inline public function getProgress():Float
	{
		return Mapping.map(_b, _min, _max, 0, 1);
	}
	
	inline public function getKey():String
	{
		return _key;
	}
	
	inline public function getEase():Interpolation<Float>
	{
		return _ease;
	}
	
	public function run(onComplete:Void->Void = null):Tween
	{
		if (_key != null)
		{
			if (_map == null) _map = new StringMap();
			if (_map.exists(_key))
			{
				//cancel if running
				if (_id != -1) cancel();
			}
			else
				_map.set(_key, this);
		}
		
		_min = _target.get();
		
		if (onComplete != null)
			_onComplete = onComplete;
		
		_id = Timeline.schedule(this, _duration, _delay);
		return this;
	}
	
	public function once():Tween
	{
		_yoyo = false;
		return this;
	}
	
	public function yoyo(repeat = 0):Tween
	{
		_repeat = repeat + 1;
		_yoyo = true;
		return this;
	}
	
	public function ease(x:Ease):Tween
	{
		_ease = EaseFactory.create(x);
		return this;
	}
	
	public function from(x:Float):Tween
	{
		_target.set(_min = x);
		return this;
	}
	
	public function to(x:Float):Tween
	{
		_max = x;
		return this;
	}
	
	public function duration(x:Float):Tween
	{
		_duration = x;
		return this;
	}
	
	public function delay(x:Float):Tween
	{
		_delay = x;
		return this;
	}
	
	public function onComplete(x:Void->Void):Tween
	{
		_onComplete = x;
		return this;
	}
	
	public function cancel():Tween
	{
		Timeline.cancel(_id);
		_id = 1;
		if (_interpolate) Timebase.detach(this);
		return this;
	}
	
	public function attach(o:IObserver, mask = 0):Void
	{
		if (_observable == null) _observable = new Observable(0, this);
		_observable.attach(o, mask);
	}
	
	public function detach(o:IObserver, mask:Int = 0):Void 
	{
		if (_observable != null) _observable.attach(o, mask);
	}
	
	public function notify(type:Int, userData:Dynamic = null):Void 
	{
		if (_observable != null) _observable.notify(type, userData);
	}
	
	public function onUpdate(type:Int, source:IObservable, userData:Dynamic):Void
	{
		if (_id == -1) return;
		var alpha:Float = userData;
		_target.set(M.lerp(_a, _b, alpha));
	}
	
	function onBlip():Void {}
	
	function onStart():Void
	{
		if (_activeTweens == null) _activeTweens = new DA<Tween>();
		_activeTweens.pushBack(this);
		if (_interpolate) Timebase.attach(this, TimebaseEvent.RENDER);
		_a = _b = _min;
		if (!_interpolate) _target.set(_b);
		notify(TweenEvent.START, _min);
	}
	
	function onProgress(alpha:Float):Void 
	{
		if (_id == -1) return;
		_a = _b; _b = M.lerp(_min, _max, _ease.interpolate(alpha));
		if (!_interpolate) _target.set(_b);
		notify(TweenEvent.ADVANCE, _b);
	}
	
	function onEnd():Void 
	{
		if (_id == -1) return;
		_id = -1;
		_a = _b = _max;
		_target.set(_b);
		
		if (_yoyo && _repeat-- > 0)
		{
			var tmp = _min; _min = _max; _max = tmp;
			run(_onComplete);
			return;
		}
		else
		{
			_activeTweens.remove(this);
			notify(TweenEvent.FINISH, _max);
			if (_onComplete != null)
				_onComplete();
		}
		if (_key == null) free();
	}
	
	function onCancel():Void 
	{
		if (_activeTweens != null) _activeTweens.remove(this);
		notify(TweenEvent.FINISH, _b);
		if (_onComplete != null) _onComplete();
		if (_key == null) free();
	}
}