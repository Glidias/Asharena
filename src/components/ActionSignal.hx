package components;
import ash.signals.Signal1;

/**
 * A signal for triggering an action across various instances.
 * @author Glenn Ko
 */
class ActionSignal extends Signal1<String>
{
	public var current:String;
	public var locked:Bool; // flag for misc use
	
	public function new() 
	{
		super();
		locked = false;
		
	}
	
	public inline function set(val:String):Bool {
		if (val != current) dispatch(current = val);
		return val != current;
	}
	
	
	
}