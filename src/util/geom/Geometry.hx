package util.geom;

/**
 * Basic geometry class to support collision detection/raycasting/etc., or some basic 3D
 * @author Glenn Ko
 */
 import components.Transform3D;
 import systems.collisions.A3DConst;
 import systems.collisions.EllipsoidCollider;
 import systems.collisions.IECollidable;
 import util.TypeDefs;
 import haxe.io.Error;
 
class Geometry implements IECollidable
{
	public var vertices:Vector<Float>;
	public var indices:Vector<UInt>;
	//public var normals:Vector<Float>;
	public var numVertices:Int;
	public var numIndices:Int;
	static public  var IDENTITY:Transform3D = new Transform3D();

	public function new() 
	{
		vertices = new Vector<Float>();
		indices = new Vector<UInt>();
		//normals = [];
		numVertices = 0;
		numIndices = 0;
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
	
	public inline function setVertices(val:Vector<Float>):Void {
		vertices = val;
		numVertices = Std.int( val.length / 3);
	}
	
	public inline function setIndices(val:Vector<UInt>):Void {
		indices = val;
		numIndices = val.length;
	}
	
	public inline function addTriFaces(indices:Vector<UInt>, d:Int=-1):Void {
		var i:Int = 0;
		var addFaceBuffer:Vector<UInt> = TypeDefs.createUIntVector(3, true);
		var len:Int = indices.length;
		while ( i < len) {
			addFaceBuffer[0] = indices[i];
			addFaceBuffer[1] = indices[i + 1];
			addFaceBuffer[2] = indices[i + 2];
			
			addFace(addFaceBuffer, d);
			i += 3;
		}
	}
	
	public inline function addFace(valIndices:Vector<UInt>, d:Int=-1):Void {
		//if (valIndices.length < 3) trace("Invalid n-gon length:" + valIndices.length);

		if (d < 0) d = indices.length;
		var d:Int = indices.length;
		var len:Int = valIndices.length;
	
		var header:Int = ( (valIndices.length << A3DConst._NSHIFT) | valIndices[0] ); 
		indices[d++] = header;  
		for (i in 1...len) {
			indices[d++] = valIndices[i];
		}
		
		numIndices = d;
		
	}
	
	/* INTERFACE systems.collisions.IECollidable */
	
	public function collectGeometry(collider:EllipsoidCollider):Void 
	{
		collider.addGeometry(this, collider.inverseMatrix);
	}
	
	/*
	public inline function pushNFaces(indices:Vector<Int>, nSides:Int):Void {
		
	}
	*/
	
	
}