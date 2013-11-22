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
import de.polygonal.ds.ArrayedQueue;
import de.polygonal.ds.Cloneable;
import de.polygonal.ds.Collection;
import de.polygonal.ds.DLL;
import de.polygonal.ds.Heap;
import de.polygonal.ds.Heapable;
import de.polygonal.ds.pooling.ObjectPool;

/**
 * A service that can schedule events to run after a given delay for a given amount of time, or periodically.
 */
@:allow(de.polygonal.core.time)
class Timeline
{
	public static var POOL_SIZE = 4096;
	
	public static function attach(o:IObserver, mask:Int = 0):Void
	{
		D.assert(_initialized, "call Timeline.init() first");
		if (observable == null) init();
		observable.attach(o, mask);
	}
	
	public static function detach(o:IObserver, mask:Int = 0):Void
	{
		D.assert(_initialized, "call Timeline.init() first");
		observable.detach(o, mask);
	}
	
	public static var observable(default, null):Observable;
	
	static var _initialized = false;
	static var _nextId = 0;
	
	static var _currTick:Int;
	static var _currSubTick:Int;
	static var _currInterval:TimeInterval;
	
	static var _runningIntervals:DLL<TimeInterval>;
	static var _pendingAdditions:ArrayedQueue<TimeInterval>;
	static var _intervalHeap:Heap<TimeInterval>;
	static var _intervalPool:ObjectPool<TimeInterval>;
	
	static var _data:Array<Collection<TimeInterval>>;
	
	#if debug
	static var _tickRate:Float;
	#end
	
	public static function init():Void
	{
		if (_initialized) return;
		_initialized = true;
		
		Timebase.init();
		
		observable = new Observable(100);
		
		_currTick = Timebase.processedTicks;
		_currSubTick = 0;
		_currInterval = null;
		_runningIntervals = new DLL<TimeInterval>();
		_pendingAdditions = new ArrayedQueue<TimeInterval>(POOL_SIZE * 10);
		_intervalHeap = new Heap<TimeInterval>();
		_intervalPool = new ObjectPool<TimeInterval>(POOL_SIZE);
		_intervalPool.allocate(true, TimeInterval);
		_data = [_runningIntervals, _pendingAdditions, _intervalHeap];
		
		#if debug
		_tickRate = 0;
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
		
		for (i in _data) for (j in i) j.onCancel();
		
		_runningIntervals.free();
		_runningIntervals = null;
		
		_pendingAdditions.free();
		_pendingAdditions = null;
		
		_intervalHeap.free();
		_intervalHeap = null;
		
		_intervalPool.free();
		_intervalPool = null;
		
		_currInterval = null;
		_data = null;
		
		observable.clear(true);
		observable = null;
	}
	
	/**
	 * Schedules an event to run after <code>delay</code> seconds, for a period of <code>duration</code> seconds.<br/>
	 * If <code>repeatCount</code> &gt; zero, the event repeats <code>repeatCount</code> times, each time waiting for <code>interval</code> seconds before the event is carried out.<br/>
	 * If <code>repeatCount</code> &gt; zero and <em>repeatInterval</em> is omitted, <code>delay</code> is used in place of <code>repeatInterval</code>.
	 * If repeatCount equals minus one the event runs periodically until cancelled.
	 * @return an id that identifies the event. The id can be used to cancel a pending activity by calling <em>Timeline.get().cancel()</em>.
	 */
	public static function schedule(listener:TimelineListener = null, duration:Float, delay = 0., repeatCount = 0, repeatInterval = .0):Int
	{
		D.assert(_initialized, "call Timeline.init() first");
		
		#if debug
		D.assert(duration >= .0, "duration >= .0");
		D.assert(delay >= .0, "delay >= .0");
		D.assert(repeatCount >= 0 || repeatCount == -1, "repeatCount >= 0 || repeatCount == -1");
		D.assert(repeatInterval >= 0, "repeatInterval >= 0");
		if (_tickRate == 0)
			_tickRate = Timebase.tickRate;
		else
		if (Timebase.tickRate != _tickRate)
		{
			var c = _pendingAdditions.size() + _intervalHeap.size() + _runningIntervals.size();
			D.assert(c == 0, "tick rate can't be changed on-the-fly while there are active intervals");
		}
		#end
		
		if (repeatCount != 0 && repeatInterval == .0)
			repeatInterval = delay; //use delay as interval
		
		var delayTicks = Math.round(delay / Timebase.tickRate);
		var ageTicks = _currTick + delayTicks;
		var id = ++_nextId;
		
		var interval =
		if (_intervalPool.isEmpty())
		{
			L.w("TimeInterval pool exhausted");
			new TimeInterval();
		}
		else
		{
			var poolId = _intervalPool.next();
			var interval = _intervalPool.get(poolId);
			interval.poolId = poolId;
			interval;
		}
		
		interval.id = id;
		interval.ageTicks = ageTicks;
		interval.spawnTicks = ageTicks;
		interval.dieTicks = ageTicks + Timebase.secondsToTicks(duration);
		interval.subTicks = _currSubTick++;
		interval.ticks = Timebase.secondsToTicks(repeatInterval);
		interval.iterations = repeatCount;
		interval.iteration = 0;
		interval.listener = listener;
		_pendingAdditions.enqueue(interval);
		
		return id;
	}
	
