package altern.terrain;

import de.polygonal.ds.NativeInt32Array;
import de.polygonal.ds.tools.NativeInt32ArrayTools;
import util.TypeDefs;
import util.geom.PMath;


/**
 * @author Thatcher Ulrich (tu@tulrich.com)
 * @author Glenn Ko
 */
class HeightMapInfo //implements IExternalizable
{
	
	public function new() 
	{
		
	}
	
	//int16*	
	public var Data:NativeInt32Array;
	public var XOrigin:Int;
	public var ZOrigin:Int;
	public var XSize:Int;
	public var ZSize:Int;
	public var RowWidth:Int;
	public var Scale:Int = 8;
	
	
	// Retreieve height data directly for writing into bytearray buffer!
	public function getData(ix:Int, iz:Int):Int {
		return Data[ix + iz * RowWidth]; 
	}
	
	public function fillDataWithValue(val:Int):Void {
		var i:Int = Data.length;
		while (--i > -1) Data[i] = val;
	}
	
	/*
	public function getShortData(ix:int, iz:int):int { 
		var i:int = (ix + iz * RowWidth) << 1;
		return ((ShortData[i] << 8) | ShortData[i + 1]);   
	}
	*/

	public function setFixed(val:Bool):Void {
		TypeDefs.setVectorLen(Data, Data.length, val ? 1 : 0);
	}
	

	
	public function BoxFilterHeightMap(
				   smoothEdges:Bool=true):Void
{
//     width: Width of the height map in bytes
//    height: Height of the height map in bytes
// heightMap: Pointer to your height map data

// Temporary values for traversing single dimensional arrays
var x:Int = 0;
var z:Int = 0;
var width:Int = XSize;
var height:Int = width;

var  widthClamp:Int = (smoothEdges) ?  width : width  - 1;
var heightClamp:Int = (smoothEdges) ? height : height - 1;

// [Optimization] Calculate bounds ahead of time
var bounds:Int = widthClamp * heightClamp;

// Validate requirements


// TODO: pre-Allocate the result for optimized cases
var result:NativeInt32Array = NativeInt32ArrayTools.alloc(Data.length);  // this should be a float

var heightMap:NativeInt32Array = Data;



z = (smoothEdges) ? 0 : 1;
while ( z < heightClamp)
{
	x = (smoothEdges) ? 0 : 1;
	while ( x < widthClamp)
	{
	  // Sample a 3x3 filtering grid based on surrounding neighbors
	  
	  var value:Float = 0.0;
	  var cellAverage:Float = 1.0;
	  
	  // Sample top row
	  
	  if (((x - 1) + (z - 1) * width) >= 0 &&
		  ((x - 1) + (z - 1) * width) < bounds)
	  {
		value += heightMap[(x - 1) + (z - 1) * width];
		++cellAverage;
	  }
	  
	  if (((x - 0) + (z - 1) * width) >= 0 &&
		  ((x - 0) + (z - 1) * width) < bounds)
	  {
		value += heightMap[(x    ) + (z - 1) * width];
		++cellAverage;
	  }
	  
	  if (((x + 1) + (z - 1) * width) >= 0 &&
		  ((x + 1) + (z - 1) * width) < bounds)
	  {
		value += heightMap[(x + 1) + (z - 1) * width];
		++cellAverage;
	  }
	  
	  // Sample middle row
	  
	  if (((x - 1) + (z - 0) * width) >= 0 &&
		  ((x - 1) + (z - 0) * width) < bounds)
	  {
		value += heightMap[(x - 1) + (z    ) * width];
		++cellAverage;
	  }
	  
	  // Sample center point (will always be in bounds)
	  value += heightMap[x + z * width];
	  
	  if (((x + 1) + (z - 0) * width) >= 0 &&
		  ((x + 1) + (z - 0) * width) < bounds)
	  {
		value += heightMap[(x + 1) + (z    ) * width];
		++cellAverage;
	  }
	  
	  // Sample bottom row
	  
	  if (((x - 1) + (z + 1) * width) >= 0 &&
		  ((x - 1) + (z + 1) * width) < bounds)
	  {
		value += heightMap[(x - 1) + (z + 1) * width];
		++cellAverage;
	  }
	  
	  if (((x - 0) + (z + 1) * width) >= 0 &&
		  ((x - 0) + (z + 1) * width) < bounds)
	  {
		value += heightMap[(x    ) + (z + 1) * width];
		++cellAverage;
	  }
	  
	  if (((x + 1) + (z + 1) * width) >= 0 &&
		  ((x + 1) + (z + 1) * width) < bounds)
	  {
		value += heightMap[(x + 1) + (z + 1) * width];
		++cellAverage;
	  }
	  
	  // Store the result
	  result[x + z * width] = Std.int(value / cellAverage);
	  
	  ++x;
	}
	
	++z;
}



// Store the new one
Data = result;
}

