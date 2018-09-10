package altern.terrain.macro;
import haxe.io.BytesData;


#if macro
import altern.terrain.GeometryResult;
import altern.terrain.HeightMapInfo;
import haxe.io.Bytes;
import haxe.macro.Expr;
import sys.FileSystem;
import sys.io.File;
import haxe.Json;
#end

/**
 * A macro to export out Wavefront .OBJ files from terrain heightmap for use in Playcanvas/general purposes.
 * Eg. OBJ files can be used to generate navigation meshes.
 * @author Glidias
 */
class BuildTerrainChunkObj
{

	public function new() 
	{
		exportFiles();
	}
	
	// Half-life game unit scheme
	//4.8768 meters for 256 HL Unit tile
	//0.01905 scale to represent 256 HL Unit tile.
	
	// SRC files
	static inline var IMPORT_HEIGHTMAP:String = "bin/assets/terrains/63058-9p_elevation.bin";
	
	// Configurables
	static inline var SRC_SIZE:Int = 2048;
	static inline var MAP_SIZE:Int = 1024;
	static inline var HEIGHT_MIN_METERS:Float = 0;
	static inline var HEIGHT_MAX_METERS:Float = 1100;

	// Wavefront obj export scale per vertex. (Somehow, Playcanvas scales the root node of OBJs by 0.01! Use scale 100 to compensate fully 1 unit for 1 meter)
	static inline var OBJ_EXPORT_SCALE:Float = 10;	// 100 for full compensation

	static inline var METERS_PER_HL256:Float = 4.8768; // How many meters dimension consist of a HL256 tile
	
	// Conventions
	static inline var CHUNK_SIZE:Int = 128;	
	static inline var EXPORT_PATH_PREFIX:String = "bin/exports/terrain/";
	
