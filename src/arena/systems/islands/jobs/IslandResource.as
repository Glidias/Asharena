package arena.systems.islands.jobs 
{
	import flash.display.BitmapData;
	import flash.utils.ByteArray;
	/**
	 * This island resource is generated from it's mapgen2 blueprint. It is saved under a KDNode reference.
	 * @author Glenn Ko
	 */
	public class IslandResource 
	{	
		/*
		public var grayScaleHeight:ByteArray; // the raw grayscale heightmap to sample point, /intepolate average, etc. and apply noise if needed. ... Max Size of this is 1024x1024/2048x2048 unique height values. Any island larger than this would need to intepolate between height values.
		public var vAcross:int;  // the number of unique height vertex values across for the grayScaleHeight
		*/
		
		public var heightMap:BitmapData;  // grayscale heightmap
		
		public var minHeight:int;  // the starting minimum "zero" height value
		public var heightMult:Number;  // height multiplier for grayScaleHeight
		public var scaleRatio:Number = 1; // xy scale ratio multiplier. Ratio value indicates tile resolution, smaller ratios means each byte covers more tiles.
		
	
		 // Max size of all bitmapdatas and bytearrays below is maximum 1024x1024
		 
		 // Textures
		//public var colorMap:BitmapData;
		//public var splatMap:BitmapData; 
		//public var tileMap:ByteArray;  // this will be a problem if upscaled, it will be more cornerly unless smothing is done to noise the edges.
		
		// Biomes for item placement
		//public var biomeMap:BitmapData;
		
		
		// Otherwise, if island region size is 256x256/128x128 or lower, consider:
		/*
		public var heightMapProcessed:Vector.<Number>;  // the entire processed heightMap from grayScale heightmap bitmapData;
		public var normalMapProcessed:BitmapData;  //  the entire processed normalMap from above.
		//public var heightMapDataProcessed:BitmepData; // not needed unless
		*/
				
		/*
		 .125 km   - 64x64		(Possible to use 1 full Terrain LOD instead)
		.25 km   -128x128 		(Possible to use 1 full  Terrain LOD instead)
		.5 km   - 256x256   		(Possible to use 1 full  Terrain LOD instead) or  (grayscale sampling) at stride1 (CopyPixels) resolution
		1 km  (1km2) - 512x512     (grayscale sampling) at stride1 resolution (CopyPixels)
		2 km (4km2) - 1024x1024     (grayscale sampling) at stride1 resolution (CopyPixels)
		4 km  (16km2) - 2048x2048  (grayscale sampling) (1 humongous texture) at stride2/1 resolution (draw)

		8 km (64km2) - 4016x4016   (grayscale sampling) (4 humongous textures) at stride4/2 resolution (draw)
		16km (256km2) - 8192x8192  (grayscale sampling) (16 humongous textures) at stride8/4 resolution (draw)

		1 QuadTreePage -> 1 Material (Naive)  Makes streaming straightfoward

		_________________________________________


		Methods to sample grayscale heightmap:
		---------------------------------------
		1) Grayscale byte sampling (Slower runtime, less mem-storage required, manual loop code sampling...but could use Alchemy, but Alchemy within Worker works?). Using this method could allow for up to 16km2 islands without having to upscale.
		CANVAS SIZE:
		128x128 grayscale vector
		Reset 128x128 to zero.
		For each island bytearray hit region within the 128x128 space, sample height into vector, and add noise!. If no island hit, return with empty data param. Create normal map from sampled heights with noise.

		Using this sampling approach might result in fidelity loss since there's no downscaling but simply skip sampling.
		*/
		
		public function IslandResource() 
		{
			
		}
		
	}

}