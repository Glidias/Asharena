package hashds.ds.alchemy;
import de.polygonal.ds.mem.ByteMemory;
import de.polygonal.ds.mem.IntMemory;
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
	public var Scale:Int;

	public function new() 
	{
	
	}
	
	public inline function dispose():Void {
			mem.free();
		}
	
	public inline function init(width:Int, height:Int, Scale:Int=0):Void {
		this.width = width;
		this.mem = new ByteMemory(width * height);
		this.height = height;
		this.Scale = Scale;
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
			 color |= (mem.get(baseI++) << 16); 
			 return color;
		}
		
		public inline function getPixelChannel(ix:Int, iz:Int, channelOffset:Int):Int {
			var baseI:Int = ix + iz * width;
			baseI *= 3;
			baseI += channelOffset;
			return mem.get(baseI); 
		}
		
		public inline function setPixel(ix:Int, iz:Int, color:UInt):Void {
			var coor:Int = ix + iz * width;
			coor *= 3;
			mem.set(coor, blue(color)); 
			mem.set(coor, green(color)); 
			mem.set(coor, red(color)); 
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
			for (y in iy...iheight) {
				for (x in ix...iwidth) {
					var baseI:Int = dx  + dy * dWidth;
					baseI *= 3;
					var meI:Int = x * y + width;
					meI *= 3;
					result.set(baseI++, mem.get(meI++) );
					result.set(baseI++, mem.get(meI++) );
					result.set(baseI++, mem.get(meI++) );
					dx++;
				}
				dy++;
			}
		}
		//*/
		
		
		// NOT SUPPORTED ATM... need to intepolate across channels..
		
		public inline function samplePixelsTo(result:ByteMemory, ix:Float, iy:Float, ratio:Float, iwidth:Float, iheight:Float,dx:Int, dy:Int, dWidth:Int):Void {
			iwidth += ix;
			iheight += iy;
			while (iy < iheight) {
				while (ix < iwidth) {
					var baseI:Int = dx  + dy * dWidth;
					baseI *= 3;
					result.set(baseI++, sample(ix,iy,0) );
					result.set(baseI++, sample(ix,iy,1) );
					result.set(baseI, sample(ix,iy,2) );
					ix += ratio;
					dx++;
				}
				iy += ratio;
				dy++;
			}
		}
		
		/*
		public inline function samplePixelsTo2(result:IntMemory, ix:Float, iy:Float, ratio:Float, iwidth:Float, iheight:Float,dx:Int, dy:Int, dWidth:Int, scale:Int, base:Int):Void {
			iwidth += ix;
			iheight += iy;
			while (iy < iheight) {
				while (ix < iwidth) {
					result.set(dx + dy * dWidth , sample(ix,iy)*scale + base );
					ix += ratio;
					dx++;
				}
				iy += ratio;
				dy++;
			}
		}
		*/
	
		
		
		
		public inline function sample(x:Float,  z:Float, channelOffset:Int):Int 
		// Returns the height (y-value) of a point in this heightmap.  The given (x,z) are in
		// world coordinates.  Heights outside this heightmap are considered to be 0.  Heights
		// between sample points are bilinearly interpolated from surrounding points.
		// xxx deal with edges: either force to 0 or over-size the query region....
		{
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
			var	s00:Int = mem.get(xi + zi * width);
			var	s01:Int =  mem.get((xi+ widthAdd ) + zi * width);
			var	s10:Int =  mem.get(xi + (zi+heightAdd) * width);
			var	s11:Int =  mem.get((xi+ widthAdd) + (zi+heightAdd) * width);

			return round( (s00 * (1-fx) + s01 * fx) * (1-fz) +
				(s10 * (1-fx) + s11 * fx) * fz );
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