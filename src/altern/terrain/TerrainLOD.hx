package altern.terrain;
import de.polygonal.ds.NativeInt32Array;
import de.polygonal.ds.tools.NativeInt32ArrayTools;
import util.TypeDefs;
import util.geom.PMath;

/**
 * Striped down class to manage LOD of quadtree displaying in general fashion (3d engine agnostic with hooks for 3d engine to overwrite)
 * @author Glidias
 */
class TerrainLOD implements ICuller
{
	public static inline var PATCHES_ACROSS:Int = 32;  // todo: we fix this for now, later we allow for customising this
	public static inline var NUM_VERTICES:Int = (PATCHES_ACROSS+1)*(PATCHES_ACROSS+1); 
	public static inline var PATCHES_SHIFT:Int = 5;
		
	// Requirement flags
	//public static const VERTEX_NORMALS:int = 1;
	//public static const VERTEX_TANGENTS:int = 2
	private static inline var VERTEX_INCLUDE_UVS:Int = 4;
	
	//VERTEX_NO_XY;    
	//VERTEX_PREV_Z;
	
	//public var requireEdgeMask:int = VERTEX_NORMALS | VERTEX_TANGENTS;
	
	public static inline var UV_STEPWISE:Int = 0;
	public static inline var UV_NORMALIZED:Int = -1;
	
	
	//public static var PROTO_32:GeometryResult;
	
	// pooled chunk state buffers
	private var chunkPool:TerrainChunkStateList = new TerrainChunkStateList();  // BENCHMARK: changed to non/static. 
	private var activeChunks:TerrainChunkStateList = new TerrainChunkStateList();
	private var drawnChunks:Int = 0;
	private var lastDrawnChunks:Int = 0;
	public var newly_instantiated:Int = 0;
	public var pool_retrieved:Int = 0;
	public var cached_retrieved:Int = 0;
	
	// lookup buffers
	//private var tilingUVBuffers:Vector.<VertexBuffer3D>;
	//alternativa3d static var indexBuffers:Vector.<IndexBuffer3D>;
	
	//private var _uvAttribOffset:Int = 0;
	//private var _defaultUVStream:VertexStream = null;  
	
	
	private var _cameraPos:Vector3D = new Vector3D();
	private var _lastUpdateCameraPos:Vector3D = new Vector3D();
	private static var numTrianglesLookup:NativeInt32Array;
	private static var indexSideLookup:NativeInt32Array = NativeInt32ArrayTools.alloc(16);// l new Vector<Int>(16, true);
	private var cornerMask:NativeInt32Array;
	
	private var tileSize:Int;
		
		/*
		public var debug:Boolean = false;
		private var _debugStream:VertexStream;
		private var _lastDebugRun:Boolean = false;
	*/
		
		//private var _frustum:CullingPlane;
		
		// used for drawing
		/*
		private var mySurface:Surface = new Surface();  
		private var myGeometry:Geometry = new Geometry();
		private var myLODMaterial:ILODTerrainMaterial = null;
		*/
		
		
		private var _currentPage:QuadTreePage;
		
		/*
		private var _vertexUpload:Vector.<Number>;  // alchemy version could use a multipurpose ByteArray for uploading and other calculations...
		private var _data32PerVertex:int;
		private var _debugMaterial:CheckboardFillMaterial = new CheckboardFillMaterial();
		*/
		
		
		// METHOD 1  
		// A grid of quad tree pages to render
		public var gridPagesVector:Vector<QuadTreePage>;  // dense array method 
		//private var _pagesAcross:int;
		
		
		// needed this? Not too sure
		//private var _vOffsets:Vector<Int>;
		//private var _vDistances:Vector<Int>;
		
		private var culler:ICuller;
		public static inline var CULL_NONE:Int = 0;
		public static inline var CULL_WATER:Int = 1;
		public static inline var CULL_FULL:Int = 2;
		public inline function setupUpdateCullingMode(mode:Int):Void {
			culler = mode == CULL_NONE ? new NoCulling() : mode == CULL_WATER ?  new WaterClipCulling(this) : this;
		}
		
		
		public var waterLevel:Float = PMath.FLOAT_MIN; //-Number.MAX_VALUE;
		
		private var _squaredDistUpdate:Float = 0;
		
		public function setUpdateRadius(val:Float):Void {
			var a:Float = Math.sin(Math.PI * .125) * val;
			var b:Float = Math.cos(Math.PI * .125) * val;
			_squaredDistUpdate = a * a + b * b;
		}
		
		public static inline var NORTH_EAST:Int = 0;
		public static inline var NORTH_WEST:Int = 1;
		public static inline var SOUTH_WEST:Int = 2;
		public static inline var SOUTH_EAST:Int = 3;
		
		public static inline var MASK_EAST:Int = 1;
		public static inline var MASK_NORTH:Int = 2;
		public static inline var MASK_WEST:Int = 4;
		public static inline var MASK_SOUTH:Int = 8;
		
		private var _patchHeights:NativeInt32Array = NativeInt32ArrayTools.alloc(4*3);
		private static var TRI_ORDER_TRUE:NativeInt32Array =  createTriOrderIndiceTable(true); // forward slash diagonal tri-patch
		private static var TRI_ORDER_FALSE:NativeInt32Array =  createTriOrderIndiceTable(false); // back slash diagonal tri-patch
		
		private static var DIAG_NORM_ORDER_TRUE:Vector3D =  new Vector3D(-0.70710678118654752440084436210485,0.70710678118654752440084436210485,0); // forward slash tri-patch diagonal normal (left up)
		private static var DIAG_NORM_ORDER_FALSE:Vector3D =  new Vector3D(0.70710678118654752440084436210485,0.70710678118654752440084436210485,0); // back slash tri-patch diagonal normal (right up)
		