	public function	Sample(x:Int,  z:Int):Float 

	// Returns the height (y-value) of a point in this heightmap.  The given (x,z) are in
	// world coordinates.  Heights outside this heightmap are considered to be 0.  Heights
	// between sample points are bilinearly interpolated from surrounding points.
	// xxx deal with edges: either force to 0 or over-size the query region....
	{
		// Break coordinates into grid-relative coords (ix,iz) and remainder (rx,rz).

		var	ix:Int = (x - XOrigin) >> Scale;
		var	iz:Int = (z - ZOrigin) >> Scale;
		
		
		var	mask:Int = (1 << Scale) - 1;
		var	rx:Int = (x - XOrigin) & mask;
		var	rz:Int = (z - ZOrigin) & mask;
	
		

		if (ix < 0 || ix > XSize-1 || iz < 0 || iz > ZSize-1) {
			throw ("OUTSIDE!" + ix + "," + iz + ", " + XSize);
			if (ix < 0) ix  = 0;
			if (iz < 0 ) iz = 0;
			if (ix >= XSize ) ix = XSize - 1;
			if (iz >= ZSize) iz = ZSize -1;
			//return 0;	// Outside the grid.
		}
		
		

		var	fx:Float = rx / (mask + 1);
		var	fz:Float = rz / (mask + 1);

		var xSizeAdd:Int = ix < XSize-1 ? 1 : 0;
		var zSizeAdd:Int = iz < ZSize - 1 ? 1 : 0;  // clamp addition
		var	s00:Float = Data[ix + iz * RowWidth];
		var	s01:Float = Data[(ix+ xSizeAdd ) + iz * RowWidth];
		var	s10:Float = Data[ix + (iz+zSizeAdd) * RowWidth];
		var	s11:Float = Data[(ix+ xSizeAdd) + (iz+zSizeAdd) * RowWidth];

		return ( (s00 * (1-fx) + s01 * fx) * (1-fz) +
			(s10 * (1-fx) + s11 * fx) * fz );
	}
	
	public function clone():HeightMapInfo {
		var result:HeightMapInfo = new HeightMapInfo();
		
		result.XOrigin= XOrigin;
		result.ZOrigin= ZOrigin;
		result.XSize= XSize;
		result.ZSize= ZSize;
		result.RowWidth= RowWidth;
		result.Scale = Scale;
		result.Data = NativeInt32ArrayTools.copy(Data);
		return result;
	}
	
	public function flatten(val:Int = 0):Void {
		var len:Int = Data.length;
		var i:Int = 0;
		while (i < len) {
			Data[i] = val;
			i++;
		}
	}
	
	public function slopeAlongY(val:Int):Void {
		
		var len:Int = Data.length;
		var y:Int = 0;
		while ( y < ZSize) {
			
			var x:Int = 0;
			while( x < XSize ) {
				Data[y * XSize+x] += val * y;
				x++;
			}
			y++;
		}
		
	}
	
	public function slopeAltAlongY(val:Int):Void {
		
		var len:Int = Data.length;
		var y:Int = 0;
		while ( y < ZSize) {
			var x:Int = 0;
			while ( x < XSize) {
				Data[y * XSize+x] += ( (y & 1)!=0 ? 1 : -1) * val;
			}
		}
	}
	
	public function randomise(val:Int):Void {
		val *= Std.int(.5);
		var len:Int = Data.length;
		var i:Int = 0;
		while ( i < len) {
			Data[i] += Std.int( -Math.random() * val + val * 2 );
			i++;
		}
	}
	
	/*
	public function getHighestLowestBounds():Vector<Float> {
		var vec:Vector<Float>  = new Vector<Float>(2, true);
		var min:Float =  PMath.FLOAT_MAX;// Number.MAX_VALUE;
		var max:Float = -PMath.FLOAT_MAX; // -Number.MAX_VALUE;
		var i:Int = Data.length;
		var h:Float;
		while (--i > -1) {
			h = Data[i];
			if (h < min) min = h;
			if (h > max) max = h;
		}
		vec[0] = min;
		vec[1] = max;
		return vec;
	}
	*/

