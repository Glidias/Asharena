package altern.terrain;
import hxbit.Serializable;

/**
 * ...
 * @author Glidias
 */
class QuadTreePage  extends QuadChunkCornerData
{
	//public var material:Material;
	
	@:s public var requirements:Int;
	@:s public var heightMap:HeightMapInfo;  // highest detail heights
	
	//alternativa3d var _uvTileShift:int = 0;
	public var uvTileSize:Int = 0;
	//public var normals:NormMapInfo;   // todo: depeciate!
	
	

		
	function new() 
	{
		super();
	}
	
	/*	// yagni?
	public function clonePage():QuadTreePage {
		var me:QuadTreePage = new QuadTreePage();
		me.clonePropertiesFrom(this);
		return me;
	}
		
	 public function clonePropertiesFrom(ref:QuadTreePage):Void {		
		//material = ref.material;
		requirements = ref.requirements;
		heightMap = ref.heightMap.clone();
		uvTileSize = ref.uvTileSize;
		Parent = ref.Parent;
		Square = ref.Square.clone();
		if (Parent!=null) Parent.Square = Square;
		xorg = ref.xorg;
		zorg = ref.zorg;
		Level = ref.Level;
		ChildIndex = ref.ChildIndex;
		
	}
	*/
	
	static inline var LOG2E:Float = 1.4426950408889634;
	
	public static function isBase2(val:Int):Bool {
		return Math.pow(2, Math.round( Math.log(val) * LOG2E) ) == val;
	}
		
	public static function create(x:Int, y:Int, size:Int):QuadTreePage {
		var quadRoot:QuadTreePage = new QuadTreePage();
		quadRoot.xorg = x;
		quadRoot.zorg = y;
		if (!isBase2(size)) throw("Size isn't base 2!" + size);
		size >>= 1;
		quadRoot.Level = Math.round( Math.log(size) * LOG2E );
		return quadRoot;
	}
	
	/*
	public static function createFlat(x:int, y:int, numTiles:Int, tileSize:Int = 256):QuadTreePage {
		
		var heightMap:HeightMapInfo = HeightMapInfo.createFlat(numTiles, tileSize);
		var root:QuadTreePage = TerrainLOD.installQuadTreePageFromHeightMap(heightMap, x, y, tileSize, 0);

		return root;
	}
	*/
	
	
}