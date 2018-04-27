package altern.terrain;
import hxbit.Serializable;
import util.TypeDefs;

/**
 * ...
 * @author Glidias
 */
class QuadChunkCornerData implements Serializable
{

	function new() 
	{
		
	}
	
	public var Parent:QuadChunkCornerData;
	@:s public var Square:QuadSquareChunk; //	Square;
	public	var ChildIndex:Int;
	@:s public var	Level:Int;
	
	@:s public	var xorg:Int;
	@:s public var zorg:Int;

	public static var BUFFER:Array<QuadChunkCornerData> = new Array<QuadChunkCornerData>();
	public static var BI:Int = 0;
	public static var BLEN:Int = 0;
	
	
	public static function create():QuadChunkCornerData {
		//return new QuadChunkCornerData();
		var result:QuadChunkCornerData;
		if (BI < BLEN) {
			result = BUFFER[BI];
		}
		else {
			result = new QuadChunkCornerData();
			BUFFER[BLEN++] = result ;
		}

		
		BI++;
		return result;
	}
	
	public static function setFixedBufferSize(size:Int):Void {
		//return;
		TypeDefs.setVectorLen(BUFFER, size, 1);
		BLEN = size;
	}
	
	public static function fillBuffer():Void {
		var len:Int = BLEN;
		var result:Vector<QuadChunkCornerData> = BUFFER;
		var i:Int = 0;
		while ( i < len) {
			result[i] = new QuadChunkCornerData();
			i++;
		}
	}

	/*	//yagni?
	public function clone():QuadChunkCornerData {
	//	return this;
		var result:QuadChunkCornerData = new QuadChunkCornerData();
		result.Parent = Parent;
		result.Square = Square.clone();
		if (result.Parent!=null) result.Parent.Square = result.Square;
		result.xorg = xorg;
		result.zorg = zorg;
		result.Level = Level;
		result.ChildIndex = ChildIndex;
		return result;
	}
	*/
}