	/*
	public function setFromMesh(mesh:Mesh, heightScale:Number=1, heightOffset:Number=0):void {
		mesh.calculateBounds();
		Scale = 8;
		
		XOrigin = mesh.boundMinX;
		ZOrigin = mesh.boundMinY;
		var vertsX:int = (int(mesh.boundMaxX - mesh.boundMinX) >> 8) + 1;
		var vertsY:int = (int(mesh.boundMaxY - mesh.boundMinY) >> 8) + 1;
		
		RowWidth = vertsX;
		XSize = RowWidth;
		ZSize = vertsY;
		
		var data:Vector.<int> =  new Vector.<int>( (vertsX+1) * (vertsY+1), true);
		for (var v:Vertex = mesh.vertexList; v != null; v = v.next) {
			data[(int(v.y-mesh.boundMinY) >> 8)*vertsX  +   (int(v.x-mesh.boundMinX) >> 8)] = v.z * heightScale + heightOffset;
		}
		Data = data;
	}
	*/
	
	public function copyData(xStart:Int, yStart:Int, width:Int, height:Int, hm:HeightMapInfo, destX:Int = 0, destY:Int = 0 ):Void {
		var vec = hm.Data;
		var xEnd:Int = xStart + width;
		var yEnd:Int = yStart + height;
		var y:Int = yStart;
		while (y < yEnd) {
			var x:Int = xStart;
			while ( x < xEnd ) {
				var cx:Int = x < 0 ? 0 : x >= hm.XSize ? hm.XSize - 1 : x;
				var cy:Int = y < 0 ? 0 : y >= hm.ZSize ? hm.ZSize - 1 : y;
				Data[(y - yStart + destY) * XSize + x - xStart + destX] = vec[ cy * hm.XSize + cx ];
				x++;
			}
			y++;
		}
	}
	
	public static function isBase2(val:Int):Bool {
		return Math.pow(2, Math.round( Math.log(val) * PMath.LOG2E) ) == val;
	}
	
	
	public static function createFlat(patchesAcross:Int, tileSize:Int=256):HeightMapInfo {
		var me:HeightMapInfo = new HeightMapInfo();
		me.Scale = Math.round( Math.log(tileSize ) * PMath.LOG2E);
		var RowWidth:Int;
		me.RowWidth = RowWidth = patchesAcross + 1;
		me.XSize = RowWidth;
		me.ZSize = RowWidth;
		me.Data =  NativeInt32ArrayTools.alloc(RowWidth * RowWidth);
		return me;
	}
	
	/*
	public function setFromByteArray(byteArray:ByteArray, heightMult:Float, patchesAcross:Int, heightMin:Int=0, tileSize:Int=256):Void 
	{
		if (!isBase2(tileSize)) throw ("Tile size isn't base 2!");
		Scale = Math.round( Math.log(Number(tileSize) ) * Math.LOG2E);
		var bWidth:Int; var bHeight:Int;
		var vertsX:Int = bWidth = patchesAcross + 1;
		var vertsY:Int = bHeight = patchesAcross + 1;
		
		RowWidth = vertsX;
		XSize = RowWidth;
		ZSize = vertsY;
		
		var data:Vector<Int> =  new Vector<Int>( vertsX*vertsX, true);
		var by:Int = patchesAcross + 1;

		var lastValue:UInt;
		var y:Int = 0; 
		while (y <  patchesAcross ) {
			var x:Int = 0; 
			//var x:int = 0; x < patchesAcross; x++
			while ( x < patchesAcross) {
				var xer:Int = x < bWidth ? x : bWidth - 1;
				var yer:Int = y < bHeight ? y : bHeight - 1;
				data[y * by  +  x] = heightMin + (lastValue = byteArray.readUnsignedByte()) * heightMult;
			}
			data[y * by + x] = heightMin + lastValue * heightMult;
			y++;
		}
		x = 0; 
		while (x < by) {
			data[y * by + x] = data[(y - 1) * by + x];
			x++;
		}
		Data = data;
	}
	*/

	public function setFlat(numTilesAcross:Int, tileSize:Int=256):Void {
		Scale = Math.round( Math.log((tileSize) ) * PMath.LOG2E );
		var vertX:Int = numTilesAcross + 1;
		RowWidth = vertX;
		XSize = vertX;
		ZSize = vertX;
		if (Data == null) {
			Data = NativeInt32ArrayTools.alloc((vertX) * (vertX));
		}
		else {
			flatten();
		}
	}
	
