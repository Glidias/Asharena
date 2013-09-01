package alternativa.a3d.systems.text 
{
	import alternativa.engine3d.materials.Material;
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
		public var material:Material;
		public var spriteSet:SpriteSet;
		public var id:String;
		
		alternativa3d var boundParagraph:AABB2 = new AABB2();
		alternativa3d var numLinesCache:int;
		alternativa3d var boundsCache:Array;
		alternativa3d var referTextCache:String;
		alternativa3d var splitLineCache:Array;
		
		alternativa3d var counter:int = 0; 	// for internal use only
		
		private var uvx:Number = 0;
		private var uvy:Number = 0;
		
		public function FontSettings(fontSheet:Fontsheet, material:Material, spriteSet:SpriteSet, id:String="") 
		{
			this.fontSheet = fontSheet;
			this.material = material;
			this.spriteSet = spriteSet;
			this.id = id;
		}
		
		
		private static const RECT:Rectangle = new Rectangle();
		
		alternativa3d function writeMarqueeDataFromCache(x:Number, y:Number, centered:Boolean , startLetterIndex:uint, maskWidth:Number, marqueeWidth:Number):void {
			var bounds:Array = boundsCache;
			var referText:String = referTextCache;
			var minX:Number = centered ? -maskWidth*.5 : 0;
			maskWidth -= centered ? maskWidth * .5 : 0;
			
			x -= int(x/marqueeWidth)*marqueeWidth;
			
			var rect:Rectangle = RECT;
			var count:int = 0;
			var data:Vector.<Number> = spriteSet.spriteData;
			var offsetConstants:int = (spriteSet.NUM_REGISTERS_PER_SPR << 2);
			
			startLetterIndex *= offsetConstants;
			var limit:int = startLetterIndex +  bounds.length*offsetConstants; 
		
			/*
			if (data.length < limit) {
				data.fixed = false;
				data.length = limit;
				data.fixed = true;
			}
			*/
			

			
			for (var i:int = startLetterIndex; i < limit; i += offsetConstants) {
				fontSheet.getRectangleAt( fontSheet.charRectIndices[referText.charCodeAt(count)], rect );
				//font.getRandomRect(rect);
				var aabb:AABB2 = bounds[count];
				var tarX:Number =  aabb.minX;
				
				tarX += x;
				//- int(tarX / marqueeWidth)
				tarX = tarX < 0 ?  tarX+ marqueeWidth : tarX;
				
				
				
				var tarX2:Number = tarX + (aabb.maxX - aabb.minX);
				
				
				data[i] =   tarX + (aabb.maxX - aabb.minX) * .5;
				data[i + 1] =  y +  (aabb.minY + (aabb.maxY - aabb.minY) * .5);
				data[i + 2] =  (tarX2 <= maskWidth && tarX >= minX ) ? 0 : -1;
					
				count++;
				data[i + 4] =  rect.x + uvx;
				data[i + 5] = rect.y + uvy;
				data[i + 6] =   rect.width;
				data[i + 7] =  rect.height;
			}
		}
		
		alternativa3d function writeDataFromCache(x:Number, y:Number, centered:Boolean , startLetterIndex:uint, maskWidth:Number, minimumY:Number):void {
			var bounds:Array = boundsCache;
			var referText:String = referTextCache;
			var minX:Number = centered ? -maskWidth*.5 : 0;
			maskWidth -= centered ? maskWidth*.5 : 0;

			var rect:Rectangle = RECT;
			var count:int = 0;
			var data:Vector.<Number> = spriteSet.spriteData;
			var offsetConstants:int = (spriteSet.NUM_REGISTERS_PER_SPR << 2);
			
			startLetterIndex *= offsetConstants;
			var limit:int = startLetterIndex +  bounds.length*offsetConstants; 
		
		//	/*
			if (data.length < limit) {
				data.fixed = false;
				data.length = limit;
				data.fixed = true;
			}
			//*/

			
			for (var i:int = startLetterIndex; i < limit; i += offsetConstants) {
				fontSheet.getRectangleAt( fontSheet.charRectIndices[referText.charCodeAt(count)], rect );
				//font.getRandomRect(rect);
				
				var aabb:AABB2 = bounds[count];
				data[i] =   x +aabb.minX + (aabb.maxX - aabb.minX) * .5;
				data[i + 1] =  y+  (aabb.minY + (aabb.maxY-aabb.minY)*.5);
				data[i + 2] =  (x + aabb.maxX <= maskWidth && x+aabb.minX >= minX ) && ( y+aabb.minY >= minimumY ) ? 0 : -1;
					
				count++;
				data[i + 4] =  rect.x + uvx;
				data[i + 5] = rect.y + uvy;
				data[i + 6] =   rect.width;
				data[i + 7] =  rect.height;
			}
		}
		
		public function writeFinalData(str:String, x:Number = 0, y:Number = 0, maxWidth:Number = 2000, centered:Boolean = false, startLetterIndex:uint = 0, minimumY:Number=-1.79e+308):void {
			writeData(str, x, y, maxWidth, centered, startLetterIndex);
			if (boundsCache.length > spriteSet._numSprites) spriteSet.numSprites = boundsCache.length;
			spriteSet._numSprites = boundsCache.length;
		}
		
		public function cacheData(str:String, maxWidth:Number, centered:Boolean):void {
			if (str === "") {
				boundsCache = [];
				referTextCache = "";
				return;
			}
			str =maxWidth != 0 ?  fontSheet.fontV.getParagraph(str, 0, 0, maxWidth, boundParagraph) : str;
			splitLineCache =  str.split("\n");
			numLinesCache =splitLineCache.length;
			fontSheet.fontV.getBound(str, 0, 0, centered, fontSheet.tight, boundParagraph);
			
			var bounds:Array = fontSheet.fontV.getIndividualBounds(str, 0, 0, centered, fontSheet.tight);
			if (bounds.length > spriteSet._numSprites) spriteSet.numSprites = bounds.length;
			var referText:String = str.replace( /\s/g, "");
			if (referText === "") {
				boundsCache = [];
				referTextCache = "";
				return;
			}
			
			boundsCache = bounds;
			referTextCache = referText;
		}
		
		
		alternativa3d var minXOffset:Number = 0;
		
		public function setLetterZ(startLetterIndex:int, amountLetters:int, zValue:Number):void {
			var data:Vector.<Number> = spriteSet.spriteData;
			var offsetConstants:int = (spriteSet.NUM_REGISTERS_PER_SPR << 2);
			
			startLetterIndex *= offsetConstants;
			var limit:int = startLetterIndex +  amountLetters * offsetConstants; 
			
			for (var i:int = startLetterIndex; i < limit; i+=offsetConstants) {
				data[i + 2] = zValue;
			}
		}
		
		
		public function writeData(str:String, x:Number = 0, y:Number = 0, maxWidth:Number = 2000, centered:Boolean = false, startLetterIndex:int = 0, maskWidth:Number=Number.MAX_VALUE, minimumY:Number=-1.79e+308):void {
			if (str === "") {
				boundsCache = [];
				referTextCache = "";
				return;
			}
			var minX:Number = centered ? -maskWidth * .5 : 0;
			minX -= minXOffset;
			
			maskWidth -= centered ? maskWidth*.5 : 0;
			var isPara:Boolean = maxWidth != 0;
			str =isPara ?  fontSheet.fontV.getParagraph(str, 0, 0, maxWidth, boundParagraph) : str;
			numLinesCache = isPara ? str.split("\n").length : 1;
			
			fontSheet.fontV.getBound(str, 0, 0, centered, fontSheet.tight, boundParagraph);
			
			var bounds:Array = fontSheet.fontV.getIndividualBounds(str, 0, 0, centered, fontSheet.tight);
			if (bounds.length > spriteSet._numSprites) spriteSet.numSprites = bounds.length;
			var referText:String = str.replace( /\s/g, "");
			if (referText === "") {
				boundsCache = [];
				referTextCache = "";
				return;
			}
			var rect:Rectangle = RECT;
			var count:int = 0;
			var data:Vector.<Number> = spriteSet.spriteData;
			var offsetConstants:int = (spriteSet.NUM_REGISTERS_PER_SPR << 2);
			
			startLetterIndex *= offsetConstants;
			var limit:int = startLetterIndex +  bounds.length*offsetConstants; 
			
		
			if (data.length < limit) {
				data.fixed = false;
				data.length = limit;
				data.fixed = true;
			}
			
			for (var i:int = startLetterIndex; i < limit; i += offsetConstants) {
				fontSheet.getRectangleAt( fontSheet.charRectIndices[referText.charCodeAt(count)], rect );
				//font.getRandomRect(rect);
				var aabb:AABB2 = bounds[count];
				data[i] =  x + aabb.minX + (aabb.maxX - aabb.minX) * .5;
				data[i + 1] =  y +  (aabb.minY + (aabb.maxY - aabb.minY) * .5);
				data[i + 2] = (x + aabb.maxX <= maskWidth && x+aabb.minX >= minX ) && ( y+aabb.minY >=  minimumY ) ? 0 : -1;
				count++;
				data[i + 4] =  rect.x + uvx;
				data[i + 5] = rect.y + uvy;
				data[i + 6] =   rect.width;
				data[i + 7] =  rect.height;
			}
			
			
			boundsCache = bounds;
			referTextCache = referText;
		}
		
	
		
		
	}

}