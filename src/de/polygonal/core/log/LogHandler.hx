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

import de.polygonal.core.event.IObservable;
import de.polygonal.core.event.IObserver;
import de.polygonal.core.fmt.StringUtil;
import de.polygonal.core.log.LogLevel;
import de.polygonal.core.log.LogMessage;
import de.polygonal.core.util.Assert;
import haxe.ds.StringMap;

using de.polygonal.ds.BitFlags;
using de.polygonal.ds.Bits;

/**
 * <p>A log handler receives log messages from a log and exports them to various output devices.</p>
 */
@:build(de.polygonal.core.util.IntEnum.build(
[
	DATE,
	TIME,
	LEVEL,
	NAME,
	TAG,
	CLASS,
	CLASS_SHORT,
	METHOD,
	LINE
], true))
class LogHandler implements IObserver
{
	inline public static var FORMAT_RAW         = 0;
	inline public static var FORMAT_BRIEF       =               LEVEL | NAME | TAG;
	inline public static var FORMAT_BRIEF_INFOS =               LEVEL | NAME | TAG | LINE | CLASS | CLASS_SHORT | METHOD;
	inline public static var FORMAT_FULL        = DATE | TIME | LEVEL | NAME | TAG | LINE | CLASS | CLASS_SHORT | METHOD;
	
	public static var DEFAULT_FORMAT = FORMAT_BRIEF_INFOS;
	
	var _level:Int;
	var _mask:Int;
	var _bits:Int;
	var _message:LogMessage;
	var _tagFormat:StringMap<Int>;
	
	function new()
	{
		_level = 0;
		_mask = 0;
		_bits = 0;
		_message = null;
		_tagFormat = null;
		
		setLevel(LogLevel.DEBUG);
		setFormat(0);
		init();
	}
	
	/**
	 * Destroys this object by explicitly nullifying all references for GC'ing used resources.
	 */
	public function free():Void {}
	
	/**
	 * Returns the active output level(s) encoded as a bitfield.
	 */
	public function getLevel():Int
	{
		return _level;
	}
	
	/**
	 * Returns the name(s) of the active output level(s).<br/>
	 * @see <em>Log#getLevelName()</em>.
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
	 * Sets the log level <code>x</code> specifying which message levels will be ultimately handled.<br/>
	 * Example:<br/><br/>
	 * <pre class="prettyprint">
	 * import de.polygonal.core.log.LogLevel;
	 * import de.polygonal.core.log.Log;
	 * import de.polygonal.core.log.handler.TraceHandler;
	 * class Main
	 * {
	 *     static function main() {
	 *         var log = Log.getLog("Foo");
	 *         log.setLevel(LogLevel.DEBUG); //print DEBUG, INFO, WARN and ERROR logging messages
	 *         var handler = new TraceHandler();
	 *         handler.setLevel(Level.WARN); //log allows all levels, but the handler filters out everything except Level.WARN.
	 *     }
	 * }</pre>
	 * @throws de.polygonal.core.util.AssertError invalid log level (debug only).
	 */
	public function setLevel(x:Int):Void
	{
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
	}
	
	/**
	 * The current logging format encoded as a bitfield.
	 */
	public function getFormat():Int
	{
		return _bits;
	}
	
	/**
	 * Adds extra information to a logging message.<br/>
	 * Example:<br/><br/>
	 * <pre class="prettyprint">
	 * import de.polygonal.core.log.LogHandler;
	 * import de.polygonal.core.log.handler.TraceHandler;
	 * class Main
	 * {
	 *     static function main() {
	 *         var handler = new TraceHandler();
	 *         handler.setFormat(LogHandler.TIME | LogHandler.NAME);</pre>
	 *     }
	 * }</pre>
	 */
	public function setFormat(flags:Int, tag:String = null):Void
	{
		if (flags == 0) nulf();
		if (tag != null)
		{
			if (_tagFormat == null)
				_tagFormat = new StringMap();
			_tagFormat.set(tag, flags);
		}
		else
			_bits = flags;
	}
	
