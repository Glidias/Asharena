package arena.components.enemy;
import ash.core.Entity;

/**
 * Component state for possible activated enemies that will attack/engage if possible.
 * @author ...
 */
class EnemyAggro
{
	public var target:Entity;  
	public var attackRange:Float; // this is variable, randomly assign prefered attackRange within attack range margin before any attack.
	
	public function new() 
	{
		
	}
	
}