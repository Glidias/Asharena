package hashds.ds.alchemy;
import de.polygonal.ds.mem.IntMemory;
import flash.Memory;

/**
 * For storing byte data in full color format (full integer) format.
 * @author Glenn Ko
 */
class FullColorMap
{
	public var width:Int;
	public var height:Int;
	public var mem:IntMemory;

	public function new() 
	{
	
	}
	
	public inline function init(width:Int, height:Int):Void {
		this.width = width;
		this.mem = new IntMemory(width * height);
		this.height = height;
	}
	
	
	// Retreieve height data directly for writing into bytearray buffer!
		public inline function getPixel(ix:Int, iz:Int):Int {
			return mem.get(ix + iz * width); 
		}
		
		
		public inline function getPixelWithHeightScale(ix:Int, iz:Int, heightScale:Int):Int {
			return mem.get(ix + iz * width) * heightScale; 
		}
		
		public inline function setPixel(ix:Int, iz:Int, color:UInt):Void {
			mem.set(ix + iz * width, color); 
		}
		
		public inline function copyPixelsTo(result:IntMemory, ix:Int, iy:Int, iwidth:Int, iheight:Int, dx:Int, dy:Int, dWidth:Int ):Void {
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
		
		public inline function dispose():Void {
			mem.free();
		}
		
		//  Need to properly intepolate individual color channels???
		/*
		public inline function samplePixelsTo(result:IntMemory, ix:Float, iy:Float, ratio:Float, iwidth:Float, iheight:Float,dx:Int, dy:Int, dWidth:Int):Void {
			iwidth += ix;
			iheight += iy;
			while (iy < iheight) {
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
	
		
		
		
		public inline function sample(x:Float,  z:Float):Int 

		// Returns the height (y-value) of a point in this heightmap.  The given (x,z) are in
		// world coordinates.  Heights outside this heightmap are considered to be 0.  Heights
		// between sample points are bilinearly interpolated from surrounding points.
		// xxx deal with edges: either force to 0 or over-size the query region....
		{
			// Break coordinates into grid-relative coords (ix,iz) and remainder (rx,rz).
			var xi:Int = Std.int(x);
			var zi:Int = Std.int(z);
			
			var	ix:Int = (xi >> Scale);
			var	iz:Int = (zi >> Scale);
			
			
			var	mask:Int = (1 << Scale) - 1;
			var	rx:Int = (xi) & mask;
			var	rz:Int = (zi) & mask;
		
		
			if (ix < 0 || ix > width-1 || iz < 0 || iz > height-1) {
				
				if (ix < 0) ix  = 0;
				if (iz < 0 ) iz = 0;
				if (ix >= width ) ix = width - 1;
				if (iz >= height) iz = height -1;
				
				throw "Out of bounds sample!";
				//return 0;	// Outside the grid.
			}

			var	fx:Float = rx / (mask + 1);
			var	fz:Float = rz / (mask + 1);

			var widthAdd:Int = ix < width-1 ? 1 : 0;
			var heightAdd:Int = iz < height - 1 ? 1 : 0;  // clamp addition
			var	s00:Int = mem.get(ix + iz * width);
			var	s01:Int =  mem.get((ix+ widthAdd ) + iz * width);
			var	s10:Int =  mem.get(ix + (iz+heightAdd) * width);
			var	s11:Int =  mem.get((ix+ widthAdd) + (iz+heightAdd) * width);

			return round( (s00 * (1-fx) + s01 * fx) * (1-fz) +
				(s10 * (1-fx) + s11 * fx) * fz );
		}
		*/
		
		 /**
         * Fast version of <em>Math.round</em>(<code>x</code>).<br/>
         * Half-way cases are rounded away from zero.
         */
        inline private function round(x:Float):Int
        {
                return Std.int(x + (0x4000 + .5)) - 0x4000;
        }
	
	
	
	
	
}