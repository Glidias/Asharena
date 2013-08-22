package assets.fonts 
{
	import alternativa.engine3d.materials.compiler.Procedure;
	import alternativa.engine3d.resources.BitmapTextureResource;
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
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
		
		public var rects:Vector.<Number> = new Vector.<Number>();
		public var sheet:BitmapData;
		public var bmpResource:BitmapTextureResource;
		
		public function Fontsheet() 
		{
			
		}
		
		protected function init(texture:BitmapData, rectBytes:ByteArray):void {
			sheet = new BitmapData(texture.width, texture.height, true, 0x330000FF);
			var mat:Matrix = new Matrix();
			//mat.scale(1, -1);
			//mat.translate(0, sheet.height);
			sheet.draw(texture, mat);
			//sheet = texture;
			
			var sheetWidthMult:Number = 1/ sheet.width;
			var sheetHeightMult:Number = 1 / sheet.height;
			
			var len:int =  rectBytes.length /4 / 4;//*4/4;  //4 bytes per number
	
			var count:int = 0;
			for (var i:int = 0; i < len; i++) {
				var x:Number=rectBytes.readFloat();
				var y:Number=  rectBytes.readFloat();
				var width:Number = rectBytes.readFloat();
				var height:Number = rectBytes.readFloat();
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
			var index:uint =  Math.random() * getNumLetters();
			rect.width = rects[(index << 2) + 2];
			rect.height = rects[(index << 2) + 3];
			
			rect.x = rects[(index << 2)];
			rect.y = rects[(index << 2) + 1];
			
			if (rect.x < 0) rect.x = 0;
			if (rect.y < 0) rect.y = 0;
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