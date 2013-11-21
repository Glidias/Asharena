package hashds.ds.alchemy;
import flash.display.BitmapData;
import flash.geom.Rectangle;
import flash.Memory;
import flash.utils.ByteArray;
import flash.Vector;

/**
 * ...
 * @author Glenn Ko
 */
class AlchemyUtil
{

	public function new() 
	{
		RECT = new Rectangle();
	}
	
	private var RECT:Rectangle;
	
	public static function memSelect(byteArray:ByteArray):Void {
		Memory.select(byteArray);
	}
	
	public function setupGrayscaleBitmap(addr:Int, data:BitmapData, vec:Vector<UInt>):Void {
		var count:Int = 0;
		var limit:Int = data.width * data.height;
		while ( count < limit) {
			vec[count] = Memory.getByte(addr);
			count++;
			addr++;
		}
		
		RECT.width = data.width;
		RECT.height = data.height;
		RECT.x = 0;
		RECT.y = 0;
		data.setVector(RECT, vec);
	}
	
	public function setupShortHeights(addr:Int, result:Vector<UInt>, limit:Int):Void {
		var count:Int = 0;
		while ( count < limit) {
			result[count] = Memory.getUI16(addr);
			count++;
			addr += 2;
		}
	}
	
	public function setupIntHeights(addr:Int, result:Vector<UInt>, limit:Int):Void {
		var count:Int = 0;
		while ( count < limit) {
			result[count] = Memory.getI32(addr);
			count++;
			addr += 2;
		}
	}
	
	public function setupColorBitmap(addr:Int, data:BitmapData, vec:Vector<UInt>):Void {
		var count:Int = 0;

		var limit:Int = data.width * data.height;
		while ( count < limit) {
			var color:UInt = 0xFF000000;
			color |= (Memory.getByte(addr) << 16); addr++;
			color |= (Memory.getByte(addr) << 8);  addr++;
			color |= Memory.getByte(addr);  addr++;
			vec[count] = color;
			count++;
		}
		

		RECT.x = 0;
		RECT.y = 0;
		data.setVector(RECT, vec);
	}
	
	public function setupFullColorBitmap(addr:Int, data:BitmapData, vec:Vector<UInt>):Void {
		var count:Int = 0;
		var limit:Int = data.width * data.height;
		while ( count < limit) {
			vec[count] = Memory.getI32(addr);
			count++;
			addr += 4;
		}
		
		RECT.width = data.width;
		RECT.height = data.height;
		RECT.x = 0;
		RECT.y = 0;
		data.setVector(RECT, vec);
	}
	
	
	
}