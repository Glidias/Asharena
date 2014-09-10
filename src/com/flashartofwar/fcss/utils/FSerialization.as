package com.flashartofwar.fcss.utils 
{
	import com.flashartofwar.fcss.applicators.StyleApplicator;
	import com.flashartofwar.fcss.styles.IStyle;
	import com.flashartofwar.fcss.stylesheets.FStyleSheet;
	import flash.utils.describeType;
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class FSerialization 
	{
		
		public function FSerialization() 
		{
			
		}
		
		private static var styleApplier:StyleApplicator = new StyleApplicator();
		
		public static function createHashFromArray(arr:Array):Object {
			var obj:Object = { };
			
			var i:int = arr.length;
			while (--i > -1) {
				
				obj[arr[i]] = true;
			}
			return obj;
		}
		
		public static function parseStylesheet(str:String):FStyleSheet {
			var stylesheet:FStyleSheet = new FStyleSheet();
			stylesheet.parseCSS(str);
			return stylesheet;
		}
		
		public static function applyStyle(target:Object, style:IStyle):void {
			styleApplier.applyStyle(target, style);
		}
		
		
		
		public static function getStyleStringOfObject(styleName:String, obj:Object, propertyMaskHash:Object=null):String {
			var styleStr:String = styleName+" { ";
			var xml:XML = describeType(obj);
			var prop:String;
		
			//throw new Error(xml);
			
			var node:XML;
			var len:int;
			var xmlList:XMLList;
			
			xmlList = xml.accessor.(@access=="readwrite");
			len = xmlList.length();
			for (var i : int = 0; i <len; i++)
			{
				node = xmlList[i];
				prop = node.@name;
				if (propertyMaskHash == null || propertyMaskHash[prop]) styleStr += prop + ":" + obj[prop]+"; ";
			}
			
			xmlList = xml.variable;
			len = xmlList.length();
			for (i = 0; i < len; i++) {
				node = xmlList[i];
				prop = node.@name;
				if (propertyMaskHash == null || propertyMaskHash[prop]) styleStr += prop + ":" + obj[prop]+"; ";
			}
				
			styleStr += " }";
			return styleStr;
		}
		
	}

}