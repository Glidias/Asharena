package components.tweening;

/**
 * ...
 * @author Glenn Ko
 */
class TweenCore
{
	
	public var t:Float;
	public var duration:Float;
	
	// options
	public var repeatCount:Int;
	public var onComplete:Void->Void;
	public var dead:Bool;
	
	public function new() 
	{
		dead = true;
	}
	
}