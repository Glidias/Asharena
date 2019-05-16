package altern.js;

#if js
	import js.html.Float32Array;
	import js.html.Uint32Array;
	import js.html.Int32Array;
#end

/**
 * Will port this over to pure Haxe later...
 * https://github.com/mapbox/delaunator
 * 
 * @author Glidias
 */
@:native("Delaunator")
extern class Delaunator 
{
	#if js
	public function new(coords:Float32Array);
	public var triangles:Uint32Array;
	public var halfedges:Int32Array;
	public var hull:Uint32Array;
	public static function from(points:Array<Array<Float>>, ?getX:Float->Float, ?getY:Float->Float):Delaunator;
	#end

}