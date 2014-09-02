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
	public var tensionRange:Float;
	public var tensionRangeSq:Float;
	public var tensionVincity:Float;
	public var aggroRange:Float;
	public var fov:Float;
	public var eyeHeightOffset:Float;
	public static inline var DEFAULT_FOV:Float = 1.8849555921538759430775860299677;// (PMath.PI * .6);
	public static inline var DEFAULT_TENSION_RANGE:Float = 300;
	
	public function new() 
	{
		
	}
	
	public function init(alertRange:Float, aggroRange:Float, fov:Float=1.8849555921538759430775860299677, eyeHeightOffset:Float=0):EnemyIdle {
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