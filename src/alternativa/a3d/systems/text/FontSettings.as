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
		alternativa3d var _outsideBound:Boolean = false;
		
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
			
			}
		}
		
		public static function getPlainTextFromXMLString(str:String):String {
			var lastIgnoreWhite:Boolean = XML.ignoreWhitespace;
			XML.ignoreWhitespace = false;
			var xmlList:XMLList = XML(str).children();
			var len:int = xmlList.length();
			var str:String = "";
			for (var i:int = 0; i < len; i++) {
				str += xmlList[i].toString();
			}
			XML.ignoreWhitespace = lastIgnoreWhite;
			return str;
		}
		
		public static function getXMLCharListFromXMLString(str:String):XMLList {
			var lastIgnoreWhite:Boolean = XML.ignoreWhitespace;
			XML.ignoreWhitespace = true;
			var xml:XML = XML(str);
			var xmlList:XMLList = xml.children();
			/*
			for each(var node:XML in xmlList) {
				if (node.children().length) node.setChildren(node.toString().replace( /\s/g, ""))
				else node.replace(node.toString().replace( /\s/g, ""));
			}
			*/
		
			XML.ignoreWhitespace = lastIgnoreWhite;
			return xmlList;
		}
		
		//0x000FFFFF  - length mask
		// 0x80000000 - sentinel bit to identify span
		// 0x00F00000 - U mask
		// 0x0F000000 - V mask
		
		public static function getCharSpanValues(str:String):Vector.<uint> {
			var vec:Vector.<uint> = new Vector.<uint>();
			var xmlList:XMLList = getXMLCharListFromXMLString(str);
			var len:int = xmlList.length();
			var val:uint = 0;
			for (var i:int = 0; i < len; i++) {
				var xml:XML = xmlList[i];
				var str:String = xml.toString().replace( /\s/g, "");
				if ( String(xml.name()) === "span") {
					var u:uint = xml.@u != undefined ? uint(xml.@u) : 0;
					var v:uint = xml.@v != undefined ? uint(xml.@v) : 0;
					val = 0x80000000 | (u << 20) | (v << 24) |  str.length;
				}
				else val = str.length;
				vec.push(val);
			}
			vec.fixed = true;
			return vec;
		}
		
		
		
		alternativa3d function writeSpanDataFromCache(cacheChars:Vector.<uint>,startLetterIndex:uint):void {
			var len:int = cacheChars.length;
			var li:int = startLetterIndex;
			
			var data:Vector.<Number> = spriteSet.spriteData;
			var offsetConstants:int = (spriteSet.NUM_REGISTERS_PER_SPR << 2);
			startLetterIndex *= offsetConstants;
			
			var uOffset:Number = fontSheet.uSpanOffset;
			var vOffset:Number = fontSheet.vSpanOffset;
			var i:int = startLetterIndex;
		
			for (var c:int = 0; c < len; c++) {
				
				var val:uint = cacheChars[c];
				if ( (val & 0x80000000) ) {
					var bbc:int = (val & 0x000FFFFF);
					
					var bi:int = i;
					while(--bbc > -1) {
						data[bi + 4] += ((val & 0x00F00000) >> 20) * uOffset;
						data[bi + 5] += ((val & 0x0F000000) >> 24) * vOffset;
						bi += offsetConstants;
					}
					i += (val & 0x000FFFFF) * offsetConstants;
				}
				else i += val * offsetConstants;
			}
		}
		
		
		alternativa3d function writeDataFromCache(x:Number, y:Number, centered:Boolean , startLetterIndex:uint, maskWidth:Number, minimumY:Number):void {
			_outsideBound = false;
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

			var outsideBound:Boolean = false;
			for (var i:int = startLetterIndex; i < limit; i += offsetConstants) {
				fontSheet.getRectangleAt( fontSheet.charRectIndices[referText.charCodeAt(count)], rect );
				//font.getRandomRect(rect);
				
				var aabb:AABB2 = bounds[count];
				var withinBounds:Boolean =  ( y + aabb.minY >= minimumY );
				data[i] =   x +aabb.minX + (aabb.maxX - aabb.minX) * .5;
				data[i + 1] =  y+  (aabb.minY + (aabb.maxY-aabb.minY)*.5);
				data[i + 2] =   (x + aabb.maxX <= maskWidth && x + aabb.minX >= minX ) && withinBounds? 0 : -1;
				outsideBound ||=  !withinBounds;
					
				count++;
				data[i + 4] =  rect.x + uvx;
				data[i + 5] = rect.y + uvy;
				data[i + 6] =   rect.width;
				data[i + 7] =  rect.height;
			}
		
			_outsideBound = outsideBound;
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
			_outsideBound = false;
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
			var outsideBound:Boolean = false;
			for (var i:int = startLetterIndex; i < limit; i += offsetConstants) {
				fontSheet.getRectangleAt( fontSheet.charRectIndices[referText.charCodeAt(count)], rect );
				//font.getRandomRect(rect);
				var aabb:AABB2 = bounds[count];
				var withinBounds:Boolean =  ( y + aabb.minY >= minimumY );
				data[i] =   x +aabb.minX + (aabb.maxX - aabb.minX) * .5;
				data[i + 1] =  y+  (aabb.minY + (aabb.maxY-aabb.minY)*.5);
				data[i + 2] =  (x + aabb.maxX <= maskWidth && x + aabb.minX >= minX )  && withinBounds? 0 : -1;
				outsideBound ||=  !withinBounds;
				count++;
				data[i + 4] =  rect.x + uvx;
				data[i + 5] = rect.y + uvy;
				data[i + 6] =   rect.width;
				data[i + 7] =  rect.height;
			}
			
			
			boundsCache = bounds;
			referTextCache = referText;
			
			_outsideBound = outsideBound;
		}
		
	
		
		
	}

}