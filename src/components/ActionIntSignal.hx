package components;
import ash.signals.Signal1;

/**
 * 
 * @author Glenn Ko
 */
class ActionIntSignal extends Signal1<Int>
{

	public static inline var DEFAULT_VALUE:Int = 0;
	public var current:Int; 
	public var locked:Bool; // a flag for misc use
	
	public function new() 
	{
		super();
		current = DEFAULT_VALUE;
		locked = false;
	}
	
	public inline function set(val:Int):Void {
		if (val != current) dispatch(current = val);
		//return val != current;
	}
	
} 