	/**
	 * Cancels a pending/running event.<br/>
	 * Triggers a <em>TimelineEvent.CANCEL</em> update for this event.
	 * @param id the id of the event. If <code>id</code> is zero, the current event is cancelled.
	 * @return true if the event was successfully cancelled.
	 */
	public static function cancel(id = 0):Bool
	{
		D.assert(_initialized, "call Timeline.init() first");
		
		if (id < 0) return false;
		if (!_initialized) return false;
		if (id == 0)
		{
			#if debug
			D.assert(_currInterval != null, "_currInterval != null");
			#end
			
			_currInterval.cancel();
			return true;
		}
		
		for (collection in _data)
		{
			for (interval in collection)
			{
				if (interval.id == id)
				{
					interval.cancel();
					return true;
				}
			}
		}
		
		return false;
	}
	
	/**
	 * Cancels all pending/running events.<br/>
	 * Triggers a <em>TimelineEvent.CANCEL</em> update for each cancelled event.
	 */
	public static function cancelAll():Void
	{
		D.assert(_initialized, "call Timeline.init() first");
		
		for (collection in _data)
		{
			for (interval in collection)
				interval.cancel();
		}
	}
	
	/**
	 * The current event progress in the range <arg>&#091;0, 1&#093;</arg>.
	 * @throws de.polygonal.core.util.AssertError <em>Timeline</em> is empty (debug only).
	 */
	public static var progress(get_progress, never):Float;
	static function get_progress():Float
	{
		D.assert(_initialized, "call Timeline.init() first");
		D.assert(_currInterval != null, "_currInterval != null");
		
		return _currInterval.getRatio();
	}
	
	/**
	 * The id of the current event.
	 * @throws de.polygonal.core.util.AssertError <em>Timeline</em> is empty (debug only).
	 */
	public static var id(get_id, never):Int;
	inline static function get_id():Int
	{
		D.assert(_initialized, "call Timeline.init() first");
		D.assert(_currInterval != null, "_currInterval != null");
		
		return _currInterval.id;
	}
	
	/**
	 * The iteration for the current event (0=first iteration).<br/>
	 * Returns -1 if the event runs periodically.
	 * @throws de.polygonal.core.util.AssertError <em>Timeline</em> is empty (debug only).
	 */
	public static var iteration(get_iteration, never):Int;
	inline static function get_iteration():Int
	{
		D.assert(_initialized, "call Timeline.init() first");
		D.assert(_currInterval != null, "_currInterval != null");
		
		if (_currInterval.iterations == -1)
			return -1;
		else
			return _currInterval.iteration;
	}
	
	/**
	 * Updates the timeline.
	 */
	public static function advance():Void
	{
		D.assert(_initialized, "call Timeline.init() first");
		
		_currTick = Timebase.processedTicks;
		_currSubTick = 0;
		
		var interval, node, q = _pendingAdditions, h = _intervalHeap, l = _runningIntervals;
		
		//additions are buffered to optimize cancelling of pending intervals (heap removal is expensive)
		for (i in 0...q.size())
		{
			interval = q.dequeue();
			if (interval.isCancelled())
				interval.onCancel();
			else
			{
				#if debug
				D.assert(!h.contains(interval), "!_intervalHeap.contains(interval)");
				#end
				h.add(interval);
			}
		}
		
		//process active events
		node = l.head;
		while (node != null)
		{
			interval = node.val;
			if (interval.isCancelled())
			{
				node = node.unlink();
				interval.onCancel();
				continue;
			}
			
			interval.ageTicks++;
			interval.onProgress(-1);
			
			//die?
			if (interval.ageTicks == interval.dieTicks)
			{
				node = node.unlink();
				//loop or repeat?
				if (interval.iterations != 0)
				{
					interval.onEnd();
					interval.rise();
					interval.subTicks = _currSubTick++;
					q.enqueue(interval);
				}
				else
				{
					interval.reuse();
					interval.onEnd();
				}
			}
			else
				node = node.next;
		}
		
		//process pending events
		while (true)
		{
			if (h.isEmpty()) break;
			
			//get next upcoming event
			var interval = h.top();
			
			if (interval.isCancelled())
			{
				h.pop();
				interval.reuse();
				interval.onCancel();
				continue;
			}
			
			//ready?
			if (interval.ageTicks <= _currTick)
			{
				h.pop();
				
				//blip?
				if (interval.ageTicks == interval.dieTicks)
				{
					interval.onBlip();
					
					//loop or repeat?
					if (interval.doRepeat())
					{
						interval.rise();
						interval.subTicks = _currSubTick++;
						q.enqueue(interval);
					}
					else
						interval.reuse();
				}
				else
				{
					l.append(interval);
					interval.onStart();
					interval.onProgress(-1);
				}
				continue;
			}
			break;
		}
	}
}

