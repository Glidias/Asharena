(function (console, $hx_exports, $global) { "use strict";
$hx_exports.tjson = $hx_exports.tjson || {};
$hx_exports.textifician = $hx_exports.textifician || {};
$hx_exports.textifician.mapping = $hx_exports.textifician.mapping || {};
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
HxOverrides.strDate = function(s) {
	var _g = s.length;
	switch(_g) {
	case 8:
		var k = s.split(":");
		var d = new Date();
		d.setTime(0);
		d.setUTCHours(k[0]);
		d.setUTCMinutes(k[1]);
		d.setUTCSeconds(k[2]);
		return d;
	case 10:
		var k1 = s.split("-");
		return new Date(k1[0],k1[1] - 1,k1[2],0,0,0);
	case 19:
		var k2 = s.split(" ");
		var y = k2[0].split("-");
		var t = k2[1].split(":");
		return new Date(y[0],y[1] - 1,y[2],t[0],t[1],t[2]);
	default:
		throw new js__$Boot_HaxeError("Invalid date format : " + s);
	}
};
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
Reflect.callMethod = function(o,func,args) {
	return func.apply(o,args);
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
Reflect.isFunction = function(f) {
	return typeof(f) == "function" && !(f.__name__ || f.__ename__);
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
Std.parseFloat = function(x) {
	return parseFloat(x);
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
var TextificianGoJS = function() {
};
$hxClasses["TextificianGoJS"] = TextificianGoJS;
TextificianGoJS.__name__ = ["TextificianGoJS"];
TextificianGoJS.main = function() {
	de_polygonal_ds_Graph;
	textifician_mapping_LocationPacket;
	textifician_mapping_LocationDefinition;
	textifician_mapping_TextificianWorld;
	textifician_mapping_TextificianUtil;
	var serializer = new haxe_Serializer();
	serializer.useCache = true;
	var nestedArr = [0,0,0];
	var sameArr = [1,2,3,nestedArr];
	var itest = new InstanceTest();
	itest.a = sameArr;
	itest.b = sameArr;
	console.log(itest.a == itest.b);
	console.log(itest.a != null && itest.a[3] == itest.b[3]);
	serializer.serialize(itest);
	var unserializer = new haxe_Unserializer(serializer.toString());
	itest = unserializer.unserialize();
	console.log(itest.a == itest.b);
	console.log(itest.a[3] == itest.b[3]);
	var fields;
	var somethingGood = dat_gui_DatUtil.setup(new textifician_mapping_LocationDefinition(),null);
	console.log(somethingGood);
};
TextificianGoJS.prototype = {
	__class__: TextificianGoJS
};
var InstanceTest = function() {
};
$hxClasses["InstanceTest"] = InstanceTest;
InstanceTest.__name__ = ["InstanceTest"];
InstanceTest.prototype = {
	a: null
	,b: null
	,__class__: InstanceTest
};
var ValueType = $hxClasses["ValueType"] = { __ename__ : ["ValueType"], __constructs__ : ["TNull","TInt","TFloat","TBool","TObject","TFunction","TClass","TEnum","TUnknown"] };
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
Type.getEnumName = function(e) {
	var a = e.__ename__;
	return a.join(".");
};
Type.resolveClass = function(name) {
	var cl = $hxClasses[name];
	if(cl == null || !cl.__name__) return null;
	return cl;
};
Type.resolveEnum = function(name) {
	var e = $hxClasses[name];
	if(e == null || !e.__ename__) return null;
	return e;
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
Type.createEnum = function(e,constr,params) {
	var f = Reflect.field(e,constr);
	if(f == null) throw new js__$Boot_HaxeError("No such constructor " + constr);
	if(Reflect.isFunction(f)) {
		if(params == null) throw new js__$Boot_HaxeError("Constructor " + constr + " need parameters");
		return Reflect.callMethod(e,f,params);
	}
	if(params != null && params.length != 0) throw new js__$Boot_HaxeError("Constructor " + constr + " does not need parameters");
	return f;
};
Type.getInstanceFields = function(c) {
	var a = [];
	for(var i in c.prototype) a.push(i);
	HxOverrides.remove(a,"__class__");
	HxOverrides.remove(a,"__properties__");
	return a;
};
Type.getEnumConstructs = function(e) {
	var a = e.__constructs__;
	return a.slice();
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
	var rtti = haxe_rtti_Rtti.getRtti(classe);
	var meta;
	if(funcToInspect != null) meta = funcToInspect.meta; else meta = haxe_rtti_Meta.getFields(classe);
	if(funcToInspect != null) instance = funcToInspect.instance;
	var fieldHash = { };
	var fields;
	if(funcToInspect != null) fields = funcToInspect.fields; else fields = rtti.fields;
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
						Reflect.setField(funcDep.instance,funcArg.name,funcArg.opt?dat_gui_DatUtil.parseStringParam(funcArg.value,haxe_rtti_CTypeTools.toString(funcArg.t),classe):null);
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
dat_gui_DatUtil.parseStringParam = function(str,type,classe) {
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
		return type;
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
	return packet;
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
var de_polygonal_Printf = function() { };
$hxClasses["de.polygonal.Printf"] = de_polygonal_Printf;
de_polygonal_Printf.__name__ = ["de","polygonal","Printf"];
de_polygonal_Printf.init = function() {
	de_polygonal_Printf.dataTypeMap = de_polygonal_Printf.makeDataTypeMap();
	de_polygonal_Printf.formatIntFuncHash = new haxe_ds_IntMap();
	de_polygonal_Printf.formatIntFuncHash.h[1] = de_polygonal_Printf.formatSignedDecimal;
	de_polygonal_Printf.formatIntFuncHash.h[2] = de_polygonal_Printf.formatUnsignedDecimal;
	de_polygonal_Printf.formatIntFuncHash.h[0] = de_polygonal_Printf.formatCharacter;
	de_polygonal_Printf.formatIntFuncHash.h[4] = de_polygonal_Printf.formatHexadecimal;
	de_polygonal_Printf.formatIntFuncHash.h[3] = de_polygonal_Printf.formatOctal;
	de_polygonal_Printf.formatIntFuncHash.h[5] = de_polygonal_Printf.formatBinary;
	de_polygonal_Printf.formatFloatFuncHash = new haxe_ds_IntMap();
	de_polygonal_Printf.formatFloatFuncHash.h[0] = de_polygonal_Printf.formatNormalFloat;
	de_polygonal_Printf.formatFloatFuncHash.h[1] = de_polygonal_Printf.formatScientific;
	de_polygonal_Printf.formatFloatFuncHash.h[2] = de_polygonal_Printf.formatNaturalFloat;
	de_polygonal_Printf.formatStringFuncHash = new haxe_ds_IntMap();
	de_polygonal_Printf.formatStringFuncHash.h[2] = de_polygonal_Printf.formatString;
};
de_polygonal_Printf.makeDataTypeMap = function() {
	var hash = new haxe_ds_IntMap();
	hash.set(105,de_polygonal__$Printf_FormatDataType.FmtInteger(de_polygonal__$Printf_IntegerType.ISignedDecimal));
	hash.set(100,de_polygonal__$Printf_FormatDataType.FmtInteger(de_polygonal__$Printf_IntegerType.ISignedDecimal));
	hash.set(117,de_polygonal__$Printf_FormatDataType.FmtInteger(de_polygonal__$Printf_IntegerType.IUnsignedDecimal));
	hash.set(99,de_polygonal__$Printf_FormatDataType.FmtInteger(de_polygonal__$Printf_IntegerType.ICharacter));
	hash.set(120,de_polygonal__$Printf_FormatDataType.FmtInteger(de_polygonal__$Printf_IntegerType.IHex));
	hash.set(88,de_polygonal__$Printf_FormatDataType.FmtInteger(de_polygonal__$Printf_IntegerType.IHex));
	hash.set(111,de_polygonal__$Printf_FormatDataType.FmtInteger(de_polygonal__$Printf_IntegerType.IOctal));
	hash.set(98,de_polygonal__$Printf_FormatDataType.FmtInteger(de_polygonal__$Printf_IntegerType.IBin));
	hash.set(102,de_polygonal__$Printf_FormatDataType.FmtFloat(de_polygonal__$Printf_FloatType.FNormal));
	hash.set(101,de_polygonal__$Printf_FormatDataType.FmtFloat(de_polygonal__$Printf_FloatType.FScientific));
	hash.set(69,de_polygonal__$Printf_FormatDataType.FmtFloat(de_polygonal__$Printf_FloatType.FScientific));
	hash.set(103,de_polygonal__$Printf_FormatDataType.FmtFloat(de_polygonal__$Printf_FloatType.FNatural));
	hash.set(71,de_polygonal__$Printf_FormatDataType.FmtFloat(de_polygonal__$Printf_FloatType.FNatural));
	hash.h[115] = de_polygonal__$Printf_FormatDataType.FmtString;
	hash.h[112] = de_polygonal__$Printf_FormatDataType.FmtPointer;
	hash.h[110] = de_polygonal__$Printf_FormatDataType.FmtNothing;
	return hash;
};
de_polygonal_Printf.format = function(fmt,args) {
	if(!de_polygonal_Printf._initialized) {
		de_polygonal_Printf._initialized = true;
		de_polygonal_Printf.init();
	}
	var _g1 = 0;
	var _g = args.length;
	while(_g1 < _g) {
		var i = _g1++;
		if(args[i] == null) args[i] = "null";
	}
	var output = "";
	var argIndex = 0;
	var tokens = de_polygonal_Printf.tokenize(fmt);
	var _g2 = 0;
	while(_g2 < tokens.length) {
		var token = tokens[_g2];
		++_g2;
		switch(token[1]) {
		case 3:
			throw new js__$Boot_HaxeError("invalid format specifier");
			break;
		case 0:
			var str = token[2];
			output += str;
			break;
		case 2:
			var name = token[2];
			if(!Object.prototype.hasOwnProperty.call(args[0],name)) throw new js__$Boot_HaxeError("no field named " + name);
			output += Std.string(Reflect.field(args[0],name));
			break;
		case 1:
			var tagArgs = token[3];
			var type = token[2];
			if(tagArgs.width != null) tagArgs.width = tagArgs.width; else tagArgs.width = js_Boot.__cast(args[argIndex++] , Int);
			if(tagArgs.precision != null) tagArgs.precision = tagArgs.precision; else tagArgs.precision = js_Boot.__cast(args[argIndex++] , Int);
			var value = args[argIndex++];
			var formatFunction;
			switch(type[1]) {
			case 1:
				var floatType = type[2];
				formatFunction = de_polygonal_Printf.formatFloatFuncHash.h[floatType[1]];
				break;
			case 0:
				var integerType = type[2];
				formatFunction = de_polygonal_Printf.formatIntFuncHash.h[integerType[1]];
				break;
			case 2:
				formatFunction = de_polygonal_Printf.formatStringFuncHash.h[2];
				break;
			case 3:
				throw new js__$Boot_HaxeError("specifier 'p' is not supported");
				break;
			case 4:
				throw new js__$Boot_HaxeError("specifier 'n' is not supported");
				break;
			}
			output += formatFunction(value,tagArgs);
			break;
		}
	}
	return output;
};
de_polygonal_Printf.tokenize = function(fmt) {
	var length = fmt.length;
	var lastStr = new StringBuf();
	var i = 0;
	var c = 0;
	var tokens = [];
	while(i < length) {
		var c1 = de_polygonal_Printf.codeAt(fmt,i++);
		if(c1 == 37) {
			c1 = de_polygonal_Printf.codeAt(fmt,i++);
			if(c1 == 37) lastStr.b += String.fromCharCode(c1); else {
				if(lastStr.b.length > 0) {
					tokens.push(de_polygonal__$Printf_FormatToken.BareString(lastStr.b));
					lastStr = new StringBuf();
				}
				var token;
				if(c1 == 40) {
					var endPos = fmt.indexOf(")",i);
					if(endPos == -1) token = de_polygonal__$Printf_FormatToken.Unknown("named param",i); else {
						var paramName = HxOverrides.substr(fmt,i,endPos - i);
						i = endPos + 1;
						token = de_polygonal__$Printf_FormatToken.Property(paramName);
					}
				} else {
					var params = { flags : 0, pos : -1, width : -1, precision : -1};
					while(c1 == 45 || c1 == 43 || c1 == 35 || c1 == 48 || c1 == 32) {
						if(c1 == 45) params.flags |= 1 << de_polygonal__$Printf_FormatFlags.Minus[1]; else if(c1 == 43) params.flags |= 1 << de_polygonal__$Printf_FormatFlags.Plus[1]; else if(c1 == 35) params.flags |= 1 << de_polygonal__$Printf_FormatFlags.Sharp[1]; else if(c1 == 48) params.flags |= 1 << de_polygonal__$Printf_FormatFlags.Zero[1]; else if(c1 == 32) params.flags |= 1 << de_polygonal__$Printf_FormatFlags.Space[1];
						c1 = de_polygonal_Printf.codeAt(fmt,i++);
					}
					if((params.flags & 1 << de_polygonal__$Printf_FormatFlags.Minus[1]) != 0 && (params.flags & 1 << de_polygonal__$Printf_FormatFlags.Zero[1]) != 0) params.flags &= 268435455 - (1 << de_polygonal__$Printf_FormatFlags.Zero[1]);
					if((params.flags & 1 << de_polygonal__$Printf_FormatFlags.Space[1]) != 0 && (params.flags & 1 << de_polygonal__$Printf_FormatFlags.Plus[1]) != 0) params.flags &= 268435455 - (1 << de_polygonal__$Printf_FormatFlags.Space[1]);
					if(c1 == 42) {
						params.width = null;
						c1 = de_polygonal_Printf.codeAt(fmt,i++);
					} else if(c1 >= 48 && c1 <= 57) {
						params.width = 0;
						while(c1 >= 48 && c1 <= 57) {
							params.width = c1 - 48 + params.width * 10;
							c1 = de_polygonal_Printf.codeAt(fmt,i++);
						}
						if(c1 == 36) {
							params.pos = params.width - 1;
							params.width = -1;
							c1 = de_polygonal_Printf.codeAt(fmt,i++);
							if(c1 == 42) {
								params.width = null;
								c1 = de_polygonal_Printf.codeAt(fmt,i++);
							} else if(c1 >= 48 && c1 <= 57) {
								params.width = 0;
								while(c1 >= 48 && c1 <= 57) {
									params.width = c1 - 48 + params.width * 10;
									c1 = de_polygonal_Printf.codeAt(fmt,i++);
								}
							}
						}
					}
					if(c1 == 46) {
						c1 = de_polygonal_Printf.codeAt(fmt,i++);
						if(c1 == 42) {
							params.precision = null;
							c1 = de_polygonal_Printf.codeAt(fmt,i++);
						} else if(c1 >= 48 && c1 <= 57) {
							params.precision = 0;
							while(c1 >= 48 && c1 <= 57) {
								params.precision = c1 - 48 + params.precision * 10;
								c1 = de_polygonal_Printf.codeAt(fmt,i++);
							}
						} else params.precision = 0;
					}
					while(c1 == 104 || c1 == 108 || c1 == 76) {
						switch(c1) {
						case 104:
							params.flags |= 1 << de_polygonal__$Printf_FormatFlags.LengthH[1];
							break;
						case 108:
							params.flags |= 1 << de_polygonal__$Printf_FormatFlags.Lengthl[1];
							break;
						case 76:
							params.flags |= 1 << de_polygonal__$Printf_FormatFlags.LengthL[1];
							break;
						}
						c1 = de_polygonal_Printf.codeAt(fmt,i++);
					}
					if(c1 == 69 || c1 == 71 || c1 == 88) params.flags |= 1 << de_polygonal__$Printf_FormatFlags.UpperCase[1];
					var type = de_polygonal_Printf.dataTypeMap.h[c1];
					if(type == null) token = de_polygonal__$Printf_FormatToken.Unknown(String.fromCharCode(c1),i); else token = de_polygonal__$Printf_FormatToken.Tag(type,params);
				}
				tokens.push(token);
			}
		} else lastStr.b += String.fromCharCode(c1);
	}
	if(lastStr.b.length > 0) tokens.push(de_polygonal__$Printf_FormatToken.BareString(lastStr.b));
	return tokens;
};
de_polygonal_Printf.formatBinary = function(value,args) {
	var output = "";
	var flags = args.flags;
	var precision = args.precision;
	var width = args.width;
	if(precision == -1) precision = 1;
	if(value != 0) {
		if((flags & 1 << de_polygonal__$Printf_FormatFlags.LengthH[1]) != 0) value &= 65535;
		var i = value;
		do {
			output = ((i & 1) > 0?"1":"0") + output;
			i >>>= 1;
		} while(i > 0);
		if(precision > 1) {
			if(precision > output.length) output = de_polygonal_Printf.lpad(output,"0",precision);
			if((flags & 1 << de_polygonal__$Printf_FormatFlags.Sharp[1]) != 0) output = "b" + output;
		}
	}
	if((flags & 1 << de_polygonal__$Printf_FormatFlags.Minus[1]) != 0) {
		if(width > output.length) return de_polygonal_Printf.rpad(output," ",width); else return output;
	} else if(width > output.length) return de_polygonal_Printf.lpad(output,(flags & 1 << de_polygonal__$Printf_FormatFlags.Zero[1]) != 0?"0":" ",width); else return output;
};
de_polygonal_Printf.formatOctal = function(value,args) {
	var output = "";
	var flags = args.flags;
	var precision = args.precision;
	var width = args.width;
	if(precision == -1) precision = 1;
	if(value != 0) {
		if((flags & 1 << de_polygonal__$Printf_FormatFlags.LengthH[1]) != 0) value &= 65535;
		output = de_polygonal_Printf.toOct(value);
		if((flags & 1 << de_polygonal__$Printf_FormatFlags.Sharp[1]) != 0) output = "0" + output;
		if(precision > 1 && output.length < precision) output = de_polygonal_Printf.lpad(output,"0",precision);
	}
	if((flags & 1 << de_polygonal__$Printf_FormatFlags.Minus[1]) != 0) {
		if(width > output.length) return de_polygonal_Printf.rpad(output," ",width); else return output;
	} else if(width > output.length) return de_polygonal_Printf.lpad(output,(flags & 1 << de_polygonal__$Printf_FormatFlags.Zero[1]) != 0?"0":" ",width); else return output;
};
de_polygonal_Printf.formatHexadecimal = function(value,args) {
	var output = "";
	var flags = args.flags;
	var precision = args.precision;
	var width = args.width;
	if(precision == -1) precision = 1;
	if(value != 0) {
		if((flags & 1 << de_polygonal__$Printf_FormatFlags.LengthH[1]) != 0) value &= 65535;
		output = de_polygonal_Printf.toHex(value);
		if(precision > 1 && output.length < precision) output = de_polygonal_Printf.lpad(output,"0",precision);
		if((flags & 1 << de_polygonal__$Printf_FormatFlags.Sharp[1]) != 0 && value != 0) output = "0x" + output;
		if((flags & 1 << de_polygonal__$Printf_FormatFlags.UpperCase[1]) != 0) output = output.toUpperCase(); else output = output.toLowerCase();
	}
	if((flags & 1 << de_polygonal__$Printf_FormatFlags.Minus[1]) != 0) {
		if(width > output.length) return de_polygonal_Printf.rpad(output," ",width); else return output;
	} else if(width > output.length) return de_polygonal_Printf.lpad(output,(flags & 1 << de_polygonal__$Printf_FormatFlags.Zero[1]) != 0?"0":" ",width); else return output;
};
de_polygonal_Printf.formatUnsignedDecimal = function(value,args) {
	var output;
	var precision = args.precision;
	if(value >= 0) output = de_polygonal_Printf.formatSignedDecimal(value,args); else {
		var x;
		var x1 = new haxe__$Int64__$_$_$Int64(0,value);
		x = x1;
		output = haxe__$Int64_Int64_$Impl_$.toString(x);
		if(precision > 1 && output.length < precision) output = de_polygonal_Printf.lpad(output,"0",precision);
		output = de_polygonal_Printf.padNumber(output,value,args.flags,args.width);
	}
	return output;
};
de_polygonal_Printf.formatNaturalFloat = function(value,args) {
	args.precision = 0;
	var formatedFloat = de_polygonal_Printf.formatNormalFloat(value,args);
	var formatedScientific = de_polygonal_Printf.formatScientific(value,args);
	if((args.flags & 1 << de_polygonal__$Printf_FormatFlags.Sharp[1]) != 0) {
		if(formatedFloat.indexOf(".") != -1) {
			var pos = formatedFloat.length - 1;
			while(formatedFloat.charCodeAt(pos) == 48) pos--;
			formatedFloat = HxOverrides.substr(formatedFloat,0,pos);
		}
	}
	if(formatedFloat.length <= formatedScientific.length) return formatedFloat; else return formatedScientific;
};
de_polygonal_Printf.formatScientific = function(value,args) {
	var output = "";
	var flags = args.flags;
	var precision = args.precision;
	if(precision == -1) precision = 6;
	var sign;
	var exponent;
	if(value == 0) {
		sign = 0;
		exponent = 0;
		output += "0";
		if(precision > 0) {
			output += ".";
			var _g = 0;
			while(_g < precision) {
				var i = _g++;
				output += "0";
			}
		}
	} else {
		if(value > 0.) sign = 1; else if(value < 0.) sign = -1; else sign = 0;
		value = Math.abs(value);
		exponent = Math.floor(Math.log(value) / 2.302585092994046);
		value = value / Math.pow(10,exponent);
		var p = Math.pow(0.1,precision);
		value = Math.round(value / p) * p;
	}
	if(sign < 0) output += "-"; else if((flags & 1 << de_polygonal__$Printf_FormatFlags.Plus[1]) != 0) output += "+"; else output += "";
	if(value != 0) output += de_polygonal_Printf.rpad((function($this) {
		var $r;
		var _this = de_polygonal_Printf.str(value);
		$r = HxOverrides.substr(_this,0,precision + 2);
		return $r;
	}(this)),"0",precision + 2);
	if((flags & 1 << de_polygonal__$Printf_FormatFlags.UpperCase[1]) != 0) output += "E"; else output += "e";
	if(exponent >= 0) output += "+"; else output += "-";
	if(exponent < 10) output += "00"; else if(exponent < 100) output += "0";
	output += de_polygonal_Printf.str(de_polygonal_Printf.iabs(exponent));
	return output;
};
de_polygonal_Printf.formatSignedDecimal = function(value,args) {
	var output;
	var flags = args.flags;
	var precision = args.precision;
	var width = args.width;
	if(precision == 0 && value == 0) output = ""; else {
		if((flags & 1 << de_polygonal__$Printf_FormatFlags.LengthH[1]) != 0) value &= 65535;
		output = de_polygonal_Printf.str(de_polygonal_Printf.iabs(value));
		if(precision > 1 && output.length < precision) output = de_polygonal_Printf.lpad(output,"0",precision);
		if((flags & 1 << de_polygonal__$Printf_FormatFlags.Zero[1]) != 0) output = de_polygonal_Printf.lpad(output,"0",value < 0?width - 1:width);
		if(value < 0) output = "-" + output;
	}
	if(value >= 0) {
		if((flags & 1 << de_polygonal__$Printf_FormatFlags.Plus[1]) != 0) output = "+" + output; else if((flags & 1 << de_polygonal__$Printf_FormatFlags.Space[1]) != 0) output = " " + output;
	}
	if((flags & 1 << de_polygonal__$Printf_FormatFlags.Minus[1]) != 0) output = de_polygonal_Printf.rpad(output," ",args.width); else output = de_polygonal_Printf.lpad(output," ",args.width);
	return output;
};
de_polygonal_Printf.formatString = function(x,args) {
	var output = x;
	var precision = args.precision;
	var width = args.width;
	if(precision > 0) output = HxOverrides.substr(x,0,precision);
	var k = output.length;
	if(width > 0 && k < width) {
		if((args.flags & 1 << de_polygonal__$Printf_FormatFlags.Minus[1]) != 0) output = de_polygonal_Printf.rpad(output," ",width); else output = de_polygonal_Printf.lpad(output," ",width);
	}
	return output;
};
de_polygonal_Printf.formatNormalFloat = function(value,args) {
	var output;
	var flags = args.flags;
	var precision = args.precision;
	var width = args.width;
	if(precision == -1) precision = 6;
	if(precision == 0) {
		output = de_polygonal_Printf.str(de_polygonal_Printf.iabs(Math.round(value)));
		if((flags & 1 << de_polygonal__$Printf_FormatFlags.Sharp[1]) != 0) output += ".";
	} else {
		value = de_polygonal_Printf.roundTo(value,Math.pow(.1,precision));
		var decimalPlaces = precision;
		if(isNaN(value)) output = "NaN"; else {
			var t = Std["int"](Math.pow(10,decimalPlaces));
			output = de_polygonal_Printf.str((value * t | 0) / t);
			var i = output.indexOf(".");
			if(i != -1) {
				var _g = HxOverrides.substr(output,i + 1,null).length;
				while(_g < decimalPlaces) {
					var i1 = _g++;
					output += "0";
				}
			} else {
				output += ".";
				var _g1 = 0;
				while(_g1 < decimalPlaces) {
					var i2 = _g1++;
					output += "0";
				}
			}
		}
	}
	if((flags & 1 << de_polygonal__$Printf_FormatFlags.Plus[1]) != 0 && value >= 0) output = "+" + output; else if((flags & 1 << de_polygonal__$Printf_FormatFlags.Space[1]) != 0 && value >= 0) output = " " + output;
	if((flags & 1 << de_polygonal__$Printf_FormatFlags.Zero[1]) != 0) output = de_polygonal_Printf.lpad(output,"0",value < 0?width - 1:width);
	if((flags & 1 << de_polygonal__$Printf_FormatFlags.Minus[1]) != 0) output = de_polygonal_Printf.rpad(output," ",width); else output = de_polygonal_Printf.lpad(output," ",width);
	return output;
};
de_polygonal_Printf.formatCharacter = function(x,args) {
	var output = String.fromCharCode(x);
	if(args.width > 1) {
		if((args.flags & 1 << de_polygonal__$Printf_FormatFlags.Minus[1]) != 0) output = de_polygonal_Printf.rpad(output," ",args.width); else output = de_polygonal_Printf.lpad(output," ",args.width);
	}
	return output;
};
de_polygonal_Printf.padNumber = function(x,n,flags,width) {
	var k = x.length;
	if(width > 0 && k < width) {
		if((flags & 1 << de_polygonal__$Printf_FormatFlags.Minus[1]) != 0) x = de_polygonal_Printf.rpad(x," ",width); else if(n >= 0) x = de_polygonal_Printf.lpad(x,(flags & 1 << de_polygonal__$Printf_FormatFlags.Zero[1]) != 0?"0":" ",width); else if((flags & 1 << de_polygonal__$Printf_FormatFlags.Zero[1]) != 0) x = "-" + de_polygonal_Printf.lpad(HxOverrides.substr(x,1,null),"0",width); else x = de_polygonal_Printf.lpad(x," ",width);
	}
	return x;
};
de_polygonal_Printf.lpad = function(s,c,l) {
	if(c.length <= 0) throw new js__$Boot_HaxeError("c.length <= 0");
	while(s.length < l) s = c + s;
	return s;
};
de_polygonal_Printf.rpad = function(s,c,l) {
	if(c.length <= 0) throw new js__$Boot_HaxeError("c.length <= 0");
	while(s.length < l) s = s + c;
	return s;
};
de_polygonal_Printf.toHex = function(x) {
	var s = "";
	var hexChars = "0123456789ABCDEF";
	do {
		s = hexChars.charAt(x & 15) + s;
		x >>>= 4;
	} while(x > 0);
	return s;
};
de_polygonal_Printf.toOct = function(x) {
	var s = "";
	var t = x;
	do {
		s = (t & 7) + s;
		t >>>= 3;
	} while(t > 0);
	return s;
};
de_polygonal_Printf.iabs = function(x) {
	return Std["int"](Math.abs(x));
};
de_polygonal_Printf.str = function(x) {
	return Std.string(x);
};
de_polygonal_Printf.codeAt = function(x,i) {
	return x.charCodeAt(i);
};
de_polygonal_Printf.isDigit = function(x) {
	return x >= 48 && x <= 57;
};
de_polygonal_Printf.roundTo = function(x,y) {
	return Math.round(x / y) * y;
};
var de_polygonal__$Printf_FormatFlags = $hxClasses["de.polygonal._Printf.FormatFlags"] = { __ename__ : ["de","polygonal","_Printf","FormatFlags"], __constructs__ : ["Minus","Plus","Space","Sharp","Zero","LengthH","LengthL","Lengthl","UpperCase"] };
de_polygonal__$Printf_FormatFlags.Minus = ["Minus",0];
de_polygonal__$Printf_FormatFlags.Minus.toString = $estr;
de_polygonal__$Printf_FormatFlags.Minus.__enum__ = de_polygonal__$Printf_FormatFlags;
de_polygonal__$Printf_FormatFlags.Plus = ["Plus",1];
de_polygonal__$Printf_FormatFlags.Plus.toString = $estr;
de_polygonal__$Printf_FormatFlags.Plus.__enum__ = de_polygonal__$Printf_FormatFlags;
de_polygonal__$Printf_FormatFlags.Space = ["Space",2];
de_polygonal__$Printf_FormatFlags.Space.toString = $estr;
de_polygonal__$Printf_FormatFlags.Space.__enum__ = de_polygonal__$Printf_FormatFlags;
de_polygonal__$Printf_FormatFlags.Sharp = ["Sharp",3];
de_polygonal__$Printf_FormatFlags.Sharp.toString = $estr;
de_polygonal__$Printf_FormatFlags.Sharp.__enum__ = de_polygonal__$Printf_FormatFlags;
de_polygonal__$Printf_FormatFlags.Zero = ["Zero",4];
de_polygonal__$Printf_FormatFlags.Zero.toString = $estr;
de_polygonal__$Printf_FormatFlags.Zero.__enum__ = de_polygonal__$Printf_FormatFlags;
de_polygonal__$Printf_FormatFlags.LengthH = ["LengthH",5];
de_polygonal__$Printf_FormatFlags.LengthH.toString = $estr;
de_polygonal__$Printf_FormatFlags.LengthH.__enum__ = de_polygonal__$Printf_FormatFlags;
de_polygonal__$Printf_FormatFlags.LengthL = ["LengthL",6];
de_polygonal__$Printf_FormatFlags.LengthL.toString = $estr;
de_polygonal__$Printf_FormatFlags.LengthL.__enum__ = de_polygonal__$Printf_FormatFlags;
de_polygonal__$Printf_FormatFlags.Lengthl = ["Lengthl",7];
de_polygonal__$Printf_FormatFlags.Lengthl.toString = $estr;
de_polygonal__$Printf_FormatFlags.Lengthl.__enum__ = de_polygonal__$Printf_FormatFlags;
de_polygonal__$Printf_FormatFlags.UpperCase = ["UpperCase",8];
de_polygonal__$Printf_FormatFlags.UpperCase.toString = $estr;
de_polygonal__$Printf_FormatFlags.UpperCase.__enum__ = de_polygonal__$Printf_FormatFlags;
var de_polygonal__$Printf_FormatToken = $hxClasses["de.polygonal._Printf.FormatToken"] = { __ename__ : ["de","polygonal","_Printf","FormatToken"], __constructs__ : ["BareString","Tag","Property","Unknown"] };
de_polygonal__$Printf_FormatToken.BareString = function(str) { var $x = ["BareString",0,str]; $x.__enum__ = de_polygonal__$Printf_FormatToken; $x.toString = $estr; return $x; };
de_polygonal__$Printf_FormatToken.Tag = function(type,args) { var $x = ["Tag",1,type,args]; $x.__enum__ = de_polygonal__$Printf_FormatToken; $x.toString = $estr; return $x; };
de_polygonal__$Printf_FormatToken.Property = function(name) { var $x = ["Property",2,name]; $x.__enum__ = de_polygonal__$Printf_FormatToken; $x.toString = $estr; return $x; };
de_polygonal__$Printf_FormatToken.Unknown = function(str,pos) { var $x = ["Unknown",3,str,pos]; $x.__enum__ = de_polygonal__$Printf_FormatToken; $x.toString = $estr; return $x; };
var de_polygonal__$Printf_FormatDataType = $hxClasses["de.polygonal._Printf.FormatDataType"] = { __ename__ : ["de","polygonal","_Printf","FormatDataType"], __constructs__ : ["FmtInteger","FmtFloat","FmtString","FmtPointer","FmtNothing"] };
de_polygonal__$Printf_FormatDataType.FmtInteger = function(integerType) { var $x = ["FmtInteger",0,integerType]; $x.__enum__ = de_polygonal__$Printf_FormatDataType; $x.toString = $estr; return $x; };
de_polygonal__$Printf_FormatDataType.FmtFloat = function(floatType) { var $x = ["FmtFloat",1,floatType]; $x.__enum__ = de_polygonal__$Printf_FormatDataType; $x.toString = $estr; return $x; };
de_polygonal__$Printf_FormatDataType.FmtString = ["FmtString",2];
de_polygonal__$Printf_FormatDataType.FmtString.toString = $estr;
de_polygonal__$Printf_FormatDataType.FmtString.__enum__ = de_polygonal__$Printf_FormatDataType;
de_polygonal__$Printf_FormatDataType.FmtPointer = ["FmtPointer",3];
de_polygonal__$Printf_FormatDataType.FmtPointer.toString = $estr;
de_polygonal__$Printf_FormatDataType.FmtPointer.__enum__ = de_polygonal__$Printf_FormatDataType;
de_polygonal__$Printf_FormatDataType.FmtNothing = ["FmtNothing",4];
de_polygonal__$Printf_FormatDataType.FmtNothing.toString = $estr;
de_polygonal__$Printf_FormatDataType.FmtNothing.__enum__ = de_polygonal__$Printf_FormatDataType;
var de_polygonal__$Printf_IntegerType = $hxClasses["de.polygonal._Printf.IntegerType"] = { __ename__ : ["de","polygonal","_Printf","IntegerType"], __constructs__ : ["ICharacter","ISignedDecimal","IUnsignedDecimal","IOctal","IHex","IBin"] };
de_polygonal__$Printf_IntegerType.ICharacter = ["ICharacter",0];
de_polygonal__$Printf_IntegerType.ICharacter.toString = $estr;
de_polygonal__$Printf_IntegerType.ICharacter.__enum__ = de_polygonal__$Printf_IntegerType;
de_polygonal__$Printf_IntegerType.ISignedDecimal = ["ISignedDecimal",1];
de_polygonal__$Printf_IntegerType.ISignedDecimal.toString = $estr;
de_polygonal__$Printf_IntegerType.ISignedDecimal.__enum__ = de_polygonal__$Printf_IntegerType;
de_polygonal__$Printf_IntegerType.IUnsignedDecimal = ["IUnsignedDecimal",2];
de_polygonal__$Printf_IntegerType.IUnsignedDecimal.toString = $estr;
de_polygonal__$Printf_IntegerType.IUnsignedDecimal.__enum__ = de_polygonal__$Printf_IntegerType;
de_polygonal__$Printf_IntegerType.IOctal = ["IOctal",3];
de_polygonal__$Printf_IntegerType.IOctal.toString = $estr;
de_polygonal__$Printf_IntegerType.IOctal.__enum__ = de_polygonal__$Printf_IntegerType;
de_polygonal__$Printf_IntegerType.IHex = ["IHex",4];
de_polygonal__$Printf_IntegerType.IHex.toString = $estr;
de_polygonal__$Printf_IntegerType.IHex.__enum__ = de_polygonal__$Printf_IntegerType;
de_polygonal__$Printf_IntegerType.IBin = ["IBin",5];
de_polygonal__$Printf_IntegerType.IBin.toString = $estr;
de_polygonal__$Printf_IntegerType.IBin.__enum__ = de_polygonal__$Printf_IntegerType;
var de_polygonal__$Printf_FloatType = $hxClasses["de.polygonal._Printf.FloatType"] = { __ename__ : ["de","polygonal","_Printf","FloatType"], __constructs__ : ["FNormal","FScientific","FNatural"] };
de_polygonal__$Printf_FloatType.FNormal = ["FNormal",0];
de_polygonal__$Printf_FloatType.FNormal.toString = $estr;
de_polygonal__$Printf_FloatType.FNormal.__enum__ = de_polygonal__$Printf_FloatType;
de_polygonal__$Printf_FloatType.FScientific = ["FScientific",1];
de_polygonal__$Printf_FloatType.FScientific.toString = $estr;
de_polygonal__$Printf_FloatType.FScientific.__enum__ = de_polygonal__$Printf_FloatType;
de_polygonal__$Printf_FloatType.FNatural = ["FNatural",2];
de_polygonal__$Printf_FloatType.FNatural.toString = $estr;
de_polygonal__$Printf_FloatType.FNatural.__enum__ = de_polygonal__$Printf_FloatType;
var de_polygonal_core_fmt_NumberFormat = function() { };
$hxClasses["de.polygonal.core.fmt.NumberFormat"] = de_polygonal_core_fmt_NumberFormat;
de_polygonal_core_fmt_NumberFormat.__name__ = ["de","polygonal","core","fmt","NumberFormat"];
de_polygonal_core_fmt_NumberFormat.toBin = function(x,byteDelimiter,leadingZeros) {
	if(leadingZeros == null) leadingZeros = false;
	if(byteDelimiter == null) byteDelimiter = "";
	var n = 32 - de_polygonal_ds_Bits.nlz(x);
	var s;
	if((x & 1) > 0) s = "1"; else s = "0";
	x >>= 1;
	var _g = 1;
	while(_g < n) {
		var i = _g++;
		s = ((x & 1) > 0?"1":"0") + ((i & 7) == 0?byteDelimiter:"") + s;
		x >>= 1;
	}
	if(leadingZeros) {
		var _g1 = 0;
		var _g2 = 32 - n;
		while(_g1 < _g2) {
			var i1 = _g1++;
			s = "0" + s;
		}
	}
	return s;
};
de_polygonal_core_fmt_NumberFormat.toHex = function(x) {
	if(x == 0) return "0";
	var s = "";
	var a = de_polygonal_core_fmt_NumberFormat._hexLUT;
	while(x != 0) {
		s = a[x & 15] + s;
		x >>>= 4;
	}
	return s;
};
de_polygonal_core_fmt_NumberFormat.toOct = function(x) {
	var s = "";
	var t = x;
	do {
		var r = t & 7;
		s = r + s;
		t >>>= 3;
	} while(t > 0);
	return s;
};
de_polygonal_core_fmt_NumberFormat.toRadix = function(x,radix) {
	var s = "";
	var t = x;
	while(t > 0) {
		var r = t % radix;
		s = r + s;
		t = t / radix;
	}
	return s;
};
de_polygonal_core_fmt_NumberFormat.toFixed = function(x,decimalPlaces) {
	if(isNaN(x)) return "NaN"; else {
		var t = de_polygonal_core_math_Mathematics.exp(10,decimalPlaces);
		var s = Std.string((x * t | 0) / t);
		var i = s.indexOf(".");
		if(i != -1) {
			var _g = HxOverrides.substr(s,i + 1,null).length;
			while(_g < decimalPlaces) {
				var i1 = _g++;
				s += "0";
			}
		} else {
			s += ".";
			var _g1 = 0;
			while(_g1 < decimalPlaces) {
				var i2 = _g1++;
				s += "0";
			}
		}
		return s;
	}
};
de_polygonal_core_fmt_NumberFormat.toMMSS = function(x) {
	x = x * 1000 | 0;
	var ms = x % 1000;
	var r = (x - ms) / 1000;
	var tmp = r % 60;
	return HxOverrides.substr("0" + (r - tmp) / 60,-2,null) + ":" + HxOverrides.substr("0" + tmp,-2,null);
};
de_polygonal_core_fmt_NumberFormat.groupDigits = function(x,thousandsSeparator) {
	if(thousandsSeparator == null) thousandsSeparator = ".";
	var n = x;
	var c = 0;
	while(n > 1) {
		n /= 10;
		c++;
	}
	c = c / 3;
	var source;
	if(x == null) source = "null"; else source = "" + x;
	if(c == 0) return source; else {
		var target = "";
		var i = 0;
		var j = source.length - 1;
		while(j >= 0) {
			if(i == 3) {
				target = source.charAt(j--) + thousandsSeparator + target;
				i = 0;
				c--;
			} else target = source.charAt(j--) + target;
			i++;
		}
		return target;
	}
};
de_polygonal_core_fmt_NumberFormat.centToEuro = function(x,decimalSeparator,thousandsSeparator) {
	if(thousandsSeparator == null) thousandsSeparator = ".";
	if(decimalSeparator == null) decimalSeparator = ",";
	var euro = x / 100 | 0;
	if(euro == 0) {
		if(x < 10) return "0" + decimalSeparator + "0" + x; else return "0" + decimalSeparator + x;
	} else {
		var str;
		var cent = x - euro * 100;
		if(cent < 10) str = decimalSeparator + "0" + cent; else str = decimalSeparator + cent;
		if(euro >= 1000) {
			var num = euro;
			var add;
			while(num >= 1000) {
				num = euro / 1000 | 0;
				add = euro - num * 1000;
				if(add < 10) str = thousandsSeparator + "00" + add + str; else if(add < 100) str = thousandsSeparator + "0" + add + str; else str = thousandsSeparator + add + str;
				euro = num;
			}
			return str = num + str;
		} else str = euro + str;
		return str;
	}
};
var de_polygonal_core_math_Limits = function() { };
$hxClasses["de.polygonal.core.math.Limits"] = de_polygonal_core_math_Limits;
de_polygonal_core_math_Limits.__name__ = ["de","polygonal","core","math","Limits"];
var de_polygonal_core_math_Mathematics = function() { };
$hxClasses["de.polygonal.core.math.Mathematics"] = de_polygonal_core_math_Mathematics;
de_polygonal_core_math_Mathematics.__name__ = ["de","polygonal","core","math","Mathematics"];
de_polygonal_core_math_Mathematics.toRad = function(deg) {
	return deg * 0.017453292519943295;
};
de_polygonal_core_math_Mathematics.toDeg = function(rad) {
	return rad * 57.29577951308232;
};
de_polygonal_core_math_Mathematics.min = function(x,y) {
	if(x < y) return x; else return y;
};
de_polygonal_core_math_Mathematics.max = function(x,y) {
	if(x > y) return x; else return y;
};
de_polygonal_core_math_Mathematics.abs = function(x) {
	if(x < 0) return -x; else return x;
};
de_polygonal_core_math_Mathematics.sgn = function(x) {
	if(x > 0) return 1; else if(x < 0) return -1; else return 0;
};
de_polygonal_core_math_Mathematics.clamp = function(x,min,max) {
	if(x < min) return min; else if(x > max) return max; else return x;
};
de_polygonal_core_math_Mathematics.clampSym = function(x,i) {
	if(x < -i) return -i; else if(x > i) return i; else return x;
};
de_polygonal_core_math_Mathematics.wrap = function(x,min,max) {
	if(x < min) return x - min + max + 1; else if(x > max) return x - max + min - 1; else return x;
};
de_polygonal_core_math_Mathematics.fmin = function(x,y) {
	if(x < y) return x; else return y;
};
de_polygonal_core_math_Mathematics.fmax = function(x,y) {
	if(x > y) return x; else return y;
};
de_polygonal_core_math_Mathematics.fabs = function(x) {
	if(x < 0) return -x; else return x;
};
de_polygonal_core_math_Mathematics.fsgn = function(x) {
	if(x > 0.) return 1; else if(x < 0.) return -1; else return 0;
};
de_polygonal_core_math_Mathematics.fclamp = function(x,min,max) {
	if(x < min) return min; else if(x > max) return max; else return x;
};
de_polygonal_core_math_Mathematics.fclampSym = function(x,i) {
	if(x < -i) return -i; else if(x > i) return i; else return x;
};
de_polygonal_core_math_Mathematics.fwrap = function(value,lower,upper) {
	return value - ((value - lower) / (upper - lower) | 0) * (upper - lower);
};
de_polygonal_core_math_Mathematics.eqSgn = function(x,y) {
	return (x ^ y) >= 0;
};
de_polygonal_core_math_Mathematics.isEven = function(x) {
	return (x & 1) == 0;
};
de_polygonal_core_math_Mathematics.isPow2 = function(x) {
	return x > 0 && (x & x - 1) == 0;
};
de_polygonal_core_math_Mathematics.lerp = function(a,b,t) {
	return a + (b - a) * t;
};
de_polygonal_core_math_Mathematics.slerp = function(a,b,t) {
	var m = Math;
	var c1 = m.sin(a * .5);
	var r1 = m.cos(a * .5);
	var c2 = m.sin(b * .5);
	var r2 = m.cos(b * .5);
	var c = r1 * r2 + c1 * c2;
	if(c < 0.) {
		if(1. + c > 1e-6) {
			var o = m.acos(-c);
			var s = m.sin(o);
			var s0 = m.sin((1 - t) * o) / s;
			var s1 = m.sin(t * o) / s;
			return m.atan2(s0 * c1 - s1 * c2,s0 * r1 - s1 * r2) * 2.;
		} else {
			var s01 = 1 - t;
			var s11 = t;
			return m.atan2(s01 * c1 - s11 * c2,s01 * r1 - s11 * r2) * 2;
		}
	} else if(1 - c > 1e-6) {
		var o1 = m.acos(c);
		var s2 = m.sin(o1);
		var s02 = m.sin((1 - t) * o1) / s2;
		var s12 = m.sin(t * o1) / s2;
		return m.atan2(s02 * c1 + s12 * c2,s02 * r1 + s12 * r2) * 2.;
	} else {
		var s03 = 1 - t;
		var s13 = t;
		return m.atan2(s03 * c1 + s13 * c2,s03 * r1 + s13 * r2) * 2.;
	}
};
de_polygonal_core_math_Mathematics.nextPow2 = function(x) {
	var t = x - 1;
	t |= t >> 1;
	t |= t >> 2;
	t |= t >> 4;
	t |= t >> 8;
	t |= t >> 16;
	return t + 1;
};
de_polygonal_core_math_Mathematics.exp = function(a,n) {
	var t = 1;
	var r = 0;
	while(true) {
		if((n & 1) != 0) t = a * t;
		n >>= 1;
		if(n == 0) {
			r = t;
			break;
		} else a *= a;
	}
	return r;
};
de_polygonal_core_math_Mathematics.log10 = function(x) {
	return Math.log(x) * 0.4342944819032517;
};
de_polygonal_core_math_Mathematics.roundTo = function(x,y) {
	return Math.round(x / y) * y;
};
de_polygonal_core_math_Mathematics.round = function(x) {
	return (x + 16384.5 | 0) - 16384;
};
de_polygonal_core_math_Mathematics.ceil = function(x) {
	var f = x | 0;
	if(x == f) return f; else {
		x += 1;
		var f1 = x | 0;
		if(x < 0 && f1 != x) f1--;
		return f1;
	}
};
de_polygonal_core_math_Mathematics.floor = function(x) {
	var f = x | 0;
	if(x < 0 && f != x) f--;
	return f;
};
de_polygonal_core_math_Mathematics.sqrt = function(x) {
	return Math.sqrt(x);
};
de_polygonal_core_math_Mathematics.invSqrt = function(x) {
	return 1 / Math.sqrt(x);
};
de_polygonal_core_math_Mathematics.cmpAbs = function(x,y,eps) {
	var d = x - y;
	if(d > 0) return d < eps; else return -d < eps;
};
de_polygonal_core_math_Mathematics.cmpZero = function(x,eps) {
	if(x > 0) return x < eps; else return -x < eps;
};
de_polygonal_core_math_Mathematics.snap = function(x,y) {
	return de_polygonal_core_math_Mathematics.floor((x + y * .5) / y);
};
de_polygonal_core_math_Mathematics.inRange = function(x,min,max) {
	return x >= min && x <= max;
};
de_polygonal_core_math_Mathematics.wrapToPI = function(x) {
	x += 3.141592653589793;
	return x - 6.283185307179586 * Math.floor(x / 6.283185307179586) - 3.141592653589793;
};
de_polygonal_core_math_Mathematics.wrapToPI2 = function(x) {
	return x - 6.283185307179586 * Math.floor(x / 6.283185307179586);
};
de_polygonal_core_math_Mathematics.gcd = function(x,y) {
	var d = 0;
	var r = 0;
	if(x < 0) x = -x; else x = x;
	if(y < 0) y = -y; else y = y;
	while(true) if(y == 0) {
		d = x;
		break;
	} else {
		r = x % y;
		x = y;
		y = r;
	}
	return d;
};
de_polygonal_core_math_Mathematics.maxPrecision = function(x,precision) {
	return de_polygonal_core_math_Mathematics.roundTo(x,Math.pow(10,-precision));
};
de_polygonal_core_math_Mathematics.ofBool = function(x) {
	if(x) return 1; else return 0;
};
var de_polygonal_ds_Bits = function() { };
$hxClasses["de.polygonal.ds.Bits"] = de_polygonal_ds_Bits;
de_polygonal_ds_Bits.__name__ = ["de","polygonal","ds","Bits"];
de_polygonal_ds_Bits.getBits = function(x,mask) {
	return x & mask;
};
de_polygonal_ds_Bits.hasBits = function(x,mask) {
	return (x & mask) != 0;
};
de_polygonal_ds_Bits.incBits = function(x,mask) {
	return (x & mask) == mask;
};
de_polygonal_ds_Bits.setBits = function(x,mask) {
	return x | mask;
};
de_polygonal_ds_Bits.clrBits = function(x,mask) {
	return x & ~mask;
};
de_polygonal_ds_Bits.invBits = function(x,mask) {
	return x ^ mask;
};
de_polygonal_ds_Bits.setBitsIf = function(x,mask,expr) {
	if(expr) return x | mask; else return x & ~mask;
};
de_polygonal_ds_Bits.hasBitAt = function(x,i) {
	return (x & 1 << i) != 0;
};
de_polygonal_ds_Bits.setBitAt = function(x,i) {
	return x | 1 << i;
};
de_polygonal_ds_Bits.clrBitAt = function(x,i) {
	return x & ~(1 << i);
};
de_polygonal_ds_Bits.invBitAt = function(x,i) {
	return x ^ 1 << i;
};
de_polygonal_ds_Bits.setBitsRange = function(x,min,max) {
	var _g = min;
	while(_g < max) {
		var i = _g++;
		x = x | 1 << i;
	}
	return x;
};
de_polygonal_ds_Bits.mask = function(n) {
	return (1 << n) - 1;
};
de_polygonal_ds_Bits.ones = function(x) {
	x -= x >> 1 & 1431655765;
	x = (x >> 2 & 858993459) + (x & 858993459);
	x = (x >> 4) + x & 252645135;
	x += x >> 8;
	x += x >> 16;
	return x & 63;
};
de_polygonal_ds_Bits.ntz = function(x) {
	var n = 0;
	if(x != 0) {
		x = (x ^ x - 1) >>> 1;
		while(x != 0) {
			x >>= 1;
			n++;
		}
	}
	return n;
};
de_polygonal_ds_Bits.nlz = function(x) {
	if(x < 0) return 0; else {
		x |= x >> 1;
		x |= x >> 2;
		x |= x >> 4;
		x |= x >> 8;
		x |= x >> 16;
		return 32 - de_polygonal_ds_Bits.ones(x);
	}
};
de_polygonal_ds_Bits.msb = function(x) {
	x |= x >> 1;
	x |= x >> 2;
	x |= x >> 4;
	x |= x >> 8;
	x |= x >> 16;
	return x & ~(x >>> 1);
};
de_polygonal_ds_Bits.rol = function(x,n) {
	return x << n | x >>> 32 - n;
};
de_polygonal_ds_Bits.ror = function(x,n) {
	return x >>> n | x << 32 - n;
};
de_polygonal_ds_Bits.reverse = function(x) {
	var y = 1431655765;
	x = x >> 1 & y | (x & y) << 1;
	y = 858993459;
	x = x >> 2 & y | (x & y) << 2;
	y = 252645135;
	x = x >> 4 & y | (x & y) << 4;
	y = 16711935;
	x = x >> 8 & y | (x & y) << 8;
	return x >> 16 | x << 16;
};
de_polygonal_ds_Bits.flipWORD = function(x) {
	return x << 8 | x >> 8;
};
de_polygonal_ds_Bits.flipDWORD = function(x) {
	return x << 24 | x << 8 & 16711680 | x >> 8 & 65280 | x >> 24;
};
de_polygonal_ds_Bits.packI16 = function(lo,hi) {
	return hi + 32768 << 16 | lo + 32768;
};
de_polygonal_ds_Bits.packUI16 = function(lo,hi) {
	return hi << 16 | lo;
};
de_polygonal_ds_Bits.unpackI16Lo = function(x) {
	return (x & 65535) - 32768;
};
de_polygonal_ds_Bits.unpackI16Hi = function(x) {
	return (x >>> 16) - 32768;
};
de_polygonal_ds_Bits.unpackUI16Lo = function(x) {
	return x & 65535;
};
de_polygonal_ds_Bits.unpackUI16Hi = function(x) {
	return x >>> 16;
};
var de_polygonal_ds_Cloneable = function() { };
$hxClasses["de.polygonal.ds.Cloneable"] = de_polygonal_ds_Cloneable;
de_polygonal_ds_Cloneable.__name__ = ["de","polygonal","ds","Cloneable"];
de_polygonal_ds_Cloneable.prototype = {
	clone: null
	,__class__: de_polygonal_ds_Cloneable
};
var de_polygonal_ds_Hashable = function() { };
$hxClasses["de.polygonal.ds.Hashable"] = de_polygonal_ds_Hashable;
de_polygonal_ds_Hashable.__name__ = ["de","polygonal","ds","Hashable"];
de_polygonal_ds_Hashable.prototype = {
	key: null
	,__class__: de_polygonal_ds_Hashable
};
var de_polygonal_ds_Collection = function() { };
$hxClasses["de.polygonal.ds.Collection"] = de_polygonal_ds_Collection;
de_polygonal_ds_Collection.__name__ = ["de","polygonal","ds","Collection"];
de_polygonal_ds_Collection.__interfaces__ = [de_polygonal_ds_Hashable];
de_polygonal_ds_Collection.prototype = {
	get_size: null
	,free: null
	,contains: null
	,remove: null
	,clear: null
	,iterator: null
	,isEmpty: null
	,toArray: null
	,clone: null
	,__class__: de_polygonal_ds_Collection
	,__properties__: {get_size:"get_size"}
};
var de_polygonal_ds_Graph = function() {
	this.mQueSize = 16;
	this.mStackSize = 16;
	this.mIterator = null;
	this.mSize = 0;
	this.mNodeList = null;
	this.reuseIterator = false;
	this.autoClearMarks = false;
	this.key = de_polygonal_ds_HashKey._counter++;
	this.mStack = new Array(this.mStackSize);
	this.mQue = new Array(this.mQueSize);
};
$hxClasses["de.polygonal.ds.Graph"] = de_polygonal_ds_Graph;
de_polygonal_ds_Graph.__name__ = ["de","polygonal","ds","Graph"];
de_polygonal_ds_Graph.__interfaces__ = [de_polygonal_ds_Collection];
de_polygonal_ds_Graph.prototype = {
	key: null
	,autoClearMarks: null
	,reuseIterator: null
	,borrowArc: null
	,returnArc: null
	,mNodeList: null
	,mSize: null
	,mIterator: null
	,mStack: null
	,mStackSize: null
	,mQue: null
	,mQueSize: null
	,getNodeList: function() {
		return this.mNodeList;
	}
	,findNode: function(x) {
		var found = false;
		var n = this.mNodeList;
		while(n != null) {
			if(n.val == x) {
				found = true;
				break;
			}
			n = n.next;
		}
		if(found) return n; else return null;
	}
	,createNode: function(x) {
		return new de_polygonal_ds_GraphNode(this,x);
	}
	,addNode: function(x) {
		this.mSize++;
		x.next = this.mNodeList;
		if(x.next != null) x.next.prev = x;
		this.mNodeList = x;
		return x;
	}
	,removeNode: function(x) {
		this.unlink(x);
		if(x.prev != null) x.prev.next = x.next;
		if(x.next != null) x.next.prev = x.prev;
		if(this.mNodeList == x) this.mNodeList = x.next;
		this.mSize--;
	}
	,addSingleArc: function(source,target,cost) {
		if(cost == null) cost = 1.;
		var walker = this.mNodeList;
		while(walker != null) {
			if(walker == source) {
				var sourceNode = walker;
				walker = this.mNodeList;
				while(walker != null) {
					if(walker == target) {
						sourceNode.addArc(walker,cost);
						break;
					}
					walker = walker.next;
				}
				break;
			}
			walker = walker.next;
		}
	}
	,addGetSingleArc: function(source,target,cost) {
		if(cost == null) cost = 1.;
		this.addSingleArc(source,target,cost);
		return source.getArc(target);
	}
	,addMutualArcs: function(source,target,cost) {
		if(cost == null) cost = 1.;
		this.addMutualArc(source,target,cost);
		return [source.getArc(target),target.getArc(source)];
	}
	,addMutualArc: function(source,target,cost) {
		if(cost == null) cost = 1.;
		var walker = this.mNodeList;
		while(walker != null) {
			if(walker == source) {
				var sourceNode = walker;
				walker = this.mNodeList;
				while(walker != null) {
					if(walker == target) {
						sourceNode.addArc(walker,cost);
						walker.addArc(sourceNode,cost);
						break;
					}
					walker = walker.next;
				}
				break;
			}
			walker = walker.next;
		}
	}
	,unlink: function(node) {
		var arc0 = node.arcList;
		while(arc0 != null) {
			var node1 = arc0.node;
			var arc1 = node1.arcList;
			while(arc1 != null) {
				var hook1 = arc1.next;
				if(arc1.node == node) {
					if(arc1.prev != null) arc1.prev.next = hook1;
					if(hook1 != null) hook1.prev = arc1.prev;
					if(node1.arcList == arc1) node1.arcList = hook1;
					arc1.free();
					if(this.returnArc != null) this.returnArc(arc1);
				}
				arc1 = hook1;
			}
			var hook = arc0.next;
			if(arc0.prev != null) arc0.prev.next = hook;
			if(hook != null) hook.prev = arc0.prev;
			if(node.arcList == arc0) node.arcList = hook;
			arc0.free();
			if(this.returnArc != null) this.returnArc(arc0);
			arc0 = hook;
		}
		node.arcList = null;
		return node;
	}
	,clearMarks: function() {
		var node = this.mNodeList;
		while(node != null) {
			node.marked = false;
			node = node.next;
		}
	}
	,clearParent: function() {
		var node = this.mNodeList;
		while(node != null) {
			node.parent = null;
			node = node.next;
		}
	}
	,DFS: function(preflight,seed,process,userData,recursive) {
		if(recursive == null) recursive = false;
		if(preflight == null) preflight = false;
		var _g = this;
		if(this.mSize == 0) return;
		if(this.autoClearMarks) this.clearMarks();
		var c = 1;
		if(seed == null) seed = this.mNodeList;
		var max = this.mStackSize;
		var s = this.mStack;
		s[0] = seed;
		seed.parent = seed;
		seed.depth = 0;
		if(preflight) {
			if(process == null) {
				if(recursive) {
					var v = seed.val;
					if(v.visit(true,userData)) this.dFSRecursiveVisit(seed,true,userData);
				} else {
					var v1 = null;
					var n = s[0];
					v1 = n.val;
					if(!v1.visit(true,userData)) return;
					while(c > 0) {
						var n1 = de_polygonal_ds_tools_NativeArrayTools.get(s,--c);
						if(n1.marked) continue;
						n1.marked = true;
						v1 = n1.val;
						if(!v1.visit(false,userData)) break;
						var a = n1.arcList;
						while(a != null) {
							v1 = n1.val;
							a.node.parent = n1;
							a.node.depth = n1.depth + 1;
							if(v1.visit(true,userData)) {
								if(c == max) _g.resizeStack(max = max * 2);
								de_polygonal_ds_tools_NativeArrayTools.set(s,c++,a.node);
							}
							a = a.next;
						}
					}
				}
			} else if(recursive) {
				if(process(seed,true,userData)) this.dFSRecursiveProcess(seed,process,true,userData);
			} else {
				var n2 = s[0];
				if(!process(n2,true,userData)) return;
				while(c > 0) {
					var n3 = de_polygonal_ds_tools_NativeArrayTools.get(s,--c);
					if(n3.marked) continue;
					n3.marked = true;
					if(!process(n3,false,userData)) break;
					var a1 = n3.arcList;
					while(a1 != null) {
						a1.node.parent = n3;
						a1.node.depth = n3.depth + 1;
						if(process(a1.node,true,userData)) {
							if(c == max) _g.resizeStack(max = max * 2);
							de_polygonal_ds_tools_NativeArrayTools.set(s,c++,a1.node);
						}
						a1 = a1.next;
					}
				}
			}
		} else if(process == null) {
			if(recursive) this.dFSRecursiveVisit(seed,false,userData); else {
				var v2 = null;
				while(c > 0) {
					var n4 = de_polygonal_ds_tools_NativeArrayTools.get(s,--c);
					if(n4.marked) continue;
					n4.marked = true;
					v2 = n4.val;
					if(!v2.visit(false,userData)) break;
					var a2 = n4.arcList;
					while(a2 != null) {
						if(c == max) _g.resizeStack(max = max * 2);
						de_polygonal_ds_tools_NativeArrayTools.set(s,c++,a2.node);
						a2.node.parent = n4;
						a2.node.depth = n4.depth + 1;
						a2 = a2.next;
					}
				}
			}
		} else if(recursive) this.dFSRecursiveProcess(seed,process,false,userData); else while(c > 0) {
			var n5 = de_polygonal_ds_tools_NativeArrayTools.get(s,--c);
			if(n5.marked) continue;
			n5.marked = true;
			if(!process(n5,false,userData)) break;
			var a3 = n5.arcList;
			while(a3 != null) {
				if(c == max) _g.resizeStack(max = max * 2);
				de_polygonal_ds_tools_NativeArrayTools.set(s,c++,a3.node);
				a3.node.parent = n5;
				a3.node.depth = n5.depth + 1;
				a3 = a3.next;
			}
		}
	}
	,BFS: function(preflight,seed,process,userData) {
		if(preflight == null) preflight = false;
		var _g = this;
		if(this.mSize == 0) return;
		if(this.autoClearMarks) this.clearMarks();
		var front = 0;
		var c = 1;
		var q = this.mQue;
		var max = this.mQueSize;
		if(seed == null) seed = this.mNodeList;
		q[0] = seed;
		seed.marked = true;
		seed.parent = seed;
		seed.depth = 0;
		if(preflight) {
			if(process == null) {
				var v = null;
				var n = q[front];
				v = n.val;
				if(!v.visit(true,userData)) return;
				while(c > 0) {
					n = q[front];
					v = n.val;
					if(!v.visit(false,userData)) return;
					var a = n.arcList;
					while(a != null) {
						var m = a.node;
						if(m.marked) {
							a = a.next;
							continue;
						}
						m.marked = true;
						m.parent = n;
						m.depth = n.depth + 1;
						v = m.val;
						if(v.visit(true,userData)) {
							var i = c++ + front;
							if(i == max) {
								_g.resizeQue(max = max * 2);
								q = _g.mQue;
							}
							q[i] = m;
						}
						a = a.next;
					}
					front++;
					c--;
				}
			} else {
				var n1 = q[front];
				if(!process(n1,true,userData)) return;
				while(c > 0) {
					n1 = q[front];
					if(!process(n1,false,userData)) return;
					var a1 = n1.arcList;
					while(a1 != null) {
						var m1 = a1.node;
						if(m1.marked) {
							a1 = a1.next;
							continue;
						}
						m1.marked = true;
						m1.parent = n1;
						m1.depth = n1.depth + 1;
						if(process(m1,true,userData)) {
							var i1 = c++ + front;
							if(i1 == max) {
								_g.resizeQue(max = max * 2);
								q = _g.mQue;
							}
							q[i1] = m1;
						}
						a1 = a1.next;
					}
					front++;
					c--;
				}
			}
		} else if(process == null) {
			var v1 = null;
			while(c > 0) {
				var n2 = q[front];
				v1 = n2.val;
				if(!v1.visit(false,userData)) return;
				var a2 = n2.arcList;
				while(a2 != null) {
					var m2 = a2.node;
					if(m2.marked) {
						a2 = a2.next;
						continue;
					}
					m2.marked = true;
					m2.parent = n2;
					m2.depth = n2.depth + 1;
					var i2 = c++ + front;
					if(i2 == max) {
						_g.resizeQue(max = max * 2);
						q = _g.mQue;
					}
					q[i2] = m2;
					a2 = a2.next;
				}
				front++;
				c--;
			}
		} else while(c > 0) {
			var n3 = q[front];
			if(!process(n3,false,userData)) return;
			var a3 = n3.arcList;
			while(a3 != null) {
				var m3 = a3.node;
				if(m3.marked) {
					a3 = a3.next;
					continue;
				}
				m3.marked = true;
				m3.parent = n3;
				m3.depth = n3.depth + 1;
				var i3 = c++ + front;
				if(i3 == max) {
					_g.resizeQue(max = max * 2);
					q = _g.mQue;
				}
				q[i3] = m3;
				a3 = a3.next;
			}
			front++;
			c--;
		}
	}
	,DLBFS: function(maxDepth,preflight,seed,process,userData) {
		if(preflight == null) preflight = false;
		var _g = this;
		if(this.mSize == 0) return;
		if(this.autoClearMarks) this.clearMarks();
		var front = 0;
		var c = 1;
		var q = this.mQue;
		var max = this.mQueSize;
		var node = this.mNodeList;
		while(node != null) {
			node.depth = 0;
			node = node.next;
		}
		if(seed == null) seed = this.mNodeList;
		seed.marked = true;
		seed.parent = seed;
		q[0] = seed;
		if(preflight) {
			if(process == null) {
				var v = null;
				var n = q[front];
				v = n.val;
				if(!v.visit(true,userData)) return;
				while(c > 0) {
					n = q[front];
					v = n.val;
					if(!v.visit(false,userData)) return;
					var a = n.arcList;
					while(a != null) {
						var m = a.node;
						if(m.marked) {
							a = a.next;
							continue;
						}
						m.marked = true;
						m.parent = n;
						m.depth = n.depth + 1;
						if(m.depth <= maxDepth) {
							v = m.val;
							if(v.visit(true,userData)) {
								var i = c++ + front;
								if(i == max) {
									_g.resizeQue(max = max * 2);
									q = _g.mQue;
								}
								q[i] = m;
							}
						}
						a = a.next;
					}
					front++;
					c--;
				}
			} else {
				var n1 = q[front];
				if(!process(n1,true,userData)) return;
				while(c > 0) {
					n1 = q[front];
					if(!process(n1,false,userData)) return;
					var a1 = n1.arcList;
					while(a1 != null) {
						var m1 = a1.node;
						if(m1.marked) {
							a1 = a1.next;
							continue;
						}
						m1.marked = true;
						m1.parent = n1;
						m1.depth = n1.depth + 1;
						if(m1.depth <= maxDepth) {
							if(process(m1,true,userData)) {
								var i1 = c++ + front;
								if(i1 == max) {
									_g.resizeQue(max = max * 2);
									q = _g.mQue;
								}
								q[i1] = m1;
							}
						}
						a1 = a1.next;
					}
					front++;
					c--;
				}
			}
		} else if(process == null) {
			var v1 = null;
			while(c > 0) {
				var n2 = q[front];
				v1 = n2.val;
				if(!v1.visit(false,userData)) return;
				var a2 = n2.arcList;
				while(a2 != null) {
					var m2 = a2.node;
					if(m2.marked) {
						a2 = a2.next;
						continue;
					}
					m2.marked = true;
					m2.depth = n2.depth + 1;
					m2.parent = n2.parent;
					if(m2.depth <= maxDepth) {
						var i2 = c++ + front;
						if(i2 == max) {
							_g.resizeQue(max = max * 2);
							q = _g.mQue;
						}
						q[i2] = m2;
					}
					a2 = a2.next;
				}
				front++;
				c--;
			}
		} else while(c > 0) {
			var n3 = q[front];
			if(n3.depth > maxDepth) continue;
			if(!process(n3,false,userData)) return;
			var a3 = n3.arcList;
			while(a3 != null) {
				var m3 = a3.node;
				if(m3.marked) {
					a3 = a3.next;
					continue;
				}
				m3.marked = true;
				m3.depth = n3.depth + 1;
				m3.parent = n3.parent;
				if(m3.depth <= maxDepth) {
					var i3 = c++ + front;
					if(i3 == max) {
						_g.resizeQue(max = max * 2);
						q = _g.mQue;
					}
					q[i3] = m3;
				}
				a3 = a3.next;
			}
			front++;
			c--;
		}
	}
	,toString: function() {
		var b = new StringBuf();
		b.b += Std.string("{ Graph size: " + this.mSize + " }");
		if(this.mSize == 0) return b.b;
		b.b += "\n[\n";
		var node = this.mNodeList;
		while(node != null) {
			b.add("  " + node.toString() + "\n");
			node = node.next;
		}
		b.b += "]";
		return b.b;
	}
	,get_size: function() {
		return this.mSize;
	}
	,free: function() {
		var node = this.mNodeList;
		while(node != null) {
			var nextNode = node.next;
			var arc = node.arcList;
			while(arc != null) {
				var nextArc = arc.next;
				arc.next = arc.prev = null;
				arc.node = null;
				arc = nextArc;
			}
			node.free();
			node = nextNode;
		}
		this.mNodeList = null;
		de_polygonal_ds_tools_NativeArrayTools.nullify(this.mStack);
		this.mStack = null;
		de_polygonal_ds_tools_NativeArrayTools.nullify(this.mQue);
		this.mQue = null;
		if(this.mIterator != null) {
			this.mIterator.free();
			this.mIterator = null;
		}
	}
	,contains: function(x) {
		var found = false;
		var node = this.mNodeList;
		while(node != null) {
			if(node.val == x) return true;
			node = node.next;
		}
		return false;
	}
	,remove: function(x) {
		var found = false;
		var node = this.mNodeList;
		while(node != null) {
			var nextNode = node.next;
			if(node.val == x) {
				this.unlink(node);
				if(node == this.mNodeList) this.mNodeList = nextNode;
				node.val = null;
				node.next = node.prev = null;
				node.arcList = null;
				found = true;
				this.mSize--;
			}
			node = nextNode;
		}
		return found;
	}
	,clear: function(gc) {
		if(gc == null) gc = false;
		if(gc) {
			var node = this.mNodeList;
			while(node != null) {
				var hook = node.next;
				var arc = node.arcList;
				while(arc != null) {
					var hook1 = arc.next;
					arc.free();
					arc = hook1;
				}
				node.free();
				node = hook;
			}
			de_polygonal_ds_tools_NativeArrayTools.nullify(this.mStack);
			de_polygonal_ds_tools_NativeArrayTools.nullify(this.mQue);
		}
		this.mNodeList = null;
		this.mSize = 0;
	}
	,iterator: function() {
		if(this.reuseIterator) {
			if(this.mIterator == null) this.mIterator = new de_polygonal_ds_GraphIterator(this); else this.mIterator.reset();
			return this.mIterator;
		} else return new de_polygonal_ds_GraphIterator(this);
	}
	,nodeIterator: function() {
		return new de_polygonal_ds_GraphNodeIterator(this);
	}
	,arcIterator: function() {
		return new de_polygonal_ds_GraphArcIterator(this);
	}
	,isEmpty: function() {
		return this.mSize == 0;
	}
	,toArray: function() {
		if(this.mSize == 0) return [];
		var i = 0;
		var out = de_polygonal_ds_tools_ArrayTools.alloc(this.mSize);
		var node = this.mNodeList;
		while(node != null) {
			out[i++] = node.val;
			node = node.next;
		}
		return out;
	}
	,clone: function(assign,copier) {
		if(assign == null) assign = true;
		var copy = new de_polygonal_ds_Graph();
		if(this.mNodeList == null) return copy;
		var t = [];
		var i = 0;
		var n = this.mNodeList;
		var m;
		if(assign) while(n != null) {
			m = copy.addNode(copy.createNode(n.val));
			t[i++] = m;
			n = n.next;
		} else if(copier == null) while(n != null) {
			m = copy.addNode(copy.createNode((js_Boot.__cast(n.val , de_polygonal_ds_Cloneable)).clone()));
			t[i++] = m;
			n = n.next;
		} else while(n != null) {
			m = copy.addNode(copy.createNode(copier(n.val)));
			t[i++] = m;
			n = n.next;
		}
		i = 0;
		n = this.mNodeList;
		var a;
		while(n != null) {
			m = t[i++];
			a = n.arcList;
			while(a != null) {
				m.addArc(a.node,a.cost);
				a = a.next;
			}
			n = n.next;
		}
		return copy;
	}
	,dFSRecursiveVisit: function(node,preflight,userData) {
		node.marked = true;
		var v = node.val;
		if(!v.visit(false,userData)) return false;
		var a = node.arcList;
		while(a != null) {
			var m = a.node;
			if(m.marked) {
				a = a.next;
				continue;
			}
			a.node.parent = node;
			a.node.depth = node.depth + 1;
			if(preflight) {
				v = m.val;
				if(v.visit(true,userData)) {
					if(!this.dFSRecursiveVisit(m,true,userData)) return false;
				}
			} else if(!this.dFSRecursiveVisit(m,false,userData)) return false;
			a = a.next;
		}
		return true;
	}
	,dFSRecursiveProcess: function(node,process,preflight,userData) {
		node.marked = true;
		if(!process(node,false,userData)) return false;
		var a = node.arcList;
		while(a != null) {
			var m = a.node;
			if(m.marked) {
				a = a.next;
				continue;
			}
			a.node.parent = node;
			a.node.depth = node.depth + 1;
			if(preflight) {
				if(process(m,true,userData)) {
					if(!this.dFSRecursiveProcess(m,process,true,userData)) return false;
				}
			} else if(!this.dFSRecursiveProcess(m,process,false,userData)) return false;
			a = a.next;
		}
		return true;
	}
	,resizeStack: function(newSize) {
		var t = new Array(newSize);
		de_polygonal_ds_tools_NativeArrayTools.blit(this.mStack,0,t,0,this.mStackSize);
		this.mStack = t;
		this.mStackSize = newSize;
	}
	,resizeQue: function(newSize) {
		var t = new Array(newSize);
		de_polygonal_ds_tools_NativeArrayTools.blit(this.mQue,0,t,0,this.mQueSize);
		this.mQue = t;
		this.mQueSize = newSize;
	}
	,serialize: function(getVal) {
		var vals = [];
		var arcs = [];
		var arcValues = [];
		var node = this.mNodeList;
		var arc;
		var i;
		var j;
		var indexLut = new haxe_ds_IntMap();
		var i1 = 0;
		while(node != null) {
			indexLut.set(node.key,i1++);
			node = node.next;
		}
		i1 = 0;
		node = this.mNodeList;
		while(node != null) {
			vals[i1] = getVal(node.val);
			arc = node.arcList;
			while(arc != null) {
				arcs.push(i1);
				arcs.push(indexLut.h[arc.node.key]);
				arcValues.push(arc.val);
				arc = arc.next;
			}
			node = node.next;
			i1++;
		}
		return { arcs : arcs, vals : vals, arcVals : arcValues};
	}
	,unserialize: function(data,setVal) {
		this.clear(true);
		var nodes = [];
		var vals = data.vals;
		var i = 0;
		var k = vals.length;
		var arcVals = data.arcVals;
		while(i < k) nodes.push(this.createNode(setVal(vals[i++])));
		i = k;
		while(i > 0) this.addNode(nodes[--i]);
		var arcs = data.arcs;
		i = arcs.length;
		var count = arcVals.length;
		while(i > 0) {
			var target = arcs[--i];
			var source = arcs[--i];
			var val = arcVals[--count];
			this.addSingleArc(nodes[source],nodes[target]);
			if(val != null) nodes[source].arcList.val = val;
		}
	}
	,__class__: de_polygonal_ds_Graph
	,__properties__: {get_size:"get_size"}
};
var de_polygonal_ds_Itr = function() { };
$hxClasses["de.polygonal.ds.Itr"] = de_polygonal_ds_Itr;
de_polygonal_ds_Itr.__name__ = ["de","polygonal","ds","Itr"];
de_polygonal_ds_Itr.prototype = {
	hasNext: null
	,next: null
	,remove: null
	,reset: null
	,__class__: de_polygonal_ds_Itr
};
var de_polygonal_ds_GraphIterator = function(x) {
	this.mObject = x;
	{
		this.mNode = this.mObject.mNodeList;
		this;
	}
};
$hxClasses["de.polygonal.ds.GraphIterator"] = de_polygonal_ds_GraphIterator;
de_polygonal_ds_GraphIterator.__name__ = ["de","polygonal","ds","GraphIterator"];
de_polygonal_ds_GraphIterator.__interfaces__ = [de_polygonal_ds_Itr];
de_polygonal_ds_GraphIterator.prototype = {
	mObject: null
	,mNode: null
	,free: function() {
		this.mObject = null;
		this.mNode = null;
	}
	,reset: function() {
		this.mNode = this.mObject.mNodeList;
		return this;
	}
	,hasNext: function() {
		return this.mNode != null;
	}
	,next: function() {
		var x = this.mNode.val;
		this.mNode = this.mNode.next;
		return x;
	}
	,remove: function() {
		throw new js__$Boot_HaxeError("unsupported operation");
	}
	,__class__: de_polygonal_ds_GraphIterator
};
var de_polygonal_ds_GraphNodeIterator = function(x) {
	this.mObject = x;
	{
		this.mNode = this.mObject.mNodeList;
		this;
	}
};
$hxClasses["de.polygonal.ds.GraphNodeIterator"] = de_polygonal_ds_GraphNodeIterator;
de_polygonal_ds_GraphNodeIterator.__name__ = ["de","polygonal","ds","GraphNodeIterator"];
de_polygonal_ds_GraphNodeIterator.__interfaces__ = [de_polygonal_ds_Itr];
de_polygonal_ds_GraphNodeIterator.prototype = {
	mObject: null
	,mNode: null
	,reset: function() {
		this.mNode = this.mObject.mNodeList;
		return this;
	}
	,hasNext: function() {
		return this.mNode != null;
	}
	,next: function() {
		var x = this.mNode;
		this.mNode = this.mNode.next;
		return x;
	}
	,remove: function() {
		throw new js__$Boot_HaxeError("unsupported operation");
	}
	,__class__: de_polygonal_ds_GraphNodeIterator
};
var de_polygonal_ds_GraphArcIterator = function(x) {
	this.mObject = x;
	{
		this.mNode = this.mObject.mNodeList;
		this.mArc = this.mNode.arcList;
		this;
	}
};
$hxClasses["de.polygonal.ds.GraphArcIterator"] = de_polygonal_ds_GraphArcIterator;
de_polygonal_ds_GraphArcIterator.__name__ = ["de","polygonal","ds","GraphArcIterator"];
de_polygonal_ds_GraphArcIterator.__interfaces__ = [de_polygonal_ds_Itr];
de_polygonal_ds_GraphArcIterator.prototype = {
	mObject: null
	,mNode: null
	,mArc: null
	,reset: function() {
		this.mNode = this.mObject.mNodeList;
		this.mArc = this.mNode.arcList;
		return this;
	}
	,hasNext: function() {
		return this.mArc != null && this.mNode != null;
	}
	,next: function() {
		var x = this.mArc;
		this.mArc = this.mArc.next;
		if(this.mArc == null) {
			this.mNode = this.mNode.next;
			if(this.mNode != null) this.mArc = this.mNode.arcList;
		}
		return x;
	}
	,remove: function() {
		throw new js__$Boot_HaxeError("unsupported operation");
	}
	,__class__: de_polygonal_ds_GraphArcIterator
};
var de_polygonal_ds_GraphArc = function(node,cost) {
	this.key = de_polygonal_ds_HashKey._counter++;
	this.node = node;
	this.cost = cost;
	this.next = null;
	this.prev = null;
};
$hxClasses["de.polygonal.ds.GraphArc"] = de_polygonal_ds_GraphArc;
de_polygonal_ds_GraphArc.__name__ = ["de","polygonal","ds","GraphArc"];
de_polygonal_ds_GraphArc.__interfaces__ = [de_polygonal_ds_Hashable];
de_polygonal_ds_GraphArc.prototype = {
	key: null
	,node: null
	,cost: null
	,next: null
	,prev: null
	,val: null
	,free: function() {
		this.node = null;
		this.next = this.prev = null;
	}
	,__class__: de_polygonal_ds_GraphArc
};
var de_polygonal_ds_GraphNode = function(graph,x) {
	this.numArcs = 0;
	this.key = de_polygonal_ds_HashKey._counter++;
	this.val = x;
	this.arcList = null;
	this.marked = false;
	this.mGraph = graph;
};
$hxClasses["de.polygonal.ds.GraphNode"] = de_polygonal_ds_GraphNode;
de_polygonal_ds_GraphNode.__name__ = ["de","polygonal","ds","GraphNode"];
de_polygonal_ds_GraphNode.__interfaces__ = [de_polygonal_ds_Hashable];
de_polygonal_ds_GraphNode.prototype = {
	key: null
	,val: null
	,parent: null
	,depth: null
	,next: null
	,prev: null
	,arcList: null
	,marked: null
	,numArcs: null
	,mGraph: null
	,free: function() {
		this.val = null;
		this.next = this.prev = null;
		this.arcList = null;
		this.mGraph = null;
	}
	,iterator: function() {
		return new de_polygonal_ds_NodeValIterator(this);
	}
	,isConnected: function(target) {
		return this.getArc(target) != null;
	}
	,isMutuallyConnected: function(target) {
		return this.getArc(target) != null && target.getArc(this) != null;
	}
	,getArc: function(target) {
		var found = false;
		var a = this.arcList;
		while(a != null) {
			if(a.node == target) {
				found = true;
				break;
			}
			a = a.next;
		}
		if(found) return a; else return null;
	}
	,addArc: function(target,cost) {
		if(cost == null) cost = 1;
		var arc;
		if(this.mGraph.borrowArc != null) arc = this.mGraph.borrowArc(target,cost); else arc = new de_polygonal_ds_GraphArc(target,cost);
		arc.next = this.arcList;
		if(this.arcList != null) this.arcList.prev = arc;
		this.arcList = arc;
		this.numArcs++;
	}
	,removeArc: function(target) {
		var arc = this.getArc(target);
		if(arc != null) {
			if(arc.prev != null) arc.prev.next = arc.next;
			if(arc.next != null) arc.next.prev = arc.prev;
			if(this.arcList == arc) this.arcList = arc.next;
			arc.next = null;
			arc.prev = null;
			arc.node = null;
			if(this.mGraph.returnArc != null) this.mGraph.returnArc(arc);
			this.numArcs--;
			return true;
		}
		return false;
	}
	,removeSingleArcs: function() {
		var arc = this.arcList;
		while(arc != null) {
			this.removeArc(arc.node);
			arc = arc.next;
		}
		this.numArcs = 0;
	}
	,removeMutualArcs: function() {
		var arc = this.arcList;
		while(arc != null) {
			arc.node.removeArc(this);
			this.removeArc(arc.node);
			arc = arc.next;
		}
		this.arcList = null;
		this.numArcs = 0;
	}
	,toString: function() {
		var t = [];
		var arc;
		if(this.arcList != null) {
			arc = this.arcList;
			while(arc != null) {
				t.push(Std.string(arc.node.val));
				arc = arc.next;
			}
		}
		if(t.length > 0) return "{ GraphNode val: " + Std.string(this.val) + ", connected to: " + t.join(",") + " }"; else return "{ GraphNode val: " + Std.string(this.val) + " }";
	}
	,__class__: de_polygonal_ds_GraphNode
};
var de_polygonal_ds_NodeValIterator = function(x) {
	this.mObject = x;
	{
		this.mArcList = this.mObject.arcList;
		this;
	}
};
$hxClasses["de.polygonal.ds.NodeValIterator"] = de_polygonal_ds_NodeValIterator;
de_polygonal_ds_NodeValIterator.__name__ = ["de","polygonal","ds","NodeValIterator"];
de_polygonal_ds_NodeValIterator.__interfaces__ = [de_polygonal_ds_Itr];
de_polygonal_ds_NodeValIterator.prototype = {
	mObject: null
	,mArcList: null
	,reset: function() {
		this.mArcList = this.mObject.arcList;
		return this;
	}
	,hasNext: function() {
		return this.mArcList != null;
	}
	,next: function() {
		var val = this.mArcList.node.val;
		this.mArcList = this.mArcList.next;
		return val;
	}
	,remove: function() {
		throw new js__$Boot_HaxeError("unsupported operation");
	}
	,__class__: de_polygonal_ds_NodeValIterator
};
var de_polygonal_ds_HashKey = function() { };
$hxClasses["de.polygonal.ds.HashKey"] = de_polygonal_ds_HashKey;
de_polygonal_ds_HashKey.__name__ = ["de","polygonal","ds","HashKey"];
de_polygonal_ds_HashKey.next = function() {
	return de_polygonal_ds_HashKey._counter++;
};
var de_polygonal_ds_HashableItem = function() {
	this.key = de_polygonal_ds_HashKey._counter++;
};
$hxClasses["de.polygonal.ds.HashableItem"] = de_polygonal_ds_HashableItem;
de_polygonal_ds_HashableItem.__name__ = ["de","polygonal","ds","HashableItem"];
de_polygonal_ds_HashableItem.__interfaces__ = [de_polygonal_ds_Hashable];
de_polygonal_ds_HashableItem.prototype = {
	key: null
	,__class__: de_polygonal_ds_HashableItem
};
var de_polygonal_ds_Set = function() { };
$hxClasses["de.polygonal.ds.Set"] = de_polygonal_ds_Set;
de_polygonal_ds_Set.__name__ = ["de","polygonal","ds","Set"];
de_polygonal_ds_Set.__interfaces__ = [de_polygonal_ds_Collection];
de_polygonal_ds_Set.prototype = {
	has: null
	,set: null
	,unset: null
	,__class__: de_polygonal_ds_Set
};
var de_polygonal_ds_IntHashSet = function(slotCount,initialCapacity) {
	if(initialCapacity == null) initialCapacity = -1;
	this.mSize = 0;
	this.mFree = 0;
	this.reuseIterator = false;
	this.growthRate = -3;
	this.key = de_polygonal_ds_HashKey._counter++;
	if(initialCapacity == -1) initialCapacity = slotCount;
	if(2 > initialCapacity) initialCapacity = 2; else initialCapacity = initialCapacity;
	this.mMinCapacity = this.capacity = initialCapacity;
	this.slotCount = slotCount;
	this.mMask = slotCount - 1;
	this.mHash = de_polygonal_ds_tools_NativeArrayTools.init(new Array(slotCount),-1);
	this.mData = new Array(this.capacity << 1);
	this.mNext = new Array(this.capacity);
	var j = 1;
	var t = this.mData;
	var _g1 = 0;
	var _g = this.capacity;
	while(_g1 < _g) {
		var i = _g1++;
		t[j - 1] = -2147483648;
		t[j] = -1;
		j += 2;
	}
	t = this.mNext;
	var _g11 = 0;
	var _g2 = this.capacity - 1;
	while(_g11 < _g2) {
		var i1 = _g11++;
		t[i1] = i1 + 1;
	}
	t[this.capacity - 1] = -1;
};
$hxClasses["de.polygonal.ds.IntHashSet"] = de_polygonal_ds_IntHashSet;
de_polygonal_ds_IntHashSet.__name__ = ["de","polygonal","ds","IntHashSet"];
de_polygonal_ds_IntHashSet.__interfaces__ = [de_polygonal_ds_Set];
de_polygonal_ds_IntHashSet.prototype = {
	key: null
	,capacity: null
	,growthRate: null
	,reuseIterator: null
	,get_loadFactor: function() {
		return this.mSize / this.slotCount;
	}
	,slotCount: null
	,mHash: null
	,mData: null
	,mNext: null
	,mMask: null
	,mFree: null
	,mSize: null
	,mMinCapacity: null
	,mIterator: null
	,getCollisionCount: function() {
		var c = 0;
		var j;
		var d = this.mData;
		var h = this.mHash;
		var _g1 = 0;
		var _g = this.slotCount;
		while(_g1 < _g) {
			var i = _g1++;
			j = h[i];
			if(j == -1) continue;
			j = d[j + 1];
			while(j != -1) {
				j = d[j + 1];
				c++;
			}
		}
		return c;
	}
	,hasFront: function(x) {
		var h = this.mHash;
		var b = x * 73856093 & this.mMask;
		var i = h[b];
		if(i == -1) return false; else {
			var d = this.mData;
			if(d[i] == x) return true; else {
				var exists = false;
				var first = i;
				var i0 = first;
				i = d[i + 1];
				while(i != -1) {
					if(d[i] == x) {
						d[i0 + 1] = d[i + 1];
						d[i + 1] = first;
						d[b] = i;
						exists = true;
						break;
					}
					i = de_polygonal_ds_tools_NativeArrayTools.get(d,(i0 = i) + 1);
				}
				return exists;
			}
		}
	}
	,rehash: function(slotCount) {
		if(this.slotCount == slotCount) return;
		var t = new de_polygonal_ds_IntHashSet(slotCount,this.capacity);
		var d = this.mData;
		var _g1 = 0;
		var _g = this.capacity;
		while(_g1 < _g) {
			var i = _g1++;
			var v = d[i << 1];
			if(v != -2147483648) t.set(v);
		}
		this.mHash = t.mHash;
		this.mData = t.mData;
		this.mNext = t.mNext;
		this.slotCount = slotCount;
		this.mMask = t.mMask;
		this.mFree = t.mFree;
	}
	,pack: function() {
		if(this.capacity == this.mMinCapacity) return this;
		var oldCapacity = this.capacity;
		var x = this.mSize;
		var y = this.mMinCapacity;
		if(x > y) this.capacity = x; else this.capacity = y;
		var src = this.mData;
		var dst;
		var e = 0;
		var t = this.mHash;
		var j;
		dst = new Array(this.capacity << 1);
		var _g1 = 0;
		var _g = this.slotCount;
		while(_g1 < _g) {
			var i = _g1++;
			j = t[i];
			if(j == -1) continue;
			t[i] = e;
			de_polygonal_ds_tools_NativeArrayTools.set(dst,e++,src[j]);
			de_polygonal_ds_tools_NativeArrayTools.set(dst,e++,-1);
			j = src[j + 1];
			while(j != -1) {
				dst[e - 1] = e;
				de_polygonal_ds_tools_NativeArrayTools.set(dst,e++,src[j]);
				de_polygonal_ds_tools_NativeArrayTools.set(dst,e++,-1);
				j = src[j + 1];
			}
		}
		this.mData = dst;
		this.mNext = new Array(this.capacity);
		var n = this.mNext;
		var _g11 = 0;
		var _g2 = this.capacity - 1;
		while(_g11 < _g2) {
			var i1 = _g11++;
			n[i1] = i1 + 1;
		}
		n[this.capacity - 1] = -1;
		this.mFree = -1;
		return this;
	}
	,toString: function() {
		var b = new StringBuf();
		b.add(de_polygonal_Printf.format("{ IntHashSet size/capacity: %d/%d, load factor: %.2f }",[this.mSize,this.capacity,this.get_loadFactor()]));
		if(this.mSize == 0) return b.b;
		b.b += "\n[\n";
		var $it0 = this.iterator();
		while( $it0.hasNext() ) {
			var x = $it0.next();
			b.b += Std.string("  " + x + "\n");
		}
		b.b += "]";
		return b.b;
	}
	,hashCode: function(x) {
		return x * 73856093 & this.mMask;
	}
	,grow: function() {
		var oldCapacity = this.capacity;
		this.capacity = de_polygonal_ds_tools_GrowthRate.compute(this.growthRate,this.capacity);
		var t;
		t = new Array(this.capacity);
		de_polygonal_ds_tools_NativeArrayTools.blit(this.mNext,0,t,0,oldCapacity);
		this.mNext = t;
		t = new Array(this.capacity << 1);
		de_polygonal_ds_tools_NativeArrayTools.blit(this.mData,0,t,0,oldCapacity << 1);
		this.mData = t;
		t = this.mNext;
		var _g1 = oldCapacity - 1;
		var _g = this.capacity - 1;
		while(_g1 < _g) {
			var i = _g1++;
			t[i] = i + 1;
		}
		t[this.capacity - 1] = -1;
		this.mFree = oldCapacity;
		var j = oldCapacity << 1;
		var t1 = this.mData;
		var _g11 = 0;
		var _g2 = this.capacity - oldCapacity;
		while(_g11 < _g2) {
			var i1 = _g11++;
			t1[j] = -2147483648;
			t1[j + 1] = -1;
			j += 2;
		}
	}
	,has: function(x) {
		var i = this.mHash[x * 73856093 & this.mMask];
		if(i == -1) return false; else {
			var d = this.mData;
			if(d[i] == x) return true; else {
				var exists = false;
				i = d[i + 1];
				while(i != -1) {
					if(d[i] == x) {
						exists = true;
						break;
					}
					i = d[i + 1];
				}
				return exists;
			}
		}
	}
	,set: function(x) {
		var b = x * 73856093 & this.mMask;
		var d = this.mData;
		var j = this.mHash[b];
		if(j == -1) {
			if(this.mSize == this.capacity) {
				this.grow();
				d = this.mData;
			}
			j = this.mFree << 1;
			this.mFree = this.mNext[this.mFree];
			this.mHash[b] = j;
			d[j] = x;
			this.mSize++;
			return true;
		} else if(d[j] == x) return false; else {
			var p = d[j + 1];
			while(p != -1) {
				if(d[p] == x) {
					j = -1;
					break;
				}
				j = p;
				p = d[p + 1];
			}
			if(j == -1) return false; else {
				if(this.mSize == this.capacity) {
					this.grow();
					d = this.mData;
				}
				p = this.mFree << 1;
				this.mFree = this.mNext[this.mFree];
				d[p] = x;
				d[j + 1] = p;
				this.mSize++;
				return true;
			}
		}
	}
	,unset: function(x) {
		return this.remove(x);
	}
	,get_size: function() {
		return this.mSize;
	}
	,free: function() {
		this.mHash = null;
		this.mData = null;
		this.mNext = null;
		if(this.mIterator != null) {
			this.mIterator.free();
			this.mIterator = null;
		}
	}
	,contains: function(x) {
		return this.has(x);
	}
	,remove: function(x) {
		var b = x * 73856093 & this.mMask;
		var i = this.mHash[b];
		if(i == -1) return false; else {
			var d = this.mData;
			if(x == d[i]) {
				if(d[i + 1] == -1) this.mHash[b] = -1; else this.mHash[b] = d[i + 1];
				var j = i >> 1;
				this.mNext[j] = this.mFree;
				this.mFree = j;
				d[i] = -2147483648;
				d[i + 1] = -1;
				this.mSize--;
				return true;
			} else {
				var exists = false;
				var i0 = i;
				i = d[i + 1];
				while(i != -1) {
					if(d[i] == x) {
						exists = true;
						break;
					}
					i = de_polygonal_ds_tools_NativeArrayTools.get(d,(i0 = i) + 1);
				}
				if(exists) {
					d[i0 + 1] = d[i + 1];
					var j1 = i >> 1;
					this.mNext[j1] = this.mFree;
					this.mFree = j1;
					d[i] = -2147483648;
					d[i + 1] = -1;
					--this.mSize;
					return true;
				} else return false;
			}
		}
	}
	,clear: function(gc) {
		if(gc == null) gc = false;
		var h = this.mHash;
		var _g1 = 0;
		var _g = this.slotCount;
		while(_g1 < _g) {
			var i = _g1++;
			h[i] = -1;
		}
		var j = 1;
		var t = this.mData;
		var _g11 = 0;
		var _g2 = this.capacity;
		while(_g11 < _g2) {
			var i1 = _g11++;
			t[j - 1] = -2147483648;
			t[j] = -1;
			j += 2;
		}
		t = this.mNext;
		var _g12 = 0;
		var _g3 = this.capacity - 1;
		while(_g12 < _g3) {
			var i2 = _g12++;
			t[i2] = i2 + 1;
		}
		t[this.capacity - 1] = -1;
		this.mFree = 0;
		this.mSize = 0;
	}
	,iterator: function() {
		if(this.reuseIterator) {
			if(this.mIterator == null) this.mIterator = new de_polygonal_ds_IntHashSetIterator(this); else this.mIterator.reset();
			return this.mIterator;
		} else return new de_polygonal_ds_IntHashSetIterator(this);
	}
	,isEmpty: function() {
		return this.mSize == 0;
	}
	,toArray: function() {
		if(this.mSize == 0) return [];
		var out = de_polygonal_ds_tools_ArrayTools.alloc(this.mSize);
		var j = 0;
		var v;
		var d = this.mData;
		var _g1 = 0;
		var _g = this.capacity;
		while(_g1 < _g) {
			var i = _g1++;
			v = d[i << 1];
			if(v != -2147483648) out[j++] = v;
		}
		return out;
	}
	,clone: function(assign,copier) {
		if(assign == null) assign = true;
		var c = new de_polygonal_ds_IntHashSet(this.slotCount,this.mSize);
		de_polygonal_ds_tools_NativeArrayTools.blit(this.mHash,0,c.mHash,0,this.slotCount);
		de_polygonal_ds_tools_NativeArrayTools.blit(this.mData,0,c.mData,0,this.mSize << 1);
		de_polygonal_ds_tools_NativeArrayTools.blit(this.mNext,0,c.mNext,0,this.mSize);
		c.mMask = this.mMask;
		c.slotCount = this.slotCount;
		c.capacity = this.capacity;
		c.mFree = this.mFree;
		c.mSize = this.mSize;
		return c;
	}
	,__class__: de_polygonal_ds_IntHashSet
	,__properties__: {get_size:"get_size",get_loadFactor:"get_loadFactor"}
};
var de_polygonal_ds_IntHashSetIterator = function(x) {
	this.mObject = x;
	this.mData = x.mData;
	this.mI = 0;
	this.mS = x.capacity;
	this.scan();
};
$hxClasses["de.polygonal.ds.IntHashSetIterator"] = de_polygonal_ds_IntHashSetIterator;
de_polygonal_ds_IntHashSetIterator.__name__ = ["de","polygonal","ds","IntHashSetIterator"];
de_polygonal_ds_IntHashSetIterator.__interfaces__ = [de_polygonal_ds_Itr];
de_polygonal_ds_IntHashSetIterator.prototype = {
	mObject: null
	,mI: null
	,mS: null
	,mData: null
	,free: function() {
		this.mObject = null;
		this.mData = null;
	}
	,reset: function() {
		this.mData = this.mObject.mData;
		this.mI = 0;
		this.mS = this.mObject.capacity;
		this.scan();
		return this;
	}
	,hasNext: function() {
		return this.mI < this.mS;
	}
	,next: function() {
		var x = de_polygonal_ds_tools_NativeArrayTools.get(this.mData,this.mI++ << 1);
		this.scan();
		return x;
	}
	,remove: function() {
		throw new js__$Boot_HaxeError("unsupported operation");
	}
	,scan: function() {
		while(this.mI < this.mS && this.mData[this.mI << 1] == -2147483648) this.mI++;
	}
	,__class__: de_polygonal_ds_IntHashSetIterator
};
var de_polygonal_ds_Map = function() { };
$hxClasses["de.polygonal.ds.Map"] = de_polygonal_ds_Map;
de_polygonal_ds_Map.__name__ = ["de","polygonal","ds","Map"];
de_polygonal_ds_Map.__interfaces__ = [de_polygonal_ds_Collection];
de_polygonal_ds_Map.prototype = {
	has: null
	,hasKey: null
	,get: null
	,set: null
	,unset: null
	,remap: null
	,toValSet: null
	,toKeySet: null
	,keys: null
	,__class__: de_polygonal_ds_Map
};
var de_polygonal_ds_IntHashTable = function(slotCount,initialCapacity) {
	if(initialCapacity == null) initialCapacity = -1;
	this.mTmpKeyBuffer = [];
	this.mIterator = null;
	this.mSize = 0;
	this.mFree = 0;
	this.reuseIterator = false;
	this.key = de_polygonal_ds_HashKey._counter++;
	if(initialCapacity == -1) initialCapacity = slotCount;
	if(2 > initialCapacity) initialCapacity = 2; else initialCapacity = initialCapacity;
	this.mMinCapacity = this.capacity = initialCapacity;
	this.mH = new de_polygonal_ds_IntIntHashTable(slotCount,this.capacity);
	this.mVals = new Array(this.capacity);
	this.mNext = new Array(this.capacity);
	this.mKeys = de_polygonal_ds_tools_NativeArrayTools.init(new Array(this.capacity),-2147483648,0,this.capacity);
	var t = this.mNext;
	var _g1 = 0;
	var _g = this.capacity - 1;
	while(_g1 < _g) {
		var i = _g1++;
		t[i] = i + 1;
	}
	t[this.capacity - 1] = -1;
};
$hxClasses["de.polygonal.ds.IntHashTable"] = de_polygonal_ds_IntHashTable;
de_polygonal_ds_IntHashTable.__name__ = ["de","polygonal","ds","IntHashTable"];
de_polygonal_ds_IntHashTable.__interfaces__ = [de_polygonal_ds_Map];
de_polygonal_ds_IntHashTable.prototype = {
	key: null
	,capacity: null
	,get_growthRate: function() {
		return this.mH.growthRate;
	}
	,set_growthRate: function(value) {
		return this.mH.growthRate = value;
	}
	,reuseIterator: null
	,get_loadFactor: function() {
		return this.mH.get_loadFactor();
	}
	,get_slotCount: function() {
		return this.mH.slotCount;
	}
	,mH: null
	,mVals: null
	,mNext: null
	,mKeys: null
	,mFree: null
	,mSize: null
	,mMinCapacity: null
	,mShrinkSize: null
	,mIterator: null
	,mTmpKeyBuffer: null
	,getCollisionCount: function() {
		return this.mH.getCollisionCount();
	}
	,getFront: function(key) {
		var i = this.mH.getFront(key);
		if(i == -2147483648) return null; else return this.mVals[i];
	}
	,setIfAbsent: function(key,val) {
		if(this.mSize == this.capacity) this.grow();
		var i = this.mFree;
		if(this.mH.setIfAbsent(key,i)) {
			this.mVals[i] = val;
			this.mKeys[i] = key;
			this.mFree = this.mNext[i];
			this.mSize++;
			return true;
		} else return false;
	}
	,rehash: function(slotCount) {
		this.mH.rehash(slotCount);
	}
	,remap: function(key,val) {
		var i = this.mH.get(key);
		if(i != -2147483648) {
			this.mVals[i] = val;
			return true;
		} else return false;
	}
	,toKeyArray: function() {
		return this.mH.toKeyArray();
	}
	,toString: function() {
		var b = new StringBuf();
		b.add(de_polygonal_Printf.format("{ IntHashTable size/capacity: %d/%d, load factor: %.2f }",[this.mSize,this.capacity,this.get_loadFactor()]));
		if(this.mSize == 0) return b.b;
		b.b += "\n[\n";
		var max = 0.;
		var $it0 = this.keys();
		while( $it0.hasNext() ) {
			var key = $it0.next();
			max = Math.max(max,key);
		}
		var i = 1;
		while(max != 0) {
			i++;
			max = max / 10 | 0;
		}
		var args = [];
		var fmt = "  %- " + i + "d -> %d\n";
		var $it1 = this.keys();
		while( $it1.hasNext() ) {
			var key1 = $it1.next();
			args[0] = key1;
			args[1] = Std.string(this.mVals[this.mH.get(key1)]);
			b.add(de_polygonal_Printf.format(fmt,args));
		}
		b.b += "]";
		return b.b;
	}
	,has: function(val) {
		var k = this.mKeys;
		var v = this.mVals;
		var _g1 = 0;
		var _g = this.capacity;
		while(_g1 < _g) {
			var i = _g1++;
			if(k[i] == -2147483648) continue;
			if(v[i] == val) return true;
		}
		return false;
	}
	,hasKey: function(key) {
		return this.mH.hasKey(key);
	}
	,count: function(key) {
		return this.mH.count(key);
	}
	,get: function(key) {
		var i = this.mH.get(key);
		if(i == -2147483648) return null; else return this.mVals[i];
	}
	,getAll: function(key,out) {
		var i = this.mH.get(key);
		if(i == -2147483648) return 0; else {
			var b = this.mTmpKeyBuffer;
			var c = this.mH.getAll(key,b);
			var v = this.mVals;
			var _g = 0;
			while(_g < c) {
				var i1 = _g++;
				out[i1] = v[b[i1]];
			}
			return c;
		}
	}
	,set: function(key,val) {
		if(this.mSize == this.capacity) this.grow();
		var i = this.mFree;
		var first = this.mH.set(key,i);
		this.mVals[i] = val;
		this.mKeys[i] = key;
		this.mFree = this.mNext[i];
		this.mSize++;
		return first;
	}
	,unset: function(key) {
		var i = this.mH.get(key);
		if(i == -2147483648) return false;
		this.mVals[i] = null;
		this.mKeys[i] = -2147483648;
		this.mNext[i] = this.mFree;
		this.mFree = i;
		this.mH.unset(key);
		this.mSize--;
		return true;
	}
	,toValSet: function() {
		var s = new de_polygonal_ds_ListSet();
		var k = this.mKeys;
		var v = this.mVals;
		var _g1 = 0;
		var _g = this.capacity;
		while(_g1 < _g) {
			var i = _g1++;
			if(k[i] != -2147483648) s.set(v[i]);
		}
		return s;
	}
	,toKeySet: function() {
		return this.mH.toKeySet();
	}
	,keys: function() {
		return this.mH.keys();
	}
	,pack: function() {
		this.mH.pack();
		if(this.mH.capacity == this.capacity) return this;
		this.capacity = this.mH.capacity;
		this.mNext = new Array(this.capacity);
		var t = this.mNext;
		var _g1 = 0;
		var _g = this.capacity - 1;
		while(_g1 < _g) {
			var i = _g1++;
			t[i] = i + 1;
		}
		t[this.capacity - 1] = -1;
		this.mFree = 0;
		var srcKeys = this.mKeys;
		var dstKeys = new Array(this.capacity);
		var srcVals = this.mVals;
		var dstVals = new Array(this.capacity);
		var j = this.mFree;
		var $it0 = this.mH.iterator();
		while( $it0.hasNext() ) {
			var i1 = $it0.next();
			dstKeys[j] = srcKeys[i1];
			dstVals[j] = srcVals[i1];
			j = this.mNext[j];
		}
		this.mFree = j;
		this.mKeys = dstKeys;
		this.mVals = dstVals;
		var _g11 = 0;
		var _g2 = this.mSize;
		while(_g11 < _g2) {
			var i2 = _g11++;
			this.mH.remap(dstKeys[i2],i2);
		}
		return this;
	}
	,grow: function() {
		var oldCapacity = this.capacity;
		this.capacity = de_polygonal_ds_tools_GrowthRate.compute(this.get_growthRate(),this.capacity);
		var t;
		t = new Array(this.capacity);
		de_polygonal_ds_tools_NativeArrayTools.blit(this.mNext,0,t,0,oldCapacity);
		this.mNext = t;
		t = new Array(this.capacity);
		de_polygonal_ds_tools_NativeArrayTools.blit(this.mKeys,0,t,0,oldCapacity);
		this.mKeys = t;
		t = this.mKeys;
		var _g1 = oldCapacity;
		var _g = this.capacity;
		while(_g1 < _g) {
			var i = _g1++;
			t[i] = -2147483648;
		}
		t = this.mNext;
		var _g11 = oldCapacity - 1;
		var _g2 = this.capacity - 1;
		while(_g11 < _g2) {
			var i1 = _g11++;
			t[i1] = i1 + 1;
		}
		t[this.capacity - 1] = -1;
		this.mFree = oldCapacity;
		var t1 = new Array(this.capacity);
		de_polygonal_ds_tools_NativeArrayTools.blit(this.mVals,0,t1,0,oldCapacity);
		this.mVals = t1;
	}
	,get_size: function() {
		return this.mSize;
	}
	,free: function() {
		de_polygonal_ds_tools_NativeArrayTools.nullify(this.mVals);
		this.mVals = null;
		this.mKeys = null;
		this.mNext = null;
		this.mH.free();
		this.mH = null;
		if(this.mIterator != null) {
			this.mIterator.free();
			this.mIterator = null;
		}
		this.mTmpKeyBuffer = null;
	}
	,contains: function(val) {
		return this.has(val);
	}
	,remove: function(x) {
		var b = this.mTmpKeyBuffer;
		var c = 0;
		var k = this.mKeys;
		var v = this.mVals;
		var j;
		var _g1 = 0;
		var _g = this.capacity;
		while(_g1 < _g) {
			var i = _g1++;
			j = k[i];
			if(j != -2147483648) {
				if(v[i] == x) b[c++] = j;
			}
		}
		var _g2 = 0;
		while(_g2 < c) {
			var i1 = _g2++;
			this.unset(b[i1]);
		}
		return c > 0;
	}
	,clear: function(gc) {
		if(gc == null) gc = false;
		this.mH.clear(gc);
		de_polygonal_ds_tools_NativeArrayTools.init(this.mKeys,-2147483648,0,this.capacity);
		var t = this.mNext;
		var _g1 = 0;
		var _g = this.capacity - 1;
		while(_g1 < _g) {
			var i = _g1++;
			t[i] = i + 1;
		}
		t[this.capacity - 1] = -1;
		this.mFree = 0;
		this.mSize = 0;
	}
	,iterator: function() {
		if(this.reuseIterator) {
			if(this.mIterator == null) this.mIterator = new de_polygonal_ds_IntHashTableIterator(this); else this.mIterator.reset();
			return this.mIterator;
		} else return new de_polygonal_ds_IntHashTableIterator(this);
	}
	,isEmpty: function() {
		return this.mSize == 0;
	}
	,toArray: function() {
		if(this.mSize == 0) return [];
		var out = de_polygonal_ds_tools_ArrayTools.alloc(this.mSize);
		var j = 0;
		var k = this.mKeys;
		var v = this.mVals;
		var _g1 = 0;
		var _g = this.capacity;
		while(_g1 < _g) {
			var i = _g1++;
			if(k[i] != -2147483648) out[j++] = v[i];
		}
		return out;
	}
	,clone: function(assign,copier) {
		if(assign == null) assign = true;
		var c = new de_polygonal_ds_IntHashTable(this.mH.slotCount,this.mSize);
		c.mH = this.mH.clone(false);
		c.mSize = this.mSize;
		c.mFree = this.mFree;
		var src = this.mVals;
		var dst = c.mVals;
		if(assign) de_polygonal_ds_tools_NativeArrayTools.blit(src,0,dst,0,this.mSize); else {
			var k = this.mKeys;
			if(copier != null) {
				var _g1 = 0;
				var _g = this.mSize;
				while(_g1 < _g) {
					var i = _g1++;
					if(k[i] != -2147483648) de_polygonal_ds_tools_NativeArrayTools.set(dst,i,copier(src[i]));
				}
			} else {
				var _g11 = 0;
				var _g2 = this.mSize;
				while(_g11 < _g2) {
					var i1 = _g11++;
					if(k[i1] != -2147483648) de_polygonal_ds_tools_NativeArrayTools.set(dst,i1,(js_Boot.__cast(src[i1] , de_polygonal_ds_Cloneable)).clone());
				}
			}
		}
		de_polygonal_ds_tools_NativeArrayTools.blit(this.mKeys,0,c.mKeys,0,this.mSize);
		de_polygonal_ds_tools_NativeArrayTools.blit(this.mNext,0,c.mNext,0,this.mSize);
		return c;
	}
	,__class__: de_polygonal_ds_IntHashTable
	,__properties__: {get_size:"get_size",get_slotCount:"get_slotCount",get_loadFactor:"get_loadFactor",set_growthRate:"set_growthRate",get_growthRate:"get_growthRate"}
};
var de_polygonal_ds_IntHashTableIterator = function(x) {
	this.mObject = x;
	this.reset();
};
$hxClasses["de.polygonal.ds.IntHashTableIterator"] = de_polygonal_ds_IntHashTableIterator;
de_polygonal_ds_IntHashTableIterator.__name__ = ["de","polygonal","ds","IntHashTableIterator"];
de_polygonal_ds_IntHashTableIterator.__interfaces__ = [de_polygonal_ds_Itr];
de_polygonal_ds_IntHashTableIterator.prototype = {
	mObject: null
	,mVals: null
	,mKeys: null
	,mI: null
	,mS: null
	,free: function() {
		this.mObject = null;
		this.mVals = null;
		this.mKeys = null;
	}
	,reset: function() {
		this.mVals = this.mObject.mVals;
		this.mKeys = this.mObject.mKeys;
		this.mS = this.mObject.mH.capacity;
		this.mI = 0;
		while(this.mI < this.mS && this.mKeys[this.mI] == -2147483648) this.mI++;
		return this;
	}
	,hasNext: function() {
		return this.mI < this.mS;
	}
	,next: function() {
		var v = this.mVals[this.mI];
		while(++this.mI < this.mS && this.mKeys[this.mI] == -2147483648) {
		}
		return v;
	}
	,remove: function() {
		throw new js__$Boot_HaxeError("unsupported operation");
	}
	,__class__: de_polygonal_ds_IntHashTableIterator
};
var de_polygonal_ds_IntIntHashTable = function(slotCount,initialCapacity) {
	if(initialCapacity == null) initialCapacity = -1;
	this.mTmpBufferSize = 16;
	this.mSize = 0;
	this.mFree = 0;
	this.reuseIterator = false;
	this.growthRate = -3;
	this.key = de_polygonal_ds_HashKey._counter++;
	if(initialCapacity == -1) initialCapacity = slotCount; else {
	}
	this.capacity = initialCapacity;
	this.mMinCapacity = initialCapacity;
	this.slotCount = slotCount;
	this.mMask = slotCount - 1;
	this.mHash = de_polygonal_ds_tools_NativeArrayTools.init(new Array(slotCount),-1);
	this.mData = new Array(this.capacity * 3);
	this.mNext = new Array(this.capacity);
	var j = 2;
	var t = this.mData;
	var _g1 = 0;
	var _g = this.capacity;
	while(_g1 < _g) {
		var i = _g1++;
		t[j - 1] = -2147483648;
		t[j] = -1;
		j += 3;
	}
	t = this.mNext;
	var _g11 = 0;
	var _g2 = this.capacity - 1;
	while(_g11 < _g2) {
		var i1 = _g11++;
		t[i1] = i1 + 1;
	}
	t[this.capacity - 1] = -1;
	this.mTmpBuffer = new Array(this.mTmpBufferSize);
};
$hxClasses["de.polygonal.ds.IntIntHashTable"] = de_polygonal_ds_IntIntHashTable;
de_polygonal_ds_IntIntHashTable.__name__ = ["de","polygonal","ds","IntIntHashTable"];
de_polygonal_ds_IntIntHashTable.__interfaces__ = [de_polygonal_ds_Map];
de_polygonal_ds_IntIntHashTable.prototype = {
	key: null
	,capacity: null
	,growthRate: null
	,reuseIterator: null
	,get_loadFactor: function() {
		return this.mSize / this.slotCount;
	}
	,slotCount: null
	,mHash: null
	,mData: null
	,mNext: null
	,mMask: null
	,mFree: null
	,mSize: null
	,mMinCapacity: null
	,mIterator: null
	,mTmpBuffer: null
	,mTmpBufferSize: null
	,getCollisionCount: function() {
		var c = 0;
		var j;
		var d = this.mData;
		var h = this.mHash;
		var _g1 = 0;
		var _g = this.slotCount;
		while(_g1 < _g) {
			var i = _g1++;
			j = h[i];
			if(j == -1) continue;
			j = d[j + 2];
			while(j != -1) {
				j = d[j + 2];
				c++;
			}
		}
		return c;
	}
	,getFront: function(key) {
		var b = key * 73856093 & this.mMask;
		var i = this.mHash[b];
		if(i == -1) return -2147483648; else {
			var d = this.mData;
			if(d[i] == key) return d[i + 1]; else {
				var v = -2147483648;
				var first = i;
				var i0 = first;
				i = d[i + 2];
				while(i != -1) {
					if(d[i] == key) {
						v = d[i + 1];
						d[i0 + 2] = d[i + 2];
						d[i + 2] = first;
						this.mHash[b] = i;
						break;
					}
					i = de_polygonal_ds_tools_NativeArrayTools.get(d,(i0 = i) + 2);
				}
				return v;
			}
		}
	}
	,setIfAbsent: function(key,val) {
		var b = key * 73856093 & this.mMask;
		var d = this.mData;
		var j = this.mHash[b];
		if(j == -1) {
			if(this.mSize == this.capacity) {
				this.grow();
				d = this.mData;
			}
			var i = this.mFree * 3;
			this.mFree = this.mNext[this.mFree];
			this.mHash[b] = i;
			d[i] = key;
			d[i + 1] = val;
			this.mSize++;
			return true;
		} else if(d[j] == key) return false; else {
			var t = d[j + 2];
			while(t != -1) {
				if(d[t] == key) {
					j = -1;
					break;
				}
				t = de_polygonal_ds_tools_NativeArrayTools.get(d,(j = t) + 2);
			}
			if(j == -1) return false; else {
				if(this.mSize == this.capacity) {
					this.grow();
					d = this.mData;
				}
				var i1 = this.mFree * 3;
				this.mFree = this.mNext[this.mFree];
				d[j + 2] = i1;
				d[i1] = key;
				d[i1 + 1] = val;
				this.mSize++;
				return true;
			}
		}
	}
	,rehash: function(slotCount) {
		if(this.slotCount == slotCount) return;
		var t = new de_polygonal_ds_IntIntHashTable(slotCount,this.capacity);
		var d = this.mData;
		var _g1 = 0;
		var _g = this.capacity;
		while(_g1 < _g) {
			var i = _g1++;
			var v = d[i * 3 + 1];
			if(v != -2147483648) t.set(d[i * 3],v);
		}
		this.mHash = t.mHash;
		this.mData = t.mData;
		this.mNext = t.mNext;
		this.slotCount = slotCount;
		this.mMask = t.mMask;
		this.mFree = t.mFree;
	}
	,remap: function(key,val) {
		var i = this.mHash[key * 73856093 & this.mMask];
		if(i == -1) return false; else {
			var d = this.mData;
			if(d[i] == key) {
				d[i + 1] = val;
				return true;
			} else {
				i = d[i + 2];
				while(i != -1) {
					if(d[i] == key) {
						d[i + 1] = val;
						break;
					}
					i = d[i + 2];
				}
				return i != -1;
			}
		}
	}
	,extract: function(key) {
		var b = key * 73856093 & this.mMask;
		var h = this.mHash;
		var i = h[b];
		if(i == -1) return -2147483648; else {
			var d = this.mData;
			if(key == d[i]) {
				var val = d[i + 1];
				if(d[i + 2] == -1) h[b] = -1; else h[b] = d[i + 2];
				var j = i / 3 | 0;
				this.mNext[j] = this.mFree;
				this.mFree = j;
				d[i + 1] = -2147483648;
				d[i + 2] = -1;
				this.mSize--;
				return val;
			} else {
				var i0 = i;
				i = d[i + 2];
				var val1 = -2147483648;
				while(i != -1) {
					if(d[i] == key) {
						val1 = d[i + 1];
						break;
					}
					i = de_polygonal_ds_tools_NativeArrayTools.get(d,(i0 = i) + 2);
				}
				if(val1 != -2147483648) {
					d[i0 + 2] = d[i + 2];
					var j1 = i / 3 | 0;
					this.mNext[j1] = this.mFree;
					this.mFree = j1;
					d[i + 1] = -2147483648;
					d[i + 2] = -1;
					this.mSize--;
					return val1;
				} else return -2147483648;
			}
		}
	}
	,toKeyArray: function() {
		if(this.mSize == 0) return [];
		var out = de_polygonal_ds_tools_ArrayTools.alloc(this.mSize);
		var j = 0;
		var o;
		var d = this.mData;
		var _g1 = 0;
		var _g = this.capacity;
		while(_g1 < _g) {
			var i = _g1++;
			if(d[i * 3 + 1] != -2147483648) out[j++] = d[i * 3];
		}
		return out;
	}
	,toString: function() {
		var b = new StringBuf();
		b.add(de_polygonal_Printf.format("{ IntIntHashTable size/capacity: %d/%d, load factor: %.2f }",[this.mSize,this.capacity,this.get_loadFactor()]));
		if(this.mSize == 0) return b.b;
		b.b += "\n[\n";
		var max = 0.;
		var $it0 = this.keys();
		while( $it0.hasNext() ) {
			var key = $it0.next();
			max = Math.max(max,key);
		}
		var i = 1;
		while(max != 0) {
			i++;
			max = max / 10 | 0;
		}
		var args = [];
		var fmt = "  %- " + i + "d -> %d\n";
		var $it1 = this.keys();
		while( $it1.hasNext() ) {
			var key1 = $it1.next();
			args[0] = key1;
			args[1] = this.get(key1);
			b.add(de_polygonal_Printf.format(fmt,args));
		}
		b.b += "]";
		return b.b;
	}
	,has: function(val) {
		var exists = false;
		var d = this.mData;
		var _g1 = 0;
		var _g = this.capacity;
		while(_g1 < _g) {
			var i = _g1++;
			var v = d[i * 3 + 1];
			if(v == val) {
				exists = true;
				break;
			}
		}
		return exists;
	}
	,hasKey: function(key) {
		var i = this.mHash[key * 73856093 & this.mMask];
		if(i == -1) return false; else {
			var d = this.mData;
			if(d[i] == key) return true; else {
				var exists = false;
				i = d[i + 2];
				while(i != -1) {
					if(d[i] == key) {
						exists = true;
						break;
					}
					i = d[i + 2];
				}
				return exists;
			}
		}
	}
	,count: function(key) {
		var c = 0;
		var i = this.mHash[key * 73856093 & this.mMask];
		if(i == -1) return c; else {
			var d = this.mData;
			while(i != -1) {
				if(d[i] == key) c++;
				i = d[i + 2];
			}
			return c;
		}
	}
	,get: function(key) {
		var i = this.mHash[key * 73856093 & this.mMask];
		if(i == -1) return -2147483648; else {
			var d = this.mData;
			if(d[i] == key) return d[i + 1]; else {
				var v = -2147483648;
				i = d[i + 2];
				while(i != -1) {
					if(d[i] == key) {
						v = d[i + 1];
						break;
					}
					i = d[i + 2];
				}
				return v;
			}
		}
	}
	,getAll: function(key,out) {
		var i = this.mHash[key * 73856093 & this.mMask];
		if(i == -1) return 0; else {
			var c = 0;
			var d = this.mData;
			if(d[i] == key) out[c++] = d[i + 1];
			i = d[i + 2];
			while(i != -1) {
				if(d[i] == key) out[c++] = d[i + 1];
				i = d[i + 2];
			}
			return c;
		}
	}
	,hasPair: function(key,val) {
		var i = this.mHash[key * 73856093 & this.mMask];
		if(i == -1) return false; else {
			var d = this.mData;
			if(d[i] == key) {
				if(d[i + 1] == val) return true;
			}
			i = d[i + 2];
			while(i != -1) {
				if(d[i] == key) {
					if(d[i + 1] == val) return true;
				}
				i = d[i + 2];
			}
			return false;
		}
	}
	,clrPair: function(key,val) {
		var b = key * 73856093 & this.mMask;
		var h = this.mHash;
		var i = h[b];
		if(i == -1) return false; else {
			var d = this.mData;
			if(key == d[i] && val == d[i + 1]) {
				if(d[i + 2] == -1) h[b] = -1; else h[b] = d[i + 2];
				var j = i / 3 | 0;
				this.mNext[j] = this.mFree;
				this.mFree = j;
				d[i + 1] = -2147483648;
				d[i + 2] = -1;
				this.mSize--;
				return true;
			} else {
				var exists = false;
				var i0 = i;
				i = d[i + 2];
				while(i != -1) {
					if(d[i] == key && d[i + 1] == val) {
						exists = true;
						break;
					}
					i = de_polygonal_ds_tools_NativeArrayTools.get(d,(i0 = i) + 2);
				}
				if(exists) {
					d[i0 + 2] = d[i + 2];
					var j1 = i / 3 | 0;
					this.mNext[j1] = this.mFree;
					this.mFree = j1;
					d[i + 1] = -2147483648;
					d[i + 2] = -1;
					--this.mSize;
					return true;
				} else return false;
			}
		}
	}
	,set: function(key,val) {
		if(this.mSize == this.capacity) this.grow();
		var d = this.mData;
		var h = this.mHash;
		var i = this.mFree * 3;
		this.mFree = this.mNext[this.mFree];
		d[i] = key;
		d[i + 1] = val;
		var b = key * 73856093 & this.mMask;
		var j = h[b];
		if(j == -1) {
			h[b] = i;
			this.mSize++;
			return true;
		} else {
			var first = d[j] != key;
			var t = d[j + 2];
			while(t != -1) {
				if(d[t] == key) first = false;
				j = t;
				t = d[t + 2];
			}
			d[j + 2] = i;
			this.mSize++;
			return first;
		}
	}
	,unset: function(key) {
		var b = key * 73856093 & this.mMask;
		var h = this.mHash;
		var i = h[b];
		if(i == -1) return false; else {
			var d = this.mData;
			if(key == d[i]) {
				if(d[i + 2] == -1) h[b] = -1; else h[b] = d[i + 2];
				var j = i / 3 | 0;
				this.mNext[j] = this.mFree;
				this.mFree = j;
				d[i + 1] = -2147483648;
				d[i + 2] = -1;
				this.mSize--;
				return true;
			} else {
				var exists = false;
				var i0 = i;
				i = d[i + 2];
				while(i != -1) {
					if(d[i] == key) {
						exists = true;
						break;
					}
					i = de_polygonal_ds_tools_NativeArrayTools.get(d,(i0 = i) + 2);
				}
				if(exists) {
					d[i0 + 2] = d[i + 2];
					var j1 = i / 3 | 0;
					this.mNext[j1] = this.mFree;
					this.mFree = j1;
					d[i + 1] = -2147483648;
					d[i + 2] = -1;
					this.mSize--;
					return true;
				} else return false;
			}
		}
	}
	,toValSet: function() {
		var s = new de_polygonal_ds_IntHashSet(this.capacity);
		var d = this.mData;
		var _g1 = 0;
		var _g = this.capacity;
		while(_g1 < _g) {
			var i = _g1++;
			var v = d[i * 3 + 1];
			if(v != -2147483648) s.set(v);
		}
		return s;
	}
	,toKeySet: function() {
		var s = new de_polygonal_ds_IntHashSet(this.capacity);
		var d = this.mData;
		var _g1 = 0;
		var _g = this.capacity;
		while(_g1 < _g) {
			var i = _g1++;
			var v = d[i * 3 + 1];
			if(v != -2147483648) s.set(d[i * 3]);
		}
		return s;
	}
	,keys: function() {
		return new de_polygonal_ds_IntIntHashTableKeyIterator(this);
	}
	,pack: function() {
		if(this.capacity == this.mMinCapacity) return this;
		var oldCapacity = this.capacity;
		var x = this.mSize;
		var y = this.mMinCapacity;
		if(x > y) this.capacity = x; else this.capacity = y;
		var src = this.mData;
		var dst;
		var e = 0;
		var t = this.mHash;
		var j;
		dst = new Array(this.capacity * 3);
		var j1 = 2;
		var _g1 = 0;
		var _g = this.capacity;
		while(_g1 < _g) {
			var i = _g1++;
			dst[j1 - 1] = -2147483648;
			dst[j1] = -1;
			j1 += 3;
		}
		var _g11 = 0;
		var _g2 = this.slotCount;
		while(_g11 < _g2) {
			var i1 = _g11++;
			j1 = t[i1];
			if(j1 == -1) continue;
			t[i1] = e;
			dst[e] = src[j1];
			dst[e + 1] = src[j1 + 1];
			dst[e + 2] = -1;
			e += 3;
			j1 = src[j1 + 2];
			while(j1 != -1) {
				dst[e - 1] = e;
				dst[e] = src[j1];
				dst[e + 1] = src[j1 + 1];
				dst[e + 2] = -1;
				e += 3;
				j1 = src[j1 + 2];
			}
		}
		this.mData = dst;
		this.mNext = new Array(this.capacity);
		var n = this.mNext;
		var _g12 = 0;
		var _g3 = this.capacity - 1;
		while(_g12 < _g3) {
			var i2 = _g12++;
			n[i2] = i2 + 1;
		}
		n[this.capacity - 1] = -1;
		this.mFree = -1;
		return this;
	}
	,hashCode: function(x) {
		return x * 73856093 & this.mMask;
	}
	,grow: function() {
		var oldCapacity = this.capacity;
		this.capacity = de_polygonal_ds_tools_GrowthRate.compute(this.growthRate,this.capacity);
		var t;
		t = new Array(this.capacity);
		de_polygonal_ds_tools_NativeArrayTools.blit(this.mNext,0,t,0,oldCapacity);
		this.mNext = t;
		t = new Array(this.capacity * 3);
		de_polygonal_ds_tools_NativeArrayTools.blit(this.mData,0,t,0,oldCapacity * 3);
		this.mData = t;
		t = this.mNext;
		var _g1 = oldCapacity - 1;
		var _g = this.capacity - 1;
		while(_g1 < _g) {
			var i = _g1++;
			t[i] = i + 1;
		}
		t[this.capacity - 1] = -1;
		this.mFree = oldCapacity;
		var j = oldCapacity * 3 + 2;
		var t1 = this.mData;
		var _g11 = 0;
		var _g2 = this.capacity - oldCapacity;
		while(_g11 < _g2) {
			var i1 = _g11++;
			t1[j - 1] = -2147483648;
			t1[j] = -1;
			j += 3;
		}
	}
	,get_size: function() {
		return this.mSize;
	}
	,free: function() {
		this.mHash = null;
		this.mData = null;
		this.mNext = null;
		if(this.mIterator != null) {
			this.mIterator.free();
			this.mIterator = null;
		}
		this.mTmpBuffer = null;
	}
	,contains: function(val) {
		return this.has(val);
	}
	,remove: function(val) {
		var c = 0;
		var keys = this.mTmpBuffer;
		var max = this.mTmpBufferSize;
		var d = this.mData;
		var j;
		var _g1 = 0;
		var _g = this.capacity;
		while(_g1 < _g) {
			var i = _g1++;
			j = i * 3;
			if(d[j + 1] == val) {
				if(c == max) {
					max <<= 1;
					this.mTmpBufferSize = max;
					var t = new Array(max);
					de_polygonal_ds_tools_NativeArrayTools.blit(this.mTmpBuffer,0,t,0,c);
					this.mTmpBuffer = keys = t;
				}
				de_polygonal_ds_tools_NativeArrayTools.set(keys,c++,d[j]);
			}
		}
		var _g2 = 0;
		while(_g2 < c) {
			var i1 = _g2++;
			this.unset(keys[i1]);
		}
		return c > 0;
	}
	,clear: function(gc) {
		if(gc == null) gc = false;
		var h = this.mHash;
		var _g1 = 0;
		var _g = this.slotCount;
		while(_g1 < _g) {
			var i = _g1++;
			h[i] = -1;
		}
		var j = 2;
		var t = this.mData;
		var _g11 = 0;
		var _g2 = this.capacity;
		while(_g11 < _g2) {
			var i1 = _g11++;
			t[j - 1] = -2147483648;
			t[j] = -1;
			j += 3;
		}
		t = this.mNext;
		var _g12 = 0;
		var _g3 = this.capacity - 1;
		while(_g12 < _g3) {
			var i2 = _g12++;
			t[i2] = i2 + 1;
		}
		t[this.capacity - 1] = -1;
		this.mFree = 0;
		this.mSize = 0;
	}
	,iterator: function() {
		if(this.reuseIterator) {
			if(this.mIterator == null) this.mIterator = new de_polygonal_ds_IntIntHashTableValIterator(this); else this.mIterator.reset();
			return this.mIterator;
		} else return new de_polygonal_ds_IntIntHashTableValIterator(this);
	}
	,isEmpty: function() {
		return this.mSize == 0;
	}
	,toArray: function() {
		if(this.mSize == 0) return [];
		var out = de_polygonal_ds_tools_ArrayTools.alloc(this.mSize);
		var j = 0;
		var v;
		var d = this.mData;
		var _g1 = 0;
		var _g = this.capacity;
		while(_g1 < _g) {
			var i = _g1++;
			v = d[i * 3 + 1];
			if(v != -2147483648) out[j++] = v;
		}
		return out;
	}
	,clone: function(assign,copier) {
		if(assign == null) assign = true;
		var c = new de_polygonal_ds_IntIntHashTable(this.slotCount,this.capacity);
		de_polygonal_ds_tools_NativeArrayTools.blit(this.mHash,0,c.mHash,0,this.slotCount);
		de_polygonal_ds_tools_NativeArrayTools.blit(this.mData,0,c.mData,0,this.capacity * 3);
		de_polygonal_ds_tools_NativeArrayTools.blit(this.mNext,0,c.mNext,0,this.capacity);
		c.mMask = this.mMask;
		c.slotCount = this.slotCount;
		c.capacity = this.capacity;
		c.mFree = this.mFree;
		c.mSize = this.mSize;
		return c;
	}
	,__class__: de_polygonal_ds_IntIntHashTable
	,__properties__: {get_size:"get_size",get_loadFactor:"get_loadFactor"}
};
var de_polygonal_ds_IntIntHashTableValIterator = function(x) {
	this.mObject = x;
	this.mData = x.mData;
	this.mI = 0;
	this.mS = x.capacity;
	this.scan();
};
$hxClasses["de.polygonal.ds.IntIntHashTableValIterator"] = de_polygonal_ds_IntIntHashTableValIterator;
de_polygonal_ds_IntIntHashTableValIterator.__name__ = ["de","polygonal","ds","IntIntHashTableValIterator"];
de_polygonal_ds_IntIntHashTableValIterator.__interfaces__ = [de_polygonal_ds_Itr];
de_polygonal_ds_IntIntHashTableValIterator.prototype = {
	mObject: null
	,mI: null
	,mS: null
	,mData: null
	,free: function() {
		this.mObject = null;
		this.mData = null;
	}
	,reset: function() {
		this.mData = this.mObject.mData;
		this.mI = 0;
		this.mS = this.mObject.capacity;
		this.scan();
		return this;
	}
	,hasNext: function() {
		return this.mI < this.mS;
	}
	,next: function() {
		var val = de_polygonal_ds_tools_NativeArrayTools.get(this.mData,this.mI++ * 3 + 1);
		this.scan();
		return val;
	}
	,remove: function() {
		throw new js__$Boot_HaxeError("unsupported operation");
	}
	,scan: function() {
		while(this.mI < this.mS && this.mData[this.mI * 3 + 1] == -2147483648) this.mI++;
	}
	,__class__: de_polygonal_ds_IntIntHashTableValIterator
};
var de_polygonal_ds_IntIntHashTableKeyIterator = function(x) {
	this.mObject = x;
	this.mData = x.mData;
	this.mI = 0;
	this.mS = x.capacity;
	this.scan();
};
$hxClasses["de.polygonal.ds.IntIntHashTableKeyIterator"] = de_polygonal_ds_IntIntHashTableKeyIterator;
de_polygonal_ds_IntIntHashTableKeyIterator.__name__ = ["de","polygonal","ds","IntIntHashTableKeyIterator"];
de_polygonal_ds_IntIntHashTableKeyIterator.__interfaces__ = [de_polygonal_ds_Itr];
de_polygonal_ds_IntIntHashTableKeyIterator.prototype = {
	mObject: null
	,mI: null
	,mS: null
	,mData: null
	,free: function() {
		this.mObject = null;
		this.mData = null;
	}
	,reset: function() {
		this.mData = this.mObject.mData;
		this.mI = 0;
		this.mS = this.mObject.capacity;
		this.scan();
		return this;
	}
	,hasNext: function() {
		return this.mI < this.mS;
	}
	,next: function() {
		var key = de_polygonal_ds_tools_NativeArrayTools.get(this.mData,this.mI++ * 3);
		this.scan();
		return key;
	}
	,remove: function() {
		throw new js__$Boot_HaxeError("unsupported operation");
	}
	,scan: function() {
		while(this.mI < this.mS && this.mData[this.mI * 3 + 1] == -2147483648) this.mI++;
	}
	,__class__: de_polygonal_ds_IntIntHashTableKeyIterator
};
var de_polygonal_ds_ListSet = function(initialCapacity,source) {
	if(initialCapacity == null) initialCapacity = 16;
	this.mIterator = null;
	this.mSize = 0;
	this.reuseIterator = false;
	this.growthRate = -2;
	this.key = de_polygonal_ds_HashKey._counter++;
	if(1 > initialCapacity) this.mInitialCapacity = 1; else this.mInitialCapacity = initialCapacity;
	this.capacity = this.mInitialCapacity;
	if(source != null) this.capacity = source.length;
	this.mData = new Array(this.capacity);
	if(source != null) {
		var _g = 0;
		while(_g < source.length) {
			var i = source[_g];
			++_g;
			this.set(i);
		}
	}
};
$hxClasses["de.polygonal.ds.ListSet"] = de_polygonal_ds_ListSet;
de_polygonal_ds_ListSet.__name__ = ["de","polygonal","ds","ListSet"];
de_polygonal_ds_ListSet.__interfaces__ = [de_polygonal_ds_Set];
de_polygonal_ds_ListSet.prototype = {
	key: null
	,capacity: null
	,growthRate: null
	,reuseIterator: null
	,mData: null
	,mInitialCapacity: null
	,mSize: null
	,mIterator: null
	,reserve: function(n) {
		if(n > this.capacity) {
			this.capacity = n;
			this.resizeContainer(n);
		}
		return this;
	}
	,pack: function() {
		if(this.capacity > this.mInitialCapacity) {
			var x = this.mInitialCapacity;
			var y = this.mSize;
			if(x > y) this.capacity = x; else this.capacity = y;
			this.resizeContainer(this.capacity);
		} else {
			var d = this.mData;
			var _g1 = this.mSize;
			var _g = this.capacity;
			while(_g1 < _g) {
				var i = _g1++;
				d[i] = null;
			}
		}
		return this;
	}
	,toString: function() {
		var b_b = "";
		b_b += Std.string("{ ListSet size: " + this.mSize + " }");
		if(this.isEmpty()) return b_b;
		b_b += "\n[\n";
		var _g1 = 0;
		var _g = this.mSize;
		while(_g1 < _g) {
			var i = _g1++;
			b_b += Std.string("  " + Std.string(this.mData[i]) + "\n");
		}
		b_b += "]";
		return b_b;
	}
	,has: function(x) {
		if(this.isEmpty()) return false;
		var d = this.mData;
		var _g1 = 0;
		var _g = this.mSize;
		while(_g1 < _g) {
			var i = _g1++;
			if(d[i] == x) return true;
		}
		return false;
	}
	,set: function(x) {
		var d = this.mData;
		var _g1 = 0;
		var _g = this.mSize;
		while(_g1 < _g) {
			var i = _g1++;
			if(d[i] == x) return false;
		}
		if(this.mSize == this.capacity) {
			this.grow();
			d = this.mData;
		}
		de_polygonal_ds_tools_NativeArrayTools.set(d,this.mSize++,x);
		return true;
	}
	,unset: function(x) {
		return this.remove(x);
	}
	,merge: function(x,assign,copier) {
		if(assign) {
			var $it0 = x.iterator();
			while( $it0.hasNext() ) {
				var val = $it0.next();
				this.set(val);
			}
		} else if(copier != null) {
			var $it1 = x.iterator();
			while( $it1.hasNext() ) {
				var val1 = $it1.next();
				this.set(copier(val1));
			}
		} else {
			var $it2 = x.iterator();
			while( $it2.hasNext() ) {
				var val2 = $it2.next();
				this.set((js_Boot.__cast(val2 , de_polygonal_ds_Cloneable)).clone());
			}
		}
	}
	,get_size: function() {
		return this.mSize;
	}
	,free: function() {
		de_polygonal_ds_tools_NativeArrayTools.nullify(this.mData);
		this.mData = null;
		if(this.mIterator != null) {
			this.mIterator.free();
			this.mIterator = null;
		}
	}
	,contains: function(x) {
		return this.has(x);
	}
	,remove: function(x) {
		var d = this.mData;
		var _g1 = 0;
		var _g = this.mSize;
		while(_g1 < _g) {
			var i = _g1++;
			if(d[i] == x) {
				de_polygonal_ds_tools_NativeArrayTools.set(d,i,de_polygonal_ds_tools_NativeArrayTools.get(this.mData,--this.mSize));
				return true;
			}
		}
		return false;
	}
	,clear: function(gc) {
		if(gc == null) gc = false;
		if(gc) de_polygonal_ds_tools_NativeArrayTools.nullify(this.mData);
		this.mSize = 0;
	}
	,iterator: function() {
		if(this.reuseIterator) {
			if(this.mIterator == null) this.mIterator = new de_polygonal_ds_ListSetIterator(this); else this.mIterator.reset();
			return this.mIterator;
		} else return new de_polygonal_ds_ListSetIterator(this);
	}
	,isEmpty: function() {
		return this.mSize == 0;
	}
	,toArray: function() {
		return de_polygonal_ds_tools_NativeArrayTools.toArray(this.mData,0,this.mSize);
	}
	,clone: function(assign,copier) {
		if(assign == null) assign = true;
		var out = new de_polygonal_ds_ListSet();
		out.capacity = this.mSize;
		out.mSize = this.mSize;
		out.mData = new Array(this.mSize);
		var src = this.mData;
		var dst = out.mData;
		if(assign) de_polygonal_ds_tools_NativeArrayTools.blit(src,0,dst,0,this.mSize); else if(copier == null) {
			var _g1 = 0;
			var _g = this.mSize;
			while(_g1 < _g) {
				var i = _g1++;
				de_polygonal_ds_tools_NativeArrayTools.set(dst,i,(js_Boot.__cast(src[i] , de_polygonal_ds_Cloneable)).clone());
			}
		} else {
			var _g11 = 0;
			var _g2 = this.mSize;
			while(_g11 < _g2) {
				var i1 = _g11++;
				de_polygonal_ds_tools_NativeArrayTools.set(dst,i1,copier(src[i1]));
			}
		}
		return out;
	}
	,grow: function() {
		this.capacity = de_polygonal_ds_tools_GrowthRate.compute(this.growthRate,this.capacity);
		this.resizeContainer(this.capacity);
	}
	,resizeContainer: function(newSize) {
		var t = new Array(newSize);
		de_polygonal_ds_tools_NativeArrayTools.blit(this.mData,0,t,0,this.mSize);
		this.mData = t;
	}
	,__class__: de_polygonal_ds_ListSet
	,__properties__: {get_size:"get_size"}
};
var de_polygonal_ds_ListSetIterator = function(x) {
	this.mObject = x;
	{
		this.mData = this.mObject.mData;
		this.mS = this.mObject.mSize;
		this.mI = 0;
		this;
	}
};
$hxClasses["de.polygonal.ds.ListSetIterator"] = de_polygonal_ds_ListSetIterator;
de_polygonal_ds_ListSetIterator.__name__ = ["de","polygonal","ds","ListSetIterator"];
de_polygonal_ds_ListSetIterator.__interfaces__ = [de_polygonal_ds_Itr];
de_polygonal_ds_ListSetIterator.prototype = {
	mObject: null
	,mData: null
	,mI: null
	,mS: null
	,free: function() {
		this.mObject = null;
		this.mData = null;
	}
	,reset: function() {
		this.mData = this.mObject.mData;
		this.mS = this.mObject.mSize;
		this.mI = 0;
		return this;
	}
	,hasNext: function() {
		return this.mI < this.mS;
	}
	,next: function() {
		return de_polygonal_ds_tools_NativeArrayTools.get(this.mData,this.mI++);
	}
	,remove: function() {
		de_polygonal_ds_tools_NativeArrayTools.set(this.mData,this.mI,de_polygonal_ds_tools_NativeArrayTools.get(this.mData,--this.mS));
	}
	,__class__: de_polygonal_ds_ListSetIterator
};
var de_polygonal_ds_tools_ArrayTools = function() { };
$hxClasses["de.polygonal.ds.tools.ArrayTools"] = de_polygonal_ds_tools_ArrayTools;
de_polygonal_ds_tools_ArrayTools.__name__ = ["de","polygonal","ds","tools","ArrayTools"];
de_polygonal_ds_tools_ArrayTools.alloc = function(x) {
	var a;
	a = new Array(x);
	return a;
};
de_polygonal_ds_tools_ArrayTools.shrink = function(a,x) {
	if(a.length > x) {
		a.length = x;
		return a;
	} else return a;
};
de_polygonal_ds_tools_ArrayTools.copy = function(source,destination,min,max) {
	if(max == null) max = -1;
	if(min == null) min = 0;
	if(max == -1) max = source.length;
	var j = 0;
	var _g = min;
	while(_g < max) {
		var i = _g++;
		destination[j++] = source[i];
	}
	return destination;
};
de_polygonal_ds_tools_ArrayTools.init = function(destination,x,k) {
	if(k == null) k = -1;
	if(k == -1) k = destination.length;
	var _g = 0;
	while(_g < k) {
		var i = _g++;
		destination[i] = x;
	}
};
de_polygonal_ds_tools_ArrayTools.memmove = function(a,destination,source,n) {
	if(source == destination) return; else if(source <= destination) {
		var i = source + n;
		var j = destination + n;
		var _g = 0;
		while(_g < n) {
			var k = _g++;
			i--;
			j--;
			a[j] = a[i];
		}
	} else {
		var i1 = source;
		var j1 = destination;
		var _g1 = 0;
		while(_g1 < n) {
			var k1 = _g1++;
			a[j1] = a[i1];
			i1++;
			j1++;
		}
	}
};
de_polygonal_ds_tools_ArrayTools.bsearchComparator = function(a,x,min,max,comparator) {
	var l = min;
	var m;
	var h = max + 1;
	while(l < h) {
		m = l + (h - l >> 1);
		if(comparator(a[m],x) < 0) l = m + 1; else h = m;
	}
	if(l <= max && comparator(a[l],x) == 0) return l; else return ~l;
};
de_polygonal_ds_tools_ArrayTools.bsearchInt = function(a,x,min,max) {
	var l = min;
	var m;
	var h = max + 1;
	while(l < h) {
		m = l + (h - l >> 1);
		if(a[m] < x) l = m + 1; else h = m;
	}
	if(l <= max && a[l] == x) return l; else return ~l;
};
de_polygonal_ds_tools_ArrayTools.bsearchFloat = function(a,x,min,max) {
	var l = min;
	var m;
	var h = max + 1;
	while(l < h) {
		m = l + (h - l >> 1);
		if(a[m] < x) l = m + 1; else h = m;
	}
	if(l <= max && a[l] == x) return l; else return ~l;
};
de_polygonal_ds_tools_ArrayTools.shuffle = function(a,rvals) {
	var s = a.length;
	if(rvals == null) {
		var m = Math;
		while(--s > 1) {
			var i = Std["int"](m.random() * s);
			var t = a[s];
			a[s] = a[i];
			a[i] = t;
		}
	} else {
		var j = 0;
		while(--s > 1) {
			var i1 = Std["int"](rvals[j++] * s);
			var t1 = a[s];
			a[s] = a[i1];
			a[i1] = t1;
		}
	}
};
de_polygonal_ds_tools_ArrayTools.sortRange = function(a,compare,useInsertionSort,first,count) {
	var k = a.length;
	if(k > 1) {
		if(useInsertionSort) de_polygonal_ds_tools_ArrayTools._insertionSort(a,first,count,compare); else de_polygonal_ds_tools_ArrayTools._quickSort(a,first,count,compare);
	}
};
de_polygonal_ds_tools_ArrayTools.quickPerm = function(n) {
	var results = [];
	var a = [];
	var p = [];
	var i;
	var j;
	var t;
	var _g = 0;
	while(_g < n) {
		var i1 = _g++;
		a[i1] = i1 + 1;
		p[i1] = 0;
	}
	results.push(a.slice());
	i = 1;
	while(i < n) if(p[i] < i) {
		j = i % 2 * p[i];
		t = a[j];
		a[j] = a[i];
		a[i] = t;
		results.push(a.slice());
		p[i]++;
		i = 1;
	} else {
		p[i] = 0;
		i++;
	}
	return results;
};
de_polygonal_ds_tools_ArrayTools.equals = function(a,b) {
	if(a.length != b.length) return false;
	var _g1 = 0;
	var _g = a.length;
	while(_g1 < _g) {
		var i = _g1++;
		if(a[i] != b[i]) return false;
	}
	return true;
};
de_polygonal_ds_tools_ArrayTools.split = function(a,n,k) {
	var out = [];
	var b = null;
	var _g = 0;
	while(_g < n) {
		var i = _g++;
		if(i % k == 0) out[i / k | 0] = b = [];
		b.push(a[i]);
	}
	return out;
};
de_polygonal_ds_tools_ArrayTools._insertionSort = function(a,first,k,cmp) {
	var _g1 = first + 1;
	var _g = first + k;
	while(_g1 < _g) {
		var i = _g1++;
		var x = a[i];
		var j = i;
		while(j > first) {
			var y = a[j - 1];
			if(cmp(y,x) > 0) {
				a[j] = y;
				j--;
			} else break;
		}
		a[j] = x;
	}
};
de_polygonal_ds_tools_ArrayTools._quickSort = function(a,first,k,cmp) {
	var last = first + k - 1;
	var lo = first;
	var hi = last;
	if(k > 1) {
		var i0 = first;
		var i1 = i0 + (k >> 1);
		var i2 = i0 + k - 1;
		var t0 = a[i0];
		var t1 = a[i1];
		var t2 = a[i2];
		var mid;
		var t = cmp(t0,t2);
		if(t < 0 && cmp(t0,t1) < 0) if(cmp(t1,t2) < 0) mid = i1; else mid = i2; else if(cmp(t1,t0) < 0 && cmp(t1,t2) < 0) if(t < 0) mid = i0; else mid = i2; else if(cmp(t2,t0) < 0) mid = i1; else mid = i0;
		var pivot = a[mid];
		a[mid] = a[first];
		while(lo < hi) {
			while(cmp(pivot,a[hi]) < 0 && lo < hi) hi--;
			if(hi != lo) {
				a[lo] = a[hi];
				lo++;
			}
			while(cmp(pivot,a[lo]) > 0 && lo < hi) lo++;
			if(hi != lo) {
				a[hi] = a[lo];
				hi--;
			}
		}
		a[lo] = pivot;
		de_polygonal_ds_tools_ArrayTools._quickSort(a,first,lo - first,cmp);
		de_polygonal_ds_tools_ArrayTools._quickSort(a,lo + 1,last - lo,cmp);
	}
};
var de_polygonal_ds_tools_Assert = function() { };
$hxClasses["de.polygonal.ds.tools.Assert"] = de_polygonal_ds_tools_Assert;
de_polygonal_ds_tools_Assert.__name__ = ["de","polygonal","ds","tools","Assert"];
var de_polygonal_ds_tools_GrowthRate = function() { };
$hxClasses["de.polygonal.ds.tools.GrowthRate"] = de_polygonal_ds_tools_GrowthRate;
de_polygonal_ds_tools_GrowthRate.__name__ = ["de","polygonal","ds","tools","GrowthRate"];
de_polygonal_ds_tools_GrowthRate.compute = function(rate,capacity) {
	if(rate > 0) capacity += rate; else switch(rate) {
	case 0:
		throw new js__$Boot_HaxeError("out of space");
		break;
	case -1:
		var newSize = capacity + 1;
		capacity = (newSize >> 3) + (newSize < 9?3:6);
		capacity += newSize;
		break;
	case -2:
		capacity = (capacity * 3 >> 1) + 1;
		break;
	case -3:
		capacity <<= 1;
		break;
	}
	return capacity;
};
var de_polygonal_ds_tools_NativeArrayTools = function() { };
$hxClasses["de.polygonal.ds.tools.NativeArrayTools"] = de_polygonal_ds_tools_NativeArrayTools;
de_polygonal_ds_tools_NativeArrayTools.__name__ = ["de","polygonal","ds","tools","NativeArrayTools"];
de_polygonal_ds_tools_NativeArrayTools.alloc = function(len) {
	return new Array(len);
};
de_polygonal_ds_tools_NativeArrayTools.get = function(x,i) {
	return x[i];
};
de_polygonal_ds_tools_NativeArrayTools.set = function(x,i,v) {
	x[i] = v;
};
de_polygonal_ds_tools_NativeArrayTools.size = function(x) {
	return x.length;
};
de_polygonal_ds_tools_NativeArrayTools.toArray = function(x,first,count) {
	if(count == 0) return [];
	var out = de_polygonal_ds_tools_ArrayTools.alloc(count);
	if(first == 0) {
		var _g = 0;
		while(_g < count) {
			var i = _g++;
			out[i] = x[i];
		}
	} else {
		var j;
		var _g1 = first;
		var _g2 = first + count;
		while(_g1 < _g2) {
			var i1 = _g1++;
			out[i1 - first] = x[i1];
		}
	}
	return out;
};
de_polygonal_ds_tools_NativeArrayTools.ofArray = function(x) {
	return x.slice(0,x.length);
};
de_polygonal_ds_tools_NativeArrayTools.blit = function(src,srcPos,dst,dstPos,len) {
	if(len > 0) {
		if(src == dst) {
			if(srcPos < dstPos) {
				var i = srcPos + len;
				var j = dstPos + len;
				var _g = 0;
				while(_g < len) {
					var k = _g++;
					i--;
					j--;
					src[j] = src[i];
				}
			} else if(srcPos > dstPos) {
				var i1 = srcPos;
				var j1 = dstPos;
				var _g1 = 0;
				while(_g1 < len) {
					var k1 = _g1++;
					src[j1] = src[i1];
					i1++;
					j1++;
				}
			}
		} else if(srcPos == 0 && dstPos == 0) {
			var _g2 = 0;
			while(_g2 < len) {
				var i2 = _g2++;
				dst[i2] = src[i2];
			}
		} else if(srcPos == 0) {
			var _g3 = 0;
			while(_g3 < len) {
				var i3 = _g3++;
				dst[dstPos + i3] = src[i3];
			}
		} else if(dstPos == 0) {
			var _g4 = 0;
			while(_g4 < len) {
				var i4 = _g4++;
				dst[i4] = src[srcPos + i4];
			}
		} else {
			var _g5 = 0;
			while(_g5 < len) {
				var i5 = _g5++;
				dst[dstPos + i5] = src[srcPos + i5];
			}
		}
	}
};
de_polygonal_ds_tools_NativeArrayTools.copy = function(src) {
	return src.slice(0);
};
de_polygonal_ds_tools_NativeArrayTools.zero = function(dst,first,len) {
	var val = 0;
	var _g1 = first;
	var _g = first + len;
	while(_g1 < _g) {
		var i = _g1++;
		dst[i] = val;
	}
	return dst;
};
de_polygonal_ds_tools_NativeArrayTools.init = function(dst,x,first,k) {
	if(first == null) first = 0;
	if(k == null) k = dst.length;
	var _g1 = first;
	var _g = first + k;
	while(_g1 < _g) {
		var i = _g1++;
		dst[i] = x;
	}
	return dst;
};
de_polygonal_ds_tools_NativeArrayTools.nullify = function(dst,count) {
	if(count == null) count = 0;
	if(count == 0) count = dst.length;
	var _g = 0;
	while(_g < count) {
		var i = _g++;
		dst[i] = null;
	}
};
de_polygonal_ds_tools_NativeArrayTools.binarySearchCmp = function(v,x,min,max,cmp) {
	var l = min;
	var m;
	var h = max + 1;
	while(l < h) {
		m = l + (h - l >> 1);
		if(cmp(v[m],x) < 0) l = m + 1; else h = m;
	}
	if(l <= max && cmp(v[l],x) == 0) return l; else return ~l;
};
de_polygonal_ds_tools_NativeArrayTools.binarySearchf = function(v,x,min,max) {
	var l = min;
	var m;
	var h = max + 1;
	while(l < h) {
		m = l + (h - l >> 1);
		if(v[m] < x) l = m + 1; else h = m;
	}
	if(l <= max && v[l] == x) return l; else return ~l;
};
de_polygonal_ds_tools_NativeArrayTools.binarySearchi = function(v,x,min,max) {
	var l = min;
	var m;
	var h = max + 1;
	while(l < h) {
		m = l + (h - l >> 1);
		if(v[m] < x) l = m + 1; else h = m;
	}
	if(l <= max && v[l] == x) return l; else return ~l;
};
var haxe_IMap = function() { };
$hxClasses["haxe.IMap"] = haxe_IMap;
haxe_IMap.__name__ = ["haxe","IMap"];
haxe_IMap.prototype = {
	get: null
	,keys: null
	,__class__: haxe_IMap
};
var haxe__$Int32_Int32_$Impl_$ = {};
$hxClasses["haxe._Int32.Int32_Impl_"] = haxe__$Int32_Int32_$Impl_$;
haxe__$Int32_Int32_$Impl_$.__name__ = ["haxe","_Int32","Int32_Impl_"];
haxe__$Int32_Int32_$Impl_$.ucompare = function(a,b) {
	if(a < 0) if(b < 0) return ~b - ~a | 0; else return 1;
	if(b < 0) return -1; else return a - b | 0;
};
var haxe__$Int64_Int64_$Impl_$ = {};
$hxClasses["haxe._Int64.Int64_Impl_"] = haxe__$Int64_Int64_$Impl_$;
haxe__$Int64_Int64_$Impl_$.__name__ = ["haxe","_Int64","Int64_Impl_"];
haxe__$Int64_Int64_$Impl_$.toString = function(this1) {
	var i = this1;
	if((function($this) {
		var $r;
		var b;
		{
			var x = new haxe__$Int64__$_$_$Int64(0,0);
			b = x;
		}
		$r = i.high == b.high && i.low == b.low;
		return $r;
	}(this))) return "0";
	var str = "";
	var neg = false;
	if(i.high < 0) {
		neg = true;
		var high = ~i.high;
		var low = -i.low;
		if(low == 0) {
			var ret = high++;
			high = high | 0;
			ret;
		}
		var x1 = new haxe__$Int64__$_$_$Int64(high,low);
		i = x1;
	}
	var ten;
	{
		var x2 = new haxe__$Int64__$_$_$Int64(0,10);
		ten = x2;
	}
	while((function($this) {
		var $r;
		var b1;
		{
			var x3 = new haxe__$Int64__$_$_$Int64(0,0);
			b1 = x3;
		}
		$r = i.high != b1.high || i.low != b1.low;
		return $r;
	}(this))) {
		var r = haxe__$Int64_Int64_$Impl_$.divMod(i,ten);
		str = r.modulus.low + str;
		i = r.quotient;
	}
	if(neg) str = "-" + str;
	return str;
};
haxe__$Int64_Int64_$Impl_$.divMod = function(dividend,divisor) {
	if(divisor.high == 0) {
		var _g = divisor.low;
		switch(_g) {
		case 0:
			throw new js__$Boot_HaxeError("divide by zero");
			break;
		case 1:
			return { quotient : (function($this) {
				var $r;
				var x = new haxe__$Int64__$_$_$Int64(dividend.high,dividend.low);
				$r = x;
				return $r;
			}(this)), modulus : (function($this) {
				var $r;
				var x1 = new haxe__$Int64__$_$_$Int64(0,0);
				$r = x1;
				return $r;
			}(this))};
		}
	}
	var divSign = dividend.high < 0 != divisor.high < 0;
	var modulus;
	if(dividend.high < 0) {
		var high = ~dividend.high;
		var low = -dividend.low;
		if(low == 0) {
			var ret = high++;
			high = high | 0;
			ret;
		}
		var x2 = new haxe__$Int64__$_$_$Int64(high,low);
		modulus = x2;
	} else {
		var x3 = new haxe__$Int64__$_$_$Int64(dividend.high,dividend.low);
		modulus = x3;
	}
	if(divisor.high < 0) {
		var high1 = ~divisor.high;
		var low1 = -divisor.low;
		if(low1 == 0) {
			var ret1 = high1++;
			high1 = high1 | 0;
			ret1;
		}
		var x4 = new haxe__$Int64__$_$_$Int64(high1,low1);
		divisor = x4;
	} else divisor = divisor;
	var quotient;
	{
		var x5 = new haxe__$Int64__$_$_$Int64(0,0);
		quotient = x5;
	}
	var mask;
	{
		var x6 = new haxe__$Int64__$_$_$Int64(0,1);
		mask = x6;
	}
	while(!(divisor.high < 0)) {
		var cmp;
		var v = haxe__$Int32_Int32_$Impl_$.ucompare(divisor.high,modulus.high);
		if(v != 0) cmp = v; else cmp = haxe__$Int32_Int32_$Impl_$.ucompare(divisor.low,modulus.low);
		var b = 1;
		b &= 63;
		if(b == 0) {
			var x7 = new haxe__$Int64__$_$_$Int64(divisor.high,divisor.low);
			divisor = x7;
		} else if(b < 32) {
			var x8 = new haxe__$Int64__$_$_$Int64(divisor.high << b | divisor.low >>> 32 - b,divisor.low << b);
			divisor = x8;
		} else {
			var x9 = new haxe__$Int64__$_$_$Int64(divisor.low << b - 32,0);
			divisor = x9;
		}
		var b1 = 1;
		b1 &= 63;
		if(b1 == 0) {
			var x10 = new haxe__$Int64__$_$_$Int64(mask.high,mask.low);
			mask = x10;
		} else if(b1 < 32) {
			var x11 = new haxe__$Int64__$_$_$Int64(mask.high << b1 | mask.low >>> 32 - b1,mask.low << b1);
			mask = x11;
		} else {
			var x12 = new haxe__$Int64__$_$_$Int64(mask.low << b1 - 32,0);
			mask = x12;
		}
		if(cmp >= 0) break;
	}
	while((function($this) {
		var $r;
		var b2;
		{
			var x13 = new haxe__$Int64__$_$_$Int64(0,0);
			b2 = x13;
		}
		$r = mask.high != b2.high || mask.low != b2.low;
		return $r;
	}(this))) {
		if((function($this) {
			var $r;
			var v1 = haxe__$Int32_Int32_$Impl_$.ucompare(modulus.high,divisor.high);
			$r = v1 != 0?v1:haxe__$Int32_Int32_$Impl_$.ucompare(modulus.low,divisor.low);
			return $r;
		}(this)) >= 0) {
			var x14 = new haxe__$Int64__$_$_$Int64(quotient.high | mask.high,quotient.low | mask.low);
			quotient = x14;
			var high2 = modulus.high - divisor.high | 0;
			var low2 = modulus.low - divisor.low | 0;
			if(haxe__$Int32_Int32_$Impl_$.ucompare(modulus.low,divisor.low) < 0) {
				var ret2 = high2--;
				high2 = high2 | 0;
				ret2;
			}
			var x15 = new haxe__$Int64__$_$_$Int64(high2,low2);
			modulus = x15;
		}
		var b3 = 1;
		b3 &= 63;
		if(b3 == 0) {
			var x16 = new haxe__$Int64__$_$_$Int64(mask.high,mask.low);
			mask = x16;
		} else if(b3 < 32) {
			var x17 = new haxe__$Int64__$_$_$Int64(mask.high >>> b3,mask.high << 32 - b3 | mask.low >>> b3);
			mask = x17;
		} else {
			var x18 = new haxe__$Int64__$_$_$Int64(0,mask.high >>> b3 - 32);
			mask = x18;
		}
		var b4 = 1;
		b4 &= 63;
		if(b4 == 0) {
			var x19 = new haxe__$Int64__$_$_$Int64(divisor.high,divisor.low);
			divisor = x19;
		} else if(b4 < 32) {
			var x20 = new haxe__$Int64__$_$_$Int64(divisor.high >>> b4,divisor.high << 32 - b4 | divisor.low >>> b4);
			divisor = x20;
		} else {
			var x21 = new haxe__$Int64__$_$_$Int64(0,divisor.high >>> b4 - 32);
			divisor = x21;
		}
	}
	if(divSign) {
		var high3 = ~quotient.high;
		var low3 = -quotient.low;
		if(low3 == 0) {
			var ret3 = high3++;
			high3 = high3 | 0;
			ret3;
		}
		var x22 = new haxe__$Int64__$_$_$Int64(high3,low3);
		quotient = x22;
	}
	if(dividend.high < 0) {
		var high4 = ~modulus.high;
		var low4 = -modulus.low;
		if(low4 == 0) {
			var ret4 = high4++;
			high4 = high4 | 0;
			ret4;
		}
		var x23 = new haxe__$Int64__$_$_$Int64(high4,low4);
		modulus = x23;
	}
	return { quotient : quotient, modulus : modulus};
};
var haxe__$Int64__$_$_$Int64 = function(high,low) {
	this.high = high;
	this.low = low;
};
$hxClasses["haxe._Int64.___Int64"] = haxe__$Int64__$_$_$Int64;
haxe__$Int64__$_$_$Int64.__name__ = ["haxe","_Int64","___Int64"];
haxe__$Int64__$_$_$Int64.prototype = {
	high: null
	,low: null
	,__class__: haxe__$Int64__$_$_$Int64
};
var haxe_Serializer = function() {
	this.buf = new StringBuf();
	this.cache = [];
	this.useCache = haxe_Serializer.USE_CACHE;
	this.useEnumIndex = haxe_Serializer.USE_ENUM_INDEX;
	this.shash = new haxe_ds_StringMap();
	this.scount = 0;
};
$hxClasses["haxe.Serializer"] = haxe_Serializer;
haxe_Serializer.__name__ = ["haxe","Serializer"];
haxe_Serializer.prototype = {
	buf: null
	,cache: null
	,shash: null
	,scount: null
	,useCache: null
	,useEnumIndex: null
	,toString: function() {
		return this.buf.b;
	}
	,serializeString: function(s) {
		var x = this.shash.get(s);
		if(x != null) {
			this.buf.b += "R";
			if(x == null) this.buf.b += "null"; else this.buf.b += "" + x;
			return;
		}
		this.shash.set(s,this.scount++);
		this.buf.b += "y";
		s = encodeURIComponent(s);
		if(s.length == null) this.buf.b += "null"; else this.buf.b += "" + s.length;
		this.buf.b += ":";
		if(s == null) this.buf.b += "null"; else this.buf.b += "" + s;
	}
	,serializeRef: function(v) {
		var vt = typeof(v);
		var _g1 = 0;
		var _g = this.cache.length;
		while(_g1 < _g) {
			var i = _g1++;
			var ci = this.cache[i];
			if(typeof(ci) == vt && ci == v) {
				this.buf.b += "r";
				if(i == null) this.buf.b += "null"; else this.buf.b += "" + i;
				return true;
			}
		}
		this.cache.push(v);
		return false;
	}
	,serializeFields: function(v) {
		var _g = 0;
		var _g1 = Reflect.fields(v);
		while(_g < _g1.length) {
			var f = _g1[_g];
			++_g;
			this.serializeString(f);
			this.serialize(Reflect.field(v,f));
		}
		this.buf.b += "g";
	}
	,serialize: function(v) {
		{
			var _g = Type["typeof"](v);
			switch(_g[1]) {
			case 0:
				this.buf.b += "n";
				break;
			case 1:
				var v1 = v;
				if(v1 == 0) {
					this.buf.b += "z";
					return;
				}
				this.buf.b += "i";
				if(v1 == null) this.buf.b += "null"; else this.buf.b += "" + v1;
				break;
			case 2:
				var v2 = v;
				if(isNaN(v2)) this.buf.b += "k"; else if(!isFinite(v2)) if(v2 < 0) this.buf.b += "m"; else this.buf.b += "p"; else {
					this.buf.b += "d";
					if(v2 == null) this.buf.b += "null"; else this.buf.b += "" + v2;
				}
				break;
			case 3:
				if(v) this.buf.b += "t"; else this.buf.b += "f";
				break;
			case 6:
				var c = _g[2];
				if(c == String) {
					this.serializeString(v);
					return;
				}
				if(this.useCache && this.serializeRef(v)) return;
				switch(c) {
				case Array:
					var ucount = 0;
					this.buf.b += "a";
					var l = v.length;
					var _g1 = 0;
					while(_g1 < l) {
						var i = _g1++;
						if(v[i] == null) ucount++; else {
							if(ucount > 0) {
								if(ucount == 1) this.buf.b += "n"; else {
									this.buf.b += "u";
									if(ucount == null) this.buf.b += "null"; else this.buf.b += "" + ucount;
								}
								ucount = 0;
							}
							this.serialize(v[i]);
						}
					}
					if(ucount > 0) {
						if(ucount == 1) this.buf.b += "n"; else {
							this.buf.b += "u";
							if(ucount == null) this.buf.b += "null"; else this.buf.b += "" + ucount;
						}
					}
					this.buf.b += "h";
					break;
				case List:
					this.buf.b += "l";
					var v3 = v;
					var _g1_head = v3.h;
					var _g1_val = null;
					while(_g1_head != null) {
						var i1;
						_g1_val = _g1_head[0];
						_g1_head = _g1_head[1];
						i1 = _g1_val;
						this.serialize(i1);
					}
					this.buf.b += "h";
					break;
				case Date:
					var d = v;
					this.buf.b += "v";
					this.buf.add(d.getTime());
					break;
				case haxe_ds_StringMap:
					this.buf.b += "b";
					var v4 = v;
					var $it0 = v4.keys();
					while( $it0.hasNext() ) {
						var k = $it0.next();
						this.serializeString(k);
						this.serialize(__map_reserved[k] != null?v4.getReserved(k):v4.h[k]);
					}
					this.buf.b += "h";
					break;
				case haxe_ds_IntMap:
					this.buf.b += "q";
					var v5 = v;
					var $it1 = v5.keys();
					while( $it1.hasNext() ) {
						var k1 = $it1.next();
						this.buf.b += ":";
						if(k1 == null) this.buf.b += "null"; else this.buf.b += "" + k1;
						this.serialize(v5.h[k1]);
					}
					this.buf.b += "h";
					break;
				case haxe_ds_ObjectMap:
					this.buf.b += "M";
					var v6 = v;
					var $it2 = v6.keys();
					while( $it2.hasNext() ) {
						var k2 = $it2.next();
						var id = Reflect.field(k2,"__id__");
						Reflect.deleteField(k2,"__id__");
						this.serialize(k2);
						k2.__id__ = id;
						this.serialize(v6.h[k2.__id__]);
					}
					this.buf.b += "h";
					break;
				case haxe_io_Bytes:
					var v7 = v;
					var i2 = 0;
					var max = v7.length - 2;
					var charsBuf = new StringBuf();
					var b64 = haxe_Serializer.BASE64;
					while(i2 < max) {
						var b1 = v7.get(i2++);
						var b2 = v7.get(i2++);
						var b3 = v7.get(i2++);
						charsBuf.add(b64.charAt(b1 >> 2));
						charsBuf.add(b64.charAt((b1 << 4 | b2 >> 4) & 63));
						charsBuf.add(b64.charAt((b2 << 2 | b3 >> 6) & 63));
						charsBuf.add(b64.charAt(b3 & 63));
					}
					if(i2 == max) {
						var b11 = v7.get(i2++);
						var b21 = v7.get(i2++);
						charsBuf.add(b64.charAt(b11 >> 2));
						charsBuf.add(b64.charAt((b11 << 4 | b21 >> 4) & 63));
						charsBuf.add(b64.charAt(b21 << 2 & 63));
					} else if(i2 == max + 1) {
						var b12 = v7.get(i2++);
						charsBuf.add(b64.charAt(b12 >> 2));
						charsBuf.add(b64.charAt(b12 << 4 & 63));
					}
					var chars = charsBuf.b;
					this.buf.b += "s";
					if(chars.length == null) this.buf.b += "null"; else this.buf.b += "" + chars.length;
					this.buf.b += ":";
					if(chars == null) this.buf.b += "null"; else this.buf.b += "" + chars;
					break;
				default:
					if(this.useCache) this.cache.pop();
					if(v.hxSerialize != null) {
						this.buf.b += "C";
						this.serializeString(Type.getClassName(c));
						if(this.useCache) this.cache.push(v);
						v.hxSerialize(this);
						this.buf.b += "g";
					} else {
						this.buf.b += "c";
						this.serializeString(Type.getClassName(c));
						if(this.useCache) this.cache.push(v);
						this.serializeFields(v);
					}
				}
				break;
			case 4:
				if(js_Boot.__instanceof(v,Class)) {
					var className = Type.getClassName(v);
					this.buf.b += "A";
					this.serializeString(className);
				} else if(js_Boot.__instanceof(v,Enum)) {
					this.buf.b += "B";
					this.serializeString(Type.getEnumName(v));
				} else {
					if(this.useCache && this.serializeRef(v)) return;
					this.buf.b += "o";
					this.serializeFields(v);
				}
				break;
			case 7:
				var e = _g[2];
				if(this.useCache) {
					if(this.serializeRef(v)) return;
					this.cache.pop();
				}
				if(this.useEnumIndex) this.buf.b += "j"; else this.buf.b += "w";
				this.serializeString(Type.getEnumName(e));
				if(this.useEnumIndex) {
					this.buf.b += ":";
					this.buf.b += Std.string(v[1]);
				} else this.serializeString(v[0]);
				this.buf.b += ":";
				var l1 = v.length;
				this.buf.b += Std.string(l1 - 2);
				var _g11 = 2;
				while(_g11 < l1) {
					var i3 = _g11++;
					this.serialize(v[i3]);
				}
				if(this.useCache) this.cache.push(v);
				break;
			case 5:
				throw new js__$Boot_HaxeError("Cannot serialize function");
				break;
			default:
				throw new js__$Boot_HaxeError("Cannot serialize " + Std.string(v));
			}
		}
	}
	,__class__: haxe_Serializer
};
var haxe_Unserializer = function(buf) {
	this.buf = buf;
	this.length = buf.length;
	this.pos = 0;
	this.scache = [];
	this.cache = [];
	var r = haxe_Unserializer.DEFAULT_RESOLVER;
	if(r == null) {
		r = Type;
		haxe_Unserializer.DEFAULT_RESOLVER = r;
	}
	this.setResolver(r);
};
$hxClasses["haxe.Unserializer"] = haxe_Unserializer;
haxe_Unserializer.__name__ = ["haxe","Unserializer"];
haxe_Unserializer.initCodes = function() {
	var codes = [];
	var _g1 = 0;
	var _g = haxe_Unserializer.BASE64.length;
	while(_g1 < _g) {
		var i = _g1++;
		codes[haxe_Unserializer.BASE64.charCodeAt(i)] = i;
	}
	return codes;
};
haxe_Unserializer.prototype = {
	buf: null
	,pos: null
	,length: null
	,cache: null
	,scache: null
	,resolver: null
	,setResolver: function(r) {
		if(r == null) this.resolver = { resolveClass : function(_) {
			return null;
		}, resolveEnum : function(_1) {
			return null;
		}}; else this.resolver = r;
	}
	,get: function(p) {
		return this.buf.charCodeAt(p);
	}
	,readDigits: function() {
		var k = 0;
		var s = false;
		var fpos = this.pos;
		while(true) {
			var c = this.buf.charCodeAt(this.pos);
			if(c != c) break;
			if(c == 45) {
				if(this.pos != fpos) break;
				s = true;
				this.pos++;
				continue;
			}
			if(c < 48 || c > 57) break;
			k = k * 10 + (c - 48);
			this.pos++;
		}
		if(s) k *= -1;
		return k;
	}
	,readFloat: function() {
		var p1 = this.pos;
		while(true) {
			var c = this.buf.charCodeAt(this.pos);
			if(c >= 43 && c < 58 || c == 101 || c == 69) this.pos++; else break;
		}
		return Std.parseFloat(HxOverrides.substr(this.buf,p1,this.pos - p1));
	}
	,unserializeObject: function(o) {
		while(true) {
			if(this.pos >= this.length) throw new js__$Boot_HaxeError("Invalid object");
			if(this.buf.charCodeAt(this.pos) == 103) break;
			var k = this.unserialize();
			if(!(typeof(k) == "string")) throw new js__$Boot_HaxeError("Invalid object key");
			var v = this.unserialize();
			o[k] = v;
		}
		this.pos++;
	}
	,unserializeEnum: function(edecl,tag) {
		if(this.get(this.pos++) != 58) throw new js__$Boot_HaxeError("Invalid enum format");
		var nargs = this.readDigits();
		if(nargs == 0) return Type.createEnum(edecl,tag);
		var args = [];
		while(nargs-- > 0) args.push(this.unserialize());
		return Type.createEnum(edecl,tag,args);
	}
	,unserialize: function() {
		var _g = this.get(this.pos++);
		switch(_g) {
		case 110:
			return null;
		case 116:
			return true;
		case 102:
			return false;
		case 122:
			return 0;
		case 105:
			return this.readDigits();
		case 100:
			return this.readFloat();
		case 121:
			var len = this.readDigits();
			if(this.get(this.pos++) != 58 || this.length - this.pos < len) throw new js__$Boot_HaxeError("Invalid string length");
			var s = HxOverrides.substr(this.buf,this.pos,len);
			this.pos += len;
			s = decodeURIComponent(s.split("+").join(" "));
			this.scache.push(s);
			return s;
		case 107:
			return NaN;
		case 109:
			return -Infinity;
		case 112:
			return Infinity;
		case 97:
			var buf = this.buf;
			var a = [];
			this.cache.push(a);
			while(true) {
				var c = this.buf.charCodeAt(this.pos);
				if(c == 104) {
					this.pos++;
					break;
				}
				if(c == 117) {
					this.pos++;
					var n = this.readDigits();
					a[a.length + n - 1] = null;
				} else a.push(this.unserialize());
			}
			return a;
		case 111:
			var o = { };
			this.cache.push(o);
			this.unserializeObject(o);
			return o;
		case 114:
			var n1 = this.readDigits();
			if(n1 < 0 || n1 >= this.cache.length) throw new js__$Boot_HaxeError("Invalid reference");
			return this.cache[n1];
		case 82:
			var n2 = this.readDigits();
			if(n2 < 0 || n2 >= this.scache.length) throw new js__$Boot_HaxeError("Invalid string reference");
			return this.scache[n2];
		case 120:
			throw new js__$Boot_HaxeError(this.unserialize());
			break;
		case 99:
			var name = this.unserialize();
			var cl = this.resolver.resolveClass(name);
			if(cl == null) throw new js__$Boot_HaxeError("Class not found " + name);
			var o1 = Type.createEmptyInstance(cl);
			this.cache.push(o1);
			this.unserializeObject(o1);
			return o1;
		case 119:
			var name1 = this.unserialize();
			var edecl = this.resolver.resolveEnum(name1);
			if(edecl == null) throw new js__$Boot_HaxeError("Enum not found " + name1);
			var e = this.unserializeEnum(edecl,this.unserialize());
			this.cache.push(e);
			return e;
		case 106:
			var name2 = this.unserialize();
			var edecl1 = this.resolver.resolveEnum(name2);
			if(edecl1 == null) throw new js__$Boot_HaxeError("Enum not found " + name2);
			this.pos++;
			var index = this.readDigits();
			var tag = Type.getEnumConstructs(edecl1)[index];
			if(tag == null) throw new js__$Boot_HaxeError("Unknown enum index " + name2 + "@" + index);
			var e1 = this.unserializeEnum(edecl1,tag);
			this.cache.push(e1);
			return e1;
		case 108:
			var l = new List();
			this.cache.push(l);
			var buf1 = this.buf;
			while(this.buf.charCodeAt(this.pos) != 104) l.add(this.unserialize());
			this.pos++;
			return l;
		case 98:
			var h = new haxe_ds_StringMap();
			this.cache.push(h);
			var buf2 = this.buf;
			while(this.buf.charCodeAt(this.pos) != 104) {
				var s1 = this.unserialize();
				h.set(s1,this.unserialize());
			}
			this.pos++;
			return h;
		case 113:
			var h1 = new haxe_ds_IntMap();
			this.cache.push(h1);
			var buf3 = this.buf;
			var c1 = this.get(this.pos++);
			while(c1 == 58) {
				var i = this.readDigits();
				h1.set(i,this.unserialize());
				c1 = this.get(this.pos++);
			}
			if(c1 != 104) throw new js__$Boot_HaxeError("Invalid IntMap format");
			return h1;
		case 77:
			var h2 = new haxe_ds_ObjectMap();
			this.cache.push(h2);
			var buf4 = this.buf;
			while(this.buf.charCodeAt(this.pos) != 104) {
				var s2 = this.unserialize();
				h2.set(s2,this.unserialize());
			}
			this.pos++;
			return h2;
		case 118:
			var d;
			if(this.buf.charCodeAt(this.pos) >= 48 && this.buf.charCodeAt(this.pos) <= 57 && this.buf.charCodeAt(this.pos + 1) >= 48 && this.buf.charCodeAt(this.pos + 1) <= 57 && this.buf.charCodeAt(this.pos + 2) >= 48 && this.buf.charCodeAt(this.pos + 2) <= 57 && this.buf.charCodeAt(this.pos + 3) >= 48 && this.buf.charCodeAt(this.pos + 3) <= 57 && this.buf.charCodeAt(this.pos + 4) == 45) {
				var s3 = HxOverrides.substr(this.buf,this.pos,19);
				d = HxOverrides.strDate(s3);
				this.pos += 19;
			} else {
				var t = this.readFloat();
				var d1 = new Date();
				d1.setTime(t);
				d = d1;
			}
			this.cache.push(d);
			return d;
		case 115:
			var len1 = this.readDigits();
			var buf5 = this.buf;
			if(this.get(this.pos++) != 58 || this.length - this.pos < len1) throw new js__$Boot_HaxeError("Invalid bytes length");
			var codes = haxe_Unserializer.CODES;
			if(codes == null) {
				codes = haxe_Unserializer.initCodes();
				haxe_Unserializer.CODES = codes;
			}
			var i1 = this.pos;
			var rest = len1 & 3;
			var size;
			size = (len1 >> 2) * 3 + (rest >= 2?rest - 1:0);
			var max = i1 + (len1 - rest);
			var bytes = haxe_io_Bytes.alloc(size);
			var bpos = 0;
			while(i1 < max) {
				var c11 = codes[StringTools.fastCodeAt(buf5,i1++)];
				var c2 = codes[StringTools.fastCodeAt(buf5,i1++)];
				bytes.set(bpos++,c11 << 2 | c2 >> 4);
				var c3 = codes[StringTools.fastCodeAt(buf5,i1++)];
				bytes.set(bpos++,c2 << 4 | c3 >> 2);
				var c4 = codes[StringTools.fastCodeAt(buf5,i1++)];
				bytes.set(bpos++,c3 << 6 | c4);
			}
			if(rest >= 2) {
				var c12 = codes[StringTools.fastCodeAt(buf5,i1++)];
				var c21 = codes[StringTools.fastCodeAt(buf5,i1++)];
				bytes.set(bpos++,c12 << 2 | c21 >> 4);
				if(rest == 3) {
					var c31 = codes[StringTools.fastCodeAt(buf5,i1++)];
					bytes.set(bpos++,c21 << 4 | c31 >> 2);
				}
			}
			this.pos += len1;
			this.cache.push(bytes);
			return bytes;
		case 67:
			var name3 = this.unserialize();
			var cl1 = this.resolver.resolveClass(name3);
			if(cl1 == null) throw new js__$Boot_HaxeError("Class not found " + name3);
			var o2 = Type.createEmptyInstance(cl1);
			this.cache.push(o2);
			o2.hxUnserialize(this);
			if(this.get(this.pos++) != 103) throw new js__$Boot_HaxeError("Invalid custom data");
			return o2;
		case 65:
			var name4 = this.unserialize();
			var cl2 = this.resolver.resolveClass(name4);
			if(cl2 == null) throw new js__$Boot_HaxeError("Class not found " + name4);
			return cl2;
		case 66:
			var name5 = this.unserialize();
			var e2 = this.resolver.resolveEnum(name5);
			if(e2 == null) throw new js__$Boot_HaxeError("Enum not found " + name5);
			return e2;
		default:
		}
		this.pos--;
		throw new js__$Boot_HaxeError("Invalid char " + this.buf.charAt(this.pos) + " at position " + this.pos);
	}
	,__class__: haxe_Unserializer
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
	,remove: function(key) {
		if(!this.h.hasOwnProperty(key)) return false;
		delete(this.h[key]);
		return true;
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
var haxe_ds_ObjectMap = function() {
	this.h = { };
	this.h.__keys__ = { };
};
$hxClasses["haxe.ds.ObjectMap"] = haxe_ds_ObjectMap;
haxe_ds_ObjectMap.__name__ = ["haxe","ds","ObjectMap"];
haxe_ds_ObjectMap.__interfaces__ = [haxe_IMap];
haxe_ds_ObjectMap.prototype = {
	h: null
	,set: function(key,value) {
		var id = key.__id__ || (key.__id__ = ++haxe_ds_ObjectMap.count);
		this.h[id] = value;
		this.h.__keys__[id] = key;
	}
	,get: function(key) {
		return this.h[key.__id__];
	}
	,keys: function() {
		var a = [];
		for( var key in this.h.__keys__ ) {
		if(this.h.hasOwnProperty(key)) a.push(this.h.__keys__[key]);
		}
		return HxOverrides.iter(a);
	}
	,__class__: haxe_ds_ObjectMap
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
	,remove: function(key) {
		if(__map_reserved[key] != null) {
			key = "$" + key;
			if(this.rh == null || !this.rh.hasOwnProperty(key)) return false;
			delete(this.rh[key]);
			return true;
		} else {
			if(!this.h.hasOwnProperty(key)) return false;
			delete(this.h[key]);
			return true;
		}
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
var haxe_io_Bytes = function(data) {
	this.length = data.byteLength;
	this.b = new Uint8Array(data);
	this.b.bufferValue = data;
	data.hxBytes = this;
	data.bytes = this.b;
};
$hxClasses["haxe.io.Bytes"] = haxe_io_Bytes;
haxe_io_Bytes.__name__ = ["haxe","io","Bytes"];
haxe_io_Bytes.alloc = function(length) {
	return new haxe_io_Bytes(new ArrayBuffer(length));
};
haxe_io_Bytes.prototype = {
	length: null
	,b: null
	,get: function(pos) {
		return this.b[pos];
	}
	,set: function(pos,v) {
		this.b[pos] = v & 255;
	}
	,__class__: haxe_io_Bytes
};
var haxe_io_Error = $hxClasses["haxe.io.Error"] = { __ename__ : ["haxe","io","Error"], __constructs__ : ["Blocked","Overflow","OutsideBounds","Custom"] };
haxe_io_Error.Blocked = ["Blocked",0];
haxe_io_Error.Blocked.toString = $estr;
haxe_io_Error.Blocked.__enum__ = haxe_io_Error;
haxe_io_Error.Overflow = ["Overflow",1];
haxe_io_Error.Overflow.toString = $estr;
haxe_io_Error.Overflow.__enum__ = haxe_io_Error;
haxe_io_Error.OutsideBounds = ["OutsideBounds",2];
haxe_io_Error.OutsideBounds.toString = $estr;
haxe_io_Error.OutsideBounds.__enum__ = haxe_io_Error;
haxe_io_Error.Custom = function(e) { var $x = ["Custom",3,e]; $x.__enum__ = haxe_io_Error; $x.toString = $estr; return $x; };
var haxe_io_FPHelper = function() { };
$hxClasses["haxe.io.FPHelper"] = haxe_io_FPHelper;
haxe_io_FPHelper.__name__ = ["haxe","io","FPHelper"];
haxe_io_FPHelper.i32ToFloat = function(i) {
	var sign = 1 - (i >>> 31 << 1);
	var exp = i >>> 23 & 255;
	var sig = i & 8388607;
	if(sig == 0 && exp == 0) return 0.0;
	return sign * (1 + Math.pow(2,-23) * sig) * Math.pow(2,exp - 127);
};
haxe_io_FPHelper.floatToI32 = function(f) {
	if(f == 0) return 0;
	var af;
	if(f < 0) af = -f; else af = f;
	var exp = Math.floor(Math.log(af) / 0.6931471805599453);
	if(exp < -127) exp = -127; else if(exp > 128) exp = 128;
	var sig = Math.round((af / Math.pow(2,exp) - 1) * 8388608) & 8388607;
	return (f < 0?-2147483648:0) | exp + 127 << 23 | sig;
};
haxe_io_FPHelper.i64ToDouble = function(low,high) {
	var sign = 1 - (high >>> 31 << 1);
	var exp = (high >> 20 & 2047) - 1023;
	var sig = (high & 1048575) * 4294967296. + (low >>> 31) * 2147483648. + (low & 2147483647);
	if(sig == 0 && exp == -1023) return 0.0;
	return sign * (1.0 + Math.pow(2,-52) * sig) * Math.pow(2,exp);
};
haxe_io_FPHelper.doubleToI64 = function(v) {
	var i64 = haxe_io_FPHelper.i64tmp;
	if(v == 0) {
		i64.low = 0;
		i64.high = 0;
	} else {
		var av;
		if(v < 0) av = -v; else av = v;
		var exp = Math.floor(Math.log(av) / 0.6931471805599453);
		var sig;
		var v1 = (av / Math.pow(2,exp) - 1) * 4503599627370496.;
		sig = Math.round(v1);
		var sig_l = sig | 0;
		var sig_h = sig / 4294967296.0 | 0;
		i64.low = sig_l;
		i64.high = (v < 0?-2147483648:0) | exp + 1023 << 20 | sig_h;
	}
	return i64;
};
var haxe_rtti_CType = $hxClasses["haxe.rtti.CType"] = { __ename__ : ["haxe","rtti","CType"], __constructs__ : ["CUnknown","CEnum","CClass","CTypedef","CFunction","CAnonymous","CDynamic","CAbstract"] };
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
var haxe_rtti_Rights = $hxClasses["haxe.rtti.Rights"] = { __ename__ : ["haxe","rtti","Rights"], __constructs__ : ["RNormal","RNo","RCall","RMethod","RDynamic","RInline"] };
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
var haxe_rtti_TypeTree = $hxClasses["haxe.rtti.TypeTree"] = { __ename__ : ["haxe","rtti","TypeTree"], __constructs__ : ["TPackage","TClassdecl","TEnumdecl","TTypedecl","TAbstractdecl"] };
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
var js_html_compat_ArrayBuffer = function(a) {
	if((a instanceof Array) && a.__enum__ == null) {
		this.a = a;
		this.byteLength = a.length;
	} else {
		var len = a;
		this.a = [];
		var _g = 0;
		while(_g < len) {
			var i = _g++;
			this.a[i] = 0;
		}
		this.byteLength = len;
	}
};
$hxClasses["js.html.compat.ArrayBuffer"] = js_html_compat_ArrayBuffer;
js_html_compat_ArrayBuffer.__name__ = ["js","html","compat","ArrayBuffer"];
js_html_compat_ArrayBuffer.sliceImpl = function(begin,end) {
	var u = new Uint8Array(this,begin,end == null?null:end - begin);
	var result = new ArrayBuffer(u.byteLength);
	var resultArray = new Uint8Array(result);
	resultArray.set(u);
	return result;
};
js_html_compat_ArrayBuffer.prototype = {
	byteLength: null
	,a: null
	,slice: function(begin,end) {
		return new js_html_compat_ArrayBuffer(this.a.slice(begin,end));
	}
	,__class__: js_html_compat_ArrayBuffer
};
var js_html_compat_DataView = function(buffer,byteOffset,byteLength) {
	this.buf = buffer;
	if(byteOffset == null) this.offset = 0; else this.offset = byteOffset;
	if(byteLength == null) this.length = buffer.byteLength - this.offset; else this.length = byteLength;
	if(this.offset < 0 || this.length < 0 || this.offset + this.length > buffer.byteLength) throw new js__$Boot_HaxeError(haxe_io_Error.OutsideBounds);
};
$hxClasses["js.html.compat.DataView"] = js_html_compat_DataView;
js_html_compat_DataView.__name__ = ["js","html","compat","DataView"];
js_html_compat_DataView.prototype = {
	buf: null
	,offset: null
	,length: null
	,getInt8: function(byteOffset) {
		var v = this.buf.a[this.offset + byteOffset];
		if(v >= 128) return v - 256; else return v;
	}
	,getUint8: function(byteOffset) {
		return this.buf.a[this.offset + byteOffset];
	}
	,getInt16: function(byteOffset,littleEndian) {
		var v = this.getUint16(byteOffset,littleEndian);
		if(v >= 32768) return v - 65536; else return v;
	}
	,getUint16: function(byteOffset,littleEndian) {
		if(littleEndian) return this.buf.a[this.offset + byteOffset] | this.buf.a[this.offset + byteOffset + 1] << 8; else return this.buf.a[this.offset + byteOffset] << 8 | this.buf.a[this.offset + byteOffset + 1];
	}
	,getInt32: function(byteOffset,littleEndian) {
		var p = this.offset + byteOffset;
		var a = this.buf.a[p++];
		var b = this.buf.a[p++];
		var c = this.buf.a[p++];
		var d = this.buf.a[p++];
		if(littleEndian) return a | b << 8 | c << 16 | d << 24; else return d | c << 8 | b << 16 | a << 24;
	}
	,getUint32: function(byteOffset,littleEndian) {
		var v = this.getInt32(byteOffset,littleEndian);
		if(v < 0) return v + 4294967296.; else return v;
	}
	,getFloat32: function(byteOffset,littleEndian) {
		return haxe_io_FPHelper.i32ToFloat(this.getInt32(byteOffset,littleEndian));
	}
	,getFloat64: function(byteOffset,littleEndian) {
		var a = this.getInt32(byteOffset,littleEndian);
		var b = this.getInt32(byteOffset + 4,littleEndian);
		return haxe_io_FPHelper.i64ToDouble(littleEndian?a:b,littleEndian?b:a);
	}
	,setInt8: function(byteOffset,value) {
		if(value < 0) this.buf.a[byteOffset + this.offset] = value + 128 & 255; else this.buf.a[byteOffset + this.offset] = value & 255;
	}
	,setUint8: function(byteOffset,value) {
		this.buf.a[byteOffset + this.offset] = value & 255;
	}
	,setInt16: function(byteOffset,value,littleEndian) {
		this.setUint16(byteOffset,value < 0?value + 65536:value,littleEndian);
	}
	,setUint16: function(byteOffset,value,littleEndian) {
		var p = byteOffset + this.offset;
		if(littleEndian) {
			this.buf.a[p] = value & 255;
			this.buf.a[p++] = value >> 8 & 255;
		} else {
			this.buf.a[p++] = value >> 8 & 255;
			this.buf.a[p] = value & 255;
		}
	}
	,setInt32: function(byteOffset,value,littleEndian) {
		this.setUint32(byteOffset,value,littleEndian);
	}
	,setUint32: function(byteOffset,value,littleEndian) {
		var p = byteOffset + this.offset;
		if(littleEndian) {
			this.buf.a[p++] = value & 255;
			this.buf.a[p++] = value >> 8 & 255;
			this.buf.a[p++] = value >> 16 & 255;
			this.buf.a[p++] = value >>> 24;
		} else {
			this.buf.a[p++] = value >>> 24;
			this.buf.a[p++] = value >> 16 & 255;
			this.buf.a[p++] = value >> 8 & 255;
			this.buf.a[p++] = value & 255;
		}
	}
	,setFloat32: function(byteOffset,value,littleEndian) {
		this.setUint32(byteOffset,haxe_io_FPHelper.floatToI32(value),littleEndian);
	}
	,setFloat64: function(byteOffset,value,littleEndian) {
		var i64 = haxe_io_FPHelper.doubleToI64(value);
		if(littleEndian) {
			this.setUint32(byteOffset,i64.low);
			this.setUint32(byteOffset,i64.high);
		} else {
			this.setUint32(byteOffset,i64.high);
			this.setUint32(byteOffset,i64.low);
		}
	}
	,__class__: js_html_compat_DataView
};
var js_html_compat_Uint8Array = function() { };
$hxClasses["js.html.compat.Uint8Array"] = js_html_compat_Uint8Array;
js_html_compat_Uint8Array.__name__ = ["js","html","compat","Uint8Array"];
js_html_compat_Uint8Array._new = function(arg1,offset,length) {
	var arr;
	if(typeof(arg1) == "number") {
		arr = [];
		var _g = 0;
		while(_g < arg1) {
			var i = _g++;
			arr[i] = 0;
		}
		arr.byteLength = arr.length;
		arr.byteOffset = 0;
		arr.buffer = new js_html_compat_ArrayBuffer(arr);
	} else if(js_Boot.__instanceof(arg1,js_html_compat_ArrayBuffer)) {
		var buffer = arg1;
		if(offset == null) offset = 0;
		if(length == null) length = buffer.byteLength - offset;
		if(offset == 0) arr = buffer.a; else arr = buffer.a.slice(offset,offset + length);
		arr.byteLength = arr.length;
		arr.byteOffset = offset;
		arr.buffer = buffer;
	} else if((arg1 instanceof Array) && arg1.__enum__ == null) {
		arr = arg1.slice();
		arr.byteLength = arr.length;
		arr.byteOffset = 0;
		arr.buffer = new js_html_compat_ArrayBuffer(arr);
	} else throw new js__$Boot_HaxeError("TODO " + Std.string(arg1));
	arr.subarray = js_html_compat_Uint8Array._subarray;
	arr.set = js_html_compat_Uint8Array._set;
	return arr;
};
js_html_compat_Uint8Array._set = function(arg,offset) {
	var t = this;
	if(js_Boot.__instanceof(arg.buffer,js_html_compat_ArrayBuffer)) {
		var a = arg;
		if(arg.byteLength + offset > t.byteLength) throw new js__$Boot_HaxeError("set() outside of range");
		var _g1 = 0;
		var _g = arg.byteLength;
		while(_g1 < _g) {
			var i = _g1++;
			t[i + offset] = a[i];
		}
	} else if((arg instanceof Array) && arg.__enum__ == null) {
		var a1 = arg;
		if(a1.length + offset > t.byteLength) throw new js__$Boot_HaxeError("set() outside of range");
		var _g11 = 0;
		var _g2 = a1.length;
		while(_g11 < _g2) {
			var i1 = _g11++;
			t[i1 + offset] = a1[i1];
		}
	} else throw new js__$Boot_HaxeError("TODO");
};
js_html_compat_Uint8Array._subarray = function(start,end) {
	var t = this;
	var a = js_html_compat_Uint8Array._new(t.slice(start,end));
	a.byteOffset = start;
	return a;
};
var textifician_mapping_ArcNodeVM = $hx_exports.textifician.mapping.ArcNodeVM = function() {
};
$hxClasses["textifician.mapping.ArcNodeVM"] = textifician_mapping_ArcNodeVM;
textifician_mapping_ArcNodeVM.__name__ = ["textifician","mapping","ArcNodeVM"];
textifician_mapping_ArcNodeVM.prototype = {
	val: null
	,__class__: textifician_mapping_ArcNodeVM
};
var textifician_mapping_ArcPacket = $hx_exports.textifician.mapping.ArcPacket = function() {
};
$hxClasses["textifician.mapping.ArcPacket"] = textifician_mapping_ArcPacket;
textifician_mapping_ArcPacket.__name__ = ["textifician","mapping","ArcPacket"];
textifician_mapping_ArcPacket.getSync_equal = function(val,oldValue) {
	return val;
};
textifician_mapping_ArcPacket.getSync_ratioComplement = function(val,oldValue) {
	var str = Std.string(val);
	var dotIndex = str.indexOf(".");
	var numDecimalPlaces = HxOverrides.substr(str,dotIndex + 1,null).length;
	val = 1 - val;
	return de_polygonal_core_fmt_NumberFormat.toFixed(val,numDecimalPlaces);
};
textifician_mapping_ArcPacket.getSync_flipInt = function(val,oldValue) {
	return -val;
};
textifician_mapping_ArcPacket.getSync_newInstance = function(val,oldValue) {
	if(val != null) {
		if(oldValue == null) {
			if(Type.getClass(val) != null) return Type.createInstance(Type.getClass(val),[]); else return tjson_TJSON.parse(tjson_TJSON.encode(val));
		} else return val;
	} else return null;
};
textifician_mapping_ArcPacket.getSync_newEmptyInstance = function(val,oldValue) {
	if(val != null) {
		if(oldValue == null) {
			if(Type.getClass(val) != null) return Type.createEmptyInstance(Type.getClass(val)); else return tjson_TJSON.parse(tjson_TJSON.encode(val));
		} else return val;
	} else return null;
};
textifician_mapping_ArcPacket._tjsonParse = function(val) {
	return tjson_TJSON.parse(tjson_TJSON.encode(val));
};
textifician_mapping_ArcPacket.prototype = {
	flags: null
	,label: null
	,description: null
	,cardinal: null
	,pathArcInfo: null
	,toString: function() {
		return "[ArcPacket]";
	}
	,__class__: textifician_mapping_ArcPacket
};
var textifician_mapping_PathArcInfo = $hx_exports.textifician.mapping.PathArcInfo = function() {
};
$hxClasses["textifician.mapping.PathArcInfo"] = textifician_mapping_PathArcInfo;
textifician_mapping_PathArcInfo.__name__ = ["textifician","mapping","PathArcInfo"];
textifician_mapping_PathArcInfo.prototype = {
	breakpoint: null
	,customDistance: null
	,__class__: textifician_mapping_PathArcInfo
};
var textifician_mapping_IXYZ = function() { };
$hxClasses["textifician.mapping.IXYZ"] = textifician_mapping_IXYZ;
textifician_mapping_IXYZ.__name__ = ["textifician","mapping","IXYZ"];
textifician_mapping_IXYZ.prototype = {
	x: null
	,y: null
	,z: null
	,__class__: textifician_mapping_IXYZ
};
var textifician_mapping_IndoorLocationSpecs = $hx_exports.textifician.mapping.IndoorLocationSpecs = function() {
	this.wallHeight = textifician_mapping_IndoorLocationSpecs.DEFAULT_WALL_HEIGHT;
	this.wallThickness = textifician_mapping_IndoorLocationSpecs.DEFAULT_WALL_THICKNESS;
	this.wallStrength = textifician_mapping_IndoorLocationSpecs.DEFAULT_WALL_STRENGTH;
	this.ceilingThickness = textifician_mapping_IndoorLocationSpecs.DEFAULT_WALL_THICKNESS;
	this.ceilingStrength = textifician_mapping_IndoorLocationSpecs.DEFAULT_CEILING_STRENGTH;
};
$hxClasses["textifician.mapping.IndoorLocationSpecs"] = textifician_mapping_IndoorLocationSpecs;
textifician_mapping_IndoorLocationSpecs.__name__ = ["textifician","mapping","IndoorLocationSpecs"];
textifician_mapping_IndoorLocationSpecs.create = function(wallHeight,wallThickness,wallStrength,ceilingThickness,ceilingStrength) {
	if(ceilingStrength == null) ceilingStrength = -1;
	if(ceilingThickness == null) ceilingThickness = -1;
	if(wallStrength == null) wallStrength = -1;
	if(wallThickness == null) wallThickness = -1;
	if(wallHeight == null) wallHeight = -1;
	var me = new textifician_mapping_IndoorLocationSpecs();
	if(wallHeight < 0) me.wallHeight = textifician_mapping_IndoorLocationSpecs.DEFAULT_WALL_HEIGHT; else me.wallHeight = wallHeight;
	if(wallThickness < 0) me.wallThickness = textifician_mapping_IndoorLocationSpecs.DEFAULT_WALL_THICKNESS; else me.wallThickness = wallThickness;
	if(wallStrength < 0) me.wallStrength = textifician_mapping_IndoorLocationSpecs.DEFAULT_WALL_STRENGTH; else me.wallStrength = wallStrength;
	if(ceilingThickness < 0) me.ceilingThickness = textifician_mapping_IndoorLocationSpecs.DEFAULT_CEILING_THICKNESS; else me.ceilingThickness = ceilingThickness;
	if(ceilingStrength < 0) me.ceilingStrength = textifician_mapping_IndoorLocationSpecs.DEFAULT_CEILING_STRENGTH; else me.ceilingStrength = ceilingStrength;
	return me;
};
textifician_mapping_IndoorLocationSpecs.prototype = {
	wallHeight: null
	,wallThickness: null
	,wallStrength: null
	,ceilingThickness: null
	,ceilingStrength: null
	,toString: function() {
		return "[IndoorLocationSpecs]";
	}
	,__class__: textifician_mapping_IndoorLocationSpecs
};
var textifician_mapping_LocationDefinition = $hx_exports.textifician.mapping.LocationDefinition = function() {
	this.description = "";
	this.defaultLighting = 0;
	this.speedcap = 0;
};
$hxClasses["textifician.mapping.LocationDefinition"] = textifician_mapping_LocationDefinition;
textifician_mapping_LocationDefinition.__name__ = ["textifician","mapping","LocationDefinition"];
textifician_mapping_LocationDefinition.create = function(type,label,id) {
	var locDef = new textifician_mapping_LocationDefinition();
	locDef.type = type;
	locDef.label = label;
	locDef.size = 1;
	if(id != null) locDef.id = id;
	return locDef;
};
textifician_mapping_LocationDefinition.createWithMatchingId = function(type,label,id,doSlugify,camelCase) {
	if(camelCase == null) camelCase = false;
	if(doSlugify == null) doSlugify = false;
	var locDef = new textifician_mapping_LocationDefinition();
	locDef.type = type;
	locDef.label = label;
	locDef.size = 1;
	if(id != null) locDef.id = id; else {
		if(!doSlugify) locDef.id = label; else locDef.id = new EReg("-+$","").replace(new EReg("^-+","").replace(new EReg("\\-\\-+","g").replace(new EReg("[^\\w\\-]+","g").replace(new EReg("\\s+","g").replace(label.toString().toLowerCase(),"-"),""),"-"),""),"");
		if(doSlugify && camelCase) locDef.id = textifician_mapping_LocationDefinition.camelizeSlug(locDef.id);
	}
	return locDef;
};
textifician_mapping_LocationDefinition.slugify = function(label) {
	return new EReg("-+$","").replace(new EReg("^-+","").replace(new EReg("\\-\\-+","g").replace(new EReg("[^\\w\\-]+","g").replace(new EReg("\\s+","g").replace(label.toString().toLowerCase(),"-"),""),"-"),""),"");
};
textifician_mapping_LocationDefinition.camelizeSlug = function(slug) {
	var splitStr = slug.split("-");
	var len = splitStr.length;
	var _g = 1;
	while(_g < len) {
		var i = _g++;
		splitStr[i] = splitStr[i].charAt(0).toUpperCase() + HxOverrides.substr(splitStr[i],1,null);
	}
	return splitStr.join("");
};
textifician_mapping_LocationDefinition.getLocationDefinitionTypeLabel = function(val) {
	if(val == 1) return "Path"; else if(val == 2) return "Region"; else return "Point";
};
textifician_mapping_LocationDefinition.prototype = {
	id: null
	,label: null
	,description: null
	,flags: null
	,size: null
	,type: null
	,envFlags: null
	,defaultLighting: null
	,generalFixtures: null
	,speedcap: null
	,priorityIndex: null
	,indoorLocationSpecs: null
	,setSize: function(val) {
		this.size = val;
		return this;
	}
	,setDescription: function(val) {
		this.description = val;
		return this;
	}
	,toString: function() {
		return "[LocationDefinition:" + this.id + "]";
	}
	,makeDoor: function(isDoor,implyEntrance) {
		if(implyEntrance == null) implyEntrance = true;
		if(isDoor == null) isDoor = true;
		if(isDoor) {
			if(implyEntrance) this.flags |= 1; else this.flags |= 0;
			this.flags |= 2;
		} else this.flags &= -3;
		return this;
	}
	,makeEntrance: function(val) {
		if(val == null) val = true;
		if(val) this.flags |= 1; else this.flags &= -2;
		return this;
	}
	,makeKey: function(val) {
		if(val == null) val = true;
		if(val) this.flags |= 4; else this.flags &= -5;
		return this;
	}
	,makeLandmark: function(val) {
		if(val == null) val = true;
		if(val) this.flags |= 8; else this.flags &= -9;
		return this;
	}
	,resetShelterFlags: function() {
		this.envFlags &= -16;
	}
	,resetShelterWallFlags: function() {
		this.envFlags &= -4;
	}
	,resetShelterCeilingFlags: function() {
		this.envFlags &= -13;
	}
	,makeFullyIndoor: function() {
		this.envFlags &= -16;
		this.envFlags |= 15;
		return this;
	}
	,makeFullyOutdoor: function() {
		this.envFlags &= -16;
		return this;
	}
	,setupIndoorLocationSpecs: function(locationSpecs) {
		this.indoorLocationSpecs = locationSpecs;
		return this;
	}
	,setupShelterAmounts: function(wallAmount,ceilingAmount) {
		this.envFlags &= -16;
		if(wallAmount == 0) this.envFlags |= 0; else if(wallAmount == 1) this.envFlags |= 1; else if(wallAmount == 2) this.envFlags |= 2; else this.envFlags |= 3;
		if(ceilingAmount == 0) this.envFlags |= 0; else if(ceilingAmount == 1) this.envFlags |= 4; else if(ceilingAmount == 2) this.envFlags |= 8; else this.envFlags |= 12;
		return this;
	}
	,setWallAmount: function(wallAmount) {
		this.envFlags &= -4;
		if(wallAmount == 0) this.envFlags |= 0; else if(wallAmount == 1) this.envFlags |= 1; else if(wallAmount == 2) this.envFlags |= 2; else this.envFlags |= 3;
		return this;
	}
	,setCeilingAmount: function(ceilingAmount) {
		this.envFlags &= -13;
		if(ceilingAmount == 0) this.envFlags |= 0; else if(ceilingAmount == 1) this.envFlags |= 4; else if(ceilingAmount == 2) this.envFlags |= 8; else this.envFlags |= 12;
		return this;
	}
	,__class__: textifician_mapping_LocationDefinition
};
var textifician_mapping_LocationPacket = $hx_exports.textifician.mapping.LocationPacket = function() {
	this.reflectType = "LocationPacket";
};
$hxClasses["textifician.mapping.LocationPacket"] = textifician_mapping_LocationPacket;
textifician_mapping_LocationPacket.__name__ = ["textifician","mapping","LocationPacket"];
textifician_mapping_LocationPacket.__interfaces__ = [textifician_mapping_IXYZ];
textifician_mapping_LocationPacket.getTypeOfPacket = function(locPacket) {
	if(locPacket.defOverwrites != null && locPacket.defOverwrites.type != null) return locPacket.defOverwrites.type; else return locPacket.def.type;
};
textifician_mapping_LocationPacket.getCategoryOfPacket = function(locPacket) {
	var type;
	if(locPacket.defOverwrites != null && locPacket.defOverwrites.type != null) type = locPacket.defOverwrites.type; else type = locPacket.def.type;
	switch(type) {
	case 2:
		return "region";
	case 1:
		return "path";
	case 0:
		return "point";
	default:
		return "point";
	}
	return "point";
};
textifician_mapping_LocationPacket.prototype = {
	def: null
	,defOverwrites: null
	,x: null
	,y: null
	,z: null
	,state: null
	,reflectType: null
	,getLabel: function() {
		if(this.defOverwrites != null && this.defOverwrites.label != null) return this.defOverwrites.label; else return this.def.label;
	}
	,setEmptyDefOverwrites: function() {
		this.defOverwrites = { };
	}
	,setupNewDefOverwrites: function(obj) {
		this.defOverwrites = { };
		this.applyDefOverwrites(obj);
	}
	,applyDefOverwrites: function(obj) {
		if(this.defOverwrites == null) this.defOverwrites = { };
		var fields = Reflect.fields(obj);
		var _g = 0;
		while(_g < fields.length) {
			var p = fields[_g];
			++_g;
			Reflect.setField(this.defOverwrites,p,Reflect.field(obj,p));
		}
	}
	,convertOverwritesToLocationDef: function() {
		if(this.defOverwrites == null) return;
		if(js_Boot.__instanceof(this.defOverwrites,textifician_mapping_LocationDefinition)) return;
		var obj = Type.createEmptyInstance(textifician_mapping_LocationDefinition);
		var fields = Reflect.fields(this.defOverwrites);
		var _g = 0;
		while(_g < fields.length) {
			var p = fields[_g];
			++_g;
			Reflect.setField(obj,p,Reflect.field(this.defOverwrites,p));
		}
		this.defOverwrites = obj;
	}
	,cloneOverwritesDynamic: function() {
		if(this.defOverwrites == null) return null;
		var obj = { };
		var fields = Reflect.fields(this.defOverwrites);
		var _g = 0;
		while(_g < fields.length) {
			var p = fields[_g];
			++_g;
			Reflect.setField(obj,p,Reflect.field(this.defOverwrites,p));
		}
		return obj;
	}
	,__class__: textifician_mapping_LocationPacket
};
var textifician_mapping_LocationState = $hx_exports.textifician.mapping.LocationState = function() {
};
$hxClasses["textifician.mapping.LocationState"] = textifician_mapping_LocationState;
textifician_mapping_LocationState.__name__ = ["textifician","mapping","LocationState"];
textifician_mapping_LocationState.prototype = {
	thingsHere: null
	,notes: null
	,flags: null
	,customData: null
	,openDoorFully: function() {
		this.flags |= 6;
		return this;
	}
	,openDoorPartially: function(ajarOnly) {
		if(ajarOnly == null) ajarOnly = false;
		this.flags &= -7;
		if(ajarOnly) this.flags |= 2; else this.flags |= 4;
		return this;
	}
	,closeDoor: function() {
		this.flags &= -7;
		return this;
	}
	,closeAndLockDoor: function() {
		this.closeDoor();
		this.flags |= 1;
		return this;
	}
	,lockDoor: function() {
		this.flags |= 1;
		return this;
	}
	,unlockDoor: function() {
		this.flags &= -2;
		return this;
	}
	,toString: function() {
		return "[LocationState]";
	}
	,__class__: textifician_mapping_LocationState
};
var textifician_mapping_TextificianUtil = $hx_exports.textifician.mapping.TextificianUtil = function() { };
$hxClasses["textifician.mapping.TextificianUtil"] = textifician_mapping_TextificianUtil;
textifician_mapping_TextificianUtil.__name__ = ["textifician","mapping","TextificianUtil"];
textifician_mapping_TextificianUtil.getTotalDistanceFrom = function(graph,startNode,endNode,route) {
	return 0;
};
textifician_mapping_TextificianUtil.getDirectDistanceFromTo = function(startLocation,endLocation,posOffset) {
	var ox;
	if(posOffset != null) ox = posOffset.x; else ox = 0;
	var oy;
	if(posOffset != null) oy = posOffset.y; else oy = 0;
	return 0;
};
textifician_mapping_TextificianUtil.distancePointToRegion = function(pt,regionPt,regionSize) {
	return 0;
};
textifician_mapping_TextificianUtil.distanceRegionToRegion = function(pt,pt1RegionSize,pt2,pt2RegionSize) {
	return 0;
};
textifician_mapping_TextificianUtil.distancePtToPt = function(pt,pt2) {
	var dx = pt2.x - pt.x;
	var dy = pt2.y - pt.y;
	return Math.sqrt(dx * dx + dy * dy);
};
textifician_mapping_TextificianUtil.getPropertyChainObj = function(src,property) {
	var me = new textifician_mapping_PropertyChainHolder();
	me.setupProperty(src,property);
	return me;
};
textifician_mapping_TextificianUtil.applyDynamicProperties = function(obj,target) {
	var fields = Reflect.fields(obj);
	var _g = 0;
	while(_g < fields.length) {
		var p = fields[_g];
		++_g;
		var val = Reflect.field(fields,p);
		if(Reflect.isObject(val)) {
			var tarProp = Reflect.getProperty(target,p);
			if(tarProp != null) textifician_mapping_TextificianUtil.applyDynamicProperties(val,tarProp); else Reflect.setProperty(target,p,null);
		} else Reflect.setProperty(target,p,val);
	}
};
textifician_mapping_TextificianUtil.applyPropertiesOverFromSrc = function(src,obj) {
};
var textifician_mapping_PropertyChainHolder = function() {
	Object.defineProperty(this,"value",{ get : $bind(this,this.get_value), set : $bind(this,this.set_value)});
};
$hxClasses["textifician.mapping.PropertyChainHolder"] = textifician_mapping_PropertyChainHolder;
textifician_mapping_PropertyChainHolder.__name__ = ["textifician","mapping","PropertyChainHolder"];
textifician_mapping_PropertyChainHolder.prototype = {
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
	,__class__: textifician_mapping_PropertyChainHolder
	,__properties__: {set_value:"set_value",get_value:"get_value"}
};
var textifician_mapping_TextificianWorldBase = function() {
};
$hxClasses["textifician.mapping.TextificianWorldBase"] = textifician_mapping_TextificianWorldBase;
textifician_mapping_TextificianWorldBase.__name__ = ["textifician","mapping","TextificianWorldBase"];
textifician_mapping_TextificianWorldBase.prototype = {
	graph: null
	,zones: null
	,__class__: textifician_mapping_TextificianWorldBase
};
var textifician_mapping_TextificianWorld = $hx_exports.textifician.mapping.TextificianWorld = function() {
	textifician_mapping_TextificianWorldBase.call(this);
	textifician_rpg_ICharacter;
	textifician_rpg_IParty;
	textifician_rpg_IFixture;
	textifician_rpg_IItem;
	this.zones = new haxe_ds_StringMap();
	this.graph = new de_polygonal_ds_Graph();
	this.locationDefs = new haxe_ds_StringMap();
	this.editableHash = new haxe_ds_IntMap();
	textifician_mapping_ArcNodeVM;
};
$hxClasses["textifician.mapping.TextificianWorld"] = textifician_mapping_TextificianWorld;
textifician_mapping_TextificianWorld.__name__ = ["textifician","mapping","TextificianWorld"];
textifician_mapping_TextificianWorld.serialize = function(world) {
	var serializer = new haxe_Serializer();
	serializer.useCache = true;
	serializer.serialize(world);
	return serializer.toString();
};
textifician_mapping_TextificianWorld.unserialize = function(str) {
	var unserializer = new haxe_Unserializer(str);
	return unserializer.unserialize();
};
textifician_mapping_TextificianWorld.configureGlobals = function(defaultMapScale,smallestMovementUnit) {
	textifician_mapping_Zone.DEFAULT_SCALE = defaultMapScale;
	textifician_mapping_TextificianUtil.EPSILON = smallestMovementUnit;
};
textifician_mapping_TextificianWorld.configureGlobalMapScale = function(defaultMapScale) {
	textifician_mapping_Zone.DEFAULT_SCALE = defaultMapScale;
};
textifician_mapping_TextificianWorld.configureGlobalSmallestMovementDist = function(smallestMovementUnit) {
	textifician_mapping_TextificianUtil.EPSILON = smallestMovementUnit;
};
textifician_mapping_TextificianWorld.__super__ = textifician_mapping_TextificianWorldBase;
textifician_mapping_TextificianWorld.prototype = $extend(textifician_mapping_TextificianWorldBase.prototype,{
	locationDefs: null
	,editableHash: null
	,registerHashEditable: function(hashable,editableContent) {
		this.editableHash.set(hashable.key,editableContent);
	}
	,removeHashEditable: function(hashable) {
		return this.editableHash.remove(hashable.key);
	}
	,getHashEditable: function(hashable) {
		return this.editableHash.h[hashable.key];
	}
	,setupDefaultNew: function(zone) {
		if(zone == null) zone = textifician_mapping_Zone.create("DefaultZone","");
		this.addZone(zone);
		this.addLocationDef(textifician_mapping_LocationDefinition.createWithMatchingId(0,"Point"));
		this.addLocationDef(textifician_mapping_LocationDefinition.createWithMatchingId(1,"Path"));
		this.addLocationDef(textifician_mapping_LocationDefinition.createWithMatchingId(2,"Region"));
	}
	,getLocationDefinitionIds: function(ignoreHash) {
		var arr = [];
		var $it0 = this.locationDefs.keys();
		while( $it0.hasNext() ) {
			var p = $it0.next();
			if(ignoreHash == null || !Reflect.field(ignoreHash,p)) arr.push(p);
		}
		return arr;
	}
	,getDefaultLocationDefIdHash: function() {
		return { 'Point' : true, 'Path' : true, 'Region' : true};
	}
	,setLocationDefinitionIds: function(arr) {
		var newStrMap = new haxe_ds_StringMap();
		var len = arr.length;
		var _g = 0;
		while(_g < len) {
			var i = _g++;
			var locDef = this.getLocationDef(arr[i]);
			if(locDef != null) newStrMap.set(locDef.id,locDef); else console.log("Warning!! LocationDefinition search for:" + arr[i] + " is empty!");
		}
		this.locationDefs = newStrMap;
	}
	,getDuplicationLocationDef: function(def,newId) {
		if(newId == null) newId = "";
		var serializer = new haxe_Serializer();
		serializer.serialize(def);
		var unserializer = new haxe_Unserializer(serializer.toString());
		var locDef = unserializer.unserialize();
		if(newId != null) if(newId != "") locDef.id = newId; else locDef.id = null; else locDef.id = "instance" + de_polygonal_ds_HashKey._counter++;
		return locDef;
	}
	,getGOGraphData: function(goTypeSizes,defaultPictureOpacity) {
		if(defaultPictureOpacity == null) defaultPictureOpacity = .5;
		var obj;
		var dataGraph = this.graph.serialize($bind(this,this.returnSelf));
		var goGraphData = { nodes : [], links : []};
		var node = this.graph.mNodeList;
		var count = 0;
		var nodeArr = [];
		while(node != null) {
			if(js_Boot.__instanceof(node.val,textifician_mapping_LocationPacket)) {
				var locPacket = node.val;
				goGraphData.nodes.push(obj = { loc : new go.Point(locPacket.x,locPacket.y), key : count, locid : locPacket.def.id, isProto : false, text : locPacket.getLabel(), category : textifician_mapping_LocationPacket.getCategoryOfPacket(locPacket), size : goTypeSizes[locPacket.defOverwrites != null && locPacket.defOverwrites.type != null?locPacket.defOverwrites.type:locPacket.def.type], _node : node});
			} else if(js_Boot.__instanceof(node.val,textifician_mapping_Zone)) {
				var zone = node.val;
				goGraphData.nodes.push(obj = { loc : new go.Point(zone.x,zone.y), key : count, locid : "", zoneid : false, isProto : false, text : zone.label, pictureOpacity : defaultPictureOpacity, pictureSrc : zone.imageURL, category : "zone", size : goTypeSizes[0], _node : node});
			} else {
				throw new js__$Boot_HaxeError("Could not resolve data type of node val:" + Std.string(node.val));
				goGraphData.nodes.push(node.val);
			}
			this.editableHash.set(node.key,obj);
			count++;
			nodeArr.push(node);
			node = node.next;
		}
		var arcList = dataGraph.arcs;
		var len = arcList.length;
		var i = 0;
		while(i < len) {
			var fromInt = arcList[i];
			var toInt = arcList[i + 1];
			var theArc = nodeArr[fromInt].getArc(nodeArr[toInt]);
			goGraphData.links.push(obj = { key : this.getUniqueHashKey(), _arc : theArc, from : fromInt, to : toInt});
			this.editableHash.set(theArc.key,obj);
			i += 2;
		}
		return goGraphData;
	}
	,saveWorld: function() {
		var serializer = new haxe_Serializer();
		serializer.useCache = true;
		serializer.serialize(this.locationDefs);
		serializer.serialize(this.zones);
		var graphData = this.graph.serialize($bind(this,this.returnSelf));
		serializer.serialize(graphData);
		return serializer.toString();
	}
	,loadWorld: function(worldStr) {
		var unserializer = new haxe_Unserializer(worldStr);
		this.locationDefs = unserializer.unserialize();
		this.zones = unserializer.unserialize();
		var graphData = unserializer.unserialize();
		this.graph = new de_polygonal_ds_Graph();
		this.graph.unserialize(graphData,$bind(this,this.returnSelf));
		this.editableHash = new haxe_ds_IntMap();
	}
	,returnSelf: function(self) {
		if(js_Boot.__instanceof(self,textifician_mapping_LocationPacket) || js_Boot.__instanceof(self,textifician_mapping_Zone)) {
		} else throw new js__$Boot_HaxeError("Should be valid instance type:" + Std.string(self));
		return self;
	}
	,addLocationNode: function(def,x,y,z,state,defOverwrites) {
		if(z == null) z = 0;
		if(y == null) y = 0;
		if(x == null) x = 0;
		var locationPacket = new textifician_mapping_LocationPacket();
		locationPacket.def = def;
		locationPacket.state = state;
		locationPacket.x = x;
		locationPacket.y = y;
		locationPacket.z = z;
		locationPacket.defOverwrites = defOverwrites;
		return this.graph.addNode(this.graph.createNode(locationPacket));
	}
	,addZoneNode: function(zone) {
		return this.graph.addNode(this.graph.createNode(zone));
	}
	,getUniqueHashKey: function() {
		return de_polygonal_ds_HashKey._counter++;
	}
	,getLocationDef: function(id) {
		return this.locationDefs.get(id);
	}
	,removeLocationDef: function(def) {
		return this.locationDefs.remove(def.id);
	}
	,addLocationDef: function(def,forceOverwrite) {
		if(forceOverwrite == null) forceOverwrite = false;
		if(def.id == null) {
			def.id = "instance" + de_polygonal_ds_HashKey._counter++;
			if(!forceOverwrite && this.locationDefs.exists(def.id)) throw new js__$Boot_HaxeError("Location Definition of: " + def.id + " already exists!");
			this.locationDefs.set(def.id,def);
		} else {
			var current;
			current = this.locationDefs.get(def.id);
			if(current == null) this.locationDefs.set(def.id,def); else if(forceOverwrite) this.locationDefs.set(def.id,def); else throw new js__$Boot_HaxeError("Location Definition of: " + def.id + " already exists!");
		}
		return def;
	}
	,addZone: function(zone,forceOverwrite) {
		if(forceOverwrite == null) forceOverwrite = false;
		if(zone.id == null) {
			zone.id = "zone" + de_polygonal_ds_HashKey._counter++;
			if(!forceOverwrite && this.zones.exists(zone.id)) throw new js__$Boot_HaxeError("Zone id of: " + zone.id + " already exists!");
			this.zones.set(zone.id,zone);
		} else {
			var current;
			current = this.zones.get(zone.id);
			if(current == null) this.zones.set(zone.id,zone); else if(forceOverwrite) this.zones.set(zone.id,zone); else throw new js__$Boot_HaxeError("Zone id of: " + zone.id + " already exists!");
		}
		return zone;
	}
	,getZone: function(id) {
		if(id == null) id = "";
		return this.zones.get(id);
	}
	,__class__: textifician_mapping_TextificianWorld
});
var textifician_mapping_Zone = $hx_exports.textifician.mapping.Zone = function() {
	this.reflectType = "Zone";
	this.imageURL = "https://s-media-cache-ak0.pinimg.com/736x/e4/89/8c/e4898c58d4713c8b4328fccf38287120.jpg";
	this.scale = 1;
	this.size = 0;
};
$hxClasses["textifician.mapping.Zone"] = textifician_mapping_Zone;
textifician_mapping_Zone.__name__ = ["textifician","mapping","Zone"];
textifician_mapping_Zone.__interfaces__ = [textifician_mapping_IXYZ];
textifician_mapping_Zone.slugify = function(label) {
	return new EReg("-+$","").replace(new EReg("^-+","").replace(new EReg("\\-\\-+","g").replace(new EReg("[^\\w\\-]+","g").replace(new EReg("\\s+","g").replace(label.toString().toLowerCase(),"-"),""),"-"),""),"");
};
textifician_mapping_Zone.camelizeSlug = function(slug) {
	var splitStr = slug.split("-");
	var len = splitStr.length;
	var _g = 1;
	while(_g < len) {
		var i = _g++;
		splitStr[i] = splitStr[i].charAt(0).toUpperCase() + HxOverrides.substr(splitStr[i],1,null);
	}
	return splitStr.join("");
};
textifician_mapping_Zone.resolveIdWithLabel = function(label) {
	if(textifician_mapping_Zone.IDMODE == 1) return new EReg("-+$","").replace(new EReg("^-+","").replace(new EReg("\\-\\-+","g").replace(new EReg("[^\\w\\-]+","g").replace(new EReg("\\s+","g").replace(label.toString().toLowerCase(),"-"),""),"-"),""),""); else if(textifician_mapping_Zone.IDMODE == 2) return textifician_mapping_Zone.camelizeSlug(new EReg("-+$","").replace(new EReg("^-+","").replace(new EReg("\\-\\-+","g").replace(new EReg("[^\\w\\-]+","g").replace(new EReg("\\s+","g").replace(label.toString().toLowerCase(),"-"),""),"-"),""),"")); else return label;
};
textifician_mapping_Zone.create = function(label,id) {
	var zone = new textifician_mapping_Zone();
	zone.label = label;
	if(id != null) zone.id = id; else zone.id = textifician_mapping_Zone.resolveIdWithLabel(label);
	zone.scale = textifician_mapping_Zone.DEFAULT_SCALE;
	zone.childNodes = [];
	zone.size = -1;
	return zone;
};
textifician_mapping_Zone.setupNew = function(label,id,x,y,z,scale,size) {
	if(size == null) size = -1;
	if(scale == null) scale = 1;
	if(z == null) z = 0;
	if(y == null) y = 0;
	if(x == null) x = 0;
	var newZone = textifician_mapping_Zone.create(label,id);
	newZone.scale = scale;
	newZone.size = size;
	newZone.x = x;
	newZone.y = y;
	newZone.z = z;
	return newZone;
};
textifician_mapping_Zone.prototype = {
	id: null
	,label: null
	,childNodes: null
	,size: null
	,scale: null
	,imageURL: null
	,x: null
	,y: null
	,z: null
	,parentZone: null
	,reflectType: null
	,setScale: function(scale) {
		this.scale = scale;
		return this;
	}
	,setSize: function(size) {
		this.size = size;
		return this;
	}
	,setPos: function(x,y,z) {
		if(z == null) z = 0;
		if(y == null) y = 0;
		if(x == null) x = 0;
		this.x = x;
		this.y = y;
		this.z = z;
		return this;
	}
	,addChildren: function(list) {
		var _g1 = 0;
		var _g = list.length;
		while(_g1 < _g) {
			var i = _g1++;
			this.addChild(list[i]);
		}
		return this;
	}
	,addChild: function(node) {
		return null;
	}
	,removeChild: function(node) {
		return null;
	}
	,__class__: textifician_mapping_Zone
};
var textifician_rpg_ICharacter = function() { };
$hxClasses["textifician.rpg.ICharacter"] = textifician_rpg_ICharacter;
textifician_rpg_ICharacter.__name__ = ["textifician","rpg","ICharacter"];
textifician_rpg_ICharacter.__interfaces__ = [textifician_mapping_IXYZ];
textifician_rpg_ICharacter.prototype = {
	name: null
	,__class__: textifician_rpg_ICharacter
};
var textifician_rpg_IFixture = function() { };
$hxClasses["textifician.rpg.IFixture"] = textifician_rpg_IFixture;
textifician_rpg_IFixture.__name__ = ["textifician","rpg","IFixture"];
textifician_rpg_IFixture.prototype = {
	name: null
	,__class__: textifician_rpg_IFixture
};
var textifician_rpg_IItem = function() { };
$hxClasses["textifician.rpg.IItem"] = textifician_rpg_IItem;
textifician_rpg_IItem.__name__ = ["textifician","rpg","IItem"];
textifician_rpg_IItem.__interfaces__ = [textifician_mapping_IXYZ];
textifician_rpg_IItem.prototype = {
	name: null
	,__class__: textifician_rpg_IItem
};
var textifician_rpg_IParty = function() { };
$hxClasses["textifician.rpg.IParty"] = textifician_rpg_IParty;
textifician_rpg_IParty.__name__ = ["textifician","rpg","IParty"];
textifician_rpg_IParty.__interfaces__ = [textifician_mapping_IXYZ];
textifician_rpg_IParty.prototype = {
	name: null
	,characters: null
	,__class__: textifician_rpg_IParty
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
var Bool = $hxClasses.Bool = Boolean;
Bool.__ename__ = ["Bool"];
var Class = $hxClasses.Class = { __name__ : ["Class"]};
var Enum = { };
var __map_reserved = {}
var ArrayBuffer = $global.ArrayBuffer || js_html_compat_ArrayBuffer;
if(ArrayBuffer.prototype.slice == null) ArrayBuffer.prototype.slice = js_html_compat_ArrayBuffer.sliceImpl;
var DataView = $global.DataView || js_html_compat_DataView;
var Uint8Array = $global.Uint8Array || js_html_compat_Uint8Array._new;
Xml.Element = 0;
Xml.PCData = 1;
Xml.CData = 2;
Xml.Comment = 3;
Xml.DocType = 4;
Xml.ProcessingInstruction = 5;
Xml.Document = 6;
de_polygonal_Printf._initialized = false;
de_polygonal_core_fmt_NumberFormat._hexLUT = ["0","1","2","3","4","5","6","7","8","9","A","B","C","D","E","F"];
de_polygonal_core_math_Limits.INT8_MIN = -128;
de_polygonal_core_math_Limits.INT8_MAX = 127;
de_polygonal_core_math_Limits.UINT8_MAX = 255;
de_polygonal_core_math_Limits.INT16_MIN = -32768;
de_polygonal_core_math_Limits.INT16_MAX = 32767;
de_polygonal_core_math_Limits.UINT16_MAX = 65535;
de_polygonal_core_math_Limits.INT32_MIN = -2147483648;
de_polygonal_core_math_Limits.INT32_MAX = 2147483647;
de_polygonal_core_math_Limits.UINT32_MAX = -1;
de_polygonal_core_math_Limits.INT_BITS = 32;
de_polygonal_core_math_Limits.FLOAT_MAX = 3.4028234663852886e+38;
de_polygonal_core_math_Limits.FLOAT_MIN = -3.4028234663852886e+38;
de_polygonal_core_math_Limits.DOUBLE_MAX = 1.7976931348623157e+308;
de_polygonal_core_math_Limits.DOUBLE_MIN = -1.7976931348623157e+308;
de_polygonal_core_math_Mathematics.NaN = NaN;
de_polygonal_core_math_Mathematics.POSITIVE_INFINITY = Infinity;
de_polygonal_core_math_Mathematics.NEGATIVE_INFINITY = -Infinity;
de_polygonal_core_math_Mathematics.ZERO_TOLERANCE = 1e-08;
de_polygonal_core_math_Mathematics.RAD_DEG = 57.29577951308232;
de_polygonal_core_math_Mathematics.DEG_RAD = 0.017453292519943295;
de_polygonal_core_math_Mathematics.LN2 = 0.6931471805599453;
de_polygonal_core_math_Mathematics.LN10 = 2.302585092994046;
de_polygonal_core_math_Mathematics.PI_OVER_2 = 1.5707963267948966;
de_polygonal_core_math_Mathematics.PI_OVER_4 = 0.7853981633974483;
de_polygonal_core_math_Mathematics.PI = 3.141592653589793;
de_polygonal_core_math_Mathematics.PI2 = 6.283185307179586;
de_polygonal_core_math_Mathematics.EPS = 1e-6;
de_polygonal_core_math_Mathematics.SQRT2 = 1.414213562373095;
de_polygonal_ds_Bits.BIT_01 = 1;
de_polygonal_ds_Bits.BIT_02 = 2;
de_polygonal_ds_Bits.BIT_03 = 4;
de_polygonal_ds_Bits.BIT_04 = 8;
de_polygonal_ds_Bits.BIT_05 = 16;
de_polygonal_ds_Bits.BIT_06 = 32;
de_polygonal_ds_Bits.BIT_07 = 64;
de_polygonal_ds_Bits.BIT_08 = 128;
de_polygonal_ds_Bits.BIT_09 = 256;
de_polygonal_ds_Bits.BIT_10 = 512;
de_polygonal_ds_Bits.BIT_11 = 1024;
de_polygonal_ds_Bits.BIT_12 = 2048;
de_polygonal_ds_Bits.BIT_13 = 4096;
de_polygonal_ds_Bits.BIT_14 = 8192;
de_polygonal_ds_Bits.BIT_15 = 16384;
de_polygonal_ds_Bits.BIT_16 = 32768;
de_polygonal_ds_Bits.BIT_17 = 65536;
de_polygonal_ds_Bits.BIT_18 = 131072;
de_polygonal_ds_Bits.BIT_19 = 262144;
de_polygonal_ds_Bits.BIT_20 = 524288;
de_polygonal_ds_Bits.BIT_21 = 1048576;
de_polygonal_ds_Bits.BIT_22 = 2097152;
de_polygonal_ds_Bits.BIT_23 = 4194304;
de_polygonal_ds_Bits.BIT_24 = 8388608;
de_polygonal_ds_Bits.BIT_25 = 16777216;
de_polygonal_ds_Bits.BIT_26 = 33554432;
de_polygonal_ds_Bits.BIT_27 = 67108864;
de_polygonal_ds_Bits.BIT_28 = 134217728;
de_polygonal_ds_Bits.BIT_29 = 268435456;
de_polygonal_ds_Bits.BIT_30 = 536870912;
de_polygonal_ds_Bits.BIT_31 = 1073741824;
de_polygonal_ds_Bits.BIT_32 = -2147483648;
de_polygonal_ds_Bits.ALL = -1;
de_polygonal_ds_HashKey._counter = 0;
de_polygonal_ds_IntHashSet.VAL_ABSENT = -2147483648;
de_polygonal_ds_IntHashSet.EMPTY_SLOT = -1;
de_polygonal_ds_IntHashSet.NULL_POINTER = -1;
de_polygonal_ds_IntIntHashTable.KEY_ABSENT = -2147483648;
de_polygonal_ds_IntIntHashTable.VAL_ABSENT = -2147483648;
de_polygonal_ds_IntIntHashTable.EMPTY_SLOT = -1;
de_polygonal_ds_IntIntHashTable.NULL_POINTER = -1;
de_polygonal_ds_tools_GrowthRate.FIXED = 0;
de_polygonal_ds_tools_GrowthRate.MILD = -1;
de_polygonal_ds_tools_GrowthRate.NORMAL = -2;
de_polygonal_ds_tools_GrowthRate.DOUBLE = -3;
haxe_Serializer.USE_CACHE = false;
haxe_Serializer.USE_ENUM_INDEX = false;
haxe_Serializer.BASE64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789%:";
haxe_Unserializer.DEFAULT_RESOLVER = Type;
haxe_Unserializer.BASE64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789%:";
haxe_ds_ObjectMap.count = 0;
haxe_io_FPHelper.i64tmp = (function($this) {
	var $r;
	var x = new haxe__$Int64__$_$_$Int64(0,0);
	$r = x;
	return $r;
}(this));
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
js_html_compat_Uint8Array.BYTES_PER_ELEMENT = 1;
textifician_mapping_ArcNodeVM.__meta__ = { fields : { val : { inspect : [{ _sync : "getSync_newInstance", _classes : ["primaryArc"]}]}}};
textifician_mapping_ArcNodeVM.__rtti = "<class path=\"textifician.mapping.ArcNodeVM\" params=\"\">\n\t<val public=\"1\">\n\t\t<c path=\"textifician.mapping.ArcPacket\"/>\n\t\t<meta><m n=\"inspect\"><e>{_sync:\"getSync_newInstance\",_classes:[\"primaryArc\"]}</e></m></meta>\n\t</val>\n\t<new public=\"1\" set=\"method\" line=\"14\"><f a=\"\"><x path=\"Void\"/></f></new>\n\t<meta>\n\t\t<m n=\":directlyUsed\"/>\n\t\t<m n=\":rtti\"/>\n\t\t<m n=\":expose\"/>\n\t</meta>\n</class>";
textifician_mapping_ArcPacket.__meta__ = { fields : { flags : { inspect : [{ _sync : "getSync_equal"}], bitmask : ["FLAG"]}, label : { inspect : [{ _sync : "getSync_equal"}]}, description : { inspect : [{ display : "textarea", _sync : "getSync_equal"}]}, cardinal : { inspect : [{ display : "selector", _sync : "getSync_flipInt"}], choices : ["CARDINAL"]}, pathArcInfo : { inspect : [{ _sync : "getSync_newInstance"}]}}};
textifician_mapping_ArcPacket.__rtti = "<class path=\"textifician.mapping.ArcPacket\" params=\"\">\n\t<CARDINAL_AUTO public=\"1\" get=\"inline\" set=\"null\" expr=\"0\" line=\"14\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e>0</e></m></meta>\n\t</CARDINAL_AUTO>\n\t<CARDINAL_EAST public=\"1\" get=\"inline\" set=\"null\" expr=\"1\" line=\"15\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e>1</e></m></meta>\n\t</CARDINAL_EAST>\n\t<CARDINAL_SOUTH_EAST public=\"1\" get=\"inline\" set=\"null\" expr=\"2\" line=\"16\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e>2</e></m></meta>\n\t</CARDINAL_SOUTH_EAST>\n\t<CARDINAL_SOUTH public=\"1\" get=\"inline\" set=\"null\" expr=\"3\" line=\"17\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e>3</e></m></meta>\n\t</CARDINAL_SOUTH>\n\t<CARDINAL_SOUTH_WEST public=\"1\" get=\"inline\" set=\"null\" expr=\"4\" line=\"18\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e>4</e></m></meta>\n\t</CARDINAL_SOUTH_WEST>\n\t<CARDINAL_UP public=\"1\" get=\"inline\" set=\"null\" expr=\"5\" line=\"19\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e>5</e></m></meta>\n\t</CARDINAL_UP>\n\t<CARDINAL_WEST public=\"1\" get=\"inline\" set=\"null\" expr=\"-1\" line=\"20\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e>-1</e></m></meta>\n\t</CARDINAL_WEST>\n\t<CARDINAL_NORTH_WEST public=\"1\" get=\"inline\" set=\"null\" expr=\"-2\" line=\"21\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e>-2</e></m></meta>\n\t</CARDINAL_NORTH_WEST>\n\t<CARDINAL_NORTH public=\"1\" get=\"inline\" set=\"null\" expr=\"-3\" line=\"22\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e>-3</e></m></meta>\n\t</CARDINAL_NORTH>\n\t<CARDINAL_NORTH_EAST public=\"1\" get=\"inline\" set=\"null\" expr=\"-4\" line=\"23\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e>-4</e></m></meta>\n\t</CARDINAL_NORTH_EAST>\n\t<CARDINAL_DOWN public=\"1\" get=\"inline\" set=\"null\" expr=\"-5\" line=\"24\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e>-5</e></m></meta>\n\t</CARDINAL_DOWN>\n\t<FLAG_VISIBILITY_ONLY public=\"1\" get=\"inline\" set=\"null\" expr=\"(1&lt;&lt;0)\" line=\"28\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e><![CDATA[(1<<0)]]></e></m></meta>\n\t</FLAG_VISIBILITY_ONLY>\n\t<FLAG_TELEPORT public=\"1\" get=\"inline\" set=\"null\" expr=\"(1&lt;&lt;1)\" line=\"29\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e><![CDATA[(1<<1)]]></e></m></meta>\n\t</FLAG_TELEPORT>\n\t<getSync_equal public=\"1\" get=\"inline\" set=\"null\" line=\"50\" static=\"1\"><f a=\"val:oldValue\">\n\t<d/>\n\t<d/>\n\t<d/>\n</f></getSync_equal>\n\t<getSync_ratioComplement public=\"1\" get=\"inline\" set=\"null\" line=\"53\" static=\"1\"><f a=\"val:oldValue\">\n\t<d/>\n\t<d/>\n\t<d/>\n</f></getSync_ratioComplement>\n\t<getSync_flipInt public=\"1\" get=\"inline\" set=\"null\" line=\"61\" static=\"1\"><f a=\"val:oldValue\">\n\t<d/>\n\t<d/>\n\t<d/>\n</f></getSync_flipInt>\n\t<getSync_newInstance public=\"1\" get=\"inline\" set=\"null\" line=\"64\" static=\"1\"><f a=\"val:oldValue\">\n\t<d/>\n\t<d/>\n\t<d/>\n</f></getSync_newInstance>\n\t<getSync_newEmptyInstance public=\"1\" get=\"inline\" set=\"null\" line=\"67\" static=\"1\"><f a=\"val:oldValue\">\n\t<d/>\n\t<d/>\n\t<d/>\n</f></getSync_newEmptyInstance>\n\t<_tjsonParse get=\"inline\" set=\"null\" line=\"71\" static=\"1\"><f a=\"val\">\n\t<d/>\n\t<d/>\n</f></_tjsonParse>\n\t<flags public=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta>\n\t\t\t<m n=\"inspect\"><e>{_sync:\"getSync_equal\"}</e></m>\n\t\t\t<m n=\"bitmask\"><e>\"FLAG\"</e></m>\n\t\t</meta>\n\t</flags>\n\t<label public=\"1\">\n\t\t<c path=\"String\"/>\n\t\t<meta><m n=\"inspect\"><e>{_sync:\"getSync_equal\"}</e></m></meta>\n\t</label>\n\t<description public=\"1\">\n\t\t<c path=\"String\"/>\n\t\t<meta><m n=\"inspect\"><e>{display:\"textarea\",_sync:\"getSync_equal\"}</e></m></meta>\n\t</description>\n\t<cardinal public=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta>\n\t\t\t<m n=\"inspect\"><e>{display:\"selector\",_sync:\"getSync_flipInt\"}</e></m>\n\t\t\t<m n=\"choices\"><e>\"CARDINAL\"</e></m>\n\t\t</meta>\n\t</cardinal>\n\t<pathArcInfo public=\"1\">\n\t\t<c path=\"textifician.mapping.PathArcInfo\"/>\n\t\t<meta><m n=\"inspect\"><e>{_sync:\"getSync_newInstance\"}</e></m></meta>\n\t</pathArcInfo>\n\t<toString public=\"1\" set=\"method\" line=\"39\"><f a=\"\"><c path=\"String\"/></f></toString>\n\t<new public=\"1\" set=\"method\" line=\"43\"><f a=\"\"><x path=\"Void\"/></f></new>\n\t<meta>\n\t\t<m n=\":rtti\"/>\n\t\t<m n=\":expose\"/>\n\t</meta>\n</class>";
textifician_mapping_ArcPacket.CARDINAL_AUTO = 0;
textifician_mapping_ArcPacket.CARDINAL_EAST = 1;
textifician_mapping_ArcPacket.CARDINAL_SOUTH_EAST = 2;
textifician_mapping_ArcPacket.CARDINAL_SOUTH = 3;
textifician_mapping_ArcPacket.CARDINAL_SOUTH_WEST = 4;
textifician_mapping_ArcPacket.CARDINAL_UP = 5;
textifician_mapping_ArcPacket.CARDINAL_WEST = -1;
textifician_mapping_ArcPacket.CARDINAL_NORTH_WEST = -2;
textifician_mapping_ArcPacket.CARDINAL_NORTH = -3;
textifician_mapping_ArcPacket.CARDINAL_NORTH_EAST = -4;
textifician_mapping_ArcPacket.CARDINAL_DOWN = -5;
textifician_mapping_ArcPacket.FLAG_VISIBILITY_ONLY = 1;
textifician_mapping_ArcPacket.FLAG_TELEPORT = 2;
textifician_mapping_PathArcInfo.__meta__ = { fields : { breakpoint : { inspect : [{ _sync : "getSync_ratioComplement", step : 0.01, value : 0.5, display : "range", min : 0, max : 1}]}, customDistance : { inspect : [{ _sync : "getSync_equal"}]}}};
textifician_mapping_PathArcInfo.__rtti = "<class path=\"textifician.mapping.PathArcInfo\" params=\"\" module=\"textifician.mapping.ArcPacket\">\n\t<breakpoint public=\"1\">\n\t\t<x path=\"Float\"/>\n\t\t<meta><m n=\"inspect\"><e>{_sync:\"getSync_ratioComplement\",step:0.01,value:0.5,display:\"range\",min:0,max:1}</e></m></meta>\n\t</breakpoint>\n\t<customDistance public=\"1\">\n\t\t<x path=\"Float\"/>\n\t\t<meta><m n=\"inspect\"><e>{_sync:\"getSync_equal\"}</e></m></meta>\n\t</customDistance>\n\t<new public=\"1\" set=\"method\" line=\"84\"><f a=\"\"><x path=\"Void\"/></f></new>\n\t<meta>\n\t\t<m n=\":rtti\"/>\n\t\t<m n=\":expose\"/>\n\t</meta>\n</class>";
textifician_mapping_IndoorLocationSpecs.__meta__ = { fields : { wallHeight : { inspect : null}, wallThickness : { inspect : null}, wallStrength : { inspect : null}, ceilingThickness : { inspect : null}, ceilingStrength : { inspect : null}}};
textifician_mapping_IndoorLocationSpecs.__rtti = "<class path=\"textifician.mapping.IndoorLocationSpecs\" params=\"\">\n\t<DEFAULT_WALL_HEIGHT public=\"1\" expr=\"1\" line=\"17\" static=\"1\">\n\t\t<x path=\"Float\"/>\n\t\t<meta><m n=\":value\"><e>1</e></m></meta>\n\t</DEFAULT_WALL_HEIGHT>\n\t<DEFAULT_WALL_THICKNESS public=\"1\" expr=\"1\" line=\"18\" static=\"1\">\n\t\t<x path=\"Float\"/>\n\t\t<meta><m n=\":value\"><e>1</e></m></meta>\n\t</DEFAULT_WALL_THICKNESS>\n\t<DEFAULT_WALL_STRENGTH public=\"1\" expr=\"1\" line=\"19\" static=\"1\">\n\t\t<x path=\"Float\"/>\n\t\t<meta><m n=\":value\"><e>1</e></m></meta>\n\t</DEFAULT_WALL_STRENGTH>\n\t<DEFAULT_CEILING_THICKNESS public=\"1\" expr=\"1\" line=\"20\" static=\"1\">\n\t\t<x path=\"Float\"/>\n\t\t<meta><m n=\":value\"><e>1</e></m></meta>\n\t</DEFAULT_CEILING_THICKNESS>\n\t<DEFAULT_CEILING_STRENGTH public=\"1\" expr=\"1\" line=\"21\" static=\"1\">\n\t\t<x path=\"Float\"/>\n\t\t<meta><m n=\":value\"><e>1</e></m></meta>\n\t</DEFAULT_CEILING_STRENGTH>\n\t<create public=\"1\" set=\"method\" line=\"44\" static=\"1\">\n\t\t<f a=\"?wallHeight:?wallThickness:?wallStrength:?ceilingThickness:?ceilingStrength\" v=\"-1:-1:-1:-1:-1\">\n\t\t\t<x path=\"Float\"/>\n\t\t\t<x path=\"Float\"/>\n\t\t\t<x path=\"Float\"/>\n\t\t\t<x path=\"Float\"/>\n\t\t\t<x path=\"Float\"/>\n\t\t\t<c path=\"textifician.mapping.IndoorLocationSpecs\"/>\n\t\t</f>\n\t\t<meta><m n=\":value\"><e>{ceilingStrength:-1,ceilingThickness:-1,wallStrength:-1,wallThickness:-1,wallHeight:-1}</e></m></meta>\n\t</create>\n\t<wallHeight public=\"1\">\n\t\t<x path=\"Float\"/>\n\t\t<meta><m n=\"inspect\"/></meta>\n\t</wallHeight>\n\t<wallThickness public=\"1\">\n\t\t<x path=\"Float\"/>\n\t\t<meta><m n=\"inspect\"/></meta>\n\t</wallThickness>\n\t<wallStrength public=\"1\">\n\t\t<x path=\"Float\"/>\n\t\t<meta><m n=\"inspect\"/></meta>\n\t</wallStrength>\n\t<ceilingThickness public=\"1\">\n\t\t<x path=\"Float\"/>\n\t\t<meta><m n=\"inspect\"/></meta>\n\t</ceilingThickness>\n\t<ceilingStrength public=\"1\">\n\t\t<x path=\"Float\"/>\n\t\t<meta><m n=\"inspect\"/></meta>\n\t</ceilingStrength>\n\t<toString public=\"1\" set=\"method\" line=\"55\"><f a=\"\"><c path=\"String\"/></f></toString>\n\t<new public=\"1\" set=\"method\" line=\"24\"><f a=\"\"><x path=\"Void\"/></f></new>\n\t<meta>\n\t\t<m n=\":directlyUsed\"/>\n\t\t<m n=\":rtti\"/>\n\t\t<m n=\":expose\"/>\n\t</meta>\n</class>";
textifician_mapping_IndoorLocationSpecs.DEFAULT_WALL_HEIGHT = 1;
textifician_mapping_IndoorLocationSpecs.DEFAULT_WALL_THICKNESS = 1;
textifician_mapping_IndoorLocationSpecs.DEFAULT_WALL_STRENGTH = 1;
textifician_mapping_IndoorLocationSpecs.DEFAULT_CEILING_THICKNESS = 1;
textifician_mapping_IndoorLocationSpecs.DEFAULT_CEILING_STRENGTH = 1;
textifician_mapping_LocationDefinition.__meta__ = { fields : { id : { inspect : [{ _readonly : true}]}, label : { inspect : null}, description : { inspect : [{ display : "textarea"}]}, flags : { inspect : null, bitmask : ["FLAG"]}, size : { inspect : null}, type : { inspect : [{ display : "selector"}], choices : ["TYPE"]}, envFlags : { inspect : null, bitmask : ["ENV"]}, defaultLighting : { inspect : [{ display : "range", value : 2}], range : ["LIGHTING"]}, speedcap : { inspect : [{ display : "selector"}], choices : ["SPEEDCAP"]}, priorityIndex : { inspect : null}, indoorLocationSpecs : { inspect : null}, makeDoor : { inspect : null}, resetShelterFlags : { inspect : null}, resetShelterWallFlags : { inspect : null}, resetShelterCeilingFlags : { inspect : null}, makeFullyIndoor : { inspect : null}, makeFullyOutdoor : { inspect : null}, setupShelterAmounts : { inspect : [[{ inspect : { display : "range"}, range : "SHELTER"},{ inspect : { display : "range"}, range : "SHELTER"}]]}, setWallAmount : { inspect : [{ inspect : { display : "range"}, range : "SHELTER"}]}, setCeilingAmount : { inspect : [{ inspect : { display : "range"}, range : "SHELTER"}]}}};
textifician_mapping_LocationDefinition.__rtti = "<class path=\"textifician.mapping.LocationDefinition\" params=\"\">\n\t<FLAG_ENTRANCE public=\"1\" get=\"inline\" set=\"null\" expr=\"(1&lt;&lt;0)\" line=\"10\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e><![CDATA[(1<<0)]]></e></m></meta>\n\t</FLAG_ENTRANCE>\n\t<FLAG_DOOR public=\"1\" get=\"inline\" set=\"null\" expr=\"(1&lt;&lt;1)\" line=\"11\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e><![CDATA[(1<<1)]]></e></m></meta>\n\t</FLAG_DOOR>\n\t<FLAG_KEY public=\"1\" get=\"inline\" set=\"null\" expr=\"(1&lt;&lt;2)\" line=\"12\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e><![CDATA[(1<<2)]]></e></m></meta>\n\t</FLAG_KEY>\n\t<FLAG_LANDMARK public=\"1\" get=\"inline\" set=\"null\" expr=\"(1&lt;&lt;3)\" line=\"13\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e><![CDATA[(1<<3)]]></e></m></meta>\n\t</FLAG_LANDMARK>\n\t<FLAG_VIS_ENCLOSED public=\"1\" get=\"inline\" set=\"null\" expr=\"(1&lt;&lt;4)\" line=\"14\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e><![CDATA[(1<<4)]]></e></m></meta>\n\t</FLAG_VIS_ENCLOSED>\n\t<TYPE_POINT public=\"1\" get=\"inline\" set=\"null\" expr=\"0\" line=\"16\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e>0</e></m></meta>\n\t</TYPE_POINT>\n\t<TYPE_PATH public=\"1\" get=\"inline\" set=\"null\" expr=\"1\" line=\"17\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e>1</e></m></meta>\n\t</TYPE_PATH>\n\t<TYPE_REGION public=\"1\" get=\"inline\" set=\"null\" expr=\"2\" line=\"18\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e>2</e></m></meta>\n\t</TYPE_REGION>\n\t<ENV_WALL_1 public=\"1\" get=\"inline\" set=\"null\" expr=\"(1&lt;&lt;0)\" line=\"20\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e><![CDATA[(1<<0)]]></e></m></meta>\n\t</ENV_WALL_1>\n\t<ENV_WALL_2 public=\"1\" get=\"inline\" set=\"null\" expr=\"(1&lt;&lt;1)\" line=\"21\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e><![CDATA[(1<<1)]]></e></m></meta>\n\t</ENV_WALL_2>\n\t<ENV_CEILING_1 public=\"1\" get=\"inline\" set=\"null\" expr=\"(1&lt;&lt;2)\" line=\"22\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e><![CDATA[(1<<2)]]></e></m></meta>\n\t</ENV_CEILING_1>\n\t<ENV_CEILING_2 public=\"1\" get=\"inline\" set=\"null\" expr=\"(1&lt;&lt;3)\" line=\"23\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e><![CDATA[(1<<3)]]></e></m></meta>\n\t</ENV_CEILING_2>\n\t<LIGHTING_NONE_OR_OUT public=\"1\" get=\"inline\" set=\"null\" expr=\"0\" line=\"27\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e>0</e></m></meta>\n\t</LIGHTING_NONE_OR_OUT>\n\t<LIGHTING_DIM public=\"1\" get=\"inline\" set=\"null\" expr=\"1\" line=\"28\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e>1</e></m></meta>\n\t</LIGHTING_DIM>\n\t<LIGHTING_NORMAL public=\"1\" get=\"inline\" set=\"null\" expr=\"2\" line=\"29\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e>2</e></m></meta>\n\t</LIGHTING_NORMAL>\n\t<LIGHTING_BRIGHT public=\"1\" get=\"inline\" set=\"null\" expr=\"3\" line=\"30\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e>3</e></m></meta>\n\t</LIGHTING_BRIGHT>\n\t<DENSITY_NONE public=\"1\" get=\"inline\" set=\"null\" expr=\"0\" line=\"32\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e>0</e></m></meta>\n\t</DENSITY_NONE>\n\t<DENSITY_VERY_SPARSE public=\"1\" get=\"inline\" set=\"null\" expr=\"1\" line=\"33\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e>1</e></m></meta>\n\t</DENSITY_VERY_SPARSE>\n\t<DENSITY_SPARSE public=\"1\" get=\"inline\" set=\"null\" expr=\"2\" line=\"34\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e>2</e></m></meta>\n\t</DENSITY_SPARSE>\n\t<DENSITY_AVERAGE public=\"1\" get=\"inline\" set=\"null\" expr=\"3\" line=\"35\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e>3</e></m></meta>\n\t</DENSITY_AVERAGE>\n\t<DENSITY_DENSE public=\"1\" get=\"inline\" set=\"null\" expr=\"4\" line=\"36\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e>4</e></m></meta>\n\t</DENSITY_DENSE>\n\t<DENSITY_VERY_DENSE public=\"1\" get=\"inline\" set=\"null\" expr=\"5\" line=\"37\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e>5</e></m></meta>\n\t</DENSITY_VERY_DENSE>\n\t<SHELTER_NONE public=\"1\" get=\"inline\" set=\"null\" expr=\"0\" line=\"39\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e>0</e></m></meta>\n\t</SHELTER_NONE>\n\t<SHELTER_SPARSE public=\"1\" get=\"inline\" set=\"null\" expr=\"1\" line=\"40\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e>1</e></m></meta>\n\t</SHELTER_SPARSE>\n\t<SHELTER_HALF public=\"1\" get=\"inline\" set=\"null\" expr=\"2\" line=\"41\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e>2</e></m></meta>\n\t</SHELTER_HALF>\n\t<SHELTER_FULL public=\"1\" get=\"inline\" set=\"null\" expr=\"3\" line=\"42\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e>3</e></m></meta>\n\t</SHELTER_FULL>\n\t<SPEEDCAP_NONE public=\"1\" get=\"inline\" set=\"null\" expr=\"0\" line=\"44\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e>0</e></m></meta>\n\t</SPEEDCAP_NONE>\n\t<SPEEDCAP_CRAWL public=\"1\" get=\"inline\" set=\"null\" expr=\"1\" line=\"45\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e>1</e></m></meta>\n\t</SPEEDCAP_CRAWL>\n\t<SPEEDCAP_CAUTIOUS public=\"1\" get=\"inline\" set=\"null\" expr=\"2\" line=\"46\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e>2</e></m></meta>\n\t</SPEEDCAP_CAUTIOUS>\n\t<SPEEDCAP_NORMAL public=\"1\" get=\"inline\" set=\"null\" expr=\"3\" line=\"47\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e>3</e></m></meta>\n\t</SPEEDCAP_NORMAL>\n\t<SPEEDCAP_HURRIED public=\"1\" get=\"inline\" set=\"null\" expr=\"4\" line=\"48\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e>4</e></m></meta>\n\t</SPEEDCAP_HURRIED>\n\t<create public=\"1\" set=\"method\" line=\"74\" static=\"1\">\n\t\t<f a=\"type:label:?id\" v=\"::null\">\n\t\t\t<x path=\"Int\"/>\n\t\t\t<c path=\"String\"/>\n\t\t\t<c path=\"String\"/>\n\t\t\t<c path=\"textifician.mapping.LocationDefinition\"/>\n\t\t</f>\n\t\t<meta><m n=\":value\"><e>{id:null}</e></m></meta>\n\t</create>\n\t<createWithMatchingId public=\"1\" set=\"method\" line=\"95\" static=\"1\">\n\t\t<f a=\"type:label:?id:?doSlugify:?camelCase\" v=\"::null:false:false\">\n\t\t\t<x path=\"Int\"/>\n\t\t\t<c path=\"String\"/>\n\t\t\t<c path=\"String\"/>\n\t\t\t<x path=\"Bool\"/>\n\t\t\t<x path=\"Bool\"/>\n\t\t\t<c path=\"textifician.mapping.LocationDefinition\"/>\n\t\t</f>\n\t\t<meta><m n=\":value\"><e>{camelCase:false,doSlugify:false,id:null}</e></m></meta>\n\t</createWithMatchingId>\n\t<slugify public=\"1\" get=\"inline\" set=\"null\" line=\"117\" static=\"1\"><f a=\"label\">\n\t<c path=\"String\"/>\n\t<c path=\"String\"/>\n</f></slugify>\n\t<camelizeSlug public=\"1\" get=\"inline\" set=\"null\" line=\"139\" static=\"1\"><f a=\"slug\">\n\t<c path=\"String\"/>\n\t<c path=\"String\"/>\n</f></camelizeSlug>\n\t<getLocationDefinitionTypeLabel public=\"1\" set=\"method\" line=\"223\" static=\"1\"><f a=\"val\">\n\t<x path=\"Int\"/>\n\t<c path=\"String\"/>\n</f></getLocationDefinitionTypeLabel>\n\t<id public=\"1\">\n\t\t<c path=\"String\"/>\n\t\t<meta><m n=\"inspect\"><e>{_readonly:true}</e></m></meta>\n\t</id>\n\t<label public=\"1\">\n\t\t<c path=\"String\"/>\n\t\t<meta><m n=\"inspect\"/></meta>\n\t</label>\n\t<description public=\"1\">\n\t\t<c path=\"String\"/>\n\t\t<meta><m n=\"inspect\"><e>{display:\"textarea\"}</e></m></meta>\n\t</description>\n\t<flags public=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta>\n\t\t\t<m n=\"inspect\"/>\n\t\t\t<m n=\"bitmask\"><e>\"FLAG\"</e></m>\n\t\t</meta>\n\t</flags>\n\t<size public=\"1\">\n\t\t<x path=\"Float\"/>\n\t\t<meta><m n=\"inspect\"/></meta>\n\t</size>\n\t<type public=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta>\n\t\t\t<m n=\"inspect\"><e>{display:\"selector\"}</e></m>\n\t\t\t<m n=\"choices\"><e>\"TYPE\"</e></m>\n\t\t</meta>\n\t</type>\n\t<envFlags public=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta>\n\t\t\t<m n=\"inspect\"/>\n\t\t\t<m n=\"bitmask\"><e>\"ENV\"</e></m>\n\t\t</meta>\n\t</envFlags>\n\t<defaultLighting public=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta>\n\t\t\t<m n=\"inspect\"><e>{display:\"range\",value:2}</e></m>\n\t\t\t<m n=\"range\"><e>\"LIGHTING\"</e></m>\n\t\t</meta>\n\t</defaultLighting>\n\t<generalFixtures public=\"1\"><c path=\"Array\"><c path=\"String\"/></c></generalFixtures>\n\t<speedcap public=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta>\n\t\t\t<m n=\"inspect\"><e>{display:\"selector\"}</e></m>\n\t\t\t<m n=\"choices\"><e>\"SPEEDCAP\"</e></m>\n\t\t</meta>\n\t</speedcap>\n\t<priorityIndex public=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\"inspect\"/></meta>\n\t</priorityIndex>\n\t<indoorLocationSpecs public=\"1\">\n\t\t<c path=\"textifician.mapping.IndoorLocationSpecs\"/>\n\t\t<meta><m n=\"inspect\"/></meta>\n\t</indoorLocationSpecs>\n\t<setSize public=\"1\" set=\"method\" line=\"86\"><f a=\"val\">\n\t<x path=\"Float\"/>\n\t<c path=\"textifician.mapping.LocationDefinition\"/>\n</f></setSize>\n\t<setDescription public=\"1\" set=\"method\" line=\"90\"><f a=\"val\">\n\t<c path=\"String\"/>\n\t<c path=\"textifician.mapping.LocationDefinition\"/>\n</f></setDescription>\n\t<toString public=\"1\" set=\"method\" line=\"113\"><f a=\"\"><c path=\"String\"/></f></toString>\n\t<makeDoor public=\"1\" set=\"method\" line=\"155\">\n\t\t<f a=\"?isDoor:?implyEntrance\" v=\"true:true\">\n\t\t\t<x path=\"Bool\"/>\n\t\t\t<x path=\"Bool\"/>\n\t\t\t<c path=\"textifician.mapping.LocationDefinition\"/>\n\t\t</f>\n\t\t<meta>\n\t\t\t<m n=\":value\"><e>{implyEntrance:true,isDoor:true}</e></m>\n\t\t\t<m n=\"inspect\"/>\n\t\t</meta>\n\t</makeDoor>\n\t<makeEntrance public=\"1\" set=\"method\" line=\"166\">\n\t\t<f a=\"?val\" v=\"true\">\n\t\t\t<x path=\"Bool\"/>\n\t\t\t<c path=\"textifician.mapping.LocationDefinition\"/>\n\t\t</f>\n\t\t<meta><m n=\":value\"><e>{val:true}</e></m></meta>\n\t</makeEntrance>\n\t<makeKey public=\"1\" set=\"method\" line=\"176\">\n\t\t<f a=\"?val\" v=\"true\">\n\t\t\t<x path=\"Bool\"/>\n\t\t\t<c path=\"textifician.mapping.LocationDefinition\"/>\n\t\t</f>\n\t\t<meta><m n=\":value\"><e>{val:true}</e></m></meta>\n\t</makeKey>\n\t<makeLandmark public=\"1\" set=\"method\" line=\"186\">\n\t\t<f a=\"?val\" v=\"true\">\n\t\t\t<x path=\"Bool\"/>\n\t\t\t<c path=\"textifician.mapping.LocationDefinition\"/>\n\t\t</f>\n\t\t<meta><m n=\":value\"><e>{val:true}</e></m></meta>\n\t</makeLandmark>\n\t<resetShelterFlags public=\"1\" get=\"inline\" set=\"null\" line=\"196\">\n\t\t<f a=\"\"><x path=\"Void\"/></f>\n\t\t<meta><m n=\"inspect\"/></meta>\n\t</resetShelterFlags>\n\t<resetShelterWallFlags public=\"1\" get=\"inline\" set=\"null\" line=\"199\">\n\t\t<f a=\"\"><x path=\"Void\"/></f>\n\t\t<meta><m n=\"inspect\"/></meta>\n\t</resetShelterWallFlags>\n\t<resetShelterCeilingFlags public=\"1\" get=\"inline\" set=\"null\" line=\"202\">\n\t\t<f a=\"\"><x path=\"Void\"/></f>\n\t\t<meta><m n=\"inspect\"/></meta>\n\t</resetShelterCeilingFlags>\n\t<makeFullyIndoor public=\"1\" set=\"method\" line=\"206\">\n\t\t<f a=\"\"><c path=\"textifician.mapping.LocationDefinition\"/></f>\n\t\t<meta><m n=\"inspect\"/></meta>\n\t</makeFullyIndoor>\n\t<makeFullyOutdoor public=\"1\" set=\"method\" line=\"212\">\n\t\t<f a=\"\"><c path=\"textifician.mapping.LocationDefinition\"/></f>\n\t\t<meta><m n=\"inspect\"/></meta>\n\t</makeFullyOutdoor>\n\t<setupIndoorLocationSpecs public=\"1\" set=\"method\" line=\"218\"><f a=\"locationSpecs\">\n\t<c path=\"textifician.mapping.IndoorLocationSpecs\"/>\n\t<c path=\"textifician.mapping.LocationDefinition\"/>\n</f></setupIndoorLocationSpecs>\n\t<setupShelterAmounts public=\"1\" set=\"method\" line=\"234\">\n\t\t<f a=\"wallAmount:ceilingAmount\">\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<c path=\"textifician.mapping.LocationDefinition\"/>\n\t\t</f>\n\t\t<meta><m n=\"inspect\"><e>[{inspect:{display:\"range\"},range:\"SHELTER\"},{inspect:{display:\"range\"},range:\"SHELTER\"}]</e></m></meta>\n\t</setupShelterAmounts>\n\t<setWallAmount public=\"1\" set=\"method\" line=\"242\">\n\t\t<f a=\"wallAmount\">\n\t\t\t<x path=\"Int\"/>\n\t\t\t<c path=\"textifician.mapping.LocationDefinition\"/>\n\t\t</f>\n\t\t<meta><m n=\"inspect\"><e>{inspect:{display:\"range\"},range:\"SHELTER\"}</e></m></meta>\n\t</setWallAmount>\n\t<setCeilingAmount public=\"1\" set=\"method\" line=\"248\">\n\t\t<f a=\"ceilingAmount\">\n\t\t\t<x path=\"Int\"/>\n\t\t\t<c path=\"textifician.mapping.LocationDefinition\"/>\n\t\t</f>\n\t\t<meta><m n=\"inspect\"><e>{inspect:{display:\"range\"},range:\"SHELTER\"}</e></m></meta>\n\t</setCeilingAmount>\n\t<new public=\"1\" set=\"method\" line=\"254\"><f a=\"\"><x path=\"Void\"/></f></new>\n\t<meta>\n\t\t<m n=\":directlyUsed\"/>\n\t\t<m n=\":rtti\"/>\n\t\t<m n=\":expose\"/>\n\t</meta>\n</class>";
textifician_mapping_LocationDefinition.FLAG_ENTRANCE = 1;
textifician_mapping_LocationDefinition.FLAG_DOOR = 2;
textifician_mapping_LocationDefinition.FLAG_KEY = 4;
textifician_mapping_LocationDefinition.FLAG_LANDMARK = 8;
textifician_mapping_LocationDefinition.FLAG_VIS_ENCLOSED = 16;
textifician_mapping_LocationDefinition.TYPE_POINT = 0;
textifician_mapping_LocationDefinition.TYPE_PATH = 1;
textifician_mapping_LocationDefinition.TYPE_REGION = 2;
textifician_mapping_LocationDefinition.ENV_WALL_1 = 1;
textifician_mapping_LocationDefinition.ENV_WALL_2 = 2;
textifician_mapping_LocationDefinition.ENV_CEILING_1 = 4;
textifician_mapping_LocationDefinition.ENV_CEILING_2 = 8;
textifician_mapping_LocationDefinition.LIGHTING_NONE_OR_OUT = 0;
textifician_mapping_LocationDefinition.LIGHTING_DIM = 1;
textifician_mapping_LocationDefinition.LIGHTING_NORMAL = 2;
textifician_mapping_LocationDefinition.LIGHTING_BRIGHT = 3;
textifician_mapping_LocationDefinition.DENSITY_NONE = 0;
textifician_mapping_LocationDefinition.DENSITY_VERY_SPARSE = 1;
textifician_mapping_LocationDefinition.DENSITY_SPARSE = 2;
textifician_mapping_LocationDefinition.DENSITY_AVERAGE = 3;
textifician_mapping_LocationDefinition.DENSITY_DENSE = 4;
textifician_mapping_LocationDefinition.DENSITY_VERY_DENSE = 5;
textifician_mapping_LocationDefinition.SHELTER_NONE = 0;
textifician_mapping_LocationDefinition.SHELTER_SPARSE = 1;
textifician_mapping_LocationDefinition.SHELTER_HALF = 2;
textifician_mapping_LocationDefinition.SHELTER_FULL = 3;
textifician_mapping_LocationDefinition.SPEEDCAP_NONE = 0;
textifician_mapping_LocationDefinition.SPEEDCAP_CRAWL = 1;
textifician_mapping_LocationDefinition.SPEEDCAP_CAUTIOUS = 2;
textifician_mapping_LocationDefinition.SPEEDCAP_NORMAL = 3;
textifician_mapping_LocationDefinition.SPEEDCAP_HURRIED = 4;
textifician_mapping_LocationPacket.__meta__ = { fields : { x : { inspect : [{ _classes : ["position"], _readonly : true}]}, y : { inspect : [{ _classes : ["position"], _readonly : true}]}, z : { inspect : [{ _classes : ["position"]}]}, state : { inspect : null}}};
textifician_mapping_LocationPacket.__rtti = "<class path=\"textifician.mapping.LocationPacket\" params=\"\">\n\t<implements path=\"textifician.mapping.IXYZ\"/>\n\t<getTypeOfPacket public=\"1\" get=\"inline\" set=\"null\" line=\"34\" static=\"1\"><f a=\"locPacket\">\n\t<c path=\"textifician.mapping.LocationPacket\"/>\n\t<x path=\"Int\"/>\n</f></getTypeOfPacket>\n\t<getCategoryOfPacket public=\"1\" set=\"method\" line=\"37\" static=\"1\"><f a=\"locPacket\">\n\t<c path=\"textifician.mapping.LocationPacket\"/>\n\t<c path=\"String\"/>\n</f></getCategoryOfPacket>\n\t<def public=\"1\"><c path=\"textifician.mapping.LocationDefinition\"/></def>\n\t<defOverwrites public=\"1\"><d/></defOverwrites>\n\t<x public=\"1\">\n\t\t<x path=\"Float\"/>\n\t\t<meta><m n=\"inspect\"><e>{_classes:[\"position\"],_readonly:true}</e></m></meta>\n\t</x>\n\t<y public=\"1\">\n\t\t<x path=\"Float\"/>\n\t\t<meta><m n=\"inspect\"><e>{_classes:[\"position\"],_readonly:true}</e></m></meta>\n\t</y>\n\t<z public=\"1\">\n\t\t<x path=\"Float\"/>\n\t\t<meta><m n=\"inspect\"><e>{_classes:[\"position\"]}</e></m></meta>\n\t</z>\n\t<state public=\"1\">\n\t\t<c path=\"textifician.mapping.LocationState\"/>\n\t\t<meta><m n=\"inspect\"/></meta>\n\t</state>\n\t<reflectType expr=\"&quot;LocationPacket&quot;\" line=\"18\">\n\t\t<c path=\"String\"/>\n\t\t<meta><m n=\":value\"><e>\"LocationPacket\"</e></m></meta>\n\t</reflectType>\n\t<getLabel public=\"1\" set=\"method\" line=\"20\"><f a=\"\"><c path=\"String\"/></f></getLabel>\n\t<setEmptyDefOverwrites public=\"1\" get=\"inline\" set=\"null\" line=\"24\"><f a=\"\"><x path=\"Void\"/></f></setEmptyDefOverwrites>\n\t<setupNewDefOverwrites public=\"1\" set=\"method\" line=\"28\"><f a=\"obj\">\n\t<d/>\n\t<x path=\"Void\"/>\n</f></setupNewDefOverwrites>\n\t<applyDefOverwrites public=\"1\" get=\"inline\" set=\"null\" line=\"55\"><f a=\"obj\">\n\t<d/>\n\t<x path=\"Void\"/>\n</f></applyDefOverwrites>\n\t<convertOverwritesToLocationDef public=\"1\" set=\"method\" line=\"65\"><f a=\"\"><x path=\"Void\"/></f></convertOverwritesToLocationDef>\n\t<cloneOverwritesDynamic public=\"1\" set=\"method\" line=\"84\"><f a=\"\"><d/></f></cloneOverwritesDynamic>\n\t<new public=\"1\" set=\"method\" line=\"99\"><f a=\"\"><x path=\"Void\"/></f></new>\n\t<meta>\n\t\t<m n=\":directlyUsed\"/>\n\t\t<m n=\":rtti\"/>\n\t\t<m n=\":expose\"/>\n\t</meta>\n</class>";
textifician_mapping_LocationState.__meta__ = { fields : { notes : { inspect : [{ display : "textarea"}]}, flags : { inspect : null, bitmask : ["FLAG"]}, openDoorFully : { inspect : null}, openDoorPartially : { inspect : null}, closeDoor : { inspect : null}, closeAndLockDoor : { inspect : null}}};
textifician_mapping_LocationState.__rtti = "<class path=\"textifician.mapping.LocationState\" params=\"\">\n\t<FLAG_DOOR_LOCKED public=\"1\" get=\"inline\" set=\"null\" expr=\"(1&lt;&lt;0)\" line=\"12\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e><![CDATA[(1<<0)]]></e></m></meta>\n\t</FLAG_DOOR_LOCKED>\n\t<FLAG_DOOR_OPEN_1 public=\"1\" get=\"inline\" set=\"null\" expr=\"(1&lt;&lt;1)\" line=\"14\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e><![CDATA[(1<<1)]]></e></m></meta>\n\t</FLAG_DOOR_OPEN_1>\n\t<FLAG_DOOR_OPEN_2 public=\"1\" get=\"inline\" set=\"null\" expr=\"(1&lt;&lt;2)\" line=\"15\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e><![CDATA[(1<<2)]]></e></m></meta>\n\t</FLAG_DOOR_OPEN_2>\n\t<thingsHere public=\"1\"><c path=\"Array\"><d/></c></thingsHere>\n\t<notes public=\"1\">\n\t\t<c path=\"String\"/>\n\t\t<meta><m n=\"inspect\"><e>{display:\"textarea\"}</e></m></meta>\n\t</notes>\n\t<flags public=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta>\n\t\t\t<m n=\"inspect\"/>\n\t\t\t<m n=\"bitmask\"><e>\"FLAG\"</e></m>\n\t\t</meta>\n\t</flags>\n\t<customData public=\"1\"><d/></customData>\n\t<openDoorFully public=\"1\" set=\"method\" line=\"31\">\n\t\t<f a=\"\"><c path=\"textifician.mapping.LocationState\"/></f>\n\t\t<meta><m n=\"inspect\"/></meta>\n\t</openDoorFully>\n\t<openDoorPartially public=\"1\" set=\"method\" line=\"36\">\n\t\t<f a=\"?ajarOnly\" v=\"false\">\n\t\t\t<x path=\"Bool\"/>\n\t\t\t<c path=\"textifician.mapping.LocationState\"/>\n\t\t</f>\n\t\t<meta>\n\t\t\t<m n=\":value\"><e>{ajarOnly:false}</e></m>\n\t\t\t<m n=\"inspect\"/>\n\t\t</meta>\n\t</openDoorPartially>\n\t<closeDoor public=\"1\" set=\"method\" line=\"42\">\n\t\t<f a=\"\"><c path=\"textifician.mapping.LocationState\"/></f>\n\t\t<meta><m n=\"inspect\"/></meta>\n\t</closeDoor>\n\t<closeAndLockDoor public=\"1\" set=\"method\" line=\"46\">\n\t\t<f a=\"\"><c path=\"textifician.mapping.LocationState\"/></f>\n\t\t<meta><m n=\"inspect\"/></meta>\n\t</closeAndLockDoor>\n\t<lockDoor public=\"1\" set=\"method\" line=\"51\"><f a=\"\"><c path=\"textifician.mapping.LocationState\"/></f></lockDoor>\n\t<unlockDoor public=\"1\" set=\"method\" line=\"55\"><f a=\"\"><c path=\"textifician.mapping.LocationState\"/></f></unlockDoor>\n\t<toString public=\"1\" set=\"method\" line=\"60\"><f a=\"\"><c path=\"String\"/></f></toString>\n\t<new public=\"1\" set=\"method\" line=\"66\"><f a=\"\"><x path=\"Void\"/></f></new>\n\t<meta>\n\t\t<m n=\":rtti\"/>\n\t\t<m n=\":expose\"/>\n\t</meta>\n</class>";
textifician_mapping_LocationState.FLAG_DOOR_LOCKED = 1;
textifician_mapping_LocationState.FLAG_DOOR_OPEN_1 = 2;
textifician_mapping_LocationState.FLAG_DOOR_OPEN_2 = 4;
textifician_mapping_TextificianUtil.EPSILON = 1;
textifician_mapping_Zone.__meta__ = { fields : { id : { inspect : [{ _readonly : true}]}, label : { inspect : null}, size : { inspect : null}, scale : { inspect : null}, imageURL : { inspect : [{ _lazy : true}]}, x : { inspect : [{ _classes : ["position"], _readonly : true}]}, y : { inspect : [{ _classes : ["position"], _readonly : true}]}, z : { inspect : [{ _classes : ["position"]}]}, parentZone : { readonly : null}}};
textifician_mapping_Zone.__rtti = "<class path=\"textifician.mapping.Zone\" params=\"\">\n\t<implements path=\"textifician.mapping.IXYZ\"/>\n\t<DEFAULT_SCALE public=\"1\" expr=\"1\" line=\"16\" static=\"1\">\n\t\t<x path=\"Float\"/>\n\t\t<meta><m n=\":value\"><e>1</e></m></meta>\n\t</DEFAULT_SCALE>\n\t<ID_MATCH_LABEL public=\"1\" get=\"inline\" set=\"null\" expr=\"0\" line=\"46\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e>0</e></m></meta>\n\t</ID_MATCH_LABEL>\n\t<ID_SLUGIFY public=\"1\" get=\"inline\" set=\"null\" expr=\"1\" line=\"47\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e>1</e></m></meta>\n\t</ID_SLUGIFY>\n\t<ID_CAMELIZE public=\"1\" get=\"inline\" set=\"null\" expr=\"2\" line=\"48\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e>2</e></m></meta>\n\t</ID_CAMELIZE>\n\t<IDMODE public=\"1\" expr=\"ID_MATCH_LABEL\" line=\"50\" static=\"1\">\n\t\t<x path=\"Int\"/>\n\t\t<meta><m n=\":value\"><e>ID_MATCH_LABEL</e></m></meta>\n\t</IDMODE>\n\t<slugify public=\"1\" get=\"inline\" set=\"null\" line=\"52\" static=\"1\"><f a=\"label\">\n\t<c path=\"String\"/>\n\t<c path=\"String\"/>\n</f></slugify>\n\t<camelizeSlug public=\"1\" get=\"inline\" set=\"null\" line=\"59\" static=\"1\"><f a=\"slug\">\n\t<c path=\"String\"/>\n\t<c path=\"String\"/>\n</f></camelizeSlug>\n\t<resolveIdWithLabel public=\"1\" set=\"method\" line=\"68\" static=\"1\"><f a=\"label\">\n\t<c path=\"String\"/>\n\t<c path=\"String\"/>\n</f></resolveIdWithLabel>\n\t<create public=\"1\" set=\"method\" line=\"73\" static=\"1\">\n\t\t<f a=\"label:?id\" v=\":null\">\n\t\t\t<c path=\"String\"/>\n\t\t\t<c path=\"String\"/>\n\t\t\t<c path=\"textifician.mapping.Zone\"/>\n\t\t</f>\n\t\t<meta><m n=\":value\"><e>{id:null}</e></m></meta>\n\t</create>\n\t<setupNew public=\"1\" set=\"method\" line=\"83\" static=\"1\">\n\t\t<f a=\"label:?id:?x:?y:?z:?scale:?size\" v=\":null:0:0:0:1:-1\">\n\t\t\t<c path=\"String\"/>\n\t\t\t<c path=\"String\"/>\n\t\t\t<x path=\"Float\"/>\n\t\t\t<x path=\"Float\"/>\n\t\t\t<x path=\"Float\"/>\n\t\t\t<x path=\"Float\"/>\n\t\t\t<x path=\"Float\"/>\n\t\t\t<c path=\"textifician.mapping.Zone\"/>\n\t\t</f>\n\t\t<meta><m n=\":value\"><e>{size:-1,scale:1,z:0,y:0,x:0,id:null}</e></m></meta>\n\t</setupNew>\n\t<id public=\"1\">\n\t\t<c path=\"String\"/>\n\t\t<meta><m n=\"inspect\"><e>{_readonly:true}</e></m></meta>\n\t</id>\n\t<label public=\"1\">\n\t\t<c path=\"String\"/>\n\t\t<meta><m n=\"inspect\"/></meta>\n\t</label>\n\t<childNodes><c path=\"Array\"><c path=\"de.polygonal.ds.GraphNode\"><d/></c></c></childNodes>\n\t<size public=\"1\">\n\t\t<x path=\"Float\"/>\n\t\t<meta><m n=\"inspect\"/></meta>\n\t</size>\n\t<scale public=\"1\">\n\t\t<x path=\"Float\"/>\n\t\t<meta><m n=\"inspect\"/></meta>\n\t</scale>\n\t<imageURL public=\"1\" expr=\"&quot;https://s-media-cache-ak0.pinimg.com/736x/e4/89/8c/e4898c58d4713c8b4328fccf38287120.jpg&quot;\" line=\"24\">\n\t\t<c path=\"String\"/>\n\t\t<meta>\n\t\t\t<m n=\":value\"><e>\"https://s-media-cache-ak0.pinimg.com/736x/e4/89/8c/e4898c58d4713c8b4328fccf38287120.jpg\"</e></m>\n\t\t\t<m n=\"inspect\"><e>{_lazy:true}</e></m>\n\t\t</meta>\n\t</imageURL>\n\t<x public=\"1\">\n\t\t<x path=\"Float\"/>\n\t\t<meta><m n=\"inspect\"><e>{_classes:[\"position\"],_readonly:true}</e></m></meta>\n\t</x>\n\t<y public=\"1\">\n\t\t<x path=\"Float\"/>\n\t\t<meta><m n=\"inspect\"><e>{_classes:[\"position\"],_readonly:true}</e></m></meta>\n\t</y>\n\t<z public=\"1\">\n\t\t<x path=\"Float\"/>\n\t\t<meta><m n=\"inspect\"><e>{_classes:[\"position\"]}</e></m></meta>\n\t</z>\n\t<parentZone>\n\t\t<c path=\"textifician.mapping.Zone\"/>\n\t\t<meta><m n=\"readonly\"/></meta>\n\t</parentZone>\n\t<reflectType expr=\"&quot;Zone&quot;\" line=\"32\">\n\t\t<c path=\"String\"/>\n\t\t<meta><m n=\":value\"><e>\"Zone\"</e></m></meta>\n\t</reflectType>\n\t<setScale public=\"1\" set=\"method\" line=\"94\"><f a=\"scale\">\n\t<x path=\"Float\"/>\n\t<c path=\"textifician.mapping.Zone\"/>\n</f></setScale>\n\t<setSize public=\"1\" set=\"method\" line=\"98\"><f a=\"size\">\n\t<x path=\"Float\"/>\n\t<c path=\"textifician.mapping.Zone\"/>\n</f></setSize>\n\t<setPos public=\"1\" set=\"method\" line=\"102\">\n\t\t<f a=\"?x:?y:?z\" v=\"0:0:0\">\n\t\t\t<x path=\"Float\"/>\n\t\t\t<x path=\"Float\"/>\n\t\t\t<x path=\"Float\"/>\n\t\t\t<c path=\"textifician.mapping.Zone\"/>\n\t\t</f>\n\t\t<meta><m n=\":value\"><e>{z:0,y:0,x:0}</e></m></meta>\n\t</setPos>\n\t<addChildren public=\"1\" set=\"method\" line=\"109\"><f a=\"list\">\n\t<c path=\"Array\"><c path=\"de.polygonal.ds.GraphNode\"><d/></c></c>\n\t<c path=\"textifician.mapping.Zone\"/>\n</f></addChildren>\n\t<addChild public=\"1\" set=\"method\" line=\"117\"><f a=\"node\">\n\t<c path=\"de.polygonal.ds.GraphNode\"><d/></c>\n\t<c path=\"de.polygonal.ds.GraphNode\"><d/></c>\n</f></addChild>\n\t<removeChild public=\"1\" set=\"method\" line=\"122\"><f a=\"node\">\n\t<c path=\"de.polygonal.ds.GraphNode\"><d/></c>\n\t<c path=\"de.polygonal.ds.GraphNode\"><d/></c>\n</f></removeChild>\n\t<new public=\"1\" set=\"method\" line=\"40\"><f a=\"\"><x path=\"Void\"/></f></new>\n\t<meta>\n\t\t<m n=\":directlyUsed\"/>\n\t\t<m n=\":expose\"/>\n\t\t<m n=\":rtti\"/>\n\t</meta>\n</class>";
textifician_mapping_Zone.DEFAULT_SCALE = 1;
textifician_mapping_Zone.ID_MATCH_LABEL = 0;
textifician_mapping_Zone.ID_SLUGIFY = 1;
textifician_mapping_Zone.ID_CAMELIZE = 2;
textifician_mapping_Zone.IDMODE = 0;
tjson_TJSON.OBJECT_REFERENCE_PREFIX = "@~obRef#";
TextificianGoJS.main();
})(typeof console != "undefined" ? console : {log:function(){}}, typeof window != "undefined" ? window : exports, typeof window != "undefined" ? window : typeof global != "undefined" ? global : typeof self != "undefined" ? self : this);
