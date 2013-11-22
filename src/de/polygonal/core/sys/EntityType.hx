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

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.ds.StringMap;
import haxe.macro.Type;
#end

/**
 * Generates an unique identifier for every class extending de.polygonal.core.sys.Entity.
 */
class EntityType
{
	#if macro
	inline static var CACHE_PATH = "tmp_entity_type_cache";
	
	static var callbackRegistered = false;
	static var types:StringMap<Int> = null;
	static var cache:String = null;
	static var next = -1;
	static var changed = false;
	
	macro public static function build():Array<Field>
	{
		if (Context.defined("display")) return null;
		
		//write cache file when done
		if (!callbackRegistered)
		{
			callbackRegistered = true;
			Context.onGenerate(onGenerate);
			Context.registerModuleDependency("de.polygonal.core.sys.Entity", CACHE_PATH);
		}
		
		var c = Context.getLocalClass().get();
		var f = Context.getBuildFields();
		
		//create unique id for the local class
		var id = c.module;
		if (c.module.indexOf(c.name) == -1)
			id += c.name;
		
		if (cache == null)
			if (sys.FileSystem.exists(CACHE_PATH))
				cache = sys.io.File.getContent(CACHE_PATH);
		
		if (cache != null)
		{
			if (types == null)
			{
				//parse cache file and store in types map
				types = new StringMap<Int>();
				next = -1;
				for (i in cache.split(";"))
				{
					var ereg = ~/([\w.]+):(\d+)/;
					ereg.match(i);
					var j = Std.parseInt(ereg.matched(2));
					if (j > next) next = j;
					types.set(ereg.matched(1), j);
				}
			}
			
			if (types.exists(id))
			{
				//reuse type
				addType(f, types.get(id));
			}
			else
			{
				//append type
				next++;
				addType(f, next);
				types.set(id, next);
				cache += ";" + id + ":" + next;
				changed = true;
			}
		}
		else
		{
			//no cache file exists
			addType(f, 1);
			cache = id + ":" + 1;
			changed = true;
		}
		
		return f;
	}
	
	static function addType(fields:Array<Field>, type:Int):Void
	{
		var p = Context.currentPos();
		fields.push
		(
			{
				name: "___type",
				doc: null,
				meta: [],
				access: [APublic, AStatic],
				kind: FVar(TPath({pack: [], name: "Int", params: [], sub: null}), {expr: EConst(CInt(Std.string(type))), pos: p}),
				pos: p
			}
		);
	}
	
	static function onGenerate(types:Array<haxe.macro.Type>):Void
	{
		if (!changed) return;
		var fout = sys.io.File.write(CACHE_PATH, false);
		fout.writeString(cache);
		fout.close();
	}
	#end
}