@:publicFields
private class TimeInterval
	implements Heapable<TimeInterval>
	implements Cloneable<TimeInterval>
	implements TimelineListener
{
	var id:Int;
	var poolId:Int;
	var spawnTicks:Int;
	var ageTicks:Int;
	var dieTicks:Int;
	var ticks:Int;
	var subTicks:Int;
	var iterations:Int;
	var iteration:Int;
	var listener:TimelineListener = null;
	var position:Int;
	var observable:Observable;
	
	function new()
	{
		observable = Timeline.observable;
		poolId = -1;
	}
	
	inline function getRatio():Float
	{
		return (ageTicks - spawnTicks) / getLife();
	}
	
	inline function getLife():Int
	{
		return (dieTicks - spawnTicks);
	}
	
	inline function rise():Void
	{
		var delayTicks = getLife() + ticks;
		spawnTicks += delayTicks;
		dieTicks += delayTicks;
		ageTicks = spawnTicks;
		
		if (iterations != -1)
		{
			iterations--;
			iteration++;
		}
	}
	
	inline function cancel():Void
	{
		ageTicks = -1;
	}
	
	inline function isCancelled():Bool
	{
		return ageTicks == -1;
	}
	
	inline function doRepeat():Bool
	{
		return iterations != 0;
	}
	
	inline function reuse():Void
	{
		if (poolId != -1) Timeline._intervalPool.put(poolId);
	}
	
	inline function onBlip():Void 
	{
		setCurrentInterval();
		if (listener != null)
			listener.onBlip();
		else
			observable.notify(TimelineEvent.BLIP, id);
	}
	
	inline function onStart():Void 
	{
		setCurrentInterval();
		if (listener != null)
			listener.onStart();
		else
			observable.notify(TimelineEvent.INTERVAL_START, id);
	}
	
	inline function onProgress(alpha:Float):Void
	{
		setCurrentInterval();
		if (listener != null)
			listener.onProgress(getRatio());
		else
			observable.notify(TimelineEvent.INTERVAL_PROGRESS, id);
	}
	
	inline function onEnd():Void 
	{
		setCurrentInterval();
		if (listener != null)
			listener.onEnd();
		else
			observable.notify(TimelineEvent.INTERVAL_END, id);
	}
	
	inline function onCancel():Void 
	{
		setCurrentInterval();
		if (listener != null)
			listener.onCancel();
		else
			observable.notify(TimelineEvent.CANCEL, id);
	}
	
	function compare(other:TimeInterval):Int
	{
		var dt = other.ageTicks - ageTicks;
		return dt == 0 ? (other.subTicks - subTicks) : dt;
	}
	
	function clone():TimeInterval
	{
		var interval = new TimeInterval();
		interval.id = id;
		interval.spawnTicks = spawnTicks;
		interval.ageTicks = ageTicks;
		interval.dieTicks = dieTicks;
		interval.ticks = ticks;
		interval.subTicks = subTicks;
		interval.iterations = iterations;
		return interval;
	}
	
	function toString():String
	{
		var s = "";
		if (iterations == -1)
			s = "repeat=inf";
		else
		if (iterations > 0)
			s = 'repeat=$iterations';
			
		if (getLife() == 0)
			return 'Blip id=$id[$subTicks] start=$spawnTicks $s';
		else
			return Printf.format('Event id=$id[$subTicks] from=$spawnTicks to=$dieTicks progress %.2f $s,', [getRatio()]);
	}
	
	inline function setCurrentInterval():Void Timeline._currInterval = this;
}