	// Derived
	static inline var HL256_TO_METERS:Float = METERS_PER_HL256/256;
	static inline var METERS_TO_HL256:Float = 1 / HL256_TO_METERS;
	static inline var TOTAL_EXPORT_SCALE:Float = OBJ_EXPORT_SCALE * HL256_TO_METERS;
	static inline var MAP_SIZE_METERS:Float = MAP_SIZE*METERS_PER_HL256;
	

	
	
	
	static macro function exportFiles():Expr {
		var noLowRes:Bool = false;
		if (MAP_SIZE < CHUNK_SIZE*2) {
			//throw "MAP_SIZE is too small for CHUNK_SIZE!";
			noLowRes = true;
		}
		var chunkLen:Int = Std.int(MAP_SIZE / CHUNK_SIZE);
		
		var chunkLowResSize:Int = Std.int( CHUNK_SIZE / chunkLen );
		
		var protoG:GeometryResult = TerrainGeomTools.createLODTerrainChunkForMesh(CHUNK_SIZE, 256);
		var protoGLowRes:GeometryResult = !noLowRes ? TerrainGeomTools.createLODTerrainChunkForMesh(chunkLowResSize, Std.int(256*(CHUNK_SIZE/chunkLowResSize))) : null;
		
		if (!FileSystem.exists(EXPORT_PATH_PREFIX + "chunks_high") || !FileSystem.isDirectory(EXPORT_PATH_PREFIX + "chunks_high")) {
			FileSystem.createDirectory(EXPORT_PATH_PREFIX + "chunks_high");
		}
		else {
			//FileSystem.deleteDirectory(EXPORT_PATH_PREFIX + "chunks_high");
			//FileSystem.createDirectory(EXPORT_PATH_PREFIX + "chunks_high");
		}
		
		
		
		var heightMap:HeightMapInfo = new HeightMapInfo();
		heightMap.XOrigin = 0;
		heightMap.ZOrigin = 0;
		
		if (!FileSystem.exists(IMPORT_HEIGHTMAP) || FileSystem.isDirectory(IMPORT_HEIGHTMAP)) {
			trace( "No IMPORT_HEIGHTMAP file found.");
			throw "Could not resolve IMPORT_HEIGHTMAP filepath";
			heightMap.setFlat(MAP_SIZE, 256);
			heightMap.flatten();
			trace("Seting flat height map...");
		}
		else {
			heightMap.setFromBytes( File.read(IMPORT_HEIGHTMAP).readAll(), (HEIGHT_MAX_METERS - HEIGHT_MIN_METERS) * METERS_TO_HL256 / 255, MAP_SIZE, Std.int(HEIGHT_MIN_METERS * METERS_TO_HL256), 256);
			heightMap.BoxFilterHeightMap(true);
			trace("Set up heightmap ref src...");
		}
		
		
		var vnBuffer:String = "vn 0 1 0\n"; //g terrain\ns 1\n
		var iBuffer:StringBuf = new StringBuf();
		var i:Int = 0;
		var len:Int = protoG.geometry.indices.length;
		while (i < len) {
			var i1:Int = protoG.geometry.indices[i] + 1;
			var i2:Int = protoG.geometry.indices[i+1] + 1;
			var i3:Int = protoG.geometry.indices[i + 2] + 1;
			iBuffer.add('f ${i1}/${i1}/1 ${i2}/${i2}/1 ${i3}/${i3}/1\n');
			i += 3;
		}
		
		var iBufferLite:StringBuf = null;
		if (protoGLowRes != null) {
			iBufferLite = new StringBuf();
			var i:Int = 0;
			var len:Int = protoGLowRes.geometry.indices.length;
			while (i < len) {
				var i1:Int = protoGLowRes.geometry.indices[i] + 1;
				var i2:Int = protoGLowRes.geometry.indices[i+1] + 1;
				var i3:Int = protoGLowRes.geometry.indices[i + 2] + 1;
				iBufferLite.add('f ${i1}/${i1}/1 ${i2}/${i2}/1 ${i3}/${i3}/1\n');
				i += 3;
			}
		}
		
		
		for (xcc in 0...chunkLen) {
			for (ycc in 0...chunkLen) {
				var vBuffer:StringBuf = new StringBuf();
				var vtBuffer:StringBuf = new StringBuf();
				var i:Int = 0;
				var len:Int = protoG.geometry.vertices.length;
				while (i < len) {
					var x:Float = protoG.geometry.vertices[i] + 256*xcc*CHUNK_SIZE;
					var y:Float = protoG.geometry.vertices[i+1];
					var z:Float = protoG.geometry.vertices[i + 2] - 256*ycc*CHUNK_SIZE;
					var xi:Int = Std.int(x / 256);
					var yi:Int = Std.int( -z / 256);
					//if (yi < 0 || yi >= heightMap.RowWidth) {
					//	throw "OUT:"+yi;
					//}
					y = heightMap.SampleInd(xi, yi);
					x *= TOTAL_EXPORT_SCALE;
					y *= TOTAL_EXPORT_SCALE;
					z *= TOTAL_EXPORT_SCALE;
					vBuffer.add('v ${x} ${y} ${z}\n');
					vtBuffer.add('vt ${xi/MAP_SIZE} ${yi/MAP_SIZE}\n');
					i += 3;
				}
				File.saveContent(EXPORT_PATH_PREFIX+"chunks_high/"+xcc+"_"+ycc+".obj", vBuffer.toString() + vtBuffer.toString() + vnBuffer + iBuffer.toString() );
			}
		}
		
		trace("...commpleted HiRes...");
		
		if (protoGLowRes != null) {
			if (!FileSystem.exists(EXPORT_PATH_PREFIX + "chunks_low") || !FileSystem.isDirectory(EXPORT_PATH_PREFIX + "chunks_low")) {
				FileSystem.createDirectory(EXPORT_PATH_PREFIX + "chunks_low");
			}
			else {
				//FileSystem.deleteDirectory(EXPORT_PATH_PREFIX + "chunks_low");
				//FileSystem.createDirectory(EXPORT_PATH_PREFIX + "chunks_low");
			}
			
			for (xcc in 0...chunkLen) {
				for (ycc in 0...chunkLen) {
					var vBuffer:StringBuf = new StringBuf();
					var vtBuffer:StringBuf = new StringBuf();
					var i:Int = 0;
					var len:Int = protoGLowRes.geometry.vertices.length;
					while (i < len) {
						var x:Float = protoGLowRes.geometry.vertices[i] + 256*xcc*CHUNK_SIZE;
						var y:Float = protoGLowRes.geometry.vertices[i+1];
						var z:Float = protoGLowRes.geometry.vertices[i + 2] - 256*ycc*CHUNK_SIZE;
						var xi:Int = Std.int(x / 256);
						var yi:Int = Std.int(-z / 256);
						y = heightMap.SampleInd(xi, yi);
						
						x *= TOTAL_EXPORT_SCALE;
						y *= TOTAL_EXPORT_SCALE;
						z *= TOTAL_EXPORT_SCALE;
						//heightMap[yi*SRC_SIZE];
						//heightMap[Std.int(z / patchSize)];
						vBuffer.add('v ${x} ${y} ${z}\n');
						vtBuffer.add('vt ${xi/MAP_SIZE} ${yi/MAP_SIZE}\n');
						i += 3;
					}
					File.saveContent(EXPORT_PATH_PREFIX+"chunks_low/"+xcc+"_"+ycc+".obj", vBuffer.toString() + vtBuffer.toString() + vnBuffer + iBufferLite.toString() );
				}
			}
		}

		
		trace("Completed ALL! Got low res? "+(protoGLowRes!=null));
		
		return macro null;
	}
	
	
	
	static function main() 
	{
		
		
	}
	


	
}