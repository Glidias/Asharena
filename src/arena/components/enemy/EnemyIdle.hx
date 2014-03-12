package arena.components.enemy;
import util.geom.PMath;

/**
 * Component state for idle enemies on watch, or just a holder for watch/vis-range settings 
 * @author ...
 */
class EnemyIdle
{
	public var alertRangeSq:Float;  // the threshold range in order to go to alert EnemyWatch state.
	public var aggroRangeSq:Float;	 // the threshold range in order to go to aggressive EnemyAggro state.
	
	public function new() 
	{
		
	}
	
	public function init(alertRange:Float, aggroRange:Float):EnemyIdle {
		alertRangeSq = PMath.getSquareDist(alertRange);
		aggroRangeSq = PMath.getSquareDist(aggroRange);
		return this;
	}
	
	
	
}