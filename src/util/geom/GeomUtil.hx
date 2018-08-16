package util.geom;
import components.Transform3D;
import util.TypeDefs;
 
/**
 * General utilities to manage 3d geometric data and transforms
 * @author Glidias
 */
class GeomUtil 
{	
	public static function transformVertices(vertices:Vector<Float>, t:Transform3D):Void {
		var len:Int = vertices.length;
		var i:Int = 0;
		while ( i < len) {
			var x:Float = vertices[i];
			var y:Float = vertices[i+1];
			var z:Float = vertices[i + 2];
			vertices[i] = t.a * x + t.b * y + t.c * z + t.d;
			vertices[i+1] = t.e * x + t.f * y + t.g * z + t.h;
			vertices[i+2] = t.i * x + t.j * y + t.k * z + t.l;
			i += 3;
		}
	}
}