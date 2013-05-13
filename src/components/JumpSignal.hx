package components;
import ash.core.Entity;
import ash.signals.Signal2;


/**
 * Whenever the state of enabled jump changes, whether due to jumping off ground or landing, a signal can be used to change animation, play sound, etc.
 * @author Glenn Ko
 */

 /**
  * Bool - Enabled state
  * Entity - The assoiated entity pointer in case you need to access anything else...
  */
class JumpSignal extends Signal2<Bool, Entity>
{
	public function new() 
	{
		super();
	}
}