package components;
import ash.core.Entity;
import ash.signals.Signal1;

/**
 * ...
 * @author Glenn Ko
 */
class EllipsoidSignal extends Ellipsoid
{
	public var signal:Signal1<Entity>;

	public function new() 
	{
		super();
		signal = new Signal1<Entity>();
	}
	
}