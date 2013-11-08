package hashds.ds.alchemy;
import de.polygonal.ds.mem.ByteMemory;
import de.polygonal.ds.mem.IntMemory;
import flash.display.BitmapData;
import flash.errors.Error;
import flash.Memory;

/**
 * For storing byte data of colors in 3byte BGR format to late upload to Stage3D. We assume the "A" in BGRA is always 255.
 * @author Glenn Ko
 */
class ColorMap
{
	public var width:Int;
	public var height:Int;
	public var mem:ByteMemory;

	public function new() 
	{
	
	}
	
	public inline function dispose():Void {
			mem.free();
		}
	
	public inline function init(width:Int, height:Int):Void {
		this.width = width;
		this.mem = new ByteMemory(width * height *3);
		this.height = height;
	}
	
	public static function createFromBitmapData(data:BitmapData):ColorMap {
		var map:ColorMap = new ColorMap();
		map.init(data.width, data.height);
		
		for (y in 0...map.height) {
			for (x in 0...map.width) {
				map.setPixel(x, y, data.getPixel(x,y));
			}
		}
		return map;
	}
	
	public function toBitmapDataFlash():BitmapData {
		var data:BitmapData = new BitmapData(width, height, false, 0);
		for (y in 0...height) {
			for (x in 0...width) {
				data.setPixel(x, y, getPixel(x,y));
			}
		}
		return data;
	}
	
	
	public function previewUpscaled(scale:Int = 2):BitmapData {
		var newMap:ColorMap = new ColorMap();
		newMap.init(width * scale, height * scale);
		
			var rec:Float = 1 / scale;
			samplePixelsTo(newMap.mem, 0, 0, rec, width, height, 0, 0, width * scale);
		/*
		if (scale != 1) {
		
		}
		else {
		*/
		//	copyPixelsTo(newMap.mem, 0, 0, width, height, 0, 0, width * scale);
		//}
		//newMap.fill(0xFF0000);
		return newMap.toBitmapDataFlash();
		
	}
	
	
	
	// Retreieve height data directly for writing into bytearray buffer!
	
		/**
		 * 
		 * @param	ix
		 * @param	iz
		 * @return In ARGB
		 */
		public inline function getPixel(ix:Int, iz:Int):UInt {
			var baseI:Int = ix + iz * width;
			baseI *= 3;
			var color:UInt = 0xFF000000;
			 color |= mem.get(baseI++); 
			 color |= (mem.get(baseI++) << 8); 
			 color |= (mem.get(baseI) << 16); 
			 return color;
		}
		
		public inline function getPixelChannel(ix:Int, iz:Int, channelOffset:Int):Int {
			ix = ix >= width ? width - 1 : ix;
			iz = iz >= height ? height - 1: iz;
			var baseI:Int = ix + iz * width;
			baseI *= 3;
			baseI += channelOffset;
			return mem.get(baseI); 
		}
		
		public inline  function setPixel(ix:Int, iz:Int, color:UInt):Void {
			var coor:Int = ix + iz * width;
			coor *= 3;
			mem.set(coor++, blue(color)); 
			mem.set(coor++, green(color)); 
			mem.set(coor, red(color)); 
			
		}
		
		public inline function fill(color:UInt):Void {
			var len:Int = mem.size;
			var i:Int = 0;
			while( i < len) {
				mem.set(i++, blue(color) );
				mem.set(i++, green(color) );
				mem.set(i++, red(color) );
			}
		}
		

		
		private inline function red(color:UInt):UInt {
			return (color & 0xFF0000) >> 16;
		}
		private inline function green(color:UInt):UInt {
			return (color & 0xFF00) >> 8;
		}
		private inline function blue(color:UInt):UInt {
			return (color & 0xFF);
		}
		///*
		public inline function copyPixelsTo(result:ByteMemory, ix:Int, iy:Int, iwidth:Int, iheight:Int, dx:Int, dy:Int, dWidth:Int ):Void {
			iwidth += ix;
			iheight += iy;
			var startX:Int = dx;
			var count = 0;
			for (y in iy...iheight) {
				dx = startX;
				for (x in ix...iwidth) {
					var baseI:Int = dx  + dy * dWidth;
					baseI *= 3;
					var meI:Int = x + y * width;
					meI *= 3;
					result.set(baseI++, mem.get(meI++) );
					result.set(baseI++, mem.get(meI++) );
					result.set(baseI, mem.get(meI++) );
					count++;
					dx++;
				}
				dy++;
			}
			//throw count + ", "+(iwidth*iheight) + ", "+width + ", "+height;
		}
		//*/
		
		

