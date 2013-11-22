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
package de.polygonal.core.log;

import de.polygonal.core.event.Observable;
import de.polygonal.core.util.Assert;

using de.polygonal.ds.Bits;

/**
 * <p>A lightweight log.</p>
 * <p>Logging messages are passed to registered <em>LogHandler</em> objects.</p>
 */
class Log
{
	static var _counter = 0;
	
	public var name(default, null):String;
	
	public var inclTag:EReg = null;
	public var exclTag:EReg = null;
	
	var _observable:Observable;
	var _mask:Int;
	var _level:Int;
	var _logMessage:LogMessage;
	var _tagFilter:EReg;
	
	public function new(name:String)
	{
		this.name = name;
		
		_mask = 0;
		_level = 0;
		_observable = new Observable();
		_logMessage = new LogMessage();
		setLevel(LogLevel.DEBUG);
	}
	
	/**
	 * Adds the handler <code>x</code> to this log.<br/>
	 * Once registered, <code>x</code> receives logging messages.
	 */
	public function addHandler(x:LogHandler):Void
	{
		#if log
		for (observer in _observable)
			if (observer == x) return;
		_observable.attach(x, 0);
		#end
	}

	/**
	 * Removes the handler <code>x</code> from this log.
	 */
	public function removeHandler(x:LogHandler):Void
	{
		#if log
		_observable.detach(x);
		#end
	}
	
	/**
	 * Removes all handlers  from this log.
	 */
	public function removeAllHandlers():Void
	{
		#if log
		for (handler in _observable.getObserverList())
			removeHandler(cast handler);
		#end
	}
	
	/**
	 * A list of all registered log handlers.
	 */
	public function getLogHandlers():Array<LogHandler>
	{
		return cast _observable.getObserverList();
	}
	
	/**
	 * Returns the name(s) of the active log level(s).<br/>
	 * Example:<br/><br/>
	 * <pre class="prettyprint">
	 * class Main 
	 * {
	 *     static function main() {
	 *         var log = de.polygonal.core.log.Log.getLog("Foo");
	 *         log.setLevel(LogLevel.INFO);
	 *         trace(log.getLevelName()); //INFO
	 *         log.setLevel(LogLevel.INFO | LogLevel.WARN);
	 *         trace(log.getLevelName()); //INFO|WARN
	 *     }
	 * }</pre>
	 */
	public function getLevelName():String
	{
		if (_level.ones() > 1)
		{
			var a = new Array<String>();
			var i = LogLevel.DEBUG;
			while (i < LogLevel.ALL)
			{
				if ((_level & i) > 0)
					a.push(LogLevel.getName(i));
				i <<= 1;
			}
			return a.join("|");
		}
		
		return LogLevel.getName(_level);
	}
	
	/**
	 * Returns the active log level(s) encoded as a bitfield.
	 */
	public function getLevel():Int
	{
		return _level;
	}
	
	/**
	 * Sets the log level <code>x</code> for controlling logging output.<br/>
	 * Enabling logging at a given level also enables logging at all higher levels.<br/>
	 * Each log level is specified by a bit flag in the range 0x01 (<em>LogLevel.DEBUG</em>) to 0x08 (<em>LogLevel.ERROR</em>).<br/>
	 * LogLevel.OFF can be used to turn off logging. The default log level is <em>LogLevel.DEBUG</em>.<br/>
	 * Example:<br/><br/>
	 * <pre class="prettyprint">
	 * import de.polygonal.core.log.LogLevel;
	 * class Main 
	 * {
	 *     static function main() {
	 *         var log = de.polygonal.core.log.Log.getLog("Foo");
	 *         log.setLevel(LogLevel.DEBUG);                 //print DEBUG, INFO, WARN and ERROR log messages
	 *         log.setLevel(LogLevel.WARN);                  //print WARN and ERROR log messages
	 *         log.setLevel(LogLevel.INFO | LogLevel.ERROR); //print INFO and ERROR log messages
	 *         log.setLevel(LogLevel.OFF);                   //print nothing
	 *     }
	 * }</pre>
	 * @throws de.polygonal.core.util.AssertError invalid log level (debug only).
	 */
	#if !log inline #end
	public function setLevel(x:Int):Void
	{
		#if log
		#if debug
		D.assert((x & LogLevel.ALL) > 0, "(x & LogLevel.ALL) > 0");
		#end
		
		_level = x;
		
		if (x.ones() > 1)
		{
			_mask = x;
			return;
		}
		
		_mask = LogLevel.ALL;
		while (x > LogLevel.DEBUG)
		{
			x >>= 1;
			_mask = _mask.clrBits(x);
		}
		#end
	}
	
