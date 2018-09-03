package altern.geom;

/**
 * ...
 * @author Glidias
 */
class Vertex
{

	public function new() 
	{
		
	}
	public var next:Vertex;
	public var value:Vertex;
	
	public var x:Float;
	public var y:Float;
	public var z:Float;
	
	public var offset:Float;
	
	public var cameraX:Float;
	public var cameraY:Float;
	public var cameraZ:Float;
	
	public var transformId:Int = 0;
	
	public static var collector:Vertex;
	public static function create():Vertex {
		if (collector != null) {
			var res:Vertex = collector;
			collector = res.next;
			res.next = null;
			res.transformId = 0;
			//res.drawId = 0;
			return res;
		} else {
			//trace("new Vertex");
			return new Vertex();
		}
	}
	
}