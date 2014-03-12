package arena.components.enemy;
import util.geom.PMath;

/**
 * Component state for idle enemies on watch, or just a holder for watch/range settings
 * @author ...
 */
class EnemyIdle
{
	public var alertRangeSq:Float;  // the threshold range in order to go to alert  EnemyWatch state.
	
	
	public function new() 
	{
		
	}
	
	public function init(range:Float):EnemyIdle {
		alertRangeSq = PMath.getSquareDist(range);
		return this;
	}
	
	
	
}