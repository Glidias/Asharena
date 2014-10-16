package arena.components.enemy;
import util.geom.PMath;

/**
 * Component state for idle enemies on watch, or just a holder for watch/vis-range settings 
 * @author ...
 */
class EnemyIdle
{
	// the threshold range from which enemies will be alerted and can trigger turn-based combat against you. Also dictates fast-travel/free-travel ability.
	public var alertRange:Float;  
	public var alertRangeSq:Float;  // the threshold range in order to go to alert EnemyWatch state.
	public var aggroRangeSq:Float;	 // the threshold range in order to go to aggressive EnemyAggro state.
	public var tensionRange:Float;
	public var tensionRangeSq:Float;
	public var tensionVincity:Float;
	public var aggroRange:Float;
	public var fov:Float;
	public var eyeHeightOffset:Float;
	public static inline var DEFAULT_FOV:Float = 1.8849555921538759430775860299677;// (PMath.PI * .6);
	public static inline var DEFAULT_TENSION_RANGE:Float = 300;
	public static inline var DEFAULT_AGGRO_RANGE:Float = 288;
	public static inline var DEFAULT_AGGRO_RANGE_SQ:Float = DEFAULT_AGGRO_RANGE*DEFAULT_AGGRO_RANGE;
	
	public function new() 
	{
		
	}
	
	public function init(alertRange:Float, aggroRange:Float, fov:Float=1.8849555921538759430775860299677, eyeHeightOffset:Float=0):EnemyIdle {
		this.alertRange = alertRange;
		alertRangeSq = alertRange * alertRange;// PMath.getSquareDist(alertRange);
		aggroRangeSq = aggroRange * aggroRange;// PMath.getSquareDist(aggroRange);
		tensionRange = aggroRange + DEFAULT_TENSION_RANGE;
		tensionRangeSq = tensionRange * tensionRange;
		
		this.aggroRange = aggroRange;
		tensionVincity = tensionRange - aggroRange;
		
		this.fov = fov;
		this.eyeHeightOffset = eyeHeightOffset;
		return this;
	}
	
	
	
}