	/**
	 * Logs a <em>LogLevel.DEBUG</em> message.
	 * @param msg the log message.
	 */
	#if !log inline #end
	public function d(msg:String, ?tag:String, ?posInfos:haxe.PosInfos):Void
	{
		#if log
		if (_observable.size() > 0)
			if (_mask.hasBits(LogLevel.DEBUG)) output(LogLevel.DEBUG, msg, tag, posInfos);
		#end
	}
	
	/**
	 * Logs a <em>LogLevel.DEBUG</em> message.
	 * @param msg the log message.
	 */
	#if !log inline #end
	public function debug(msg:String, ?tag:String, ?posInfos:haxe.PosInfos):Void
	{
		#if log
		if (_observable.size() > 0)
			if (_mask.hasBits(LogLevel.DEBUG)) output(LogLevel.DEBUG, msg, tag, posInfos);
		#end
	}
	
	/**
	 * Logs a <em>LogLevel.INFO</em> message.
	 * @param msg the log message.
	 */
	#if !log inline #end
	public function i(msg:String, ?tag:String, ?posInfos:haxe.PosInfos):Void
	{
		#if log
		if (_observable.size() > 0)
			if (_mask.hasBits(LogLevel.INFO)) output(LogLevel.INFO, msg, tag, posInfos);
		#end
	}
	
	/**
	 * Logs a <em>LogLevel.INFO</em> message.
	 * @param msg the log message.
	 */
	#if !log inline #end
	public function info(msg:String, ?tag:String, ?posInfos:haxe.PosInfos):Void
	{
		#if log
		if (_observable.size() > 0)
			if (_mask.hasBits(LogLevel.INFO)) output(LogLevel.INFO, msg, tag, posInfos);
		#end
	}
	
	/**
	 * Logs a <em>LogLevel.WARN</em> message.
	 * @param msg the log message.
	 */
	#if !log inline #end
	public function w(msg:String, ?tag:String, ?posInfos:haxe.PosInfos):Void
	{
		#if log
		if (_observable.size() > 0)
			if (_mask.hasBits(LogLevel.WARN)) output(LogLevel.WARN, msg, tag, posInfos);
		#end
	}
	
	/**
	 * Logs a <em>LogLevel.WARN</em> message.
	 * @param msg the log message.
	 */
	#if !log inline #end
	public function warn(msg:String, ?tag:String, ?posInfos:haxe.PosInfos):Void
	{
		#if log
		if (_observable.size() > 0)
			if (_mask.hasBits(LogLevel.WARN)) output(LogLevel.WARN, msg, tag, posInfos);
		#end
	}
	
	/**
	 * Logs a <em>LogLevel.ERROR</em> message.
	 * @param msg the log message.
	 */
	#if !log inline #end
	public function e(msg:String, ?tag:String, ?posInfos:haxe.PosInfos):Void
	{
		#if log
		if (_observable.size() > 0)
			if (_mask.hasBits(LogLevel.ERROR)) output(LogLevel.ERROR, msg, tag, posInfos);
		#end
	}
	
	/**
	 * Logs a <em>LogLevel.ERROR</em> message.
	 * @param msg the log message.
	 */
	#if !log inline #end
	public function error(msg:String, ?tag:String, ?posInfos:haxe.PosInfos):Void
	{
		#if log
		if (_observable.size() > 0)
			if (_mask.hasBits(LogLevel.ERROR)) output(LogLevel.ERROR, msg, tag, posInfos);
		#end
	}

	function output(level:Int, msg:String, tag:String, ?posInfos:haxe.PosInfos):Void
	{
		if (inclTag != null)
			if (!inclTag.match(tag))
				return;
		
		if (exclTag != null)
			if (exclTag.match(tag))
				return;
		
		_counter++; if (_counter == 1000) _counter = 0;
		
		if (msg == null) msg = "null";
		
		_logMessage.id          = _counter;
		_logMessage.msg         = msg;
		_logMessage.tag         = tag;
		_logMessage.log         = this;
		_logMessage.outputLevel = level;
		_logMessage.posInfos    = posInfos;
		_observable.notify(LogEvent.LOG_MESSAGE, _logMessage);
	}
}