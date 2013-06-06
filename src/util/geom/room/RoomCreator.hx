package util.geom.room;
import flash.geom.Rectangle;
import flash.Vector;
import util.geom.Geometry;
import util.geom.Vec3;

/**
 * ...
 * @author Glenn Ko
 */
class RoomCreator
{

	public static inline var NORTH:Int = 0;
	public static inline var WEST:Int = 1;
	public static inline var SOUTH:Int = 2;
	public static inline var EAST:Int = 3;
	public static inline var UPWARDS:Int = 4;
	public static inline var DOWNWARDS:Int = 5;
	
	// constants do NOT change! Indicates indices for cardinal direction-facing walls.
	public var INDICES_WEST:Vector<Int>;
	public var INDICES_NORTH:Vector<Int>;
	public var INDICES_SOUTH:Vector<Int>;
	public var INDICES_EAST:Vector<Int>;
	public var INDICES_DOWNWARDS:Vector<Int>;
	public var INDICES_UPWARDS:Vector<Int>;
	public var INDICES_LOOKUP:Vector<Vector<Int>>;
	public static var UP:Vec3 = new Vec3(0, 0, 1);
	
	public static var DIRECTIONS:Array<Vec3> = [ 
		new Vec3(0, -1, 0),
		new Vec3(-1, 0, 0),
		new Vec3(0, 1, 0),
		new Vec3(1, 0,0)
	];
	
	
	public function new() 
	{
		var indices:Vector<Vector<Int>> = new Vector<Vector<Int>>();
			#if (cpp||php)
					for (i in 0...6)) {
						indices[i] = 0;
					}
				#else
					untyped indices.length = 6;
				#end
		indices[EAST] = INDICES_EAST;
		indices[SOUTH] = INDICES_SOUTH;
		indices[NORTH] = INDICES_NORTH;
		indices[WEST] = INDICES_WEST;
		indices[DOWNWARDS] = INDICES_DOWNWARDS;
		indices[UPWARDS] = INDICES_UPWARDS;
		INDICES_LOOKUP = indices;
		
