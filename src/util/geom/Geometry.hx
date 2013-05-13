package util.geom;

/**
 * Basic geometry class to support collision detection/raycasting/etc., or some basic 3D
 * @author Glenn Ko
 */


 import systems.collisions.A3DConst;
 import util.TypeDefs;
 import haxe.io.Error;
 
class Geometry
{
	public var vertices:Vector<Float>;
	public var indices:Vector<Int>;
	//public var normals:Vector<Float>;
	public var numVertices:Int;

	public function new() 
	{
		vertices = [];
		indices = [];
		//normals = [];
		numVertices = 0;		
	}
	
	public inline function addVertex(x:Float, y:Float, z:Float):Int {
		
		var b:Int = numVertices * 3;
		vertices[b] = x; b++;
		vertices[b] = y; b++;
		vertices[b] = z;
		b = numVertices;
		numVertices++;
		return b;
	}
	
	
	public function pushVertices(values:Vector<Float>):Void {
		var len:Int= values.length;
		var numVF:Float = len / 3;
		len = Math.floor( numVF);
		if (len != numVF) {
			trace("Invalid push vertices. Values not divisible by 3!");
			return;
		}
		numVertices += len;
		len = values.length;
		for (i in 0...len) {
			vertices.push(values[i]);
			
		}
	
	}
	
	public inline function addFace(valIndices:Vector<Int>):Void {
		//if (valIndices.length < 3) trace("Invalid n-gon length:" + valIndices.length);
		valIndices = valIndices.slice(0);
		valIndices.reverse();
		var startD:Int;
		var d:Int = startD= indices.length;
		var len:Int = valIndices.length;
	
		var header:Int = ( (valIndices.length << A3DConst._NSHIFT) | valIndices[0] ); 
		//trace("H:" + header);
		indices[d++] = header;  
		for (i in 1...len) {
			indices[d++] = valIndices[i];
		}
	
		
			d = startD;
			// v1
			
		//	var testVal;
			//trace( testVal=((indices[d] & A3DConst._NMASK_) >> A3DConst._NSHIFT) );
			//if (testVal == 0) trace("indiceD:"+ Std.string(indices[d]));  //1073741824 >> A3DConst._NSHIFT
			
			/*
			d = (indices[d] & A3DConst._FMASK_) * 3;
			var ax = vertices[  d ]; d++;
			var ay =  vertices[d ];  d++;
			var az =  vertices[ d ]; 

			// v2
			d = ++startD;
			d = indices[d] * 3;
			var bx =  vertices[ d ]; d++;
			var by =  vertices[ d ]; d++;
			var bz = vertices[ d ]; 

			// v3
			d = ++startD;
			d = indices[d] * 3;
			var cx = vertices[ d]; d++;
			var cy =  vertices[d ]; d++;
			var cz = vertices[ d]; 

			// v2-v1
			var abx = bx - ax;
			var aby = by - ay;
			var abz = bz - az;

			// v3-v1
			var acx = cx - ax;
			var acy = cy - ay;
			var acz = cz - az;

			var normalX = acz*aby - acy*abz;
			var normalY = acx*abz - acz*abx;
			var normalZ = acy*abx - acx*aby;

			var normalLen = Math.sqrt(normalX*normalX + normalY*normalY + normalZ*normalZ);

			if (normalLen > 0) {
				normalX /= normalLen;
				normalY /= normalLen;
				normalZ /= normalLen;
			} else {
				trace("degenerated triangle");
			}
			
			normals.push(normalX);
			normals.push(normalY);
			normals.push(normalZ);
			normals.push(normalX * ax + normalY * ay + normalZ * az);
			*/
	}
	
	/*
	public inline function pushNFaces(indices:Vector<Int>, nSides:Int):Void {
		
	}
	*/
	
	
}