	/*
	public function setFromBmpData(bmpData:BitmapData, heightMult:Float, heightMin:Int=0, tileSize:Int=256):Void 
	{
		if (!isBase2(tileSize)) throw ("Tile size isn't base 2!");
		Scale = Math.round( Math.log(Number(tileSize) ) * Math.LOG2E );
		var bWidth:Int; var bHeight:Int;
		var vertsX:Int = bWidth = bmpData.width;
		var vertsY:Int = bHeight = bmpData.height;
		if ( (vertsX & 1) != 1) {
			//throw new Error("Must be odd number of vertices along x dir!"); 
			vertsX += 1;
		}
		if ( (vertsY & 1) != 1) {
			//throw new Error("Must be odd number of vertices along y dir!"); 
			vertsY += 1;
		}
		
		RowWidth = vertsX;
		XSize = RowWidth;
		ZSize = vertsY;
		
		var data:Vector<Int> =  new Vector<Int>( (vertsX) * (vertsY), true);
		var by:Int = vertsY;
		var bx:Int = vertsX;
		var y:Int = 0;
		while ( y <  by ) {
			var x:Int = 0;
			while ( x < bx) {
				var xer:Int = x < bWidth ? x : bWidth - 1;
				var yer:Int = y < bHeight ? y : bHeight - 1;
				data[y * by  +  x] = heightMin + (bmpData.getPixel(xer, yer) & 0x0000FF) * heightMult;
				x++;
			}
			y++;
		}
		Data = data;
	}
	*/
	
	/*
	public static function createFromMesh(mesh:Mesh, heightScale:Number=1, heightOffset:Number=0):HeightMapInfo {
		var result:HeightMapInfo = new HeightMapInfo();
		result.setFromMesh(mesh, heightScale, heightOffset);
		return result;
	}
	*/
	
	/*
	public static function createFromBmpData(bmpData:BitmapData, x:Int = 0, y:Int=0, heightMult:Float=16, heightMin:Float=0, tileSize:Int=256):HeightMapInfo {
		var result:HeightMapInfo = new HeightMapInfo();
		result.XOrigin = x;
		result.ZOrigin = y;
		result.setFromBmpData(bmpData, heightMult, heightMin, tileSize);
		return result;
	}
	
	
	static public function createFromByteArray(bytes:ByteArray, patchesAcross:Int, x:Int = 0, y:Int=0, heightMult:Float=16, heightMin:Float=0, tileSize:Int=256):HeightMapInfo {
		var result:HeightMapInfo = new HeightMapInfo();
		result.XOrigin = x;
		result.ZOrigin = y;
		result.setFromByteArray(bytes, heightMult, patchesAcross, heightMin, tileSize);
		return result;
	}
	*/
	
	/* INTERFACE flash.utils.IExternalizable */
	
	/*
	public function readExternal(byte:IDataInput):Void 
	{
		XOrigin = byte.readInt();
		ZOrigin = byte.readInt();
		XSize = byte.readInt();
		ZSize = byte.readInt();
		RowWidth = byte.readInt();
		Scale = byte.readInt();
		
		Data = new Vector<Int>(byte.readUnsignedInt(), true);
		var len:UInt = Data.length;
		var i:UInt = 0;
		while ( i <  len) {
			Data[i] = byte.readInt();
			i++;
		}
	}
	
	public function writeExternal(byte:IDataOutput):Void 
	{
		byte.writeInt(XOrigin);
		byte.writeInt(ZOrigin);
		byte.writeInt(XSize);
		byte.writeInt(ZSize);
		byte.writeInt(RowWidth);
		byte.writeInt(Scale);
		
		//byte.writeObject(Data);
		var len:UInt = Data.length;
		byte.writeUnsignedInt(Data.length);
		
		var i:UInt = 0;
		while (i < len) {
			byte.writeInt(Data[i]);
			i++;
		}
	}
	*/
	
	
	public function reset():Void 
	{
		Data = NativeInt32ArrayTools.alloc(RowWidth * RowWidth); // new Vector<Int>(RowWidth * RowWidth, true);
	}
	
	public function paddEdgeDataValues():Void 
	{
		var x:Int; var y:Int;
		
		var cap:Int;
		
		x = XSize -1;
		cap = ZSize - 1;
		var y:Int = 0;
		while (y < cap) {
			Data[y * RowWidth + x] = Data[y*RowWidth + x - 1];
			y++;
		}
		
		y = ZSize - 1;
		cap = XSize - 1;
		x = 0;
		while ( x < cap) {
			Data[y * RowWidth + x] = Data[(y-1)*RowWidth + x ];
			x++;
		}
		
		x = XSize -1;
		y = ZSize -1;
		Data[y * RowWidth + x] = Data[(y-1)*RowWidth + x - 1 ];
	}
	
}




