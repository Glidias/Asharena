package components.tweening;

/**
 * ...
 * @author Glenn Ko
 */
class TweenGroup extends TweenCore
{

	public var tweens:Array<Tween>;

	public function new(options:TweenGroupOptions=null) 
	{
		super();
		
		tweens = new Array<Tween>();
		duration = 0;
		t = 0;
		
		if (options != null) {
			repeatCount = options.repeatCount != null ? options.repeatCount : 0;
			onComplete = options.onComplete != null ? options.onComplete : null;
		}
		else {
			repeatCount = 0;
			onComplete = null;
		}
		
	}
	
	
	public inline function append(tw:Tween):Void {
		var tryDur:Float = tw._getTotalDuration();
		duration = tryDur > duration ? tryDur : duration;
		tweens.push(tw);
	}
	
	public inline function setTweens(val:Array<Tween>):Void {
		this.tweens = val;
	}
	
	
	
	
	
}

typedef TweenGroupOptions = {
	@:optional  var repeatCount : Int;
	//@:optional  var onProgress : Dynamic;
	@:optional  var onComplete : Void->Void;
}