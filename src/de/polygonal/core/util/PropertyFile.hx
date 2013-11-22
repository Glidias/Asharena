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
package de.polygonal.core.util;

import haxe.ds.StringMap;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
#end

class PropertyFile
{
	#if macro
	static var _url:String;
	
	macro public static function build(url:String, useStaticFields:Bool, useInline:Bool):Array<Field>
	{
		_url = url;
		
		Context.registerModuleDependency(Std.string(Context.getLocalClass()), url);
		var pos = Context.currentPos();
		
		var fields = Context.getBuildFields();
		var assign = new Array<Expr>();
		
		var access = [APublic];
		if (useStaticFields)
		{
			access.push(AStatic);
			if (useInline)
				access.push(AInline);
		}
		
		var map = parse(sys.io.File.getContent(url));
		for (key in map.keys())
		{
			var val = map.get(key);
			
			var c = null, n:String, p = [];
			if (val.indexOf(",") != -1)
			{
				var arrExpr = [];
				var arrType;
				var tmp = val.split(",");
				
				if (tmp[0].indexOf(".") != -1)
				{
					for (i in tmp) arrExpr.push({expr: EConst(CFloat(Std.string(Std.parseFloat(i)))), pos: pos});
					arrType = "Float";
				}
				else
				if (tmp[0] == "false" || tmp[0] == "true")
				{
					for (i in tmp) arrExpr.push({expr: EConst(CIdent(Std.string(i))), pos: pos});
					arrType = "Bool";
				}
				else
				{
					var int = Std.parseInt(tmp[0]);
					if (int == null)
					{
						for (i in tmp) arrExpr.push({expr: EConst(CString(i)), pos: pos});
						arrType = "String";
					}
					else
					{
						for (i in tmp) arrExpr.push({expr: EConst(CInt(Std.string(Std.parseInt(i)))), pos: pos});
						arrType = "Int";
					}
				}
				
				n = "Array";
				c = EArrayDecl(arrExpr);
				p = [TPType(TPath({sub: null, name: arrType, pack: [], params: []}))];
			}
			else
			if (val.indexOf(".") != -1)
			{
				if (Math.isNaN(Std.parseFloat(val)))
				{
					c = EConst(CString(val));
					n = "String";
				}
				else
				{
					c = EConst(CFloat(StringTools.trim(val)));
					n = "Float";
				}
			}
			else
			if (val == "true" || val == "false")
			{
				c = EConst(CIdent(val));
				n = "Bool";
			}
			else
			{
				var int = Std.parseInt(val);
				if (int == null)
				{
					c = EConst(CString(val));
					n = "String";
				}
				else
				{
					c = EConst(CInt(StringTools.trim(val)));
					n = "Int";
				}
			}
			
			if (c == null)
				Context.error("invalid field type", Context.currentPos());
			
			if (useStaticFields)
				fields.push({name: key, doc: null, meta: [], access: access, kind: FVar(TPath({pack: [], name: n, params: p, sub: null}), {expr: c, pos: pos}), pos: pos});
			else
			{
				fields.push({name: key, doc: null, meta: [], access: access, kind: FVar(TPath({pack: [], name: n, params: p, sub: null})), pos: pos});
				assign.push({expr: EBinop(Binop.OpAssign, {expr: EConst(CIdent(key)), pos: pos}, {expr: c, pos: pos}), pos:pos});
			}
		}
		
		if (!useStaticFields) fields.push({name: "new", doc: null, meta: [], access: [APublic], kind: FFun({args: [], ret: null, expr: {expr: EBlock(assign), pos:pos}, params: []}), pos: pos});
		return fields;
	}
	#end
	
	/**
	 * Parses a .properties file according to this <a href="http://en.wikipedia.org/wiki/Java_properties">format</a>.
	 * @return a hash with all key/value pairs defined in <code>str</code>.
	 */
	public static function parse(str:String):StringMap<String>
	{
		var pairs = new StringMap<String>();
		
		function add(pair)
		{
			if (pair != null)
			{
				if (pairs.exists(pair.key))
				{
					var msg = "found duplicate key: " + pair.key;
					#if macro
					var min = str.indexOf(pair.key, str.indexOf(pair.key) + 1);
					var max = min + pair.key.length;
					Context.error(msg, Context.makePosition({min: min, max: max, file: _url}));
					#else
					throw msg;
					#end
				}
				pairs.set(pair.key, pair.val);
			}
		}
		
		var line = "";
		var i = 0;
		var k = str.length - 1;
		while (i < k)
		{
			var c = str.charAt(i++);
			var peek = str.charAt(i);
			
			if (c == "\r")
			{
				if (peek == "\n")
				{
					i++;
					if (str.charAt(i - 3) != "\\")
					{
						add(parseLine(line));
						line = "";
					}
				}
				else
				if (str.charAt(i - 2) != "\\")
				{
					add(parseLine(line));
					line = "";
				}
			}
			else
			if (c == "\n")
			{
				if (str.charAt(i - 2) != "\\")
				{
					add(parseLine(line));
					line = "";
				}
			}
			else
			if (c == "\\") {}
			else
				line += c;
		}
		
		line += str.charAt(k);
		add(parseLine(line));
		
		return pairs;
	}
	
	#if !macro
	public static function ofFile(str:String, obj:Dynamic):Void
	{
		var isInst = Type.getClass(obj) != null;
		
		var rtti = Reflect.field(isInst ? Type.getClass(obj) : obj, "__rtti");
		if (rtti == null)
			throw "@:rtti metadata required";
		
		var xml = Xml.parse(rtti).firstElement();
		
		var pairs = parse(str);
		for (key in pairs.keys())
		{
			//resolve type from rtti
			var e = xml.elementsNamed(key).next();
			var type = e.firstChild().get("path");
			var param = null;
			if (type == "Array") param = e.firstChild().firstChild().get("path");
			
			//convert string to real type
			var value:Dynamic = pairs.get(key);
			switch (type)
			{
				case "Int":   value = Std.parseInt(value);
				case "Float": value = Std.parseFloat(value);
				case "Bool":  value = value == "true";
				case "Array": value = value.split(",");
					switch (param)
					{
						case "Int":   for (i in 0...value.length) value[i] = Std.parseInt(value[i]);
						case "Float": for (i in 0...value.length) value[i] = Std.parseFloat(value[i]);
						case "Bool" : for (i in 0...value.length) value[i] = value[i] == "true";
						case _:
					}
				case _:
			}
			
			Reflect.setField(obj, key, value);
		}
	}
	#end
	
	static function parseLine(str:String):{key:String, val:String}
	{
		if (!~/\S/.match(str)) return null;
		
		var i = 0;
		var k = str.length;
		
		while (i < k)
		{
			var c = str.charAt(i);
			if (c == " " || c == "\t")
				i++;
			else
				break;
		}
		
		var c = str.charAt(i);
		if (c == "#") return null;
		if (c == "!") return null;
		
		var key = "";
		while (i < k)
		{
			var c = str.charAt(i++);
			if (c == " " || c == "\t" || c == ":" || c == "=") break;
			key += c;
		}
		
		while (i < k)
		{
			var c = str.charAt(i);
			if (c == " " || c == "\t")
				i++;
			else
				break;
		}
		
		var val = "";
		while (i < k)
		{
			var c = str.charAt(i++);
			val += c;
		}
		
		if (val == "") val = key;
		
		if (val == key && val == "") return null;
		
		return {key: key, val: val};
	}
}