package altern.culling;

/**
 * ...
 * @author Glidias
 */
class CullingPlane
{
	

	public function new() 
	{
		
	}
	public var x:Float;
	public var y:Float;
	public var z:Float;
	public var offset:Float;
	
	public var next:CullingPlane;
		
	static public var collector:CullingPlane;

	static public function create():CullingPlane {
		if (collector != null) {
			var res:CullingPlane = collector;
			collector = res.next;
			res.next = null;
			return res;
		} else {
			return new CullingPlane();
		}
	}
}