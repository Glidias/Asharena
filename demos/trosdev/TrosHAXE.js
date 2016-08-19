(function (console, $hx_exports, $global) { "use strict";
$hx_exports.troshx = $hx_exports.troshx || {};
$hx_exports.troshx.util = $hx_exports.troshx.util || {};
;$hx_exports.troshx.tros = $hx_exports.troshx.tros || {};
$hx_exports.troshx.tros.ai = $hx_exports.troshx.tros.ai || {};
$hx_exports.tjson = $hx_exports.tjson || {};
$hx_exports.dat = $hx_exports.dat || {};
$hx_exports.dat.gui = $hx_exports.dat.gui || {};
var $hxClasses = {},$estr = function() { return js_Boot.__string_rec(this,''); };
function $extend(from, fields) {
	function Inherit() {} Inherit.prototype = from; var proto = new Inherit();
	for (var name in fields) proto[name] = fields[name];
	if( fields.toString !== Object.prototype.toString ) proto.toString = fields.toString;
	return proto;
}
var EReg = function(r,opt) {
	opt = opt.split("u").join("");
	this.r = new RegExp(r,opt);
};
$hxClasses["EReg"] = EReg;
EReg.__name__ = ["EReg"];
EReg.prototype = {
	r: null
	,match: function(s) {
		if(this.r.global) this.r.lastIndex = 0;
		this.r.m = this.r.exec(s);
		this.r.s = s;
		return this.r.m != null;
	}
	,matched: function(n) {
		if(this.r.m != null && n >= 0 && n < this.r.m.length) return this.r.m[n]; else throw new js__$Boot_HaxeError("EReg::matched");
	}
	,replace: function(s,by) {
		return s.replace(this.r,by);
	}
	,__class__: EReg
};
var HxOverrides = function() { };
$hxClasses["HxOverrides"] = HxOverrides;
HxOverrides.__name__ = ["HxOverrides"];
HxOverrides.cca = function(s,index) {
	var x = s.charCodeAt(index);
	if(x != x) return undefined;
	return x;
};
HxOverrides.substr = function(s,pos,len) {
	if(pos != null && pos != 0 && len != null && len < 0) return "";
	if(len == null) len = s.length;
	if(pos < 0) {
		pos = s.length + pos;
		if(pos < 0) pos = 0;
	} else if(len < 0) len = s.length + len - pos;
	return s.substr(pos,len);
};
HxOverrides.indexOf = function(a,obj,i) {
	var len = a.length;
	if(i < 0) {
		i += len;
		if(i < 0) i = 0;
	}
	while(i < len) {
		if(a[i] === obj) return i;
		i++;
	}
	return -1;
};
HxOverrides.remove = function(a,obj) {
	var i = HxOverrides.indexOf(a,obj,0);
	if(i == -1) return false;
	a.splice(i,1);
	return true;
};
HxOverrides.iter = function(a) {
	return { cur : 0, arr : a, hasNext : function() {
		return this.cur < this.arr.length;
	}, next : function() {
		return this.arr[this.cur++];
	}};
};
var List = function() {
	this.length = 0;
};
$hxClasses["List"] = List;
List.__name__ = ["List"];
List.prototype = {
	h: null
	,q: null
	,length: null
	,add: function(item) {
		var x = [item];
		if(this.h == null) this.h = x; else this.q[1] = x;
		this.q = x;
		this.length++;
	}
	,last: function() {
		if(this.q == null) return null; else return this.q[0];
	}
	,remove: function(v) {
		var prev = null;
		var l = this.h;
		while(l != null) {
			if(l[0] == v) {
				if(prev == null) this.h = l[1]; else prev[1] = l[1];
				if(this.q == l) this.q = prev;
				this.length--;
				return true;
			}
			prev = l;
			l = l[1];
		}
		return false;
	}
	,iterator: function() {
		return new _$List_ListIterator(this.h);
	}
	,join: function(sep) {
		var s = new StringBuf();
		var first = true;
		var l = this.h;
		while(l != null) {
			if(first) first = false; else if(sep == null) s.b += "null"; else s.b += "" + sep;
			s.add(l[0]);
			l = l[1];
		}
		return s.b;
	}
	,map: function(f) {
		var b = new List();
		var l = this.h;
		while(l != null) {
			var v = l[0];
			l = l[1];
			b.add(f(v));
		}
		return b;
	}
	,__class__: List
};
var _$List_ListIterator = function(head) {
	this.head = head;
	this.val = null;
};
$hxClasses["_List.ListIterator"] = _$List_ListIterator;
_$List_ListIterator.__name__ = ["_List","ListIterator"];
_$List_ListIterator.prototype = {
	head: null
	,val: null
	,hasNext: function() {
		return this.head != null;
	}
	,next: function() {
		this.val = this.head[0];
		this.head = this.head[1];
		return this.val;
	}
	,__class__: _$List_ListIterator
};
var Main = function() { };
$hxClasses["Main"] = Main;
Main.__name__ = ["Main"];
Main.main = function() {
};
Math.__name__ = ["Math"];
var Reflect = function() { };
$hxClasses["Reflect"] = Reflect;
Reflect.__name__ = ["Reflect"];
Reflect.field = function(o,field) {
	try {
		return o[field];
	} catch( e ) {
		if (e instanceof js__$Boot_HaxeError) e = e.val;
		return null;
	}
};
Reflect.setField = function(o,field,value) {
	o[field] = value;
};
Reflect.getProperty = function(o,field) {
	var tmp;
	if(o == null) return null; else if(o.__properties__ && (tmp = o.__properties__["get_" + field])) return o[tmp](); else return o[field];
};
Reflect.setProperty = function(o,field,value) {
	var tmp;
	if(o.__properties__ && (tmp = o.__properties__["set_" + field])) o[tmp](value); else o[field] = value;
};
Reflect.fields = function(o) {
	var a = [];
	if(o != null) {
		var hasOwnProperty = Object.prototype.hasOwnProperty;
		for( var f in o ) {
		if(f != "__id__" && f != "hx__closures__" && hasOwnProperty.call(o,f)) a.push(f);
		}
	}
	return a;
};
Reflect.isObject = function(v) {
	if(v == null) return false;
	var t = typeof(v);
	return t == "string" || t == "object" && v.__enum__ == null || t == "function" && (v.__name__ || v.__ename__) != null;
};
Reflect.deleteField = function(o,field) {
	if(!Object.prototype.hasOwnProperty.call(o,field)) return false;
	delete(o[field]);
	return true;
};
var Std = function() { };
$hxClasses["Std"] = Std;
Std.__name__ = ["Std"];
Std.string = function(s) {
	return js_Boot.__string_rec(s,"");
};
Std["int"] = function(x) {
	return x | 0;
};
Std.parseInt = function(x) {
	var v = parseInt(x,10);
	if(v == 0 && (HxOverrides.cca(x,1) == 120 || HxOverrides.cca(x,1) == 88)) v = parseInt(x);
	if(isNaN(v)) return null;
	return v;
};
var StringBuf = function() {
	this.b = "";
};
$hxClasses["StringBuf"] = StringBuf;
StringBuf.__name__ = ["StringBuf"];
StringBuf.prototype = {
	b: null
	,add: function(x) {
		this.b += Std.string(x);
	}
	,addSub: function(s,pos,len) {
		if(len == null) this.b += HxOverrides.substr(s,pos,null); else this.b += HxOverrides.substr(s,pos,len);
	}
	,__class__: StringBuf
};
var StringTools = function() { };
$hxClasses["StringTools"] = StringTools;
StringTools.__name__ = ["StringTools"];
StringTools.htmlEscape = function(s,quotes) {
	s = s.split("&").join("&amp;").split("<").join("&lt;").split(">").join("&gt;");
	if(quotes) return s.split("\"").join("&quot;").split("'").join("&#039;"); else return s;
};
StringTools.startsWith = function(s,start) {
	return s.length >= start.length && HxOverrides.substr(s,0,start.length) == start;
};
StringTools.isSpace = function(s,pos) {
	var c = HxOverrides.cca(s,pos);
	return c > 8 && c < 14 || c == 32;
};
StringTools.ltrim = function(s) {
	var l = s.length;
	var r = 0;
	while(r < l && StringTools.isSpace(s,r)) r++;
	if(r > 0) return HxOverrides.substr(s,r,l - r); else return s;
};
StringTools.rtrim = function(s) {
	var l = s.length;
	var r = 0;
	while(r < l && StringTools.isSpace(s,l - r - 1)) r++;
	if(r > 0) return HxOverrides.substr(s,0,l - r); else return s;
};
StringTools.trim = function(s) {
	return StringTools.ltrim(StringTools.rtrim(s));
};
StringTools.replace = function(s,sub,by) {
	return s.split(sub).join(by);
};
StringTools.fastCodeAt = function(s,index) {
	return s.charCodeAt(index);
};
var ValueType = { __ename__ : true, __constructs__ : ["TNull","TInt","TFloat","TBool","TObject","TFunction","TClass","TEnum","TUnknown"] };
ValueType.TNull = ["TNull",0];
ValueType.TNull.toString = $estr;
ValueType.TNull.__enum__ = ValueType;
ValueType.TInt = ["TInt",1];
ValueType.TInt.toString = $estr;
ValueType.TInt.__enum__ = ValueType;
ValueType.TFloat = ["TFloat",2];
ValueType.TFloat.toString = $estr;
ValueType.TFloat.__enum__ = ValueType;
ValueType.TBool = ["TBool",3];
ValueType.TBool.toString = $estr;
ValueType.TBool.__enum__ = ValueType;
ValueType.TObject = ["TObject",4];
ValueType.TObject.toString = $estr;
ValueType.TObject.__enum__ = ValueType;
ValueType.TFunction = ["TFunction",5];
ValueType.TFunction.toString = $estr;
ValueType.TFunction.__enum__ = ValueType;
ValueType.TClass = function(c) { var $x = ["TClass",6,c]; $x.__enum__ = ValueType; $x.toString = $estr; return $x; };
ValueType.TEnum = function(e) { var $x = ["TEnum",7,e]; $x.__enum__ = ValueType; $x.toString = $estr; return $x; };
ValueType.TUnknown = ["TUnknown",8];
ValueType.TUnknown.toString = $estr;
ValueType.TUnknown.__enum__ = ValueType;
var Type = function() { };
$hxClasses["Type"] = Type;
Type.__name__ = ["Type"];
Type.getClass = function(o) {
	if(o == null) return null; else return js_Boot.getClass(o);
};
Type.getClassName = function(c) {
	var a = c.__name__;
	if(a == null) return null;
	return a.join(".");
};
Type.resolveClass = function(name) {
	var cl = $hxClasses[name];
	if(cl == null || !cl.__name__) return null;
	return cl;
};
Type.createInstance = function(cl,args) {
	var _g = args.length;
	switch(_g) {
	case 0:
		return new cl();
	case 1:
		return new cl(args[0]);
	case 2:
		return new cl(args[0],args[1]);
	case 3:
		return new cl(args[0],args[1],args[2]);
	case 4:
		return new cl(args[0],args[1],args[2],args[3]);
	case 5:
		return new cl(args[0],args[1],args[2],args[3],args[4]);
	case 6:
		return new cl(args[0],args[1],args[2],args[3],args[4],args[5]);
	case 7:
		return new cl(args[0],args[1],args[2],args[3],args[4],args[5],args[6]);
	case 8:
		return new cl(args[0],args[1],args[2],args[3],args[4],args[5],args[6],args[7]);
	default:
		throw new js__$Boot_HaxeError("Too many arguments");
	}
	return null;
};
Type.createEmptyInstance = function(cl) {
	function empty() {}; empty.prototype = cl.prototype;
	return new empty();
};
Type.getInstanceFields = function(c) {
	var a = [];
	for(var i in c.prototype) a.push(i);
	HxOverrides.remove(a,"__class__");
	HxOverrides.remove(a,"__properties__");
	return a;
};
Type["typeof"] = function(v) {
	var _g = typeof(v);
	switch(_g) {
	case "boolean":
		return ValueType.TBool;
	case "string":
		return ValueType.TClass(String);
	case "number":
		if(Math.ceil(v) == v % 2147483648.0) return ValueType.TInt;
		return ValueType.TFloat;
	case "object":
		if(v == null) return ValueType.TNull;
		var e = v.__enum__;
		if(e != null) return ValueType.TEnum(e);
		var c = js_Boot.getClass(v);
		if(c != null) return ValueType.TClass(c);
		return ValueType.TObject;
	case "function":
		if(v.__name__ || v.__ename__) return ValueType.TObject;
		return ValueType.TFunction;
	case "undefined":
		return ValueType.TNull;
	default:
		return ValueType.TUnknown;
	}
};
var Xml = function(nodeType) {
	this.nodeType = nodeType;
	this.children = [];
	this.attributeMap = new haxe_ds_StringMap();
};
$hxClasses["Xml"] = Xml;
Xml.__name__ = ["Xml"];
Xml.parse = function(str) {
	return haxe_xml_Parser.parse(str);
};
Xml.createElement = function(name) {
	var xml = new Xml(Xml.Element);
	if(xml.nodeType != Xml.Element) throw new js__$Boot_HaxeError("Bad node type, expected Element but found " + xml.nodeType);
	xml.nodeName = name;
	return xml;
};
Xml.createPCData = function(data) {
	var xml = new Xml(Xml.PCData);
	if(xml.nodeType == Xml.Document || xml.nodeType == Xml.Element) throw new js__$Boot_HaxeError("Bad node type, unexpected " + xml.nodeType);
	xml.nodeValue = data;
	return xml;
};
Xml.createCData = function(data) {
	var xml = new Xml(Xml.CData);
	if(xml.nodeType == Xml.Document || xml.nodeType == Xml.Element) throw new js__$Boot_HaxeError("Bad node type, unexpected " + xml.nodeType);
	xml.nodeValue = data;
	return xml;
};
Xml.createComment = function(data) {
	var xml = new Xml(Xml.Comment);
	if(xml.nodeType == Xml.Document || xml.nodeType == Xml.Element) throw new js__$Boot_HaxeError("Bad node type, unexpected " + xml.nodeType);
	xml.nodeValue = data;
	return xml;
};
Xml.createDocType = function(data) {
	var xml = new Xml(Xml.DocType);
	if(xml.nodeType == Xml.Document || xml.nodeType == Xml.Element) throw new js__$Boot_HaxeError("Bad node type, unexpected " + xml.nodeType);
	xml.nodeValue = data;
	return xml;
};
Xml.createProcessingInstruction = function(data) {
	var xml = new Xml(Xml.ProcessingInstruction);
	if(xml.nodeType == Xml.Document || xml.nodeType == Xml.Element) throw new js__$Boot_HaxeError("Bad node type, unexpected " + xml.nodeType);
	xml.nodeValue = data;
	return xml;
};
Xml.createDocument = function() {
	return new Xml(Xml.Document);
};
Xml.prototype = {
	nodeType: null
	,nodeName: null
	,nodeValue: null
	,parent: null
	,children: null
	,attributeMap: null
	,get_nodeName: function() {
		if(this.nodeType != Xml.Element) throw new js__$Boot_HaxeError("Bad node type, expected Element but found " + this.nodeType);
		return this.nodeName;
	}
	,get: function(att) {
		if(this.nodeType != Xml.Element) throw new js__$Boot_HaxeError("Bad node type, expected Element but found " + this.nodeType);
		return this.attributeMap.get(att);
	}
	,set: function(att,value) {
		if(this.nodeType != Xml.Element) throw new js__$Boot_HaxeError("Bad node type, expected Element but found " + this.nodeType);
		this.attributeMap.set(att,value);
	}
	,exists: function(att) {
		if(this.nodeType != Xml.Element) throw new js__$Boot_HaxeError("Bad node type, expected Element but found " + this.nodeType);
		return this.attributeMap.exists(att);
	}
	,attributes: function() {
		if(this.nodeType != Xml.Element) throw new js__$Boot_HaxeError("Bad node type, expected Element but found " + this.nodeType);
		return this.attributeMap.keys();
	}
	,iterator: function() {
		if(this.nodeType != Xml.Document && this.nodeType != Xml.Element) throw new js__$Boot_HaxeError("Bad node type, expected Element or Document but found " + this.nodeType);
		return HxOverrides.iter(this.children);
	}
	,elements: function() {
		if(this.nodeType != Xml.Document && this.nodeType != Xml.Element) throw new js__$Boot_HaxeError("Bad node type, expected Element or Document but found " + this.nodeType);
		var ret;
		var _g = [];
		var _g1 = 0;
		var _g2 = this.children;
		while(_g1 < _g2.length) {
			var child = _g2[_g1];
			++_g1;
			if(child.nodeType == Xml.Element) _g.push(child);
		}
		ret = _g;
		return HxOverrides.iter(ret);
	}
	,elementsNamed: function(name) {
		if(this.nodeType != Xml.Document && this.nodeType != Xml.Element) throw new js__$Boot_HaxeError("Bad node type, expected Element or Document but found " + this.nodeType);
		var ret;
		var _g = [];
		var _g1 = 0;
		var _g2 = this.children;
		while(_g1 < _g2.length) {
			var child = _g2[_g1];
			++_g1;
			if(child.nodeType == Xml.Element && (function($this) {
				var $r;
				if(child.nodeType != Xml.Element) throw new js__$Boot_HaxeError("Bad node type, expected Element but found " + child.nodeType);
				$r = child.nodeName;
				return $r;
			}(this)) == name) _g.push(child);
		}
		ret = _g;
		return HxOverrides.iter(ret);
	}
	,firstElement: function() {
		if(this.nodeType != Xml.Document && this.nodeType != Xml.Element) throw new js__$Boot_HaxeError("Bad node type, expected Element or Document but found " + this.nodeType);
		var _g = 0;
		var _g1 = this.children;
		while(_g < _g1.length) {
			var child = _g1[_g];
			++_g;
			if(child.nodeType == Xml.Element) return child;
		}
		return null;
	}
	,addChild: function(x) {
		if(this.nodeType != Xml.Document && this.nodeType != Xml.Element) throw new js__$Boot_HaxeError("Bad node type, expected Element or Document but found " + this.nodeType);
		if(x.parent != null) x.parent.removeChild(x);
		this.children.push(x);
		x.parent = this;
	}
	,removeChild: function(x) {
		if(this.nodeType != Xml.Document && this.nodeType != Xml.Element) throw new js__$Boot_HaxeError("Bad node type, expected Element or Document but found " + this.nodeType);
		if(HxOverrides.remove(this.children,x)) {
			x.parent = null;
			return true;
		}
		return false;
	}
	,__class__: Xml
	,__properties__: {get_nodeName:"get_nodeName"}
};
var dat_gui_DatUtil = $hx_exports.dat.gui.DatUtil = function() { };
$hxClasses["dat.gui.DatUtil"] = dat_gui_DatUtil;
dat_gui_DatUtil.__name__ = ["dat","gui","DatUtil"];
dat_gui_DatUtil._concatDyn = function(a1,a2) {
	return a1.concat(a2);
};
dat_gui_DatUtil.setup = function(instance,classe,options,dotPath,funcToInspect) {
	if(dotPath == null) dotPath = "";
	var typeStr;
	if(classe == null) classe = Type.getClass(instance);
	if(options == null) options = { };
	var ignoreInspectMeta = Reflect.field(options,"ignoreInspectMeta");
	var useStatic = Reflect.field(options,"isStatic");
	var rtti = haxe_rtti_Rtti.getRtti(classe);
	var meta;
	if(funcToInspect != null) meta = funcToInspect.meta; else if(useStatic) meta = haxe_rtti_Meta.getStatics(classe); else meta = haxe_rtti_Meta.getFields(classe);
	if(funcToInspect != null) instance = funcToInspect.instance;
	var fieldHash = { };
	var fields;
	if(funcToInspect != null) fields = funcToInspect.fields; else if(useStatic) fields = rtti.statics; else fields = rtti.fields;
	var funcFolder = null;
	var cur;
	var curVal;
	var frStatics;
	var frParams;
	var frValue;
	var frPrefix = null;
	var frI;
	var _g_head = fields.h;
	var _g_val = null;
	while(_g_head != null) {
		var f;
		f = (function($this) {
			var $r;
			_g_val = _g_head[0];
			_g_head = _g_head[1];
			$r = _g_val;
			return $r;
		}(this));
		var fieldMeta = Reflect.field(meta,f.name);
		var isVar = haxe_rtti_TypeApi.isVar(f.type);
		if(isVar && (!ignoreInspectMeta?fieldMeta != null && Object.prototype.hasOwnProperty.call(fieldMeta,"inspect"):true)) {
			cur = Reflect.field(fieldMeta,"inspect");
			if(cur == null) cur = { }; else cur = cur[0];
			if(cur == null) cur = { };
			if(Object.prototype.hasOwnProperty.call(cur,"value")) curVal = Reflect.field(cur,"value"); else curVal = Reflect.getProperty(instance,f.name);
			typeStr = haxe_rtti_CTypeTools.toString(f.type);
			if(typeStr == "Int" || typeStr == "UInt" || typeStr == "Float") {
				if(curVal == null) curVal = 0;
				cur.value = curVal;
				if(typeStr == "Int" || typeStr == "UInt") {
					if(Object.prototype.hasOwnProperty.call(fieldMeta,"bitmask")) {
						var bitMaskFolder = { _classes : Object.prototype.hasOwnProperty.call(cur,"_classes")?dat_gui_DatUtil._concatDyn(["bitmask"],Reflect.field(cur,"_classes")):["bitmask"]};
						var gotBits = false;
						var bitFieldMeta = Reflect.field(fieldMeta,"bitmask")[0];
						if(typeof(bitFieldMeta) == "string") {
							frValue = bitFieldMeta;
							frStatics = new _$List_ListIterator(rtti.statics.h);
							var _g = frStatics;
							while(_g.head != null) {
								var f1;
								f1 = (function($this) {
									var $r;
									_g.val = _g.head[0];
									_g.head = _g.head[1];
									$r = _g.val;
									return $r;
								}(this));
								frI = f1.name.indexOf("_");
								if(frI >= 0) {
									gotBits = true;
									frPrefix = f1.name.substring(0,frI);
									if(frPrefix == frValue) Reflect.setField(bitMaskFolder,f1.name.substring(frI + 1),{ _bit : Reflect.field(classe,f1.name), value : (curVal & Reflect.field(classe,f1.name)) != 0});
								}
							}
						} else {
							var _g1 = 0;
							while(_g1 < 32) {
								var i = _g1++;
								bitMaskFolder["b" + (i == null?"null":"" + i)] = { _bit : 1 << i, value : (curVal & 1 << i) != 0};
							}
							gotBits = true;
						}
						if(gotBits) {
							fieldHash[f.name] = bitMaskFolder;
							var _g2 = 0;
							var _g11 = Reflect.fields(cur);
							while(_g2 < _g11.length) {
								var p = _g11[_g2];
								++_g2;
								if(p.charAt(0) != "_") continue;
								Reflect.setField(bitMaskFolder,p,Reflect.field(cur,p));
							}
							bitMaskFolder._subProxy = "bitmask";
							bitMaskFolder._value = curVal;
						}
					} else {
						if(!Object.prototype.hasOwnProperty.call(cur,"step")) cur.step = 1;
						if(typeStr == "UInt" && !Object.prototype.hasOwnProperty.call(cur,"min")) cur.min = 0;
						fieldHash[f.name] = cur;
						cur._isLeaf = true;
					}
				} else {
					if(dat_gui_DatUtil.DEFAULT_FLOAT_STEP > 0 && !Object.prototype.hasOwnProperty.call(cur,"step")) cur.step = dat_gui_DatUtil.DEFAULT_FLOAT_STEP;
					fieldHash[f.name] = cur;
					cur._isLeaf = true;
				}
			} else if(typeStr == "String") {
				if(curVal == null) curVal = "";
				cur.value = curVal;
				fieldHash[f.name] = cur;
				cur._isLeaf = true;
			} else if(typeStr == "Bool") {
				if(curVal == null) curVal = false;
				cur.value = curVal;
				fieldHash[f.name] = cur;
				cur._isLeaf = true;
			} else {
				var tryInstance = Reflect.getProperty(instance,f.name);
				var instanceAvailable = true;
				if(tryInstance == null) {
					instanceAvailable = false;
					tryInstance = Type.createInstance(Type.resolveClass(typeStr),[]);
				}
				var nested;
				Reflect.setField(fieldHash,f.name,nested = dat_gui_DatUtil.setup(tryInstance,Type.resolveClass(typeStr),f.type,(dotPath != ""?dotPath + ".":"") + f.name));
				var _g3 = 0;
				var _g12 = Reflect.fields(cur);
				while(_g3 < _g12.length) {
					var p1 = _g12[_g3];
					++_g3;
					if(p1.charAt(0) != "_") continue;
					Reflect.setField(nested,p1,Reflect.field(cur,p1));
				}
				if(instanceAvailable) nested._folded = false; else nested._folded = true;
				Reflect.setField(nested,"_classes",Object.prototype.hasOwnProperty.call(cur,"_classes")?dat_gui_DatUtil._concatDyn(["instance"],Reflect.field(cur,"_classes")):["instance"]);
			}
			if(Object.prototype.hasOwnProperty.call(fieldMeta,"range")) {
				frParams = Reflect.field(fieldMeta,"range");
				if(frParams != null && frParams.length > 0) {
					frValue = frParams[0];
					if(typeof(frValue) == "string") {
						var frEnum = { };
						var min = 1e20;
						var max = -1e20;
						frStatics = new _$List_ListIterator(rtti.statics.h);
						var _g4 = frStatics;
						while(_g4.head != null) {
							var f2;
							f2 = (function($this) {
								var $r;
								_g4.val = _g4.head[0];
								_g4.head = _g4.head[1];
								$r = _g4.val;
								return $r;
							}(this));
							frI = f2.name.indexOf("_");
							if(frI >= 0) {
								frPrefix = f2.name.substring(0,frI);
								if(frPrefix == frValue) {
									var v;
									v = Reflect.field(classe,f2.name);
									if(v > max) max = v;
									if(v < min) min = v;
									Reflect.setField(frEnum,f2.name.substring(frI + 1),v);
								}
							}
						}
						cur.enumeration = frEnum;
						cur.min = min;
						cur.max = max;
					} else {
						Reflect.setField(cur,"min",Object.prototype.hasOwnProperty.call(frValue,"min")?Reflect.field(frValue,"min"):0);
						Reflect.setField(cur,"max",Object.prototype.hasOwnProperty.call(frValue,"max")?Reflect.field(frValue,"max"):Reflect.field(frValue,"min") + 1);
					}
				}
			}
			if(Object.prototype.hasOwnProperty.call(fieldMeta,"choices")) {
				frParams = Reflect.field(fieldMeta,"choices");
				if(frParams != null && frParams.length > 0) {
					frValue = frParams[0];
					if(typeof(frValue) == "string") {
						var frChoices = { };
						frStatics = new _$List_ListIterator(rtti.statics.h);
						var _g5 = frStatics;
						while(_g5.head != null) {
							var f3;
							f3 = (function($this) {
								var $r;
								_g5.val = _g5.head[0];
								_g5.head = _g5.head[1];
								$r = _g5.val;
								return $r;
							}(this));
							frI = f3.name.indexOf("_");
							if(frI >= 0) {
								frPrefix = f3.name.substring(0,frI);
								if(frPrefix == frValue) Reflect.setField(frChoices,f3.name.substring(frI + 1),Reflect.field(classe,f3.name));
							}
						}
						cur.choices = frChoices;
					} else cur.choices = frValue;
				}
			}
		} else if(!isVar && fieldMeta != null && Object.prototype.hasOwnProperty.call(fieldMeta,"inspect")) {
			cur = Reflect.field(fieldMeta,"inspect");
			if(cur == null) cur = []; else {
				cur = cur[0];
				if(!((cur instanceof Array) && cur.__enum__ == null)) cur = [cur];
			}
			{
				var _g6 = f.type;
				switch(_g6[1]) {
				case 4:
					var ret = _g6[3];
					var args = _g6[2];
					if(funcFolder == null) funcFolder = { };
					var funcDep = { meta : { }, instance : { }, fields : new List()};
					var count = 0;
					var _g1_head = args.h;
					var _g1_val = null;
					while(_g1_head != null) {
						var funcArg;
						funcArg = (function($this) {
							var $r;
							_g1_val = _g1_head[0];
							_g1_head = _g1_head[1];
							$r = _g1_val;
							return $r;
						}(this));
						funcDep.fields.add({ name : funcArg.name, type : funcArg.t, isPublic : true, isOverride : false, doc : null, get : null, set : null, params : null, platforms : null, meta : null, line : null, overloads : null, expr : null});
						var paramsObj;
						if(count < cur.length) paramsObj = cur[count]; else paramsObj = { };
						var newObj = { inspect : null};
						var _g13 = 0;
						var _g21 = Reflect.fields(paramsObj);
						while(_g13 < _g21.length) {
							var r = _g21[_g13];
							++_g13;
							Reflect.setField(newObj,r,[Reflect.field(paramsObj,r)]);
						}
						funcDep.meta[funcArg.name] = newObj;
						Reflect.setField(funcDep.instance,funcArg.name,funcArg.opt?dat_gui_DatUtil.parseOptStringParam(funcArg.value,haxe_rtti_CTypeTools.toString(funcArg.t),classe):dat_gui_DatUtil.parseDefaultTypeParamValue(haxe_rtti_CTypeTools.toString(funcArg.t),classe));
						count++;
					}
					funcFolder[f.name] = funcDep;
					break;
				default:
				}
			}
		}
	}
	if(funcFolder != null) fieldHash._functions = funcFolder;
	fieldHash._dotPath = dotPath;
	Reflect.setField(fieldHash,"_hxclass",Type.getClassName(classe));
	return fieldHash;
};
dat_gui_DatUtil.parseOptStringParam = function(str,type,classe) {
	switch(type) {
	case "Int":
		if(!(function($this) {
			var $r;
			var f = parseFloat(str);
			$r = isNaN(f);
			return $r;
		}(this))) return Std["int"](parseFloat(str)); else return Reflect.field(classe,str);
		break;
	case "UInt":
		if(!(function($this) {
			var $r;
			var f1 = Std.parseInt(str);
			$r = isNaN(f1);
			return $r;
		}(this))) return Std.parseInt(str); else return Reflect.field(classe,str);
		break;
	case "Float":
		if(!(function($this) {
			var $r;
			var f2 = parseFloat(str);
			$r = isNaN(f2);
			return $r;
		}(this))) return parseFloat(str); else return Reflect.field(classe,str);
		break;
	case "String":
		if(str.charAt(0) == "\"" || str.charAt(0) == "'") return str.substring(1,str.length - 1); else return Reflect.field(classe,str);
		break;
	case "Bool":
		if(str == "true") return true; else if(str == "false") return false; else return Reflect.field(classe,str);
		break;
	default:
		return null;
	}
};
dat_gui_DatUtil.parseDefaultTypeParamValue = function(type,classe) {
	switch(type) {
	case "Int":
		return 0;
	case "UInt":
		return 0;
	case "Float":
		return 0;
	case "String":
		return "";
	case "Bool":
		return false;
	default:
		return Type.createEmptyInstance(classe);
	}
};
dat_gui_DatUtil.getDummyClassFieldForFuncParam = function(name,type) {
	return { name : name, type : type, isPublic : true, isOverride : false, doc : null, get : null, set : null, params : null, platforms : null, meta : null, line : null, overloads : null, expr : null};
};
dat_gui_DatUtil.callMethod = function(scope,func,params,funcDep) {
	var arr = [];
	var _g_head = funcDep.fields.h;
	var _g_val = null;
	while(_g_head != null) {
		var f;
		f = (function($this) {
			var $r;
			_g_val = _g_head[0];
			_g_head = _g_head[1];
			$r = _g_val;
			return $r;
		}(this));
		arr.push(Reflect.field(params,f.name));
	}
	return func.apply(scope,arr);
};
dat_gui_DatUtil.callInstanceMethodWithPacket = function(instance,funcCallPacket) {
	return dat_gui_DatUtil.callMethod(instance,Reflect.field(instance,funcCallPacket.name),funcCallPacket.params,funcCallPacket.func);
};
dat_gui_DatUtil.setupGUIForFunctionCall = function(folder,p,handler,func,instance,classe,options,guiOptions) {
	var guiGlueMethod = window.guiGlueRender;
	var guiSetup = dat_gui_DatUtil.setup(instance,classe,options,"",func);
	var untypedGUI = guiGlueMethod(guiSetup,null,null,folder);
	var str = "";
	var i = func.fields.length;
	while(--i > -1) str += ".";
	var packet = { handler : handler, params : untypedGUI._guiGlueParams, func : func, guiGlue : untypedGUI._guiGlue, name : p};
	folder.add(packet,"handler").name("Execute(" + str + ")");
	return null;
};
dat_gui_DatUtil.createFunctionLibraryForGUI = function(gui,funcGuiMap,instance,classe,options,guiOptions) {
	var funcMap = { };
	var handler;
	if(options != null && Object.prototype.hasOwnProperty.call(options,"handler")) handler = Reflect.field(options,"handler"); else handler = dat_gui_DatUtil.emptyFunction;
	var _g = 0;
	var _g1 = Reflect.fields(funcGuiMap);
	while(_g < _g1.length) {
		var p = _g1[_g];
		++_g;
		var func = Reflect.field(funcGuiMap,p);
		var folder = gui.addFolder(p);
		folder.close();
		var packet = dat_gui_DatUtil.setupGUIForFunctionCall(folder,p,handler,func,instance,classe,options,guiOptions);
		funcMap[p] = packet;
	}
	return funcMap;
};
dat_gui_DatUtil.createFunctionButtonsForGUI = function(gui,funcGuiMap,instance,classe,options,guiOptions) {
	var guiGlueMethod = window.guiGlueRender;
	var funcMap = { };
	var handler;
	if(options != null && Object.prototype.hasOwnProperty.call(options,"handler")) handler = Reflect.field(options,"handler"); else handler = dat_gui_DatUtil.emptyFunction;
	var _g = 0;
	var _g1 = Reflect.fields(funcGuiMap);
	while(_g < _g1.length) {
		var p = _g1[_g];
		++_g;
		var func = Reflect.field(funcGuiMap,p);
		var trigger = { handler : handler, func : func, name : p};
		funcMap[p] = trigger;
		gui.add(trigger,"handler").name(p + "(" + (func.fields.length > 0?"...":"") + ")");
	}
	return funcMap;
};
dat_gui_DatUtil.emptyFunction = function() {
};
var haxe_IMap = function() { };
$hxClasses["haxe.IMap"] = haxe_IMap;
haxe_IMap.__name__ = ["haxe","IMap"];
haxe_IMap.prototype = {
	get: null
	,keys: null
	,__class__: haxe_IMap
};
var haxe_Utf8 = function(size) {
	this.__b = "";
};
$hxClasses["haxe.Utf8"] = haxe_Utf8;
haxe_Utf8.__name__ = ["haxe","Utf8"];
haxe_Utf8.prototype = {
	__b: null
	,__class__: haxe_Utf8
};
var haxe_ds_IntMap = function() {
	this.h = { };
};
$hxClasses["haxe.ds.IntMap"] = haxe_ds_IntMap;
haxe_ds_IntMap.__name__ = ["haxe","ds","IntMap"];
haxe_ds_IntMap.__interfaces__ = [haxe_IMap];
haxe_ds_IntMap.prototype = {
	h: null
	,set: function(key,value) {
		this.h[key] = value;
	}
	,get: function(key) {
		return this.h[key];
	}
	,keys: function() {
		var a = [];
		for( var key in this.h ) {
		if(this.h.hasOwnProperty(key)) a.push(key | 0);
		}
		return HxOverrides.iter(a);
	}
	,__class__: haxe_ds_IntMap
};
var haxe_ds_StringMap = function() {
	this.h = { };
};
$hxClasses["haxe.ds.StringMap"] = haxe_ds_StringMap;
haxe_ds_StringMap.__name__ = ["haxe","ds","StringMap"];
haxe_ds_StringMap.__interfaces__ = [haxe_IMap];
haxe_ds_StringMap.prototype = {
	h: null
	,rh: null
	,set: function(key,value) {
		if(__map_reserved[key] != null) this.setReserved(key,value); else this.h[key] = value;
	}
	,get: function(key) {
		if(__map_reserved[key] != null) return this.getReserved(key);
		return this.h[key];
	}
	,exists: function(key) {
		if(__map_reserved[key] != null) return this.existsReserved(key);
		return this.h.hasOwnProperty(key);
	}
	,setReserved: function(key,value) {
		if(this.rh == null) this.rh = { };
		this.rh["$" + key] = value;
	}
	,getReserved: function(key) {
		if(this.rh == null) return null; else return this.rh["$" + key];
	}
	,existsReserved: function(key) {
		if(this.rh == null) return false;
		return this.rh.hasOwnProperty("$" + key);
	}
	,keys: function() {
		var _this = this.arrayKeys();
		return HxOverrides.iter(_this);
	}
	,arrayKeys: function() {
		var out = [];
		for( var key in this.h ) {
		if(this.h.hasOwnProperty(key)) out.push(key);
		}
		if(this.rh != null) {
			for( var key in this.rh ) {
			if(key.charCodeAt(0) == 36) out.push(key.substr(1));
			}
		}
		return out;
	}
	,__class__: haxe_ds_StringMap
};
var haxe_rtti_CType = { __ename__ : true, __constructs__ : ["CUnknown","CEnum","CClass","CTypedef","CFunction","CAnonymous","CDynamic","CAbstract"] };
haxe_rtti_CType.CUnknown = ["CUnknown",0];
haxe_rtti_CType.CUnknown.toString = $estr;
haxe_rtti_CType.CUnknown.__enum__ = haxe_rtti_CType;
haxe_rtti_CType.CEnum = function(name,params) { var $x = ["CEnum",1,name,params]; $x.__enum__ = haxe_rtti_CType; $x.toString = $estr; return $x; };
haxe_rtti_CType.CClass = function(name,params) { var $x = ["CClass",2,name,params]; $x.__enum__ = haxe_rtti_CType; $x.toString = $estr; return $x; };
haxe_rtti_CType.CTypedef = function(name,params) { var $x = ["CTypedef",3,name,params]; $x.__enum__ = haxe_rtti_CType; $x.toString = $estr; return $x; };
haxe_rtti_CType.CFunction = function(args,ret) { var $x = ["CFunction",4,args,ret]; $x.__enum__ = haxe_rtti_CType; $x.toString = $estr; return $x; };
haxe_rtti_CType.CAnonymous = function(fields) { var $x = ["CAnonymous",5,fields]; $x.__enum__ = haxe_rtti_CType; $x.toString = $estr; return $x; };
haxe_rtti_CType.CDynamic = function(t) { var $x = ["CDynamic",6,t]; $x.__enum__ = haxe_rtti_CType; $x.toString = $estr; return $x; };
haxe_rtti_CType.CAbstract = function(name,params) { var $x = ["CAbstract",7,name,params]; $x.__enum__ = haxe_rtti_CType; $x.toString = $estr; return $x; };
var haxe_rtti_Rights = { __ename__ : true, __constructs__ : ["RNormal","RNo","RCall","RMethod","RDynamic","RInline"] };
haxe_rtti_Rights.RNormal = ["RNormal",0];
haxe_rtti_Rights.RNormal.toString = $estr;
haxe_rtti_Rights.RNormal.__enum__ = haxe_rtti_Rights;
haxe_rtti_Rights.RNo = ["RNo",1];
haxe_rtti_Rights.RNo.toString = $estr;
haxe_rtti_Rights.RNo.__enum__ = haxe_rtti_Rights;
haxe_rtti_Rights.RCall = function(m) { var $x = ["RCall",2,m]; $x.__enum__ = haxe_rtti_Rights; $x.toString = $estr; return $x; };
haxe_rtti_Rights.RMethod = ["RMethod",3];
haxe_rtti_Rights.RMethod.toString = $estr;
haxe_rtti_Rights.RMethod.__enum__ = haxe_rtti_Rights;
haxe_rtti_Rights.RDynamic = ["RDynamic",4];
haxe_rtti_Rights.RDynamic.toString = $estr;
haxe_rtti_Rights.RDynamic.__enum__ = haxe_rtti_Rights;
haxe_rtti_Rights.RInline = ["RInline",5];
haxe_rtti_Rights.RInline.toString = $estr;
haxe_rtti_Rights.RInline.__enum__ = haxe_rtti_Rights;
var haxe_rtti_TypeTree = { __ename__ : true, __constructs__ : ["TPackage","TClassdecl","TEnumdecl","TTypedecl","TAbstractdecl"] };
haxe_rtti_TypeTree.TPackage = function(name,full,subs) { var $x = ["TPackage",0,name,full,subs]; $x.__enum__ = haxe_rtti_TypeTree; $x.toString = $estr; return $x; };
haxe_rtti_TypeTree.TClassdecl = function(c) { var $x = ["TClassdecl",1,c]; $x.__enum__ = haxe_rtti_TypeTree; $x.toString = $estr; return $x; };
haxe_rtti_TypeTree.TEnumdecl = function(e) { var $x = ["TEnumdecl",2,e]; $x.__enum__ = haxe_rtti_TypeTree; $x.toString = $estr; return $x; };
haxe_rtti_TypeTree.TTypedecl = function(t) { var $x = ["TTypedecl",3,t]; $x.__enum__ = haxe_rtti_TypeTree; $x.toString = $estr; return $x; };
haxe_rtti_TypeTree.TAbstractdecl = function(a) { var $x = ["TAbstractdecl",4,a]; $x.__enum__ = haxe_rtti_TypeTree; $x.toString = $estr; return $x; };
var haxe_rtti_TypeApi = function() { };
$hxClasses["haxe.rtti.TypeApi"] = haxe_rtti_TypeApi;
haxe_rtti_TypeApi.__name__ = ["haxe","rtti","TypeApi"];
haxe_rtti_TypeApi.isVar = function(t) {
	switch(t[1]) {
	case 4:
		return false;
	default:
		return true;
	}
};
var haxe_rtti_CTypeTools = function() { };
$hxClasses["haxe.rtti.CTypeTools"] = haxe_rtti_CTypeTools;
haxe_rtti_CTypeTools.__name__ = ["haxe","rtti","CTypeTools"];
haxe_rtti_CTypeTools.toString = function(t) {
	switch(t[1]) {
	case 0:
		return "unknown";
	case 2:
		var params = t[3];
		var name = t[2];
		return haxe_rtti_CTypeTools.nameWithParams(name,params);
	case 1:
		var params1 = t[3];
		var name1 = t[2];
		return haxe_rtti_CTypeTools.nameWithParams(name1,params1);
	case 3:
		var params2 = t[3];
		var name2 = t[2];
		return haxe_rtti_CTypeTools.nameWithParams(name2,params2);
	case 7:
		var params3 = t[3];
		var name3 = t[2];
		return haxe_rtti_CTypeTools.nameWithParams(name3,params3);
	case 4:
		var ret = t[3];
		var args = t[2];
		if(args.length == 0) return "Void -> " + haxe_rtti_CTypeTools.toString(ret); else return args.map(haxe_rtti_CTypeTools.functionArgumentName).join(" -> ");
		break;
	case 6:
		var d = t[2];
		if(d == null) return "Dynamic"; else return "Dynamic<" + haxe_rtti_CTypeTools.toString(d) + ">";
		break;
	case 5:
		var fields = t[2];
		return "{ " + fields.map(haxe_rtti_CTypeTools.classField).join(", ");
	}
};
haxe_rtti_CTypeTools.nameWithParams = function(name,params) {
	if(params.length == 0) return name;
	return name + "<" + params.map(haxe_rtti_CTypeTools.toString).join(", ") + ">";
};
haxe_rtti_CTypeTools.functionArgumentName = function(arg) {
	return (arg.opt?"?":"") + arg.name + ":" + haxe_rtti_CTypeTools.toString(arg.t) + (arg.value == null?"":" = " + arg.value);
};
haxe_rtti_CTypeTools.classField = function(cf) {
	return cf.name + ":" + haxe_rtti_CTypeTools.toString(cf.type);
};
var haxe_rtti_Meta = function() { };
$hxClasses["haxe.rtti.Meta"] = haxe_rtti_Meta;
haxe_rtti_Meta.__name__ = ["haxe","rtti","Meta"];
haxe_rtti_Meta.getMeta = function(t) {
	return t.__meta__;
};
haxe_rtti_Meta.getStatics = function(t) {
	var meta = haxe_rtti_Meta.getMeta(t);
	if(meta == null || meta.statics == null) return { }; else return meta.statics;
};
haxe_rtti_Meta.getFields = function(t) {
	var meta = haxe_rtti_Meta.getMeta(t);
	if(meta == null || meta.fields == null) return { }; else return meta.fields;
};
var haxe_rtti_Rtti = function() { };
$hxClasses["haxe.rtti.Rtti"] = haxe_rtti_Rtti;
haxe_rtti_Rtti.__name__ = ["haxe","rtti","Rtti"];
haxe_rtti_Rtti.getRtti = function(c) {
	var rtti = Reflect.field(c,"__rtti");
	if(rtti == null) throw new js__$Boot_HaxeError("Class " + Type.getClassName(c) + " has no RTTI information, consider adding @:rtti");
	var x = Xml.parse(rtti).firstElement();
	var infos = new haxe_rtti_XmlParser().processElement(x);
	{
		var t = infos;
		switch(infos[1]) {
		case 1:
			var c1 = infos[2];
			return c1;
		default:
			throw new js__$Boot_HaxeError("Enum mismatch: expected TClassDecl but found " + Std.string(t));
		}
	}
};
var haxe_rtti_XmlParser = function() {
	this.root = [];
};
$hxClasses["haxe.rtti.XmlParser"] = haxe_rtti_XmlParser;
haxe_rtti_XmlParser.__name__ = ["haxe","rtti","XmlParser"];
haxe_rtti_XmlParser.prototype = {
	root: null
	,curplatform: null
	,mkPath: function(p) {
		return p;
	}
	,mkTypeParams: function(p) {
		var pl = p.split(":");
		if(pl[0] == "") return [];
		return pl;
	}
	,mkRights: function(r) {
		switch(r) {
		case "null":
			return haxe_rtti_Rights.RNo;
		case "method":
			return haxe_rtti_Rights.RMethod;
		case "dynamic":
			return haxe_rtti_Rights.RDynamic;
		case "inline":
			return haxe_rtti_Rights.RInline;
		default:
			return haxe_rtti_Rights.RCall(r);
		}
	}
	,xerror: function(c) {
		throw new js__$Boot_HaxeError("Invalid " + c.get_name());
	}
	,processElement: function(x) {
		var c = new haxe_xml_Fast(x);
		var _g = c.get_name();
		switch(_g) {
		case "class":
			return haxe_rtti_TypeTree.TClassdecl(this.xclass(c));
		case "enum":
			return haxe_rtti_TypeTree.TEnumdecl(this.xenum(c));
		case "typedef":
			return haxe_rtti_TypeTree.TTypedecl(this.xtypedef(c));
		case "abstract":
			return haxe_rtti_TypeTree.TAbstractdecl(this.xabstract(c));
		default:
			return this.xerror(c);
		}
	}
	,xmeta: function(x) {
		var ml = [];
		var _g = x.nodes.resolve("m").iterator();
		while(_g.head != null) {
			var m;
			m = (function($this) {
				var $r;
				_g.val = _g.head[0];
				_g.head = _g.head[1];
				$r = _g.val;
				return $r;
			}(this));
			var pl = [];
			var _g1 = m.nodes.resolve("e").iterator();
			while(_g1.head != null) {
				var p;
				p = (function($this) {
					var $r;
					_g1.val = _g1.head[0];
					_g1.head = _g1.head[1];
					$r = _g1.val;
					return $r;
				}(this));
				pl.push(p.get_innerHTML());
			}
			ml.push({ name : m.att.resolve("n"), params : pl});
		}
		return ml;
	}
	,xoverloads: function(x) {
		var l = new List();
		var $it0 = x.get_elements();
		while( $it0.hasNext() ) {
			var m = $it0.next();
			l.add(this.xclassfield(m));
		}
		return l;
	}
	,xpath: function(x) {
		var path = this.mkPath(x.att.resolve("path"));
		var params = new List();
		var $it0 = x.get_elements();
		while( $it0.hasNext() ) {
			var c = $it0.next();
			params.add(this.xtype(c));
		}
		return { path : path, params : params};
	}
	,xclass: function(x) {
		var csuper = null;
		var doc = null;
		var tdynamic = null;
		var interfaces = new List();
		var fields = new List();
		var statics = new List();
		var meta = [];
		var $it0 = x.get_elements();
		while( $it0.hasNext() ) {
			var c = $it0.next();
			var _g = c.get_name();
			switch(_g) {
			case "haxe_doc":
				doc = c.get_innerData();
				break;
			case "extends":
				csuper = this.xpath(c);
				break;
			case "implements":
				interfaces.add(this.xpath(c));
				break;
			case "haxe_dynamic":
				tdynamic = this.xtype(new haxe_xml_Fast(c.x.firstElement()));
				break;
			case "meta":
				meta = this.xmeta(c);
				break;
			default:
				if(c.x.exists("static")) statics.add(this.xclassfield(c)); else fields.add(this.xclassfield(c));
			}
		}
		return { file : x.has.resolve("file")?x.att.resolve("file"):null, path : this.mkPath(x.att.resolve("path")), module : x.has.resolve("module")?this.mkPath(x.att.resolve("module")):null, doc : doc, isPrivate : x.x.exists("private"), isExtern : x.x.exists("extern"), isInterface : x.x.exists("interface"), params : this.mkTypeParams(x.att.resolve("params")), superClass : csuper, interfaces : interfaces, fields : fields, statics : statics, tdynamic : tdynamic, platforms : this.defplat(), meta : meta};
	}
	,xclassfield: function(x,defPublic) {
		if(defPublic == null) defPublic = false;
		var e = x.get_elements();
		var t = this.xtype(e.next());
		var doc = null;
		var meta = [];
		var overloads = null;
		while( e.hasNext() ) {
			var c = e.next();
			var _g = c.get_name();
			switch(_g) {
			case "haxe_doc":
				doc = c.get_innerData();
				break;
			case "meta":
				meta = this.xmeta(c);
				break;
			case "overloads":
				overloads = this.xoverloads(c);
				break;
			default:
				this.xerror(c);
			}
		}
		return { name : x.get_name(), type : t, isPublic : x.x.exists("public") || defPublic, isOverride : x.x.exists("override"), line : x.has.resolve("line")?Std.parseInt(x.att.resolve("line")):null, doc : doc, get : x.has.resolve("get")?this.mkRights(x.att.resolve("get")):haxe_rtti_Rights.RNormal, set : x.has.resolve("set")?this.mkRights(x.att.resolve("set")):haxe_rtti_Rights.RNormal, params : x.has.resolve("params")?this.mkTypeParams(x.att.resolve("params")):[], platforms : this.defplat(), meta : meta, overloads : overloads, expr : x.has.resolve("expr")?x.att.resolve("expr"):null};
	}
	,xenum: function(x) {
		var cl = new List();
		var doc = null;
		var meta = [];
		var $it0 = x.get_elements();
		while( $it0.hasNext() ) {
			var c = $it0.next();
			if(c.get_name() == "haxe_doc") doc = c.get_innerData(); else if(c.get_name() == "meta") meta = this.xmeta(c); else cl.add(this.xenumfield(c));
		}
		return { file : x.has.resolve("file")?x.att.resolve("file"):null, path : this.mkPath(x.att.resolve("path")), module : x.has.resolve("module")?this.mkPath(x.att.resolve("module")):null, doc : doc, isPrivate : x.x.exists("private"), isExtern : x.x.exists("extern"), params : this.mkTypeParams(x.att.resolve("params")), constructors : cl, platforms : this.defplat(), meta : meta};
	}
	,xenumfield: function(x) {
		var args = null;
		var xdoc = x.x.elementsNamed("haxe_doc").next();
		var meta;
		if(x.hasNode.resolve("meta")) meta = this.xmeta(x.node.resolve("meta")); else meta = [];
		if(x.has.resolve("a")) {
			var names = x.att.resolve("a").split(":");
			var elts = x.get_elements();
			args = new List();
			var _g = 0;
			while(_g < names.length) {
				var c = names[_g];
				++_g;
				var opt = false;
				if(c.charAt(0) == "?") {
					opt = true;
					c = HxOverrides.substr(c,1,null);
				}
				args.add({ name : c, opt : opt, t : this.xtype(elts.next())});
			}
		}
		return { name : x.get_name(), args : args, doc : xdoc == null?null:new haxe_xml_Fast(xdoc).get_innerData(), meta : meta, platforms : this.defplat()};
	}
	,xabstract: function(x) {
		var doc = null;
		var impl = null;
		var athis = null;
		var meta = [];
		var to = [];
		var from = [];
		var $it0 = x.get_elements();
		while( $it0.hasNext() ) {
			var c = $it0.next();
			var _g = c.get_name();
			switch(_g) {
			case "haxe_doc":
				doc = c.get_innerData();
				break;
			case "meta":
				meta = this.xmeta(c);
				break;
			case "to":
				var $it1 = c.get_elements();
				while( $it1.hasNext() ) {
					var t = $it1.next();
					to.push({ t : this.xtype(new haxe_xml_Fast(t.x.firstElement())), field : t.has.resolve("field")?t.att.resolve("field"):null});
				}
				break;
			case "from":
				var $it2 = c.get_elements();
				while( $it2.hasNext() ) {
					var t1 = $it2.next();
					from.push({ t : this.xtype(new haxe_xml_Fast(t1.x.firstElement())), field : t1.has.resolve("field")?t1.att.resolve("field"):null});
				}
				break;
			case "impl":
				impl = this.xclass(c.node.resolve("class"));
				break;
			case "this":
				athis = this.xtype(new haxe_xml_Fast(c.x.firstElement()));
				break;
			default:
				this.xerror(c);
			}
		}
		return { file : x.has.resolve("file")?x.att.resolve("file"):null, path : this.mkPath(x.att.resolve("path")), module : x.has.resolve("module")?this.mkPath(x.att.resolve("module")):null, doc : doc, isPrivate : x.x.exists("private"), params : this.mkTypeParams(x.att.resolve("params")), platforms : this.defplat(), meta : meta, athis : athis, to : to, from : from, impl : impl};
	}
	,xtypedef: function(x) {
		var doc = null;
		var t = null;
		var meta = [];
		var $it0 = x.get_elements();
		while( $it0.hasNext() ) {
			var c = $it0.next();
			if(c.get_name() == "haxe_doc") doc = c.get_innerData(); else if(c.get_name() == "meta") meta = this.xmeta(c); else t = this.xtype(c);
		}
		var types = new haxe_ds_StringMap();
		if(this.curplatform != null) types.set(this.curplatform,t);
		return { file : x.has.resolve("file")?x.att.resolve("file"):null, path : this.mkPath(x.att.resolve("path")), module : x.has.resolve("module")?this.mkPath(x.att.resolve("module")):null, doc : doc, isPrivate : x.x.exists("private"), params : this.mkTypeParams(x.att.resolve("params")), type : t, types : types, platforms : this.defplat(), meta : meta};
	}
	,xtype: function(x) {
		var _g = x.get_name();
		switch(_g) {
		case "unknown":
			return haxe_rtti_CType.CUnknown;
		case "e":
			return haxe_rtti_CType.CEnum(this.mkPath(x.att.resolve("path")),this.xtypeparams(x));
		case "c":
			return haxe_rtti_CType.CClass(this.mkPath(x.att.resolve("path")),this.xtypeparams(x));
		case "t":
			return haxe_rtti_CType.CTypedef(this.mkPath(x.att.resolve("path")),this.xtypeparams(x));
		case "x":
			return haxe_rtti_CType.CAbstract(this.mkPath(x.att.resolve("path")),this.xtypeparams(x));
		case "f":
			var args = new List();
			var aname = x.att.resolve("a").split(":");
			var eargs = HxOverrides.iter(aname);
			var evalues;
			if(x.has.resolve("v")) {
				var _this = x.att.resolve("v").split(":");
				evalues = HxOverrides.iter(_this);
			} else evalues = null;
			var $it0 = x.get_elements();
			while( $it0.hasNext() ) {
				var e = $it0.next();
				var opt = false;
				var a = eargs.next();
				if(a == null) a = "";
				if(a.charAt(0) == "?") {
					opt = true;
					a = HxOverrides.substr(a,1,null);
				}
				var v;
				if(evalues == null) v = null; else v = evalues.next();
				args.add({ name : a, opt : opt, t : this.xtype(e), value : v == ""?null:v});
			}
			var ret = args.last();
			args.remove(ret);
			return haxe_rtti_CType.CFunction(args,ret.t);
		case "a":
			var fields = new List();
			var $it1 = x.get_elements();
			while( $it1.hasNext() ) {
				var f = $it1.next();
				var f1 = this.xclassfield(f,true);
				f1.platforms = new List();
				fields.add(f1);
			}
			return haxe_rtti_CType.CAnonymous(fields);
		case "d":
			var t = null;
			var tx = x.x.firstElement();
			if(tx != null) t = this.xtype(new haxe_xml_Fast(tx));
			return haxe_rtti_CType.CDynamic(t);
		default:
			return this.xerror(x);
		}
	}
	,xtypeparams: function(x) {
		var p = new List();
		var $it0 = x.get_elements();
		while( $it0.hasNext() ) {
			var c = $it0.next();
			p.add(this.xtype(c));
		}
		return p;
	}
	,defplat: function() {
		var l = new List();
		if(this.curplatform != null) l.add(this.curplatform);
		return l;
	}
	,__class__: haxe_rtti_XmlParser
};
var haxe_xml__$Fast_NodeAccess = function(x) {
	this.__x = x;
};
$hxClasses["haxe.xml._Fast.NodeAccess"] = haxe_xml__$Fast_NodeAccess;
haxe_xml__$Fast_NodeAccess.__name__ = ["haxe","xml","_Fast","NodeAccess"];
haxe_xml__$Fast_NodeAccess.prototype = {
	__x: null
	,resolve: function(name) {
		var x = this.__x.elementsNamed(name).next();
		if(x == null) {
			var xname;
			if(this.__x.nodeType == Xml.Document) xname = "Document"; else xname = this.__x.get_nodeName();
			throw new js__$Boot_HaxeError(xname + " is missing element " + name);
		}
		return new haxe_xml_Fast(x);
	}
	,__class__: haxe_xml__$Fast_NodeAccess
};
var haxe_xml__$Fast_AttribAccess = function(x) {
	this.__x = x;
};
$hxClasses["haxe.xml._Fast.AttribAccess"] = haxe_xml__$Fast_AttribAccess;
haxe_xml__$Fast_AttribAccess.__name__ = ["haxe","xml","_Fast","AttribAccess"];
haxe_xml__$Fast_AttribAccess.prototype = {
	__x: null
	,resolve: function(name) {
		if(this.__x.nodeType == Xml.Document) throw new js__$Boot_HaxeError("Cannot access document attribute " + name);
		var v = this.__x.get(name);
		if(v == null) throw new js__$Boot_HaxeError(this.__x.get_nodeName() + " is missing attribute " + name);
		return v;
	}
	,__class__: haxe_xml__$Fast_AttribAccess
};
var haxe_xml__$Fast_HasAttribAccess = function(x) {
	this.__x = x;
};
$hxClasses["haxe.xml._Fast.HasAttribAccess"] = haxe_xml__$Fast_HasAttribAccess;
haxe_xml__$Fast_HasAttribAccess.__name__ = ["haxe","xml","_Fast","HasAttribAccess"];
haxe_xml__$Fast_HasAttribAccess.prototype = {
	__x: null
	,resolve: function(name) {
		if(this.__x.nodeType == Xml.Document) throw new js__$Boot_HaxeError("Cannot access document attribute " + name);
		return this.__x.exists(name);
	}
	,__class__: haxe_xml__$Fast_HasAttribAccess
};
var haxe_xml__$Fast_HasNodeAccess = function(x) {
	this.__x = x;
};
$hxClasses["haxe.xml._Fast.HasNodeAccess"] = haxe_xml__$Fast_HasNodeAccess;
haxe_xml__$Fast_HasNodeAccess.__name__ = ["haxe","xml","_Fast","HasNodeAccess"];
haxe_xml__$Fast_HasNodeAccess.prototype = {
	__x: null
	,resolve: function(name) {
		return this.__x.elementsNamed(name).hasNext();
	}
	,__class__: haxe_xml__$Fast_HasNodeAccess
};
var haxe_xml__$Fast_NodeListAccess = function(x) {
	this.__x = x;
};
$hxClasses["haxe.xml._Fast.NodeListAccess"] = haxe_xml__$Fast_NodeListAccess;
haxe_xml__$Fast_NodeListAccess.__name__ = ["haxe","xml","_Fast","NodeListAccess"];
haxe_xml__$Fast_NodeListAccess.prototype = {
	__x: null
	,resolve: function(name) {
		var l = new List();
		var $it0 = this.__x.elementsNamed(name);
		while( $it0.hasNext() ) {
			var x = $it0.next();
			l.add(new haxe_xml_Fast(x));
		}
		return l;
	}
	,__class__: haxe_xml__$Fast_NodeListAccess
};
var haxe_xml_Fast = function(x) {
	if(x.nodeType != Xml.Document && x.nodeType != Xml.Element) throw new js__$Boot_HaxeError("Invalid nodeType " + x.nodeType);
	this.x = x;
	this.node = new haxe_xml__$Fast_NodeAccess(x);
	this.nodes = new haxe_xml__$Fast_NodeListAccess(x);
	this.att = new haxe_xml__$Fast_AttribAccess(x);
	this.has = new haxe_xml__$Fast_HasAttribAccess(x);
	this.hasNode = new haxe_xml__$Fast_HasNodeAccess(x);
};
$hxClasses["haxe.xml.Fast"] = haxe_xml_Fast;
haxe_xml_Fast.__name__ = ["haxe","xml","Fast"];
haxe_xml_Fast.prototype = {
	x: null
	,node: null
	,nodes: null
	,att: null
	,has: null
	,hasNode: null
	,get_name: function() {
		if(this.x.nodeType == Xml.Document) return "Document"; else return this.x.get_nodeName();
	}
	,get_innerData: function() {
		var it = this.x.iterator();
		if(!it.hasNext()) throw new js__$Boot_HaxeError(this.get_name() + " does not have data");
		var v = it.next();
		var n = it.next();
		if(n != null) {
			if(v.nodeType == Xml.PCData && n.nodeType == Xml.CData && StringTools.trim((function($this) {
				var $r;
				if(v.nodeType == Xml.Document || v.nodeType == Xml.Element) throw new js__$Boot_HaxeError("Bad node type, unexpected " + v.nodeType);
				$r = v.nodeValue;
				return $r;
			}(this))) == "") {
				var n2 = it.next();
				if(n2 == null || n2.nodeType == Xml.PCData && StringTools.trim((function($this) {
					var $r;
					if(n2.nodeType == Xml.Document || n2.nodeType == Xml.Element) throw new js__$Boot_HaxeError("Bad node type, unexpected " + n2.nodeType);
					$r = n2.nodeValue;
					return $r;
				}(this))) == "" && it.next() == null) {
					if(n.nodeType == Xml.Document || n.nodeType == Xml.Element) throw new js__$Boot_HaxeError("Bad node type, unexpected " + n.nodeType);
					return n.nodeValue;
				}
			}
			throw new js__$Boot_HaxeError(this.get_name() + " does not only have data");
		}
		if(v.nodeType != Xml.PCData && v.nodeType != Xml.CData) throw new js__$Boot_HaxeError(this.get_name() + " does not have data");
		if(v.nodeType == Xml.Document || v.nodeType == Xml.Element) throw new js__$Boot_HaxeError("Bad node type, unexpected " + v.nodeType);
		return v.nodeValue;
	}
	,get_innerHTML: function() {
		var s = new StringBuf();
		var $it0 = this.x.iterator();
		while( $it0.hasNext() ) {
			var x = $it0.next();
			s.add(haxe_xml_Printer.print(x));
		}
		return s.b;
	}
	,get_elements: function() {
		var it = this.x.elements();
		return { hasNext : $bind(it,it.hasNext), next : function() {
			var x = it.next();
			if(x == null) return null;
			return new haxe_xml_Fast(x);
		}};
	}
	,__class__: haxe_xml_Fast
	,__properties__: {get_elements:"get_elements",get_innerHTML:"get_innerHTML",get_innerData:"get_innerData",get_name:"get_name"}
};
var haxe_xml_Parser = function() { };
$hxClasses["haxe.xml.Parser"] = haxe_xml_Parser;
haxe_xml_Parser.__name__ = ["haxe","xml","Parser"];
haxe_xml_Parser.parse = function(str,strict) {
	if(strict == null) strict = false;
	var doc = Xml.createDocument();
	haxe_xml_Parser.doParse(str,strict,0,doc);
	return doc;
};
haxe_xml_Parser.doParse = function(str,strict,p,parent) {
	if(p == null) p = 0;
	var xml = null;
	var state = 1;
	var next = 1;
	var aname = null;
	var start = 0;
	var nsubs = 0;
	var nbrackets = 0;
	var c = str.charCodeAt(p);
	var buf = new StringBuf();
	var escapeNext = 1;
	var attrValQuote = -1;
	while(!(c != c)) {
		switch(state) {
		case 0:
			switch(c) {
			case 10:case 13:case 9:case 32:
				break;
			default:
				state = next;
				continue;
			}
			break;
		case 1:
			switch(c) {
			case 60:
				state = 0;
				next = 2;
				break;
			default:
				start = p;
				state = 13;
				continue;
			}
			break;
		case 13:
			if(c == 60) {
				buf.addSub(str,start,p - start);
				var child = Xml.createPCData(buf.b);
				buf = new StringBuf();
				parent.addChild(child);
				nsubs++;
				state = 0;
				next = 2;
			} else if(c == 38) {
				buf.addSub(str,start,p - start);
				state = 18;
				escapeNext = 13;
				start = p + 1;
			}
			break;
		case 17:
			if(c == 93 && str.charCodeAt(p + 1) == 93 && str.charCodeAt(p + 2) == 62) {
				var child1 = Xml.createCData(HxOverrides.substr(str,start,p - start));
				parent.addChild(child1);
				nsubs++;
				p += 2;
				state = 1;
			}
			break;
		case 2:
			switch(c) {
			case 33:
				if(str.charCodeAt(p + 1) == 91) {
					p += 2;
					if(HxOverrides.substr(str,p,6).toUpperCase() != "CDATA[") throw new js__$Boot_HaxeError("Expected <![CDATA[");
					p += 5;
					state = 17;
					start = p + 1;
				} else if(str.charCodeAt(p + 1) == 68 || str.charCodeAt(p + 1) == 100) {
					if(HxOverrides.substr(str,p + 2,6).toUpperCase() != "OCTYPE") throw new js__$Boot_HaxeError("Expected <!DOCTYPE");
					p += 8;
					state = 16;
					start = p + 1;
				} else if(str.charCodeAt(p + 1) != 45 || str.charCodeAt(p + 2) != 45) throw new js__$Boot_HaxeError("Expected <!--"); else {
					p += 2;
					state = 15;
					start = p + 1;
				}
				break;
			case 63:
				state = 14;
				start = p;
				break;
			case 47:
				if(parent == null) throw new js__$Boot_HaxeError("Expected node name");
				start = p + 1;
				state = 0;
				next = 10;
				break;
			default:
				state = 3;
				start = p;
				continue;
			}
			break;
		case 3:
			if(!(c >= 97 && c <= 122 || c >= 65 && c <= 90 || c >= 48 && c <= 57 || c == 58 || c == 46 || c == 95 || c == 45)) {
				if(p == start) throw new js__$Boot_HaxeError("Expected node name");
				xml = Xml.createElement(HxOverrides.substr(str,start,p - start));
				parent.addChild(xml);
				nsubs++;
				state = 0;
				next = 4;
				continue;
			}
			break;
		case 4:
			switch(c) {
			case 47:
				state = 11;
				break;
			case 62:
				state = 9;
				break;
			default:
				state = 5;
				start = p;
				continue;
			}
			break;
		case 5:
			if(!(c >= 97 && c <= 122 || c >= 65 && c <= 90 || c >= 48 && c <= 57 || c == 58 || c == 46 || c == 95 || c == 45)) {
				var tmp;
				if(start == p) throw new js__$Boot_HaxeError("Expected attribute name");
				tmp = HxOverrides.substr(str,start,p - start);
				aname = tmp;
				if(xml.exists(aname)) throw new js__$Boot_HaxeError("Duplicate attribute");
				state = 0;
				next = 6;
				continue;
			}
			break;
		case 6:
			switch(c) {
			case 61:
				state = 0;
				next = 7;
				break;
			default:
				throw new js__$Boot_HaxeError("Expected =");
			}
			break;
		case 7:
			switch(c) {
			case 34:case 39:
				buf = new StringBuf();
				state = 8;
				start = p + 1;
				attrValQuote = c;
				break;
			default:
				throw new js__$Boot_HaxeError("Expected \"");
			}
			break;
		case 8:
			switch(c) {
			case 38:
				buf.addSub(str,start,p - start);
				state = 18;
				escapeNext = 8;
				start = p + 1;
				break;
			case 62:
				if(strict) throw new js__$Boot_HaxeError("Invalid unescaped " + String.fromCharCode(c) + " in attribute value"); else if(c == attrValQuote) {
					buf.addSub(str,start,p - start);
					var val = buf.b;
					buf = new StringBuf();
					xml.set(aname,val);
					state = 0;
					next = 4;
				}
				break;
			case 60:
				if(strict) throw new js__$Boot_HaxeError("Invalid unescaped " + String.fromCharCode(c) + " in attribute value"); else if(c == attrValQuote) {
					buf.addSub(str,start,p - start);
					var val1 = buf.b;
					buf = new StringBuf();
					xml.set(aname,val1);
					state = 0;
					next = 4;
				}
				break;
			default:
				if(c == attrValQuote) {
					buf.addSub(str,start,p - start);
					var val2 = buf.b;
					buf = new StringBuf();
					xml.set(aname,val2);
					state = 0;
					next = 4;
				}
			}
			break;
		case 9:
			p = haxe_xml_Parser.doParse(str,strict,p,xml);
			start = p;
			state = 1;
			break;
		case 11:
			switch(c) {
			case 62:
				state = 1;
				break;
			default:
				throw new js__$Boot_HaxeError("Expected >");
			}
			break;
		case 12:
			switch(c) {
			case 62:
				if(nsubs == 0) parent.addChild(Xml.createPCData(""));
				return p;
			default:
				throw new js__$Boot_HaxeError("Expected >");
			}
			break;
		case 10:
			if(!(c >= 97 && c <= 122 || c >= 65 && c <= 90 || c >= 48 && c <= 57 || c == 58 || c == 46 || c == 95 || c == 45)) {
				if(start == p) throw new js__$Boot_HaxeError("Expected node name");
				var v = HxOverrides.substr(str,start,p - start);
				if(v != (function($this) {
					var $r;
					if(parent.nodeType != Xml.Element) throw new js__$Boot_HaxeError("Bad node type, expected Element but found " + parent.nodeType);
					$r = parent.nodeName;
					return $r;
				}(this))) throw new js__$Boot_HaxeError("Expected </" + (function($this) {
					var $r;
					if(parent.nodeType != Xml.Element) throw "Bad node type, expected Element but found " + parent.nodeType;
					$r = parent.nodeName;
					return $r;
				}(this)) + ">");
				state = 0;
				next = 12;
				continue;
			}
			break;
		case 15:
			if(c == 45 && str.charCodeAt(p + 1) == 45 && str.charCodeAt(p + 2) == 62) {
				var xml1 = Xml.createComment(HxOverrides.substr(str,start,p - start));
				parent.addChild(xml1);
				nsubs++;
				p += 2;
				state = 1;
			}
			break;
		case 16:
			if(c == 91) nbrackets++; else if(c == 93) nbrackets--; else if(c == 62 && nbrackets == 0) {
				var xml2 = Xml.createDocType(HxOverrides.substr(str,start,p - start));
				parent.addChild(xml2);
				nsubs++;
				state = 1;
			}
			break;
		case 14:
			if(c == 63 && str.charCodeAt(p + 1) == 62) {
				p++;
				var str1 = HxOverrides.substr(str,start + 1,p - start - 2);
				var xml3 = Xml.createProcessingInstruction(str1);
				parent.addChild(xml3);
				nsubs++;
				state = 1;
			}
			break;
		case 18:
			if(c == 59) {
				var s = HxOverrides.substr(str,start,p - start);
				if(s.charCodeAt(0) == 35) {
					var c1;
					if(s.charCodeAt(1) == 120) c1 = Std.parseInt("0" + HxOverrides.substr(s,1,s.length - 1)); else c1 = Std.parseInt(HxOverrides.substr(s,1,s.length - 1));
					buf.b += String.fromCharCode(c1);
				} else if(!haxe_xml_Parser.escapes.exists(s)) {
					if(strict) throw new js__$Boot_HaxeError("Undefined entity: " + s);
					buf.b += Std.string("&" + s + ";");
				} else buf.add(haxe_xml_Parser.escapes.get(s));
				start = p + 1;
				state = escapeNext;
			} else if(!(c >= 97 && c <= 122 || c >= 65 && c <= 90 || c >= 48 && c <= 57 || c == 58 || c == 46 || c == 95 || c == 45) && c != 35) {
				if(strict) throw new js__$Boot_HaxeError("Invalid character in entity: " + String.fromCharCode(c));
				buf.b += "&";
				buf.addSub(str,start,p - start);
				p--;
				start = p + 1;
				state = escapeNext;
			}
			break;
		}
		c = StringTools.fastCodeAt(str,++p);
	}
	if(state == 1) {
		start = p;
		state = 13;
	}
	if(state == 13) {
		if(p != start || nsubs == 0) {
			buf.addSub(str,start,p - start);
			var xml4 = Xml.createPCData(buf.b);
			parent.addChild(xml4);
			nsubs++;
		}
		return p;
	}
	if(!strict && state == 18 && escapeNext == 13) {
		buf.b += "&";
		buf.addSub(str,start,p - start);
		var xml5 = Xml.createPCData(buf.b);
		parent.addChild(xml5);
		nsubs++;
		return p;
	}
	throw new js__$Boot_HaxeError("Unexpected end");
};
var haxe_xml_Printer = function(pretty) {
	this.output = new StringBuf();
	this.pretty = pretty;
};
$hxClasses["haxe.xml.Printer"] = haxe_xml_Printer;
haxe_xml_Printer.__name__ = ["haxe","xml","Printer"];
haxe_xml_Printer.print = function(xml,pretty) {
	if(pretty == null) pretty = false;
	var printer = new haxe_xml_Printer(pretty);
	printer.writeNode(xml,"");
	return printer.output.b;
};
haxe_xml_Printer.prototype = {
	output: null
	,pretty: null
	,writeNode: function(value,tabs) {
		var _g = value.nodeType;
		switch(_g) {
		case 2:
			this.output.b += Std.string(tabs + "<![CDATA[");
			this.write(StringTools.trim((function($this) {
				var $r;
				if(value.nodeType == Xml.Document || value.nodeType == Xml.Element) throw new js__$Boot_HaxeError("Bad node type, unexpected " + value.nodeType);
				$r = value.nodeValue;
				return $r;
			}(this))));
			this.output.b += "]]>";
			if(this.pretty) this.output.b += "";
			break;
		case 3:
			var commentContent;
			if(value.nodeType == Xml.Document || value.nodeType == Xml.Element) throw new js__$Boot_HaxeError("Bad node type, unexpected " + value.nodeType);
			commentContent = value.nodeValue;
			commentContent = new EReg("[\n\r\t]+","g").replace(commentContent,"");
			commentContent = "<!--" + commentContent + "-->";
			if(tabs == null) this.output.b += "null"; else this.output.b += "" + tabs;
			this.write(StringTools.trim(commentContent));
			if(this.pretty) this.output.b += "";
			break;
		case 6:
			var $it0 = (function($this) {
				var $r;
				if(value.nodeType != Xml.Document && value.nodeType != Xml.Element) throw new js__$Boot_HaxeError("Bad node type, expected Element or Document but found " + value.nodeType);
				$r = HxOverrides.iter(value.children);
				return $r;
			}(this));
			while( $it0.hasNext() ) {
				var child = $it0.next();
				this.writeNode(child,tabs);
			}
			break;
		case 0:
			this.output.b += Std.string(tabs + "<");
			this.write((function($this) {
				var $r;
				if(value.nodeType != Xml.Element) throw new js__$Boot_HaxeError("Bad node type, expected Element but found " + value.nodeType);
				$r = value.nodeName;
				return $r;
			}(this)));
			var $it1 = value.attributes();
			while( $it1.hasNext() ) {
				var attribute = $it1.next();
				this.output.b += Std.string(" " + attribute + "=\"");
				this.write(StringTools.htmlEscape(value.get(attribute),true));
				this.output.b += "\"";
			}
			if(this.hasChildren(value)) {
				this.output.b += ">";
				if(this.pretty) this.output.b += "";
				var $it2 = (function($this) {
					var $r;
					if(value.nodeType != Xml.Document && value.nodeType != Xml.Element) throw new js__$Boot_HaxeError("Bad node type, expected Element or Document but found " + value.nodeType);
					$r = HxOverrides.iter(value.children);
					return $r;
				}(this));
				while( $it2.hasNext() ) {
					var child1 = $it2.next();
					this.writeNode(child1,this.pretty?tabs + "\t":tabs);
				}
				this.output.b += Std.string(tabs + "</");
				this.write((function($this) {
					var $r;
					if(value.nodeType != Xml.Element) throw new js__$Boot_HaxeError("Bad node type, expected Element but found " + value.nodeType);
					$r = value.nodeName;
					return $r;
				}(this)));
				this.output.b += ">";
				if(this.pretty) this.output.b += "";
			} else {
				this.output.b += "/>";
				if(this.pretty) this.output.b += "";
			}
			break;
		case 1:
			var nodeValue;
			if(value.nodeType == Xml.Document || value.nodeType == Xml.Element) throw new js__$Boot_HaxeError("Bad node type, unexpected " + value.nodeType);
			nodeValue = value.nodeValue;
			if(nodeValue.length != 0) {
				this.write(tabs + StringTools.htmlEscape(nodeValue));
				if(this.pretty) this.output.b += "";
			}
			break;
		case 5:
			this.write("<?" + (function($this) {
				var $r;
				if(value.nodeType == Xml.Document || value.nodeType == Xml.Element) throw new js__$Boot_HaxeError("Bad node type, unexpected " + value.nodeType);
				$r = value.nodeValue;
				return $r;
			}(this)) + "?>");
			break;
		case 4:
			this.write("<!DOCTYPE " + (function($this) {
				var $r;
				if(value.nodeType == Xml.Document || value.nodeType == Xml.Element) throw new js__$Boot_HaxeError("Bad node type, unexpected " + value.nodeType);
				$r = value.nodeValue;
				return $r;
			}(this)) + ">");
			break;
		}
	}
	,write: function(input) {
		if(input == null) this.output.b += "null"; else this.output.b += "" + input;
	}
	,hasChildren: function(value) {
		var $it0 = (function($this) {
			var $r;
			if(value.nodeType != Xml.Document && value.nodeType != Xml.Element) throw new js__$Boot_HaxeError("Bad node type, expected Element or Document but found " + value.nodeType);
			$r = HxOverrides.iter(value.children);
			return $r;
		}(this));
		while( $it0.hasNext() ) {
			var child = $it0.next();
			var _g = child.nodeType;
			switch(_g) {
			case 0:case 1:
				return true;
			case 2:case 3:
				if(StringTools.ltrim((function($this) {
					var $r;
					if(child.nodeType == Xml.Document || child.nodeType == Xml.Element) throw new js__$Boot_HaxeError("Bad node type, unexpected " + child.nodeType);
					$r = child.nodeValue;
					return $r;
				}(this))).length != 0) return true;
				break;
			default:
			}
		}
		return false;
	}
	,__class__: haxe_xml_Printer
};
var js__$Boot_HaxeError = function(val) {
	Error.call(this);
	this.val = val;
	this.message = String(val);
	if(Error.captureStackTrace) Error.captureStackTrace(this,js__$Boot_HaxeError);
};
$hxClasses["js._Boot.HaxeError"] = js__$Boot_HaxeError;
js__$Boot_HaxeError.__name__ = ["js","_Boot","HaxeError"];
js__$Boot_HaxeError.__super__ = Error;
js__$Boot_HaxeError.prototype = $extend(Error.prototype,{
	val: null
	,__class__: js__$Boot_HaxeError
});
var js_Boot = function() { };
$hxClasses["js.Boot"] = js_Boot;
js_Boot.__name__ = ["js","Boot"];
js_Boot.getClass = function(o) {
	if((o instanceof Array) && o.__enum__ == null) return Array; else {
		var cl = o.__class__;
		if(cl != null) return cl;
		var name = js_Boot.__nativeClassName(o);
		if(name != null) return js_Boot.__resolveNativeClass(name);
		return null;
	}
};
js_Boot.__string_rec = function(o,s) {
	if(o == null) return "null";
	if(s.length >= 5) return "<...>";
	var t = typeof(o);
	if(t == "function" && (o.__name__ || o.__ename__)) t = "object";
	switch(t) {
	case "object":
		if(o instanceof Array) {
			if(o.__enum__) {
				if(o.length == 2) return o[0];
				var str2 = o[0] + "(";
				s += "\t";
				var _g1 = 2;
				var _g = o.length;
				while(_g1 < _g) {
					var i1 = _g1++;
					if(i1 != 2) str2 += "," + js_Boot.__string_rec(o[i1],s); else str2 += js_Boot.__string_rec(o[i1],s);
				}
				return str2 + ")";
			}
			var l = o.length;
			var i;
			var str1 = "[";
			s += "\t";
			var _g2 = 0;
			while(_g2 < l) {
				var i2 = _g2++;
				str1 += (i2 > 0?",":"") + js_Boot.__string_rec(o[i2],s);
			}
			str1 += "]";
			return str1;
		}
		var tostr;
		try {
			tostr = o.toString;
		} catch( e ) {
			if (e instanceof js__$Boot_HaxeError) e = e.val;
			return "???";
		}
		if(tostr != null && tostr != Object.toString && typeof(tostr) == "function") {
			var s2 = o.toString();
			if(s2 != "[object Object]") return s2;
		}
		var k = null;
		var str = "{\n";
		s += "\t";
		var hasp = o.hasOwnProperty != null;
		for( var k in o ) {
		if(hasp && !o.hasOwnProperty(k)) {
			continue;
		}
		if(k == "prototype" || k == "__class__" || k == "__super__" || k == "__interfaces__" || k == "__properties__") {
			continue;
		}
		if(str.length != 2) str += ", \n";
		str += s + k + " : " + js_Boot.__string_rec(o[k],s);
		}
		s = s.substring(1);
		str += "\n" + s + "}";
		return str;
	case "function":
		return "<function>";
	case "string":
		return o;
	default:
		return String(o);
	}
};
js_Boot.__interfLoop = function(cc,cl) {
	if(cc == null) return false;
	if(cc == cl) return true;
	var intf = cc.__interfaces__;
	if(intf != null) {
		var _g1 = 0;
		var _g = intf.length;
		while(_g1 < _g) {
			var i = _g1++;
			var i1 = intf[i];
			if(i1 == cl || js_Boot.__interfLoop(i1,cl)) return true;
		}
	}
	return js_Boot.__interfLoop(cc.__super__,cl);
};
js_Boot.__instanceof = function(o,cl) {
	if(cl == null) return false;
	switch(cl) {
	case Int:
		return (o|0) === o;
	case Float:
		return typeof(o) == "number";
	case Bool:
		return typeof(o) == "boolean";
	case String:
		return typeof(o) == "string";
	case Array:
		return (o instanceof Array) && o.__enum__ == null;
	case Dynamic:
		return true;
	default:
		if(o != null) {
			if(typeof(cl) == "function") {
				if(o instanceof cl) return true;
				if(js_Boot.__interfLoop(js_Boot.getClass(o),cl)) return true;
			} else if(typeof(cl) == "object" && js_Boot.__isNativeObj(cl)) {
				if(o instanceof cl) return true;
			}
		} else return false;
		if(cl == Class && o.__name__ != null) return true;
		if(cl == Enum && o.__ename__ != null) return true;
		return o.__enum__ == cl;
	}
};
js_Boot.__cast = function(o,t) {
	if(js_Boot.__instanceof(o,t)) return o; else throw new js__$Boot_HaxeError("Cannot cast " + Std.string(o) + " to " + Std.string(t));
};
js_Boot.__nativeClassName = function(o) {
	var name = js_Boot.__toStr.call(o).slice(8,-1);
	if(name == "Object" || name == "Function" || name == "Math" || name == "JSON") return null;
	return name;
};
js_Boot.__isNativeObj = function(o) {
	return js_Boot.__nativeClassName(o) != null;
};
js_Boot.__resolveNativeClass = function(name) {
	return $global[name];
};
var tjson_TJSON = $hx_exports.tjson.TJSON = function() { };
$hxClasses["tjson.TJSON"] = tjson_TJSON;
tjson_TJSON.__name__ = ["tjson","TJSON"];
tjson_TJSON.parse = function(json,fileName,stringProcessor) {
	if(fileName == null) fileName = "JSON Data";
	var t = new tjson_TJSONParser(json,fileName,stringProcessor);
	return t.doParse();
};
tjson_TJSON.encode = function(obj,style,useCache) {
	if(useCache == null) useCache = true;
	var t = new tjson_TJSONEncoder(useCache);
	return t.doEncode(obj,style);
};
tjson_TJSON.encodeToPlainObject = function(obj,style,useCache) {
	if(useCache == null) useCache = true;
	return tjson_TJSON.parse(tjson_TJSON.encode(obj));
};
var tjson_TJSONParser = function(vjson,vfileName,stringProcessor) {
	if(vfileName == null) vfileName = "JSON Data";
	this.json = vjson;
	this.fileName = vfileName;
	this.currentLine = 1;
	this.lastSymbolQuoted = false;
	this.pos = 0;
	this.floatRegex = new EReg("^-?[0-9]*\\.[0-9]+$","");
	this.intRegex = new EReg("^-?[0-9]+$","");
	if(stringProcessor == null) this.strProcessor = $bind(this,this.defaultStringProcessor); else this.strProcessor = stringProcessor;
	this.cache = [];
};
$hxClasses["tjson.TJSONParser"] = tjson_TJSONParser;
tjson_TJSONParser.__name__ = ["tjson","TJSONParser"];
tjson_TJSONParser.prototype = {
	pos: null
	,json: null
	,lastSymbolQuoted: null
	,fileName: null
	,currentLine: null
	,cache: null
	,floatRegex: null
	,intRegex: null
	,strProcessor: null
	,doParse: function() {
		try {
			var _g = this.getNextSymbol();
			var s = _g;
			switch(_g) {
			case "{":
				return this.doObject();
			case "[":
				return this.doArray();
			default:
				return this.convertSymbolToProperType(s);
			}
		} catch( e ) {
			if (e instanceof js__$Boot_HaxeError) e = e.val;
			if( js_Boot.__instanceof(e,String) ) {
				throw new js__$Boot_HaxeError(this.fileName + " on line " + this.currentLine + ": " + e);
			} else throw(e);
		}
	}
	,doObject: function() {
		var o = { };
		var val = "";
		var key;
		var isClassOb = false;
		this.cache.push(o);
		while(this.pos < this.json.length) {
			key = this.getNextSymbol();
			if(key == "," && !this.lastSymbolQuoted) continue;
			if(key == "}" && !this.lastSymbolQuoted) {
				if(isClassOb && o.TJ_unserialize != null) o.TJ_unserialize();
				return o;
			}
			var seperator = this.getNextSymbol();
			if(seperator != ":") throw new js__$Boot_HaxeError("Expected ':' but got '" + seperator + "' instead.");
			var v = this.getNextSymbol();
			if(key == "_hxcls") {
				if(StringTools.startsWith(v,"Date@")) {
					var t = Std.parseInt(HxOverrides.substr(v,5,null));
					var d = new Date();
					d.setTime(t);
					o = d;
				} else {
					var cls = Type.resolveClass(v);
					if(cls == null) {
						cls = eval("window['" + v + "']");
						if(cls == null) throw new js__$Boot_HaxeError("Could not resolve Javascript class - " + v);
					}
					o = Type.createEmptyInstance(cls);
				}
				this.cache.pop();
				this.cache.push(o);
				isClassOb = true;
				continue;
			}
			if(v == "{" && !this.lastSymbolQuoted) val = this.doObject(); else if(v == "[" && !this.lastSymbolQuoted) val = this.doArray(); else val = this.convertSymbolToProperType(v);
			o[key] = val;
		}
		throw new js__$Boot_HaxeError("Unexpected end of file. Expected '}'");
	}
	,doArray: function() {
		var a = [];
		var val;
		while(this.pos < this.json.length) {
			val = this.getNextSymbol();
			if(val == "," && !this.lastSymbolQuoted) continue; else if(val == "]" && !this.lastSymbolQuoted) return a; else if(val == "{" && !this.lastSymbolQuoted) val = this.doObject(); else if(val == "[" && !this.lastSymbolQuoted) val = this.doArray(); else val = this.convertSymbolToProperType(val);
			a.push(val);
		}
		throw new js__$Boot_HaxeError("Unexpected end of file. Expected ']'");
	}
	,convertSymbolToProperType: function(symbol) {
		if(this.lastSymbolQuoted) {
			if(StringTools.startsWith(symbol,tjson_TJSON.OBJECT_REFERENCE_PREFIX)) {
				var idx = Std.parseInt(HxOverrides.substr(symbol,tjson_TJSON.OBJECT_REFERENCE_PREFIX.length,null));
				return this.cache[idx];
			}
			return symbol;
		}
		if(this.looksLikeFloat(symbol)) return parseFloat(symbol);
		if(this.looksLikeInt(symbol)) return Std.parseInt(symbol);
		if(symbol.toLowerCase() == "true") return true;
		if(symbol.toLowerCase() == "false") return false;
		if(symbol.toLowerCase() == "null") return null;
		return symbol;
	}
	,looksLikeFloat: function(s) {
		if(this.floatRegex.match(s)) return true;
		if(this.intRegex.match(s)) {
			if((function($this) {
				var $r;
				var intStr = $this.intRegex.matched(0);
				$r = HxOverrides.cca(intStr,0) == 45?intStr > "-2147483648":intStr > "2147483647";
				return $r;
			}(this))) return true;
			var f = parseFloat(s);
			if(f > 2147483647.0) return true; else if(f < -2147483648) return true;
		}
		return false;
	}
	,looksLikeInt: function(s) {
		return this.intRegex.match(s);
	}
	,getNextSymbol: function() {
		this.lastSymbolQuoted = false;
		var c = "";
		var inQuote = false;
		var quoteType = "";
		var symbol = "";
		var inEscape = false;
		var inSymbol = false;
		var inLineComment = false;
		var inBlockComment = false;
		while(this.pos < this.json.length) {
			c = this.json.charAt(this.pos++);
			if(c == "\n" && !inSymbol) this.currentLine++;
			if(inLineComment) {
				if(c == "\n" || c == "\r") {
					inLineComment = false;
					this.pos++;
				}
				continue;
			}
			if(inBlockComment) {
				if(c == "*" && this.json.charAt(this.pos) == "/") {
					inBlockComment = false;
					this.pos++;
				}
				continue;
			}
			if(inQuote) {
				if(inEscape) {
					inEscape = false;
					if(c == "'" || c == "\"") {
						symbol += c;
						continue;
					}
					if(c == "t") {
						symbol += "\t";
						continue;
					}
					if(c == "n") {
						symbol += "\n";
						continue;
					}
					if(c == "\\") {
						symbol += "\\";
						continue;
					}
					if(c == "r") {
						symbol += "\r";
						continue;
					}
					if(c == "/") {
						symbol += "/";
						continue;
					}
					if(c == "u") {
						var hexValue = 0;
						var _g = 0;
						while(_g < 4) {
							var i = _g++;
							if(this.pos >= this.json.length) throw new js__$Boot_HaxeError("Unfinished UTF8 character");
							var nc;
							var index = this.pos++;
							nc = HxOverrides.cca(this.json,index);
							hexValue = hexValue << 4;
							if(nc >= 48 && nc <= 57) hexValue += nc - 48; else if(nc >= 65 && nc <= 70) hexValue += 10 + nc - 65; else if(nc >= 97 && nc <= 102) hexValue += 10 + nc - 95; else throw new js__$Boot_HaxeError("Not a hex digit");
						}
						var utf = new haxe_Utf8();
						utf.__b += String.fromCharCode(hexValue);
						symbol += utf.__b;
						continue;
					}
					throw new js__$Boot_HaxeError("Invalid escape sequence '\\" + c + "'");
				} else {
					if(c == "\\") {
						inEscape = true;
						continue;
					}
					if(c == quoteType) return symbol;
					symbol += c;
					continue;
				}
			} else if(c == "/") {
				var c2 = this.json.charAt(this.pos);
				if(c2 == "/") {
					inLineComment = true;
					this.pos++;
					continue;
				} else if(c2 == "*") {
					inBlockComment = true;
					this.pos++;
					continue;
				}
			}
			if(inSymbol) {
				if(c == " " || c == "\n" || c == "\r" || c == "\t" || c == "," || c == ":" || c == "}" || c == "]") {
					this.pos--;
					return symbol;
				} else {
					symbol += c;
					continue;
				}
			} else {
				if(c == " " || c == "\t" || c == "\n" || c == "\r") continue;
				if(c == "{" || c == "}" || c == "[" || c == "]" || c == "," || c == ":") return c;
				if(c == "'" || c == "\"") {
					inQuote = true;
					quoteType = c;
					this.lastSymbolQuoted = true;
					continue;
				} else {
					inSymbol = true;
					symbol = c;
					continue;
				}
			}
		}
		if(inQuote) throw new js__$Boot_HaxeError("Unexpected end of data. Expected ( " + quoteType + " )");
		return symbol;
	}
	,defaultStringProcessor: function(str) {
		return str;
	}
	,__class__: tjson_TJSONParser
};
var tjson_TJSONEncoder = function(useCache) {
	if(useCache == null) useCache = true;
	this.uCache = useCache;
	if(this.uCache) this.cache = [];
};
$hxClasses["tjson.TJSONEncoder"] = tjson_TJSONEncoder;
tjson_TJSONEncoder.__name__ = ["tjson","TJSONEncoder"];
tjson_TJSONEncoder.prototype = {
	cache: null
	,uCache: null
	,doEncode: function(obj,style) {
		if(!Reflect.isObject(obj)) throw new js__$Boot_HaxeError("Provided object is not an object.");
		var st;
		if(js_Boot.__instanceof(style,tjson_EncodeStyle)) st = style; else if(style == "fancy") st = new tjson_FancyStyle(); else st = new tjson_SimpleStyle();
		var buffer = new StringBuf();
		if((obj instanceof Array) && obj.__enum__ == null || js_Boot.__instanceof(obj,List)) buffer.add(this.encodeIterable(obj,st,0)); else if(js_Boot.__instanceof(obj,haxe_ds_StringMap)) buffer.add(this.encodeMap(obj,st,0)); else {
			this.cacheEncode(obj);
			buffer.add(this.encodeObject(obj,st,0));
		}
		return buffer.b;
	}
	,encodeObject: function(obj,style,depth) {
		var buffer = new StringBuf();
		buffer.add(style.beginObject(depth));
		var fieldCount = 0;
		var fields;
		var dontEncodeFields = null;
		var cls = Type.getClass(obj);
		if(cls != null) fields = Type.getInstanceFields(cls); else fields = Reflect.fields(obj);
		{
			var _g = Type["typeof"](obj);
			switch(_g[1]) {
			case 6:
				var c = _g[2];
				var className = Type.getClassName(c);
				if(className == "Date") className += "@" + (js_Boot.__cast(obj , Date)).getTime();
				if(fieldCount++ > 0) buffer.add(style.entrySeperator(depth)); else buffer.add(style.firstEntry(depth));
				buffer.add("\"_hxcls\"" + style.keyValueSeperator(depth));
				buffer.add(this.encodeValue(className,style,depth));
				if(obj.TJ_noEncode != null) dontEncodeFields = obj.TJ_noEncode();
				break;
			default:
			}
		}
		var _g1 = 0;
		while(_g1 < fields.length) {
			var field = fields[_g1];
			++_g1;
			if(dontEncodeFields != null && HxOverrides.indexOf(dontEncodeFields,field,0) >= 0) continue;
			var value = Reflect.field(obj,field);
			var vStr = this.encodeValue(value,style,depth);
			if(vStr != null) {
				if(fieldCount++ > 0) buffer.add(style.entrySeperator(depth)); else buffer.add(style.firstEntry(depth));
				buffer.add("\"" + field + "\"" + style.keyValueSeperator(depth) + vStr);
			}
		}
		buffer.add(style.endObject(depth));
		return buffer.b;
	}
	,encodeMap: function(obj,style,depth) {
		var buffer = new StringBuf();
		buffer.add(style.beginObject(depth));
		var fieldCount = 0;
		var $it0 = obj.keys();
		while( $it0.hasNext() ) {
			var field = $it0.next();
			if(fieldCount++ > 0) buffer.add(style.entrySeperator(depth)); else buffer.add(style.firstEntry(depth));
			var value = obj.get(field);
			buffer.add("\"" + field + "\"" + style.keyValueSeperator(depth));
			buffer.add(this.encodeValue(value,style,depth));
		}
		buffer.add(style.endObject(depth));
		return buffer.b;
	}
	,encodeIterable: function(obj,style,depth) {
		var buffer = new StringBuf();
		buffer.add(style.beginArray(depth));
		var fieldCount = 0;
		var $it0 = $iterator(obj)();
		while( $it0.hasNext() ) {
			var value = $it0.next();
			if(fieldCount++ > 0) buffer.add(style.entrySeperator(depth)); else buffer.add(style.firstEntry(depth));
			buffer.add(this.encodeValue(value,style,depth));
		}
		buffer.add(style.endArray(depth));
		return buffer.b;
	}
	,cacheEncode: function(value) {
		if(!this.uCache) return null;
		var _g1 = 0;
		var _g = this.cache.length;
		while(_g1 < _g) {
			var c = _g1++;
			if(this.cache[c] == value) return "\"" + tjson_TJSON.OBJECT_REFERENCE_PREFIX + c + "\"";
		}
		this.cache.push(value);
		return null;
	}
	,encodeValue: function(value,style,depth) {
		if(((value | 0) === value) || typeof(value) == "number") return value; else if((value instanceof Array) && value.__enum__ == null || js_Boot.__instanceof(value,List)) {
			var v = value;
			return this.encodeIterable(v,style,depth + 1);
		} else if(js_Boot.__instanceof(value,List)) {
			var v1 = value;
			return this.encodeIterable(v1,style,depth + 1);
		} else if(js_Boot.__instanceof(value,haxe_ds_StringMap)) return this.encodeMap(value,style,depth + 1); else if(typeof(value) == "string") return "\"" + StringTools.replace(StringTools.replace(StringTools.replace(StringTools.replace(Std.string(value),"\\","\\\\"),"\n","\\n"),"\r","\\r"),"\"","\\\"") + "\""; else if(typeof(value) == "boolean") return value; else if(Reflect.isObject(value)) {
			var ret = this.cacheEncode(value);
			if(ret != null) return ret;
			return this.encodeObject(value,style,depth + 1);
		} else if(value == null) return "null"; else return null;
	}
	,__class__: tjson_TJSONEncoder
};
var tjson_EncodeStyle = function() { };
$hxClasses["tjson.EncodeStyle"] = tjson_EncodeStyle;
tjson_EncodeStyle.__name__ = ["tjson","EncodeStyle"];
tjson_EncodeStyle.prototype = {
	beginObject: null
	,endObject: null
	,beginArray: null
	,endArray: null
	,firstEntry: null
	,entrySeperator: null
	,keyValueSeperator: null
	,__class__: tjson_EncodeStyle
};
var tjson_SimpleStyle = function() {
};
$hxClasses["tjson.SimpleStyle"] = tjson_SimpleStyle;
tjson_SimpleStyle.__name__ = ["tjson","SimpleStyle"];
tjson_SimpleStyle.__interfaces__ = [tjson_EncodeStyle];
tjson_SimpleStyle.prototype = {
	beginObject: function(depth) {
		return "{";
	}
	,endObject: function(depth) {
		return "}";
	}
	,beginArray: function(depth) {
		return "[";
	}
	,endArray: function(depth) {
		return "]";
	}
	,firstEntry: function(depth) {
		return "";
	}
	,entrySeperator: function(depth) {
		return ",";
	}
	,keyValueSeperator: function(depth) {
		return ":";
	}
	,__class__: tjson_SimpleStyle
};
var tjson_FancyStyle = function(tab) {
	if(tab == null) tab = "    ";
	this.tab = tab;
	this.charTimesNCache = [""];
};
$hxClasses["tjson.FancyStyle"] = tjson_FancyStyle;
tjson_FancyStyle.__name__ = ["tjson","FancyStyle"];
tjson_FancyStyle.__interfaces__ = [tjson_EncodeStyle];
tjson_FancyStyle.prototype = {
	tab: null
	,beginObject: function(depth) {
		return "{\n";
	}
	,endObject: function(depth) {
		return "\n" + this.charTimesN(depth) + "}";
	}
	,beginArray: function(depth) {
		return "[\n";
	}
	,endArray: function(depth) {
		return "\n" + this.charTimesN(depth) + "]";
	}
	,firstEntry: function(depth) {
		return this.charTimesN(depth + 1) + " ";
	}
	,entrySeperator: function(depth) {
		return "\n" + this.charTimesN(depth + 1) + ",";
	}
	,keyValueSeperator: function(depth) {
		return " : ";
	}
	,charTimesNCache: null
	,charTimesN: function(n) {
		if(n < this.charTimesNCache.length) return this.charTimesNCache[n]; else return this.charTimesNCache[n] = this.charTimesN(n - 1) + this.tab;
	}
	,__class__: tjson_FancyStyle
};
var troshx_BodyChar = $hx_exports.troshx.BodyChar = function() {
	this.zones = [];
	this.zones[0] = null;
	this.zonesB = [];
	this.zones[1] = null;
};
$hxClasses["troshx.BodyChar"] = troshx_BodyChar;
troshx_BodyChar.__name__ = ["troshx","BodyChar"];
troshx_BodyChar.getEmptyBodyPartTypeDef = function() {
	return { BL : 0, KD : null, lev : 0, d : 0, ko : null, shock : 0, shockWP : 0, pain : 0, painWP : 0};
};
troshx_BodyChar.getEmptyWoundLocation = function(id) {
	return { id : id, cut : [], puncture : [], bludgeon : []};
};
troshx_BodyChar.getCleanArrayOfWound = function(dirtyArr) {
	var cleanArr = [];
	var _g1 = 0;
	var _g = dirtyArr.length;
	while(_g1 < _g) {
		var i = _g1++;
		cleanArr[i] = troshx_BodyChar.getBodyPartOf(dirtyArr[i]);
	}
	return cleanArr;
};
troshx_BodyChar.getBodyPartOf = function(obj) {
	var theBodyPart = troshx_BodyChar.getEmptyBodyPartTypeDef();
	var _g = 0;
	var _g1 = Reflect.fields(theBodyPart);
	while(_g < _g1.length) {
		var f = _g1[_g];
		++_g;
		if(Object.prototype.hasOwnProperty.call(obj,f)) Reflect.setField(theBodyPart,f,Reflect.field(obj,f));
	}
	return theBodyPart;
};
troshx_BodyChar.prototype = {
	getAllWoundLocations: function() {
		var arr = [];
		var partsMap = new haxe_ds_StringMap();
		var _g = 0;
		var _g1 = Reflect.fields(this.partsCut);
		while(_g < _g1.length) {
			var f = _g1[_g];
			++_g;
			if(__map_reserved[f] != null) partsMap.setReserved(f,true); else partsMap.h[f] = true;
		}
		var _g2 = 0;
		var _g11 = Reflect.fields(this.partsBludgeon);
		while(_g2 < _g11.length) {
			var f1 = _g11[_g2];
			++_g2;
			if(__map_reserved[f1] != null) partsMap.setReserved(f1,true); else partsMap.h[f1] = true;
		}
		var _g3 = 0;
		var _g12 = Reflect.fields(this.partsPuncture);
		while(_g3 < _g12.length) {
			var f2 = _g12[_g3];
			++_g3;
			if(__map_reserved[f2] != null) partsMap.setReserved(f2,true); else partsMap.h[f2] = true;
		}
		var $it0 = partsMap.keys();
		while( $it0.hasNext() ) {
			var f3 = $it0.next();
			var woundLocation = troshx_BodyChar.getEmptyWoundLocation(f3);
			if(Object.prototype.hasOwnProperty.call(this.partsCut,f3)) woundLocation.cut = troshx_BodyChar.getCleanArrayOfWound(Reflect.field(this.partsCut,f3));
			if(Object.prototype.hasOwnProperty.call(this.partsPuncture,f3)) woundLocation.puncture = troshx_BodyChar.getCleanArrayOfWound(Reflect.field(this.partsPuncture,f3));
			if(Object.prototype.hasOwnProperty.call(this.partsBludgeon,f3)) woundLocation.bludgeon = troshx_BodyChar.getCleanArrayOfWound(Reflect.field(this.partsBludgeon,f3));
			arr.push(woundLocation);
		}
		return arr;
	}
	,zones: null
	,zonesB: null
	,thrustStartIndex: null
	,centerOfMass: null
	,centerOfMassT: null
	,partsCut: null
	,partsPuncture: null
	,partsBludgeon: null
	,getTargetZoneCost: function(index) {
		return 0;
	}
	,__class__: troshx_BodyChar
};
var troshx_GameRules = $hx_exports.troshx.GameRules = function() { };
$hxClasses["troshx.GameRules"] = troshx_GameRules;
troshx_GameRules.__name__ = ["troshx","GameRules"];
var troshx_ZoneBody = function() {
	this.weightsTotal = 0;
};
$hxClasses["troshx.ZoneBody"] = troshx_ZoneBody;
troshx_ZoneBody.__name__ = ["troshx","ZoneBody"];
troshx_ZoneBody.create = function(name,partWeights,parts,weightsTotal) {
	if(weightsTotal == null) weightsTotal = 0;
	var zb = new troshx_ZoneBody();
	zb.name = name;
	zb.parts = parts;
	zb.partWeights = partWeights;
	zb.weightsTotal = weightsTotal;
	if(weightsTotal == 0) zb.recalcWeightsTotal();
	return zb;
};
troshx_ZoneBody.prototype = {
	name: null
	,parts: null
	,partWeights: null
	,weightsTotal: null
	,recalcWeightsTotal: function() {
		var accum = 0;
		var i = this.partWeights.length;
		while(--i > -1) accum += this.partWeights[i];
		this.weightsTotal = accum;
	}
	,getBodyPart: function(floatRatio) {
		floatRatio *= this.weightsTotal;
		var accum = 0;
		var result = 0;
		var _g1 = 0;
		var _g = this.partWeights.length;
		while(_g1 < _g) {
			var i = _g1++;
			if(floatRatio < accum) break;
			accum += this.partWeights[i];
			result = i;
		}
		return this.parts[result];
	}
	,__class__: troshx_ZoneBody
};
var troshx_tros_HumanoidBody = $hx_exports.troshx.tros.HumanoidBody = function() {
	troshx_BodyChar.call(this);
	this.partsBludgeon = { 'foot' : [{ 'BL' : 0, 'shock' : 4, 'shockWP' : 1, 'pain' : 4, 'painWP' : 1},{ 'BL' : 0, 'shock' : 3, 'shockWP' : 0, 'pain' : 5, 'painWP' : 1},{ 'KD' : 3, 'BL' : 0, 'shock' : 4, 'shockWP' : 0, 'pain' : 6, 'painWP' : 1},{ 'KD' : 1, 'BL' : 0, 'shock' : 6, 'shockWP' : 0, 'pain' : 8, 'painWP' : 1},{ 'KD' : -1, 'BL' : 1, 'shock' : 9, 'shockWP' : 0, 'pain' : 10, 'painWP' : 1}], 'shin_and_lower_leg' : [{ 'BL' : 0, 'shock' : 4, 'shockWP' : 0, 'pain' : 5, 'painWP' : 1},{ 'KD' : 2, 'BL' : 0, 'shock' : 5, 'shockWP' : 0, 'pain' : 6, 'painWP' : 1},{ 'BL' : 0, 'shock' : 6, 'shockWP' : 0, 'pain' : 7, 'painWP' : 1},{ 'KD' : -3, 'BL' : 2, 'shock' : 8, 'shockWP' : 0, 'pain' : 9, 'painWP' : 1},{ 'KD' : -1, 'BL' : 5, 'shock' : 10, 'shockWP' : 0, 'pain' : 12, 'painWP' : 1}], 'knee_and_nearby_areas' : [{ 'BL' : 0, 'shock' : 5, 'shockWP' : 1, 'pain' : 4, 'painWP' : 1},{ 'BL' : 0, 'shock' : 4, 'shockWP' : 0, 'pain' : 5, 'painWP' : 1},{ 'KD' : 0, 'BL' : 2, 'shock' : 8, 'shockWP' : 0, 'pain' : 8, 'painWP' : 1},{ 'KD' : -5, 'BL' : 6, 'shock' : 10, 'shockWP' : 0, 'pain' : 0, 'painWP' : 0},{ 'KD' : -1, 'BL' : 8, 'shock' : 15, 'shockWP' : 0, 'pain' : 12, 'painWP' : 1}], 'thigh' : [{ 'BL' : 0, 'shock' : 4, 'shockWP' : 1, 'pain' : 4, 'painWP' : 1},{ 'KD' : 2, 'BL' : 0, 'shock' : 5, 'shockWP' : 0, 'pain' : 4, 'painWP' : 1},{ 'KD' : 0, 'BL' : 0, 'shock' : 7, 'shockWP' : 0, 'pain' : 7, 'painWP' : 1},{ 'KD' : -4, 'BL' : 3, 'shock' : 8, 'shockWP' : 0, 'pain' : 9, 'painWP' : 1},{ 'KD' : -1, 'BL' : 7, 'shock' : 10, 'shockWP' : 0, 'pain' : 12, 'painWP' : 1}], 'inner_thigh' : [{ 'BL' : 0, 'shock' : 4, 'shockWP' : 1, 'pain' : 4, 'painWP' : 1},{ 'KD' : 2, 'BL' : 0, 'shock' : 5, 'shockWP' : 0, 'pain' : 4, 'painWP' : 1},{ 'KD' : 0, 'BL' : 0, 'shock' : 7, 'shockWP' : 0, 'pain' : 7, 'painWP' : 1},{ 'KD' : -4, 'BL' : 3, 'shock' : 8, 'shockWP' : 0, 'pain' : 9, 'painWP' : 1},{ 'KD' : -1, 'BL' : 7, 'shock' : 10, 'shockWP' : 0, 'pain' : 12, 'painWP' : 1}], 'hip' : [{ 'BL' : 0, 'shock' : 3, 'shockWP' : 0, 'pain' : 4, 'painWP' : 1},{ 'BL' : 0, 'shock' : 5, 'shockWP' : 0, 'pain' : 6, 'painWP' : 1},{ 'KD' : -1, 'BL' : 2, 'shock' : 8, 'shockWP' : 0, 'pain' : 10, 'painWP' : 1},{ 'BL' : 10, 'shock' : 10, 'shockWP' : 0, 'pain' : 12, 'painWP' : 1},{ 'BL' : 20, 'shock' : -1, 'shockWP' : 0, 'pain' : 13, 'painWP' : 1, 'd' : 1}], 'groin' : [{ 'BL' : 0, 'shock' : 7, 'shockWP' : 0, 'pain' : 9, 'painWP' : 1},{ 'ko' : 0, 'BL' : 0, 'shock' : 9, 'shockWP' : 0, 'pain' : 10, 'painWP' : 1},{ 'ko' : -2, 'BL' : 3, 'shock' : 11, 'shockWP' : 0, 'pain' : 15, 'painWP' : 1},{ 'ko' : -1, 'BL' : 18, 'shock' : -1, 'shockWP' : 0, 'pain' : -1, 'painWP' : 0},{ 'BL' : 20, 'shock' : -1, 'shockWP' : 0, 'pain' : -1, 'painWP' : 0, 'd' : 2}], 'abdomen' : [{ 'BL' : 0, 'shock' : 3, 'shockWP' : 0, 'pain' : 5, 'painWP' : 1},{ 'ko' : 3, 'BL' : 0, 'shock' : 7, 'shockWP' : 0, 'pain' : 6, 'painWP' : 1},{ 'ko' : 0, 'BL' : 3, 'shock' : 10, 'shockWP' : 0, 'pain' : 8, 'painWP' : 1},{ 'BL' : 8, 'shock' : 10, 'shockWP' : 0, 'pain' : 12, 'painWP' : 1},{ 'ko' : -3, 'BL' : 15, 'shock' : -1, 'shockWP' : 0, 'pain' : 15, 'painWP' : 1}], 'ribcage' : [{ 'BL' : 0, 'shock' : 5, 'shockWP' : 1, 'pain' : 4, 'painWP' : 1},{ 'BL' : 0, 'shock' : 4, 'shockWP' : 0, 'pain' : 5, 'painWP' : 1},{ 'ko' : 2, 'BL' : 1, 'shock' : 8, 'shockWP' : 0, 'pain' : 6, 'painWP' : 1},{ 'ko' : 0, 'BL' : 3, 'shock' : 10, 'shockWP' : 0, 'pain' : 9, 'painWP' : 1},{ 'ko' : -3, 'BL' : 9, 'shock' : -1, 'shockWP' : 0, 'pain' : 15, 'painWP' : 1}], 'upper_abdomen' : [{ 'BL' : 0, 'shock' : 3, 'shockWP' : 0, 'pain' : 5, 'painWP' : 1},{ 'ko' : 3, 'BL' : 0, 'shock' : 7, 'shockWP' : 0, 'pain' : 6, 'painWP' : 1},{ 'ko' : 0, 'BL' : 3, 'shock' : 10, 'shockWP' : 0, 'pain' : 8, 'painWP' : 1},{ 'BL' : 8, 'shock' : 10, 'shockWP' : 0, 'pain' : 12, 'painWP' : 1},{ 'ko' : -3, 'BL' : 15, 'shock' : -1, 'shockWP' : 0, 'pain' : 15, 'painWP' : 1}], 'chest' : [{ 'BL' : 0, 'shock' : 5, 'shockWP' : 1, 'pain' : 4, 'painWP' : 1},{ 'BL' : 0, 'shock' : 4, 'shockWP' : 0, 'pain' : 5, 'painWP' : 1},{ 'ko' : 2, 'BL' : 1, 'shock' : 8, 'shockWP' : 0, 'pain' : 6, 'painWP' : 1},{ 'ko' : 0, 'BL' : 3, 'shock' : 10, 'shockWP' : 0, 'pain' : 9, 'painWP' : 1},{ 'ko' : 0, 'BL' : 9, 'shock' : -1, 'shockWP' : 0, 'pain' : 15, 'painWP' : 1}], 'upper_body' : [{ 'BL' : 0, 'shock' : 5, 'shockWP' : 1, 'pain' : 4, 'painWP' : 1},{ 'BL' : 0, 'shock' : 4, 'shockWP' : 0, 'pain' : 5, 'painWP' : 1},{ 'ko' : 2, 'BL' : 1, 'shock' : 8, 'shockWP' : 0, 'pain' : 6, 'painWP' : 1},{ 'ko' : 0, 'BL' : 3, 'shock' : 10, 'shockWP' : 0, 'pain' : 9, 'painWP' : 1},{ 'ko' : -3, 'BL' : 9, 'shock' : -1, 'shockWP' : 0, 'pain' : 15, 'painWP' : 1}], 'neck' : [{ 'BL' : 0, 'shock' : 4, 'shockWP' : 0, 'pain' : 5, 'painWP' : 1},{ 'BL' : 1, 'shock' : 7, 'shockWP' : 0, 'pain' : 9, 'painWP' : 1},{ 'ko' : 0, 'BL' : 3, 'shock' : 10, 'shockWP' : 0, 'pain' : 12, 'painWP' : 1},{ 'BL' : 3, 'shock' : -1, 'shockWP' : 0, 'pain' : 15, 'painWP' : 1},{ 'd' : 2, 'shock' : 0, 'shockWP' : 0, 'pain' : 0, 'painWP' : 0}], 'face' : [{ 'ko' : 3, 'BL' : 0, 'shock' : 5, 'shockWP' : 1, 'pain' : 0, 'painWP' : 0},{ 'ko' : 1, 'BL' : 1, 'shock' : 8, 'shockWP' : 0, 'pain' : 6, 'painWP' : 1},{ 'BL' : 4, 'shock' : 10, 'shockWP' : 0, 'pain' : 0, 'painWP' : 0},{ 'ko' : -3, 'BL' : 6, 'shock' : 12, 'shockWP' : 0, 'pain' : 9, 'painWP' : 1},{ 'd' : 2, 'shock' : 0, 'shockWP' : 0, 'pain' : 0, 'painWP' : 0}], 'lower_head' : [{ 'ko' : 3, 'BL' : 0, 'shock' : 5, 'shockWP' : 1, 'pain' : 0, 'painWP' : 0},{ 'ko' : 1, 'BL' : 1, 'shock' : 8, 'shockWP' : 0, 'pain' : 6, 'painWP' : 1},{ 'BL' : 4, 'shock' : 10, 'shockWP' : 0, 'pain' : 0, 'painWP' : 0},{ 'ko' : -3, 'BL' : 6, 'shock' : 12, 'shockWP' : 0, 'pain' : 9, 'painWP' : 1},{ 'd' : 2, 'shock' : 0, 'shockWP' : 0, 'pain' : 0, 'painWP' : 0}], 'upper_head' : [{ 'ko' : 2, 'BL' : 0, 'shock' : 8, 'shockWP' : 1, 'pain' : 5, 'painWP' : 1},{ 'ko' : 0, 'BL' : 3, 'shock' : 8, 'shockWP' : 0, 'pain' : 8, 'painWP' : 1},{ 'ko' : -3, 'BL' : 4, 'shock' : 10, 'shockWP' : 0, 'pain' : 12, 'painWP' : 1},{ 'BL' : 6, 'shock' : -1, 'shockWP' : 0, 'pain' : -1, 'painWP' : 0},{ 'd' : 2, 'shock' : 0, 'shockWP' : 0, 'pain' : 0, 'painWP' : 0}], 'upper_arm_and_shoulder' : [{ 'BL' : 0, 'shock' : 5, 'shockWP' : 1, 'pain' : 4, 'painWP' : 1},{ 'BL' : 0, 'shock' : 5, 'shockWP' : 0, 'pain' : 5, 'painWP' : 1},{ 'BL' : 1, 'shock' : 7, 'shockWP' : 0, 'pain' : 8, 'painWP' : 1},{ 'BL' : 5, 'shock' : 10, 'shockWP' : 0, 'pain' : 9, 'painWP' : 1},{ 'BL' : 10, 'shock' : 13, 'shockWP' : 0, 'pain' : 12, 'painWP' : 1}], 'hand' : [{ 'BL' : 0, 'shock' : 4, 'shockWP' : 1, 'pain' : 0, 'painWP' : 0},{ 'BL' : 0, 'shock' : 3, 'shockWP' : 0, 'pain' : 4, 'painWP' : 1},{ 'BL' : 0, 'shock' : 7, 'shockWP' : 1, 'pain' : 5, 'painWP' : 1},{ 'BL' : 1, 'shock' : 7, 'shockWP' : 0, 'pain' : 8, 'painWP' : 1},{ 'BL' : 3, 'shock' : 9, 'shockWP' : 0, 'pain' : 9, 'painWP' : 1}], 'forearm' : [{ 'BL' : 0, 'shock' : 4, 'shockWP' : 1, 'pain' : 0, 'painWP' : 0},{ 'BL' : 0, 'shock' : 3, 'shockWP' : 0, 'pain' : 4, 'painWP' : 1},{ 'BL' : 1, 'shock' : 5, 'shockWP' : 0, 'pain' : 6, 'painWP' : 1},{ 'BL' : 2, 'shock' : 8, 'shockWP' : 0, 'pain' : 8, 'painWP' : 1},{ 'BL' : 3, 'shock' : 10, 'shockWP' : 0, 'pain' : 10, 'painWP' : 1}], 'elbow' : [{ 'BL' : 0, 'shock' : 5, 'shockWP' : 1, 'pain' : 4, 'painWP' : 1},{ 'BL' : 0, 'shock' : 5, 'shockWP' : 0, 'pain' : 4, 'painWP' : 1},{ 'BL' : 0, 'shock' : 5, 'shockWP' : 0, 'pain' : 6, 'painWP' : 1},{ 'BL' : 1, 'shock' : 8, 'shockWP' : 0, 'pain' : 7, 'painWP' : 1},{ 'BL' : 3, 'shock' : 9, 'shockWP' : 0, 'pain' : 10, 'painWP' : 0}]};
	this.partsCut = { 'foot' : [{ 'BL' : 0, 'shock' : 3, 'shockWP' : 1, 'pain' : 2, 'painWP' : 1},{ 'BL' : 1, 'shock' : 3, 'shockWP' : 0, 'pain' : 3, 'painWP' : 1},{ 'KD' : 3, 'BL' : 2, 'shock' : 4, 'shockWP' : 0, 'pain' : 5, 'painWP' : 1},{ 'KD' : 1, 'BL' : 5, 'shock' : 6, 'shockWP' : 0, 'pain' : 6, 'painWP' : 1},{ 'KD' : 0, 'BL' : 10, 'shock' : 9, 'shockWP' : 0, 'pain' : 8, 'painWP' : 1}], 'shin_and_lower_leg' : [{ 'BL' : 0, 'shock' : 3, 'shockWP' : 0, 'pain' : 2, 'painWP' : 1},{ 'KD' : 2, 'BL' : 2, 'shock' : 5, 'shockWP' : 0, 'pain' : 6, 'painWP' : 1},{ 'BL' : 4, 'shock' : 5, 'shockWP' : 0, 'pain' : 6, 'painWP' : 1},{ 'KD' : -2, 'BL' : 8, 'shock' : 7, 'shockWP' : 0, 'pain' : 8, 'painWP' : 1},{ 'KD' : 0, 'BL' : 13, 'shock' : 9, 'shockWP' : 0, 'pain' : 10, 'painWP' : 1}], 'knee_and_nearby_areas' : [{ 'BL' : 0, 'shock' : 5, 'shockWP' : 1, 'pain' : 3, 'painWP' : 1},{ 'BL' : 2, 'shock' : 5, 'shockWP' : 0, 'pain' : 5, 'painWP' : 1},{ 'KD' : 0, 'BL' : 4, 'shock' : 8, 'shockWP' : 0, 'pain' : 8, 'painWP' : 1},{ 'KD' : -5, 'BL' : 8, 'shock' : 10, 'shockWP' : 0, 'pain' : 13, 'painWP' : 1},{ 'KD' : 0, 'BL' : 13, 'shock' : 12, 'shockWP' : 0, 'pain' : 12, 'painWP' : 1}], 'thigh' : [{ 'BL' : 1, 'shock' : 4, 'shockWP' : 1, 'pain' : 3, 'painWP' : 1},{ 'KD' : 2, 'BL' : 2, 'shock' : 2, 'shockWP' : 0, 'pain' : 4, 'painWP' : 1},{ 'KD' : 2, 'BL' : 4, 'shock' : 5, 'shockWP' : 0, 'pain' : 4, 'painWP' : 1},{ 'KD' : 2, 'BL' : 4, 'shock' : 5, 'shockWP' : 0, 'pain' : 4, 'painWP' : 1},{ 'KD' : 2, 'BL' : 4, 'shock' : 5, 'shockWP' : 0, 'pain' : 4, 'painWP' : 1}], 'inner_thigh' : [{ 'BL' : 0, 'shock' : 4, 'shockWP' : 1, 'pain' : 4, 'painWP' : 1},{ 'BL' : 6, 'shock' : 3, 'shockWP' : 0, 'pain' : 5, 'painWP' : 1},{ 'KD' : 0, 'BL' : 9, 'shock' : 5, 'shockWP' : 0, 'pain' : 16, 'painWP' : 1},{ 'BL' : 12, 'shock' : 7, 'shockWP' : 0, 'pain' : 8, 'painWP' : 1},{ 'BL' : 17, 'shock' : 7, 'shockWP' : 0, 'pain' : 10, 'painWP' : 1, 'd' : 2}], 'groin' : [{ 'BL' : 6, 'shock' : 9, 'shockWP' : 0, 'pain' : 9, 'painWP' : 1},{ 'BL' : 9, 'shock' : 9, 'shockWP' : 0, 'pain' : 10, 'painWP' : 1},{ 'BL' : 12, 'shock' : 10, 'shockWP' : 0, 'pain' : 12, 'painWP' : 1, 'd' : 1},{ 'BL' : 18, 'shock' : -1, 'shockWP' : 0, 'pain' : -1, 'painWP' : 0},{ 'BL' : 20, 'shock' : -1, 'shockWP' : 0, 'pain' : -1, 'painWP' : 0, 'd' : 2}], 'hip' : [{ 'BL' : 0, 'shock' : 4, 'shockWP' : 1, 'pain' : 3, 'painWP' : 1},{ 'BL' : 2, 'shock' : 3, 'shockWP' : 0, 'pain' : 5, 'painWP' : 1},{ 'KD' : 0, 'BL' : 4, 'shock' : 5, 'shockWP' : 0, 'pain' : 7, 'painWP' : 1},{ 'KD' : -2, 'BL' : 8, 'shock' : 8, 'shockWP' : 0, 'pain' : 10, 'painWP' : 1},{ 'KD' : -1, 'BL' : 12, 'shock' : 10, 'shockWP' : 0, 'pain' : 12, 'painWP' : 1}], 'abdomen' : [{ 'BL' : 1, 'shock' : 2, 'shockWP' : 0, 'pain' : 5, 'painWP' : 1},{ 'BL' : 3, 'shock' : 4, 'shockWP' : 0, 'pain' : 6, 'painWP' : 1},{ 'BL' : 7, 'shock' : 8, 'shockWP' : 0, 'pain' : 10, 'painWP' : 1},{ 'BL' : 10, 'shock' : 10, 'shockWP' : 0, 'pain' : 12, 'painWP' : 1},{ 'BL' : 20, 'shock' : -1, 'shockWP' : 0, 'pain' : -1, 'painWP' : 0}], 'ribcage' : [{ 'BL' : 0, 'shock' : 2, 'shockWP' : 0, 'pain' : 4, 'painWP' : 1},{ 'BL' : 2, 'shock' : 4, 'shockWP' : 0, 'pain' : 5, 'painWP' : 1},{ 'KD' : 0, 'BL' : 3, 'shock' : 8, 'shockWP' : 0, 'pain' : 7, 'painWP' : 1},{ 'BL' : 9, 'shock' : 10, 'shockWP' : 0, 'pain' : 12, 'painWP' : 1},{ 'BL' : 20, 'shock' : 0, 'shockWP' : 0, 'pain' : 0, 'painWP' : 0, 'd' : 2}], 'chest' : [{ 'BL' : 0, 'shock' : 2, 'shockWP' : 0, 'pain' : 4, 'painWP' : 1},{ 'BL' : 2, 'shock' : 4, 'shockWP' : 0, 'pain' : 5, 'painWP' : 1},{ 'KD' : 0, 'BL' : 3, 'shock' : 8, 'shockWP' : 0, 'pain' : 7, 'painWP' : 1},{ 'BL' : 9, 'shock' : 10, 'shockWP' : 0, 'pain' : 12, 'painWP' : 1},{ 'BL' : 20, 'shock' : 0, 'shockWP' : 0, 'pain' : 0, 'painWP' : 0, 'd' : 2}], 'upper_arm_and_shoulder' : [{ 'BL' : 0, 'shock' : 4, 'shockWP' : 1, 'pain' : 4, 'painWP' : 1},{ 'BL' : 2, 'shock' : 4, 'shockWP' : 0, 'pain' : 5, 'painWP' : 1},{ 'BL' : 4, 'shock' : 5, 'shockWP' : 0, 'pain' : 8, 'painWP' : 1},{ 'BL' : 8, 'shock' : 8, 'shockWP' : 0, 'pain' : 10, 'painWP' : 1},{ 'BL' : 12, 'shock' : 13, 'shockWP' : 0, 'pain' : 14, 'painWP' : 1}], 'shoulder' : [{ 'BL' : 1, 'shock' : 4, 'shockWP' : 1, 'pain' : 4, 'painWP' : 1},{ 'BL' : 2, 'shock' : 4, 'shockWP' : 0, 'pain' : 5, 'painWP' : 1},{ 'BL' : 5, 'shock' : 6, 'shockWP' : 0, 'pain' : 7, 'painWP' : 1},{ 'BL' : 10, 'shock' : 8, 'shockWP' : 0, 'pain' : 10, 'painWP' : 1},{ 'BL' : 25, 'shock' : 10, 'shockWP' : 0, 'pain' : 11, 'painWP' : 1}], 'neck' : [{ 'BL' : 1, 'shock' : 4, 'shockWP' : 0, 'pain' : 5, 'painWP' : 1},{ 'BL' : 4, 'shock' : 7, 'shockWP' : 0, 'pain' : 10, 'painWP' : 1},{ 'BL' : 9, 'shock' : 10, 'shockWP' : 0, 'pain' : 11, 'painWP' : 1},{ 'BL' : 20, 'shock' : 13, 'shockWP' : 0, 'pain' : 14, 'painWP' : 1},{ 'd' : 2, 'shock' : 0, 'shockWP' : 0, 'pain' : 0, 'painWP' : 0}], 'face' : [{ 'BL' : 0, 'shock' : 5, 'shockWP' : 1, 'pain' : 0, 'painWP' : 0},{ 'BL' : 2, 'shock' : 8, 'shockWP' : 0, 'pain' : 5, 'painWP' : 1},{ 'BL' : 5, 'shock' : 1, 'shockWP' : 1, 'pain' : 7, 'painWP' : 1},{ 'BL' : 7, 'shock' : 10, 'shockWP' : 0, 'pain' : 10, 'painWP' : 1},{ 'd' : 2, 'shock' : 0, 'shockWP' : 0, 'pain' : 0, 'painWP' : 0}], 'lower_head' : [{ 'BL' : 0, 'shock' : 5, 'shockWP' : 1, 'pain' : 0, 'painWP' : 0},{ 'BL' : 2, 'shock' : 8, 'shockWP' : 0, 'pain' : 5, 'painWP' : 1},{ 'BL' : 5, 'shock' : 1, 'shockWP' : 1, 'pain' : 7, 'painWP' : 1},{ 'BL' : 7, 'shock' : 10, 'shockWP' : 0, 'pain' : 10, 'painWP' : 1},{ 'd' : 2, 'shock' : 0, 'shockWP' : 0, 'pain' : 0, 'painWP' : 0}], 'upper_head' : [{ 'BL' : 3, 'shock' : 3, 'shockWP' : 0, 'pain' : 4, 'painWP' : 1},{ 'BL' : 3, 'shock' : 7, 'shockWP' : 0, 'pain' : 8, 'painWP' : 1},{ 'BL' : 4, 'shock' : 10, 'shockWP' : 0, 'pain' : 12, 'painWP' : 1},{ 'ko' : 0, 'BL' : 10, 'shock' : -1, 'shockWP' : 0, 'pain' : -1, 'painWP' : 0},{ 'd' : 2, 'shock' : 0, 'shockWP' : 0, 'pain' : 0, 'painWP' : 0}], 'hand' : [{ 'BL' : 0, 'shock' : 7, 'shockWP' : 1, 'pain' : 4, 'painWP' : 1},{ 'BL' : 2, 'shock' : 0, 'shockWP' : 0, 'pain' : 4, 'painWP' : 1},{ 'BL' : 6, 'shock' : 9, 'shockWP' : 1, 'pain' : 6, 'painWP' : 1},{ 'BL' : 8, 'shock' : 8, 'shockWP' : 0, 'pain' : 9, 'painWP' : 1},{ 'BL' : 10, 'shock' : 10, 'shockWP' : 0, 'pain' : 11, 'painWP' : 1, 'd' : 1}], 'forearm' : [{ 'BL' : 0, 'shock' : 4, 'shockWP' : 1, 'pain' : 4, 'painWP' : 1},{ 'BL' : 3, 'shock' : 5, 'shockWP' : 0, 'pain' : 7, 'painWP' : 1},{ 'BL' : 4, 'shock' : 5, 'shockWP' : 0, 'pain' : 7, 'painWP' : 1},{ 'BL' : 6, 'shock' : 8, 'shockWP' : 0, 'pain' : 8, 'painWP' : 1},{ 'BL' : 12, 'shock' : 10, 'shockWP' : 0, 'pain' : 12, 'painWP' : 1, 'd' : 1}], 'elbow' : [{ 'BL' : 0, 'shock' : 5, 'shockWP' : 1, 'pain' : 4, 'painWP' : 1},{ 'BL' : 0, 'shock' : 4, 'shockWP' : 0, 'pain' : 5, 'painWP' : 1},{ 'BL' : 3, 'shock' : 6, 'shockWP' : 0, 'pain' : 6, 'painWP' : 1},{ 'BL' : 6, 'shock' : 8, 'shockWP' : 0, 'pain' : 9, 'painWP' : 1},{ 'BL' : 12, 'shock' : 10, 'shockWP' : 0, 'pain' : 10, 'painWP' : 1}]};
	this.partsPuncture = { 'foot' : [{ 'BL' : 0, 'shock' : 4, 'shockWP' : 1, 'pain' : 4, 'painWP' : 1},{ 'BL' : 0, 'shock' : 3, 'shockWP' : 0, 'pain' : 5, 'painWP' : 1},{ 'KD' : 3, 'BL' : 2, 'shock' : 4, 'shockWP' : 0, 'pain' : 6, 'painWP' : 1},{ 'KD' : -1, 'BL' : 3, 'shock' : 7, 'shockWP' : 0, 'pain' : 7, 'painWP' : 1},{ 'KD' : -1, 'BL' : 3, 'shock' : 7, 'shockWP' : 0, 'pain' : 7, 'painWP' : 1}], 'shin_and_lower_leg' : [{ 'BL' : 0, 'shock' : 4, 'shockWP' : 0, 'pain' : 4, 'painWP' : 1},{ 'KD' : 2, 'BL' : 1, 'shock' : 5, 'shockWP' : 0, 'pain' : 6, 'painWP' : 1},{ 'BL' : 2, 'shock' : 5, 'shockWP' : 0, 'pain' : 6, 'painWP' : 1},{ 'KD' : -2, 'BL' : 2, 'shock' : 5, 'shockWP' : 0, 'pain' : 6, 'painWP' : 1},{ 'KD' : 0, 'BL' : 4, 'shock' : 7, 'shockWP' : 0, 'pain' : 8, 'painWP' : 1}], 'knee_and_nearby_areas' : [{ 'BL' : 0, 'shock' : 5, 'shockWP' : 1, 'pain' : 5, 'painWP' : 1},{ 'BL' : 0, 'shock' : 4, 'shockWP' : 0, 'pain' : 5, 'painWP' : 1},{ 'KD' : 0, 'BL' : 3, 'shock' : 6, 'shockWP' : 0, 'pain' : 6, 'painWP' : 1},{ 'KD' : -2, 'BL' : 4, 'shock' : 7, 'shockWP' : 0, 'pain' : 8, 'painWP' : 1},{ 'KD' : -5, 'BL' : 6, 'shock' : 9, 'shockWP' : 0, 'pain' : 11, 'painWP' : 1}], 'thigh' : [{ 'BL' : 0, 'shock' : 4, 'shockWP' : 1, 'pain' : 4, 'painWP' : 1},{ 'KD' : 2, 'BL' : 1, 'shock' : 3, 'shockWP' : 0, 'pain' : 4, 'painWP' : 1},{ 'KD' : 0, 'BL' : 2, 'shock' : 5, 'shockWP' : 0, 'pain' : 5, 'painWP' : 1},{ 'KD' : -2, 'BL' : 4, 'shock' : 5, 'shockWP' : 0, 'pain' : 6, 'painWP' : 1},{ 'BL' : 8, 'shock' : 5, 'shockWP' : 0, 'pain' : 7, 'painWP' : 1}], 'groin' : [{ 'BL' : 6, 'shock' : 7, 'shockWP' : 0, 'pain' : 9, 'painWP' : 1},{ 'BL' : 8, 'shock' : 8, 'shockWP' : 0, 'pain' : 10, 'painWP' : 1},{ 'BL' : 10, 'shock' : 10, 'shockWP' : 0, 'pain' : 15, 'painWP' : 1},{ 'shock' : -1, 'shockWP' : 0, 'pain' : -1, 'painWP' : 0},{ 'BL' : 15, 'shock' : -1, 'shockWP' : 0, 'pain' : -1, 'painWP' : 0}], 'hip' : [{ 'BL' : 0, 'shock' : 4, 'shockWP' : 1, 'pain' : 4, 'painWP' : 1},{ 'BL' : 1, 'shock' : 3, 'shockWP' : 0, 'pain' : 5, 'painWP' : 1},{ 'BL' : 3, 'shock' : 5, 'shockWP' : 0, 'pain' : 9, 'painWP' : 1},{ 'KD' : -2, 'BL' : 6, 'shock' : 8, 'shockWP' : 0, 'pain' : 10, 'painWP' : 1},{ 'KD' : 0, 'BL' : 10, 'shock' : 10, 'shockWP' : 0, 'pain' : 12, 'painWP' : 1}], 'flesh_to_the_side' : [{ 'lev' : 1, 'BL' : 3, 'shock' : 5, 'shockWP' : 0, 'pain' : 6, 'painWP' : 1},{ 'lev' : 1, 'BL' : 3, 'shock' : 5, 'shockWP' : 0, 'pain' : 6, 'painWP' : 1},{ 'lev' : 1, 'BL' : 3, 'shock' : 5, 'shockWP' : 0, 'pain' : 6, 'painWP' : 1},{ 'lev' : 1, 'BL' : 3, 'shock' : 5, 'shockWP' : 0, 'pain' : 6, 'painWP' : 1},{ 'lev' : 1, 'BL' : 3, 'shock' : 5, 'shockWP' : 0, 'pain' : 6, 'painWP' : 1}], 'lower_abdomen' : [{ 'BL' : 0, 'shock' : 3, 'shockWP' : 0, 'pain' : 4, 'painWP' : 1},{ 'BL' : 6, 'shock' : 4, 'shockWP' : 0, 'pain' : 6, 'painWP' : 1},{ 'BL' : 8, 'shock' : 7, 'shockWP' : 0, 'pain' : 9, 'painWP' : 1},{ 'shock' : 10, 'shockWP' : 0, 'pain' : 12, 'painWP' : 1},{ 'BL' : 18, 'shock' : -1, 'shockWP' : 0, 'pain' : -1, 'painWP' : 0}], 'upper_abdomen' : [{ 'BL' : 0, 'shock' : 3, 'shockWP' : 0, 'pain' : 4, 'painWP' : 1},{ 'BL' : 8, 'shock' : 5, 'shockWP' : 0, 'pain' : 6, 'painWP' : 1},{ 'BL' : 10, 'shock' : 8, 'shockWP' : 0, 'pain' : 10, 'painWP' : 1},{ 'BL' : 13, 'shock' : 13, 'shockWP' : 0, 'pain' : 15, 'painWP' : 1},{ 'BL' : 19, 'shock' : -1, 'shockWP' : 0, 'pain' : -1, 'painWP' : 0}], 'chest' : [{ 'BL' : 0, 'shock' : 9, 'shockWP' : 1, 'pain' : 5, 'painWP' : 1},{ 'BL' : 4, 'shock' : 4, 'shockWP' : 0, 'pain' : 6, 'painWP' : 1},{ 'BL' : 8, 'shock' : 7, 'shockWP' : 0, 'pain' : 8, 'painWP' : 1},{ 'BL' : 19, 'shock' : 13, 'shockWP' : 0, 'pain' : 13, 'painWP' : 1, 'd' : 2},{ 'd' : 2, 'shock' : 0, 'shockWP' : 0, 'pain' : 0, 'painWP' : 0}], 'collar_and_throat' : [{ 'BL' : 2, 'shock' : 4, 'shockWP' : 0, 'pain' : 5, 'painWP' : 1},{ 'BL' : 6, 'shock' : 7, 'shockWP' : 0, 'pain' : 6, 'painWP' : 1},{ 'shock' : 13, 'shockWP' : 0, 'pain' : 15, 'painWP' : 1},{ 'BL' : 15, 'shock' : -1, 'shockWP' : 0, 'pain' : 20, 'painWP' : 1},{ 'd' : 2, 'shock' : 0, 'shockWP' : 0, 'pain' : 0, 'painWP' : 0}], 'face' : [{ 'BL' : 1, 'shock' : 7, 'shockWP' : 1, 'pain' : 4, 'painWP' : 1},{ 'BL' : 2, 'shock' : 6, 'shockWP' : 0, 'pain' : 6, 'painWP' : 1},{ 'ko' : -3, 'BL' : 8, 'shock' : 10, 'shockWP' : 0, 'pain' : 9, 'painWP' : 1},{ 'ko' : 0, 'BL' : 19, 'shock' : 13, 'shockWP' : 0, 'pain' : 13, 'painWP' : 0},{ 'd' : 2, 'shock' : 0, 'shockWP' : 0, 'pain' : 0, 'painWP' : 0}], 'head' : [{ 'BL' : 1, 'shock' : 7, 'shockWP' : 1, 'pain' : 4, 'painWP' : 1},{ 'BL' : 2, 'shock' : 6, 'shockWP' : 0, 'pain' : 6, 'painWP' : 1},{ 'ko' : -3, 'BL' : 8, 'shock' : 10, 'shockWP' : 0, 'pain' : 9, 'painWP' : 1},{ 'ko' : 0, 'BL' : 19, 'shock' : 13, 'shockWP' : 0, 'pain' : 13, 'painWP' : 0},{ 'd' : 2, 'shock' : 0, 'shockWP' : 0, 'pain' : 0, 'painWP' : 0}], 'hand' : [{ 'BL' : 0, 'shock' : 6, 'shockWP' : 1, 'pain' : 5, 'painWP' : 1},{ 'BL' : 0, 'shock' : 3, 'shockWP' : 0, 'pain' : 4, 'painWP' : 1},{ 'BL' : 2, 'shock' : 9, 'shockWP' : 1, 'pain' : 6, 'painWP' : 1},{ 'BL' : 5, 'shock' : 7, 'shockWP' : 0, 'pain' : 9, 'painWP' : 1},{ 'BL' : 9, 'shock' : 8, 'shockWP' : 0, 'pain' : 9, 'painWP' : 1}], 'forearm' : [{ 'shock' : 5, 'shockWP' : 1, 'pain' : 4, 'painWP' : 1},{ 'BL' : 1, 'shock' : 5, 'shockWP' : 0, 'pain' : 6, 'painWP' : 1},{ 'BL' : 2, 'shock' : 5, 'shockWP' : 0, 'pain' : 6, 'painWP' : 1},{ 'BL' : 6, 'shock' : 7, 'shockWP' : 0, 'pain' : 8, 'painWP' : 1},{ 'BL' : 7, 'shock' : 8, 'shockWP' : 0, 'pain' : 9, 'painWP' : 1}], 'elbow' : [{ 'BL' : 0, 'shock' : 6, 'shockWP' : 1, 'pain' : 5, 'painWP' : 1},{ 'BL' : 0, 'shock' : 4, 'shockWP' : 0, 'pain' : 6, 'painWP' : 1},{ 'BL' : 3, 'shock' : 6, 'shockWP' : 0, 'pain' : 7, 'painWP' : 1},{ 'BL' : 5, 'shock' : 8, 'shockWP' : 0, 'pain' : 9, 'painWP' : 1},{ 'BL' : 7, 'shock' : 9, 'shockWP' : 0, 'pain' : 11, 'painWP' : 1}], 'upper_arm' : [{ 'BL' : 0, 'shock' : 4, 'shockWP' : 1, 'pain' : 4, 'painWP' : 1},{ 'BL' : 1, 'shock' : 3, 'shockWP' : 0, 'pain' : 5, 'painWP' : 1},{ 'BL' : 3, 'shock' : 5, 'shockWP' : 0, 'pain' : 6, 'painWP' : 1},{ 'BL' : 5, 'shock' : 6, 'shockWP' : 0, 'pain' : 7, 'painWP' : 1},{ 'BL' : 7, 'shock' : 7, 'shockWP' : 0, 'pain' : 8, 'painWP' : 1}]};
	this.thrustStartIndex = 8;
	this.zones[1] = troshx_ZoneBody.create("to the Lower Legs",[1,3,2],["foot","shin_and_lower_leg","knee_and_nearby_areas"]);
	this.zones[2] = troshx_ZoneBody.create("to the Upper Legs",[2,3,1],["knee_and_nearby_areas","thigh","hip"]);
	this.zones[3] = troshx_ZoneBody.create("for Horizontal Swing",[1,1,1,2,1],["hip","upper_abdomen","lower_abdomen","ribcage","arms"]);
	this.zones[4] = troshx_ZoneBody.create("for Overhand Swing",[2,1,1,1,1],["upper_arm_and_shoulder","chest","neck","lower_head","upper_head"]);
	this.zones[5] = troshx_ZoneBody.create("for Downward Swing from Above",[3,1,2],["upper_head","lower_head","shoulder"]);
	this.zones[6] = troshx_ZoneBody.create("for Upward Swing from Below",[3,1,1,1],["inner_thigh","groin","abdomen","chest"]);
	this.zones[7] = troshx_ZoneBody.create("to the Arms",[1,2,1,2],["hand","forearm","elbow","upper_arm_and_shoulder"]);
	this.zones[8] = troshx_ZoneBody.create("to the Lower Legs",[1,3,1,1],["foot","shin_and_lower_leg","knee_and_nearby_areas",""]);
	this.zones[9] = troshx_ZoneBody.create("to the Upper Legs",[2,3,1],["knee_and_nearby_areas","thigh","hip"]);
	this.zones[10] = troshx_ZoneBody.create("to the Pelvis",[2,2,2],["hip","groin","lower_abdomen"]);
	this.zones[11] = troshx_ZoneBody.create("to the Belly",[5,1],["lower_abdomen","flesh_to_the_side"]);
	this.zones[12] = troshx_ZoneBody.create("to the Chest",[2,4],["upper_abdomen","chest"]);
	this.zones[13] = troshx_ZoneBody.create("to the Head",[2,4],["collar_and_throat",["face","face","face","head","head"]]);
	this.zones[14] = troshx_ZoneBody.create("to the Arm",[1,2,1,2],["hand","forearm","elbow","upper_arm"]);
	this.zonesB[1] = troshx_ZoneBody.create("to the Lower Legs",[1,3,2],["foot","shin_and_lower_leg","knee_and_nearby_areas"]);
	this.zonesB[2] = troshx_ZoneBody.create("to the Upper Legs",[2,3,1],["knee_and_nearby_areas","thigh","hip"]);
	this.zonesB[3] = troshx_ZoneBody.create("for Horizontal Swing",[1,1,1,2,1],["hip","upper_abdomen","lower_abdomen","ribcage","arms"]);
	this.zonesB[4] = troshx_ZoneBody.create("for Overhand Swing",[2,1,1,1,1],["upper_arm_and_shoulder","upper_body","neck","lower_head","upper_head"]);
	this.zonesB[5] = troshx_ZoneBody.create("for Downward Swing from Above",[2,1,3],["shoulder","lower_head","upper_head"]);
	this.zonesB[6] = troshx_ZoneBody.create("for Upward Swing from Below",[3,1,1,1],["inner_thigh","groin","abdomen","lower_head"]);
	this.zonesB[7] = troshx_ZoneBody.create("to the Arms",[1,2,1,2],["hand","forearm","elbow","upper_arm_and_shoulder"]);
	this.zonesB[8] = troshx_ZoneBody.create("to the Lower Legs",[1,3,1,1],["foot","shin_and_lower_leg","knee_and_nearby_areas",""]);
	this.zonesB[9] = troshx_ZoneBody.create("to the Upper Legs",[2,3,1],["knee_and_nearby_areas","thigh","hip"]);
	this.zonesB[10] = troshx_ZoneBody.create("to the Pelvis",[2,2,2],["hip","groin","lower_abdomen"]);
	this.zonesB[11] = troshx_ZoneBody.create("to the Belly",[6],["lower_abdomen"]);
	this.zonesB[12] = troshx_ZoneBody.create("to the Chest",[2,4],["upper_abdomen","chest"]);
	this.zonesB[13] = troshx_ZoneBody.create("to the Head",[1,3,2],["neck",["face","face","face","lower_head","lower_head"],"upper_head"]);
	this.zonesB[14] = troshx_ZoneBody.create("to the Arm",[1,2,1,2],["hand","forearm","elbow","upper_arm_and_shoulder"]);
	this.partsBludgeon.lower_abdomen = this.partsBludgeon.abdomen;
	this.partsBludgeon.arms = this.partsBludgeon.upper_arm_and_shoulder;
	this.partsBludgeon.shoulder = this.partsBludgeon.upper_arm_and_shoulder;
	this.partsCut.lower_abdomen = this.partsCut.abdomen;
	this.partsCut.upper_abdomen = this.partsCut.abdomen;
	this.partsCut.arms = this.partsCut.upper_arm_and_shoulder;
	this.centerOfMass = troshx_tros_HumanoidBody.CENTER_OF_MASS;
	this.centerOfMassT = troshx_tros_HumanoidBody.CENTER_OF_MASS_T;
};
$hxClasses["troshx.tros.HumanoidBody"] = troshx_tros_HumanoidBody;
troshx_tros_HumanoidBody.__name__ = ["troshx","tros","HumanoidBody"];
troshx_tros_HumanoidBody.getInstance = function() {
	if(troshx_tros_HumanoidBody.INSTANCE != null) return troshx_tros_HumanoidBody.INSTANCE; else return troshx_tros_HumanoidBody.INSTANCE = new troshx_tros_HumanoidBody();
};
troshx_tros_HumanoidBody.__super__ = troshx_BodyChar;
troshx_tros_HumanoidBody.prototype = $extend(troshx_BodyChar.prototype,{
	__class__: troshx_tros_HumanoidBody
});
var troshx_tros_Manuever = $hx_exports.troshx.tros.Manuever = function(id,name,cost) {
	if(cost == null) cost = 0;
	this.id = id;
	this.name = name;
	this.cost = cost;
	this.usingHands = 0;
	this.defaultTN = 0;
	this.customRange = 0;
	this.customMinRange = 0;
	this.stanceModifier = 2;
	this.attackTypes = 1 | 2;
	this.damageType = 0;
	this.requiredLevel = 0;
	this.spamPenalty = 0;
	this.spamIndividualOnly = false;
	this.regionMask = 0;
	this.offHanded = false;
	this.evasive = false;
	this.manueverType = 0;
};
$hxClasses["troshx.tros.Manuever"] = troshx_tros_Manuever;
troshx_tros_Manuever.__name__ = ["troshx","tros","Manuever"];
troshx_tros_Manuever.isThrustingMotion = function(targetzone,toBody) {
	return targetzone >= toBody.thrustStartIndex;
};
troshx_tros_Manuever.prototype = {
	id: null
	,name: null
	,cost: null
	,attackTypes: null
	,damageType: null
	,defaultTN: null
	,customRange: null
	,customMinRange: null
	,requiredLevel: null
	,spamPenalty: null
	,spamIndividualOnly: null
	,regionMask: null
	,offHanded: null
	,stanceModifier: null
	,evasive: null
	,usingHands: null
	,manueverType: null
	,__class__: troshx_tros_Manuever
};
var troshx_tros_Weapon = $hx_exports.troshx.tros.Weapon = function(name,profGroups) {
	this.name = name;
	this.profeciencies = profGroups;
	this.attrBaseIndex = 0;
	this.drawCutModifier = 0;
	this.damage = 0;
	this.damage2 = 0;
	this.damage3 = 0;
	this.atn = 0;
	this.atn2 = 0;
	this.dtn = 0;
	this.dtn2 = 0;
	this.twoHanded = false;
	this.rangedWeapon = false;
	this.shield = false;
	this.shieldLimit = 0;
	this.cpPenalty = 0;
	this.movePenalty = 0;
	this.blunt = false;
	this.hooking = 0;
};
$hxClasses["troshx.tros.Weapon"] = troshx_tros_Weapon;
troshx_tros_Weapon.__name__ = ["troshx","tros","Weapon"];
troshx_tros_Weapon.createDyn = function(name,profGroups,properties) {
	var weap = new troshx_tros_Weapon(name,profGroups);
	var _g = 0;
	var _g1 = Reflect.fields(properties);
	while(_g < _g1.length) {
		var p = _g1[_g];
		++_g;
		Reflect.setField(weap,p,Reflect.field(properties,p));
	}
	return weap;
};
troshx_tros_Weapon.prototype = {
	atn: null
	,atn2: null
	,dtn: null
	,dntT: null
	,dtn2: null
	,damage: null
	,damage2: null
	,damage3: null
	,shield: null
	,profeciencies: null
	,name: null
	,drawCutModifier: null
	,attrBaseIndex: null
	,twoHanded: null
	,rangedWeapon: null
	,cpPenalty: null
	,movePenalty: null
	,shieldLimit: null
	,blunt: null
	,range: null
	,hooking: null
	,getDamageTo: function(body,manuever,targetZone,margin,strength) {
		var dmg;
		if(this.damage3 != 0 && (this.blunt || manuever.damageType == 3)) dmg = this.damage3; else if(targetZone >= body.thrustStartIndex) dmg = this.damage2; else dmg = this.damage;
		dmg += margin;
		if(this.attrBaseIndex == 0) dmg += strength;
		return dmg;
	}
	,getHookingATN: function(tieBiasToThrust) {
		if(tieBiasToThrust == null) tieBiasToThrust = false;
		var strikeATN;
		if((this.hooking & 1) != 0) strikeATN = this.atn; else strikeATN = 0;
		var thrustATN;
		if((this.hooking & 2) != 0) thrustATN = this.atn2; else thrustATN = 0;
		if(strikeATN != 0 && thrustATN != 0) {
			if(!tieBiasToThrust) {
				if(thrustATN < strikeATN) return -thrustATN; else return strikeATN;
			} else if(strikeATN < thrustATN) return strikeATN; else return -thrustATN;
		} else if(strikeATN == 0) return -thrustATN; else return strikeATN;
	}
	,getHookingATNType: function(tieBiasToThrust) {
		if(tieBiasToThrust == null) tieBiasToThrust = false;
		var strikeATN;
		if((this.hooking & 1) != 0) strikeATN = this.atn; else strikeATN = 0;
		var thrustATN;
		if((this.hooking & 2) != 0) thrustATN = this.atn2; else thrustATN = 0;
		if(strikeATN != 0 && thrustATN != 0) {
			if(!tieBiasToThrust) {
				if(thrustATN < strikeATN) return -thrustATN; else return strikeATN;
			} else if(strikeATN < thrustATN) return strikeATN; else return -thrustATN;
		} else if(strikeATN == 0) return -thrustATN; else return strikeATN;
	}
	,__class__: troshx_tros_Weapon
};
var troshx_tros_WeaponSheet = $hx_exports.troshx.tros.WeaponSheet = function() {
};
$hxClasses["troshx.tros.WeaponSheet"] = troshx_tros_WeaponSheet;
troshx_tros_WeaponSheet.__name__ = ["troshx","tros","WeaponSheet"];
troshx_tros_WeaponSheet.getWeaponByName = function(name) {
	return troshx_tros_WeaponSheet.HASH.get(name);
};
troshx_tros_WeaponSheet.weaponNameIsShield = function(name) {
	var weap = troshx_tros_WeaponSheet.getWeaponByName(name);
	if(weap != null) return weap.shield; else return false;
};
troshx_tros_WeaponSheet.weaponIsShield = function(weapon) {
	return weapon.shield;
};
troshx_tros_WeaponSheet.createHashLookupViaName = function(arr) {
	var obj = new haxe_ds_StringMap();
	var _g1 = 0;
	var _g = arr.length;
	while(_g1 < _g) {
		var i = _g1++;
		var lookinFor = arr[i];
		obj.set(lookinFor.name,lookinFor);
	}
	return obj;
};
troshx_tros_WeaponSheet.prototype = {
	__class__: troshx_tros_WeaponSheet
};
var troshx_util_AIManueverChoice = $hx_exports.troshx.util.AIManueverChoice = function() {
};
$hxClasses["troshx.util.AIManueverChoice"] = troshx_util_AIManueverChoice;
troshx_util_AIManueverChoice.__name__ = ["troshx","util","AIManueverChoice"];
troshx_util_AIManueverChoice.prototype = {
	manuever: null
	,manueverCP: null
	,manueverTN: null
	,targetZone: null
	,manueverType: null
	,offhand: null
	,againstID: null
	,cost: null
	,getManueverCPSpent: function() {
		return this.cost + this.manueverCP;
	}
	,secondary: null
	,nothing: function() {
		this.manuever = "";
		this.manueverCP = 0;
		this.targetZone = 0;
		this.manueverType = 0;
		this.offhand = false;
		this.againstID = 0;
		this.secondary = null;
	}
	,setupSecondAttack: function(manuever,manueverCP,manueverTN,targetZone,cost,offhand) {
		if(offhand == null) offhand = false;
		if(this.secondary == null) this.secondary = new troshx_util_AIManueverChoice();
		this.secondary.setAttack(manuever,manueverCP,manueverTN,targetZone,cost,offhand);
	}
	,setupSecondDefend: function(manuever,manueverCP,manueverTN,targetZone,cost,offhand) {
		if(offhand == null) offhand = false;
		if(this.secondary == null) this.secondary = new troshx_util_AIManueverChoice();
		this.secondary.setDefend(manuever,manueverCP,manueverTN,cost,offhand);
	}
	,copyTo: function(newChoice,newAgainstID) {
		if(newAgainstID == null) newAgainstID = -1;
		newChoice.manuever = this.manuever;
		newChoice.manueverCP = this.manueverCP;
		newChoice.targetZone = this.targetZone;
		newChoice.manueverType = this.manueverType;
		newChoice.offhand = this.offhand;
		newChoice.manueverTN = this.manueverTN;
		if(newAgainstID >= 0) newChoice.againstID = newAgainstID; else newChoice.againstID = this.againstID;
	}
	,setAttack: function(manuever,manueverCP,manueverTN,targetZone,cost,offhand) {
		if(offhand == null) offhand = false;
		this.manuever = manuever;
		this.manueverCP = manueverCP;
		this.targetZone = targetZone;
		this.offhand = offhand;
		this.manueverType = 2;
		this.manueverTN = manueverTN;
		this.cost = cost;
		this.secondary = null;
	}
	,setDefend: function(manuever,manueverCP,manueverTN,cost,offhand) {
		if(offhand == null) offhand = false;
		this.manuever = manuever;
		this.manueverCP = manueverCP;
		this.targetZone = 0;
		this.offhand = offhand;
		this.manueverType = 1;
		this.manueverTN = manueverTN;
		this.cost = cost;
		this.secondary = null;
	}
	,__class__: troshx_util_AIManueverChoice
};
var troshx_tros_ai_TROSAiBot = $hx_exports.troshx.tros.ai.TROSAiBot = function() {
	this.decidedManuevers = [new troshx_util_AIManueverChoice(),new troshx_util_AIManueverChoice(),new troshx_util_AIManueverChoice(),new troshx_util_AIManueverChoice()];
	this.handsUsedUp = 0;
	this.manueverUsingHands = 0;
	this.mobility = 6;
	this.perception = 4;
	this.currentExchange = 0;
	this.plannedCombos = [0,0,0,0];
	this.cpBudget = [];
	this.opponentLen = 0;
	this.opponents = [];
};
$hxClasses["troshx.tros.ai.TROSAiBot"] = troshx_tros_ai_TROSAiBot;
troshx_tros_ai_TROSAiBot.__name__ = ["troshx","tros","ai","TROSAiBot"];
troshx_tros_ai_TROSAiBot.getTargetAlphaStrikeCPThreshold = function() {
	return troshx_tros_ai_TROSAiBot.ENEMY_STEAL_COST + 1 + troshx_tros_ai_TROSAiBot.MIN_EXPOSED_AV;
};
troshx_tros_ai_TROSAiBot.setAlphaStrikeBudget = function(cp,cp2) {
	var minCP = troshx_tros_ai_TROSAiBot.ENEMY_STEAL_COST + 1 + troshx_tros_ai_TROSAiBot.MIN_EXPOSED_AV - 1;
	if(cp2 > minCP) minCP = cp2 - minCP; else minCP = 0;
	troshx_tros_ai_TROSAiBot.B_COMBO_EXCHANGE_BUDGET[0] = cp - minCP;
	troshx_tros_ai_TROSAiBot.B_COMBO_EXCHANGE_BUDGET[3] = cp2;
	troshx_tros_ai_TROSAiBot.B_COMBO_EXCHANGE_BUDGET[2] = minCP;
	troshx_tros_ai_TROSAiBot.B_COMBO_EXCHANGE_BUDGET[3] = -1;
};
troshx_tros_ai_TROSAiBot.setTypicalAVAILCostsForTesting = function() {
	troshx_tros_ai_TROSAiBot.AVAIL_bash = 1;
	troshx_tros_ai_TROSAiBot.AVAIL_spike = 0;
	troshx_tros_ai_TROSAiBot.AVAIL_cut = 1;
	troshx_tros_ai_TROSAiBot.AVAIL_thrust = 1;
	troshx_tros_ai_TROSAiBot.AVAIL_beat = 1;
	troshx_tros_ai_TROSAiBot.AVAIL_bindstrike = 1;
	troshx_tros_ai_TROSAiBot.AVAIL_hook = 2;
	troshx_tros_ai_TROSAiBot.AVAIL_block = 1;
	troshx_tros_ai_TROSAiBot.AVAIL_parry = 1;
	troshx_tros_ai_TROSAiBot.AVAIL_duckweave = 1;
	troshx_tros_ai_TROSAiBot.AVAIL_partialevasion = 1;
	troshx_tros_ai_TROSAiBot.AVAIL_fullevasion = 1;
	troshx_tros_ai_TROSAiBot.AVAIL_blockopenstrike = 3;
	troshx_tros_ai_TROSAiBot.AVAIL_counter = 3;
	troshx_tros_ai_TROSAiBot.AVAIL_rota = 3;
	troshx_tros_ai_TROSAiBot.AVAIL_expulsion = 2;
	troshx_tros_ai_TROSAiBot.AVAIL_disarm = 2;
	troshx_tros_ai_TROSAiBot.AVAIL_StealInitiative = 5;
};
troshx_tros_ai_TROSAiBot.getCostOfAVAIL = function(avail) {
	return avail - 1;
};
troshx_tros_ai_TROSAiBot.getCostOfManuever = function(manuever) {
	switch(manuever) {
	case "bash":
		return troshx_tros_ai_TROSAiBot.AVAIL_bash - 1;
	case "spike":
		return troshx_tros_ai_TROSAiBot.AVAIL_spike - 1;
	case "cut":
		return troshx_tros_ai_TROSAiBot.AVAIL_cut - 1;
	case "thrust":
		return troshx_tros_ai_TROSAiBot.AVAIL_thrust - 1;
	case "beat":
		return troshx_tros_ai_TROSAiBot.AVAIL_beat - 1;
	case "bindstrike":
		return troshx_tros_ai_TROSAiBot.AVAIL_bindstrike - 1;
	case "hook":
		return troshx_tros_ai_TROSAiBot.AVAIL_hook - 1;
	case "block":
		return troshx_tros_ai_TROSAiBot.AVAIL_block - 1;
	case "parry":
		return troshx_tros_ai_TROSAiBot.AVAIL_parry - 1;
	case "duckweave":
		return troshx_tros_ai_TROSAiBot.AVAIL_duckweave - 1;
	case "partialevasion":
		return troshx_tros_ai_TROSAiBot.AVAIL_partialevasion - 1;
	case "fullevasion":
		return troshx_tros_ai_TROSAiBot.AVAIL_fullevasion - 1;
	case "blockopenstrike":
		return troshx_tros_ai_TROSAiBot.AVAIL_blockopenstrike - 1;
	case "counter":
		return troshx_tros_ai_TROSAiBot.AVAIL_counter - 1;
	case "rota":
		return troshx_tros_ai_TROSAiBot.AVAIL_rota - 1;
	case "expulsion":
		return troshx_tros_ai_TROSAiBot.AVAIL_expulsion - 1;
	case "disarm":
		return troshx_tros_ai_TROSAiBot.AVAIL_disarm - 1;
	}
	return 0;
};
troshx_tros_ai_TROSAiBot.getRegularAttackOrAdvantageMove = function(availableCP,roll,againstRoll,againstTN) {
	if(againstTN == null) againstTN = 1;
	if(againstRoll == null) againstRoll = -1;
	if(roll == null) roll = 0;
	var str = troshx_tros_ai_TROSAiBot.getRegularAttack(availableCP,roll,againstRoll,againstTN);
	var curAggr = -999;
	var regularStr = null;
	troshx_tros_ai_TROSAiBot.B_USE_ADVANTAGE = false;
	if(str != null) {
		curAggr = troshx_tros_ai_TROSAiBot.ATTACK_AGGR;
		regularStr = str;
	}
	str = troshx_tros_ai_TROSAiBot.getRegularAdvantageMove(availableCP,roll,againstRoll,againstTN);
	if(str != null && troshx_tros_ai_TROSAiBot.ATTACK_AGGR > curAggr) {
		curAggr = troshx_tros_ai_TROSAiBot.ATTACK_AGGR;
		troshx_tros_ai_TROSAiBot.B_USE_ADVANTAGE = true;
		return str;
	}
	return regularStr;
};
troshx_tros_ai_TROSAiBot.getRegularAdvantageMove = function(availableCP,roll,againstRoll,againstTN) {
	if(againstTN == null) againstTN = 1;
	if(againstRoll == null) againstRoll = -1;
	if(roll == null) roll = 0;
	troshx_tros_ai_TROSAiBot.B_CANDIDATE_COUNT = 0;
	var weapon = troshx_tros_WeaponSheet.getWeaponByName(troshx_tros_ai_TROSAiBot.B_EQUIP);
	var tn;
	if(weapon != null) tn = weapon.atn; else tn = 888;
	var tn2;
	if(weapon != null) tn2 = weapon.atn2; else tn2 = 888;
	var cost;
	var aggr;
	if(roll == 0) roll = availableCP;
	var tnP;
	if(tn < 11) tnP = (10 - tn + 1) / 10; else tnP = (1 - (tn - Math.floor(tn / 10) * 10) / 10) * Math.pow(0.1,Math.floor(tn / 10));
	var tn2P;
	if(tn2 < 11) tn2P = (10 - tn2 + 1) / 10; else tn2P = (1 - (tn2 - Math.floor(tn2 / 10) * 10) / 10) * Math.pow(0.1,Math.floor(tn2 / 10));
	var gotEnemyRoll = againstRoll >= 0;
	var aggrCur = -999;
	if(troshx_tros_ai_TROSAiBot.AVAIL_beat > 0 && tn != 888) {
		cost = troshx_tros_ai_TROSAiBot.AVAIL_beat - 1;
		if(cost < availableCP) {
			if(gotEnemyRoll) aggr = Math.round(troshx_util_TROSAI.getChanceToSucceedContest(roll - cost,tn,againstRoll,againstTN,1) * 1000); else aggr = tnP * (roll - cost);
			if(aggr > 0 && aggr >= aggrCur) {
				if(aggr != aggrCur) troshx_tros_ai_TROSAiBot.B_CANDIDATE_COUNT = 0;
				troshx_tros_ai_TROSAiBot.B_CANDIDATES[troshx_tros_ai_TROSAiBot.B_CANDIDATE_COUNT++] = "beat";
				aggrCur = aggr;
			}
		}
	}
	if(troshx_tros_ai_TROSAiBot.AVAIL_bindstrike > 0) {
		cost = troshx_tros_ai_TROSAiBot.AVAIL_bindstrike - 1;
		if(cost < availableCP) {
			if(gotEnemyRoll) aggr = Math.round(troshx_util_TROSAI.getChanceToSucceedContest(roll - cost,troshx_tros_ai_TROSAiBot.getATNOfManuever("bindstrike"),againstRoll,againstTN,1) * 1000); else aggr = Math.min(tnP,tn2P) * (roll - cost);
			if(aggr > 0 && aggr >= aggrCur) {
				if(aggr != aggrCur) troshx_tros_ai_TROSAiBot.B_CANDIDATE_COUNT = 0;
				troshx_tros_ai_TROSAiBot.B_CANDIDATES[troshx_tros_ai_TROSAiBot.B_CANDIDATE_COUNT++] = "bindstrike";
				aggrCur = aggr;
			}
		}
	}
	if(troshx_tros_ai_TROSAiBot.B_CANDIDATE_COUNT == 0) return null;
	troshx_tros_ai_TROSAiBot.ATTACK_AGGR = aggrCur;
	return troshx_tros_ai_TROSAiBot.B_CANDIDATES[Std["int"](Math.random() * troshx_tros_ai_TROSAiBot.B_CANDIDATE_COUNT)];
};
troshx_tros_ai_TROSAiBot.mathMax = function(a,b) {
	if(a >= b) return a; else return b;
};
troshx_tros_ai_TROSAiBot.enforceDmgAggrIfFav = function(val) {
	return Math.round(val * 1000) + (val >= troshx_tros_ai_TROSAiBot.P_THRESHOLD_FAVORABLE?1000:0);
};
troshx_tros_ai_TROSAiBot.getRegularAttack = function(availableCP,roll,againstRoll,againstTN) {
	if(againstTN == null) againstTN = 1;
	if(againstRoll == null) againstRoll = -1;
	if(roll == null) roll = 0;
	troshx_tros_ai_TROSAiBot.B_CANDIDATE_COUNT = 0;
	var weapon = troshx_tros_WeaponSheet.getWeaponByName(troshx_tros_ai_TROSAiBot.B_EQUIP);
	var tn;
	if(weapon != null) tn = weapon.atn; else tn = 888;
	var tn2;
	if(weapon != null) tn2 = weapon.atn2; else tn2 = 888;
	var cost;
	var aggr;
	if(roll == 0) roll = availableCP;
	var tnP;
	if(tn < 11) tnP = (10 - tn + 1) / 10; else tnP = (1 - (tn - Math.floor(tn / 10) * 10) / 10) * Math.pow(0.1,Math.floor(tn / 10));
	var tn2P;
	if(tn2 < 11) tn2P = (10 - tn2 + 1) / 10; else tn2P = (1 - (tn2 - Math.floor(tn2 / 10) * 10) / 10) * Math.pow(0.1,Math.floor(tn2 / 10));
	var gotEnemyRoll = againstRoll >= 0;
	var concessionDmg = troshx_tros_ai_TROSAiBot.B_BS_REQUIRED_DMG_DEFAULT > 1;
	var dmg;
	if(weapon != null && gotEnemyRoll) dmg = weapon.damage; else dmg = 0;
	var dmgT;
	if(weapon != null && gotEnemyRoll) dmgT = weapon.damage2; else dmgT = 0;
	var aggrCur = -999;
	if(troshx_tros_ai_TROSAiBot.AVAIL_bash > 0 && tn != 888) {
		cost = troshx_tros_ai_TROSAiBot.AVAIL_bash - 1;
		if(cost < availableCP) {
			if(gotEnemyRoll) aggr = troshx_tros_ai_TROSAiBot.enforceDmgAggrIfFav(troshx_util_TROSAI.getChanceToSucceedContest(roll - cost,tn,againstRoll,againstTN,troshx_tros_ai_TROSAiBot.B_BS_REQUIRED_DMG_DEFAULT,true)) + dmg / 10; else aggr = tnP * (roll - cost);
			if(aggr > 0 && aggr >= aggrCur) {
				if(aggr != aggrCur) troshx_tros_ai_TROSAiBot.B_CANDIDATE_COUNT = 0;
				troshx_tros_ai_TROSAiBot.B_CANDIDATES[troshx_tros_ai_TROSAiBot.B_CANDIDATE_COUNT++] = "bash";
				aggrCur = aggr;
			}
		}
	}
	if(troshx_tros_ai_TROSAiBot.AVAIL_cut > 0 && tn != 888) {
		cost = troshx_tros_ai_TROSAiBot.AVAIL_cut - 1;
		if(cost < availableCP) {
			if(gotEnemyRoll) aggr = troshx_tros_ai_TROSAiBot.enforceDmgAggrIfFav(troshx_util_TROSAI.getChanceToSucceedContest(roll - cost,tn,againstRoll,againstTN,troshx_tros_ai_TROSAiBot.B_BS_REQUIRED_DMG_DEFAULT,true)) + dmg / 10; else aggr = tnP * (roll - cost);
			if(aggr > 0 && aggr >= aggrCur) {
				if(aggr != aggrCur) troshx_tros_ai_TROSAiBot.B_CANDIDATE_COUNT = 0;
				troshx_tros_ai_TROSAiBot.B_CANDIDATES[troshx_tros_ai_TROSAiBot.B_CANDIDATE_COUNT++] = "cut";
				aggrCur = aggr;
			}
		}
	}
	if(troshx_tros_ai_TROSAiBot.AVAIL_spike > 0 && tn2 != 888) {
		cost = troshx_tros_ai_TROSAiBot.AVAIL_spike - 1;
		if(cost < availableCP) {
			if(gotEnemyRoll) aggr = troshx_tros_ai_TROSAiBot.enforceDmgAggrIfFav(troshx_util_TROSAI.getChanceToSucceedContest(roll - cost,tn2,againstRoll,againstTN,troshx_tros_ai_TROSAiBot.B_BS_REQUIRED_DMG_DEFAULT,true)) + dmgT / 10; else aggr = tn2P * (roll - cost);
			if(aggr > 0 && aggr >= aggrCur) {
				if(aggr != aggrCur) troshx_tros_ai_TROSAiBot.B_CANDIDATE_COUNT = 0;
				troshx_tros_ai_TROSAiBot.B_CANDIDATES[troshx_tros_ai_TROSAiBot.B_CANDIDATE_COUNT++] = "spike";
				aggrCur = aggr;
			}
		}
	}
	if(troshx_tros_ai_TROSAiBot.AVAIL_thrust > 0 && tn2 != 888) {
		cost = troshx_tros_ai_TROSAiBot.AVAIL_thrust - 1;
		if(cost < availableCP) {
			if(gotEnemyRoll) aggr = troshx_tros_ai_TROSAiBot.enforceDmgAggrIfFav(troshx_util_TROSAI.getChanceToSucceedContest(roll - cost,tn2,againstRoll,againstTN,troshx_tros_ai_TROSAiBot.B_BS_REQUIRED_DMG_DEFAULT,true)) + dmgT / 10; else aggr = tn2P * (roll - cost);
			if(aggr > 0 && aggr >= aggrCur) {
				if(aggr != aggrCur) troshx_tros_ai_TROSAiBot.B_CANDIDATE_COUNT = 0;
				troshx_tros_ai_TROSAiBot.B_CANDIDATES[troshx_tros_ai_TROSAiBot.B_CANDIDATE_COUNT++] = "thrust";
				aggrCur = aggr;
			}
		}
	}
	if(troshx_tros_ai_TROSAiBot.B_CANDIDATE_COUNT == 0) return null;
	troshx_tros_ai_TROSAiBot.ATTACK_AGGR = aggrCur;
	return troshx_tros_ai_TROSAiBot.B_CANDIDATES[Std["int"](Math.random() * troshx_tros_ai_TROSAiBot.B_CANDIDATE_COUNT)];
};
troshx_tros_ai_TROSAiBot.getRegularDefense = function(availableCP,roll,enforceMustRegainInitiative) {
	if(enforceMustRegainInitiative == null) enforceMustRegainInitiative = false;
	if(roll == null) roll = 0;
	troshx_tros_ai_TROSAiBot.B_CANDIDATE_COUNT = 0;
	var weapon = troshx_tros_WeaponSheet.getWeaponByName(troshx_tros_ai_TROSAiBot.B_EQUIP);
	var offhand = troshx_tros_WeaponSheet.getWeaponByName(troshx_tros_ai_TROSAiBot.D_EQUIP);
	var tn;
	if(weapon != null) tn = weapon.dtn; else tn = 888;
	var tnOff;
	if(offhand != null) tnOff = offhand.dtn; else tnOff = 888;
	var tnP;
	if(tn < 11) tnP = (10 - tn + 1) / 10; else tnP = (1 - (tn - Math.floor(tn / 10) * 10) / 10) * Math.pow(0.1,Math.floor(tn / 10));
	var tnPOff;
	if(tnOff < 11) tnPOff = (10 - tnOff + 1) / 10; else tnPOff = (1 - (tnOff - Math.floor(tnOff / 10) * 10) / 10) * Math.pow(0.1,Math.floor(tnOff / 10));
	var aggr;
	var aggrCur = -999;
	if(roll == 0) roll = availableCP;
	var cost;
	if(troshx_tros_ai_TROSAiBot.AVAIL_block > 0 && tnPOff != 888) {
		cost = troshx_tros_ai_TROSAiBot.AVAIL_block - 1;
		if(cost < roll) {
			aggr = tnPOff * (roll - cost);
			if(aggr >= aggrCur) {
				if(aggr != aggrCur) troshx_tros_ai_TROSAiBot.B_CANDIDATE_COUNT = 0;
				troshx_tros_ai_TROSAiBot.B_CANDIDATES[troshx_tros_ai_TROSAiBot.B_CANDIDATE_COUNT++] = "block";
				aggrCur = aggr;
			}
		}
	}
	if(troshx_tros_ai_TROSAiBot.AVAIL_parry > 0 && tnP != 888) {
		cost = troshx_tros_ai_TROSAiBot.AVAIL_parry - 1;
		if(cost < availableCP) {
			aggr = tnP * (roll - cost);
			if(aggr >= aggrCur) {
				if(aggr != aggrCur) troshx_tros_ai_TROSAiBot.B_CANDIDATE_COUNT = 0;
				troshx_tros_ai_TROSAiBot.B_CANDIDATES[troshx_tros_ai_TROSAiBot.B_CANDIDATE_COUNT++] = "parry";
				aggrCur = aggr;
			}
		}
	}
	if(troshx_tros_ai_TROSAiBot.AVAIL_partialevasion > 0) {
		cost = troshx_tros_ai_TROSAiBot.AVAIL_partialevasion - 1;
		if(cost + (enforceMustRegainInitiative?2:0) < availableCP) {
			aggr = 0.4 * (roll - cost - .00000001);
			if(aggr >= aggrCur) {
				if(aggr != aggrCur) troshx_tros_ai_TROSAiBot.B_CANDIDATE_COUNT = 0;
				troshx_tros_ai_TROSAiBot.B_CANDIDATES[troshx_tros_ai_TROSAiBot.B_CANDIDATE_COUNT++] = "partialevasion";
				aggrCur = aggr;
			}
		}
	}
	if(troshx_tros_ai_TROSAiBot.B_CANDIDATE_COUNT == 0) return null;
	return troshx_tros_ai_TROSAiBot.B_CANDIDATES[Std["int"](Math.random() * troshx_tros_ai_TROSAiBot.B_CANDIDATE_COUNT)];
};
troshx_tros_ai_TROSAiBot.getATNOfManuever = function(manuever) {
	var weapon = troshx_tros_WeaponSheet.getWeaponByName(troshx_tros_ai_TROSAiBot.B_EQUIP);
	var tn;
	if(weapon != null) tn = weapon.atn; else tn = 888;
	var tn2;
	if(weapon != null) tn2 = weapon.atn2; else tn2 = 888;
	var cost;
	var aggr;
	switch(manuever) {
	case "bash":
		return tn;
	case "cut":
		return tn;
	case "disarm":
		return tn;
	case "hook":
		if(weapon != null) return weapon.getHookingATN(); else return 888;
		break;
	case "beat":
		return tn;
	case "bindstrike":
		if(tn2 < tn) return tn2; else return tn;
		break;
	case "spike":
		return tn2;
	case "thrust":
		return tn2;
	}
	return 0;
};
troshx_tros_ai_TROSAiBot.getDTNOfManuever = function(manuever) {
	var weapon = troshx_tros_WeaponSheet.getWeaponByName(troshx_tros_ai_TROSAiBot.B_EQUIP);
	var offhand = troshx_tros_WeaponSheet.getWeaponByName(troshx_tros_ai_TROSAiBot.D_EQUIP);
	var tn;
	if(weapon != null) tn = weapon.dtn; else tn = 888;
	var tnOff;
	if(offhand != null) tnOff = offhand.dtn; else tnOff = 888;
	switch(manuever) {
	case "block":
		return tnOff;
	case "parry":
		return tn;
	case "rota":
		return tn;
	case "counter":
		return tn;
	case "disarm":
		return tn;
	case "blockopenstrike":
		return tn;
	case "expulsion":
		return tn;
	case "partialevasion":
		return 7;
	case "duckweave":
		return 9;
	case "fullevasion":
		return 4;
	}
	return 0;
};
troshx_tros_ai_TROSAiBot.getTargetZoneAverageAVOffset = function(tarZone,weaponName) {
	return 0;
};
troshx_tros_ai_TROSAiBot.getRegularTargetZone = function(manuever,atn,cp) {
	var zones = troshx_tros_ai_TROSAiBot.CURRENT_OPPONENT.body.zones;
	var randIndex = 1 + Std["int"](Math.random() * (zones.length - 1));
	return randIndex;
};
troshx_tros_ai_TROSAiBot.checkCostViability = function(availableCP,tn,threshold,againstRoll,againstTN,useAllCP) {
	if(useAllCP == null) useAllCP = false;
	if(againstTN == null) againstTN = 1;
	var min;
	var accum;
	if(useAllCP) min = availableCP; else if(troshx_tros_ai_TROSAiBot.B_BS_REQUIRED > 1) min = troshx_tros_ai_TROSAiBot.B_BS_REQUIRED; else min = 1;
	var _g1 = min;
	var _g = availableCP + 1;
	while(_g1 < _g) {
		var c = _g1++;
		accum = troshx_tros_ai_TROSAiBot.precisionPerc(troshx_util_TROSAI.getChanceToSucceedContest(c,tn,againstRoll,againstTN,troshx_tros_ai_TROSAiBot.B_BS_REQUIRED,true));
		if(accum >= threshold) {
			troshx_tros_ai_TROSAiBot.B_VIABLE_PROBABILITY = accum;
			return c;
		}
	}
	return 0;
};
troshx_tros_ai_TROSAiBot.precisionPerc = function(val) {
	return Math.round(val / 0.01) * 0.01;
};
troshx_tros_ai_TROSAiBot.checkCostViabilityBorderline = function(availableCP,tn,threshold,againstRoll,againstTN,useAllCP) {
	if(useAllCP == null) useAllCP = false;
	if(againstTN == null) againstTN = 1;
	var min;
	var accum;
	var bsRequired;
	if(troshx_tros_ai_TROSAiBot.B_BS_REQUIRED > 1) bsRequired = troshx_tros_ai_TROSAiBot.B_BS_REQUIRED; else bsRequired = 1;
	var min1;
	if(useAllCP) min1 = availableCP; else min1 = bsRequired;
	var _g1 = min1;
	var _g = availableCP + 1;
	while(_g1 < _g) {
		var c = _g1++;
		var successProbabilitWithBS = troshx_util_TROSAI.getChanceToSucceedContest(c,tn,againstRoll,againstTN,bsRequired,true);
		accum = troshx_tros_ai_TROSAiBot.precisionPerc((successProbabilitWithBS + troshx_util_TROSAI.getChanceToSucceedContest(c,tn,againstRoll,againstTN,bsRequired - 1,false)) * 0.5);
		if(accum >= threshold) {
			if(successProbabilitWithBS == 0) return 0;
			troshx_tros_ai_TROSAiBot.B_VIABLE_PROBABILITY = successProbabilitWithBS;
			if(useAllCP) return availableCP; else return c;
		}
	}
	return 0;
};
troshx_tros_ai_TROSAiBot.checkCostAntiFavorability = function(availableCP,tn,threshold,againstCP,againstTN,useAllCP,offset,requiredBS) {
	if(requiredBS == null) requiredBS = 1;
	if(offset == null) offset = 0;
	if(useAllCP == null) useAllCP = false;
	if(againstTN == null) againstTN = 1;
	var min;
	var accum;
	min = 1;
	var cpToUse = 0;
	var _g1 = min;
	var _g = availableCP + 1;
	while(_g1 < _g) {
		var c = _g1++;
		accum = troshx_tros_ai_TROSAiBot.precisionPerc(troshx_util_TROSAI.getChanceToSucceedContest(againstCP,againstTN,c,tn,requiredBS,true));
		if(accum < threshold) {
			cpToUse = c;
			break;
		}
	}
	if(cpToUse != 0) {
		if(useAllCP) cpToUse = availableCP; else {
			cpToUse += offset;
			if(cpToUse <= 0) cpToUse = 1;
			if(cpToUse > availableCP) cpToUse = availableCP;
		}
		troshx_tros_ai_TROSAiBot.B_VIABLE_PROBABILITY_GET = troshx_util_TROSAI.getChanceToSucceedContest(cpToUse,tn,againstCP,againstTN,troshx_tros_ai_TROSAiBot.B_BS_REQUIRED,true);
	}
	return cpToUse;
};
troshx_tros_ai_TROSAiBot.checkCostAntiBorderline = function(availableCP,tn,threshold,againstCP,againstTN,useAllCP,offset) {
	if(offset == null) offset = 0;
	if(useAllCP == null) useAllCP = false;
	if(againstTN == null) againstTN = 1;
	var min;
	var accum;
	min = 1;
	var cpToUse = 0;
	var successProbabilitWith1BS = .0;
	var _g1 = min;
	var _g = availableCP + 1;
	while(_g1 < _g) {
		var c = _g1++;
		successProbabilitWith1BS = troshx_util_TROSAI.getChanceToSucceedContest(againstCP,againstTN,c,tn,1,true);
		accum = troshx_tros_ai_TROSAiBot.precisionPerc((successProbabilitWith1BS + troshx_util_TROSAI.getChanceToSucceedContest(againstCP,againstTN,c,tn,0)) * 0.5);
		if(accum < threshold) {
			cpToUse = c;
			break;
		}
	}
	if(cpToUse != 0) {
		if(useAllCP) cpToUse = availableCP; else {
			cpToUse += offset;
			if(cpToUse <= 0) cpToUse = 1;
			if(cpToUse > availableCP) cpToUse = availableCP;
		}
		troshx_tros_ai_TROSAiBot.B_VIABLE_PROBABILITY_GET = troshx_util_TROSAI.getChanceToSucceedContest(cpToUse,tn,againstCP,againstTN,troshx_tros_ai_TROSAiBot.B_BS_REQUIRED,true);
	}
	return cpToUse;
};
troshx_tros_ai_TROSAiBot.getCostOfAvail = function(avail) {
	return avail - 1;
};
troshx_tros_ai_TROSAiBot.getTheSuitableAttack = function(manuever,tn,tarZone,threshold,availableCP,againstRoll,againstTN,favorable,useAllCP) {
	if(useAllCP == null) useAllCP = false;
	if(favorable == null) favorable = true;
	if(againstTN == null) againstTN = 1;
	if(againstRoll == null) againstRoll = 0;
	var cpToUse;
	if(favorable) cpToUse = troshx_tros_ai_TROSAiBot.checkCostViability(availableCP,tn,threshold,againstRoll,againstTN,useAllCP); else cpToUse = troshx_tros_ai_TROSAiBot.checkCostViabilityBorderline(availableCP,tn,threshold,againstRoll,againstTN,useAllCP);
	if(cpToUse > 0) {
		troshx_tros_ai_TROSAiBot.MANUEVER_CHOICE.setAttack(manuever,cpToUse,tn,tarZone,troshx_tros_ai_TROSAiBot.getCostOfManuever(manuever),troshx_tros_ai_TROSAiBot.B_IS_OFFHAND);
		return true;
	}
	return false;
};
troshx_tros_ai_TROSAiBot.getTheSuitableDefense = function(manuever,tn,threshold,availableCP,againstRoll,againstTN,favorable,useAllCP) {
	if(useAllCP == null) useAllCP = false;
	if(favorable == null) favorable = true;
	if(againstTN == null) againstTN = 1;
	if(againstRoll == null) againstRoll = 0;
	var cpToUse;
	if(favorable) cpToUse = troshx_tros_ai_TROSAiBot.checkCostViability(availableCP,tn,threshold,againstRoll,againstTN,useAllCP); else cpToUse = troshx_tros_ai_TROSAiBot.checkCostViabilityBorderline(availableCP,tn,threshold,againstRoll,againstTN,useAllCP);
	if(cpToUse > 0) {
		troshx_tros_ai_TROSAiBot.MANUEVER_CHOICE.setDefend(manuever,cpToUse,tn,troshx_tros_ai_TROSAiBot.getCostOfManuever(manuever),troshx_tros_ai_TROSAiBot.B_IS_OFFHAND);
		return true;
	}
	return false;
};
troshx_tros_ai_TROSAiBot.getTheForcefulInitiativeAttack = function(manuever,tn,tarZone,threshold,availableCP,againstCP,againstTN,favorable,useAllCP,offset) {
	if(offset == null) offset = 0;
	if(useAllCP == null) useAllCP = false;
	if(favorable == null) favorable = true;
	if(againstTN == null) againstTN = 1;
	if(againstCP == null) againstCP = 0;
	var cpToUse;
	if(favorable) cpToUse = troshx_tros_ai_TROSAiBot.checkCostAntiFavorability(availableCP,tn,threshold,againstCP,againstTN,useAllCP,offset); else cpToUse = troshx_tros_ai_TROSAiBot.checkCostAntiBorderline(availableCP,tn,threshold,againstCP,againstTN,useAllCP,offset);
	if(cpToUse > 0) {
		troshx_tros_ai_TROSAiBot.MANUEVER_CHOICE.setAttack(manuever,cpToUse,tn,tarZone,troshx_tros_ai_TROSAiBot.getCostOfManuever(manuever),troshx_tros_ai_TROSAiBot.B_IS_OFFHAND);
		return true;
	}
	return false;
};
troshx_tros_ai_TROSAiBot.getASuitableAttack = function(threshold,availableCP,againstRoll,againstTN,favorable,useAllCP) {
	if(useAllCP == null) useAllCP = false;
	if(favorable == null) favorable = true;
	if(againstTN == null) againstTN = 1;
	if(againstRoll == null) againstRoll = 0;
	troshx_tros_ai_TROSAiBot.B_BS_REQUIRED = troshx_tros_ai_TROSAiBot.B_BS_REQUIRED_DMG_DEFAULT;
	var manuever = troshx_tros_ai_TROSAiBot.getRegularAttack(availableCP,0,againstRoll,againstTN);
	if(manuever != null) {
		availableCP -= troshx_tros_ai_TROSAiBot.getCostOfManuever(manuever);
		var tn = troshx_tros_ai_TROSAiBot.getATNOfManuever(manuever);
		var tarZone = troshx_tros_ai_TROSAiBot.getRegularTargetZone(manuever,tn,availableCP);
		if(tarZone != 0) {
			availableCP -= troshx_tros_ai_TROSAiBot.CURRENT_OPPONENT.body.getTargetZoneCost(tarZone);
			return troshx_tros_ai_TROSAiBot.getTheSuitableAttack(manuever,tn,tarZone,threshold,availableCP,againstRoll,againstTN,favorable,useAllCP);
		}
	}
	return false;
};
troshx_tros_ai_TROSAiBot.getAForcefulInitiativeAttack = function(threshold,availableCP,againstCP,againstTN,favorable,useAllCP,offset) {
	if(offset == null) offset = 0;
	if(useAllCP == null) useAllCP = false;
	if(favorable == null) favorable = true;
	if(againstTN == null) againstTN = 1;
	if(againstCP == null) againstCP = 0;
	var manuever = troshx_tros_ai_TROSAiBot.getRegularAttackOrAdvantageMove(availableCP,0,againstCP,againstTN);
	if(troshx_tros_ai_TROSAiBot.B_USE_ADVANTAGE) troshx_tros_ai_TROSAiBot.B_BS_REQUIRED = 1; else troshx_tros_ai_TROSAiBot.B_BS_REQUIRED = troshx_tros_ai_TROSAiBot.B_BS_REQUIRED_DMG_DEFAULT;
	if(manuever != null) {
		availableCP -= troshx_tros_ai_TROSAiBot.getCostOfManuever(manuever);
		var tn = troshx_tros_ai_TROSAiBot.getATNOfManuever(manuever);
		var tarZone = troshx_tros_ai_TROSAiBot.getRegularTargetZone(manuever,tn,availableCP);
		if(tarZone != 0) {
			var result = troshx_tros_ai_TROSAiBot.getTheForcefulInitiativeAttack(manuever,tn,tarZone,threshold,availableCP,againstCP,againstTN,favorable,useAllCP,offset);
			if(result) return true;
		}
	}
	return false;
};
troshx_tros_ai_TROSAiBot.getASuitableDefense = function(threshold,availableCP,againstRoll,againstTN,mustRegainInitiative,favorable,useAllCP) {
	if(useAllCP == null) useAllCP = false;
	if(favorable == null) favorable = true;
	if(mustRegainInitiative == null) mustRegainInitiative = false;
	if(againstTN == null) againstTN = 1;
	if(againstRoll == null) againstRoll = 0;
	troshx_tros_ai_TROSAiBot.B_BS_REQUIRED = troshx_tros_ai_TROSAiBot.B_BS_REQUIRED_DEFAULT;
	var manuever = troshx_tros_ai_TROSAiBot.getRegularDefense(availableCP,0,mustRegainInitiative);
	if(manuever != null) {
		availableCP -= troshx_tros_ai_TROSAiBot.getCostOfManuever(manuever);
		var tn = troshx_tros_ai_TROSAiBot.getDTNOfManuever(manuever);
		return troshx_tros_ai_TROSAiBot.getTheSuitableDefense(manuever,tn,threshold,availableCP,againstRoll,againstTN,favorable,useAllCP);
	}
	return false;
};
troshx_tros_ai_TROSAiBot.getFavorableAttack = function(availableCP,againstRoll,againstTN,heuristic,flags,customThreshold) {
	if(customThreshold == null) customThreshold = 0;
	if(flags == null) flags = 0;
	if(heuristic == null) heuristic = true;
	if(againstTN == null) againstTN = 1;
	if(againstRoll == null) againstRoll = 0;
	return troshx_tros_ai_TROSAiBot.getFBAttack(true,availableCP,againstRoll,againstTN,heuristic,flags,customThreshold);
};
troshx_tros_ai_TROSAiBot.getBorderlineAttack = function(availableCP,againstRoll,againstTN,heuristic,flags,customThreshold) {
	if(customThreshold == null) customThreshold = 0;
	if(flags == null) flags = 0;
	if(heuristic == null) heuristic = true;
	if(againstTN == null) againstTN = 1;
	if(againstRoll == null) againstRoll = 0;
	return troshx_tros_ai_TROSAiBot.getFBAttack(false,availableCP,againstRoll,againstTN,heuristic,flags,customThreshold);
};
troshx_tros_ai_TROSAiBot.getFBAttack = function(favorable,availableCP,againstRoll,againstTN,heuristic,flags,customThreshold) {
	if(customThreshold == null) customThreshold = 0;
	if(flags == null) flags = 0;
	if(heuristic == null) heuristic = true;
	if(againstTN == null) againstTN = 1;
	if(againstRoll == null) againstRoll = 0;
	var threshold;
	if(customThreshold != 0) threshold = customThreshold; else if(favorable) threshold = troshx_tros_ai_TROSAiBot.P_THRESHOLD_FAVORABLE; else threshold = troshx_tros_ai_TROSAiBot.P_THRESHOLD_BORDERLINE;
	troshx_tros_ai_TROSAiBot.B_VIABLE_HEURISTIC = false;
	var result;
	if(heuristic) result = troshx_tros_ai_TROSAiBot.getASuitableAttack(threshold,availableCP,againstRoll,againstTN,favorable,(flags & 2) != 0); else result = false;
	if(result) {
		troshx_tros_ai_TROSAiBot.B_VIABLE_PROBABILITY_GET = troshx_tros_ai_TROSAiBot.B_VIABLE_PROBABILITY;
		troshx_tros_ai_TROSAiBot.B_VIABLE_HEURISTIC = true;
		return true;
	}
	var cp = availableCP;
	var cpToUse;
	var useCheapestMult;
	if((flags & 1) != 0) useCheapestMult = 1; else useCheapestMult = 0;
	var aggr;
	troshx_tros_ai_TROSAiBot.B_MANUEVER_CHOICE_COUNT = 0;
	var curAggr = 9999999999999;
	var tn;
	var checkCostFunc;
	if(favorable) checkCostFunc = troshx_tros_ai_TROSAiBot.checkCostViability; else checkCostFunc = troshx_tros_ai_TROSAiBot.checkCostViabilityBorderline;
	if(troshx_tros_ai_TROSAiBot.AVAIL_bash > 0) {
		troshx_tros_ai_TROSAiBot.B_BS_REQUIRED = troshx_tros_ai_TROSAiBot.B_BS_REQUIRED_DMG_DEFAULT;
		cp = availableCP - (troshx_tros_ai_TROSAiBot.AVAIL_bash - 1);
		if(cp > 0) {
			tn = troshx_tros_ai_TROSAiBot.getATNOfManuever("bash");
			var _g1 = 1;
			var _g = troshx_tros_ai_TROSAiBot.CURRENT_OPPONENT.body.thrustStartIndex;
			while(_g1 < _g) {
				var i = _g1++;
				troshx_tros_ai_TROSAiBot.B_BS_REQUIRED += troshx_tros_ai_TROSAiBot.getTargetZoneAverageAVOffset(i,troshx_tros_ai_TROSAiBot.B_EQUIP);
				cpToUse = checkCostFunc(cp,tn,threshold,againstRoll,againstTN,(flags & 2) != 0);
				if(cpToUse > 0) {
					aggr = useCheapestMult * cpToUse + (1 - troshx_tros_ai_TROSAiBot.B_VIABLE_PROBABILITY);
					if(aggr <= curAggr) {
						if(aggr != curAggr) troshx_tros_ai_TROSAiBot.B_MANUEVER_CHOICE_COUNT = 0;
						troshx_tros_ai_TROSAiBot.MANUEVER_CHOICE.setAttack("bash",cpToUse,tn,i,troshx_tros_ai_TROSAiBot.AVAIL_bash - 1,troshx_tros_ai_TROSAiBot.B_IS_OFFHAND);
						troshx_tros_ai_TROSAiBot.addPossibleRegularManueverChoice(troshx_tros_ai_TROSAiBot.B_MANUEVER_CHOICE_COUNT);
						troshx_tros_ai_TROSAiBot.B_MANUEVER_CHOICE_PROBABILITIES[troshx_tros_ai_TROSAiBot.B_MANUEVER_CHOICE_COUNT] = troshx_tros_ai_TROSAiBot.B_VIABLE_PROBABILITY;
						troshx_tros_ai_TROSAiBot.B_MANUEVER_CHOICE_COUNT++;
						curAggr = aggr;
					}
				}
			}
		}
	}
	if(troshx_tros_ai_TROSAiBot.AVAIL_spike > 0) {
		troshx_tros_ai_TROSAiBot.B_BS_REQUIRED = troshx_tros_ai_TROSAiBot.B_BS_REQUIRED_DMG_DEFAULT;
		cp = availableCP - (troshx_tros_ai_TROSAiBot.AVAIL_spike - 1);
		if(cp > 0) {
			tn = troshx_tros_ai_TROSAiBot.getATNOfManuever("spike");
			var _g11 = troshx_tros_ai_TROSAiBot.CURRENT_OPPONENT.body.thrustStartIndex;
			var _g2 = troshx_tros_ai_TROSAiBot.CURRENT_OPPONENT.body.zones.length;
			while(_g11 < _g2) {
				var i1 = _g11++;
				troshx_tros_ai_TROSAiBot.B_BS_REQUIRED += troshx_tros_ai_TROSAiBot.getTargetZoneAverageAVOffset(i1,troshx_tros_ai_TROSAiBot.B_EQUIP);
				cpToUse = checkCostFunc(cp,tn,threshold,againstRoll,againstTN,(flags & 2) != 0);
				if(cpToUse > 0) {
					aggr = useCheapestMult * cpToUse + (1 - troshx_tros_ai_TROSAiBot.B_VIABLE_PROBABILITY);
					if(aggr <= curAggr) {
						if(aggr != curAggr) troshx_tros_ai_TROSAiBot.B_MANUEVER_CHOICE_COUNT = 0;
						troshx_tros_ai_TROSAiBot.MANUEVER_CHOICE.setAttack("spike",cpToUse,tn,i1,troshx_tros_ai_TROSAiBot.AVAIL_spike - 1,troshx_tros_ai_TROSAiBot.B_IS_OFFHAND);
						troshx_tros_ai_TROSAiBot.addPossibleRegularManueverChoice(troshx_tros_ai_TROSAiBot.B_MANUEVER_CHOICE_COUNT);
						troshx_tros_ai_TROSAiBot.B_MANUEVER_CHOICE_PROBABILITIES[troshx_tros_ai_TROSAiBot.B_MANUEVER_CHOICE_COUNT] = troshx_tros_ai_TROSAiBot.B_VIABLE_PROBABILITY;
						troshx_tros_ai_TROSAiBot.B_MANUEVER_CHOICE_COUNT++;
						curAggr = aggr;
					}
				}
			}
		}
	}
	if(troshx_tros_ai_TROSAiBot.AVAIL_cut > 0) {
		troshx_tros_ai_TROSAiBot.B_BS_REQUIRED = troshx_tros_ai_TROSAiBot.B_BS_REQUIRED_DMG_DEFAULT;
		cp = availableCP - (troshx_tros_ai_TROSAiBot.AVAIL_cut - 1);
		if(cp > 0) {
			tn = troshx_tros_ai_TROSAiBot.getATNOfManuever("cut");
			var _g12 = 1;
			var _g3 = troshx_tros_ai_TROSAiBot.CURRENT_OPPONENT.body.thrustStartIndex;
			while(_g12 < _g3) {
				var i2 = _g12++;
				troshx_tros_ai_TROSAiBot.B_BS_REQUIRED += troshx_tros_ai_TROSAiBot.getTargetZoneAverageAVOffset(i2,troshx_tros_ai_TROSAiBot.B_EQUIP);
				cpToUse = checkCostFunc(cp,tn,threshold,againstRoll,againstTN,(flags & 2) != 0);
				if(cpToUse > 0) {
					aggr = useCheapestMult * cpToUse + (1 - troshx_tros_ai_TROSAiBot.B_VIABLE_PROBABILITY);
					if(aggr <= curAggr) {
						if(aggr != curAggr) troshx_tros_ai_TROSAiBot.B_MANUEVER_CHOICE_COUNT = 0;
						troshx_tros_ai_TROSAiBot.MANUEVER_CHOICE.setAttack("cut",cpToUse,tn,i2,troshx_tros_ai_TROSAiBot.AVAIL_cut - 1,troshx_tros_ai_TROSAiBot.B_IS_OFFHAND);
						troshx_tros_ai_TROSAiBot.addPossibleRegularManueverChoice(troshx_tros_ai_TROSAiBot.B_MANUEVER_CHOICE_COUNT);
						troshx_tros_ai_TROSAiBot.B_MANUEVER_CHOICE_PROBABILITIES[troshx_tros_ai_TROSAiBot.B_MANUEVER_CHOICE_COUNT] = troshx_tros_ai_TROSAiBot.B_VIABLE_PROBABILITY;
						troshx_tros_ai_TROSAiBot.B_MANUEVER_CHOICE_COUNT++;
						curAggr = aggr;
					}
				}
			}
		}
	}
	if(troshx_tros_ai_TROSAiBot.AVAIL_thrust > 0) {
		troshx_tros_ai_TROSAiBot.B_BS_REQUIRED = troshx_tros_ai_TROSAiBot.B_BS_REQUIRED_DMG_DEFAULT;
		cp = availableCP - (troshx_tros_ai_TROSAiBot.AVAIL_thrust - 1);
		if(cp > 0) {
			tn = troshx_tros_ai_TROSAiBot.getATNOfManuever("thrust");
			var _g13 = troshx_tros_ai_TROSAiBot.CURRENT_OPPONENT.body.thrustStartIndex;
			var _g4 = troshx_tros_ai_TROSAiBot.CURRENT_OPPONENT.body.zones.length;
			while(_g13 < _g4) {
				var i3 = _g13++;
				troshx_tros_ai_TROSAiBot.B_BS_REQUIRED += troshx_tros_ai_TROSAiBot.getTargetZoneAverageAVOffset(i3,troshx_tros_ai_TROSAiBot.B_EQUIP);
				cpToUse = checkCostFunc(cp,tn,threshold,againstRoll,againstTN,(flags & 2) != 0);
				if(cpToUse > 0) {
					aggr = useCheapestMult * cpToUse + (1 - troshx_tros_ai_TROSAiBot.B_VIABLE_PROBABILITY);
					if(aggr <= curAggr) {
						if(aggr != curAggr) troshx_tros_ai_TROSAiBot.B_MANUEVER_CHOICE_COUNT = 0;
						troshx_tros_ai_TROSAiBot.MANUEVER_CHOICE.setAttack("thrust",cpToUse,tn,i3,troshx_tros_ai_TROSAiBot.AVAIL_thrust - 1,troshx_tros_ai_TROSAiBot.B_IS_OFFHAND);
						troshx_tros_ai_TROSAiBot.addPossibleRegularManueverChoice(troshx_tros_ai_TROSAiBot.B_MANUEVER_CHOICE_COUNT);
						troshx_tros_ai_TROSAiBot.B_MANUEVER_CHOICE_PROBABILITIES[troshx_tros_ai_TROSAiBot.B_MANUEVER_CHOICE_COUNT] = troshx_tros_ai_TROSAiBot.B_VIABLE_PROBABILITY;
						troshx_tros_ai_TROSAiBot.B_MANUEVER_CHOICE_COUNT++;
						curAggr = aggr;
					}
				}
			}
		}
	}
	if(troshx_tros_ai_TROSAiBot.B_MANUEVER_CHOICE_COUNT > 0) {
		var randIndex = Std["int"](Math.random() * troshx_tros_ai_TROSAiBot.B_MANUEVER_CHOICE_COUNT);
		troshx_tros_ai_TROSAiBot.B_MANUEVER_CHOICES[randIndex].copyTo(troshx_tros_ai_TROSAiBot.MANUEVER_CHOICE,null);
		troshx_tros_ai_TROSAiBot.B_VIABLE_PROBABILITY_GET = troshx_tros_ai_TROSAiBot.B_MANUEVER_CHOICE_PROBABILITIES[randIndex];
		return true;
	}
	return false;
};
troshx_tros_ai_TROSAiBot.getFBDefense = function(favorable,availableCP,againstRoll,againstTN,heuristic,flags,customThreshold) {
	if(customThreshold == null) customThreshold = 0;
	if(flags == null) flags = 0;
	if(heuristic == null) heuristic = true;
	if(againstTN == null) againstTN = 1;
	if(againstRoll == null) againstRoll = 0;
	var threshold;
	if(customThreshold != 0) threshold = customThreshold; else if(favorable) threshold = troshx_tros_ai_TROSAiBot.P_THRESHOLD_FAVORABLE; else threshold = troshx_tros_ai_TROSAiBot.P_THRESHOLD_BORDERLINE;
	var safetyCost;
	troshx_tros_ai_TROSAiBot.B_VIABLE_HEURISTIC = false;
	var result;
	if(heuristic) result = troshx_tros_ai_TROSAiBot.getASuitableDefense(threshold,availableCP,againstRoll,againstTN,false,favorable,(flags & 2) != 0); else result = false;
	if(result && (flags & 4) != 0) {
		safetyCost = troshx_tros_ai_TROSAiBot.checkCostAntiFavorability(availableCP,troshx_tros_ai_TROSAiBot.MANUEVER_CHOICE.manueverTN,troshx_tros_ai_TROSAiBot.P_RECKLESS,againstRoll,againstTN,false,0,2);
		if(safetyCost > 0) {
			if(troshx_tros_ai_TROSAiBot.MANUEVER_CHOICE.manueverCP < safetyCost) troshx_tros_ai_TROSAiBot.MANUEVER_CHOICE.manueverCP = safetyCost;
		} else result = false;
	}
	if(result) {
		troshx_tros_ai_TROSAiBot.B_VIABLE_PROBABILITY_GET = troshx_tros_ai_TROSAiBot.B_VIABLE_PROBABILITY;
		troshx_tros_ai_TROSAiBot.B_VIABLE_HEURISTIC = true;
		return true;
	}
	var cp = availableCP;
	var cpToUse;
	var useCheapestMult;
	if((flags & 1) != 0) useCheapestMult = 1; else useCheapestMult = 0;
	var aggr;
	troshx_tros_ai_TROSAiBot.B_MANUEVER_CHOICE_COUNT = 0;
	var curAggr = 9999999999999;
	var tn;
	var checkCostFunc;
	if(favorable) checkCostFunc = troshx_tros_ai_TROSAiBot.checkCostViability; else checkCostFunc = troshx_tros_ai_TROSAiBot.checkCostViabilityBorderline;
	if(troshx_tros_ai_TROSAiBot.AVAIL_block > 0) {
		troshx_tros_ai_TROSAiBot.B_BS_REQUIRED = troshx_tros_ai_TROSAiBot.B_BS_REQUIRED_DEFAULT;
		cp = availableCP - (troshx_tros_ai_TROSAiBot.AVAIL_block - 1);
		if(cp > 0) {
			tn = troshx_tros_ai_TROSAiBot.getDTNOfManuever("block");
			cpToUse = checkCostFunc(cp,tn,threshold,againstRoll,againstTN,(flags & 2) != 0);
			if(cpToUse > 0 && (flags & 4) != 0) {
				safetyCost = troshx_tros_ai_TROSAiBot.checkCostAntiFavorability(cp,tn,troshx_tros_ai_TROSAiBot.P_RECKLESS,againstRoll,againstTN,false,0,2);
				if(safetyCost > 0) {
					if(cpToUse < safetyCost) cpToUse = safetyCost;
				} else cpToUse = 0;
			}
			if(cpToUse > 0) {
				aggr = useCheapestMult * cpToUse + (1 - troshx_tros_ai_TROSAiBot.B_VIABLE_PROBABILITY);
				if(aggr <= curAggr) {
					if(aggr != curAggr) troshx_tros_ai_TROSAiBot.B_MANUEVER_CHOICE_COUNT = 0;
					troshx_tros_ai_TROSAiBot.MANUEVER_CHOICE.setDefend("block",cpToUse,tn,troshx_tros_ai_TROSAiBot.AVAIL_block - 1,true);
					troshx_tros_ai_TROSAiBot.addPossibleRegularManueverChoice(troshx_tros_ai_TROSAiBot.B_MANUEVER_CHOICE_COUNT);
					troshx_tros_ai_TROSAiBot.B_MANUEVER_CHOICE_PROBABILITIES[troshx_tros_ai_TROSAiBot.B_MANUEVER_CHOICE_COUNT] = troshx_tros_ai_TROSAiBot.B_VIABLE_PROBABILITY;
					troshx_tros_ai_TROSAiBot.B_MANUEVER_CHOICE_COUNT++;
				}
			}
		}
	}
	if(troshx_tros_ai_TROSAiBot.AVAIL_parry > 0) {
		troshx_tros_ai_TROSAiBot.B_BS_REQUIRED = troshx_tros_ai_TROSAiBot.B_BS_REQUIRED_DEFAULT;
		cp = availableCP - (troshx_tros_ai_TROSAiBot.AVAIL_parry - 1);
		if(cp > 0) {
			tn = troshx_tros_ai_TROSAiBot.getDTNOfManuever("parry");
			cpToUse = checkCostFunc(cp,tn,threshold,againstRoll,againstTN,(flags & 2) != 0);
			if(cpToUse > 0 && (flags & 4) != 0) {
				safetyCost = troshx_tros_ai_TROSAiBot.checkCostAntiFavorability(cp,tn,troshx_tros_ai_TROSAiBot.P_RECKLESS,againstRoll,againstTN,false,0,2);
				if(safetyCost > 0) {
					if(cpToUse < safetyCost) cpToUse = safetyCost;
				} else cpToUse = 0;
			}
			if(cpToUse > 0) {
				aggr = useCheapestMult * cpToUse + (1 - troshx_tros_ai_TROSAiBot.B_VIABLE_PROBABILITY);
				if(aggr <= curAggr) {
					if(aggr != curAggr) troshx_tros_ai_TROSAiBot.B_MANUEVER_CHOICE_COUNT = 0;
					troshx_tros_ai_TROSAiBot.MANUEVER_CHOICE.setDefend("parry",cpToUse,tn,troshx_tros_ai_TROSAiBot.AVAIL_parry - 1,troshx_tros_ai_TROSAiBot.B_IS_OFFHAND);
					troshx_tros_ai_TROSAiBot.addPossibleRegularManueverChoice(troshx_tros_ai_TROSAiBot.B_MANUEVER_CHOICE_COUNT);
					troshx_tros_ai_TROSAiBot.B_MANUEVER_CHOICE_PROBABILITIES[troshx_tros_ai_TROSAiBot.B_MANUEVER_CHOICE_COUNT] = troshx_tros_ai_TROSAiBot.B_VIABLE_PROBABILITY;
					troshx_tros_ai_TROSAiBot.B_MANUEVER_CHOICE_COUNT++;
				}
			}
		}
	}
	if(troshx_tros_ai_TROSAiBot.AVAIL_partialevasion > 0) {
		troshx_tros_ai_TROSAiBot.B_BS_REQUIRED = troshx_tros_ai_TROSAiBot.B_BS_REQUIRED_DEFAULT;
		cp = availableCP - (troshx_tros_ai_TROSAiBot.AVAIL_partialevasion - 1) - 2;
		if(cp > 0) {
			tn = troshx_tros_ai_TROSAiBot.getDTNOfManuever("partialevasion");
			cpToUse = checkCostFunc(cp,tn,threshold,againstRoll,againstTN,(flags & 2) != 0);
			if(cpToUse > 0 && (flags & 4) != 0) {
				safetyCost = troshx_tros_ai_TROSAiBot.checkCostAntiFavorability(cp,tn,troshx_tros_ai_TROSAiBot.P_RECKLESS,againstRoll,againstTN,false,0,2);
				if(safetyCost > 0) {
					if(cpToUse < safetyCost) cpToUse = safetyCost;
				} else cpToUse = 0;
			}
			if(cpToUse > 0) {
				aggr = useCheapestMult * cpToUse + (1 - troshx_tros_ai_TROSAiBot.B_VIABLE_PROBABILITY);
				if(aggr <= curAggr) {
					if(aggr != curAggr) troshx_tros_ai_TROSAiBot.B_MANUEVER_CHOICE_COUNT = 0;
					troshx_tros_ai_TROSAiBot.MANUEVER_CHOICE.setDefend("partialevasion",cpToUse,tn,troshx_tros_ai_TROSAiBot.AVAIL_partialevasion - 1,false);
					troshx_tros_ai_TROSAiBot.addPossibleRegularManueverChoice(troshx_tros_ai_TROSAiBot.B_MANUEVER_CHOICE_COUNT);
					troshx_tros_ai_TROSAiBot.B_MANUEVER_CHOICE_PROBABILITIES[troshx_tros_ai_TROSAiBot.B_MANUEVER_CHOICE_COUNT] = troshx_tros_ai_TROSAiBot.B_VIABLE_PROBABILITY;
					troshx_tros_ai_TROSAiBot.B_MANUEVER_CHOICE_COUNT++;
				}
			}
		}
	}
	if(troshx_tros_ai_TROSAiBot.B_MANUEVER_CHOICE_COUNT > 0) {
		var randIndex = Std["int"](Math.random() * troshx_tros_ai_TROSAiBot.B_MANUEVER_CHOICE_COUNT);
		troshx_tros_ai_TROSAiBot.B_MANUEVER_CHOICES[randIndex].copyTo(troshx_tros_ai_TROSAiBot.MANUEVER_CHOICE,null);
		troshx_tros_ai_TROSAiBot.B_VIABLE_PROBABILITY_GET = troshx_tros_ai_TROSAiBot.B_MANUEVER_CHOICE_PROBABILITIES[randIndex];
		return true;
	}
	return false;
};
troshx_tros_ai_TROSAiBot.getFavorableDefense = function(availableCP,againstRoll,againstTN,heuristic,flags) {
	if(flags == null) flags = 0;
	if(heuristic == null) heuristic = true;
	if(againstTN == null) againstTN = 1;
	if(againstRoll == null) againstRoll = 0;
	return troshx_tros_ai_TROSAiBot.getFBDefense(true,availableCP,againstRoll,againstTN,heuristic,flags);
};
troshx_tros_ai_TROSAiBot.getBorderlineDefense = function(availableCP,againstRoll,againstTN,heuristic,flags) {
	if(flags == null) flags = 0;
	if(heuristic == null) heuristic = true;
	if(againstTN == null) againstTN = 1;
	if(againstRoll == null) againstRoll = 0;
	return troshx_tros_ai_TROSAiBot.getFBDefense(false,availableCP,againstRoll,againstTN,heuristic,flags);
};
troshx_tros_ai_TROSAiBot.getFleeOrDefend = function(favorable,availableCP,againstRoll,againstTN,heuristic,flags,customThreshold,secondExchange) {
	if(secondExchange == null) secondExchange = false;
	if(customThreshold == null) customThreshold = 0;
	if(flags == null) flags = 0;
	if(heuristic == null) heuristic = true;
	if(againstTN == null) againstTN = 1;
	if(againstRoll == null) againstRoll = 0;
	var threshold;
	if(customThreshold != 0) threshold = customThreshold; else if(favorable) threshold = troshx_tros_ai_TROSAiBot.P_THRESHOLD_FAVORABLE; else threshold = troshx_tros_ai_TROSAiBot.P_THRESHOLD_BORDERLINE;
	var spend;
	if(troshx_tros_ai_TROSAiBot.AVAIL_fullevasion > 0) {
		var cpToUseForFleeing;
		if(troshx_GameRules.FLEE_CAP == 0 || troshx_GameRules.FLEE_CAP == 1 && secondExchange) cpToUseForFleeing = availableCP; else if(availableCP > 6) cpToUseForFleeing = 6; else cpToUseForFleeing = availableCP;
		if(favorable) {
			spend = troshx_tros_ai_TROSAiBot.checkCostViability(cpToUseForFleeing,4,threshold,againstRoll,againstTN,(flags & 2) != 0);
			if(spend > 0) {
				troshx_tros_ai_TROSAiBot.MANUEVER_CHOICE.setDefend("fullevasion",spend,4,troshx_tros_ai_TROSAiBot.AVAIL_fullevasion - 1,false);
				troshx_tros_ai_TROSAiBot.B_VIABLE_PROBABILITY_GET = troshx_tros_ai_TROSAiBot.B_VIABLE_PROBABILITY;
				return true;
			}
		} else {
			spend = troshx_tros_ai_TROSAiBot.checkCostViabilityBorderline(cpToUseForFleeing,4,threshold,againstRoll,againstTN,(flags & 2) != 0);
			if(spend > 0) {
				troshx_tros_ai_TROSAiBot.MANUEVER_CHOICE.setDefend("fullevasion",spend,4,troshx_tros_ai_TROSAiBot.AVAIL_fullevasion - 1,false);
				troshx_tros_ai_TROSAiBot.B_VIABLE_PROBABILITY_GET = troshx_tros_ai_TROSAiBot.B_VIABLE_PROBABILITY;
				return true;
			}
		}
	}
	return troshx_tros_ai_TROSAiBot.getFBDefense(favorable,availableCP,againstRoll,againstTN,heuristic,flags);
};
troshx_tros_ai_TROSAiBot.addPossibleRegularManueverChoice = function(index) {
	troshx_tros_ai_TROSAiBot.MANUEVER_CHOICE.copyTo(index >= troshx_tros_ai_TROSAiBot.B_MANUEVER_CHOICES.length?troshx_tros_ai_TROSAiBot.B_MANUEVER_CHOICES[index] = new troshx_util_AIManueverChoice():troshx_tros_ai_TROSAiBot.B_MANUEVER_CHOICES[index],null);
};
troshx_tros_ai_TROSAiBot.getAdvantageManuever = function(manueverName,favorable,availableCP,againstRoll,againstTN,flags,customThreshold,preferedRS,defensive) {
	if(defensive == null) defensive = false;
	if(preferedRS == null) preferedRS = 1;
	if(customThreshold == null) customThreshold = 0;
	if(flags == null) flags = 0;
	if(againstTN == null) againstTN = 1;
	if(againstRoll == null) againstRoll = 0;
	var threshold;
	if(customThreshold != 0) threshold = customThreshold; else if(favorable) threshold = troshx_tros_ai_TROSAiBot.P_THRESHOLD_FAVORABLE; else threshold = troshx_tros_ai_TROSAiBot.P_THRESHOLD_BORDERLINE;
	availableCP -= troshx_tros_ai_TROSAiBot.getCostOfManuever(manueverName);
	if(availableCP > 0) {
		troshx_tros_ai_TROSAiBot.B_BS_REQUIRED = preferedRS;
		var tn;
		if(defensive) tn = troshx_tros_ai_TROSAiBot.getDTNOfManuever(manueverName); else tn = troshx_tros_ai_TROSAiBot.getATNOfManuever(manueverName);
		if(tn == 0 || tn == 888) return false;
		var costing;
		if(favorable) costing = troshx_tros_ai_TROSAiBot.checkCostViability(availableCP,tn,threshold,againstRoll,againstTN,(flags & 2) != 0); else costing = troshx_tros_ai_TROSAiBot.checkCostViabilityBorderline(availableCP,tn,threshold,againstRoll,againstTN,(flags & 2) != 0);
		troshx_tros_ai_TROSAiBot.B_BS_REQUIRED = troshx_tros_ai_TROSAiBot.B_BS_REQUIRED_DEFAULT;
		if(costing > 0) {
			if(defensive) {
				troshx_tros_ai_TROSAiBot.B_VIABLE_PROBABILITY_GET = troshx_tros_ai_TROSAiBot.B_VIABLE_PROBABILITY;
				troshx_tros_ai_TROSAiBot.MANUEVER_CHOICE.setDefend(manueverName,costing,tn,troshx_tros_ai_TROSAiBot.getCostOfManuever(manueverName),troshx_tros_ai_TROSAiBot.B_IS_OFFHAND);
			} else {
				troshx_tros_ai_TROSAiBot.B_VIABLE_PROBABILITY_GET = troshx_tros_ai_TROSAiBot.B_VIABLE_PROBABILITY;
				troshx_tros_ai_TROSAiBot.MANUEVER_CHOICE.setAttack(manueverName,costing,tn,0,troshx_tros_ai_TROSAiBot.getCostOfManuever(manueverName),troshx_tros_ai_TROSAiBot.B_IS_OFFHAND);
			}
			return true;
		}
	}
	return false;
};
troshx_tros_ai_TROSAiBot.getBlockOpenAndStrike = function(favorable,availableCP,againstRoll,againstTN,flags,customThreshold,preferedRS) {
	if(preferedRS == null) preferedRS = 1;
	if(customThreshold == null) customThreshold = 0;
	if(flags == null) flags = 0;
	if(againstTN == null) againstTN = 1;
	if(againstRoll == null) againstRoll = 0;
	if(troshx_tros_ai_TROSAiBot.AVAIL_blockopenstrike > 0) return troshx_tros_ai_TROSAiBot.getAdvantageManuever("blockopenstrike",favorable,availableCP,againstRoll,againstTN,flags,customThreshold,preferedRS,true); else return false;
};
troshx_tros_ai_TROSAiBot.getRota = function(favorable,availableCP,againstRoll,againstTN,flags,customThreshold,preferedRS) {
	if(preferedRS == null) preferedRS = 1;
	if(customThreshold == null) customThreshold = 0;
	if(flags == null) flags = 0;
	if(troshx_tros_ai_TROSAiBot.AVAIL_rota > 0) return troshx_tros_ai_TROSAiBot.getAdvantageManuever("rota",favorable,availableCP,againstRoll,againstTN,flags,customThreshold,preferedRS,true); else return false;
};
troshx_tros_ai_TROSAiBot.getCounter = function(favorable,availableCP,againstRoll,againstTN,flags,customThreshold,preferedRS) {
	if(preferedRS == null) preferedRS = 1;
	if(customThreshold == null) customThreshold = 0;
	if(flags == null) flags = 0;
	if(troshx_tros_ai_TROSAiBot.AVAIL_counter > 0) return troshx_tros_ai_TROSAiBot.getAdvantageManuever("counter",favorable,availableCP,againstRoll,againstTN,flags,customThreshold,preferedRS,true); else return false;
};
troshx_tros_ai_TROSAiBot.getExpulsion = function(favorable,availableCP,againstRoll,againstTN,flags,customThreshold,preferedRS) {
	if(preferedRS == null) preferedRS = 1;
	if(customThreshold == null) customThreshold = 0;
	if(flags == null) flags = 0;
	if(troshx_tros_ai_TROSAiBot.AVAIL_expulsion > 0) return troshx_tros_ai_TROSAiBot.getAdvantageManuever("expulsion",favorable,availableCP,againstRoll,againstTN,flags,customThreshold,preferedRS,true); else return false;
};
troshx_tros_ai_TROSAiBot.getDisarm = function(favorable,availableCP,againstRoll,againstTN,flags,customThreshold,preferedRS,defensive,disarmOffhand) {
	if(disarmOffhand == null) disarmOffhand = false;
	if(defensive == null) defensive = false;
	if(preferedRS == null) preferedRS = 1;
	if(customThreshold == null) customThreshold = 0;
	if(flags == null) flags = 0;
	if(againstTN == null) againstTN = 1;
	if(againstRoll == null) againstRoll = 0;
	var result;
	if(troshx_tros_ai_TROSAiBot.AVAIL_disarm > 0) result = troshx_tros_ai_TROSAiBot.getAdvantageManuever("disarm",favorable,availableCP,againstRoll,againstTN,flags,customThreshold,preferedRS,defensive); else result = false;
	if(disarmOffhand) troshx_tros_ai_TROSAiBot.MANUEVER_CHOICE.targetZone = 1; else troshx_tros_ai_TROSAiBot.MANUEVER_CHOICE.targetZone = 0;
	return result;
};
troshx_tros_ai_TROSAiBot.getHook = function(favorable,availableCP,againstRoll,againstTN,flags,customThreshold,preferedRS) {
	if(preferedRS == null) preferedRS = 1;
	if(customThreshold == null) customThreshold = 0;
	if(flags == null) flags = 0;
	if(againstTN == null) againstTN = 1;
	if(againstRoll == null) againstRoll = 0;
	if(troshx_tros_ai_TROSAiBot.AVAIL_hook > 0) return troshx_tros_ai_TROSAiBot.getAdvantageManuever("hook",favorable,availableCP,againstRoll,againstTN,flags,customThreshold,preferedRS,false); else return false;
};
troshx_tros_ai_TROSAiBot.getBindStrike = function(favorable,availableCP,againstCP,againstRoll,againstTN,flags,customThreshold,preferedRS) {
	if(preferedRS == null) preferedRS = 1;
	if(customThreshold == null) customThreshold = 0;
	if(flags == null) flags = 0;
	if(againstTN == null) againstTN = 1;
	if(againstRoll == null) againstRoll = 0;
	if(troshx_tros_ai_TROSAiBot.AVAIL_bindstrike > 0) return troshx_tros_ai_TROSAiBot.getAdvantageManuever("bindstrike",favorable,availableCP,againstRoll,againstTN,flags,customThreshold,preferedRS,false); else return false;
};
troshx_tros_ai_TROSAiBot.getBeat = function(favorable,availableCP,againstRoll,againstTN,flags,customThreshold,preferedRS,preferTargetMaster) {
	if(preferTargetMaster == null) preferTargetMaster = 0;
	if(preferedRS == null) preferedRS = 1;
	if(customThreshold == null) customThreshold = 0;
	if(flags == null) flags = 0;
	if(againstTN == null) againstTN = 1;
	if(againstRoll == null) againstRoll = 0;
	if(troshx_tros_ai_TROSAiBot.AVAIL_bindstrike > 0) {
		var result = troshx_tros_ai_TROSAiBot.getAdvantageManuever("beat",favorable,availableCP,againstRoll,againstTN,flags,customThreshold,preferedRS,false);
		if(result) {
			var master = troshx_tros_ai_TROSAiBot.CURRENT_OPPONENT.getMasterDTN();
			var shield = troshx_tros_ai_TROSAiBot.CURRENT_OPPONENT.getShieldDTN();
			if(master == 0 || shield == 0) {
				if(shield == 0) troshx_tros_ai_TROSAiBot.MANUEVER_CHOICE.targetZone = 0; else troshx_tros_ai_TROSAiBot.MANUEVER_CHOICE.targetZone = 1;
			} else if(shield < master - preferTargetMaster) troshx_tros_ai_TROSAiBot.MANUEVER_CHOICE.targetZone = 1; else troshx_tros_ai_TROSAiBot.MANUEVER_CHOICE.targetZone = 0;
		}
		return result;
	}
	return false;
};
troshx_tros_ai_TROSAiBot.getRotaOrCounter = function(favorable,availableCP,againstManuever,flags,customThreshold,preferedRS,preferedCounterRSFav,counterFavProbThreshold) {
	if(counterFavProbThreshold == null) counterFavProbThreshold = 0.75;
	if(preferedCounterRSFav == null) preferedCounterRSFav = 0;
	if(preferedRS == null) preferedRS = 1;
	if(customThreshold == null) customThreshold = 0;
	if(flags == null) flags = 0;
	if(preferedCounterRSFav > 0 && troshx_util_TROSAI.getAtLeastXSuccessesProb(againstManuever.manueverCP,againstManuever.manueverTN,preferedCounterRSFav) < counterFavProbThreshold) return false;
	if(troshx_tros_ai_TROSAiBot.AVAIL_rota <= 0 && troshx_tros_ai_TROSAiBot.AVAIL_counter <= 0) return false;
	if(troshx_tros_ai_TROSAiBot.AVAIL_rota <= 0 || troshx_tros_ai_TROSAiBot.AVAIL_counter <= 0) if(troshx_tros_ai_TROSAiBot.AVAIL_rota <= 0) {
		if(troshx_tros_ai_TROSAiBot.AVAIL_counter > 0) return troshx_tros_ai_TROSAiBot.getAdvantageManuever("counter",favorable,availableCP,againstManuever.manueverCP,againstManuever.manueverTN,flags,customThreshold,preferedRS,true); else return false;
	} else if(troshx_tros_ai_TROSAiBot.AVAIL_rota > 0) return troshx_tros_ai_TROSAiBot.getAdvantageManuever("rota",favorable,availableCP,againstManuever.manueverCP,againstManuever.manueverTN,flags,customThreshold,preferedRS,true); else return false;
	var rotaBarrier = 888;
	var counterBarrier = 888;
	var rotaAVOffset = 888;
	if(troshx_tros_ai_TROSAiBot.AVAIL_rota > 0) {
		rotaBarrier = troshx_tros_ai_TROSAiBot.AVAIL_rota - 1;
		rotaBarrier += rotaAVOffset = troshx_tros_ai_TROSAiBot.getTargetZoneAverageAVOffset(againstManuever.targetZone,troshx_tros_ai_TROSAiBot.B_EQUIP);
	}
	if(troshx_tros_ai_TROSAiBot.AVAIL_counter > 0) counterBarrier = troshx_tros_ai_TROSAiBot.AVAIL_counter - 1;
	if(rotaBarrier < counterBarrier) {
		if(troshx_tros_ai_TROSAiBot.AVAIL_rota > 0) return troshx_tros_ai_TROSAiBot.getAdvantageManuever("rota",favorable,availableCP,againstManuever.manueverCP,againstManuever.manueverTN,flags,customThreshold,preferedRS,true); else return false;
	} else if(troshx_tros_ai_TROSAiBot.AVAIL_counter > 0) return troshx_tros_ai_TROSAiBot.getAdvantageManuever("counter",favorable,availableCP,againstManuever.manueverCP,againstManuever.manueverTN,flags,customThreshold,preferedRS,true); else return false;
};
troshx_tros_ai_TROSAiBot.getBlockOpenOrExpulsion = function(favorable,availableCP,againstManuever,flags,customThreshold,preferedRS) {
	if(preferedRS == null) preferedRS = 0;
	if(customThreshold == null) customThreshold = 0;
	if(flags == null) flags = 0;
	if(troshx_tros_ai_TROSAiBot.AVAIL_blockopenstrike <= 0 && troshx_tros_ai_TROSAiBot.AVAIL_expulsion <= 0) return false;
	if(troshx_tros_ai_TROSAiBot.AVAIL_blockopenstrike <= 0 || troshx_tros_ai_TROSAiBot.AVAIL_expulsion <= 0) if(troshx_tros_ai_TROSAiBot.AVAIL_expulsion <= 0) return troshx_tros_ai_TROSAiBot.getBlockOpenAndStrike(favorable,availableCP,againstManuever.manueverCP,againstManuever.manueverTN,flags,customThreshold,preferedRS > 0?preferedRS:troshx_tros_ai_TROSAiBot.AVAIL_blockopenstrike - 1); else if(troshx_tros_ai_TROSAiBot.AVAIL_expulsion > 0) return troshx_tros_ai_TROSAiBot.getAdvantageManuever("expulsion",favorable,availableCP,againstManuever.manueverCP,againstManuever.manueverTN,flags,customThreshold,preferedRS > 0?preferedRS:troshx_tros_ai_TROSAiBot.AVAIL_expulsion - 1,true); else return false;
	var bosProbability = 0;
	var considerExpul = troshx_tros_ai_TROSAiBot.CURRENT_OPPONENT.isThruster() && troshx_tros_ai_TROSAiBot.AVAIL_expulsion > 0;
	if(troshx_tros_ai_TROSAiBot.AVAIL_blockopenstrike > 0) {
		if(!considerExpul || troshx_tros_ai_TROSAiBot.getBlockOpenAndStrike(favorable,availableCP,againstManuever.manueverCP,againstManuever.manueverTN,2,customThreshold,preferedRS > 0?preferedRS:troshx_tros_ai_TROSAiBot.AVAIL_blockopenstrike - 1)) {
			if(!considerExpul) return troshx_tros_ai_TROSAiBot.getBlockOpenAndStrike(favorable,availableCP,againstManuever.manueverCP,againstManuever.manueverTN,flags,customThreshold,preferedRS > 0?preferedRS:troshx_tros_ai_TROSAiBot.AVAIL_blockopenstrike - 1); else bosProbability = troshx_tros_ai_TROSAiBot.B_VIABLE_PROBABILITY;
		} else if(troshx_tros_ai_TROSAiBot.AVAIL_expulsion > 0) return troshx_tros_ai_TROSAiBot.getAdvantageManuever("expulsion",favorable,availableCP,againstManuever.manueverCP,againstManuever.manueverTN,flags,customThreshold,preferedRS > 0?preferedRS:troshx_tros_ai_TROSAiBot.AVAIL_expulsion - 1,true); else return false;
	}
	if(considerExpul) {
		if(troshx_tros_ai_TROSAiBot.AVAIL_expulsion > 0?troshx_tros_ai_TROSAiBot.getAdvantageManuever("expulsion",favorable,availableCP,againstManuever.manueverCP,againstManuever.manueverTN,2,customThreshold,preferedRS > 0?preferedRS:troshx_tros_ai_TROSAiBot.AVAIL_expulsion - 1,true):false) {
			if(troshx_tros_ai_TROSAiBot.B_VIABLE_PROBABILITY > bosProbability) if(troshx_tros_ai_TROSAiBot.AVAIL_expulsion > 0) return troshx_tros_ai_TROSAiBot.getAdvantageManuever("expulsion",favorable,availableCP,againstManuever.manueverCP,againstManuever.manueverTN,flags,customThreshold,preferedRS > 0?preferedRS:troshx_tros_ai_TROSAiBot.AVAIL_expulsion - 1,true); else return false;
		}
		if(bosProbability != 0) return troshx_tros_ai_TROSAiBot.getBlockOpenAndStrike(favorable,availableCP,againstManuever.manueverCP,againstManuever.manueverTN,flags,customThreshold,preferedRS > 0?preferedRS:troshx_tros_ai_TROSAiBot.AVAIL_blockopenstrike - 1);
	}
	return false;
};
troshx_tros_ai_TROSAiBot.getAdvantageGainCPOffensiveMove = function(favorable,availableCP,againstRoll,againstTN,flags,customThreshold,preferedRS,preferTargetMaster) {
	if(preferTargetMaster == null) preferTargetMaster = 0;
	if(preferedRS == null) preferedRS = 1;
	if(customThreshold == null) customThreshold = 0;
	if(flags == null) flags = 0;
	if(againstTN == null) againstTN = 1;
	if(againstRoll == null) againstRoll = 0;
	troshx_tros_ai_TROSAiBot.B_BS_REQUIRED = troshx_tros_ai_TROSAiBot.B_BS_REQUIRED_DEFAULT;
	var threshold;
	if(customThreshold != 0) threshold = customThreshold; else if(favorable) threshold = troshx_tros_ai_TROSAiBot.P_THRESHOLD_FAVORABLE; else threshold = troshx_tros_ai_TROSAiBot.P_THRESHOLD_BORDERLINE;
	var manuever = troshx_tros_ai_TROSAiBot.getRegularAdvantageMove(availableCP,0,againstRoll,againstTN);
	if(manuever != null) {
		var tn = troshx_tros_ai_TROSAiBot.getATNOfManuever(manuever);
		var cost = troshx_tros_ai_TROSAiBot.getCostOfManuever(manuever);
		availableCP -= cost;
		if(availableCP > 0) {
			var cpToUse;
			if(favorable) cpToUse = troshx_tros_ai_TROSAiBot.checkCostViability(availableCP,tn,threshold,againstRoll,againstTN,(flags & 2) != 0); else cpToUse = troshx_tros_ai_TROSAiBot.checkCostViabilityBorderline(availableCP,tn,threshold,againstRoll,againstTN,(flags & 2) != 0);
			if(cpToUse > 0) {
				troshx_tros_ai_TROSAiBot.B_VIABLE_PROBABILITY_GET = troshx_tros_ai_TROSAiBot.B_VIABLE_PROBABILITY;
				troshx_tros_ai_TROSAiBot.MANUEVER_CHOICE.setAttack(manuever,cpToUse,tn,0,cost,troshx_tros_ai_TROSAiBot.B_IS_OFFHAND);
				return true;
			}
		}
	}
	return false;
};
troshx_tros_ai_TROSAiBot.getPredictedOpponentDTN = function() {
	return troshx_tros_ai_TROSAiBot.CURRENT_OPPONENT.getPredictedDTN();
};
troshx_tros_ai_TROSAiBot.getPredictedOpponentATN = function() {
	return troshx_tros_ai_TROSAiBot.CURRENT_OPPONENT.getPredictedATN();
};
troshx_tros_ai_TROSAiBot.fluctuateLower = function(val,lowerBy) {
	if(lowerBy >= val) lowerBy = val * .5; else lowerBy = lowerBy;
	val -= Math.random() * lowerBy;
	return val;
};
troshx_tros_ai_TROSAiBot.getComboExchangeBudgetingWithInitiative = function(combo,cp,cp2,threatManuever) {
	var lastDefault;
	if(threatManuever != null && threatManuever.manuever == "") threatManuever = null;
	var dtn = troshx_tros_ai_TROSAiBot.CURRENT_OPPONENT.getPredictedDTN();
	var stipulateRemaining;
	if(combo > 0) switch(combo) {
	case 1:
		stipulateRemaining = Math.floor(cp2 * .5);
		if((troshx_tros_ai_TROSAiBot.getFavorableAttack(Math.floor(cp * .5),stipulateRemaining,dtn,false,1,null) || troshx_tros_ai_TROSAiBot.getAdvantageGainCPOffensiveMove(true,Math.floor(cp * .5),stipulateRemaining,dtn,1)) && cp - troshx_tros_ai_TROSAiBot.MANUEVER_CHOICE.getManueverCPSpent() >= Math.ceil(cp * .5) || (troshx_tros_ai_TROSAiBot.getBorderlineAttack(Math.floor(cp * .5),stipulateRemaining,dtn,false,1) || troshx_tros_ai_TROSAiBot.getAdvantageGainCPOffensiveMove(false,Math.floor(cp * .5),stipulateRemaining,dtn,1))) {
			cp -= troshx_tros_ai_TROSAiBot.MANUEVER_CHOICE.getManueverCPSpent();
			troshx_tros_ai_TROSAiBot.B_COMBO_EXCHANGE_BUDGET[0] = cp;
			var val = Math.ceil(cp2 * .5);
			troshx_tros_ai_TROSAiBot.B_COMBO_EXCHANGE_BUDGET[1] = val;
			var val1 = troshx_tros_ai_TROSAiBot.MANUEVER_CHOICE.getManueverCPSpent();
			troshx_tros_ai_TROSAiBot.B_COMBO_EXCHANGE_BUDGET[2] = val1;
			troshx_tros_ai_TROSAiBot.B_COMBO_EXCHANGE_BUDGET[3] = stipulateRemaining;
			if(troshx_tros_ai_TROSAiBot.getBorderlineAttack(cp,troshx_tros_ai_TROSAiBot.B_COMBO_EXCHANGE_BUDGET[1],dtn,false,2) || troshx_tros_ai_TROSAiBot.getAdvantageGainCPOffensiveMove(false,cp,troshx_tros_ai_TROSAiBot.B_COMBO_EXCHANGE_BUDGET[1],dtn,2)) return troshx_tros_ai_TROSAiBot.B_COMBO_EXCHANGE_BUDGET;
		}
		break;
	case 2:
		if(troshx_tros_ai_TROSAiBot.getAForcefulInitiativeAttack(troshx_tros_ai_TROSAiBot.P_THRESHOLD_FAVORABLE,cp,cp2,dtn,true,false,0)) {
			stipulateRemaining = 0;
			var consideredCP = troshx_tros_ai_TROSAiBot.MANUEVER_CHOICE.getManueverCPSpent();
			lastDefault = troshx_tros_ai_TROSAiBot.B_BS_REQUIRED_DEFAULT;
			troshx_tros_ai_TROSAiBot.B_BS_REQUIRED_DEFAULT = 0;
			troshx_tros_ai_TROSAiBot.getFBAttack(true,cp,cp2 * .5 | 0,dtn,false,1,0);
			if(troshx_tros_ai_TROSAiBot.MANUEVER_CHOICE.getManueverCPSpent() > consideredCP) consideredCP = troshx_tros_ai_TROSAiBot.MANUEVER_CHOICE.getManueverCPSpent();
			if(consideredCP < Math.ceil(cp * .5)) consideredCP = Math.ceil(cp * .5);
			troshx_tros_ai_TROSAiBot.B_BS_REQUIRED_DEFAULT = lastDefault;
			troshx_tros_ai_TROSAiBot.B_COMBO_EXCHANGE_BUDGET[0] = consideredCP;
			troshx_tros_ai_TROSAiBot.B_COMBO_EXCHANGE_BUDGET[1] = cp2;
			cp -= consideredCP;
			if(cp > 2 && (troshx_tros_ai_TROSAiBot.getFBAttack(true,cp,stipulateRemaining,dtn,false,2,0.5) || troshx_tros_ai_TROSAiBot.getAdvantageGainCPOffensiveMove(true,cp,stipulateRemaining,dtn,2,0.5))) {
				var val2 = troshx_tros_ai_TROSAiBot.MANUEVER_CHOICE.getManueverCPSpent();
				troshx_tros_ai_TROSAiBot.B_COMBO_EXCHANGE_BUDGET[2] = val2;
				troshx_tros_ai_TROSAiBot.B_COMBO_EXCHANGE_BUDGET[3] = stipulateRemaining;
				return troshx_tros_ai_TROSAiBot.B_COMBO_EXCHANGE_BUDGET;
			}
		}
		break;
	case 3:
		troshx_tros_ai_TROSAiBot.setAlphaStrikeBudget(cp,cp2);
		if(troshx_tros_ai_TROSAiBot.getDisarm(true,troshx_tros_ai_TROSAiBot.B_COMBO_EXCHANGE_BUDGET[0],cp2,dtn,2,0,troshx_tros_ai_TROSAiBot.PREFERED_DISARM_BS,false)) return troshx_tros_ai_TROSAiBot.B_COMBO_EXCHANGE_BUDGET;
		break;
	case 4:
		if(troshx_tros_ai_TROSAiBot.AVAIL_hook > 0?troshx_tros_ai_TROSAiBot.getAdvantageManuever("hook",true,troshx_tros_ai_TROSAiBot.B_COMBO_EXCHANGE_BUDGET[0],cp2,dtn,2,0,troshx_tros_ai_TROSAiBot.PREFERED_HOOK_BS,false):false) return troshx_tros_ai_TROSAiBot.B_COMBO_EXCHANGE_BUDGET;
		break;
	case 5:
		if(troshx_tros_ai_TROSAiBot.getFBAttack(true,troshx_tros_ai_TROSAiBot.B_COMBO_EXCHANGE_BUDGET[0],cp2,dtn,false,2,0)) return troshx_tros_ai_TROSAiBot.B_COMBO_EXCHANGE_BUDGET;
		break;
	case 6:
		break;
	case 7:
		break;
	case 8:
		break;
	case 9:
		lastDefault = troshx_tros_ai_TROSAiBot.B_BS_REQUIRED_DMG_DEFAULT;
		troshx_tros_ai_TROSAiBot.B_BS_REQUIRED_DMG_DEFAULT += 1;
		if(cp2 < troshx_tros_ai_TROSAiBot.ENEMY_STEAL_COST + 1 + troshx_tros_ai_TROSAiBot.MIN_EXPOSED_AV && troshx_tros_ai_TROSAiBot.getFBAttack(true,cp,cp2,dtn,true,2,cp2 >= 2?0:cp2 == 0?0.00001:0.5)) {
			troshx_tros_ai_TROSAiBot.B_COMBO_EXCHANGE_BUDGET[2] = 0;
			troshx_tros_ai_TROSAiBot.B_COMBO_EXCHANGE_BUDGET[3] = -1;
			troshx_tros_ai_TROSAiBot.B_COMBO_EXCHANGE_BUDGET[0] = cp;
			troshx_tros_ai_TROSAiBot.B_COMBO_EXCHANGE_BUDGET[1] = cp2;
			troshx_tros_ai_TROSAiBot.B_BS_REQUIRED_DMG_DEFAULT = lastDefault;
			return troshx_tros_ai_TROSAiBot.B_COMBO_EXCHANGE_BUDGET;
		}
		troshx_tros_ai_TROSAiBot.B_BS_REQUIRED_DMG_DEFAULT = lastDefault;
		break;
	}
	return null;
};
troshx_tros_ai_TROSAiBot.tryFavoredElseBorderlineAttacks = function(cp,cp2,dtn,heuristic,flags) {
	return troshx_tros_ai_TROSAiBot.getFBAttack(true,cp,cp2,dtn,heuristic,flags,0) || troshx_tros_ai_TROSAiBot.getAdvantageGainCPOffensiveMove(true,cp,cp2,dtn,flags) || troshx_tros_ai_TROSAiBot.getBorderlineAttack(cp,cp2,dtn,heuristic,flags) || troshx_tros_ai_TROSAiBot.getAdvantageGainCPOffensiveMove(false,cp,cp2,dtn,flags);
};
troshx_tros_ai_TROSAiBot.getComboAction = function(combo,cp,cp2,threatManuever,hasInitiative,secondExchange) {
	if(secondExchange == null) secondExchange = false;
	if(hasInitiative == null) hasInitiative = true;
	var flags = 2;
	var lastInt;
	var result;
	var dtn = troshx_tros_ai_TROSAiBot.CURRENT_OPPONENT.getPredictedDTN();
	if(hasInitiative) switch(combo) {
	case 1:
		return troshx_tros_ai_TROSAiBot.getFBAttack(true,cp,cp2,dtn,true,flags,0) || troshx_tros_ai_TROSAiBot.getAdvantageGainCPOffensiveMove(true,cp,cp2,dtn,flags) || troshx_tros_ai_TROSAiBot.getBorderlineAttack(cp,cp2,dtn,true,flags) || troshx_tros_ai_TROSAiBot.getAdvantageGainCPOffensiveMove(false,cp,cp2,dtn,flags);
	case 2:
		if(!secondExchange) return troshx_tros_ai_TROSAiBot.getAForcefulInitiativeAttack(troshx_tros_ai_TROSAiBot.P_THRESHOLD_FAVORABLE,cp,cp2,dtn,true,true,0); else return troshx_tros_ai_TROSAiBot.getFBAttack(true,cp,cp2,dtn,true,flags,0) || troshx_tros_ai_TROSAiBot.getAdvantageGainCPOffensiveMove(true,cp,cp2,dtn,flags) || troshx_tros_ai_TROSAiBot.getBorderlineAttack(cp,cp2,dtn,true,flags) || troshx_tros_ai_TROSAiBot.getAdvantageGainCPOffensiveMove(false,cp,cp2,dtn,flags);
		break;
	case 3:
		if(!secondExchange) return !troshx_tros_ai_TROSAiBot.CURRENT_OPPONENT.isDualWeilding() && troshx_tros_ai_TROSAiBot.getDisarm(true,cp,cp2,dtn,flags,0,troshx_tros_ai_TROSAiBot.PREFERED_DISARM_BS,false); else return troshx_tros_ai_TROSAiBot.getFBAttack(true,cp,cp2,dtn,true,flags,0) || troshx_tros_ai_TROSAiBot.getBorderlineAttack(cp,cp2,dtn,true,flags) || troshx_tros_ai_TROSAiBot.getAdvantageGainCPOffensiveMove(false,cp,cp2,dtn,flags);
		break;
	case 4:
		if(!secondExchange) if(troshx_tros_ai_TROSAiBot.AVAIL_hook > 0) return troshx_tros_ai_TROSAiBot.getAdvantageManuever("hook",true,cp,cp2,dtn,flags,0,troshx_tros_ai_TROSAiBot.PREFERED_HOOK_BS,false); else return false; else return troshx_tros_ai_TROSAiBot.getFBAttack(true,cp,cp2,dtn,true,flags,0) || troshx_tros_ai_TROSAiBot.getAdvantageGainCPOffensiveMove(true,cp,cp2,dtn,flags) || troshx_tros_ai_TROSAiBot.getBorderlineAttack(cp,cp2,dtn,true,flags) || troshx_tros_ai_TROSAiBot.getAdvantageGainCPOffensiveMove(false,cp,cp2,dtn,flags);
		break;
	case 5:
		if(!secondExchange) return troshx_tros_ai_TROSAiBot.getFBAttack(true,cp,cp2,dtn,true,flags,0); else return troshx_tros_ai_TROSAiBot.getFBAttack(true,cp,cp2,dtn,true,flags,0) || troshx_tros_ai_TROSAiBot.getAdvantageGainCPOffensiveMove(true,cp,cp2,dtn,flags) || troshx_tros_ai_TROSAiBot.getBorderlineAttack(cp,cp2,dtn,true,flags) || troshx_tros_ai_TROSAiBot.getAdvantageGainCPOffensiveMove(false,cp,cp2,dtn,flags);
		break;
	case 6:
		if(!secondExchange) {
		} else return troshx_tros_ai_TROSAiBot.getFBAttack(true,cp,cp2,dtn,true,flags,0) || troshx_tros_ai_TROSAiBot.getAdvantageGainCPOffensiveMove(true,cp,cp2,dtn,flags) || troshx_tros_ai_TROSAiBot.getBorderlineAttack(cp,cp2,dtn,true,flags) || troshx_tros_ai_TROSAiBot.getAdvantageGainCPOffensiveMove(false,cp,cp2,dtn,flags);
		break;
	case 7:
		if(!secondExchange) {
		} else return troshx_tros_ai_TROSAiBot.getFBAttack(true,cp,cp2,dtn,true,flags,0) || troshx_tros_ai_TROSAiBot.getAdvantageGainCPOffensiveMove(true,cp,cp2,dtn,flags) || troshx_tros_ai_TROSAiBot.getBorderlineAttack(cp,cp2,dtn,true,flags) || troshx_tros_ai_TROSAiBot.getAdvantageGainCPOffensiveMove(false,cp,cp2,dtn,flags);
		break;
	case 8:
		if(!secondExchange) {
		} else return troshx_tros_ai_TROSAiBot.getFBAttack(true,cp,cp2,dtn,true,flags,0) || troshx_tros_ai_TROSAiBot.getAdvantageGainCPOffensiveMove(true,cp,cp2,dtn,flags) || troshx_tros_ai_TROSAiBot.getBorderlineAttack(cp,cp2,dtn,true,flags) || troshx_tros_ai_TROSAiBot.getAdvantageGainCPOffensiveMove(false,cp,cp2,dtn,flags);
		break;
	case 9:
		lastInt = troshx_tros_ai_TROSAiBot.B_BS_REQUIRED_DMG_DEFAULT;
		troshx_tros_ai_TROSAiBot.B_BS_REQUIRED_DMG_DEFAULT += 1;
		result = cp2 < troshx_tros_ai_TROSAiBot.ENEMY_STEAL_COST + 1 + troshx_tros_ai_TROSAiBot.MIN_EXPOSED_AV && troshx_tros_ai_TROSAiBot.getFBAttack(true,cp,cp2,dtn,true,flags,cp2 >= 2?0:cp2 == 0?0.00001:0.5);
		troshx_tros_ai_TROSAiBot.B_BS_REQUIRED_DMG_DEFAULT = lastInt;
		return result;
	case -1:
		return troshx_tros_ai_TROSAiBot.getFBAttack(true,cp,cp2,dtn,true,flags,0) || troshx_tros_ai_TROSAiBot.getAdvantageGainCPOffensiveMove(true,cp,cp2,dtn,flags) || troshx_tros_ai_TROSAiBot.getBorderlineAttack(cp,cp2,dtn,true,flags) || troshx_tros_ai_TROSAiBot.getAdvantageGainCPOffensiveMove(false,cp,cp2,dtn,flags);
	case -3:
		return troshx_tros_ai_TROSAiBot.getFBAttack(true,cp,cp2,dtn,true,flags,0) || troshx_tros_ai_TROSAiBot.getAdvantageGainCPOffensiveMove(true,cp,cp2,dtn,flags) || troshx_tros_ai_TROSAiBot.getBorderlineAttack(cp,cp2,dtn,true,flags) || troshx_tros_ai_TROSAiBot.getAdvantageGainCPOffensiveMove(false,cp,cp2,dtn,flags);
	case -4:
		return troshx_tros_ai_TROSAiBot.getFBAttack(true,cp,cp2,dtn,true,flags,0) || troshx_tros_ai_TROSAiBot.getAdvantageGainCPOffensiveMove(true,cp,cp2,dtn,flags) || troshx_tros_ai_TROSAiBot.getBorderlineAttack(cp,cp2,dtn,true,flags) || troshx_tros_ai_TROSAiBot.getAdvantageGainCPOffensiveMove(false,cp,cp2,dtn,flags);
	case -5:
		return troshx_tros_ai_TROSAiBot.getFBAttack(true,cp,cp2,dtn,true,flags,0) || troshx_tros_ai_TROSAiBot.getAdvantageGainCPOffensiveMove(true,cp,cp2,dtn,flags) || troshx_tros_ai_TROSAiBot.getBorderlineAttack(cp,cp2,dtn,true,flags) || troshx_tros_ai_TROSAiBot.getAdvantageGainCPOffensiveMove(false,cp,cp2,dtn,flags);
	} else switch(combo) {
	case 1:
		break;
	case 2:
		break;
	case 3:
		break;
	case 4:
		break;
	case 5:
		break;
	case 6:
		break;
	case 7:
		break;
	case 8:
		break;
	case 9:
		break;
	case -1:
		if(threatManuever != null) {
			if(!secondExchange) {
				lastInt = troshx_tros_ai_TROSAiBot.getCheapestBorderlineAtkCost(cp,cp2 - threatManuever.manueverCP,dtn);
				if(lastInt > 0) {
					cp -= lastInt;
					return troshx_tros_ai_TROSAiBot.getFBDefense(true,cp,threatManuever.manueverCP,threatManuever.manueverTN,true,2,0);
				}
			}
		}
		break;
	case -2:
		if(threatManuever != null) {
			if(!secondExchange) {
				if(troshx_tros_ai_TROSAiBot.getFleeOrDefend(false,cp,cp2 - threatManuever.manueverCP,troshx_tros_ai_TROSAiBot.CURRENT_OPPONENT.getPredictedATN(),false,5,0,true)) {
					cp -= troshx_tros_ai_TROSAiBot.MANUEVER_CHOICE.getManueverCPSpent();
					return troshx_tros_ai_TROSAiBot.getFBDefense(false,cp,threatManuever.manueverCP,threatManuever.manueverTN,true,4,0);
				}
			}
		}
		break;
	case -4:
		if(threatManuever != null) return troshx_tros_ai_TROSAiBot.getDisarm(true,cp,threatManuever.manueverCP,threatManuever.manueverTN,0,0,troshx_tros_ai_TROSAiBot.PREFERED_DISARM_DEF_BS,true,threatManuever.offhand);
		break;
	case -3:
		break;
	case -5:
		break;
	}
	return false;
};
troshx_tros_ai_TROSAiBot.getCheapestBorderlineAtkCost = function(cp,againstCP,dtn,customThreshold) {
	if(customThreshold == null) customThreshold = 0;
	var cpToSpend = 0;
	if(troshx_tros_ai_TROSAiBot.getAdvantageGainCPOffensiveMove(false,cp,againstCP,dtn,1,customThreshold)) cpToSpend = troshx_tros_ai_TROSAiBot.MANUEVER_CHOICE.getManueverCPSpent();
	if(troshx_tros_ai_TROSAiBot.getFBAttack(false,cp,againstCP,dtn,false,1,customThreshold)) {
		if(troshx_tros_ai_TROSAiBot.MANUEVER_CHOICE.getManueverCPSpent() < cpToSpend) cpToSpend = troshx_tros_ai_TROSAiBot.MANUEVER_CHOICE.getManueverCPSpent();
	}
	return cpToSpend;
};
troshx_tros_ai_TROSAiBot.getCoupThreshold = function(cp2) {
	if(cp2 >= 2) return 0; else if(cp2 == 0) return 0.00001; else return 0.5;
};
troshx_tros_ai_TROSAiBot.addPossibleComboManueverChoice = function(index,theChoice) {
	theChoice.copyTo(index >= troshx_tros_ai_TROSAiBot.B_COMBO_CANDIDATE_MANUEVER.length?troshx_tros_ai_TROSAiBot.B_COMBO_CANDIDATE_MANUEVER[index] = new troshx_util_AIManueverChoice():troshx_tros_ai_TROSAiBot.B_COMBO_CANDIDATE_MANUEVER[index],null);
};
troshx_tros_ai_TROSAiBot.setBestComboActionWithInitiativePlan = function(cp,cp2,threatManuever) {
	troshx_tros_ai_TROSAiBot.B_COMBO_CANDIDATE_COUNT = 0;
	if(troshx_tros_ai_TROSAiBot.CURRENT_OPPONENT.initiative) {
		if(threatManuever != null && threatManuever.manueverType == 2) {
		}
	}
	var budget;
	var _g = 9;
	while(_g < 10) {
		var i1 = _g++;
		budget = troshx_tros_ai_TROSAiBot.getComboExchangeBudgetingWithInitiative(i1,cp,cp2,threatManuever);
		if(budget != null) {
			if(troshx_tros_ai_TROSAiBot.getComboAction(i1,budget[0],budget[1],threatManuever,true,false)) {
				troshx_tros_ai_TROSAiBot.MANUEVER_CHOICE.copyTo(troshx_tros_ai_TROSAiBot.MANUEVER_CHOICE_CONSIDER_MASTER,null);
				if(budget[3] == -1 || troshx_tros_ai_TROSAiBot.getComboAction(i1,budget[2],budget[3],threatManuever,true,true)) {
					troshx_tros_ai_TROSAiBot.MANUEVER_COMBO_SET = i1;
					troshx_tros_ai_TROSAiBot.MANUEVER_CHOICE_SET = troshx_tros_ai_TROSAiBot.MANUEVER_CHOICE_CONSIDER_MASTER;
					return true;
				}
			}
		}
	}
	var i = 1;
	var curProbability = 0;
	var probabilityCheck;
	var len = 9;
	while(i < 9) {
		budget = troshx_tros_ai_TROSAiBot.getComboExchangeBudgetingWithInitiative(i,cp,cp2,threatManuever);
		if(budget != null) {
			if(troshx_tros_ai_TROSAiBot.getComboAction(i,budget[0],budget[1],threatManuever,true,false)) {
				probabilityCheck = troshx_tros_ai_TROSAiBot.B_VIABLE_PROBABILITY_GET;
				troshx_tros_ai_TROSAiBot.MANUEVER_CHOICE.copyTo(troshx_tros_ai_TROSAiBot.MANUEVER_CHOICE_1,null);
				if(budget[3] == -1 || troshx_tros_ai_TROSAiBot.getComboAction(i,budget[2],budget[3],threatManuever,true,true)) {
					troshx_tros_ai_TROSAiBot.B_COMBO_CANDIDATES[troshx_tros_ai_TROSAiBot.B_COMBO_CANDIDATE_COUNT] = i;
					troshx_tros_ai_TROSAiBot.addPossibleComboManueverChoice(troshx_tros_ai_TROSAiBot.B_COMBO_CANDIDATE_COUNT,troshx_tros_ai_TROSAiBot.MANUEVER_CHOICE_1);
					curProbability = probabilityCheck;
					troshx_tros_ai_TROSAiBot.B_COMBO_CANDIDATE_COUNT++;
				}
			}
		}
		i++;
	}
	if(troshx_tros_ai_TROSAiBot.B_COMBO_CANDIDATE_COUNT > 0) {
		var randIndex = Std["int"](Math.random() * troshx_tros_ai_TROSAiBot.B_COMBO_CANDIDATE_COUNT);
		troshx_tros_ai_TROSAiBot.MANUEVER_COMBO_SET = troshx_tros_ai_TROSAiBot.B_COMBO_CANDIDATES[randIndex];
		troshx_tros_ai_TROSAiBot.MANUEVER_CHOICE_SET = troshx_tros_ai_TROSAiBot.B_COMBO_CANDIDATE_MANUEVER[randIndex];
		return true;
	}
	return false;
};
troshx_tros_ai_TROSAiBot.setBestComboActionWithoutInitiativePlan = function(cp,cp2,threatManuever) {
	troshx_tros_ai_TROSAiBot.B_COMBO_CANDIDATE_COUNT = 0;
	var i = 1;
	var curProbability = 0;
	var probabilityCheck;
	var len = 5;
	if(threatManuever == null || threatManuever.manueverType != 2) {
	}
	while(i < len) {
		if(troshx_tros_ai_TROSAiBot.getComboAction(-i,cp,cp2,threatManuever,false,false)) {
			probabilityCheck = troshx_tros_ai_TROSAiBot.B_VIABLE_PROBABILITY_GET;
			troshx_tros_ai_TROSAiBot.MANUEVER_CHOICE.copyTo(troshx_tros_ai_TROSAiBot.MANUEVER_CHOICE_1,null);
			troshx_tros_ai_TROSAiBot.B_COMBO_CANDIDATES[troshx_tros_ai_TROSAiBot.B_COMBO_CANDIDATE_COUNT] = -i;
			troshx_tros_ai_TROSAiBot.addPossibleComboManueverChoice(troshx_tros_ai_TROSAiBot.B_COMBO_CANDIDATE_COUNT,troshx_tros_ai_TROSAiBot.MANUEVER_CHOICE_1);
			curProbability = probabilityCheck;
			troshx_tros_ai_TROSAiBot.B_COMBO_CANDIDATE_COUNT++;
		}
		i++;
	}
	if(troshx_tros_ai_TROSAiBot.B_COMBO_CANDIDATE_COUNT > 0) {
		var randIndex = Std["int"](Math.random() * troshx_tros_ai_TROSAiBot.B_COMBO_CANDIDATE_COUNT);
		troshx_tros_ai_TROSAiBot.MANUEVER_COMBO_SET = troshx_tros_ai_TROSAiBot.B_COMBO_CANDIDATES[randIndex];
		troshx_tros_ai_TROSAiBot.MANUEVER_CHOICE_SET = troshx_tros_ai_TROSAiBot.B_COMBO_CANDIDATE_MANUEVER[randIndex];
		return true;
	}
	return false;
};
troshx_tros_ai_TROSAiBot.prototype = {
	opponents: null
	,opponentLen: null
	,cpBudget: null
	,plannedCombos: null
	,currentExchange: null
	,body: null
	,cp: null
	,perception: null
	,equipMasterhand: null
	,equipOffhand: null
	,mobility: null
	,id: null
	,initiative: null
	,stance: null
	,manueverUsingHands: null
	,handsUsedUp: null
	,decidedStance: null
	,decidedOrientation: null
	,decidedManuevers: null
	,getDecidedManueverForSlot: function(slot) {
		if(this.decidedManuevers[slot] != null) return this.decidedManuevers[slot].manuever; else return "";
	}
	,getDecidedManueverCP: function(slot) {
		if(this.decidedManuevers[slot] != null) return this.decidedManuevers[slot].manueverCP; else return 0;
	}
	,getDecidedManueverTargetZone: function(slot) {
		if(this.decidedManuevers[slot] != null) return this.decidedManuevers[slot].targetZone; else return 0;
	}
	,isThruster: function() {
		return false;
	}
	,getPredictedDTN: function() {
		var weapon;
		var dtn = 7;
		if((this.manueverUsingHands & 1) == 0) weapon = troshx_tros_WeaponSheet.getWeaponByName(this.equipMasterhand); else weapon = null;
		if(weapon != null && weapon.dtn < dtn && weapon.dtn > 0) dtn = weapon.dtn;
		if((this.manueverUsingHands & 2) == 0) weapon = troshx_tros_WeaponSheet.getWeaponByName(this.equipOffhand); else weapon = null;
		if(weapon != null && weapon.dtn < dtn && weapon.dtn > 0) dtn = weapon.dtn;
		return dtn;
	}
	,getPredictedATN: function() {
		var weapon;
		var atn = 10;
		weapon = troshx_tros_WeaponSheet.getWeaponByName(this.equipMasterhand);
		if(weapon != null) {
			if(weapon.atn < atn && weapon.atn > 0) atn = weapon.atn;
			if(weapon.atn2 < atn && weapon.atn2 > 0) atn = weapon.atn2;
		}
		weapon = troshx_tros_WeaponSheet.getWeaponByName(this.equipOffhand);
		if(weapon != null) {
			if(weapon.atn < atn && weapon.atn > 0) atn = weapon.atn;
			if(weapon.atn2 < atn && weapon.atn2 > 0) atn = weapon.atn2;
		}
		return atn;
	}
	,getOffhandDTN: function() {
		var weapon = troshx_tros_WeaponSheet.getWeaponByName(this.equipOffhand);
		if(weapon != null) return weapon.dtn; else return 0;
	}
	,getShieldDTN: function() {
		var weapon = troshx_tros_WeaponSheet.getWeaponByName(this.equipOffhand);
		if(weapon != null && weapon.shield) return weapon.dtn; else return 0;
	}
	,getMasterDTN: function() {
		var weapon = troshx_tros_WeaponSheet.getWeaponByName(this.equipMasterhand);
		if(weapon != null) return weapon.dtn; else return 0;
	}
	,getHighestATNOrDTN: function() {
		var atn = this.getPredictedATN();
		var dtn = this.getPredictedDTN();
		if(atn > dtn) return atn; else return dtn;
	}
	,getDTNBetterMargin: function() {
		return this.getPredictedATN() - this.getPredictedDTN();
	}
	,isDualWeilding: function() {
		return this.equipMasterhand != null && this.equipOffhand != null && troshx_tros_WeaponSheet.weaponNameIsShield(this.equipOffhand);
	}
	,newExchange: function(newRound) {
		if(newRound == null) newRound = false;
		var _g1 = 0;
		var _g = this.decidedManuevers.length;
		while(_g1 < _g) {
			var i = _g1++;
			var d = this.decidedManuevers[i];
			d.manuever = "";
			d.manueverCP = 0;
			d.targetZone = 0;
			d.manueverType = 0;
			d.offhand = false;
			d.againstID = 0;
			d.secondary = null;
		}
		if(newRound) {
			this.currentExchange = 1;
			var _g11 = 0;
			var _g2 = this.decidedManuevers.length;
			while(_g11 < _g2) {
				var i1 = _g11++;
				this.plannedCombos[i1] = 0;
			}
		} else this.currentExchange = 2;
	}
	,decideStance: function(enemies,target,targetedBy) {
	}
	,decideOrientation: function(enemies,target,targetedBy) {
	}
	,decideTarget: function(enemies) {
	}
	,preDeclareManuevers: function(target,targetedBy) {
		this.handsUsedUp = this.manueverUsingHands;
		this.opponents[0] = target;
		var count = 1;
		var totalOpponentCP = 0;
		var _g1 = 0;
		var _g = targetedBy.length;
		while(_g1 < _g) {
			var i = _g1++;
			if(targetedBy[i] != target) {
				this.opponents[count++] = targetedBy[i];
				totalOpponentCP += targetedBy[i].cp;
			}
		}
		this.opponentLen = count;
		var _g11 = this.opponentLen;
		var _g2 = this.opponents.length;
		while(_g11 < _g2) {
			var i1 = _g11++;
			this.opponents[i1] = null;
		}
		var cpLeft = this.cp;
		var _g12 = 0;
		var _g3 = this.opponentLen;
		while(_g12 < _g3) {
			var i2 = _g12++;
			var cpToAssign = Std["int"](Math.min(cpLeft,Math.ceil(this.opponents[i2].cp / totalOpponentCP * this.cp)));
			this.cpBudget[i2] = cpToAssign;
			cpLeft -= cpToAssign;
		}
	}
	,declareManuevers: function() {
		var _g1 = 0;
		var _g = this.opponentLen;
		while(_g1 < _g) {
			var i = _g1++;
			this.declareManueverAgainstOpponent(i);
		}
	}
	,declareManueverAgainstOpponent: function(index) {
		if((this.handsUsedUp & 1) == 0) troshx_tros_ai_TROSAiBot.B_EQUIP = this.equipMasterhand; else troshx_tros_ai_TROSAiBot.B_EQUIP = null;
		if((this.handsUsedUp & 2) == 0) troshx_tros_ai_TROSAiBot.D_EQUIP = this.equipOffhand; else troshx_tros_ai_TROSAiBot.D_EQUIP = null;
		var cpAvailable = this.cpBudget[index];
		var cpAvailable2;
		var opponent = this.opponents[index];
		troshx_tros_ai_TROSAiBot.CURRENT_OPPONENT = opponent;
		var threatManuever = null;
		var threatManuever2 = null;
		if(opponent.decidedManuevers[0] != null && opponent.decidedManuevers[0].againstID == this.id) threatManuever = opponent.decidedManuevers[0]; else if(opponent.decidedManuevers[0] == null) {
		}
		if(opponent.decidedManuevers[1] != null && opponent.decidedManuevers[1].againstID == this.id) {
			if(threatManuever != null) threatManuever2 = opponent.decidedManuevers[1]; else threatManuever = opponent.decidedManuevers[1];
		}
		if(threatManuever2 != null) {
		}
		if(this.currentExchange != 2) {
			if(this.initiative) {
				if(troshx_tros_ai_TROSAiBot.setBestComboActionWithInitiativePlan(this.cp,opponent.cp,threatManuever)) {
					this.plannedCombos[index] = troshx_tros_ai_TROSAiBot.MANUEVER_COMBO_SET;
					troshx_tros_ai_TROSAiBot.MANUEVER_CHOICE_SET.copyTo(this.decidedManuevers[index],null);
					return true;
				}
			} else if(troshx_tros_ai_TROSAiBot.setBestComboActionWithoutInitiativePlan(this.cp,opponent.cp,threatManuever)) {
				this.plannedCombos[index] = troshx_tros_ai_TROSAiBot.MANUEVER_COMBO_SET;
				troshx_tros_ai_TROSAiBot.MANUEVER_CHOICE_SET.copyTo(this.decidedManuevers[index],null);
				return true;
			}
		} else if(this.plannedCombos[index] != 0) {
			if(troshx_tros_ai_TROSAiBot.getComboAction(this.plannedCombos[index],this.cp,opponent.cp,threatManuever,this.initiative,true)) {
				troshx_tros_ai_TROSAiBot.MANUEVER_CHOICE.copyTo(this.decidedManuevers[index],null);
				this.decidedManuevers[index].manueverCP = cpAvailable;
				return true;
			}
		}
		return false;
	}
	,__class__: troshx_tros_ai_TROSAiBot
};
var troshx_util_PropertyChainHolder = $hx_exports.troshx.util.PropertyChainHolder = function() {
	Object.defineProperty(this,"value",{ get : $bind(this,this.get_value), set : $bind(this,this.set_value)});
};
$hxClasses["troshx.util.PropertyChainHolder"] = troshx_util_PropertyChainHolder;
troshx_util_PropertyChainHolder.__name__ = ["troshx","util","PropertyChainHolder"];
troshx_util_PropertyChainHolder.prototype = {
	_src: null
	,value: null
	,propertyChain: null
	,setupProperty: function(src,property) {
		this._src = src;
		if(property == null) return;
		if(typeof(property) == "string") {
			var str = property;
			this.propertyChain = str.split(".");
		} else this.propertyChain = property;
	}
	,getPropertyChainValue: function() {
		var len = this.propertyChain.length;
		var cur = this._src;
		var _g = 0;
		while(_g < len) {
			var i = _g++;
			var propToGet = this.propertyChain[i];
			cur = Reflect.getProperty(cur,propToGet);
			if(cur == null) return null;
		}
		return cur;
	}
	,setPropertyChainValue: function(val) {
		if(this._src == null) this._src = { };
		var cur = this._src;
		var len = this.propertyChain.length;
		var propStack = [];
		var _g = 0;
		while(_g < len) {
			var i = _g++;
			var propToSet = this.propertyChain[i];
			propStack.push(propToSet);
			cur = this.setPropertyOf(cur,propToSet,val,i >= len - 1,propStack);
			if(cur == null) return null;
		}
		return cur;
	}
	,deletePropertyChainValue: function(val) {
		if(this._src == null) return null;
		var cur = this._src;
		var len = this.propertyChain.length;
		var propStack = [];
		var _g = 0;
		while(_g < len) {
			var i = _g++;
			var propToSet = this.propertyChain[i];
			propStack.push(propToSet);
			cur = this.deletePropertyOf(cur,propToSet,val,i >= len - 1,propStack);
			if(cur == null) return null;
		}
		return cur;
	}
	,setPropertyOf: function(obj,prop,val,leaf,propStack) {
		if(!leaf) {
			var reflectProp = val = Reflect.getProperty(obj,prop);
			if(reflectProp == null) {
				if(val == null) return null;
				Reflect.setProperty(obj,prop,reflectProp = { });
			}
			val = reflectProp;
		}
		Reflect.setProperty(obj,prop,val);
		return val;
	}
	,deletePropertyOf: function(obj,prop,val,leaf,propStack) {
		if(!leaf) {
			var reflectProp = val = Reflect.getProperty(obj,prop);
			if(reflectProp == null) return null;
			Reflect.setProperty(obj,prop,val);
			return val;
		}
		Reflect.deleteField(obj,prop);
		return val;
	}
	,getPropertyOf: function(obj,prop) {
		return Reflect.getProperty(obj,prop);
	}
	,get_value: function() {
		if(this.propertyChain != null && this._src != null) return this.getPropertyChainValue(); else return null;
	}
	,set_value: function(v) {
		if(this.propertyChain != null) return this.setPropertyChainValue(v); else return null;
	}
	,__class__: troshx_util_PropertyChainHolder
	,__properties__: {set_value:"set_value",get_value:"get_value"}
};
var troshx_util_ReflectUtil = $hx_exports.troshx.util.ReflectUtil = function() { };
$hxClasses["troshx.util.ReflectUtil"] = troshx_util_ReflectUtil;
troshx_util_ReflectUtil.__name__ = ["troshx","util","ReflectUtil"];
troshx_util_ReflectUtil.setItemStaticMethodsTo = function(c,to) {
	return troshx_util_ReflectUtil.setItemMethodsTo(c,to,true);
};
troshx_util_ReflectUtil.setItemInstanceMethodsTo = function(c,to) {
	return troshx_util_ReflectUtil.setItemMethodsTo(c,to,false);
};
troshx_util_ReflectUtil.getMetaDataOfField = function(metaName,t,fieldName,isStatic) {
	if(isStatic == null) isStatic = false;
	var meta;
	if(isStatic) meta = haxe_rtti_Meta.getStatics(t); else meta = haxe_rtti_Meta.getFields(t);
	var fieldMeta = Reflect.field(meta,fieldName);
	if(Object.prototype.hasOwnProperty.call(fieldMeta,metaName)) return Reflect.field(fieldMeta,metaName);
	return null;
};
troshx_util_ReflectUtil.getEnumStrMapUnderscored = function(prefix,c) {
	var to = new haxe_ds_IntMap();
	var reference = c;
	var rtti = haxe_rtti_Rtti.getRtti(c);
	var _g_head = rtti.statics.h;
	var _g_val = null;
	while(_g_head != null) {
		var f;
		f = (function($this) {
			var $r;
			_g_val = _g_head[0];
			_g_head = _g_head[1];
			$r = _g_val;
			return $r;
		}(this));
		{
			var _g = f.type;
			switch(_g[1]) {
			case 7:
				var ret = _g[3];
				var args = _g[2];
				if(f.name.indexOf("_") >= 0 && f.name.split("_")[0] == prefix) to.set(Reflect.field(reference,f.name),f.name);
				break;
			default:
			}
		}
	}
	return to;
};
troshx_util_ReflectUtil.getAllEnums = function(c) {
	var myMetaHash = { };
	var dyn = { };
	troshx_util_ReflectUtil.setItemFieldsTo(c,dyn,true,"enum");
	var meta = haxe_rtti_Meta.getStatics(c);
	var _g = 0;
	var _g1 = Reflect.fields(dyn);
	while(_g < _g1.length) {
		var p = _g1[_g];
		++_g;
		var fieldMeta = Reflect.field(meta,p);
		var prefix = Reflect.field(fieldMeta,"enum");
		var daMap;
		if(!Object.prototype.hasOwnProperty.call(dyn,prefix)) {
			daMap = troshx_util_ReflectUtil.getEnumStrMapUnderscored(prefix,c);
			dyn[prefix] = daMap;
		} else daMap = Reflect.field(dyn,prefix);
		myMetaHash[p] = daMap;
	}
	dyn._meta = myMetaHash;
	return dyn;
};
troshx_util_ReflectUtil.setItemFieldsTo = function(c,to,isStatic,requireMeta) {
	if(isStatic == null) isStatic = false;
	var rtti = haxe_rtti_Rtti.getRtti(c);
	var reference;
	if(isStatic) reference = c; else reference = Type.createEmptyInstance(c);
	var meta;
	if(isStatic) meta = haxe_rtti_Meta.getStatics(c); else meta = haxe_rtti_Meta.getFields(c);
	var _g_head;
	_g_head = (isStatic?rtti.statics:rtti.fields).h;
	var _g_val = null;
	while(_g_head != null) {
		var f;
		f = (function($this) {
			var $r;
			_g_val = _g_head[0];
			_g_head = _g_head[1];
			$r = _g_val;
			return $r;
		}(this));
		var fieldMeta = Reflect.field(meta,f.name);
		if(requireMeta == null || fieldMeta != null && Object.prototype.hasOwnProperty.call(fieldMeta,requireMeta)) {
			var _g = f.type;
			switch(_g[1]) {
			case 7:
				var ret = _g[3];
				var args = _g[2];
				Reflect.setField(to,f.name,Reflect.field(reference,f.name));
				break;
			case 2:
				var ret1 = _g[3];
				var args1 = _g[2];
				Reflect.setField(to,f.name,Reflect.field(reference,f.name));
				break;
			default:
			}
		}
	}
	return to;
};
troshx_util_ReflectUtil.setItemMethodsTo = function(c,to,isStatic,requireMeta) {
	if(isStatic == null) isStatic = false;
	var rtti = haxe_rtti_Rtti.getRtti(c);
	var reference;
	if(isStatic) reference = c; else reference = Type.createEmptyInstance(c);
	var meta;
	if(isStatic) meta = haxe_rtti_Meta.getStatics(c); else meta = haxe_rtti_Meta.getFields(c);
	var _g_head;
	_g_head = (isStatic?rtti.statics:rtti.fields).h;
	var _g_val = null;
	while(_g_head != null) {
		var f;
		f = (function($this) {
			var $r;
			_g_val = _g_head[0];
			_g_head = _g_head[1];
			$r = _g_val;
			return $r;
		}(this));
		var fieldMeta = Reflect.field(meta,f.name);
		if(requireMeta == null || fieldMeta != null && Object.prototype.hasOwnProperty.call(fieldMeta,requireMeta)) {
			var _g = f.type;
			switch(_g[1]) {
			case 4:
				var ret = _g[3];
				var args = _g[2];
				Reflect.setField(to,f.name,Reflect.field(reference,f.name));
				break;
			default:
			}
		}
	}
	return to;
};
var troshx_util_TROSAI = $hx_exports.troshx.util.TROSAI = function() {
};
$hxClasses["troshx.util.TROSAI"] = troshx_util_TROSAI;
troshx_util_TROSAI.__name__ = ["troshx","util","TROSAI"];
troshx_util_TROSAI.factorial = function(val) {
	if(val == 0) val = 1;
	var v = val;
	while(--v > 1) val *= v;
	return val;
};
troshx_util_TROSAI.binomialCoef = function(n,r) {
	if(r > 0) return troshx_util_TROSAI.factorial(n) / (troshx_util_TROSAI.factorial(r) * troshx_util_TROSAI.factorial(n - r)); else return 1;
};
troshx_util_TROSAI.getTNSuccessProbForDie = function(tn) {
	if(tn < 11) return (10 - tn + 1) / 10; else return (1 - (tn - Math.floor(tn / 10) * 10) / 10) * Math.pow(0.1,Math.floor(tn / 10));
};
troshx_util_TROSAI.getXSuccessesProb = function(numDiceToRoll,tn,x) {
	var prob;
	if(tn < 11) prob = (10 - tn + 1) / 10; else prob = (1 - (tn - Math.floor(tn / 10) * 10) / 10) * Math.pow(0.1,Math.floor(tn / 10));
	return (x > 0?troshx_util_TROSAI.factorial(numDiceToRoll) / (troshx_util_TROSAI.factorial(x) * troshx_util_TROSAI.factorial(numDiceToRoll - x)):1) * Math.pow(prob,x) * Math.pow(1 - prob,numDiceToRoll - x);
};
troshx_util_TROSAI.getAtLeastXSuccessesProb = function(numDiceToRoll,tn,x) {
	var accum = 0;
	while(x <= numDiceToRoll) {
		accum += troshx_util_TROSAI.getXSuccessesProb(numDiceToRoll,tn,x);
		x++;
	}
	if(accum > 1) accum = 1;
	return accum;
};
troshx_util_TROSAI.probabilityAOrB = function(a,b) {
	return a + b - a * b;
};
troshx_util_TROSAI.probabilityOfArrayOr = function(arr) {
	var p = 0;
	if(arr.length == 0) return 0;
	p = arr[0];
	var _g1 = 1;
	var _g = arr.length;
	while(_g1 < _g) {
		var i = _g1++;
		p = troshx_util_TROSAI.probabilityAOrB(p,arr[i]);
	}
	return p;
};
troshx_util_TROSAI.getBelowOrEqualXSuccessesProb = function(numDiceToRoll,tn,x) {
	var accum = 0;
	while(x >= 0) {
		accum += troshx_util_TROSAI.getXSuccessesProb(numDiceToRoll,tn,x);
		x--;
	}
	if(accum > 1) accum = 1;
	return accum;
};
troshx_util_TROSAI.getChanceToSucceedContest = function(numDice,tn,againstNumDice,againstTN,rs,requireAtLeast1TS) {
	if(requireAtLeast1TS == null) requireAtLeast1TS = true;
	if(rs == null) rs = 1;
	if(rs > numDice) return 0;
	var accum = 0;
	var start;
	if(requireAtLeast1TS && rs < 1) start = 1; else start = rs;
	var i = start;
	var p = 0;
	while(i <= numDice) {
		var k = i - rs;
		if(k > againstNumDice) k = againstNumDice;
		while(k >= 0) {
			p += troshx_util_TROSAI.getXSuccessesProb(numDice,tn,i) * troshx_util_TROSAI.getXSuccessesProb(againstNumDice,againstTN,k);
			k--;
		}
		i++;
	}
	return p;
};
troshx_util_TROSAI.getChanceToSucceed = function(numDice,tn,rs) {
	if(rs == null) rs = 1;
	if(rs > numDice) return 0;
	return troshx_util_TROSAI.getAtLeastXSuccessesProb(numDice,tn,rs);
};
troshx_util_TROSAI.getAllXSuccessesProb = function(numDice,tn) {
	var arr = [];
	var _g1 = 0;
	var _g = numDice + 1;
	while(_g1 < _g) {
		var i = _g1++;
		arr.push(troshx_util_TROSAI.getXSuccessesProb(numDice,tn,i));
	}
	return arr;
};
troshx_util_TROSAI.getTabulatedRollData = function(numDice,tn) {
	var arr = [];
	var accum = 0;
	var i = numDice;
	while(i >= 0) {
		var v = troshx_util_TROSAI.getXSuccessesProb(numDice,tn,i);
		accum += v;
		arr.push({ x : i, gte : accum, eq : v});
		i--;
	}
	arr.reverse();
	var _g1 = 0;
	var _g = arr.length - 1;
	while(_g1 < _g) {
		var i1 = _g1++;
		if(arr[i1 + 1].eq <= arr[i1].eq) {
			arr[i1].peak = 1;
			if(arr[i1 + 1].eq != arr[i1].eq) break;
		}
	}
	return arr;
};
troshx_util_TROSAI.maxPrecision = function(x,precision) {
	return troshx_util_TROSAI.roundTo(x,Math.pow(10,-precision));
};
troshx_util_TROSAI.roundTo = function(x,y) {
	return Math.round(x / y) * y;
};
troshx_util_TROSAI.displayAsPercentage = function(probability) {
	probability *= 100;
	if(probability < 1 && probability > 0) return troshx_util_TROSAI.roundTo(probability,Math.pow(10,-2)); else return Math.floor(probability);
};
troshx_util_TROSAI.prototype = {
	__class__: troshx_util_TROSAI
};
function $iterator(o) { if( o instanceof Array ) return function() { return HxOverrides.iter(o); }; return typeof(o.iterator) == 'function' ? $bind(o,o.iterator) : o.iterator; }
var $_, $fid = 0;
function $bind(o,m) { if( m == null ) return null; if( m.__id__ == null ) m.__id__ = $fid++; var f; if( o.hx__closures__ == null ) o.hx__closures__ = {}; else f = o.hx__closures__[m.__id__]; if( f == null ) { f = function(){ return f.method.apply(f.scope, arguments); }; f.scope = o; f.method = m; o.hx__closures__[m.__id__] = f; } return f; }
if(Array.prototype.indexOf) HxOverrides.indexOf = function(a,o,i) {
	return Array.prototype.indexOf.call(a,o,i);
};
$hxClasses.Math = Math;
String.prototype.__class__ = $hxClasses.String = String;
String.__name__ = ["String"];
$hxClasses.Array = Array;
Array.__name__ = ["Array"];
Date.prototype.__class__ = $hxClasses.Date = Date;
Date.__name__ = ["Date"];
var Int = $hxClasses.Int = { __name__ : ["Int"]};
var Dynamic = $hxClasses.Dynamic = { __name__ : ["Dynamic"]};
var Float = $hxClasses.Float = Number;
Float.__name__ = ["Float"];
var Bool = Boolean;
Bool.__ename__ = ["Bool"];
var Class = $hxClasses.Class = { __name__ : ["Class"]};
var Enum = { };
var __map_reserved = {}
Xml.Element = 0;
Xml.PCData = 1;
Xml.CData = 2;
Xml.Comment = 3;
Xml.DocType = 4;
Xml.ProcessingInstruction = 5;
Xml.Document = 6;
dat_gui_DatUtil.DEFAULT_FLOAT_STEP = 0;
haxe_xml_Parser.escapes = (function($this) {
	var $r;
	var h = new haxe_ds_StringMap();
	if(__map_reserved.lt != null) h.setReserved("lt","<"); else h.h["lt"] = "<";
	if(__map_reserved.gt != null) h.setReserved("gt",">"); else h.h["gt"] = ">";
	if(__map_reserved.amp != null) h.setReserved("amp","&"); else h.h["amp"] = "&";
	if(__map_reserved.quot != null) h.setReserved("quot","\""); else h.h["quot"] = "\"";
	if(__map_reserved.apos != null) h.setReserved("apos","'"); else h.h["apos"] = "'";
	$r = h;
	return $r;
}(this));
js_Boot.__toStr = {}.toString;
tjson_TJSON.OBJECT_REFERENCE_PREFIX = "@~obRef#";
troshx_BodyChar.D_DESTROY_PART = 1;
troshx_BodyChar.D_DEATH = 2;
troshx_BodyChar.WOUND_TYPE_CUT = 1;
troshx_BodyChar.WOUND_TYPE_PIERCE = 2;
troshx_BodyChar.WOUND_TYPE_BLUNT_TRAUMA = 4;
troshx_BodyChar.WOUND_D_DESTROY = 1;
troshx_BodyChar.WOUND_D_DEATH = 2;
troshx_GameRules.__meta__ = { statics : { FLEE_CAP : { inspect : [{ display : "selector"}], choices : ["FLEE_CAP"]}}};
troshx_GameRules.__rtti = "<class path=\"troshx.GameRules\" params=\"\">\n\t<FLEE_CAP_NONE public=\"1\" get=\"inline\" set=\"null\" expr=\"0\" line=\"13\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e>0</e></m></meta>\n\t</FLEE_CAP_NONE>\n\t<FLEE_CAP_BY_MOBILITY_EXCHANGE1 public=\"1\" get=\"inline\" set=\"null\" expr=\"1\" line=\"14\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e>1</e></m></meta>\n\t</FLEE_CAP_BY_MOBILITY_EXCHANGE1>\n\t<FLEE_CAP_BY_MOBILITY_ALL public=\"1\" get=\"inline\" set=\"null\" expr=\"2\" line=\"15\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e>2</e></m></meta>\n\t</FLEE_CAP_BY_MOBILITY_ALL>\n\t<FLEE_CAP public=\"1\" expr=\"FLEE_CAP_NONE\" line=\"17\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta>\n\t\t\t<m n=\":value\"><e>FLEE_CAP_NONE</e></m>\n\t\t\t<m n=\"inspect\"><e>{display:\"selector\"}</e></m>\n\t\t\t<m n=\"choices\"><e>\"FLEE_CAP\"</e></m>\n\t\t</meta>\n\t</FLEE_CAP>\n\t<meta>\n\t\t<m n=\":directlyUsed\"/>\n\t\t<m n=\":expose\"/>\n\t\t<m n=\":rtti\"/>\n\t</meta>\n</class>";
troshx_GameRules.FLEE_CAP_NONE = 0;
troshx_GameRules.FLEE_CAP_BY_MOBILITY_EXCHANGE1 = 1;
troshx_GameRules.FLEE_CAP_BY_MOBILITY_ALL = 2;
troshx_GameRules.FLEE_CAP = 0;
troshx_tros_HumanoidBody.ZONE_I = 1;
troshx_tros_HumanoidBody.ZONE_II = 2;
troshx_tros_HumanoidBody.ZONE_III = 3;
troshx_tros_HumanoidBody.ZONE_IV = 4;
troshx_tros_HumanoidBody.ZONE_V = 5;
troshx_tros_HumanoidBody.ZONE_VI = 6;
troshx_tros_HumanoidBody.ZONE_VII = 7;
troshx_tros_HumanoidBody.ZONE_VIII = 8;
troshx_tros_HumanoidBody.ZONE_IX = 9;
troshx_tros_HumanoidBody.ZONE_X = 10;
troshx_tros_HumanoidBody.ZONE_XI = 11;
troshx_tros_HumanoidBody.ZONE_XII = 12;
troshx_tros_HumanoidBody.ZONE_XIII = 13;
troshx_tros_HumanoidBody.ZONE_XIV = 14;
troshx_tros_HumanoidBody.CENTER_OF_MASS = [3,2,5,6];
troshx_tros_HumanoidBody.CENTER_OF_MASS_T = [10,11,11,12];
troshx_tros_Manuever.MANUEVER_HAND_NONE = 0;
troshx_tros_Manuever.MANUEVER_HAND_MASTER = 1;
troshx_tros_Manuever.MANUEVER_HAND_SECONDARY = 2;
troshx_tros_Manuever.MANUEVER_HAND_BOTH = 3;
troshx_tros_Manuever.MANUEVER_TYPE_MELEE = 0;
troshx_tros_Manuever.MANUEVER_TYPE_RANGED = 1;
troshx_tros_Manuever.DAMAGE_TYPE_CUTTING = 1;
troshx_tros_Manuever.DAMAGE_TYPE_PUNCTURING = 2;
troshx_tros_Manuever.DAMAGE_TYPE_BLUDGEONING = 3;
troshx_tros_Manuever.ATTACK_TYPE_STRIKE = 1;
troshx_tros_Manuever.ATTACK_TYPE_THRUST = 2;
troshx_tros_Manuever.DEFEND_TYPE_OFFHAND = 1;
troshx_tros_Manuever.DEFEND_TYPE_MASTERHAND = 2;
troshx_tros_Weapon.__rtti = "<class path=\"troshx.tros.Weapon\" params=\"\">\n\t<ATTR_BASE_NONE public=\"1\" get=\"inline\" set=\"null\" expr=\"-1\" line=\"38\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e>-1</e></m></meta>\n\t</ATTR_BASE_NONE>\n\t<ATTR_BASE_STRENGTH public=\"1\" get=\"inline\" set=\"null\" expr=\"0\" line=\"39\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e>0</e></m></meta>\n\t</ATTR_BASE_STRENGTH>\n\t<HOOK_STRIKE get=\"inline\" set=\"null\" expr=\"1\" line=\"41\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e>1</e></m></meta>\n\t</HOOK_STRIKE>\n\t<HOOK_THRUST get=\"inline\" set=\"null\" expr=\"2\" line=\"42\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e>2</e></m></meta>\n\t</HOOK_THRUST>\n\t<createDyn public=\"1\" set=\"method\" line=\"111\" static=\"1\"><f a=\"name:profGroups:properties\">\n\t<c path=\"String\"/>\n\t<c path=\"Array\"><c path=\"String\"/></c>\n\t<d/>\n\t<c path=\"troshx.tros.Weapon\"/>\n</f></createDyn>\n\t<atn public=\"1\"><x path=\"Int\"/></atn>\n\t<atn2 public=\"1\"><x path=\"Int\"/></atn2>\n\t<dtn public=\"1\"><x path=\"Int\"/></dtn>\n\t<dntT public=\"1\"><x path=\"Int\"/></dntT>\n\t<dtn2 public=\"1\"><x path=\"Int\"/></dtn2>\n\t<damage public=\"1\"><x path=\"Int\"/></damage>\n\t<damage2 public=\"1\"><x path=\"Int\"/></damage2>\n\t<damage3 public=\"1\"><x path=\"Int\"/></damage3>\n\t<shield public=\"1\"><x path=\"Bool\"/></shield>\n\t<profeciencies public=\"1\"><c path=\"Array\"><c path=\"String\"/></c></profeciencies>\n\t<name public=\"1\"><c path=\"String\"/></name>\n\t<drawCutModifier public=\"1\"><x path=\"Int\"/></drawCutModifier>\n\t<attrBaseIndex public=\"1\"><x path=\"Int\"/></attrBaseIndex>\n\t<twoHanded public=\"1\"><x path=\"Bool\"/></twoHanded>\n\t<rangedWeapon public=\"1\"><x path=\"Bool\"/></rangedWeapon>\n\t<cpPenalty public=\"1\"><x path=\"Float\"/></cpPenalty>\n\t<movePenalty public=\"1\"><x path=\"Float\"/></movePenalty>\n\t<shieldLimit public=\"1\"><x path=\"Int\"/></shieldLimit>\n\t<blunt public=\"1\"><x path=\"Bool\"/></blunt>\n\t<range public=\"1\"><x path=\"Int\"/></range>\n\t<hooking public=\"1\"><x path=\"Int\"/></hooking>\n\t<getDamageTo public=\"1\" set=\"method\" line=\"45\"><f a=\"body:manuever:targetZone:margin:strength\">\n\t<c path=\"troshx.BodyChar\"/>\n\t<c path=\"troshx.tros.Manuever\"/>\n\t<x path=\"Int\"/>\n\t<x path=\"Int\"/>\n\t<x path=\"Int\"/>\n\t<x path=\"Int\"/>\n</f></getDamageTo>\n\t<getHookingATN public=\"1\" set=\"method\" line=\"64\">\n\t\t<f a=\"?tieBiasToThrust\" v=\"false\">\n\t\t\t<x path=\"Bool\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t</f>\n\t\t<meta><m n=\":value\"><e>{tieBiasToThrust:false}</e></m></meta>\n\t</getHookingATN>\n\t<getHookingATNType public=\"1\" set=\"method\" line=\"78\">\n\t\t<f a=\"?tieBiasToThrust\" v=\"false\">\n\t\t\t<x path=\"Bool\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t</f>\n\t\t<meta><m n=\":value\"><e>{tieBiasToThrust:false}</e></m></meta>\n\t</getHookingATNType>\n\t<new public=\"1\" set=\"method\" line=\"88\"><f a=\"name:profGroups\">\n\t<c path=\"String\"/>\n\t<c path=\"Array\"><c path=\"String\"/></c>\n\t<x path=\"Void\"/>\n</f></new>\n\t<meta>\n\t\t<m n=\":directlyUsed\"/>\n\t\t<m n=\":expose\"/>\n\t\t<m n=\":rtti\"/>\n\t</meta>\n</class>";
troshx_tros_Weapon.ATTR_BASE_NONE = -1;
troshx_tros_Weapon.ATTR_BASE_STRENGTH = 0;
troshx_tros_Weapon.HOOK_STRIKE = 1;
troshx_tros_Weapon.HOOK_THRUST = 2;
troshx_tros_WeaponSheet.LIST = [troshx_tros_Weapon.createDyn("Short Sword",["cutthrust","swordshield"],{ 'range' : 1, 'atn' : 7, 'atn2' : 5, 'dtn' : 7, 'damage' : -1, 'damage2' : 1}),troshx_tros_Weapon.createDyn("Gladius",["swordshield"],{ 'range' : 1, 'atn' : 6, 'atn2' : 6, 'dtn' : 7, 'damage' : 0, 'damage2' : 1, 'drawCutModifier' : 0}),troshx_tros_Weapon.createDyn("Blunted Sword",["swordshield","cutthrust"],{ 'range' : 2, 'atn' : 6, 'atn2' : 6, 'dtn' : 6, 'damage' : 0, 'damage2' : 0, 'drawCutModifier' : 0}),troshx_tros_Weapon.createDyn("Arming Sword",["swordshield","cutthrust"],{ 'range' : 2, 'atn' : 6, 'atn2' : 7, 'dtn' : 6, 'damage' : 1, 'damage2' : 0, 'drawCutModifier' : 0}),troshx_tros_Weapon.createDyn("Rapier",["rapier","caserapiers"],{ 'range' : 3, 'atn' : 7, 'atn2' : 5, 'dtn' : 8, 'dtnT' : 6, 'damage' : -3, 'damage2' : 2, 'drawCutModifier' : 1}),troshx_tros_Weapon.createDyn("Hand Shield",["swordshield","massweaponshield"],{ 'shield' : true, 'dtn' : 7, 'dtn2' : 9}),troshx_tros_Weapon.createDyn("Small Shield",["swordshield","massweaponshield"],{ 'shield' : true, 'dtn' : 6, 'dtn2' : 8}),troshx_tros_Weapon.createDyn("Medium Shield",["swordshield","massweaponshield"],{ 'shield' : true, 'dtn' : 5, 'dtn2' : 7, 'cpPenalty' : 0.5, 'movePenalty' : 0.5}),troshx_tros_Weapon.createDyn("Large Shield",["swordshield","massweaponshield"],{ 'shield' : true, 'dtn' : 5, 'dtn2' : 6, 'cpPenalty' : 0.5, 'movePenalty' : 1})];
troshx_tros_WeaponSheet.HASH = troshx_tros_WeaponSheet.createHashLookupViaName(troshx_tros_WeaponSheet.LIST);
troshx_util_AIManueverChoice.__meta__ = { fields : { manuever : { inspect : null}, manueverCP : { inspect : [{ min : 0}]}, manueverTN : { inspect : [{ min : 0}]}, targetZone : { inspect : [{ min : 0}]}, manueverType : { inspect : [{ display : "selector"}], choices : ["TYPE"]}, offhand : { inspect : null}, againstID : { inspect : null}, cost : { inspect : [{ min : 0}]}}};
troshx_util_AIManueverChoice.__rtti = "<class path=\"troshx.util.AIManueverChoice\" params=\"\" module=\"troshx.util.TROSAI\">\n\t<TYPE_ATTACKING public=\"1\" get=\"inline\" set=\"null\" expr=\"2\" line=\"240\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e>2</e></m></meta>\n\t</TYPE_ATTACKING>\n\t<TYPE_DEFENDING public=\"1\" get=\"inline\" set=\"null\" expr=\"1\" line=\"241\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e>1</e></m></meta>\n\t</TYPE_DEFENDING>\n\t<TARGET_WEAPON public=\"1\" get=\"inline\" set=\"null\" expr=\"0\" line=\"243\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e>0</e></m></meta>\n\t</TARGET_WEAPON>\n\t<TARGET_SHIELD public=\"1\" get=\"inline\" set=\"null\" expr=\"1\" line=\"244\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e>1</e></m></meta>\n\t</TARGET_SHIELD>\n\t<TARGET_OFFHAND public=\"1\" get=\"inline\" set=\"null\" expr=\"TARGET_SHIELD\" line=\"245\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e>TARGET_SHIELD</e></m></meta>\n\t</TARGET_OFFHAND>\n\t<manuever public=\"1\">\n\t\t<c path=\"String\"/>\n\t\t<meta><m n=\"inspect\"/></meta>\n\t</manuever>\n\t<manueverCP public=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\"inspect\"><e>{min:0}</e></m></meta>\n\t</manueverCP>\n\t<manueverTN public=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\"inspect\"><e>{min:0}</e></m></meta>\n\t</manueverTN>\n\t<targetZone public=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\"inspect\"><e>{min:0}</e></m></meta>\n\t</targetZone>\n\t<manueverType public=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta>\n\t\t\t<m n=\"inspect\"><e>{display:\"selector\"}</e></m>\n\t\t\t<m n=\"choices\"><e>\"TYPE\"</e></m>\n\t\t</meta>\n\t</manueverType>\n\t<offhand public=\"1\">\n\t\t<x path=\"Bool\"/>\n\t\t<meta><m n=\"inspect\"/></meta>\n\t</offhand>\n\t<againstID public=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\"inspect\"/></meta>\n\t</againstID>\n\t<cost public=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\"inspect\"><e>{min:0}</e></m></meta>\n\t</cost>\n\t<getManueverCPSpent public=\"1\" get=\"inline\" set=\"null\" line=\"236\"><f a=\"\"><x path=\"Int\"/></f></getManueverCPSpent>\n\t<secondary public=\"1\"><c path=\"troshx.util.AIManueverChoice\"/></secondary>\n\t<nothing public=\"1\" get=\"inline\" set=\"null\" line=\"254\"><f a=\"\"><x path=\"Void\"/></f></nothing>\n\t<setupSecondAttack public=\"1\" set=\"method\" line=\"264\">\n\t\t<f a=\"manuever:manueverCP:manueverTN:targetZone:cost:?offhand\" v=\":::::false\">\n\t\t\t<c path=\"String\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Bool\"/>\n\t\t\t<x path=\"Void\"/>\n\t\t</f>\n\t\t<meta><m n=\":value\"><e>{offhand:false}</e></m></meta>\n\t</setupSecondAttack>\n\t<setupSecondDefend public=\"1\" set=\"method\" line=\"269\">\n\t\t<f a=\"manuever:manueverCP:manueverTN:targetZone:cost:?offhand\" v=\":::::false\">\n\t\t\t<c path=\"String\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Bool\"/>\n\t\t\t<x path=\"Void\"/>\n\t\t</f>\n\t\t<meta><m n=\":value\"><e>{offhand:false}</e></m></meta>\n\t</setupSecondDefend>\n\t<copyTo public=\"1\" get=\"inline\" set=\"null\" line=\"274\">\n\t\t<f a=\"newChoice:?newAgainstID\" v=\":-1\">\n\t\t\t<c path=\"troshx.util.AIManueverChoice\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Void\"/>\n\t\t</f>\n\t\t<meta><m n=\":value\"><e>{newAgainstID:-1}</e></m></meta>\n\t</copyTo>\n\t<setAttack public=\"1\" set=\"method\" line=\"285\">\n\t\t<f a=\"manuever:manueverCP:manueverTN:targetZone:cost:?offhand\" v=\":::::false\">\n\t\t\t<c path=\"String\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Bool\"/>\n\t\t\t<x path=\"Void\"/>\n\t\t</f>\n\t\t<meta><m n=\":value\"><e>{offhand:false}</e></m></meta>\n\t</setAttack>\n\t<setDefend public=\"1\" set=\"method\" line=\"297\">\n\t\t<f a=\"manuever:manueverCP:manueverTN:cost:?offhand\" v=\"::::false\">\n\t\t\t<c path=\"String\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Bool\"/>\n\t\t\t<x path=\"Void\"/>\n\t\t</f>\n\t\t<meta><m n=\":value\"><e>{offhand:false}</e></m></meta>\n\t</setDefend>\n\t<new public=\"1\" set=\"method\" line=\"249\"><f a=\"\"><x path=\"Void\"/></f></new>\n\t<meta>\n\t\t<m n=\":directlyUsed\"/>\n\t\t<m n=\":rtti\"/>\n\t\t<m n=\":expose\"/>\n\t</meta>\n</class>";
troshx_util_AIManueverChoice.TYPE_ATTACKING = 2;
troshx_util_AIManueverChoice.TYPE_DEFENDING = 1;
troshx_util_AIManueverChoice.TARGET_WEAPON = 0;
troshx_util_AIManueverChoice.TARGET_SHIELD = 1;
troshx_util_AIManueverChoice.TARGET_OFFHAND = 1;
troshx_tros_ai_TROSAiBot.__meta__ = { statics : { AVAIL_bash : { inspect : [{ min : 0}], bind : null}, AVAIL_spike : { inspect : [{ min : 0}], bind : null}, AVAIL_cut : { inspect : [{ min : 0}], bind : null}, AVAIL_thrust : { inspect : [{ min : 0}], bind : null}, AVAIL_beat : { inspect : [{ min : 0}], bind : null}, AVAIL_bindstrike : { inspect : [{ min : 0}], bind : null}, AVAIL_hook : { inspect : [{ min : 0}], bind : null}, AVAIL_block : { inspect : [{ min : 0}], bind : null}, AVAIL_parry : { inspect : [{ min : 0}], bind : null}, AVAIL_duckweave : { inspect : [{ min : 0}], bind : null}, AVAIL_partialevasion : { inspect : [{ min : 0}], bind : null}, AVAIL_fullevasion : { inspect : [{ min : 0}], bind : null}, AVAIL_blockopenstrike : { inspect : [{ min : 0}], bind : null}, AVAIL_counter : { inspect : [{ min : 0}], bind : null}, AVAIL_rota : { inspect : [{ min : 0}], bind : null}, AVAIL_expulsion : { inspect : [{ min : 0}], bind : null}, AVAIL_disarm : { inspect : [{ min : 0}], bind : null}, AVAIL_StealInitiative : { inspect : [{ min : 0}], bind : null}, B_EQUIP : { settable : null}, B_IS_OFFHAND : { settable : null}, D_EQUIP : { settable : null}, CURRENT_OPPONENT : { inject : null}, P_THRESHOLD_FAVORABLE : { inspect : [{ min : 0, max : 1, display : "range", step : 0.01}]}, P_THRESHOLD_BORDERLINE : { inspect : [{ min : 0, max : 1, display : "range", step : 0.01}]}, P_RECKLESS : { inspect : [{ min : 0, max : 1, display : "range", step : 0.01}]}, B_BS_REQUIRED_DMG_DEFAULT : { inspect : [{ min : 1}]}, B_COMBO_CANDIDATES : { 'enum' : ["COMBO"]}, getRegularAttackOrAdvantageMove : { inspect : [[{ inspect : { min : 0}},{ inspect : { min : 0}},{ inspect : { min : -1}},{ inspect : { min : 1}}]], 'return' : ["B_USE_ADVANTAGE"]}, getRegularAdvantageMove : { 'return' : ["B_CANDIDATES","B_CANDIDATE_COUNT","ATTACK_AGGR"], inspect : [[{ inspect : { min : 0}},{ inspect : { min : 0}},{ inspect : { min : -1}},{ inspect : { min : 1}}]]}, getRegularAttack : { 'return' : ["B_CANDIDATES","B_CANDIDATE_COUNT","ATTACK_AGGR"], inspect : [[{ inspect : { min : 0}},{ inspect : { min : 0}},{ inspect : { min : -1}},{ inspect : { min : 1}}]]}, getRegularDefense : { 'return' : ["B_CANDIDATES","B_CANDIDATE_COUNT"], inspect : [[{ inspect : { min : 0}},{ inspect : { min : 0}}]]}, MANUEVER_COMBO_SET : { 'enum' : ["COMBO"]}, checkCostViability : { 'return' : ["B_VIABLE_PROBABILITY"]}, checkCostViabilityBorderline : { 'return' : ["B_VIABLE_PROBABILITY"]}, checkCostAntiFavorability : { 'return' : ["B_VIABLE_PROBABILITY_GET"]}, checkCostAntiBorderline : { 'return' : ["B_VIABLE_PROBABILITY_GET"]}, getASuitableAttack : { 'return' : ["MANUEVER_CHOICE","B_VIABLE_PROBABILITY"], inspect : [[{ inspect : { min : 0, step : 0.01, max : 1, display : "range"}},{ inspect : { min : 0}},{ inspect : { min : 0}},{ inspect : { min : 1}}]]}, getAForcefulInitiativeAttack : { 'return' : ["MANUEVER_CHOICE","B_VIABLE_PROBABILITY_GET"], inspect : [[{ inspect : { min : 0, step : 0.01, max : 1, display : "range"}},{ inspect : { min : 0}},{ inspect : { min : 0}},{ inspect : { min : 1}}]]}, getASuitableDefense : { 'return' : ["MANUEVER_CHOICE","B_VIABLE_PROBABILITY"], inspect : [[{ inspect : { min : 0, step : 0.01, max : 1, display : "range"}},{ inspect : { min : 0}},{ inspect : { min : 0}},{ inspect : { min : 1}}]]}, getFavorableAttack : { inspect : [[{ inspect : { min : 0}},{ inspect : { min : 0}},{ inspect : { min : 1}},{ inspect : null},{ inspect : null, bitmask : "FLAG"},{ inspect : { min : 0, display : "range", step : 0.01, max : 1}}]], 'return' : ["B_VIABLE_PROBABILITY_GET","MANUEVER_CHOICE","B_VIABLE_HEURISTIC"]}, getBorderlineAttack : { inspect : [[{ inspect : { min : 0}},{ inspect : { min : 0}},{ inspect : { min : 1}},{ inspect : null},{ inspect : null, bitmask : "FLAG"},{ inspect : { min : 0, display : "range", step : 0.01, max : 1}}]], 'return' : ["B_VIABLE_PROBABILITY_GET","MANUEVER_CHOICE","B_VIABLE_HEURISTIC"]}, getFavorableDefense : { 'return' : ["B_VIABLE_PROBABILITY_GET","MANUEVER_CHOICE","B_VIABLE_HEURISTIC"]}, getBorderlineDefense : { 'return' : ["B_VIABLE_PROBABILITY_GET","MANUEVER_CHOICE","B_VIABLE_HEURISTIC"]}, getFleeOrDefend : { 'return' : ["B_VIABLE_PROBABILITY_GET","MANUEVER_CHOICE"]}, getBlockOpenAndStrike : { 'return' : ["B_VIABLE_PROBABILITY_GET","MANUEVER_CHOICE"]}, getRota : { 'return' : ["B_VIABLE_PROBABILITY_GET","MANUEVER_CHOICE"]}, getCounter : { 'return' : ["B_VIABLE_PROBABILITY_GET","MANUEVER_CHOICE"]}, getExpulsion : { 'return' : ["B_VIABLE_PROBABILITY_GET","MANUEVER_CHOICE"]}, getDisarm : { 'return' : ["B_VIABLE_PROBABILITY_GET","MANUEVER_CHOICE"]}, getHook : { 'return' : ["B_VIABLE_PROBABILITY_GET","MANUEVER_CHOICE"]}, getBindStrike : { 'return' : ["B_VIABLE_PROBABILITY_GET","MANUEVER_CHOICE"]}, getBeat : { 'return' : ["B_VIABLE_PROBABILITY_GET","MANUEVER_CHOICE"]}, getRotaOrCounter : { 'return' : ["B_VIABLE_PROBABILITY_GET","MANUEVER_CHOICE"], inspect : [[{ inspect : { value : true}},{ inspect : { min : 0}},{ inspect : { min : 0}},{ inspect : null, bitmask : "FLAG"},{ inspect : { min : 0, display : "range", step : 0.01, max : 1}},{ inspect : { min : 0}},{ inspect : { min : 0}},{ inspect : { min : 0, display : "range", step : 0.01, max : 1}}]]}, getBlockOpenOrExpulsion : { 'return' : ["B_VIABLE_PROBABILITY_GET","MANUEVER_CHOICE"], inspect : [[{ inspect : { value : true}},{ inspect : { min : 0}},{ inspect : { min : 0}},{ inspect : null, bitmask : "FLAG"},{ inspect : { min : 0, display : "range", step : 0.01, max : 1}},{ inspect : { min : 0}}]]}, getAdvantageGainCPOffensiveMove : { 'return' : ["B_VIABLE_PROBABILITY_GET","MANUEVER_CHOICE"]}, getPredictedOpponentDTN : { inspect : null}, getPredictedOpponentATN : { inspect : null}, getComboExchangeBudgetingWithInitiative : { inspect : [[{ inspect : { display : "selector"}, choices : "COMBO"},{ inspect : { min : 0}},{ inspect : { min : 0}}]]}, getComboAction : { 'return' : ["B_VIABLE_PROBABILITY_GET","MANUEVER_CHOICE"], inspect : [[{ inspect : { display : "selector"}, choices : "COMBO"},{ inspect : { min : 0}},{ inspect : { min : 0}}]]}, setBestComboActionWithInitiativePlan : { 'return' : ["MANUEVER_COMBO_SET","MANUEVER_CHOICE_SET","B_COMBO_CANDIDATE_COUNT","B_COMBO_CANDIDATES"], inspect : [[{ inspect : { min : 0}},{ inspect : { min : 0}}]]}, setBestComboActionWithoutInitiativePlan : { 'return' : ["MANUEVER_COMBO_SET","MANUEVER_CHOICE_SET","B_COMBO_CANDIDATE_COUNT","B_COMBO_CANDIDATES"], inspect : [[{ inspect : { min : 0}},{ inspect : { min : 0}}]]}}, fields : { body : { inject : null}, cp : { bind : ["_cp"]}, perception : { bind : ["_perception"]}, equipMasterhand : { bind : ["_equipMasterhand"]}, equipOffhand : { bind : ["_equipOffhand"]}, mobility : { bind : ["_mobility"]}, id : { bind : ["_id"]}, initiative : { bind : ["_fight_initiative"]}, stance : { bind : ["_fight_stance"]}, manueverUsingHands : { bind : ["_manueverUsingHands"]}}};
troshx_tros_ai_TROSAiBot.__rtti = "<class path=\"troshx.tros.ai.TROSAiBot\" params=\"\">\n\t<ENEMY_STEAL_COST expr=\"4\" line=\"42\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e>4</e></m></meta>\n\t</ENEMY_STEAL_COST>\n\t<MIN_EXPOSED_AV expr=\"0\" line=\"43\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e>0</e></m></meta>\n\t</MIN_EXPOSED_AV>\n\t<getTargetAlphaStrikeCPThreshold get=\"inline\" set=\"null\" line=\"44\" static=\"1\"><f a=\"\"><x path=\"Int\"/></f></getTargetAlphaStrikeCPThreshold>\n\t<setAlphaStrikeBudget get=\"inline\" set=\"null\" line=\"47\" static=\"1\"><f a=\"cp:cp2\">\n\t<x path=\"Int\"/>\n\t<x path=\"Int\"/>\n\t<x path=\"Void\"/>\n</f></setAlphaStrikeBudget>\n\t<AVAIL_bash public=\"1\" expr=\"0\" line=\"75\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta>\n\t\t\t<m n=\":value\"><e>0</e></m>\n\t\t\t<m n=\"inspect\"><e>{min:0}</e></m>\n\t\t\t<m n=\"bind\"/>\n\t\t</meta>\n\t</AVAIL_bash>\n\t<AVAIL_spike public=\"1\" expr=\"0\" line=\"76\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta>\n\t\t\t<m n=\":value\"><e>0</e></m>\n\t\t\t<m n=\"inspect\"><e>{min:0}</e></m>\n\t\t\t<m n=\"bind\"/>\n\t\t</meta>\n\t</AVAIL_spike>\n\t<AVAIL_cut public=\"1\" expr=\"0\" line=\"77\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta>\n\t\t\t<m n=\":value\"><e>0</e></m>\n\t\t\t<m n=\"inspect\"><e>{min:0}</e></m>\n\t\t\t<m n=\"bind\"/>\n\t\t</meta>\n\t</AVAIL_cut>\n\t<AVAIL_thrust public=\"1\" expr=\"0\" line=\"78\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta>\n\t\t\t<m n=\":value\"><e>0</e></m>\n\t\t\t<m n=\"inspect\"><e>{min:0}</e></m>\n\t\t\t<m n=\"bind\"/>\n\t\t</meta>\n\t</AVAIL_thrust>\n\t<AVAIL_beat public=\"1\" expr=\"0\" line=\"79\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta>\n\t\t\t<m n=\":value\"><e>0</e></m>\n\t\t\t<m n=\"inspect\"><e>{min:0}</e></m>\n\t\t\t<m n=\"bind\"/>\n\t\t</meta>\n\t</AVAIL_beat>\n\t<AVAIL_bindstrike public=\"1\" expr=\"0\" line=\"80\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta>\n\t\t\t<m n=\":value\"><e>0</e></m>\n\t\t\t<m n=\"inspect\"><e>{min:0}</e></m>\n\t\t\t<m n=\"bind\"/>\n\t\t</meta>\n\t</AVAIL_bindstrike>\n\t<AVAIL_hook public=\"1\" expr=\"0\" line=\"81\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta>\n\t\t\t<m n=\":value\"><e>0</e></m>\n\t\t\t<m n=\"inspect\"><e>{min:0}</e></m>\n\t\t\t<m n=\"bind\"/>\n\t\t</meta>\n\t</AVAIL_hook>\n\t<AVAIL_block public=\"1\" expr=\"0\" line=\"84\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta>\n\t\t\t<m n=\":value\"><e>0</e></m>\n\t\t\t<m n=\"inspect\"><e>{min:0}</e></m>\n\t\t\t<m n=\"bind\"/>\n\t\t</meta>\n\t</AVAIL_block>\n\t<AVAIL_parry public=\"1\" expr=\"0\" line=\"85\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta>\n\t\t\t<m n=\":value\"><e>0</e></m>\n\t\t\t<m n=\"inspect\"><e>{min:0}</e></m>\n\t\t\t<m n=\"bind\"/>\n\t\t</meta>\n\t</AVAIL_parry>\n\t<AVAIL_duckweave public=\"1\" expr=\"0\" line=\"86\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta>\n\t\t\t<m n=\":value\"><e>0</e></m>\n\t\t\t<m n=\"inspect\"><e>{min:0}</e></m>\n\t\t\t<m n=\"bind\"/>\n\t\t</meta>\n\t</AVAIL_duckweave>\n\t<AVAIL_partialevasion public=\"1\" expr=\"0\" line=\"87\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta>\n\t\t\t<m n=\":value\"><e>0</e></m>\n\t\t\t<m n=\"inspect\"><e>{min:0}</e></m>\n\t\t\t<m n=\"bind\"/>\n\t\t</meta>\n\t</AVAIL_partialevasion>\n\t<AVAIL_fullevasion public=\"1\" expr=\"0\" line=\"88\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta>\n\t\t\t<m n=\":value\"><e>0</e></m>\n\t\t\t<m n=\"inspect\"><e>{min:0}</e></m>\n\t\t\t<m n=\"bind\"/>\n\t\t</meta>\n\t</AVAIL_fullevasion>\n\t<AVAIL_blockopenstrike public=\"1\" expr=\"0\" line=\"89\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta>\n\t\t\t<m n=\":value\"><e>0</e></m>\n\t\t\t<m n=\"inspect\"><e>{min:0}</e></m>\n\t\t\t<m n=\"bind\"/>\n\t\t</meta>\n\t</AVAIL_blockopenstrike>\n\t<AVAIL_counter public=\"1\" expr=\"0\" line=\"90\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta>\n\t\t\t<m n=\":value\"><e>0</e></m>\n\t\t\t<m n=\"inspect\"><e>{min:0}</e></m>\n\t\t\t<m n=\"bind\"/>\n\t\t</meta>\n\t</AVAIL_counter>\n\t<AVAIL_rota public=\"1\" expr=\"0\" line=\"91\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta>\n\t\t\t<m n=\":value\"><e>0</e></m>\n\t\t\t<m n=\"inspect\"><e>{min:0}</e></m>\n\t\t\t<m n=\"bind\"/>\n\t\t</meta>\n\t</AVAIL_rota>\n\t<AVAIL_expulsion public=\"1\" expr=\"0\" line=\"92\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta>\n\t\t\t<m n=\":value\"><e>0</e></m>\n\t\t\t<m n=\"inspect\"><e>{min:0}</e></m>\n\t\t\t<m n=\"bind\"/>\n\t\t</meta>\n\t</AVAIL_expulsion>\n\t<AVAIL_disarm public=\"1\" expr=\"0\" line=\"93\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta>\n\t\t\t<m n=\":value\"><e>0</e></m>\n\t\t\t<m n=\"inspect\"><e>{min:0}</e></m>\n\t\t\t<m n=\"bind\"/>\n\t\t</meta>\n\t</AVAIL_disarm>\n\t<AVAIL_StealInitiative public=\"1\" expr=\"0\" line=\"94\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta>\n\t\t\t<m n=\":value\"><e>0</e></m>\n\t\t\t<m n=\"inspect\"><e>{min:0}</e></m>\n\t\t\t<m n=\"bind\"/>\n\t\t</meta>\n\t</AVAIL_StealInitiative>\n\t<setTypicalAVAILCostsForTesting set=\"method\" line=\"96\" static=\"1\"><f a=\"\"><x path=\"Void\"/></f></setTypicalAVAILCostsForTesting>\n\t<getCostOfAVAIL get=\"inline\" set=\"null\" line=\"118\" static=\"1\"><f a=\"avail\">\n\t<x path=\"Int\"/>\n\t<x path=\"Int\"/>\n</f></getCostOfAVAIL>\n\t<getCostOfManuever set=\"method\" line=\"122\" static=\"1\"><f a=\"manuever\">\n\t<c path=\"String\"/>\n\t<x path=\"Int\"/>\n</f></getCostOfManuever>\n\t<B_EQUIP expr=\"&quot;&quot;\" line=\"152\" static=\"1\">\n\t\t<c path=\"String\"/>\n\t\t<meta>\n\t\t\t<m n=\":value\"><e>\"\"</e></m>\n\t\t\t<m n=\"settable\"/>\n\t\t</meta>\n\t</B_EQUIP>\n\t<B_IS_OFFHAND expr=\"false\" line=\"153\" static=\"1\">\n\t\t<x path=\"Bool\"/>\n\t\t<meta>\n\t\t\t<m n=\":value\"><e>false</e></m>\n\t\t\t<m n=\"settable\"/>\n\t\t</meta>\n\t</B_IS_OFFHAND>\n\t<D_EQUIP expr=\"&quot;&quot;\" line=\"154\" static=\"1\">\n\t\t<c path=\"String\"/>\n\t\t<meta>\n\t\t\t<m n=\":value\"><e>\"\"</e></m>\n\t\t\t<m n=\"settable\"/>\n\t\t</meta>\n\t</D_EQUIP>\n\t<B_COMBO_EXCHANGE_BUDGET expr=\"&apos;???&apos;\" line=\"157\" static=\"1\">\n\t\t<x path=\"haxe.ds.Vector\"><x path=\"Int\"/></x>\n\t\t<meta><m n=\":value\"><e>'???'</e></m></meta>\n\t</B_COMBO_EXCHANGE_BUDGET>\n\t<BUDGET_EXCHANGE_1 get=\"inline\" set=\"null\" expr=\"0\" line=\"158\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e>0</e></m></meta>\n\t</BUDGET_EXCHANGE_1>\n\t<BUDGET_EXCHANGE_1_ENEMY get=\"inline\" set=\"null\" expr=\"1\" line=\"159\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e>1</e></m></meta>\n\t</BUDGET_EXCHANGE_1_ENEMY>\n\t<BUDGET_EXCHANGE_2 get=\"inline\" set=\"null\" expr=\"2\" line=\"160\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e>2</e></m></meta>\n\t</BUDGET_EXCHANGE_2>\n\t<BUDGET_EXCHANGE_2_ENEMY get=\"inline\" set=\"null\" expr=\"3\" line=\"161\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e>3</e></m></meta>\n\t</BUDGET_EXCHANGE_2_ENEMY>\n\t<CURRENT_OPPONENT static=\"1\">\n\t\t<c path=\"troshx.tros.ai.TROSAiBot\"/>\n\t\t<meta><m n=\"inject\"/></meta>\n\t</CURRENT_OPPONENT>\n\t<COMBO_PureMeanStrikes get=\"inline\" set=\"null\" expr=\"1\" line=\"170\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e>1</e></m></meta>\n\t</COMBO_PureMeanStrikes>\n\t<COMBO_HeavyFirstStrikes get=\"inline\" set=\"null\" expr=\"2\" line=\"171\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e>2</e></m></meta>\n\t</COMBO_HeavyFirstStrikes>\n\t<COMBO_AlphaDisarm get=\"inline\" set=\"null\" expr=\"3\" line=\"172\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e>3</e></m></meta>\n\t</COMBO_AlphaDisarm>\n\t<COMBO_AlphaHookStrike get=\"inline\" set=\"null\" expr=\"4\" line=\"173\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e>4</e></m></meta>\n\t</COMBO_AlphaHookStrike>\n\t<COMBO_AlphaStrike get=\"inline\" set=\"null\" expr=\"5\" line=\"174\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e>5</e></m></meta>\n\t</COMBO_AlphaStrike>\n\t<COMBO_FeintStrike get=\"inline\" set=\"null\" expr=\"6\" line=\"175\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e>6</e></m></meta>\n\t</COMBO_FeintStrike>\n\t<COMBO_DoubleAttack get=\"inline\" set=\"null\" expr=\"7\" line=\"176\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e>7</e></m></meta>\n\t</COMBO_DoubleAttack>\n\t<COMBO_SimulatenousBlockStrike get=\"inline\" set=\"null\" expr=\"8\" line=\"177\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e>8</e></m></meta>\n\t</COMBO_SimulatenousBlockStrike>\n\t<COMBOS_LEN_INITIATIVE get=\"inline\" set=\"null\" expr=\"9\" line=\"178\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e>9</e></m></meta>\n\t</COMBOS_LEN_INITIATIVE>\n\t<COMBO_CoupDeGrace get=\"inline\" set=\"null\" expr=\"9\" line=\"179\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e>9</e></m></meta>\n\t</COMBO_CoupDeGrace>\n\t<COMBOS_LEN_INITIATIVE_FINAL get=\"inline\" set=\"null\" expr=\"10\" line=\"180\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e>10</e></m></meta>\n\t</COMBOS_LEN_INITIATIVE_FINAL>\n\t<COMBO_DefensiveFirst get=\"inline\" set=\"null\" expr=\"-1\" line=\"183\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e>-1</e></m></meta>\n\t</COMBO_DefensiveFirst>\n\t<COMBO_DefensiveBorderline get=\"inline\" set=\"null\" expr=\"-2\" line=\"184\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e>-2</e></m></meta>\n\t</COMBO_DefensiveBorderline>\n\t<COMBO_AlphaInitiativeStealer get=\"inline\" set=\"null\" expr=\"-3\" line=\"185\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e>-3</e></m></meta>\n\t</COMBO_AlphaInitiativeStealer>\n\t<COMBO_AlphaDisarmDef get=\"inline\" set=\"null\" expr=\"-4\" line=\"186\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e>-4</e></m></meta>\n\t</COMBO_AlphaDisarmDef>\n\t<COMBO_SimulatenousBlockStrikeStealer get=\"inline\" set=\"null\" expr=\"-5\" line=\"187\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e>-5</e></m></meta>\n\t</COMBO_SimulatenousBlockStrikeStealer>\n\t<COMBOS_LEN_NO_INITAITIVE get=\"inline\" set=\"null\" expr=\"5\" line=\"188\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e>5</e></m></meta>\n\t</COMBOS_LEN_NO_INITAITIVE>\n\t<P_THRESHOLD_FAVORABLE public=\"1\" expr=\"0.75\" line=\"191\" static=\"1\">\n\t\t<x path=\"Float\"/>\n\t\t<meta>\n\t\t\t<m n=\":value\"><e>0.75</e></m>\n\t\t\t<m n=\"inspect\"><e>{min:0,max:1,display:\"range\",step:0.01}</e></m>\n\t\t</meta>\n\t</P_THRESHOLD_FAVORABLE>\n\t<P_THRESHOLD_BORDERLINE public=\"1\" expr=\"0.5\" line=\"192\" static=\"1\">\n\t\t<x path=\"Float\"/>\n\t\t<meta>\n\t\t\t<m n=\":value\"><e>0.5</e></m>\n\t\t\t<m n=\"inspect\"><e>{min:0,max:1,display:\"range\",step:0.01}</e></m>\n\t\t</meta>\n\t</P_THRESHOLD_BORDERLINE>\n\t<P_RECKLESS public=\"1\" expr=\"0.2\" line=\"193\" static=\"1\">\n\t\t<x path=\"Float\"/>\n\t\t<meta>\n\t\t\t<m n=\":value\"><e>0.2</e></m>\n\t\t\t<m n=\"inspect\"><e>{min:0,max:1,display:\"range\",step:0.01}</e></m>\n\t\t</meta>\n\t</P_RECKLESS>\n\t<B_CANDIDATES expr=\"[]\" line=\"196\" static=\"1\">\n\t\t<c path=\"Array\"><c path=\"String\"/></c>\n\t\t<meta><m n=\":value\"><e>[]</e></m></meta>\n\t</B_CANDIDATES>\n\t<B_CANDIDATE_COUNT expr=\"0\" line=\"197\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e>0</e></m></meta>\n\t</B_CANDIDATE_COUNT>\n\t<B_BS_REQUIRED expr=\"1\" line=\"198\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e>1</e></m></meta>\n\t</B_BS_REQUIRED>\n\t<B_BS_REQUIRED_DEFAULT expr=\"1\" line=\"201\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e>1</e></m></meta>\n\t</B_BS_REQUIRED_DEFAULT>\n\t<COUP_BS_MODIFIER get=\"inline\" set=\"null\" expr=\"1\" line=\"202\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e>1</e></m></meta>\n\t</COUP_BS_MODIFIER>\n\t<B_BS_REQUIRED_DMG_DEFAULT expr=\"1\" line=\"203\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta>\n\t\t\t<m n=\":value\"><e>1</e></m>\n\t\t\t<m n=\"inspect\"><e>{min:1}</e></m>\n\t\t</meta>\n\t</B_BS_REQUIRED_DMG_DEFAULT>\n\t<PREFERED_HOOK_BS expr=\"2\" line=\"204\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e>2</e></m></meta>\n\t</PREFERED_HOOK_BS>\n\t<PREFERED_DISARM_BS expr=\"2\" line=\"205\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e>2</e></m></meta>\n\t</PREFERED_DISARM_BS>\n\t<PREFERED_DISARM_DEF_BS expr=\"2\" line=\"206\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e>2</e></m></meta>\n\t</PREFERED_DISARM_DEF_BS>\n\t<B_VIABLE_PROBABILITY static=\"1\"><x path=\"Float\"/></B_VIABLE_PROBABILITY>\n\t<B_VIABLE_PROBABILITY_GET static=\"1\"><x path=\"Float\"/></B_VIABLE_PROBABILITY_GET>\n\t<B_VIABLE_HEURISTIC static=\"1\"><x path=\"Bool\"/></B_VIABLE_HEURISTIC>\n\t<B_MANUEVER_CHOICES expr=\"[]\" line=\"212\" static=\"1\">\n\t\t<c path=\"Array\"><c path=\"troshx.util.AIManueverChoice\"/></c>\n\t\t<meta><m n=\":value\"><e>[]</e></m></meta>\n\t</B_MANUEVER_CHOICES>\n\t<B_MANUEVER_CHOICE_PROBABILITIES expr=\"[]\" line=\"213\" static=\"1\">\n\t\t<c path=\"Array\"><x path=\"Float\"/></c>\n\t\t<meta><m n=\":value\"><e>[]</e></m></meta>\n\t</B_MANUEVER_CHOICE_PROBABILITIES>\n\t<B_MANUEVER_CHOICE_COUNT expr=\"0\" line=\"214\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e>0</e></m></meta>\n\t</B_MANUEVER_CHOICE_COUNT>\n\t<B_COMBO_CANDIDATES expr=\"[]\" line=\"216\" static=\"1\">\n\t\t<c path=\"Array\"><x path=\"Int\"/></c>\n\t\t<meta>\n\t\t\t<m n=\":value\"><e>[]</e></m>\n\t\t\t<m n=\"enum\"><e>\"COMBO\"</e></m>\n\t\t</meta>\n\t</B_COMBO_CANDIDATES>\n\t<B_COMBO_CANDIDATE_MANUEVER expr=\"[]\" line=\"217\" static=\"1\">\n\t\t<c path=\"Array\"><c path=\"troshx.util.AIManueverChoice\"/></c>\n\t\t<meta><m n=\":value\"><e>[]</e></m></meta>\n\t</B_COMBO_CANDIDATE_MANUEVER>\n\t<B_COMBO_CANDIDATE_COUNT expr=\"0\" line=\"218\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e>0</e></m></meta>\n\t</B_COMBO_CANDIDATE_COUNT>\n\t<BPROB_BASE get=\"inline\" set=\"null\" expr=\"1000\" line=\"220\" static=\"1\">\n\t\t<x path=\"Float\"/>\n\t\t<meta><m n=\":value\"><e>1000</e></m></meta>\n\t</BPROB_BASE>\n\t<DMG_AGGR_BASE get=\"inline\" set=\"null\" expr=\"10\" line=\"221\" static=\"1\">\n\t\t<x path=\"Float\"/>\n\t\t<meta><m n=\":value\"><e>10</e></m></meta>\n\t</DMG_AGGR_BASE>\n\t<IMPOSSIBLE_TN get=\"inline\" set=\"null\" expr=\"888\" line=\"222\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e>888</e></m></meta>\n\t</IMPOSSIBLE_TN>\n\t<B_USE_ADVANTAGE public=\"1\" expr=\"false\" line=\"225\" static=\"1\">\n\t\t<x path=\"Bool\"/>\n\t\t<meta><m n=\":value\"><e>false</e></m></meta>\n\t</B_USE_ADVANTAGE>\n\t<getRegularAttackOrAdvantageMove public=\"1\" set=\"method\" line=\"237\" static=\"1\">\n\t\t<f a=\"availableCP:?roll:?againstRoll:?againstTN\" v=\":0:-1:1\">\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<c path=\"String\"/>\n\t\t</f>\n\t\t<meta>\n\t\t\t<m n=\":value\"><e>{againstTN:1,againstRoll:-1,roll:0}</e></m>\n\t\t\t<m n=\"inspect\"><e>[{inspect:{min:0}},{inspect:{min:0}},{inspect:{min:-1}},{inspect:{min:1}}]</e></m>\n\t\t\t<m n=\"return\"><e>\"B_USE_ADVANTAGE\"</e></m>\n\t\t</meta>\n\t</getRegularAttackOrAdvantageMove>\n\t<getRegularAdvantageMove set=\"method\" line=\"259\" static=\"1\">\n\t\t<f a=\"availableCP:?roll:?againstRoll:?againstTN\" v=\":0:-1:1\">\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<c path=\"String\"/>\n\t\t</f>\n\t\t<meta>\n\t\t\t<m n=\":value\"><e>{againstTN:1,againstRoll:-1,roll:0}</e></m>\n\t\t\t<m n=\"return\">\n\t\t\t\t<e>\"B_CANDIDATES\"</e>\n\t\t\t\t<e>\"B_CANDIDATE_COUNT\"</e>\n\t\t\t\t<e>\"ATTACK_AGGR\"</e>\n\t\t\t</m>\n\t\t\t<m n=\"inspect\"><e>[{inspect:{min:0}},{inspect:{min:0}},{inspect:{min:-1}},{inspect:{min:1}}]</e></m>\n\t\t</meta>\n\t</getRegularAdvantageMove>\n\t<mathMax get=\"inline\" set=\"null\" line=\"313\" static=\"1\"><f a=\"a:b\">\n\t<x path=\"Int\"/>\n\t<x path=\"Int\"/>\n\t<x path=\"Int\"/>\n</f></mathMax>\n\t<enforceDmgAggrIfFav set=\"method\" line=\"317\" static=\"1\"><f a=\"val\">\n\t<x path=\"Float\"/>\n\t<x path=\"Float\"/>\n</f></enforceDmgAggrIfFav>\n\t<ATTACK_AGGR expr=\"0\" line=\"322\" static=\"1\">\n\t\t<x path=\"Float\"/>\n\t\t<meta><m n=\":value\"><e>0</e></m></meta>\n\t</ATTACK_AGGR>\n\t<getRegularAttack set=\"method\" line=\"333\" static=\"1\">\n\t\t<f a=\"availableCP:?roll:?againstRoll:?againstTN\" v=\":0:-1:1\">\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<c path=\"String\"/>\n\t\t</f>\n\t\t<meta>\n\t\t\t<m n=\":value\"><e>{againstTN:1,againstRoll:-1,roll:0}</e></m>\n\t\t\t<m n=\"return\">\n\t\t\t\t<e>\"B_CANDIDATES\"</e>\n\t\t\t\t<e>\"B_CANDIDATE_COUNT\"</e>\n\t\t\t\t<e>\"ATTACK_AGGR\"</e>\n\t\t\t</m>\n\t\t\t<m n=\"inspect\"><e>[{inspect:{min:0}},{inspect:{min:0}},{inspect:{min:-1}},{inspect:{min:1}}]</e></m>\n\t\t</meta>\n\t</getRegularAttack>\n\t<getRegularDefense public=\"1\" set=\"method\" line=\"438\" static=\"1\">\n\t\t<f a=\"availableCP:?roll:?enforceMustRegainInitiative\" v=\":0:false\">\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Bool\"/>\n\t\t\t<c path=\"String\"/>\n\t\t</f>\n\t\t<meta>\n\t\t\t<m n=\":value\"><e>{enforceMustRegainInitiative:false,roll:0}</e></m>\n\t\t\t<m n=\"return\">\n\t\t\t\t<e>\"B_CANDIDATES\"</e>\n\t\t\t\t<e>\"B_CANDIDATE_COUNT\"</e>\n\t\t\t</m>\n\t\t\t<m n=\"inspect\"><e>[{inspect:{min:0}},{inspect:{min:0}}]</e></m>\n\t\t</meta>\n\t</getRegularDefense>\n\t<getATNOfManuever set=\"method\" line=\"501\" static=\"1\"><f a=\"manuever\">\n\t<c path=\"String\"/>\n\t<x path=\"Int\"/>\n</f></getATNOfManuever>\n\t<getDTNOfManuever set=\"method\" line=\"520\" static=\"1\"><f a=\"manuever\">\n\t<c path=\"String\"/>\n\t<x path=\"Int\"/>\n</f></getDTNOfManuever>\n\t<getTargetZoneAverageAVOffset public=\"1\" set=\"method\" line=\"543\" static=\"1\"><f a=\"tarZone:weaponName\">\n\t<x path=\"Int\"/>\n\t<c path=\"String\"/>\n\t<x path=\"Int\"/>\n</f></getTargetZoneAverageAVOffset>\n\t<getRegularTargetZone public=\"1\" set=\"method\" line=\"548\" static=\"1\"><f a=\"manuever:atn:cp\">\n\t<c path=\"String\"/>\n\t<x path=\"Int\"/>\n\t<x path=\"Int\"/>\n\t<x path=\"Int\"/>\n</f></getRegularTargetZone>\n\t<MANUEVER_CHOICE expr=\"&apos;???&apos;\" line=\"581\" static=\"1\">\n\t\t<c path=\"troshx.util.AIManueverChoice\"/>\n\t\t<meta><m n=\":value\"><e>'???'</e></m></meta>\n\t</MANUEVER_CHOICE>\n\t<MANUEVER_CHOICE_1 expr=\"&apos;???&apos;\" line=\"582\" static=\"1\">\n\t\t<c path=\"troshx.util.AIManueverChoice\"/>\n\t\t<meta><m n=\":value\"><e>'???'</e></m></meta>\n\t</MANUEVER_CHOICE_1>\n\t<MANUEVER_CHOICE_SET expr=\"&apos;???&apos;\" line=\"583\" static=\"1\">\n\t\t<c path=\"troshx.util.AIManueverChoice\"/>\n\t\t<meta><m n=\":value\"><e>'???'</e></m></meta>\n\t</MANUEVER_CHOICE_SET>\n\t<MANUEVER_COMBO_SET expr=\"0\" line=\"584\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta>\n\t\t\t<m n=\":value\"><e>0</e></m>\n\t\t\t<m n=\"enum\"><e>\"COMBO\"</e></m>\n\t\t</meta>\n\t</MANUEVER_COMBO_SET>\n\t<checkCostViability set=\"method\" line=\"587\" static=\"1\">\n\t\t<f a=\"availableCP:tn:threshold:againstRoll:?againstTN:?useAllCP\" v=\"::::1:false\">\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Float\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Bool\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t</f>\n\t\t<meta>\n\t\t\t<m n=\":value\"><e>{useAllCP:false,againstTN:1}</e></m>\n\t\t\t<m n=\"return\"><e>\"B_VIABLE_PROBABILITY\"</e></m>\n\t\t</meta>\n\t</checkCostViability>\n\t<precisionPerc get=\"inline\" set=\"null\" line=\"602\" static=\"1\"><f a=\"val\">\n\t<x path=\"Float\"/>\n\t<x path=\"Float\"/>\n</f></precisionPerc>\n\t<checkCostViabilityBorderline set=\"method\" line=\"607\" static=\"1\">\n\t\t<f a=\"availableCP:tn:threshold:againstRoll:?againstTN:?useAllCP\" v=\"::::1:false\">\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Float\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Bool\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t</f>\n\t\t<meta>\n\t\t\t<m n=\":value\"><e>{useAllCP:false,againstTN:1}</e></m>\n\t\t\t<m n=\"return\"><e>\"B_VIABLE_PROBABILITY\"</e></m>\n\t\t</meta>\n\t</checkCostViabilityBorderline>\n\t<checkCostAntiFavorability set=\"method\" line=\"630\" static=\"1\">\n\t\t<f a=\"availableCP:tn:threshold:againstCP:?againstTN:?useAllCP:?offset:?requiredBS\" v=\"::::1:false:0:1\">\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Float\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Bool\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t</f>\n\t\t<meta>\n\t\t\t<m n=\":value\"><e>{requiredBS:1,offset:0,useAllCP:false,againstTN:1}</e></m>\n\t\t\t<m n=\"return\"><e>\"B_VIABLE_PROBABILITY_GET\"</e></m>\n\t\t</meta>\n\t</checkCostAntiFavorability>\n\t<checkCostAntiBorderline set=\"method\" line=\"669\" static=\"1\">\n\t\t<f a=\"availableCP:tn:threshold:againstCP:?againstTN:?useAllCP:?offset\" v=\"::::1:false:0\">\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Float\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Bool\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t</f>\n\t\t<meta>\n\t\t\t<m n=\":value\"><e>{offset:0,useAllCP:false,againstTN:1}</e></m>\n\t\t\t<m n=\"return\"><e>\"B_VIABLE_PROBABILITY_GET\"</e></m>\n\t\t</meta>\n\t</checkCostAntiBorderline>\n\t<getCostOfAvail get=\"inline\" set=\"null\" line=\"703\" static=\"1\"><f a=\"avail\">\n\t<x path=\"Int\"/>\n\t<x path=\"Int\"/>\n</f></getCostOfAvail>\n\t<getTheSuitableAttack set=\"method\" line=\"707\" static=\"1\">\n\t\t<f a=\"manuever:tn:tarZone:threshold:availableCP:?againstRoll:?againstTN:?favorable:?useAllCP\" v=\":::::0:1:true:false\">\n\t\t\t<c path=\"String\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Float\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Bool\"/>\n\t\t\t<x path=\"Bool\"/>\n\t\t\t<x path=\"Bool\"/>\n\t\t</f>\n\t\t<meta><m n=\":value\"><e>{useAllCP:false,favorable:true,againstTN:1,againstRoll:0}</e></m></meta>\n\t</getTheSuitableAttack>\n\t<getTheSuitableDefense set=\"method\" line=\"717\" static=\"1\">\n\t\t<f a=\"manuever:tn:threshold:availableCP:?againstRoll:?againstTN:?favorable:?useAllCP\" v=\"::::0:1:true:false\">\n\t\t\t<c path=\"String\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Float\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Bool\"/>\n\t\t\t<x path=\"Bool\"/>\n\t\t\t<x path=\"Bool\"/>\n\t\t</f>\n\t\t<meta><m n=\":value\"><e>{useAllCP:false,favorable:true,againstTN:1,againstRoll:0}</e></m></meta>\n\t</getTheSuitableDefense>\n\t<getTheForcefulInitiativeAttack set=\"method\" line=\"726\" static=\"1\">\n\t\t<f a=\"manuever:tn:tarZone:threshold:availableCP:?againstCP:?againstTN:?favorable:?useAllCP:?offset\" v=\":::::0:1:true:false:0\">\n\t\t\t<c path=\"String\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Float\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Bool\"/>\n\t\t\t<x path=\"Bool\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Bool\"/>\n\t\t</f>\n\t\t<meta><m n=\":value\"><e>{offset:0,useAllCP:false,favorable:true,againstTN:1,againstCP:0}</e></m></meta>\n\t</getTheForcefulInitiativeAttack>\n\t<getASuitableAttack public=\"1\" set=\"method\" line=\"737\" static=\"1\">\n\t\t<f a=\"threshold:availableCP:?againstRoll:?againstTN:?favorable:?useAllCP\" v=\"::0:1:true:false\">\n\t\t\t<x path=\"Float\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Bool\"/>\n\t\t\t<x path=\"Bool\"/>\n\t\t\t<x path=\"Bool\"/>\n\t\t</f>\n\t\t<meta>\n\t\t\t<m n=\":value\"><e>{useAllCP:false,favorable:true,againstTN:1,againstRoll:0}</e></m>\n\t\t\t<m n=\"return\">\n\t\t\t\t<e>\"MANUEVER_CHOICE\"</e>\n\t\t\t\t<e>\"B_VIABLE_PROBABILITY\"</e>\n\t\t\t</m>\n\t\t\t<m n=\"inspect\"><e>[{inspect:{min:0,step:0.01,max:1,display:\"range\"}},{inspect:{min:0}},{inspect:{min:0}},{inspect:{min:1}}]</e></m>\n\t\t</meta>\n\t</getASuitableAttack>\n\t<getAForcefulInitiativeAttack public=\"1\" set=\"method\" line=\"755\" static=\"1\">\n\t\t<f a=\"threshold:availableCP:?againstCP:?againstTN:?favorable:?useAllCP:?offset\" v=\"::0:1:true:false:0\">\n\t\t\t<x path=\"Float\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Bool\"/>\n\t\t\t<x path=\"Bool\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Bool\"/>\n\t\t</f>\n\t\t<meta>\n\t\t\t<m n=\":value\"><e>{offset:0,useAllCP:false,favorable:true,againstTN:1,againstCP:0}</e></m>\n\t\t\t<m n=\"return\">\n\t\t\t\t<e>\"MANUEVER_CHOICE\"</e>\n\t\t\t\t<e>\"B_VIABLE_PROBABILITY_GET\"</e>\n\t\t\t</m>\n\t\t\t<m n=\"inspect\"><e>[{inspect:{min:0,step:0.01,max:1,display:\"range\"}},{inspect:{min:0}},{inspect:{min:0}},{inspect:{min:1}}]</e></m>\n\t\t</meta>\n\t</getAForcefulInitiativeAttack>\n\t<getASuitableDefense public=\"1\" set=\"method\" line=\"775\" static=\"1\">\n\t\t<f a=\"threshold:availableCP:?againstRoll:?againstTN:?mustRegainInitiative:?favorable:?useAllCP\" v=\"::0:1:false:true:false\">\n\t\t\t<x path=\"Float\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Bool\"/>\n\t\t\t<x path=\"Bool\"/>\n\t\t\t<x path=\"Bool\"/>\n\t\t\t<x path=\"Bool\"/>\n\t\t</f>\n\t\t<meta>\n\t\t\t<m n=\":value\"><e>{useAllCP:false,favorable:true,mustRegainInitiative:false,againstTN:1,againstRoll:0}</e></m>\n\t\t\t<m n=\"return\">\n\t\t\t\t<e>\"MANUEVER_CHOICE\"</e>\n\t\t\t\t<e>\"B_VIABLE_PROBABILITY\"</e>\n\t\t\t</m>\n\t\t\t<m n=\"inspect\"><e>[{inspect:{min:0,step:0.01,max:1,display:\"range\"}},{inspect:{min:0}},{inspect:{min:0}},{inspect:{min:1}}]</e></m>\n\t\t</meta>\n\t</getASuitableDefense>\n\t<FLAG_GET_CHEAPEST public=\"1\" get=\"inline\" set=\"null\" expr=\"1\" line=\"786\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e>1</e></m></meta>\n\t</FLAG_GET_CHEAPEST>\n\t<FLAG_USE_ALL_CP public=\"1\" get=\"inline\" set=\"null\" expr=\"2\" line=\"787\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e>2</e></m></meta>\n\t</FLAG_USE_ALL_CP>\n\t<FLAG_BORDERLINE_DEF_SAFETY public=\"1\" get=\"inline\" set=\"null\" expr=\"4\" line=\"788\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e>4</e></m></meta>\n\t</FLAG_BORDERLINE_DEF_SAFETY>\n\t<getFavorableAttack public=\"1\" get=\"inline\" set=\"null\" line=\"792\" static=\"1\">\n\t\t<f a=\"availableCP:?againstRoll:?againstTN:?heuristic:?flags:?customThreshold\" v=\":0:1:true:0:0\">\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Bool\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Float\"/>\n\t\t\t<x path=\"Bool\"/>\n\t\t</f>\n\t\t<meta>\n\t\t\t<m n=\":value\"><e>{customThreshold:0,flags:0,heuristic:true,againstTN:1,againstRoll:0}</e></m>\n\t\t\t<m n=\"inspect\"><e>[{inspect:{min:0}},{inspect:{min:0}},{inspect:{min:1}},{inspect:null},{inspect:null,bitmask:\"FLAG\"},{inspect:{min:0,display:\"range\",step:0.01,max:1}}]</e></m>\n\t\t\t<m n=\"return\">\n\t\t\t\t<e>\"B_VIABLE_PROBABILITY_GET\"</e>\n\t\t\t\t<e>\"MANUEVER_CHOICE\"</e>\n\t\t\t\t<e>\"B_VIABLE_HEURISTIC\"</e>\n\t\t\t</m>\n\t\t</meta>\n\t</getFavorableAttack>\n\t<getBorderlineAttack public=\"1\" set=\"method\" line=\"800\" static=\"1\">\n\t\t<f a=\"availableCP:?againstRoll:?againstTN:?heuristic:?flags:?customThreshold\" v=\":0:1:true:0:0\">\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Bool\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Float\"/>\n\t\t\t<x path=\"Bool\"/>\n\t\t</f>\n\t\t<meta>\n\t\t\t<m n=\":value\"><e>{customThreshold:0,flags:0,heuristic:true,againstTN:1,againstRoll:0}</e></m>\n\t\t\t<m n=\"inspect\"><e>[{inspect:{min:0}},{inspect:{min:0}},{inspect:{min:1}},{inspect:null},{inspect:null,bitmask:\"FLAG\"},{inspect:{min:0,display:\"range\",step:0.01,max:1}}]</e></m>\n\t\t\t<m n=\"return\">\n\t\t\t\t<e>\"B_VIABLE_PROBABILITY_GET\"</e>\n\t\t\t\t<e>\"MANUEVER_CHOICE\"</e>\n\t\t\t\t<e>\"B_VIABLE_HEURISTIC\"</e>\n\t\t\t</m>\n\t\t</meta>\n\t</getBorderlineAttack>\n\t<getFBAttack set=\"method\" line=\"805\" static=\"1\">\n\t\t<f a=\"favorable:availableCP:?againstRoll:?againstTN:?heuristic:?flags:?customThreshold\" v=\"::0:1:true:0:0\">\n\t\t\t<x path=\"Bool\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Bool\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Float\"/>\n\t\t\t<x path=\"Bool\"/>\n\t\t</f>\n\t\t<meta><m n=\":value\"><e>{customThreshold:0,flags:0,heuristic:true,againstTN:1,againstRoll:0}</e></m></meta>\n\t</getFBAttack>\n\t<getFBDefense set=\"method\" line=\"927\" static=\"1\">\n\t\t<f a=\"favorable:availableCP:?againstRoll:?againstTN:?heuristic:?flags:?customThreshold\" v=\"::0:1:true:0:0\">\n\t\t\t<x path=\"Bool\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Bool\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Float\"/>\n\t\t\t<x path=\"Bool\"/>\n\t\t</f>\n\t\t<meta><m n=\":value\"><e>{customThreshold:0,flags:0,heuristic:true,againstTN:1,againstRoll:0}</e></m></meta>\n\t</getFBDefense>\n\t<getFavorableDefense public=\"1\" get=\"inline\" set=\"null\" line=\"1066\" static=\"1\">\n\t\t<f a=\"availableCP:?againstRoll:?againstTN:?heuristic:?flags\" v=\":0:1:true:0\">\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Bool\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Bool\"/>\n\t\t</f>\n\t\t<meta>\n\t\t\t<m n=\":value\"><e>{flags:0,heuristic:true,againstTN:1,againstRoll:0}</e></m>\n\t\t\t<m n=\"return\">\n\t\t\t\t<e>\"B_VIABLE_PROBABILITY_GET\"</e>\n\t\t\t\t<e>\"MANUEVER_CHOICE\"</e>\n\t\t\t\t<e>\"B_VIABLE_HEURISTIC\"</e>\n\t\t\t</m>\n\t\t</meta>\n\t</getFavorableDefense>\n\t<getBorderlineDefense public=\"1\" get=\"inline\" set=\"null\" line=\"1071\" static=\"1\">\n\t\t<f a=\"availableCP:?againstRoll:?againstTN:?heuristic:?flags\" v=\":0:1:true:0\">\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Bool\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Bool\"/>\n\t\t</f>\n\t\t<meta>\n\t\t\t<m n=\":value\"><e>{flags:0,heuristic:true,againstTN:1,againstRoll:0}</e></m>\n\t\t\t<m n=\"return\">\n\t\t\t\t<e>\"B_VIABLE_PROBABILITY_GET\"</e>\n\t\t\t\t<e>\"MANUEVER_CHOICE\"</e>\n\t\t\t\t<e>\"B_VIABLE_HEURISTIC\"</e>\n\t\t\t</m>\n\t\t</meta>\n\t</getBorderlineDefense>\n\t<getFleeOrDefend public=\"1\" set=\"method\" line=\"1076\" static=\"1\">\n\t\t<f a=\"favorable:availableCP:?againstRoll:?againstTN:?heuristic:?flags:?customThreshold:?secondExchange\" v=\"::0:1:true:0:0:false\">\n\t\t\t<x path=\"Bool\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Bool\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Float\"/>\n\t\t\t<x path=\"Bool\"/>\n\t\t\t<x path=\"Bool\"/>\n\t\t</f>\n\t\t<meta>\n\t\t\t<m n=\":value\"><e>{secondExchange:false,customThreshold:0,flags:0,heuristic:true,againstTN:1,againstRoll:0}</e></m>\n\t\t\t<m n=\"return\">\n\t\t\t\t<e>\"B_VIABLE_PROBABILITY_GET\"</e>\n\t\t\t\t<e>\"MANUEVER_CHOICE\"</e>\n\t\t\t</m>\n\t\t</meta>\n\t</getFleeOrDefend>\n\t<addPossibleRegularManueverChoice get=\"inline\" set=\"null\" line=\"1102\" static=\"1\"><f a=\"index\">\n\t<x path=\"Int\"/>\n\t<x path=\"Void\"/>\n</f></addPossibleRegularManueverChoice>\n\t<getAdvantageManuever set=\"method\" line=\"1107\" static=\"1\">\n\t\t<f a=\"manueverName:favorable:availableCP:?againstRoll:?againstTN:?flags:?customThreshold:?preferedRS:?defensive\" v=\":::0:1:0:0:1:false\">\n\t\t\t<c path=\"String\"/>\n\t\t\t<x path=\"Bool\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Float\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Bool\"/>\n\t\t\t<x path=\"Bool\"/>\n\t\t</f>\n\t\t<meta><m n=\":value\"><e>{defensive:false,preferedRS:1,customThreshold:0,flags:0,againstTN:1,againstRoll:0}</e></m></meta>\n\t</getAdvantageManuever>\n\t<getBlockOpenAndStrike public=\"1\" set=\"method\" line=\"1136\" static=\"1\">\n\t\t<f a=\"favorable:availableCP:?againstRoll:?againstTN:?flags:?customThreshold:?preferedRS\" v=\"::0:1:0:0:1\">\n\t\t\t<x path=\"Bool\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Float\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Bool\"/>\n\t\t</f>\n\t\t<meta>\n\t\t\t<m n=\":value\"><e>{preferedRS:1,customThreshold:0,flags:0,againstTN:1,againstRoll:0}</e></m>\n\t\t\t<m n=\"return\">\n\t\t\t\t<e>\"B_VIABLE_PROBABILITY_GET\"</e>\n\t\t\t\t<e>\"MANUEVER_CHOICE\"</e>\n\t\t\t</m>\n\t\t</meta>\n\t</getBlockOpenAndStrike>\n\t<getRota public=\"1\" get=\"inline\" set=\"null\" line=\"1141\" static=\"1\">\n\t\t<f a=\"favorable:availableCP:againstRoll:againstTN:?flags:?customThreshold:?preferedRS\" v=\"::::0:0:1\">\n\t\t\t<x path=\"Bool\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Float\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Bool\"/>\n\t\t</f>\n\t\t<meta>\n\t\t\t<m n=\":value\"><e>{preferedRS:1,customThreshold:0,flags:0}</e></m>\n\t\t\t<m n=\"return\">\n\t\t\t\t<e>\"B_VIABLE_PROBABILITY_GET\"</e>\n\t\t\t\t<e>\"MANUEVER_CHOICE\"</e>\n\t\t\t</m>\n\t\t</meta>\n\t</getRota>\n\t<getCounter public=\"1\" get=\"inline\" set=\"null\" line=\"1146\" static=\"1\">\n\t\t<f a=\"favorable:availableCP:againstRoll:againstTN:?flags:?customThreshold:?preferedRS\" v=\"::::0:0:1\">\n\t\t\t<x path=\"Bool\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Float\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Bool\"/>\n\t\t</f>\n\t\t<meta>\n\t\t\t<m n=\":value\"><e>{preferedRS:1,customThreshold:0,flags:0}</e></m>\n\t\t\t<m n=\"return\">\n\t\t\t\t<e>\"B_VIABLE_PROBABILITY_GET\"</e>\n\t\t\t\t<e>\"MANUEVER_CHOICE\"</e>\n\t\t\t</m>\n\t\t</meta>\n\t</getCounter>\n\t<getExpulsion public=\"1\" get=\"inline\" set=\"null\" line=\"1151\" static=\"1\">\n\t\t<f a=\"favorable:availableCP:againstRoll:againstTN:?flags:?customThreshold:?preferedRS\" v=\"::::0:0:1\">\n\t\t\t<x path=\"Bool\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Float\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Bool\"/>\n\t\t</f>\n\t\t<meta>\n\t\t\t<m n=\":value\"><e>{preferedRS:1,customThreshold:0,flags:0}</e></m>\n\t\t\t<m n=\"return\">\n\t\t\t\t<e>\"B_VIABLE_PROBABILITY_GET\"</e>\n\t\t\t\t<e>\"MANUEVER_CHOICE\"</e>\n\t\t\t</m>\n\t\t</meta>\n\t</getExpulsion>\n\t<getDisarm public=\"1\" set=\"method\" line=\"1157\" static=\"1\">\n\t\t<f a=\"favorable:availableCP:?againstRoll:?againstTN:?flags:?customThreshold:?preferedRS:?defensive:?disarmOffhand\" v=\"::0:1:0:0:1:false:false\">\n\t\t\t<x path=\"Bool\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Float\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Bool\"/>\n\t\t\t<x path=\"Bool\"/>\n\t\t\t<x path=\"Bool\"/>\n\t\t</f>\n\t\t<meta>\n\t\t\t<m n=\":value\"><e>{disarmOffhand:false,defensive:false,preferedRS:1,customThreshold:0,flags:0,againstTN:1,againstRoll:0}</e></m>\n\t\t\t<m n=\"return\">\n\t\t\t\t<e>\"B_VIABLE_PROBABILITY_GET\"</e>\n\t\t\t\t<e>\"MANUEVER_CHOICE\"</e>\n\t\t\t</m>\n\t\t</meta>\n\t</getDisarm>\n\t<getHook public=\"1\" get=\"inline\" set=\"null\" line=\"1163\" static=\"1\">\n\t\t<f a=\"favorable:availableCP:?againstRoll:?againstTN:?flags:?customThreshold:?preferedRS\" v=\"::0:1:0:0:1\">\n\t\t\t<x path=\"Bool\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Float\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Bool\"/>\n\t\t</f>\n\t\t<meta>\n\t\t\t<m n=\":value\"><e>{preferedRS:1,customThreshold:0,flags:0,againstTN:1,againstRoll:0}</e></m>\n\t\t\t<m n=\"return\">\n\t\t\t\t<e>\"B_VIABLE_PROBABILITY_GET\"</e>\n\t\t\t\t<e>\"MANUEVER_CHOICE\"</e>\n\t\t\t</m>\n\t\t</meta>\n\t</getHook>\n\t<getBindStrike public=\"1\" get=\"inline\" set=\"null\" line=\"1168\" static=\"1\">\n\t\t<f a=\"favorable:availableCP:againstCP:?againstRoll:?againstTN:?flags:?customThreshold:?preferedRS\" v=\":::0:1:0:0:1\">\n\t\t\t<x path=\"Bool\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Float\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Bool\"/>\n\t\t</f>\n\t\t<meta>\n\t\t\t<m n=\":value\"><e>{preferedRS:1,customThreshold:0,flags:0,againstTN:1,againstRoll:0}</e></m>\n\t\t\t<m n=\"return\">\n\t\t\t\t<e>\"B_VIABLE_PROBABILITY_GET\"</e>\n\t\t\t\t<e>\"MANUEVER_CHOICE\"</e>\n\t\t\t</m>\n\t\t</meta>\n\t</getBindStrike>\n\t<getBeat public=\"1\" set=\"method\" line=\"1173\" static=\"1\">\n\t\t<f a=\"favorable:availableCP:?againstRoll:?againstTN:?flags:?customThreshold:?preferedRS:?preferTargetMaster\" v=\"::0:1:0:0:1:0\">\n\t\t\t<x path=\"Bool\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Float\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Bool\"/>\n\t\t</f>\n\t\t<meta>\n\t\t\t<m n=\":value\"><e>{preferTargetMaster:0,preferedRS:1,customThreshold:0,flags:0,againstTN:1,againstRoll:0}</e></m>\n\t\t\t<m n=\"return\">\n\t\t\t\t<e>\"B_VIABLE_PROBABILITY_GET\"</e>\n\t\t\t\t<e>\"MANUEVER_CHOICE\"</e>\n\t\t\t</m>\n\t\t</meta>\n\t</getBeat>\n\t<getRotaOrCounter public=\"1\" set=\"method\" line=\"1188\" static=\"1\">\n\t\t<f a=\"favorable:availableCP:againstManuever:?flags:?customThreshold:?preferedRS:?preferedCounterRSFav:?counterFavProbThreshold\" v=\":::0:0:1:0:0.75\">\n\t\t\t<x path=\"Bool\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<c path=\"troshx.util.AIManueverChoice\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Float\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Float\"/>\n\t\t\t<x path=\"Bool\"/>\n\t\t</f>\n\t\t<meta>\n\t\t\t<m n=\":value\"><e>{counterFavProbThreshold:0.75,preferedCounterRSFav:0,preferedRS:1,customThreshold:0,flags:0}</e></m>\n\t\t\t<m n=\"return\">\n\t\t\t\t<e>\"B_VIABLE_PROBABILITY_GET\"</e>\n\t\t\t\t<e>\"MANUEVER_CHOICE\"</e>\n\t\t\t</m>\n\t\t\t<m n=\"inspect\"><e>[{inspect:{value:true}},{inspect:{min:0}},{inspect:{min:0}},{inspect:null,bitmask:\"FLAG\"},{inspect:{min:0,display:\"range\",step:0.01,max:1}},{inspect:{min:0}},{inspect:{min:0}},{inspect:{min:0,display:\"range\",step:0.01,max:1}}]</e></m>\n\t\t</meta>\n\t</getRotaOrCounter>\n\t<getBlockOpenOrExpulsion public=\"1\" set=\"method\" line=\"1217\" static=\"1\">\n\t\t<f a=\"favorable:availableCP:againstManuever:?flags:?customThreshold:?preferedRS\" v=\":::0:0:0\">\n\t\t\t<x path=\"Bool\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<c path=\"troshx.util.AIManueverChoice\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Float\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Bool\"/>\n\t\t</f>\n\t\t<meta>\n\t\t\t<m n=\":value\"><e>{preferedRS:0,customThreshold:0,flags:0}</e></m>\n\t\t\t<m n=\"return\">\n\t\t\t\t<e>\"B_VIABLE_PROBABILITY_GET\"</e>\n\t\t\t\t<e>\"MANUEVER_CHOICE\"</e>\n\t\t\t</m>\n\t\t\t<m n=\"inspect\"><e>[{inspect:{value:true}},{inspect:{min:0}},{inspect:{min:0}},{inspect:null,bitmask:\"FLAG\"},{inspect:{min:0,display:\"range\",step:0.01,max:1}},{inspect:{min:0}}]</e></m>\n\t\t</meta>\n\t</getBlockOpenOrExpulsion>\n\t<getAdvantageGainCPOffensiveMove public=\"1\" set=\"method\" line=\"1255\" static=\"1\">\n\t\t<f a=\"favorable:availableCP:?againstRoll:?againstTN:?flags:?customThreshold:?preferedRS:?preferTargetMaster\" v=\"::0:1:0:0:1:0\">\n\t\t\t<x path=\"Bool\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Float\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Bool\"/>\n\t\t</f>\n\t\t<meta>\n\t\t\t<m n=\":value\"><e>{preferTargetMaster:0,preferedRS:1,customThreshold:0,flags:0,againstTN:1,againstRoll:0}</e></m>\n\t\t\t<m n=\"return\">\n\t\t\t\t<e>\"B_VIABLE_PROBABILITY_GET\"</e>\n\t\t\t\t<e>\"MANUEVER_CHOICE\"</e>\n\t\t\t</m>\n\t\t</meta>\n\t</getAdvantageGainCPOffensiveMove>\n\t<getPredictedOpponentDTN public=\"1\" get=\"inline\" set=\"null\" line=\"1288\" static=\"1\">\n\t\t<f a=\"\"><x path=\"Int\"/></f>\n\t\t<meta><m n=\"inspect\"/></meta>\n\t</getPredictedOpponentDTN>\n\t<getPredictedOpponentATN public=\"1\" get=\"inline\" set=\"null\" line=\"1293\" static=\"1\">\n\t\t<f a=\"\"><x path=\"Int\"/></f>\n\t\t<meta><m n=\"inspect\"/></meta>\n\t</getPredictedOpponentATN>\n\t<fluctuateLower get=\"inline\" set=\"null\" line=\"1370\" static=\"1\"><f a=\"val:lowerBy\">\n\t<x path=\"Float\"/>\n\t<x path=\"Float\"/>\n\t<x path=\"Float\"/>\n</f></fluctuateLower>\n\t<getComboExchangeBudgetingWithInitiative set=\"method\" line=\"1379\" static=\"1\">\n\t\t<f a=\"combo:cp:cp2:?threatManuever\" v=\":::null\">\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<c path=\"troshx.util.AIManueverChoice\"/>\n\t\t\t<x path=\"haxe.ds.Vector\"><x path=\"Int\"/></x>\n\t\t</f>\n\t\t<meta>\n\t\t\t<m n=\":value\"><e>{threatManuever:null}</e></m>\n\t\t\t<m n=\"inspect\"><e>[{inspect:{display:\"selector\"},choices:\"COMBO\"},{inspect:{min:0}},{inspect:{min:0}}]</e></m>\n\t\t</meta>\n\t</getComboExchangeBudgetingWithInitiative>\n\t<tryFavoredElseBorderlineAttacks get=\"inline\" set=\"null\" line=\"1468\" static=\"1\"><f a=\"cp:cp2:dtn:heuristic:flags\">\n\t<x path=\"Int\"/>\n\t<x path=\"Int\"/>\n\t<x path=\"Int\"/>\n\t<x path=\"Bool\"/>\n\t<x path=\"Int\"/>\n\t<x path=\"Bool\"/>\n</f></tryFavoredElseBorderlineAttacks>\n\t<getComboAction set=\"method\" line=\"1484\" static=\"1\">\n\t\t<f a=\"combo:cp:cp2:?threatManuever:?hasInitiative:?secondExchange\" v=\":::null:true:false\">\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<c path=\"troshx.util.AIManueverChoice\"/>\n\t\t\t<x path=\"Bool\"/>\n\t\t\t<x path=\"Bool\"/>\n\t\t\t<x path=\"Bool\"/>\n\t\t</f>\n\t\t<meta>\n\t\t\t<m n=\":value\"><e>{secondExchange:false,hasInitiative:true,threatManuever:null}</e></m>\n\t\t\t<m n=\"return\">\n\t\t\t\t<e>\"B_VIABLE_PROBABILITY_GET\"</e>\n\t\t\t\t<e>\"MANUEVER_CHOICE\"</e>\n\t\t\t</m>\n\t\t\t<m n=\"inspect\"><e>[{inspect:{display:\"selector\"},choices:\"COMBO\"},{inspect:{min:0}},{inspect:{min:0}}]</e></m>\n\t\t</meta>\n\t</getComboAction>\n\t<getCheapestBorderlineAtkCost set=\"method\" line=\"1617\" static=\"1\">\n\t\t<f a=\"cp:againstCP:dtn:?customThreshold\" v=\":::0\">\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Float\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t</f>\n\t\t<meta><m n=\":value\"><e>{customThreshold:0}</e></m></meta>\n\t</getCheapestBorderlineAtkCost>\n\t<getCoupThreshold get=\"inline\" set=\"null\" line=\"1637\" static=\"1\"><f a=\"cp2\">\n\t<x path=\"Int\"/>\n\t<x path=\"Float\"/>\n</f></getCoupThreshold>\n\t<addPossibleComboManueverChoice get=\"inline\" set=\"null\" line=\"1643\" static=\"1\"><f a=\"index:theChoice\">\n\t<x path=\"Int\"/>\n\t<c path=\"troshx.util.AIManueverChoice\"/>\n\t<x path=\"Void\"/>\n</f></addPossibleComboManueverChoice>\n\t<BUDGET_SKIP get=\"inline\" set=\"null\" expr=\"-1\" line=\"1649\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e>-1</e></m></meta>\n\t</BUDGET_SKIP>\n\t<MANUEVER_CHOICE_CONSIDER_MASTER expr=\"&apos;???&apos;\" line=\"1650\" static=\"1\">\n\t\t<c path=\"troshx.util.AIManueverChoice\"/>\n\t\t<meta><m n=\":value\"><e>'???'</e></m></meta>\n\t</MANUEVER_CHOICE_CONSIDER_MASTER>\n\t<setBestComboActionWithInitiativePlan set=\"method\" line=\"1661\" static=\"1\">\n\t\t<f a=\"cp:cp2:?threatManuever\" v=\"::null\">\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<c path=\"troshx.util.AIManueverChoice\"/>\n\t\t\t<x path=\"Bool\"/>\n\t\t</f>\n\t\t<meta>\n\t\t\t<m n=\":value\"><e>{threatManuever:null}</e></m>\n\t\t\t<m n=\"return\">\n\t\t\t\t<e>\"MANUEVER_COMBO_SET\"</e>\n\t\t\t\t<e>\"MANUEVER_CHOICE_SET\"</e>\n\t\t\t\t<e>\"B_COMBO_CANDIDATE_COUNT\"</e>\n\t\t\t\t<e>\"B_COMBO_CANDIDATES\"</e>\n\t\t\t</m>\n\t\t\t<m n=\"inspect\"><e>[{inspect:{min:0}},{inspect:{min:0}}]</e></m>\n\t\t</meta>\n\t</setBestComboActionWithInitiativePlan>\n\t<setBestComboActionWithoutInitiativePlan public=\"1\" set=\"method\" line=\"1748\" static=\"1\">\n\t\t<f a=\"cp:cp2:threatManuever\">\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<c path=\"troshx.util.AIManueverChoice\"/>\n\t\t\t<x path=\"Bool\"/>\n\t\t</f>\n\t\t<meta>\n\t\t\t<m n=\"return\">\n\t\t\t\t<e>\"MANUEVER_COMBO_SET\"</e>\n\t\t\t\t<e>\"MANUEVER_CHOICE_SET\"</e>\n\t\t\t\t<e>\"B_COMBO_CANDIDATE_COUNT\"</e>\n\t\t\t\t<e>\"B_COMBO_CANDIDATES\"</e>\n\t\t\t</m>\n\t\t\t<m n=\"inspect\"><e>[{inspect:{min:0}},{inspect:{min:0}}]</e></m>\n\t\t</meta>\n\t</setBestComboActionWithoutInitiativePlan>\n\t<opponents expr=\"[]\" line=\"19\">\n\t\t<c path=\"Array\"><c path=\"troshx.tros.ai.TROSAiBot\"/></c>\n\t\t<meta><m n=\":value\"><e>[]</e></m></meta>\n\t</opponents>\n\t<opponentLen expr=\"0\" line=\"20\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e>0</e></m></meta>\n\t</opponentLen>\n\t<cpBudget expr=\"[]\" line=\"21\">\n\t\t<c path=\"Array\"><x path=\"Int\"/></c>\n\t\t<meta><m n=\":value\"><e>[]</e></m></meta>\n\t</cpBudget>\n\t<plannedCombos expr=\"[0,0,0,0]\" line=\"23\">\n\t\t<c path=\"Array\"><x path=\"Int\"/></c>\n\t\t<meta><m n=\":value\"><e>[0,0,0,0]</e></m></meta>\n\t</plannedCombos>\n\t<currentExchange expr=\"0\" line=\"25\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e>0</e></m></meta>\n\t</currentExchange>\n\t<body public=\"1\">\n\t\t<c path=\"troshx.BodyChar\"/>\n\t\t<meta><m n=\"inject\"/></meta>\n\t</body>\n\t<cp public=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\"bind\"><e>\"_cp\"</e></m></meta>\n\t</cp>\n\t<perception public=\"1\" expr=\"4\" line=\"31\">\n\t\t<x path=\"Int\"/>\n\t\t<meta>\n\t\t\t<m n=\":value\"><e>4</e></m>\n\t\t\t<m n=\"bind\"><e>\"_perception\"</e></m>\n\t\t</meta>\n\t</perception>\n\t<equipMasterhand public=\"1\">\n\t\t<c path=\"String\"/>\n\t\t<meta><m n=\"bind\"><e>\"_equipMasterhand\"</e></m></meta>\n\t</equipMasterhand>\n\t<equipOffhand public=\"1\">\n\t\t<c path=\"String\"/>\n\t\t<meta><m n=\"bind\"><e>\"_equipOffhand\"</e></m></meta>\n\t</equipOffhand>\n\t<mobility public=\"1\" expr=\"6\" line=\"34\">\n\t\t<x path=\"Int\"/>\n\t\t<meta>\n\t\t\t<m n=\":value\"><e>6</e></m>\n\t\t\t<m n=\"bind\"><e>\"_mobility\"</e></m>\n\t\t</meta>\n\t</mobility>\n\t<id public=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\"bind\"><e>\"_id\"</e></m></meta>\n\t</id>\n\t<initiative public=\"1\">\n\t\t<x path=\"Bool\"/>\n\t\t<meta><m n=\"bind\"><e>\"_fight_initiative\"</e></m></meta>\n\t</initiative>\n\t<stance public=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\"bind\"><e>\"_fight_stance\"</e></m></meta>\n\t</stance>\n\t<manueverUsingHands public=\"1\" expr=\"0\" line=\"40\">\n\t\t<x path=\"Int\"/>\n\t\t<meta>\n\t\t\t<m n=\":value\"><e>0</e></m>\n\t\t\t<m n=\"bind\"><e>\"_manueverUsingHands\"</e></m>\n\t\t</meta>\n\t</manueverUsingHands>\n\t<handsUsedUp expr=\"0\" line=\"56\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e>0</e></m></meta>\n\t</handsUsedUp>\n\t<decidedStance public=\"1\"><x path=\"Int\"/></decidedStance>\n\t<decidedOrientation public=\"1\"><x path=\"Int\"/></decidedOrientation>\n\t<decidedManuevers public=\"1\" expr=\"[&apos;???&apos;,&apos;???&apos;,&apos;???&apos;,&apos;???&apos;]\" line=\"60\">\n\t\t<c path=\"Array\"><c path=\"troshx.util.AIManueverChoice\"/></c>\n\t\t<meta><m n=\":value\"><e>['???','???','???','???']</e></m></meta>\n\t</decidedManuevers>\n\t<getDecidedManueverForSlot public=\"1\" set=\"method\" line=\"64\"><f a=\"slot\">\n\t<x path=\"Int\"/>\n\t<c path=\"String\"/>\n</f></getDecidedManueverForSlot>\n\t<getDecidedManueverCP public=\"1\" set=\"method\" line=\"67\"><f a=\"slot\">\n\t<x path=\"Int\"/>\n\t<x path=\"Int\"/>\n</f></getDecidedManueverCP>\n\t<getDecidedManueverTargetZone public=\"1\" set=\"method\" line=\"70\"><f a=\"slot\">\n\t<x path=\"Int\"/>\n\t<x path=\"Int\"/>\n</f></getDecidedManueverTargetZone>\n\t<isThruster public=\"1\" set=\"method\" line=\"1282\"><f a=\"\"><x path=\"Bool\"/></f></isThruster>\n\t<getPredictedDTN set=\"method\" line=\"1297\"><f a=\"\"><x path=\"Int\"/></f></getPredictedDTN>\n\t<getPredictedATN set=\"method\" line=\"1317\"><f a=\"\"><x path=\"Int\"/></f></getPredictedATN>\n\t<getOffhandDTN get=\"inline\" set=\"null\" line=\"1345\"><f a=\"\"><x path=\"Int\"/></f></getOffhandDTN>\n\t<getShieldDTN get=\"inline\" set=\"null\" line=\"1350\"><f a=\"\"><x path=\"Int\"/></f></getShieldDTN>\n\t<getMasterDTN get=\"inline\" set=\"null\" line=\"1354\"><f a=\"\"><x path=\"Int\"/></f></getMasterDTN>\n\t<getHighestATNOrDTN set=\"method\" line=\"1360\"><f a=\"\"><x path=\"Int\"/></f></getHighestATNOrDTN>\n\t<getDTNBetterMargin get=\"inline\" set=\"null\" line=\"1366\"><f a=\"\"><x path=\"Int\"/></f></getDTNBetterMargin>\n\t<isDualWeilding get=\"inline\" set=\"null\" line=\"1632\"><f a=\"\"><x path=\"Bool\"/></f></isDualWeilding>\n\t<newExchange public=\"1\" set=\"method\" line=\"1802\">\n\t\t<f a=\"?newRound\" v=\"false\">\n\t\t\t<x path=\"Bool\"/>\n\t\t\t<x path=\"Void\"/>\n\t\t</f>\n\t\t<meta><m n=\":value\"><e>{newRound:false}</e></m></meta>\n\t</newExchange>\n\t<decideStance public=\"1\" set=\"method\" line=\"1820\"><f a=\"enemies:target:targetedBy\">\n\t<c path=\"Array\"><c path=\"troshx.tros.ai.TROSAiBot\"/></c>\n\t<c path=\"troshx.tros.ai.TROSAiBot\"/>\n\t<c path=\"Array\"><c path=\"troshx.tros.ai.TROSAiBot\"/></c>\n\t<x path=\"Void\"/>\n</f></decideStance>\n\t<decideOrientation public=\"1\" set=\"method\" line=\"1824\"><f a=\"enemies:target:targetedBy\">\n\t<c path=\"Array\"><c path=\"troshx.tros.ai.TROSAiBot\"/></c>\n\t<c path=\"troshx.tros.ai.TROSAiBot\"/>\n\t<c path=\"Array\"><c path=\"troshx.tros.ai.TROSAiBot\"/></c>\n\t<x path=\"Void\"/>\n</f></decideOrientation>\n\t<decideTarget public=\"1\" set=\"method\" line=\"1828\"><f a=\"enemies\">\n\t<c path=\"Array\"><c path=\"troshx.tros.ai.TROSAiBot\"/></c>\n\t<x path=\"Void\"/>\n</f></decideTarget>\n\t<preDeclareManuevers public=\"1\" set=\"method\" line=\"1833\"><f a=\"target:targetedBy\">\n\t<c path=\"troshx.tros.ai.TROSAiBot\"/>\n\t<c path=\"Array\"><c path=\"troshx.tros.ai.TROSAiBot\"/></c>\n\t<x path=\"Void\"/>\n</f></preDeclareManuevers>\n\t<declareManuevers public=\"1\" set=\"method\" line=\"1862\"><f a=\"\"><x path=\"Void\"/></f></declareManuevers>\n\t<declareManueverAgainstOpponent public=\"1\" set=\"method\" line=\"1874\"><f a=\"index\">\n\t<x path=\"Int\"/>\n\t<x path=\"Bool\"/>\n</f></declareManueverAgainstOpponent>\n\t<new public=\"1\" set=\"method\" line=\"1794\"><f a=\"\"><x path=\"Void\"/></f></new>\n\t<meta>\n\t\t<m n=\":directlyUsed\"/>\n\t\t<m n=\":expose\"/>\n\t\t<m n=\":rtti\"/>\n\t</meta>\n</class>";
troshx_tros_ai_TROSAiBot.ENEMY_STEAL_COST = 4;
troshx_tros_ai_TROSAiBot.MIN_EXPOSED_AV = 0;
troshx_tros_ai_TROSAiBot.AVAIL_bash = 0;
troshx_tros_ai_TROSAiBot.AVAIL_spike = 0;
troshx_tros_ai_TROSAiBot.AVAIL_cut = 0;
troshx_tros_ai_TROSAiBot.AVAIL_thrust = 0;
troshx_tros_ai_TROSAiBot.AVAIL_beat = 0;
troshx_tros_ai_TROSAiBot.AVAIL_bindstrike = 0;
troshx_tros_ai_TROSAiBot.AVAIL_hook = 0;
troshx_tros_ai_TROSAiBot.AVAIL_block = 0;
troshx_tros_ai_TROSAiBot.AVAIL_parry = 0;
troshx_tros_ai_TROSAiBot.AVAIL_duckweave = 0;
troshx_tros_ai_TROSAiBot.AVAIL_partialevasion = 0;
troshx_tros_ai_TROSAiBot.AVAIL_fullevasion = 0;
troshx_tros_ai_TROSAiBot.AVAIL_blockopenstrike = 0;
troshx_tros_ai_TROSAiBot.AVAIL_counter = 0;
troshx_tros_ai_TROSAiBot.AVAIL_rota = 0;
troshx_tros_ai_TROSAiBot.AVAIL_expulsion = 0;
troshx_tros_ai_TROSAiBot.AVAIL_disarm = 0;
troshx_tros_ai_TROSAiBot.AVAIL_StealInitiative = 0;
troshx_tros_ai_TROSAiBot.B_EQUIP = "";
troshx_tros_ai_TROSAiBot.B_IS_OFFHAND = false;
troshx_tros_ai_TROSAiBot.D_EQUIP = "";
troshx_tros_ai_TROSAiBot.B_COMBO_EXCHANGE_BUDGET = (function($this) {
	var $r;
	var this1;
	this1 = new Array(4);
	$r = this1;
	return $r;
}(this));
troshx_tros_ai_TROSAiBot.BUDGET_EXCHANGE_1 = 0;
troshx_tros_ai_TROSAiBot.BUDGET_EXCHANGE_1_ENEMY = 1;
troshx_tros_ai_TROSAiBot.BUDGET_EXCHANGE_2 = 2;
troshx_tros_ai_TROSAiBot.BUDGET_EXCHANGE_2_ENEMY = 3;
troshx_tros_ai_TROSAiBot.COMBO_PureMeanStrikes = 1;
troshx_tros_ai_TROSAiBot.COMBO_HeavyFirstStrikes = 2;
troshx_tros_ai_TROSAiBot.COMBO_AlphaDisarm = 3;
troshx_tros_ai_TROSAiBot.COMBO_AlphaHookStrike = 4;
troshx_tros_ai_TROSAiBot.COMBO_AlphaStrike = 5;
troshx_tros_ai_TROSAiBot.COMBO_FeintStrike = 6;
troshx_tros_ai_TROSAiBot.COMBO_DoubleAttack = 7;
troshx_tros_ai_TROSAiBot.COMBO_SimulatenousBlockStrike = 8;
troshx_tros_ai_TROSAiBot.COMBOS_LEN_INITIATIVE = 9;
troshx_tros_ai_TROSAiBot.COMBO_CoupDeGrace = 9;
troshx_tros_ai_TROSAiBot.COMBOS_LEN_INITIATIVE_FINAL = 10;
troshx_tros_ai_TROSAiBot.COMBO_DefensiveFirst = -1;
troshx_tros_ai_TROSAiBot.COMBO_DefensiveBorderline = -2;
troshx_tros_ai_TROSAiBot.COMBO_AlphaInitiativeStealer = -3;
troshx_tros_ai_TROSAiBot.COMBO_AlphaDisarmDef = -4;
troshx_tros_ai_TROSAiBot.COMBO_SimulatenousBlockStrikeStealer = -5;
troshx_tros_ai_TROSAiBot.COMBOS_LEN_NO_INITAITIVE = 5;
troshx_tros_ai_TROSAiBot.P_THRESHOLD_FAVORABLE = 0.75;
troshx_tros_ai_TROSAiBot.P_THRESHOLD_BORDERLINE = 0.5;
troshx_tros_ai_TROSAiBot.P_RECKLESS = 0.2;
troshx_tros_ai_TROSAiBot.B_CANDIDATES = [];
troshx_tros_ai_TROSAiBot.B_CANDIDATE_COUNT = 0;
troshx_tros_ai_TROSAiBot.B_BS_REQUIRED = 1;
troshx_tros_ai_TROSAiBot.B_BS_REQUIRED_DEFAULT = 1;
troshx_tros_ai_TROSAiBot.COUP_BS_MODIFIER = 1;
troshx_tros_ai_TROSAiBot.B_BS_REQUIRED_DMG_DEFAULT = 1;
troshx_tros_ai_TROSAiBot.PREFERED_HOOK_BS = 2;
troshx_tros_ai_TROSAiBot.PREFERED_DISARM_BS = 2;
troshx_tros_ai_TROSAiBot.PREFERED_DISARM_DEF_BS = 2;
troshx_tros_ai_TROSAiBot.B_MANUEVER_CHOICES = [];
troshx_tros_ai_TROSAiBot.B_MANUEVER_CHOICE_PROBABILITIES = [];
troshx_tros_ai_TROSAiBot.B_MANUEVER_CHOICE_COUNT = 0;
troshx_tros_ai_TROSAiBot.B_COMBO_CANDIDATES = [];
troshx_tros_ai_TROSAiBot.B_COMBO_CANDIDATE_MANUEVER = [];
troshx_tros_ai_TROSAiBot.B_COMBO_CANDIDATE_COUNT = 0;
troshx_tros_ai_TROSAiBot.BPROB_BASE = 1000;
troshx_tros_ai_TROSAiBot.DMG_AGGR_BASE = 10;
troshx_tros_ai_TROSAiBot.IMPOSSIBLE_TN = 888;
troshx_tros_ai_TROSAiBot.B_USE_ADVANTAGE = false;
troshx_tros_ai_TROSAiBot.ATTACK_AGGR = 0;
troshx_tros_ai_TROSAiBot.MANUEVER_CHOICE = new troshx_util_AIManueverChoice();
troshx_tros_ai_TROSAiBot.MANUEVER_CHOICE_1 = new troshx_util_AIManueverChoice();
troshx_tros_ai_TROSAiBot.MANUEVER_CHOICE_SET = new troshx_util_AIManueverChoice();
troshx_tros_ai_TROSAiBot.MANUEVER_COMBO_SET = 0;
troshx_tros_ai_TROSAiBot.FLAG_GET_CHEAPEST = 1;
troshx_tros_ai_TROSAiBot.FLAG_USE_ALL_CP = 2;
troshx_tros_ai_TROSAiBot.FLAG_BORDERLINE_DEF_SAFETY = 4;
troshx_tros_ai_TROSAiBot.BUDGET_SKIP = -1;
troshx_tros_ai_TROSAiBot.MANUEVER_CHOICE_CONSIDER_MASTER = new troshx_util_AIManueverChoice();
troshx_util_TROSAI.__rtti = "<class path=\"troshx.util.TROSAI\" params=\"\">\n\t<factorial public=\"1\" get=\"inline\" set=\"null\" line=\"26\" static=\"1\"><f a=\"val\">\n\t<x path=\"Int\"/>\n\t<x path=\"Float\"/>\n</f></factorial>\n\t<binomialCoef public=\"1\" get=\"inline\" set=\"null\" line=\"40\" static=\"1\"><f a=\"n:r\">\n\t<x path=\"Int\"/>\n\t<x path=\"Int\"/>\n\t<x path=\"Float\"/>\n</f></binomialCoef>\n\t<getTNSuccessProbForDie public=\"1\" get=\"inline\" set=\"null\" line=\"50\" static=\"1\"><f a=\"tn\">\n\t<x path=\"Int\"/>\n\t<x path=\"Float\"/>\n</f></getTNSuccessProbForDie>\n\t<getXSuccessesProb public=\"1\" get=\"inline\" set=\"null\" line=\"54\" static=\"1\"><f a=\"numDiceToRoll:tn:x\">\n\t<x path=\"Int\"/>\n\t<x path=\"Int\"/>\n\t<x path=\"Int\"/>\n\t<x path=\"Float\"/>\n</f></getXSuccessesProb>\n\t<getAtLeastXSuccessesProb public=\"1\" set=\"method\" line=\"59\" static=\"1\"><f a=\"numDiceToRoll:tn:x\">\n\t<x path=\"Int\"/>\n\t<x path=\"Int\"/>\n\t<x path=\"Int\"/>\n\t<x path=\"Float\"/>\n</f></getAtLeastXSuccessesProb>\n\t<probabilityAOrB public=\"1\" get=\"inline\" set=\"null\" line=\"69\" static=\"1\"><f a=\"a:b\">\n\t<x path=\"Float\"/>\n\t<x path=\"Float\"/>\n\t<x path=\"Float\"/>\n</f></probabilityAOrB>\n\t<probabilityOfArrayOr public=\"1\" get=\"inline\" set=\"null\" line=\"73\" static=\"1\"><f a=\"arr\">\n\t<c path=\"Array\"><x path=\"Float\"/></c>\n\t<x path=\"Float\"/>\n</f></probabilityOfArrayOr>\n\t<getBelowOrEqualXSuccessesProb public=\"1\" set=\"method\" line=\"83\" static=\"1\"><f a=\"numDiceToRoll:tn:x\">\n\t<x path=\"Int\"/>\n\t<x path=\"Int\"/>\n\t<x path=\"Int\"/>\n\t<x path=\"Float\"/>\n</f></getBelowOrEqualXSuccessesProb>\n\t<getChanceToSucceedContest public=\"1\" set=\"method\" line=\"105\" static=\"1\">\n\t\t<f a=\"numDice:tn:againstNumDice:againstTN:?rs:?requireAtLeast1TS\" v=\"::::1:true\">\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Bool\"/>\n\t\t\t<x path=\"Float\"/>\n\t\t</f>\n\t\t<meta><m n=\":value\"><e>{requireAtLeast1TS:true,rs:1}</e></m></meta>\n\t</getChanceToSucceedContest>\n\t<getChanceToSucceed public=\"1\" set=\"method\" line=\"142\" static=\"1\">\n\t\t<f a=\"numDice:tn:?rs\" v=\"::1\">\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Float\"/>\n\t\t</f>\n\t\t<meta><m n=\":value\"><e>{rs:1}</e></m></meta>\n\t</getChanceToSucceed>\n\t<getAllXSuccessesProb public=\"1\" set=\"method\" line=\"149\" static=\"1\"><f a=\"numDice:tn\">\n\t<x path=\"Int\"/>\n\t<x path=\"Int\"/>\n\t<c path=\"Array\"><x path=\"Float\"/></c>\n</f></getAllXSuccessesProb>\n\t<getTabulatedRollData public=\"1\" set=\"method\" line=\"157\" static=\"1\"><f a=\"numDice:tn\">\n\t<x path=\"Int\"/>\n\t<x path=\"Int\"/>\n\t<c path=\"Array\"><d/></c>\n</f></getTabulatedRollData>\n\t<maxPrecision public=\"1\" get=\"inline\" set=\"null\" line=\"180\" static=\"1\"><f a=\"x:precision\">\n\t<x path=\"Float\"/>\n\t<x path=\"Int\"/>\n\t<x path=\"Float\"/>\n</f></maxPrecision>\n\t<roundTo public=\"1\" set=\"method\" line=\"184\" static=\"1\"><f a=\"x:y\">\n\t<x path=\"Float\"/>\n\t<x path=\"Float\"/>\n\t<x path=\"Float\"/>\n</f></roundTo>\n\t<INT32_MIN public=\"1\" get=\"inline\" set=\"null\" expr=\"0x80000000\" line=\"208\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e>0x80000000</e></m></meta>\n\t</INT32_MIN>\n\t<INT32_MAX public=\"1\" get=\"inline\" set=\"null\" expr=\"0x7fffffff\" line=\"214\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e>0x7fffffff</e></m></meta>\n\t</INT32_MAX>\n\t<displayAsPercentage public=\"1\" get=\"inline\" set=\"null\" line=\"217\" static=\"1\"><f a=\"probability\">\n\t<x path=\"Float\"/>\n\t<x path=\"Float\"/>\n</f></displayAsPercentage>\n\t<new public=\"1\" set=\"method\" line=\"16\"><f a=\"\"><x path=\"Void\"/></f></new>\n\t<meta>\n\t\t<m n=\":directlyUsed\"/>\n\t\t<m n=\":expose\"/>\n\t\t<m n=\":rtti\"/>\n\t</meta>\n</class>";
troshx_util_TROSAI.INT32_MIN = -2147483648;
troshx_util_TROSAI.INT32_MAX = 2147483647;
Main.main();
})(typeof console != "undefined" ? console : {log:function(){}}, typeof window != "undefined" ? window : exports, typeof window != "undefined" ? window : typeof global != "undefined" ? global : typeof self != "undefined" ? self : this);
