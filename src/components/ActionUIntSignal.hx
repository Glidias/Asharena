package components;
import ash.signals.Signal1;

/**
 * 
 * @author Glenn Ko
 */
class ActionUIntSignal extends Signal1<Int>
{

	public static inline var DEFAULT_VALUE:Int = 0;
	public var current:UInt; 
	public var locked:Bool; // a flag for misc use
	
	public function new() 
	{
		super();
		current = DEFAULT_VALUE;
		locked = false;
	}
	
	public inline function set(val:UInt):Void {
		if (val != current) dispatch(current = val);
		//return val != current;
	}
	
} 