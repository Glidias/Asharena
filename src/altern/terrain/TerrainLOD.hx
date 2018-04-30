package altern.terrain;
import altern.ray.IRaycastImpl;
import altern.terrain.QuadChunkCornerData;
import altern.terrain.QuadSquareChunk;
import de.polygonal.ds.NativeFloat32Array;
import de.polygonal.ds.NativeInt32Array;
import de.polygonal.ds.tools.NativeInt32ArrayTools;
import util.TypeDefs;
import util.geom.PMath;
import util.geom.Vec3;

/**
 * Striped down class to manage LOD of quadtree displaying in general fashion (3d engine agnostic with hooks for 3d engine to overwrite)
 * @author Glidias
 */
class TerrainLOD implements ICuller implements IRaycastImpl
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
	
	
	public static var PROTO_32:GeometryResult;
	
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
	private static var indexSideLookup:NativeInt32Array; 
	private var cornerMask:NativeInt32Array;
	
	private var tileSize:Int;
	private var tileSizeInv:Float;
	
	
		
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
		
	
		private var _vertexUpload:NativeFloat32Array; 
		private var _data32PerVertex:Int;
		//private var _debugMaterial:CheckboardFillMaterial = new CheckboardFillMaterial();
		
		
		
		// METHOD 1  
		// A grid of quad tree pages to render
		public var gridPagesVector:Vector<QuadTreePage>;  // dense array method 
		//private var _pagesAcross:int;
		
		
		// needed this? Not too sure
		//private var _vOffsets:Vector<Int>;
		//private var _vDistances:Vector<Int>;
		
		// METHOD 3
		public var tree:QuadTreePage;
		
		
		
		public var detail:Float = 5;

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
		
		private var quadOrderTable:Vector<NativeInt32Array>;
		private var _repeatUVLowestLevel:Int;
		private var lodLvlMin:Int = 12;
		private var currentLookupIndex:Int=0;
		private var tileShift:Int;
		private var tileMod:Int;
		
		
		private static var QUAD_ORDER:Vector<NativeInt32Array> = createQuadOrderIndiceTable(false);  // back to front
		private static var QUAD_ORDER2:Vector<NativeInt32Array> = createQuadOrderIndiceTable(true);  // front to back
		private static var QUAD_OFFSETS:NativeInt32Array = createQuadOffsetTable();
		private static function createQuadOrderIndiceTable(reversed:Bool):Vector<NativeInt32Array> {
			// quad z order
			var result:Vector<NativeInt32Array> = TypeDefs.createVector(4, true);
			result[0] = NativeInt32ArrayTools.ofArray(!reversed  ? [3, 2, 0, 1] : [1, 0, 2, 3]);
			result[1] = NativeInt32ArrayTools.ofArray( !reversed ? [2,3,1,0] : [0,1,3,2] );
			result[2] = NativeInt32ArrayTools.ofArray(!reversed ? [0,1,3,2] : [2,3,1,0] );
			result[3] = NativeInt32ArrayTools.ofArray( !reversed ?  [1,2,0,3] : [3,0,2,1] );
			return result;
		}
		private static function createQuadOffsetTable():NativeInt32Array {
			var result:NativeInt32Array = NativeInt32ArrayTools.alloc(4);
			result[0] = 1;
			result[1] = 0;
			result[2] = 2;
			result[3] = 3;
			return result;
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
		cornerMask[0] = ~(TerrainGeomTools.MASK_NORTH | TerrainGeomTools.MASK_EAST) & 0xF;
		cornerMask[1] = ~(TerrainGeomTools.MASK_NORTH | TerrainGeomTools.MASK_WEST) & 0xF;
		cornerMask[2] = ~(TerrainGeomTools.MASK_SOUTH | TerrainGeomTools.MASK_WEST) & 0xF;
		cornerMask[3] = ~(TerrainGeomTools.MASK_SOUTH | TerrainGeomTools.MASK_EAST) & 0xF;
		//mySurface.numTriangles = PATCHES_ACROSS * 2;
	}
	
	function setupIndexReferences( indexLookup:NativeInt32Array, patchesAcross:Int):Void {
		//indexBuffers = new Vector.<IndexBuffer3D>(9, true);
		numTrianglesLookup = NativeInt32ArrayTools.alloc(9); // new Vector.<int>(9, true);
		indexSideLookup = NativeInt32ArrayTools.alloc(16);
		//var buffer:IndexBuffer3D;
		
		var count:Int = 0;
		var indices:Vector<UInt> = new Vector<UInt>();
		//var byteArray:ByteArray = new ByteArray();
		//byteArray.endian = Endian.LITTLE_ENDIAN;
		TerrainGeomTools.writeInnerIndicesToByteArray(patchesAcross, indexLookup, indices);
		var startEdgesPosition:Int = indices.length;
		
		TerrainGeomTools.writeEdgeVerticesToByteArray(patchesAcross, indexLookup, indices, 0);   
		//buffer = context3D.createIndexBuffer( byteArray.length >> 1 );
		//indexBuffers[count] = buffer;
		numTrianglesLookup[count] = Std.int(indices.length / 3);
		setupIndexBuffer(indices, count); //buffer.uploadFromByteArray(byteArray, 0, 0, byteArray.length >> 1); 
		indexSideLookup[0xF] = count;
		count++;
		
		TypeDefs.setVectorLen(indices, startEdgesPosition); //byteArray.position = byteArray.length = startEdgesPosition;
		TerrainGeomTools.writeEdgeVerticesToByteArray(patchesAcross, indexLookup, indices, TerrainGeomTools.MASK_EAST );
		//buffer = context3D.createIndexBuffer( byteArray.length >> 1 );
		//indexBuffers[count] = buffer;
		numTrianglesLookup[count] = Std.int(indices.length / 3);
		setupIndexBuffer(indices, count); //buffer.uploadFromByteArray(byteArray, 0, 0, byteArray.length >> 1);
		indexSideLookup[(~TerrainGeomTools.MASK_EAST) & 0xF] = count;
		count++;
		
		TypeDefs.setVectorLen(indices, startEdgesPosition); //byteArray.position = byteArray.length = startEdgesPosition;
		TerrainGeomTools.writeEdgeVerticesToByteArray(patchesAcross, indexLookup, indices, TerrainGeomTools.MASK_NORTH );
		//buffer = context3D.createIndexBuffer( byteArray.length >> 1 );
		//indexBuffers[count] = buffer;
		numTrianglesLookup[count] = Std.int(indices.length / 3);
		setupIndexBuffer(indices, count); //buffer.uploadFromByteArray(byteArray, 0, 0, byteArray.length >> 1);
		indexSideLookup[(~TerrainGeomTools.MASK_NORTH)&0xF] = count;
		count++;
		
		TypeDefs.setVectorLen(indices, startEdgesPosition); //byteArray.position = byteArray.length = startEdgesPosition;
		TerrainGeomTools.writeEdgeVerticesToByteArray(patchesAcross, indexLookup, indices, TerrainGeomTools.TerrainGeomTools.MASK_WEST );
		//buffer = context3D.createIndexBuffer( byteArray.length >> 1 );
		//indexBuffers[count] = buffer;
		numTrianglesLookup[count] = Std.int(indices.length / 3);
		setupIndexBuffer(indices, count); //buffer.uploadFromByteArray(byteArray, 0, 0, byteArray.length >> 1);
		indexSideLookup[(~TerrainGeomTools.MASK_WEST)&0xF] = count;
		count++;
		
		TypeDefs.setVectorLen(indices, startEdgesPosition); //byteArray.position = byteArray.length = startEdgesPosition;
		TerrainGeomTools.writeEdgeVerticesToByteArray(patchesAcross, indexLookup, indices, TerrainGeomTools.MASK_SOUTH );
		//buffer = context3D.createIndexBuffer( byteArray.length >> 1 );
		//indexBuffers[count] = buffer;
		numTrianglesLookup[count] = Std.int(indices.length / 3);
		setupIndexBuffer(indices, count); //buffer.uploadFromByteArray(byteArray, 0, 0, byteArray.length >> 1);
		indexSideLookup[(~TerrainGeomTools.MASK_SOUTH)&0xF] = count;
		count++;
		
		TypeDefs.setVectorLen(indices, startEdgesPosition); //byteArray.position = byteArray.length = startEdgesPosition;
		TerrainGeomTools.writeEdgeVerticesToByteArray(patchesAcross, indexLookup, indices, TerrainGeomTools.MASK_NORTH | TerrainGeomTools.MASK_EAST );
		//buffer = context3D.createIndexBuffer( byteArray.length >> 1 );
		//indexBuffers[count] = buffer;
		numTrianglesLookup[count] = Std.int(indices.length / 3);
		setupIndexBuffer(indices, count); //buffer.uploadFromByteArray(byteArray, 0, 0, byteArray.length >> 1);
		indexSideLookup[~(TerrainGeomTools.MASK_NORTH | TerrainGeomTools.MASK_EAST)&0xF] = count;
		count++;
		
		TypeDefs.setVectorLen(indices, startEdgesPosition); //byteArray.position = byteArray.length = startEdgesPosition;
		TerrainGeomTools.writeEdgeVerticesToByteArray(patchesAcross, indexLookup, indices, TerrainGeomTools.MASK_NORTH | TerrainGeomTools.TerrainGeomTools.MASK_WEST );
		//buffer = context3D.createIndexBuffer( byteArray.length >> 1 );
		//indexBuffers[count] = buffer;
		numTrianglesLookup[count] = Std.int(indices.length / 3);
		setupIndexBuffer(indices, count); //buffer.uploadFromByteArray(byteArray, 0, 0, byteArray.length >> 1);
		indexSideLookup[~(TerrainGeomTools.MASK_NORTH | TerrainGeomTools.MASK_WEST)&0xF] = count;
		count++;
		
		TypeDefs.setVectorLen(indices, startEdgesPosition); //byteArray.position = byteArray.length = startEdgesPosition;
		TerrainGeomTools.writeEdgeVerticesToByteArray(patchesAcross, indexLookup, indices, TerrainGeomTools.MASK_SOUTH | TerrainGeomTools.TerrainGeomTools.MASK_WEST );
		//buffer = context3D.createIndexBuffer( byteArray.length >> 1 );
		//indexBuffers[count] = buffer;
		numTrianglesLookup[count] = Std.int(indices.length / 3);
		setupIndexBuffer(indices, count); //buffer.uploadFromByteArray(byteArray, 0, 0, byteArray.length >> 1);
		indexSideLookup[ ~(TerrainGeomTools.MASK_SOUTH | TerrainGeomTools.MASK_WEST)&0xF ] = count;
		count++;
		
		TypeDefs.setVectorLen(indices, startEdgesPosition); //byteArray.position = byteArray.length = startEdgesPosition;
		TerrainGeomTools.writeEdgeVerticesToByteArray(patchesAcross, indexLookup, indices, TerrainGeomTools.MASK_SOUTH | TerrainGeomTools.MASK_EAST );
		//buffer = context3D.createIndexBuffer( byteArray.length >> 1 );
		//indexBuffers[count] = buffer;
		numTrianglesLookup[count] = Std.int(indices.length / 3);
		setupIndexBuffer(indices, count); //buffer.uploadFromByteArray(byteArray, 0, 0, byteArray.length >> 1);
		indexSideLookup[ ~(TerrainGeomTools.MASK_SOUTH | TerrainGeomTools.MASK_EAST)&0xF ] = count;
		count++;
	}
	
	function setupPreliminaries(quadCornerChunk:QuadTreePage, requirements:Int, tileSize:Int, uvTileSize:Int):Void 
	{
		if (!QuadCornerData.isBase2(tileSize)) throw("tileSize must be base 2!");
		
		lodLvlMin = Math.round(Math.log(tileSize * PATCHES_ACROSS) * PMath.LOG2E) - 1;

		
			
		if (PROTO_32 == null) PROTO_32 = TerrainGeomTools.createLODTerrainChunkForMesh(PATCHES_ACROSS, tileSize);
		if (indexSideLookup == null) setupIndexReferences(PROTO_32.indexLookup, PATCHES_ACROSS);
		
		
		

		this.tileSize = tileSize;
		this.tileSizeInv = 1 / tileSize;
		this.tileShift = Math.round(Math.log(tileSize ) * PMath.LOG2E);
		
		this.tileMod = tileSize  - 1;
		
		if ( uvTileSize > 0 && !QuadCornerData.isBase2(uvTileSize)) throw ("uvTileSize must be base 2!");
		
	}
		
	function setupPostliminaries( requirements:Int, tileSize:Int, uvTileSize:Int, rootLevel:Int):Void {
		var injectUV:Bool=false;
		var repeatUV:Bool = false;
		if (uvTileSize > 0) {  // Got UVs
			
			
			if (uvTileSize <= tileSize * PATCHES_ACROSS) {  // repeatable texture coordinates per chunk level with same origin can be used
				 repeatUV = true;
				 
			}
			else {   // need to inject uv coordinates
				injectUV = true;
				requirements |= VERTEX_INCLUDE_UVS;
				
				if (tree != null) tree.requirements |= VERTEX_INCLUDE_UVS;
				if (gridPagesVector != null) {
					var i:Int = gridPagesVector.length;
					while (--i > -1) {
						gridPagesVector[i].requirements |= VERTEX_INCLUDE_UVS;
					}
				}
			}
		}
	
		/*  // outside scope...for 3d engine
		setupGeometry(requirements);  
		if (repeatUV) setupRepeatingUVs(context3D, uvTileSize, rootLevel);
		else if (injectUV) {
			setDefaultUVStream(myGeometry._attributesStreams[VertexAttributes.TEXCOORDS[0]], myGeometry._attributesOffsets[VertexAttributes.TEXCOORDS[0]] ); 
		}
		else if (uvTileSize === UV_STEPWISE) {
			setDefaultUVStream(  (_debugStream || (_debugStream = createDebugUVStream(context3D) )) , 0);
			
				_defaultUVStream.attributes = [VertexAttributes.TEXCOORDS[0], VertexAttributes.TEXCOORDS[0]];
		}
		else if (uvTileSize === UV_NORMALIZED) {
			setDefaultUVStream( getNormalizedUVStream(context3D), 0 );
				_defaultUVStream.attributes = [VertexAttributes.TEXCOORDS[0], VertexAttributes.TEXCOORDS[0]];
		}
		*/
		
		setupVertexUpload(requirements, tileSize);
	}
	
	
	function setupVertexUpload(requirements:Int, tileSize:Int):Void 
	{
		
		var len:Int;
		var i:Int;
		var vAcross:Int = PATCHES_ACROSS + 1;
		_vertexUpload = new NativeFloat32Array(  vAcross * vAcross * _data32PerVertex);

	
		/*
		var indexLookup:Vector.<int> = PROTO_32.indexLookup;
		var pos:Int;
		
		//this wouldn't work anyway because we re-uploading x,y later during sampleHeights
		for (var y:int = 0; y < vAcross; y++) {
			for (var x:int = 0; x < vAcross; x++) {
				pos = indexLookup[y * vAcross + x] * stride;
				_vertexUpload[pos] =  x * tileSize;
				_vertexUpload[pos+1] =  -y * tileSize;
			}
		}
		*/
	}
	
	function getNewChunkState():TerrainChunkState {
		
		var state:TerrainChunkState = new TerrainChunkState();
		//state.index = ;
		
		//state.vertexBuffer = context3D.createVertexBuffer(NUM_VERTICES, _data32PerVertex);
	
		return state;
	}
	
	public function loadSinglePage( page:QuadTreePage,  uvTileSize:Int = 0, requirements:Int =-1, tileSize:Int = 256):Void {
		runSinglePage(page.heightMap, page, requirements>=0 ? requirements : page.requirements,  uvTileSize != 0 ? uvTileSize : page.uvTileSize, tileSize);
	}
	
	public function runSinglePage(heightMap:HeightMapInfo, quadCornerChunk:QuadTreePage,  requirements:Int, uvTileSize:Int = 0, tileSize:Int = 256):Void {
		setupPreliminaries(quadCornerChunk, requirements, tileSize, uvTileSize);
			
		var chunk:QuadSquareChunk  = quadCornerChunk.Square;

		var str:String;
		
		tree = new QuadTreePage();
		tree.heightMap = heightMap;
		//tree.material = material;	
		tree.requirements = requirements;
		tree.uvTileSize = uvTileSize != 0 ? uvTileSize  : tree.uvTileSize;
		tree.Square = chunk;
		tree.Level = quadCornerChunk.Level;
		tree.xorg = quadCornerChunk.xorg;
		tree.zorg = quadCornerChunk.zorg;
		

		setupPostliminaries(requirements, tileSize, uvTileSize, tree.Level);
	}
	// to be implemented by 3d engine
	function calculateFrustum(camera:Vec3):Void {
		
	}
	function setupIndexBuffer(indices:Vector<UInt>, id:Int):Void {
		
	}
	function setupVertexChunkState(state:TerrainChunkState, vertices:NativeFloat32Array):Void {
		
	}
	function drawChunkState(state:TerrainChunkState, indexBufferId:Int):Void {
		
	}
	
	
	function sampleHeights(requirements:Int, heightMap:HeightMapInfo, square:QuadChunkCornerData ):Void {
		
		var len:Int;
		var i:Int;
		
		var offset:Int;
		var stride:Int = _data32PerVertex;
		// based on requirements, could access a different vertex upload
		var heightData:NativeInt32Array = heightMap.Data;

		var xorg:Int = square.xorg;
		var zorg:Int =  square.zorg;
		var hXOrigin:Int = heightMap.XOrigin;
		var hZOrigin:Int = heightMap.ZOrigin;
		xorg -= hXOrigin;  // need to check if this is correct
		zorg -= hZOrigin;
		xorg = Std.int(xorg/tileSize);
		zorg = Std.int(zorg/tileSize);
	
		
		var limit:Int = (((1 << square.Level) << 1) >> tileShift);  // numbr of tiles
		
		var vAcross:Int = PATCHES_ACROSS + 1;
		var tStride:Int = (limit >> PATCHES_SHIFT);  // divide by 32
		var yLimit:Int = zorg + limit + 1;
		var xLimit:Int = xorg + limit + 1;
		var RowWidth:Int = heightMap.RowWidth;
		
		var indexLookup:NativeInt32Array = PROTO_32.indexLookup;
		var pos:Int;
		
		// NOTE: If all pages are using the same requirements, it's actually possible to hardcode all these below as an inline operation
		// within a single loop. 
		///*
		var xi:Int;
		var yi:Int;
		var y:Int;
		var x:Int;

		// We assume position offset is always zero and always made available!
		// TODO: consider Only Z case...
		yi = 0;
		y = zorg;
		while ( y < yLimit) {
			xi = 0;
			x = xorg; 
			while (x < xLimit) {
				pos = indexLookup[yi * vAcross + xi] * stride;
				_vertexUpload[pos] = x * tileSize + hXOrigin;
				_vertexUpload[pos + 1] = y * -tileSize - hZOrigin;
				_vertexUpload[pos + 2] = heightData[y * RowWidth + x];
				xi++;
				x += tStride;
			}
			yi++;
			y += tStride;
		}
		
		//var vStream:VertexStream;
	
		var attribId:Int;
		
		var divisor:Float;

		
		
		/*	// TODO: see how to incldue UVs
		if ( (requirements & VERTEX_INCLUDE_UVS) != 0) {  
	
			divisor = 1 / _currentPage.uvTileSize;
			attribId = VertexAttributes.TEXCOORDS[0];
			//vStream =  myGeometry._attributesStreams[attribId];
			offset =  3;// _defaultUVStream._attributesOffsets[attribId];
			
			yi = 0;
			y = zorg;
			while ( y < yLimit) {
				xi = 0;
				x = xorg;
				while ( x < xLimit) {
					pos = indexLookup[yi * vAcross + xi] * stride + offset;
					_vertexUpload[pos] = x * tileSize*divisor;
					_vertexUpload[pos + 1] = y * tileSize*divisor;
					xi++;
					x += tStride;
				}
				yi++;
				y+=tStride
			}
		}
		*/
		
	
		//*/
	}
	
	
	function drawLeaf(cd:QuadChunkCornerData, s:QuadSquareChunk, camera:Vec3):Void
	{
		var state:TerrainChunkState;   
		//if (!debug && tilingUVBuffers != null) myGeometry._attributesStreams[VertexAttributes.TEXCOORDS[0]].buffer = tilingUVBuffers[cd.Level-_repeatUVLowestLevel];
		//if (myLODMaterial != null) myLODMaterial.visit(cd, _currentPage, tileShift, currentLookupIndex);
		
		var id:Int = cd.Parent != null ? indexSideLookup[((cd.Parent.Square.EnabledFlags & 0xF) | cornerMask[cd.ChildIndex])]  : 0;
		state = s.state;   
		if (state == null) { // lazy instantaatiate state ??
			
			pool_retrieved += chunkPool.head != null ? 1 : 0;  // tracking
			newly_instantiated += chunkPool.head != null ? 0 : 1;  // tracking
			state = chunkPool.getAvailable();
			state =  state!= null ? state : getNewChunkState();
			
			 if (state.square != null)  state.square.state = null;  // this means that the square is from pool!
			 state.square = s;
			 s.state = state;
			state.enabledFlags = s.EnabledFlags;
			
			sampleHeights(_currentPage.requirements, _currentPage.heightMap, cd);
			setupVertexChunkState(state, _vertexUpload); //state.vertexBuffer.uploadFromVector(_vertexUpload, 0, NUM_VERTICES);	
		}
		else {
			cached_retrieved += chunkPool.head != null ? 1 : 0; // tracking
			//if (state.parent != chunkPool) throw new Error("SHULD NOT BE!");  
		}
		/*
		else if ( state.enabledFlags != s.EnabledFlags ) {  
			if (_currentPage.requirements & requireEdgeMask) updateEdges(_currentPage.requirements, cd, state.enabledFlags, s.EnabledFlags);
			state.enabledFlags = s.EnabledFlags;
		}
		*/
		
		
		state.enabledFlags = s.EnabledFlags;
		
		//mySurface.numTriangles = numTrianglesLookup[id]; 
		//myGeometry._indexBuffer = indexBuffers[id];
		drawChunkState(state, id);
		
		
		//myGeometry._attributesStreams[1].buffer = s.state.vertexBuffer;  
		//mySurface.material.collectDraws( camera, mySurface, myGeometry, lights, lightsLength, useShadow);

		
		if (state.parent !=null) {
			state.parent.remove(state);  //  state.parent will always be avialble for cached_retrieved case, since pooling mechanism works by always appending 
		}
		activeChunks.append(state);
		
		drawnChunks++;
	}
	
	// basic quad tree recursion for update detail and whether to draw or not
	private function drawQuad(cd:QuadChunkCornerData, camera:Vec3, culling:Int):Void 
	{
		var q:QuadChunkCornerData;
		var s:QuadSquareChunk = cd.Square;
		var c:QuadSquareChunk;
		var index:Int;
		var half:Int;
		var full:Int;
		var cCulling:Int;
		var state:TerrainChunkState;
		var orderedIndices:NativeInt32Array;
	
		
		if ( cd.Level <= lodLvlMin) {  
			// draw single chunk!
			drawLeaf(cd, s, camera);
			return;
		}
		
		if (  (s.EnabledFlags & 0xF)!=0 ) { 
			
			half = (1 << cd.Level);
			full = (half << 1);
			var halfX:Int = cd.xorg + half;
			var halfY:Int = cd.zorg + half;
			index = 0;
			index |= _cameraPos.x < halfX ? 1 : 0; 
			index |= _cameraPos.y < halfY ? 2 : 0; 
			orderedIndices = quadOrderTable[index]; 
			var o:Int;
			
			index = orderedIndices[0];
			o =  QUAD_OFFSETS[index];
			c = s.Child[index];  
			if (s.EnabledFlags & (16 << index)!=0 ) {
				cCulling = culling == 0 ? 0 :  cullingInFrustum(culling, cd.xorg + ((o & 1)!=0 ? half : 0), c.MinY, cd.zorg + ((o & 2)!=0 ? half : 0), cd.xorg + ((o & 1)!=0 ? full : half), c.MaxY, cd.zorg + ((o & 2)!=0 ? full : half));		
				if (cCulling >= 0) {
					q = QuadChunkCornerData.create();  
					s.SetupCornerData(q, cd, index);
					drawQuad(q, camera, cCulling);
				}
			}
			else {
				q = QuadChunkCornerData.create();  
				s.SetupCornerData(q, cd, index);
				drawLeaf(q, c, camera);
			}
			
			index = orderedIndices[1];
			o =  QUAD_OFFSETS[index];
			c = s.Child[index];
			if (s.EnabledFlags & (16 << index)!=0 ) {
				cCulling = culling == 0 ? 0 : cullingInFrustum(culling, cd.xorg + ((o & 1)!=0 ? half : 0), c.MinY, cd.zorg + ((o & 2)!=0 ? half : 0), cd.xorg + ((o & 1)!=0 ? full : half), c.MaxY, cd.zorg + ((o & 2)!=0 ? full : half));		
				if (cCulling >= 0) {
					q = QuadChunkCornerData.create(); 
					s.SetupCornerData(q, cd, index);
					drawQuad(q, camera, cCulling);
				}
			}
			else {
					q = QuadChunkCornerData.create();  
					s.SetupCornerData(q, cd, index);
				drawLeaf(q, c, camera);
			}
			
			index = orderedIndices[2];
			o =  QUAD_OFFSETS[index];
			c = s.Child[index];
			if (s.EnabledFlags & (16 << index)!=0 ) {
				cCulling = culling == 0 ? 0 :  cullingInFrustum(culling, cd.xorg + ((o & 1)!=0 ? half : 0), c.MinY,  cd.zorg + ((o & 2)!=0 ? half : 0), cd.xorg + ((o & 1)!=0 ? full : half), c.MaxY, cd.zorg + ((o & 2)!=0? full : half));		
				if (cCulling >= 0) {
					q = QuadChunkCornerData.create();  
					s.SetupCornerData(q, cd, index);
					drawQuad(q, camera,  cCulling);
				}
			}
			else {
					q = QuadChunkCornerData.create();  
					s.SetupCornerData(q, cd, index);
				drawLeaf(q, c, camera);
			}
			
			index = orderedIndices[3];
			o =  QUAD_OFFSETS[index];
			c = s.Child[index];
			if (s.EnabledFlags & (16 << index)!=0 ) {
				
				cCulling = culling == 0 ? 0 :  cullingInFrustum(culling, cd.xorg + ((o & 1)!=0 ? half : 0), c.MinY, cd.zorg + ((o & 2)!=0 ? half : 0), cd.xorg + ((o & 1)!=0 ? full : half), c.MaxY, cd.zorg + ((o & 2)!=0 ? full : half));		
				if (cCulling >= 0) {
					q = QuadChunkCornerData.create(); 
					s.SetupCornerData(q, cd, index);
					drawQuad(q, camera, cCulling);
				}
			}
			else {
					q = QuadChunkCornerData.create();  
					s.SetupCornerData(q, cd, index);
				drawLeaf(q, c, camera);
			}
		}
		else {
			drawLeaf(cd, s, camera);
		}
	}
	

	
	public function collectDraws(camera:Vec3):Void {
		var c:QuadSquareChunk;
		var full:Int;
		var half:Int;
				
		drawnChunks = 0;
		newly_instantiated = 0 ;
		cached_retrieved = 0;
		pool_retrieved = 0;
	
		var i:Int;
	
		QuadSquareChunk.LOD_LVL_MIN = lodLvlMin;
		
		quadOrderTable = QUAD_ORDER2;
		var tx:Float;
		var ty:Float;
		var tz:Float;
		
		_cameraPos.x = camera.x;
		_cameraPos.y = camera.y;
		_cameraPos.z = camera.z;
		
		tx = _cameraPos.x - _lastUpdateCameraPos.x;
		ty = _cameraPos.y - _lastUpdateCameraPos.y;
		tz = _cameraPos.z - _lastUpdateCameraPos.z;
		
		var doUpdate:Bool = false;
		if (tx * tx + ty * ty + tz * tz > _squaredDistUpdate) {
			_lastUpdateCameraPos.x = _cameraPos.x;
			_lastUpdateCameraPos.y = _cameraPos.y;
			_lastUpdateCameraPos.z = _cameraPos.z;
			doUpdate = true;
		}
		
		calculateFrustum(camera);
		var culling:Int = 0;
		var cd:QuadTreePage;
		
		if (tree != null) {  // Draw tree
			_currentPage = tree;
			cd = tree;
			c = cd.Square;
			half = (1 << cd.Level);
			full = ( half << 1);
			culling = cullingInFrustum(63, cd.xorg, c.MinY, cd.zorg, cd.xorg + full, c.MaxY, cd.zorg + full);
			if (doUpdate) {
				QuadChunkCornerData.BI = 0;
				tree.Square.Update(tree, _cameraPos, detail, culler , culling);  
				QuadChunkCornerData.BI = 0;
			}
			drawQuad(tree, camera, culling);
			QuadChunkCornerData.BI = 0;
		}
		
		if (gridPagesVector != null) {  // draw grid of pages 
			
			cd = gridPagesVector[0];
			half = (1 << cd.Level);
			full = ( half << 1);
			
			///*  // Blindly iterate through all quad tree pages in grid. 
			i = gridPagesVector.length;
		
			while ( --i > -1) {
				
				
				_currentPage = cd = gridPagesVector[i];
				
				c = cd.Square;
				var curCulling:Int;
				if  ( (curCulling=cullingInFrustum(culling, cd.xorg , c.MinY, cd.zorg, cd.xorg + full, c.MaxY, cd.zorg + full )) >=0 ) {
			
					QuadChunkCornerData.BI = 0;
					c.Update(cd, _cameraPos, detail, culler , curCulling); 
					QuadChunkCornerData.BI = 0;
					drawQuad(cd, camera, curCulling);
				}
			}
			//*/
			
			QuadChunkCornerData.BI = 0;
		}
		
		
		///*
		if (activeChunks.head !=null) {
			chunkPool.appendList( activeChunks.head, activeChunks.tail );
			activeChunks.head = null;
			activeChunks.tail = null;
		}
		//	*/
			
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
	
	
	/* INTERFACE altern.ray.IRaycastImpl */
	// TODO: all raycast implementations from AS3 version
	
	public function intersectRay(origin:Vector3D, direction:Vector3D, output:Vector3D):Vector3D 
	{
		return null;
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