package tests.pvp 
{
	import com.adobe.images.PNGEncoder;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Vector3D;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	
	/**
	 * ...
	 * @author Glidias
	 */
	public class TestTerrainSplatGenner extends Sprite 
	{
		[Embed(source="../../../bin/assets/terrains/63058-9p_elevation.bin", mimeType="application/octet-stream")]
		public static var ELEVATION_CLS:Class;
		
		[Embed(source="../../../bin/assets/terrains/63058-9p_moisture.bin", mimeType="application/octet-stream")]
		public static var MOISTURE_CLS:Class;
		/*
		Generating splat map from Moisture Map + Height Map

		BIOME:
		0. SCORCHED r100 (RED)
		1. BARE r95,g5
		2. TEMPERATE DESERT r90,g10
		3. SHRUBLAND  r70,g30
		4. SUBTROPICAL DESERT r60,g40
		5. GRASSLAND (GREEN) g100
		6. TROPICAL RAINFOREST  g100  
		7. TEMPERATE RAINFOREST g90,b10
		8. TROPICAL SEASONAL FOREST g80,b20	
		9. TEMPERATE DECIDIOUS FOREST g60,b40
		10. TAIGA  (BLUE)  b100
		11. TUNDRA b70,a30
		12. SNOW (ALPHA) a100

		MOISTURE:
		0. [4,2,2,0]
		1. [5,5,2,1]
		2. [6,7,3,12]
		3. [6,9,3,12]
		4. [6,9,10,12]
		5. [6,7,10,12]
		*/
		
		
		///*
		private static var BIOMES:Array = [
			[100, 0, 0, 0], // SCORCHED
			[95, 5, 0, 0],  // BARE
			[90, 10, 0, 0], // TEMPERATE DESERT
			[85, 15, 0, 0], // SHRUBLAND
			[80, 20, 0, 0], //SUBTROPICAL DESERT
			[0, 100, 0, 0], // GRASSLAND
			[0, 100, 0, 0], //TROPICAL RAINFOREST
			[0, 90, 10, 0], //TEMPERATE RAINFOREST
			[0, 80, 20, 0],  //   TROPICAL SEASONAL FOREST
			[0, 60, 40, 0],  //   TEMPERATE DECIDIOUS FOREST
			[0, 0, 100, 0], // TAIGA
			[0, 0, 90, 10],  // TUNDRA
			[0, 0, 0, 100]	// SNOW
		];
		//*/
		
		
		private static var MOISTURE:Array = [
			[4,2,2,2,2,0],
			[5,5,5,2,2,1],
			[6,7,7,3,3,12],
			[6,9,9,3,3,12],
			[6,9,9,10,10,12],
			[6,7,7,10,10,12]
		];
		
		private static const  BASE:int = 256;
		private static const HEIGHT_LEN:int = 6;


		private function lerp(value1:Number, value2:Number, amount:Number):Number {
			//amount = amount < 0 ? 0 : amount;
			//amount = amount > 1 ? 1 : amount;
			return value1 + (value2 - value1) * amount;
		}
		
		private function lerpVector(vec1:Vector3D, vec2:Vector3D, amount:Number, result:Vector3D = null):Vector3D {
			if (result == null) result = new Vector3D();
			result.x = lerp(vec1.x, vec2.x, amount);
			result.y = lerp(vec1.y, vec2.y, amount);
			result.z = lerp(vec1.z, vec2.z, amount);
			result.w = lerp(vec1.w, vec2.w, amount);
			return result;
		}
		public function TestTerrainSplatGenner() 
		{
			
			var elevationBytes:ByteArray = new ELEVATION_CLS();
			var moistureBytes:ByteArray = new MOISTURE_CLS();
			
			var bitmapData:BitmapData = new BitmapData(2048, 2048, true, 0);
			var alphaBitmapData:BitmapData = new BitmapData(2048, 2048, false, 0);
			var mh:Vector3D = new Vector3D();
			var mh2:Vector3D = new Vector3D();
			var m2h:Vector3D = new Vector3D();
			var m2h2:Vector3D = new Vector3D();
			var sample:Array;
			var sampleVec:Vector3D;
			var left:Vector3D = new Vector3D();
			var right:Vector3D = new Vector3D();
			var result:Vector3D = new Vector3D();
			var heightData:BitmapData = new BitmapData(2048, 2048, false, 0);
			for (var x:int = 0; x < 2048; x++) {

				for (var y:int = 0; y < 2048; y++) {
					var elev:int = elevationBytes.readUnsignedByte();
					var gradient:Number;
					//gradient = ((elev & 0xFF0000) >> 16) / 255 * 0.3 +((elev & 0x00FF) >> 8) / 255 * 0.59 + (elev & 0xFF) / 255 * 0.11;
					//gradient *= 255;
					gradient = elev;
					var mois:int = moistureBytes.readUnsignedByte();
					var M:int = Math.floor(mois / BASE * MOISTURE.length);
					var H:int = Math.floor(gradient / BASE * HEIGHT_LEN);
					var M2:int = M < MOISTURE.length -1 ? M + 1 : M;
					var H2:int = H < HEIGHT_LEN - 1 ? H + 1 : H;
					
					/*
					(Pick Moisture zone color sample at location with blended Height)..(Blend to next moisture zone with blended Height)
					(M+H)..(M2+H)
					.blendedH .blendedH    
					(M+H2)..(M2+H2)
					*/
					
					sample = BIOMES[MOISTURE[M][H]]; sampleVec = mh;
					
					sampleVec.x = sample[0] / 100; sampleVec.y = sample[1] / 100; sampleVec.z = sample[2] / 100; sampleVec.w = sample[3] / 100;
				
					
					sample = BIOMES[MOISTURE[M][H2]]; sampleVec = mh2;
					sampleVec.x = sample[0] / 100; sampleVec.y = sample[1] / 100; sampleVec.z = sample[2] / 100; sampleVec.w = sample[3] / 100;
					
					sample = BIOMES[MOISTURE[M2][H]]; sampleVec = m2h;
					sampleVec.x = sample[0] / 100; sampleVec.y = sample[1] / 100; sampleVec.z = sample[2] / 100; sampleVec.w = sample[3] / 100;
					
					sample = BIOMES[MOISTURE[M2][H2]]; sampleVec = m2h2;
					sampleVec.x = sample[0] / 100; sampleVec.y = sample[1] / 100; sampleVec.z = sample[2] / 100; sampleVec.w = sample[3] / 100;
					
					var blendedH:Number = gradient / BASE * HEIGHT_LEN - H;
					var mBlend:Number = mois / BASE * MOISTURE.length - M;
					if (blendedH > 1 || blendedH < 0) throw new Error("invalid BlendH:"+blendedH);
					if (mBlend > 1 || mBlend < 0) throw new Error("invalid mBlend:"+mBlend + " :" + mois);
					left = lerpVector(mh, mh2, blendedH, left);
					right = lerpVector(m2h, m2h2, blendedH, right);
					result = lerpVector(left, right, mBlend, result);
					//trace(result.w);
					
					var alpha255:int = Math.round(result.w * 255);
					var a:int = Math.round(result.w * 255) << 24;
					var r:int = Math.round(result.x * 255) << 16;
					var g:int = Math.round(result.y * 255) << 8;
					var b:int = Math.round(result.z * 255);
					
					bitmapData.setPixel32(x, y, (255<<24) | r | g | b );
					//bitmapData.setPixel32(x, y, r | g | b | a);
					heightData.setPixel(x, y,  (elev<<16) | (elev<<8) | elev);
					alphaBitmapData.setPixel(x, y, (alpha255<<16)|(alpha255<<8)|alpha255);		
				}
			}
			
			new FileReference().save( PNGEncoder.encode(heightData) );
			
			//new FileReference().save( PNGEncoder.encode(bitmapData) );
			//new FileReference().save( PNGEncoder.encode(alphaBitmapData) );
			
		} 
		
		
	}
	
}