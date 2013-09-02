package assets.fonts 
{
	import alternativa.engine3d.materials.compiler.Procedure;
	import alternativa.engine3d.resources.BitmapTextureResource;
	import de.polygonal.gl.text.VectorFont;
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import util.SpawnerBundle;
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class Fontsheet 
	{
		private static var _transformProcedures:Dictionary = new Dictionary();
		
		public var rectsInt:Vector.<uint> = new Vector.<uint>();
		public var rects:Vector.<Number> = new Vector.<Number>();
		public var charRectIndices:Vector.<int>;
		public var sheet:BitmapData;
		public var bmpResource:BitmapTextureResource;
		public var padding:uint;
		public var fontV:VectorFont;
		public var tight:Boolean = true;  // for now, this setting should not change!
		
		public var uSpanOffset:Number = 0;
		public var vSpanOffset:Number = 0;
		
		public function Fontsheet() 
		{
			
		}
		
		protected function init(texture:BitmapData, rectBytes:ByteArray, duplicateColoring:Array=null, colorThreshold:uint=0xFF000001):void {
			
			if (fontV == null) throw new Error("Please define a vector font fontV variable before calling init()!");
			charRectIndices = fontV.getCharSetIndices();
			
			if (duplicateColoring != null) {
				var uLen:int = duplicateColoring.length;
				var refer:BitmapData = texture;
				texture = new BitmapData(refer.width * uLen, refer.height, true, 0); 
				for (var u:int = 0; u < uLen; u++) {
					//texture.copyPixels(refer, refer.rect, new Point(refer.width * u, 0));
					texture.threshold(refer, refer.rect, new Point(refer.width * u, 0), ">=", colorThreshold, duplicateColoring[u], 0xFFFFFFFF, true );
				//	texture.threshold(refer, refer.rect, new Point(refer.width * u, 0), "<", colorThreshold,0xFFFFFFFF, 0xFFFFFFFF, false );
				}
				
				uSpanOffset  = refer.width != texture.width ? refer.width / texture.width : 0;
				vSpanOffset =  refer.height != texture.height ? refer.height / texture.height : 0;
			}
			
			sheet = texture;
			
			var sheetWidthMult:Number = 1/ sheet.width;
			var sheetHeightMult:Number = 1 / sheet.height;
			
			var len:int =  rectBytes.length / 4 / 4;//*4/4;  //4 bytes per number
			
			padding = rectBytes.readUnsignedInt();
			
			var count:int = 0;
			var countI:int = 0;
			for (var i:int = 0; i < len; i++) {
				var x:uint=rectBytes.readUnsignedInt();
				var y:uint=  rectBytes.readUnsignedInt();
				var width:uint = rectBytes.readUnsignedInt();
				var height:uint = rectBytes.readUnsignedInt();
				rectsInt[countI++] = x;
				rectsInt[countI++] = y;
				rectsInt[countI++] = width;
				rectsInt[countI++] = height;
				rects[count++] = x * sheetWidthMult;
				rects[count++] = y * sheetHeightMult;
				rects[count++] = width * sheetWidthMult;
				rects[count++] = height * sheetHeightMult;
			}
			rects.fixed = true;
			
			bmpResource = new BitmapTextureResource(sheet);
			bmpResource.upload( SpawnerBundle.context3D );
		}
		
		public function getRandomRect(rect:Rectangle=null):Rectangle {
			rect = rect || (new Rectangle());
			var index:uint = Math.random() * getNumLetters();
			rect.width = rects[(index << 2) + 2];
			rect.height = rects[(index << 2) + 3];
			
			rect.x = rects[(index << 2)];
			rect.y = rects[(index << 2) + 1];
			
			//if (rect.x < 0) rect.x = 0;
			//if (rect.y < 0) rect.y = 0;
			//if (rect.x < 0 || rect.y <0) throw new Error("A:"+rect);
		
			return rect;
		}
		
	
		
		public function getRectangleAt(index:uint, rect:Rectangle = null):Rectangle {
			rect = rect || (new Rectangle());
			rect.x = rects[(index << 2)]
			rect.y = rects[(index << 2)+1]
			rect.width = rects[(index << 2) + 2];
			rect.height = rects[(index << 2) + 3];
			return rect;
		}
		
		public function getNumLetters():int {
			return (rects.length >> 2);
		}
		
		
		
	}

}