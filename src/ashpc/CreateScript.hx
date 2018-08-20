package ashpc;
import ash.core.Entity;

/**
 * A builder to create a Playcanvas component script that links to your Ash/Haxe/generalised class component,
 * and automatically add an entity to the Ash engine.
 * @author Glidias
 */
class CreateScript
{
	public function new(name:String, classe:Dynamic, attributes:Dynamic=null, baseClasse:Dynamic=null) 
	{
		var s:Dynamic = untyped pc.createScript(name);
		var chkClass = baseClasse != null ? baseClasse : classe;
		if(!chkClass.__name__) {
			untyped chkClass.__name__ = name.split(".");
		}
		var attributeFields:Array<String>;
		s.prototype.initialize = function() {
			if (!jsThis.entity.ash) {
				jsThis.entity.ash = new Entity();
			}
			var c = Type.createInstance(classe, []);
			jsThis.entity.ash.add(c, chkClass);
			jsThis.c = c;

			if (jsThis._liveDebug) {
					if (attributes != null) {
					jsThis.on("attr", function(p, value) {
						if (p == "_liveDebug") {
							return;
						}
						untyped c[p] = value;
						trace(jsThis.entity.name + "::" + name+" debugSet >> " + p + ": " + value);
						trace(c);
					}, jsThis);
				}
			}
			if (attributeFields != null) {
				for (p in attributeFields) {
					untyped c[p] = jsThis[p];
				}
			}
		}
		
		if (attributes != null) {
			attributeFields = Reflect.fields(attributes);
			for (p in attributeFields) {
				s.attributes.add(p, untyped attributes[p]);
			}
		}
		s.attributes.add("_liveDebug", { type:"boolean"} );
	}
	
	public static var jsThis(get, never):Dynamic;
	
	static inline function get_jsThis():Dynamic {
		return untyped __js__("this");
	}
	

	
}