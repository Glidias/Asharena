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

import de.polygonal.ds.DA;
import haxe.ds.StringMap;

class LogSystem
{
	public static var config =
	{
		redirectDebugLevelToTrace: true,
		keepDefaultTrace: false,
		addDefaultHandler: true,
		globalHandlers: new Array<LogHandler>(),
		logFileName: "out.log"
	};
	
	public static var log:Log = null;
	
	static var _logList:DA<Log> = null;
	static var _logLookup:StringMap<Log> = null;
	
	public static function init():Void
	{
		if (log != null) return;
		
		log = createLog("global", false);
		
		if (config.addDefaultHandler)
		{
			var handler = createDefaultHandler();
			handler.setFormat(handler.getFormat() & ~de.polygonal.core.log.LogHandler.NAME);
			
			log.addHandler(handler);
			for (i in config.globalHandlers) log.addHandler(i);
			
			config.globalHandlers.push(createDefaultHandler());
		}
		else
		{
			for (i in config.globalHandlers)
				log.addHandler(i);
		}
		
		#if !no_traces
		if (config.redirectDebugLevelToTrace)
		{
			var keepDefaultTrace = config.keepDefaultTrace;
			var defaultTrace = haxe.Log.trace;
			
			//override default trace to add some sprintf sugar
			haxe.Log.trace = function(x:Dynamic, ?posInfos:haxe.PosInfos):Void
			{
				if (posInfos.customParams != null)
				{
					if (~/%(([+\- #0])*)?((\d+)|(\*))?(\.(\d?|(\*)))?[hlL]?[bcdieEfgGosuxX]/g.match(x))
						x = Printf.format(Std.string(x), posInfos.customParams);
					else
						x = x + "," + posInfos.customParams.join(",");
				}
				
				log.debug(x, posInfos);
				
				if (keepDefaultTrace) defaultTrace(x, posInfos);
			}
		}
		else
		{
			if (!config.keepDefaultTrace)
				haxe.Log.trace = function(x:Dynamic, ?posInfos:haxe.PosInfos):Void {};
		}
		#end
	}
	
	public static function registerGlobalHandler(x:LogHandler):Void
	{
		config.globalHandlers.push(x);
	}
	
	/**
	 * Creates a new log or returns an existing one.
	 */
	public static function createLog(name:String, addDefaultHandler = false):Log
	{
		if (_logLookup == null)
		{
			_logLookup = new StringMap<Log>();
			_logList = new DA<Log>();
		}
		
		if (_logLookup.exists(name))
			return _logLookup.get(name);
		
		var log = new Log(name);
		
		_logLookup.set(name, log);
		
		if (addDefaultHandler && config.globalHandlers != null)
		{
			for (i in config.globalHandlers)
				log.addHandler(cast i);
		}
		_logList.pushBack(log);
		return log;
	}
	
	/**
	 * Unregisters an existing log.
	 */
	public static function removeLog(log:Log):Void
	{
		var keys = _logLookup.keys();
		for (i in keys)
		{
			if (_logLookup.exists(i))
			{
				if (log.name == i)
				{
					_logLookup.remove(i);
					_logList.remove(log);
					break;
				}
			}
		}
	}
	
	static function createDefaultHandler():LogHandler
	{
		var handler = null;
		
		#if flash
		handler = new de.polygonal.core.log.handler.TraceHandler();
		#elseif js
		handler = new de.polygonal.core.log.handler.ConsoleHandler();
		#elseif cpp
		handler = new de.polygonal.core.log.handler.FileHandler(config.logFileName);
		#else
		throw "no default log handler available.";
		#end
		
		return handler;
	}
}