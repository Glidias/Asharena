package saboteur.spawners 
{
	import flash.display.Sprite;
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class JettyPropsAndMobs extends Sprite
	{

		[Embed(source="../../../resources/props/vikingflag_marker/tall_polemarker.a3d", mimeType="application/octet-stream")]
		public static var MODEL_vikingFlagMarker:Class;
		[Embed(source="../../../resources/props/vikingflag_marker/marker.png")]
		public static var TEXTURE_vikingFlagMarker:Class;
		
		[Embed(source="../../../resources/props/volcano/volcano.a3d", mimeType="application/octet-stream")]	
		public static var MODEL_volcano:Class;
		[Embed(source="../../../resources/props/volcano/texture-atlas.png")]
		public static var TEXTURE_volcano:Class;
	
		public function JettyPropsAndMobs() 
		{
			
			
			
		}
		
		public static function $getSubClasses():Array {
			return [ElementalEarth, ElementalFire];
		}
		
	}

}
import flash.display.Sprite;

class ElementalEarth {
//[Embed(source="../../../resources/monsters/elementals/elementals_greater_earth.a3d", mimeType="application/octet-stream")]
	public static var $_MODEL:Class;
	
	//[Embed(source="../../../resources/monsters/elementals/elemearth.jpg")]
	public static var $_TEXTURE:Class;
}


class ElementalFire {
	//[Embed(source="../../../resources/monsters/elementals/elementals_lesser_fire.a3d", mimeType="application/octet-stream")]
	public static var $_MODEL:Class;
	
	//[Embed(source="../../../resources/monsters/elementals/elemfire.jpg")]
	public static var $_TEXTURE:Class;
}