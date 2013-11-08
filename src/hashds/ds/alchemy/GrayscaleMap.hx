package hashds.ds.alchemy;
import de.polygonal.ds.mem.ByteMemory;
import de.polygonal.ds.mem.IntMemory;
import de.polygonal.ds.mem.ShortMemory;
import flash.display.BitmapData;
import flash.Memory;

/**
 * For storing byte data of heights in byte format that can later be upgraded to short/integer format
 * @author Glenn Ko
 */
class GrayscaleMap
{
	public var width:Int;
	public var height:Int;
	public var mem:ByteMemory;

	public function new() 
	{
	
	}
	
	public inline function init(width:Int, height:Int):Void {
		this.width = width;
		this.mem = new ByteMemory(width * height);
		this.height = height;
	}
	
		public static function createFromBitmapData(data:BitmapData):GrayscaleMap {
		var map:GrayscaleMap = new GrayscaleMap();
		map.init(data.width, data.height);
		
		for (y in 0...map.height) {
			for (x in 0...map.width) {
				map.setPixel(x, y, data.getPixel(x,y) & 0xFF);
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
		var newMap:GrayscaleMap = new GrayscaleMap();
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
		public inline function getPixel(ix:Int, iz:Int):UInt {
			var byte:Int = mem.get(ix + iz * width);
			return 0xFF000000 | (byte << 16) | (byte << 8) | byte;
		}
		
		public inline function getPixelWithHeightScale(ix:Int, iz:Int, heightScale:Int):Int {
			return mem.get(ix + iz * width) * heightScale; 
		}
		
		public inline function setPixel(ix:Int, iz:Int, byteValue:Int):Void {
			mem.set(ix + iz * width, byteValue); 
		}
		
		public function setFromBitmapData(bmpData:BitmapData):Void {
			var iwidth:Int = bmpData.width;
			var iheight:Int = bmpData.height;
			for (y in 0...iheight) {
				var baseY:Int = y * width;
				for (x in 0...iwidth) {
					mem.set(x + baseY, bmpData.getPixel(x, y) & 0xFF  );
				}
			}
			var b:Int = height - 1;
			for (x in 0...width) {
				mem.set(x + b, bmpData.getPixel(x, b) & 0xFF  );
			}
			
			b  = width - 1;
			for (y in 0...height) {
				mem.set(y*width+b, bmpData.getPixel(b, y) & 0xFF  );
			}
		
		}
		
		public inline function copyPixelsTo(result:ByteMemory, ix:Int, iy:Int, iwidth:Int, iheight:Int, dx:Int, dy:Int, dWidth:Int ):Void {
			iwidth += ix;
			iheight += iy;
			for (y in iy...iheight) {
				for (x in ix...iwidth) {
					result.set(dx + dy * dWidth , mem.get( x + y * width ) );
					dx++;
				}
				dy++;
			}
		}
		
		public inline function copyPixelsTo2(result:IntMemory, ix:Int, iy:Int, iwidth:Int, iheight:Int,  dx:Int, dy:Int, dWidth:Int, scale:Int, base:Int ):Void {
			iwidth += ix;
			iheight += iy;
			for (y in iy...iheight) {
				for (x in ix...iwidth) {
					result.set(dx + dy * dWidth , mem.get( x + y * width ) * scale + base );
					dx++;
				}
				dy++;
			}
		}
		
		public inline function copyPixelsTo3(result:ShortMemory, ix:Int, iy:Int, iwidth:Int, iheight:Int,  dx:Int, dy:Int, dWidth:Int, scale:Int, base:Int ):Void {
			iwidth += ix;
			iheight += iy;
			for (y in iy...iheight) {
				for (x in ix...iwidth) {
					result.set(dx + dy * dWidth , mem.get( x + y * width ) * scale + base );
					dx++;
				}
				dy++;
			}
		}
		
		
		public inline function samplePixelsTo(result:ByteMemory, ix:Float, iy:Float, ratio:Float, iwidth:Float, iheight:Float,dx:Int, dy:Int, dWidth:Int):Void {
			iwidth += ix;
			iheight += iy;
			var startX:Float = ix;
			var startDX:Int = dx;
			while (iy < iheight) {
				ix = startX;
				dx = startDX;
				while (ix < iwidth) {
					result.set(dx + dy * dWidth , sample(ix,iy) );
					ix += ratio;
					dx++;
				}
				iy += ratio;
				dy++;
			}
		}
		
		public inline function samplePixelsTo2(result:IntMemory, ix:Float, iy:Float, ratio:Float, iwidth:Float, iheight:Float,dx:Int, dy:Int, dWidth:Int, scale:Int, base:Int):Void {
			iwidth += ix;
			iheight += iy;
			var startX:Float = ix;
			var startDX:Int = dx;
			while (iy < iheight) {
				ix = startX;
				dx = startDX;
				while (ix < iwidth) {
					result.set(dx + dy * dWidth , sample(ix,iy,scale,base) );
					ix += ratio;
					dx++;
				}
				iy += ratio;
				dy++;
			}
		}
		
		public inline function samplePixelsTo3(result:ShortMemory, ix:Float, iy:Float, ratio:Float, iwidth:Float, iheight:Float,dx:Int, dy:Int, dWidth:Int, scale:Int, base:Int):Void {
			iwidth += ix;
			iheight += iy;
						var startX:Float = ix;
			var startDX:Int = dx;
			while (iy < iheight) {
				ix = startX;
				dx = startDX;
				while (ix < iwidth) {
					result.set(dx + dy * dWidth , sample(ix,iy,scale,base) );
					ix += ratio;
					dx++;
				}
				iy += ratio;
				dy++;
			}
		}
		
		public inline function dispose():Void {
			mem.free();
		}
	
		
		
		
		public inline function sample(x:Float,  z:Float, scale:Int=1, base:Int=0):Int 

		// Returns the height (y-value) of a point in this heightmap.  The given (x,z) are in
		// world coordinates.  Heights outside this heightmap are considered to be 0.  Heights
		// between sample points are bilinearly interpolated from surrounding points.
		// xxx deal with edges: either force to 0 or over-size the query region....
		{
			
			return getPixel(round(x), round(z));  // naive roundoff sampling
			
		
		
			
			
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
			var	s00:Int = mem.get(xi + zi * width)*scale+base;
			var	s01:Int =  mem.get((xi+ widthAdd ) + zi * width)*scale+base;
			var	s10:Int =  mem.get(xi + (zi+heightAdd) * width)*scale+base;
			var	s11:Int =  mem.get((xi+ widthAdd) + (zi+heightAdd) * width)*scale+base;

			return round( (s00 * (1-fx) + s01 * fx) * (1-fz) +
				(s10 * (1-fx) + s11 * fx) * fz );
				
				*/
		}
		
		 /**
         * Fast version of <em>Math.round</em>(<code>x</code>).<br/>
         * Half-way cases are rounded away from zero.
         */
        inline private function round(x:Float):Int
        {
                return Std.int(x + (0x4000 + .5)) - 0x4000;
        }
	
	
	
	
	
}