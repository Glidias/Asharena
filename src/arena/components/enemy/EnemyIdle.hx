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
	public var fov:Float;
	public var eyeHeightOffset:Float;
	public static inline var DEFAULT_FOV:Float = 1.8849555921538759430775860299677;// (PMath.PI * .6);
	
	public function new() 
	{
		
	}
	
	public function init(alertRange:Float, aggroRange:Float, fov:Float=1.8849555921538759430775860299677, eyeHeightOffset:Float=0):EnemyIdle {
		alertRangeSq = alertRange * alertRange;// PMath.getSquareDist(alertRange);
		aggroRangeSq = aggroRange * aggroRange;// PMath.getSquareDist(aggroRange);
		this.fov = fov;
		this.eyeHeightOffset = eyeHeightOffset;
		return this;
	}
	
	
	
}