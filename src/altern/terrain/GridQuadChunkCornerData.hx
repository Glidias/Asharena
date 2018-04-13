package altern.terrain;
import util.TypeDefs;

/**
 * ...
 * @author Glidias
 */
class GridQuadChunkCornerData 
{

	public var vec:Vector<QuadChunkCornerData>;
	public var cols:Int;

	public var originX:Int = 0;
	public var originY:Int = 0;
	
	public function new() 
	{
		
	}
	
	/**
	 * Gets root chunk corner data at specific coordinates
	 * @param	x	World coordinates
	 * @param	y	World coordinates
	 * @param	level	Indicates the level which is the world size of a root chunk
	 * @return	A root QuadChunkCornerData.
	 */
	public inline function getCornerData(x:Int, y:Int, level:Int):QuadChunkCornerData {
		level++;
		//if (x - originX < 0) throw new Error("WRONGx"+originX +", "+x);
		//if (y - originY < 0) throw new Error("WRONGy"+originY +", "+y);
		return vec[ ((y-originY) >> (level))*cols + ((x-originX)>>(level)) ]; 
	}
	
		
}