		INDICES_WEST = _setup([5,1,2,6]);
		INDICES_NORTH =_setup([6,2,3,7]);
		INDICES_SOUTH = _setup([4,0,1,5]);
		INDICES_EAST =_setup([7,3,0,4]);
		INDICES_DOWNWARDS =_setup([4,5,6,7]);
		INDICES_UPWARDS =_setup([0, 3, 2, 1]);
	}
	
	private inline function _setup(arr:Array<Int>):Vector<Int> {
		var vec:Vector<Int> = new Vector<Int>();
		#if (cpp||php)
					for (i in 0...4)) {
						vec[i] = 0;
					}
				#else
					untyped vec.length = 4;
				#end
			
				
				
				
		for (i in 0...4) {
			vec[i] = arr[i];
		}
		
		return vec;
		
	}
	
	
	public function setupRoom(geom:Geometry, rect:Rectangle, gridSize:Float, height:Float, groundPos:Float = 0):Void {
		_setupVertices(geom, rect, gridSize, height, groundPos);
		_addWallFace(geom, NORTH);
		_addWallFace(geom, SOUTH);
		_addWallFace(geom, WEST);
		_addWallFace(geom, EAST);
		_addWallFace(geom, UPWARDS);
		_addWallFace(geom, DOWNWARDS);
	}
	
	
		private inline function _setupVertices(geom:Geometry, rect:Rectangle, gridSize:Float, height:Float, groundPos:Float = 0):Void {  
		
		
		
		
		
		var i:Int;
		
		var boundVerts:Vector<Float> = new Vector<Float>();
			#if (cpp||php)
					for (i in 0...(8 * 3)) {
						boundVerts[i] = 0;
					}
				#else
					untyped boundVerts.length = 8;
				#end
	
		
		
	
		// create 8 corner points of sector  using east and south vectors with rect, calculate bounds accordignly (<- stupid method, doh..)
		var east =  DIRECTIONS[EAST];
		var south =  DIRECTIONS[SOUTH];
		var up =  UP;
		var x:Float;
		var y:Float;
		var z:Float;
		

		var a:Float;
		var b:Float;
		var c:Float;
		
		
		// start bottom 4
		
		x = gridSize * rect.x;
		y = gridSize * rect.y;
		z = groundPos;
		//
		a = east.x * x;
		b= east.y * x;
		c = east.z * x;
		a += south.x * y;
		b += south.y * y;
		c += south.z * y;
		a += up.x * z;
		b += up.y *z;
		c += up.z * z;
		//AABBUtils.expand(a, b, c, this);
		i = 0*3;
		boundVerts[i++] = a;
		boundVerts[i++] = b;
		boundVerts[i] = c;
		
		
		x = gridSize * (rect.x + rect.width);
		y = gridSize * rect.y;
		z = groundPos;
		//
		a = east.x * x;
		b= east.y * x;
		c = east.z * x;
		a += south.x * y;
		b += south.y * y;
		c += south.z * y;
		a += up.x * z;
		b += up.y *z;
		c += up.z * z;
	//	AABBUtils.expand(a, b, c, this);   // COMMENTED AWAY
		i = 1*3;
		boundVerts[i++] = a;
		boundVerts[i++] = b;
		boundVerts[i] = c;
		
		
		x = gridSize * (rect.x + rect.width);
		y = gridSize * (rect.y + rect.height);
		z = groundPos;
		// 
		a = east.x * x;
		b= east.y * x;
		c = east.z * x;
		a += south.x * y;
		b += south.y * y;
		c += south.z * y;
		a += up.x * z;
		b += up.y *z;
		c += up.z * z;
		//AABBUtils.expand(a, b, c, this);
		i = 2*3;
		boundVerts[i++] = a;
		boundVerts[i++] = b;
		boundVerts[i] = c;
		
		x = gridSize * rect.x;
		y = gridSize * (rect.y + rect.height);
		z = groundPos;
		//
		a = east.x * x;
		b= east.y * x;
		c = east.z * x;
		a += south.x * y;
		b += south.y * y;
		c += south.z * y;
		a += up.x * z;
		b += up.y *z;
		c += up.z * z;
		//AABBUtils.expand(a, b, c, this); // COMMENTED AWAY
		i = 3*3;
		boundVerts[i++] = a;
		boundVerts[i++] = b;
		boundVerts[i] = c;
		
		
		// End bottom 4
		
		// now top 4
		
		x = gridSize * rect.x;
		y = gridSize * rect.y;
		z = groundPos + height;
		//
		a = east.x * x;
		b= east.y * x;
		c = east.z * x;
		a += south.x * y;
		b += south.y * y;
		c += south.z * y;
		a += up.x * z;
		b += up.y *z;
		c += up.z * z;
		//AABBUtils.expand(a, b, c, this);
		i = 4*3;
		boundVerts[i++] = a;
		boundVerts[i++] = b;
		boundVerts[i] = c;
		
		x = gridSize * (rect.x + rect.width);
		y = gridSize * rect.y;
		z = groundPos + height;
		//
		a = east.x * x;
		b= east.y * x;
		c = east.z * x;
		a += south.x * y;
		b += south.y * y;
		c += south.z * y;
		a += up.x * z;
		b += up.y *z;
		c += up.z * z;
		//AABBUtils.expand(a, b, c, this); // COMMENTED AWAY
		i = 5*3;
		boundVerts[i++] = a;
		boundVerts[i++] = b;
		boundVerts[i] = c;
		
		
		x = gridSize * (rect.x + rect.width);
		y = gridSize * (rect.y + rect.height);
		z = groundPos + height;
		// 
		a = east.x * x;
		b= east.y * x;
		c = east.z * x;
		a += south.x * y;
		b += south.y * y;
		c += south.z * y;
		a += up.x * z;
		b += up.y *z;
		c += up.z * z;
		//AABBUtils.expand(a, b, c, this);
		i = 6*3;
		boundVerts[i++] = a;
		boundVerts[i++] = b;
		boundVerts[i] = c;
		
		x = gridSize * rect.x;
		y = gridSize * (rect.y + rect.height);
		z = groundPos + height;
		//
		a = east.x * x;
		b= east.y * x;
		c = east.z * x;
		a += south.x * y;
		b += south.y * y;
		c += south.z * y;
		a += up.x * z;
		b += up.y *z;
		c += up.z * z;
		//AABBUtils.expand(a, b, c, this); // COMMENTED AWAY
		i = 7*3;
		boundVerts[i++] = a;
		boundVerts[i++] = b;
		boundVerts[i] = c;
		
		geom.pushVertices(boundVerts);
		
	}
	
	
	
	private inline function _addWallFace(geom:Geometry, direction:Int):Void {
		geom.addFace( INDICES_LOOKUP[direction] );
	}
	
	
	
}