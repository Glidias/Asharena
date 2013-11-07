package hashds.ds.alchemy;
import de.polygonal.ds.mem.ByteMemory;
import de.polygonal.ds.mem.IntMemory;
import de.polygonal.ds.mem.ShortMemory;
import flash.Memory;

/**
 * For storing byte data of heights in short format to be parsed later
 * @author Glenn Ko
 */
class ShortHeightMap
{
	public var width:Int;
	public var height:Int;
	public var mem:ShortMemory;

	public function new() 
	{
	
	}
	
	public inline function dispose():Void {
			mem.free();
		}
	
	public inline function init(width:Int, height:Int):Void {
		this.width = width;
		this.mem = new ShortMemory(width * height);
		this.height = height;
	}
	
	
	// Retreieve height data directly for writing into bytearray buffer!
		public inline function getPixel(ix:Int, iz:Int):Int {
			return mem.get(ix + iz * width); 
		}
		
		public inline function getPixelWithHeightScale(ix:Int, iz:Int, heightScale:Int):Int {
			return mem.get(ix + iz * width) * heightScale; 
		}
		
		public inline function setPixel(ix:Int, iz:Int, shortValue:Int):Void {
			mem.set(ix + iz * width, shortValue); 
		}
		
		public inline function copyPixelsTo(result:ShortMemory, ix:Int, iy:Int, iwidth:Int, iheight:Int, dx:Int, dy:Int, dWidth:Int ):Void {
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
		
		
		
		public inline function samplePixelsTo(result:ShortMemory, ix:Float, iy:Float, ratio:Float, iwidth:Float, iheight:Float,dx:Int, dy:Int, dWidth:Int):Void {
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
		

		
		public inline function sample(x:Float,  z:Float):Int 

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
		
		 /**
         * Fast version of <em>Math.round</em>(<code>x</code>).<br/>
         * Half-way cases are rounded away from zero.
         */
        inline private function round(x:Float):Int
        {
                return Std.int(x + (0x4000 + .5)) - 0x4000;
        }
	
	
	
	
	
}