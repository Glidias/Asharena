package altern.terrain;
import de.polygonal.ds.NativeInt32Array;
import util.geom.Geometry;

/**
 * ...
 * @author Glidias
 */
class GeometryResult 
{

	public var geometry:Geometry;
	public var indexLookup:NativeInt32Array;
	public var uvSeg:Float;
	public var edgeChangeVertexIndex:Int;
	public var verticesAcross:Int;
	public var patchSize:Int;
	
	public function new() {
		
	}
	
	public function getIndexAtUV(u:Float, v:Float):Int {

		return indexLookup[ Std.int(v / uvSeg) * verticesAcross + Std.int(u/uvSeg) ];
	}
	public function getIndex(x:Int, y:Int):Int {

		return indexLookup[ y* verticesAcross + x ];
	}
	
}