	public function onUpdate(type:Int, source:IObservable, userData:Dynamic):Void
	{
		if (type == LogEvent.LOG_MESSAGE)
		{
			_message = cast userData;
			
			if (_mask.hasBits(_message.outputLevel))
			{
				var tmp = _bits;
				if (_tagFormat != null && _tagFormat.exists(_message.tag))
					_bits = _tagFormat.get(_message.tag);
				
				output(format());
				
				_bits = tmp;
			}
		}
	}
	
	function format():String
	{
		var args:Array<String> = [];
		var vals:Array<Dynamic> = [];
		
		var fmt, val;
		
		//date & time
		fmt = "%s";
		val = "";
		if (hasf(DATE | TIME))
		{
			var date = Date.now().toString();
			if (getf(DATE | TIME) == DATE | TIME)
				val = date.substr(5); //mm-dd hh:mm:ss
			else
			if (hasf(TIME))
				val = date.substr(11); //hh:mm:ss
			else
				val = date.substr(5, 5); //mm-dd
		}
		args.push(fmt);
		vals.push(val);
		
		//level
		fmt = "%s";
		val = "";
		if (hasf(LEVEL))
		{
			val = LogLevel.getShortName(_message.outputLevel);
			if (hasf(DATE | TIME)) fmt = " %s";
		}
		args.push(fmt);
		vals.push(val);
		
		//log name
		fmt = "%s";
		val = "";
		if (hasf(NAME))
		{
			if (hasf(LEVEL)) fmt = "/%s";
			val = _message.log.name;
		}
		args.push(fmt);
		vals.push(val);
		
		//message tag
		fmt = "%s";
		val = "";
		if (hasf(TAG))
		{
			if (_message.tag != null)
			{
				val = _message.tag;
				fmt = "/%s";
			}
		}
		args.push(fmt);
		vals.push(val);
		
		//position infos
		fmt = "%s";
		if (hasf(CLASS | METHOD | LINE))
		{
			fmt = "(";
			
			if (hasf(CLASS))
			{
				var className = _message.posInfos.className;
				if (hasf(CLASS_SHORT))
					className = className.substr(className.lastIndexOf(".") + 1);
				if (className.length > 30)
					className = StringUtil.ellipsis(className, 30, 0);
				
				fmt += "%s";
				vals.push(className);
			}
			
			if (hasf(METHOD))
			{
				var methodName = _message.posInfos.methodName;
				if (methodName.length > 30) methodName = StringUtil.ellipsis(methodName, 30, 0);
				
				fmt += hasf(CLASS) ? ".%s" : "%s";
				vals.push(methodName);
			}
			
			if (hasf(LINE))
			{
				fmt += hasf(CLASS | METHOD) ? " %04d" : "%04d";
				vals.push(_message.posInfos.lineNumber);
			}
			
			fmt += ")";
		}
		else
			vals.push("");
		args.push(fmt);
		
		//message
		fmt = _bits == 0 ? "%s" : ": %s";
		val = _message.msg;
		var s = val;
		if (Std.is(s, String) && s.indexOf("\n") != -1)
		{
			var pre = "";
			if (hasf(LEVEL))
				pre = LogLevel.getShortName(_message.outputLevel);
			if (hasf(NAME))
			{
				if (hasf(LEVEL))
					pre += "/";
				pre += _message.log.name;
			}
			if (hasf(TAG))
				if (_message.tag != null)
					pre += "/" + _message.tag;
			
			if (s.indexOf("\r") != -1)
				s = s.split("\r").join("");
			var tmp = [];
			for (i in s.split("\n"))
				if (i != "") tmp.push(i);
			
			if (_bits != FORMAT_RAW)
				val = "\n" + pre + ": " + tmp.join("\n" + pre + ": ");
		}
		
		args.push(fmt);
		vals.push(val);
		
		return Printf.format(args.join(""), vals);
	}
	
	function output(msg:String):Void {}
	
	function init():Void
	{
		_bits = DEFAULT_FORMAT;
	}
}