		inline
		public function samplePixelsTo(result:ByteMemory, ix:Float, iy:Float, ratio:Float, iwidth:Float, iheight:Float, dx:Int, dy:Int, dWidth:Int):Void {
			
			iwidth += ix;
			iheight += iy;
			var startX:Float = ix;
			var startDX:Int = dx;
			var area:Int = 0;
			
			while (iy < iheight) {
				var baseY:Int =  dy * dWidth;
				ix = startX;
				dx = startDX;
				while (ix < iwidth) {
					var baseI:Int = dx  + baseY;
					baseI *= 3;
					
					result.set(baseI++, sample(ix, iy, 0) );
					result.set(baseI++, sample(ix, iy, 1) );
					result.set(baseI, sample(ix, iy, 2) );
					area++;
					ix += ratio;
					dx++;
				}
				iy += ratio;
				dy++;
			}
	
		}
		
		
		
		
		inline
		public  function sample(x:Float,  z:Float, channelOffset:Int):Int   //
		// Returns the height (y-value) of a point in this heightmap.  The given (x,z) are in
		// world coordinates.  Heights outside this heightmap are considered to be 0.  Heights
		// between sample points are bilinearly interpolated from surrounding points.
		// xxx deal with edges: either force to 0 or over-size the query region....
		{
			

			
			return getPixelChannel( round(x), round(z), channelOffset);  // naive roundoff sampling
			
			/*
			// Break coordinates into grid-relative coords (ix,iz) and remainder (rx,rz).
		
			var xi:Int = Std.int(x);
			var zi:Int = Std.int(z);
			if (xi < 0 || xi > width-1 || zi < 0 || zi > height-1) {  // debug code
				
				if (xi < 0) xi  = 0;
				if (zi < 0 ) zi = 0;
				if (xi >= width ) xi = width - 1;
				if (zi >= height) zi = height -1;
				
				throw "Out of bounds sample!";
				//return 0;	// Outside the grid.
			}

			var	fx:Float = x - xi;
			var	fz:Float = z - zi;
			

			

			var widthAdd:Int = xi < width-1 ? 1 : 0;
			var heightAdd:Int = zi < height - 1 ? 1 : 0;  // clamp addition
			var	s00:Int =getPixelChannel(xi, width, channelOffset);  // tl
			var	s01:Int = getPixelChannel((xi+ 1 ), zi, channelOffset ); // tr
			var	s10:Int =  getPixelChannel(xi, (zi+1), channelOffset );  // bl
			var	s11:Int =  getPixelChannel((xi+ 1) , (zi+1), channelOffset); // br
			
			var area:Float = (1*(1-fx)*(1-fz)  + 1*(fx * (1-fz)) + 1*((1-fx)*fz) + 1*(fx * fz) );
			if (area != 1) {
				
				throw "ivnalid area:" + area + ", "+fx + ", "+fz + " , "+(fx * fz) + " , "+((1-fx) * fz);
			}
			
			//return round( (s00*(1-fx)*(1-fz)  + s01*(fx * (1-fz)) + s10*((1-fx)*fz) + s11*(fx * fz) )   );
			
			return round( (s00 * (1-fx) + s01 * fx) * (1-fz) + (s10 * (1-fx) + s11 * fx) * fz );
			*/
		}
		//*/
		
		 /**
         * Fast version of <em>Math.round</em>(<code>x</code>).<br/>
         * Half-way cases are rounded away from zero.
         */
        inline private function round(x:Float):Int
        {
                return Std.int(x + (0x4000 + .5)) - 0x4000;
        }
	
	
	
	
	
}