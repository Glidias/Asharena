package altern.terrain;

import util.TypeDefs;
import util.geom.PMath;

/**
 * ...
 * @author Glidias
 */
class QuadCornerData
{

	public var Parent:QuadCornerData;
	public var Square:QuadSquare; //	Square;
	public var ChildIndex:Int;
	public var Level:Int;
	
	public var xorg:Int;
	public var zorg:Int;
	
	public var Verts:Vector<Int> = TypeDefs.createIntVector(4, true);	//se,sw,nw,ne
	// ne, nw, sw, se [4]
	
	//public var vertexList:Vector.<Vertex>;

	public static var BUFFER:Vector<QuadCornerData> = new Vector<QuadCornerData>();
	public static var BI:Int = 0;
	public static var BLEN:Int = 0;
	
	public function new() {
		
	}

	public static function create():QuadCornerData {
		//return new QuadCornerData();
		var result:QuadCornerData;
		if (BI < BLEN) {
			result = BUFFER[BI];
		}
		else {
			result = new QuadCornerData();
			BUFFER[BLEN++] = result ;
		}

		
		BI++;
		return result;
	}
	
	public static function setFixedBufferSize(size:Int):Void {
		//return;
		TypeDefs.setVectorLen(BUFFER, size, 1);
	}
	
	public static function fillBuffer():Void {
		var len:Int = BLEN;
		var result:Vector<QuadCornerData> = BUFFER;
		var i:Int = 0;
		while (i < 0) {
			result[i] = new QuadCornerData();
			i++;
		}
	}

	
	public function clone():QuadCornerData {
	//	return this;
		var result:QuadCornerData = new QuadCornerData();
		result.Parent = Parent;
		result.Square = Square;
		result.xorg = xorg;
		result.zorg = zorg;
		result.Level = Level;
		result.ChildIndex = ChildIndex;
		result.Verts[0] = Verts[0];
		result.Verts[1] = Verts[1];
		result.Verts[2] = Verts[2];
		result.Verts[3] = Verts[3];
		return result;
	}
	

	public static function createRoot(x:Int, y:Int, size:Int):QuadCornerData {  //, neighborTilable:Bool=false
		var quadRoot:QuadCornerData =new QuadCornerData();  // neighborTilable ? new QuadCornerDataNeighbor() : 
		quadRoot.xorg = x;
		quadRoot.zorg = y;
		if (!isBase2(size)) throw ("Size isn't base 2!" + size);
		size >>= 1;
		quadRoot.Level = Math.round( Math.log(size) * PMath.LOG2E);
		
		var sq:QuadSquare = new QuadSquare(quadRoot);

		return quadRoot;
	}
	
	public static function clearBuffer():Void {
		
		
		var len:Int = BUFFER.length;
		var i:Int = 0;
		while (i < len) {
			BUFFER[i].dispose();
			i++;
		}
		
	
		TypeDefs.setVectorLen(BUFFER, 0);
		BI = 0;
		BLEN = 0;
	}
	
	public function dispose():Void {
		Parent = null;
		Square = null;
		Verts  = null;	
	}
	
	/*
	public static function log2(input:Float):Float {
		if(input<=0){
			return Math.NaN;
		}else if((input&(input-1))==0){
			var a:Int=0;
			while(input>1){input>>=1; ++a;}
			return a;
		}else{
			return Math.round( Math.log(input) * PMath.LOG2E);
		}
	}

			
	
	*/

	public static inline function isBase2(val:Int):Bool {
		return Math.pow(2, Math.round( Math.log(val) * PMath.LOG2E) ) == val;
	}
}