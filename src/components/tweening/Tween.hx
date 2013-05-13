package components.tweening;
import ash.core.Engine;
import ash.core.Entity;
import systems.animation.IAnimatable;

/**
 * Tweening a single target. Supports up to 32 properties per target. To perform tweening with an entity, use entity.addComponent( new Tween(...,...,...) );
 * @author Glenn Ko
 */

typedef Easing = Float->Float->Float->Float->Float;

class Tween extends TweenCore /*, implements IAnimatable*/
{	
	// Duration and tween props

	public var startVals:Array<Float>;
	public var endVals:Array<Float>;
	public var props:Array<String>;
	public var funcMask:Int = 0;
	
	public var arrLen:Int;
	
	
	
	public var target:Dynamic;
	
	// options

	public var ease:Easing;
	//public var onProgress:Dynamic;
	

	/**
	 * 
	 * @param	target		The target to assign a property
	 * @param	duration	The duration of the tween
	 * @param	tweenProps	The proper
	 * @param	options		Any additional options to use
	 */
	public function new(target:Dynamic, duration:Float, tweenProps:Dynamic, options:TweenOptions=null) 
	{
		super();
		this.target = target;
		this.duration = duration;
		t = 0;
		funcMask = 0;
		
		// settle options
		if (options != null) {
			repeatCount = options.repeatCount != null ? options.repeatCount : 0;
			ease = options.ease != null ? options.ease : DEFAULT_EASE;
			onComplete = options.onComplete != null ? options.onComplete : null;
		}
		else { // set default options
			repeatCount = 0;
			ease = DEFAULT_EASE;
			onComplete = null;
		}
		

		
		startVals = new Array<Float>(); 
		endVals = new Array<Float>();
		props = new Array<String>();
		
		var nbTotal:Int = 0;
		var isFunc:Bool = false;
		var startV:Float;
		
		for ( key in Reflect.fields( tweenProps ) ) {
				isFunc = false;
				if ( key.substr(0, 3)  != "set" ) {
					startVals[untyped nbTotal] = startV = target[untyped key];	
				}
				else {
					isFunc = true;
					funcMask |= (1 << nbTotal);
					startVals[untyped nbTotal] = startV =  target[untyped "get"+key.substr(3)]();	
				}
				endVals[untyped nbTotal] = tweenProps[untyped key] - startV;
			
				props[nbTotal] = key;
				nbTotal++;
		}
			
		arrLen = nbTotal;
	}
	
	public inline function _getTotalDuration():Float {
		return duration;
	}
	
	private static function DEFAULT_EASE ( t : Float, b : Float, c : Float, d : Float ) : Float {
		return -c * ( ( t = t / d - 1 ) * t * t * t - 1 ) + b;
	}
	
	/* INTERFACE systems.animation.IAnimatable */
	///*
	public inline function animate(time:Float):Void 
	{
		t += time;
		if (t > duration) {
			if (repeatCount > 0) {  // repeat
				t = duration;
				repeatCount--;
			}
			else if (repeatCount == 0) {  // stop at end frame
				t = duration;
				// dispatch end event if required
				if (onComplete != null) onComplete();
			}
			else {  // loop uindeifnitely
				t -= duration;
			}
		}

		var i:Int = arrLen;
		while (--i > -1) {
			if ( (funcMask & (1<<i)) != 0) target[ untyped props[i] ]( ease(t, startVals[i], endVals[i], duration) );
			else  target[ untyped props[i] ] = ease(t, startVals[i], endVals[i], duration);
		}
	}
	//*/
}




typedef TweenOptions = {
	@:optional  var repeatCount : Int;
	@:optional  var ease : Easing;
	//@:optional  var onProgress : Dynamic;
	@:optional  var onComplete : Void->Void;
}