package alternativa.a3d.systems.text 
{
	import alternativa.engine3d.spriteset.materials.MaskColorAtlasMaterial;
	import alternativa.engine3d.spriteset.SpriteSet;
	import assets.fonts.Fontsheet;
	import alternativa.engine3d.alternativa3d;
	import de.polygonal.motor.geom.primitive.AABB2;
	import flash.geom.Rectangle;
	use namespace alternativa3d;
	
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class FontSettings 
	{
		public var fontSheet:Fontsheet;
		public var material:MaskColorAtlasMaterial;
		public var spriteSet:SpriteSet;
		public var id:String;
		//private var registerOffset:int = 4;
		
		alternativa3d var boundsCache:Array;
		alternativa3d var referTextCache:String;
		
		public function FontSettings(fontSheet:Fontsheet, material:MaskColorAtlasMaterial, spriteSet:SpriteSet, id:String="") 
		{
			this.fontSheet = fontSheet;
			this.material = material;
			this.spriteSet = spriteSet;
			this.id = id;
		}
		
		
		private static const RECT:Rectangle = new Rectangle();
		
		alternativa3d function writeDataFromCache(x:Number, y:Number, centered:Boolean , startLetterIndex:uint):void {
			var bounds:Array = boundsCache;
			var referText:String = referTextCache;
			
			var rect:Rectangle = RECT;
			var count:int = 0;
			var data:Vector.<Number> = spriteSet.spriteData;
			var offsetConstants:int = (spriteSet.NUM_REGISTERS_PER_SPR << 2);
			var limit:int = ((startLetterIndex + bounds.length) *offsetConstants); 
			for (var i:int = startLetterIndex; i < limit; i += offsetConstants) {
				fontSheet.getRectangleAt( fontSheet.charRectIndices[referText.charCodeAt(count)], rect );  // Charcode could also be cached..
				//font.getRandomRect(rect);
				var aabb:AABB2 = bounds[count];	
				data[i] =  aabb.minX + (aabb.maxX - aabb.minX) * .5;
				data[i + 1] =    (aabb.minY + (aabb.maxY-aabb.minY)*.5);
				
				count++;
				data[i + 4] =  rect.x;
				data[i + 5] = rect.y;
				data[i + 6] =   rect.width;
				data[i + 7] =  rect.height;
			}
			
		}
		
		public function writeData(str:String, x:Number = 0, y:Number = 0, maxWidth:Number = 2000, centered:Boolean = false, startLetterIndex:uint = 0):void {
			str = fontSheet.fontV.getParagraph(str, x, y, maxWidth);
			var bounds:Array = fontSheet.fontV.getIndividualBounds(str, x, y, centered, fontSheet.tight);
			if (bounds.length > spriteSet._numSprites) spriteSet.numSprites = bounds.length;
			var referText:String = str.replace( /\s/g, "");
			var rect:Rectangle = RECT;
			var count:int = 0;
			var data:Vector.<Number> = spriteSet.spriteData;
			var offsetConstants:int = (spriteSet.NUM_REGISTERS_PER_SPR << 2);
			var limit:int = ((startLetterIndex + bounds.length) *offsetConstants); 
			for (var i:int = startLetterIndex; i < limit; i += offsetConstants) {
				fontSheet.getRectangleAt( fontSheet.charRectIndices[referText.charCodeAt(count)], rect );
				//font.getRandomRect(rect);
				var aabb:AABB2 = bounds[count];	
				data[i] =  aabb.minX + (aabb.maxX - aabb.minX) * .5;
				data[i + 1] =    (aabb.minY + (aabb.maxY-aabb.minY)*.5);
				
				count++;
				data[i + 4] =  rect.x;
				data[i + 5] = rect.y;
				data[i + 6] =   rect.width;
				data[i + 7] =  rect.height;
			}
			
			boundsCache = bounds;
			referTextCache = referText;
		}
		
	
		
		
	}

}