		private static function createTriOrderIndiceTable(positive:Bool):NativeInt32Array {  
			var indices:NativeInt32Array = NativeInt32ArrayTools.alloc(6);
		
			if (positive) {
				//nw | se =  00 or 11   !=
				indices[0] = 0; indices[1] = 2; indices[2] = 1;
				indices[3] = 2; indices[4] = 3; indices[5] = 1;
			}
			else {
				// ne | sw - 01 or 10   ==
				indices[0] = 0; indices[1] = 3; indices[2] = 1;
				indices[3] = 0; indices[4] = 2; indices[5] = 3;
			}
			return indices;
		}
		
	
	public function new() 
	{
		culler = this;
			
		_patchHeights[0] = 0;  // nw
		_patchHeights[1] = 0;
		_patchHeights[3] = 1;  // ne
		_patchHeights[4] = 0;
		_patchHeights[6] = 0;  // sw
		_patchHeights[7] = 1;
		_patchHeights[9] = 1;  // se
		_patchHeights[10] = 1;
		
		_lastUpdateCameraPos.x = -1e22;
		_lastUpdateCameraPos.y = -1e22;
		_lastUpdateCameraPos.z = -1e22;
		
		//mySurface.object = this;
		//mySurface.indexBegin = 0;
		cornerMask = NativeInt32ArrayTools.alloc(4);
		cornerMask[0] = ~(MASK_NORTH | MASK_EAST) & 0xF;
		cornerMask[1] = ~(MASK_NORTH | MASK_WEST) & 0xF;
		cornerMask[2] = ~(MASK_SOUTH | MASK_WEST) & 0xF;
		cornerMask[3] = ~(MASK_SOUTH | MASK_EAST) & 0xF;
		//mySurface.numTriangles = PATCHES_ACROSS * 2;
	}
	
	
	/* INTERFACE altern.terrain.ICuller */
	
	public function cullingInFrustum(culling:Int, boundMinX:Float, boundMinY:Float, boundMinZ:Float, boundMaxX:Float, boundMaxY:Float, boundMaxZ:Float):Int 
	{
		/*
		if (maxY < waterLevel) return -1;		
				

			var frustum:CullingPlane = _frustum;
			
			//var temp:Number = minY;
			//minY = -maxY;
			//maxY = -temp;
		
			
			var side:int = 1;
			for (var plane:CullingPlane = frustum; plane != null; plane = plane.next) {
			if (culling & side) {
			if (plane.x >= 0)
			if (plane.y >= 0)
			if (plane.z >= 0) {
			if (maxX*plane.x + maxY*plane.y + maxZ*plane.z <= plane.offset) return -1;
			if (minX*plane.x + minY*plane.y + minZ*plane.z > plane.offset) culling &= (63 & ~side);
			} else {
			if (maxX*plane.x + maxY*plane.y + minZ*plane.z <= plane.offset) return -1;
			if (minX*plane.x + minY*plane.y + maxZ*plane.z > plane.offset) culling &= (63 & ~side);
			}
			else
			if (plane.z >= 0) {
			if (maxX*plane.x + minY*plane.y + maxZ*plane.z <= plane.offset) return -1;
			if (minX*plane.x + maxY*plane.y + minZ*plane.z > plane.offset) culling &= (63 & ~side);
			} else {
			if (maxX*plane.x + minY*plane.y + minZ*plane.z <= plane.offset) return -1;
			if (minX*plane.x + maxY*plane.y + maxZ*plane.z > plane.offset) culling &= (63 & ~side);
			}
			else if (plane.y >= 0)
			if (plane.z >= 0) {
			if (minX*plane.x + maxY*plane.y + maxZ*plane.z <= plane.offset) return -1;
			if (maxX*plane.x + minY*plane.y + minZ*plane.z > plane.offset) culling &= (63 & ~side);
			} else {
			if (minX*plane.x + maxY*plane.y + minZ*plane.z <= plane.offset) return -1;
			if (maxX*plane.x + minY*plane.y + maxZ*plane.z > plane.offset) culling &= (63 & ~side);
			}
			else if (plane.z >= 0) {
			if (minX*plane.x + minY*plane.y + maxZ*plane.z <= plane.offset) return -1;
			if (maxX*plane.x + maxY*plane.y + minZ*plane.z > plane.offset) culling &= (63 & ~side);
			} else {
			if (minX*plane.x + minY*plane.y + minZ*plane.z <= plane.offset) return -1;
			if (maxX*plane.x + maxY*plane.y + maxZ*plane.z > plane.offset) culling &= (63 & ~side);
			}
			}
			side <<= 1;
			}
			return culling;
			
			*/
			
			return 0;
	}
	
}



class NoCulling implements ICuller {
	public function new() {
		
	}
	
		public function cullingInFrustum(culling:Int, minX:Float, minY:Float, minZ:Float, maxX:Float, maxY:Float, maxZ:Float):Int 
		{
			return 0;
		
		}
}


class WaterClipCulling implements ICuller {
	private var terrainLOD:TerrainLOD;
	
	public function new(terrainLOD:TerrainLOD) {
		this.terrainLOD = terrainLOD;
		
	}
	public function cullingInFrustum(culling:Int, minX:Float, minY:Float, minZ:Float, maxX:Float, maxY:Float, maxZ:Float):Int 
		{
			return -1;
		
		}
		

}