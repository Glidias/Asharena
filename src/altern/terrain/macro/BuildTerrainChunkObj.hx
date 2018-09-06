package altern.terrain.macro;


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
	
	static inline var HEIGHT_MULT_METERS:Float = 200;
	static inline var METERS_PER_HL256:Float = 4.8768;
	static inline var HL256_TO_METERS:Float = 0.01905;
	static inline var METERS_TO_HL256:Float = 1 / HL256_TO_METERS;
	
	static inline var HEIGHT_MIN_METERS:Float = 0;
	static inline var HEIGHT_MAX_METERS:Float = 200;
	static inline var CHUNK_SIZE:Int = 128;
	static inline var SRC_SIZE:Int = 2048;
	static inline var MAP_SIZE:Int = 1024;
	static inline var MAP_SIZE_METERS:Float = MAP_SIZE*METERS_PER_HL256;
	static inline var IMPORT_PATH_PREFIX:String = "bin/imports/terrain/";
	static inline var EXPORT_PATH_PREFIX:String = "bin/exports/terrain/";
	
	static macro function exportFiles():Expr {
		var noLowRes:Bool = false;
		if (MAP_SIZE < CHUNK_SIZE*2) {
			//throw "MAP_SIZE is too small for CHUNK_SIZE!";
			noLowRes = true;
		}
		var chunkLen:Int = Std.int(MAP_SIZE / CHUNK_SIZE);
		
		var chunkLowResSize:Int = Std.int( CHUNK_SIZE / chunkLen);
		
		var protoG:GeometryResult = TerrainGeomTools.createLODTerrainChunkForMesh(CHUNK_SIZE, 256);
		var protoGLowRes:GeometryResult = !noLowRes ? TerrainGeomTools.createLODTerrainChunkForMesh(chunkLowResSize, 256) : null;
		
		if (!FileSystem.exists(EXPORT_PATH_PREFIX + "chunks_high") || !FileSystem.isDirectory(EXPORT_PATH_PREFIX + "chunks_high")) {
			FileSystem.createDirectory(EXPORT_PATH_PREFIX + "chunks_high");
		}
		if (!FileSystem.exists(EXPORT_PATH_PREFIX + "chunks_low") || !FileSystem.isDirectory(EXPORT_PATH_PREFIX + "chunks_low")) {
			FileSystem.createDirectory(EXPORT_PATH_PREFIX + "chunks_low");
		}
		var heightMap:HeightMapInfo = new HeightMapInfo();
		heightMap.setFlat(CHUNK_SIZE, 256);
		heightMap.flatten();
		//heightMap.setFromBytes(
		
		var vnBuffer:String = "0 1 0\n";
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
				var i1:Int = protoG.geometry.indices[i] + 1;
				var i2:Int = protoG.geometry.indices[i+1] + 1;
				var i3:Int = protoG.geometry.indices[i + 2] + 1;
				iBufferLite.add('f ${i1}/${i1}/1 ${i2}/${i2}/1 ${i3}/${i3}/1\n');
				i += 3;
			}
		}
		
		for (x in 0...chunkLen) {
			for (y in 0...chunkLen) {
				var vBuffer:StringBuf = new StringBuf();
				var vtBuffer:StringBuf = new StringBuf();
				var i:Int = 0;
				var len:Int = protoG.geometry.vertices.length;
				while (i < len) {
					var x:Float = protoG.geometry.vertices[i] + 256*x;
					var y:Float = protoG.geometry.vertices[i+1];
					var z:Float = protoG.geometry.vertices[i + 2] + 256*y;
					var xi:Int = Std.int(x / 256);
					var yi:Int = Std.int(y / 256);
					x *= HL256_TO_METERS;
					y *= HL256_TO_METERS;
					z *= HL256_TO_METERS;
					//heightMap[yi*SRC_SIZE];
					//heightMap[Std.int(z / patchSize)];
					vBuffer.add('v ${x} ${y} ${z}\n');
					vtBuffer.add('v ${x/MAP_SIZE_METERS} ${y/MAP_SIZE_METERS} ${z/MAP_SIZE_METERS}\n');
					i += 3;
				}
				File.saveContent(EXPORT_PATH_PREFIX+"chunks_high/"+x+"_"+y+".obj", vBuffer.toString() + vtBuffer.toString() + vnBuffer + iBuffer.toString() );
			}
		}
		trace("...commpleted HiRes...");
		
		if (protoGLowRes!=null) {
			for (x in 0...chunkLen) {
				for (y in 0...chunkLen) {
					var vBuffer:StringBuf = new StringBuf();
					var vtBuffer:StringBuf = new StringBuf();
					var i:Int = 0;
					var len:Int = protoGLowRes.geometry.vertices.length;
					while (i < len) {
						var x:Float = protoG.geometry.vertices[i] + 256*x;
						var y:Float = protoG.geometry.vertices[i+1];
						var z:Float = protoG.geometry.vertices[i + 2] + 256*y;
						var xi:Int = Std.int(x / 256);
						var yi:Int = Std.int(y / 256);
						x *= HL256_TO_METERS;
						y *= HL256_TO_METERS;
						z *= HL256_TO_METERS;
						//heightMap[yi*SRC_SIZE];
						//heightMap[Std.int(z / patchSize)];
						vBuffer.add('v ${x} ${y} ${z}\n');
						vtBuffer.add('v ${x/MAP_SIZE_METERS} ${y/MAP_SIZE_METERS} ${z/MAP_SIZE_METERS}\n');
						i += 3;
					}
					File.saveContent(EXPORT_PATH_PREFIX+"chunks_low/"+x+"_"+y+".obj", vBuffer.toString() + vtBuffer.toString() + vnBuffer + iBufferLite.toString() );
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