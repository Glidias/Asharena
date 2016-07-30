(function (console, $hx_exports) { "use strict";
$hx_exports.troshx = $hx_exports.troshx || {};
$hx_exports.troshx.util = $hx_exports.troshx.util || {};
;$hx_exports.troshx.tros = $hx_exports.troshx.tros || {};
var $estr = function() { return js_Boot.__string_rec(this,''); };
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
EReg.__name__ = ["EReg"];
EReg.prototype = {
	replace: function(s,by) {
		return s.replace(this.r,by);
	}
};
var HxOverrides = function() { };
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
List.__name__ = ["List"];
List.prototype = {
	add: function(item) {
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
};
var _$List_ListIterator = function(head) {
	this.head = head;
	this.val = null;
};
_$List_ListIterator.__name__ = ["_List","ListIterator"];
_$List_ListIterator.prototype = {
	hasNext: function() {
		return this.head != null;
	}
	,next: function() {
		this.val = this.head[0];
		this.head = this.head[1];
		return this.val;
	}
};
var Main = function() { };
Main.__name__ = ["Main"];
Main.main = function() {
};
Math.__name__ = ["Math"];
var Reflect = function() { };
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
var Std = function() { };
Std.__name__ = ["Std"];
Std.string = function(s) {
	return js_Boot.__string_rec(s,"");
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
StringBuf.__name__ = ["StringBuf"];
StringBuf.prototype = {
	add: function(x) {
		this.b += Std.string(x);
	}
	,addSub: function(s,pos,len) {
		if(len == null) this.b += HxOverrides.substr(s,pos,null); else this.b += HxOverrides.substr(s,pos,len);
	}
};
var StringTools = function() { };
StringTools.__name__ = ["StringTools"];
StringTools.htmlEscape = function(s,quotes) {
	s = s.split("&").join("&amp;").split("<").join("&lt;").split(">").join("&gt;");
	if(quotes) return s.split("\"").join("&quot;").split("'").join("&#039;"); else return s;
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
StringTools.fastCodeAt = function(s,index) {
	return s.charCodeAt(index);
};
var Type = function() { };
Type.__name__ = ["Type"];
Type.getClassName = function(c) {
	var a = c.__name__;
	if(a == null) return null;
	return a.join(".");
};
Type.createEmptyInstance = function(cl) {
	function empty() {}; empty.prototype = cl.prototype;
	return new empty();
};
var Xml = function(nodeType) {
	this.nodeType = nodeType;
	this.children = [];
	this.attributeMap = new haxe_ds_StringMap();
};
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
	get_nodeName: function() {
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
};
var haxe_IMap = function() { };
haxe_IMap.__name__ = ["haxe","IMap"];
var haxe_ds_StringMap = function() {
	this.h = { };
};
haxe_ds_StringMap.__name__ = ["haxe","ds","StringMap"];
haxe_ds_StringMap.__interfaces__ = [haxe_IMap];
haxe_ds_StringMap.prototype = {
	set: function(key,value) {
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
var haxe_rtti_Meta = function() { };
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
haxe_rtti_XmlParser.__name__ = ["haxe","rtti","XmlParser"];
haxe_rtti_XmlParser.prototype = {
	mkPath: function(p) {
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
};
var haxe_xml__$Fast_NodeAccess = function(x) {
	this.__x = x;
};
haxe_xml__$Fast_NodeAccess.__name__ = ["haxe","xml","_Fast","NodeAccess"];
haxe_xml__$Fast_NodeAccess.prototype = {
	resolve: function(name) {
		var x = this.__x.elementsNamed(name).next();
		if(x == null) {
			var xname;
			if(this.__x.nodeType == Xml.Document) xname = "Document"; else xname = this.__x.get_nodeName();
			throw new js__$Boot_HaxeError(xname + " is missing element " + name);
		}
		return new haxe_xml_Fast(x);
	}
};
var haxe_xml__$Fast_AttribAccess = function(x) {
	this.__x = x;
};
haxe_xml__$Fast_AttribAccess.__name__ = ["haxe","xml","_Fast","AttribAccess"];
haxe_xml__$Fast_AttribAccess.prototype = {
	resolve: function(name) {
		if(this.__x.nodeType == Xml.Document) throw new js__$Boot_HaxeError("Cannot access document attribute " + name);
		var v = this.__x.get(name);
		if(v == null) throw new js__$Boot_HaxeError(this.__x.get_nodeName() + " is missing attribute " + name);
		return v;
	}
};
var haxe_xml__$Fast_HasAttribAccess = function(x) {
	this.__x = x;
};
haxe_xml__$Fast_HasAttribAccess.__name__ = ["haxe","xml","_Fast","HasAttribAccess"];
haxe_xml__$Fast_HasAttribAccess.prototype = {
	resolve: function(name) {
		if(this.__x.nodeType == Xml.Document) throw new js__$Boot_HaxeError("Cannot access document attribute " + name);
		return this.__x.exists(name);
	}
};
var haxe_xml__$Fast_HasNodeAccess = function(x) {
	this.__x = x;
};
haxe_xml__$Fast_HasNodeAccess.__name__ = ["haxe","xml","_Fast","HasNodeAccess"];
haxe_xml__$Fast_HasNodeAccess.prototype = {
	resolve: function(name) {
		return this.__x.elementsNamed(name).hasNext();
	}
};
var haxe_xml__$Fast_NodeListAccess = function(x) {
	this.__x = x;
};
haxe_xml__$Fast_NodeListAccess.__name__ = ["haxe","xml","_Fast","NodeListAccess"];
haxe_xml__$Fast_NodeListAccess.prototype = {
	resolve: function(name) {
		var l = new List();
		var $it0 = this.__x.elementsNamed(name);
		while( $it0.hasNext() ) {
			var x = $it0.next();
			l.add(new haxe_xml_Fast(x));
		}
		return l;
	}
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
haxe_xml_Fast.__name__ = ["haxe","xml","Fast"];
haxe_xml_Fast.prototype = {
	get_name: function() {
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
};
var haxe_xml_Parser = function() { };
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
haxe_xml_Printer.__name__ = ["haxe","xml","Printer"];
haxe_xml_Printer.print = function(xml,pretty) {
	if(pretty == null) pretty = false;
	var printer = new haxe_xml_Printer(pretty);
	printer.writeNode(xml,"");
	return printer.output.b;
};
haxe_xml_Printer.prototype = {
	writeNode: function(value,tabs) {
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
};
var js__$Boot_HaxeError = function(val) {
	Error.call(this);
	this.val = val;
	this.message = String(val);
	if(Error.captureStackTrace) Error.captureStackTrace(this,js__$Boot_HaxeError);
};
js__$Boot_HaxeError.__name__ = ["js","_Boot","HaxeError"];
js__$Boot_HaxeError.__super__ = Error;
js__$Boot_HaxeError.prototype = $extend(Error.prototype,{
});
var js_Boot = function() { };
js_Boot.__name__ = ["js","Boot"];
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
var troshx_BodyChar = $hx_exports.troshx.BodyChar = function() {
	this.zones = [];
	this.zones[0] = null;
	this.zonesB = [];
	this.zones[1] = null;
};
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
};
var troshx_ZoneBody = function() {
	this.weightsTotal = 0;
};
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
	recalcWeightsTotal: function() {
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
troshx_tros_HumanoidBody.__name__ = ["troshx","tros","HumanoidBody"];
troshx_tros_HumanoidBody.getInstance = function() {
	if(troshx_tros_HumanoidBody.INSTANCE != null) return troshx_tros_HumanoidBody.INSTANCE; else return troshx_tros_HumanoidBody.INSTANCE = new troshx_tros_HumanoidBody();
};
troshx_tros_HumanoidBody.__super__ = troshx_BodyChar;
troshx_tros_HumanoidBody.prototype = $extend(troshx_BodyChar.prototype,{
});
var troshx_util_ReflectUtil = $hx_exports.troshx.util.ReflectUtil = function() { };
troshx_util_ReflectUtil.__name__ = ["troshx","util","ReflectUtil"];
troshx_util_ReflectUtil.setItemStaticMethodsTo = function(c,to) {
	return troshx_util_ReflectUtil.setItemMethodsTo(c,to,true);
};
troshx_util_ReflectUtil.setItemInstanceMethodsTo = function(c,to) {
	return troshx_util_ReflectUtil.setItemMethodsTo(c,to,false);
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
var $_, $fid = 0;
function $bind(o,m) { if( m == null ) return null; if( m.__id__ == null ) m.__id__ = $fid++; var f; if( o.hx__closures__ == null ) o.hx__closures__ = {}; else f = o.hx__closures__[m.__id__]; if( f == null ) { f = function(){ return f.method.apply(f.scope, arguments); }; f.scope = o; f.method = m; o.hx__closures__[m.__id__] = f; } return f; }
if(Array.prototype.indexOf) HxOverrides.indexOf = function(a,o,i) {
	return Array.prototype.indexOf.call(a,o,i);
};
String.__name__ = ["String"];
Array.__name__ = ["Array"];
var __map_reserved = {}
Xml.Element = 0;
Xml.PCData = 1;
Xml.CData = 2;
Xml.Comment = 3;
Xml.DocType = 4;
Xml.ProcessingInstruction = 5;
Xml.Document = 6;
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
troshx_BodyChar.D_DESTROY_PART = 1;
troshx_BodyChar.D_DEATH = 2;
troshx_BodyChar.WOUND_TYPE_CUT = 1;
troshx_BodyChar.WOUND_TYPE_PIERCE = 2;
troshx_BodyChar.WOUND_TYPE_BLUNT_TRAUMA = 4;
troshx_BodyChar.WOUND_D_DESTROY = 1;
troshx_BodyChar.WOUND_D_DEATH = 2;
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
troshx_util_TROSAI.__rtti = "<class path=\"troshx.util.TROSAI\" params=\"\">\n\t<factorial public=\"1\" get=\"inline\" set=\"null\" line=\"24\" static=\"1\"><f a=\"val\">\n\t<x path=\"Int\"/>\n\t<x path=\"Float\"/>\n</f></factorial>\n\t<binomialCoef public=\"1\" get=\"inline\" set=\"null\" line=\"38\" static=\"1\"><f a=\"n:r\">\n\t<x path=\"Int\"/>\n\t<x path=\"Int\"/>\n\t<x path=\"Float\"/>\n</f></binomialCoef>\n\t<getTNSuccessProbForDie public=\"1\" get=\"inline\" set=\"null\" line=\"48\" static=\"1\"><f a=\"tn\">\n\t<x path=\"Int\"/>\n\t<x path=\"Float\"/>\n</f></getTNSuccessProbForDie>\n\t<getXSuccessesProb public=\"1\" get=\"inline\" set=\"null\" line=\"52\" static=\"1\"><f a=\"numDiceToRoll:tn:x\">\n\t<x path=\"Int\"/>\n\t<x path=\"Int\"/>\n\t<x path=\"Int\"/>\n\t<x path=\"Float\"/>\n</f></getXSuccessesProb>\n\t<getAtLeastXSuccessesProb public=\"1\" set=\"method\" line=\"57\" static=\"1\"><f a=\"numDiceToRoll:tn:x\">\n\t<x path=\"Int\"/>\n\t<x path=\"Int\"/>\n\t<x path=\"Int\"/>\n\t<x path=\"Float\"/>\n</f></getAtLeastXSuccessesProb>\n\t<probabilityAOrB public=\"1\" get=\"inline\" set=\"null\" line=\"67\" static=\"1\"><f a=\"a:b\">\n\t<x path=\"Float\"/>\n\t<x path=\"Float\"/>\n\t<x path=\"Float\"/>\n</f></probabilityAOrB>\n\t<probabilityOfArrayOr public=\"1\" get=\"inline\" set=\"null\" line=\"71\" static=\"1\"><f a=\"arr\">\n\t<c path=\"Array\"><x path=\"Float\"/></c>\n\t<x path=\"Float\"/>\n</f></probabilityOfArrayOr>\n\t<getBelowOrEqualXSuccessesProb public=\"1\" set=\"method\" line=\"81\" static=\"1\"><f a=\"numDiceToRoll:tn:x\">\n\t<x path=\"Int\"/>\n\t<x path=\"Int\"/>\n\t<x path=\"Int\"/>\n\t<x path=\"Float\"/>\n</f></getBelowOrEqualXSuccessesProb>\n\t<getChanceToSucceedContest public=\"1\" set=\"method\" line=\"103\" static=\"1\">\n\t\t<f a=\"numDice:tn:againstNumDice:againstTN:?rs:?requireAtLeast1TS\" v=\"::::1:true\">\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Bool\"/>\n\t\t\t<x path=\"Float\"/>\n\t\t</f>\n\t\t<meta><m n=\":value\"><e>{requireAtLeast1TS:true,rs:1}</e></m></meta>\n\t</getChanceToSucceedContest>\n\t<getChanceToSucceed public=\"1\" set=\"method\" line=\"140\" static=\"1\">\n\t\t<f a=\"numDice:tn:?rs\" v=\"::1\">\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Int\"/>\n\t\t\t<x path=\"Float\"/>\n\t\t</f>\n\t\t<meta><m n=\":value\"><e>{rs:1}</e></m></meta>\n\t</getChanceToSucceed>\n\t<getAllXSuccessesProb public=\"1\" set=\"method\" line=\"147\" static=\"1\"><f a=\"numDice:tn\">\n\t<x path=\"Int\"/>\n\t<x path=\"Int\"/>\n\t<c path=\"Array\"><x path=\"Float\"/></c>\n</f></getAllXSuccessesProb>\n\t<getTabulatedRollData public=\"1\" set=\"method\" line=\"155\" static=\"1\"><f a=\"numDice:tn\">\n\t<x path=\"Int\"/>\n\t<x path=\"Int\"/>\n\t<c path=\"Array\"><d/></c>\n</f></getTabulatedRollData>\n\t<maxPrecision public=\"1\" get=\"inline\" set=\"null\" line=\"178\" static=\"1\"><f a=\"x:precision\">\n\t<x path=\"Float\"/>\n\t<x path=\"Int\"/>\n\t<x path=\"Float\"/>\n</f></maxPrecision>\n\t<roundTo public=\"1\" set=\"method\" line=\"182\" static=\"1\"><f a=\"x:y\">\n\t<x path=\"Float\"/>\n\t<x path=\"Float\"/>\n\t<x path=\"Float\"/>\n</f></roundTo>\n\t<displayAsPercentage public=\"1\" get=\"inline\" set=\"null\" line=\"202\" static=\"1\"><f a=\"probability\">\n\t<x path=\"Float\"/>\n\t<x path=\"Float\"/>\n</f></displayAsPercentage>\n\t<new public=\"1\" set=\"method\" line=\"14\"><f a=\"\"><x path=\"Void\"/></f></new>\n\t<meta>\n\t\t<m n=\":directlyUsed\"/>\n\t\t<m n=\":expose\"/>\n\t\t<m n=\":rtti\"/>\n\t</meta>\n</class>";
Main.main();
})(typeof console != "undefined" ? console : {log:function(){}}, typeof window != "undefined" ? window : exports);
