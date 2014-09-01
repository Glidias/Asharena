package arena.components.weapon;
import components.Ellipsoid;
import components.Health;
import components.Pos;

/**
 * Enemy AI states:

EnemyIdle - 

EnemyWatch - will watch player unless got nearer units to distract him within his aggro/threatened range. will attempt to ready weapon if needed.

EnemyAggro - will attempt to watch and attack player who potentially lies within range of weaponary. will attempt to ready weapon if needed.


EnemyAggroSystem
AggroMemManager


AnimAttackMelee

_________________

2 types of Ranged:

- Arrow Pull (use arrowPullCouple)
- Trigger pull

2 types of firemodes:

Velocity
Trajectory

AnimAttackRanged 
(time to ready it from idle state...) (ie. timeTosWing, anim_startSwingTime )
(time to recover after trigger strike pulled) (ie. cooldownTime, anim_fullSwingTime )
(time to pull trigger strike from readied state) (ie.strikeTimeAtMaxRange, anim_strikeTimeAtMaxRange )

For arrows,
simply adjust weight between 0 to 1 from minimum/max tension range using maximum arrow range towards AggroRange for all >= EnemyWatch according to time passed by speed (1/strikeTimeAtMaxRange)*t. 
Minimum weight range is clamped from maximum arrow range for a few yards from aggro range. So, they won't hold start to pull the arrow until within a few yards from aggro range.
Actually, just set minimum weight range to within few yards from AggroRange is good enough.

For arrow pull, strikeTime is different depending on the tension of the arrow at minRange/maxRange.  HIgher tension means shorter strikeTime, using the value closer towards .
For arrows, the Weight for maximum release is 1. 
Calculated time taken to pull trigger from readied state = Math.clamp(1 - current.weight) * (strikeTimeAtMaxRange)


 * @author Glidias
 */
class AnimAttackRanged
{
	public var curTime:Float;
	
	public var targetPos:Pos;
	public var originX:Float;
	public var originY:Float;
	public var originZ:Float;
	
	public var targetEllipsoid:Ellipsoid;
	public var targetHP:Health;
	public var damageDeal:Int;
	
	public var fixedStrikeTime:Float;
	public var action:Int;
	
	public function new() 
	{
		
	}
	
	public inline function init_i(pos:Pos, targetEllipsoid:Ellipsoid, targetHP:Health, damageDeal:Int, action:Int ):Void {
		curTime = 0;
		fixedStrikeTime = 0;
		this.targetPos = pos;
		this.targetEllipsoid = targetEllipsoid;
		this.targetHP = targetHP;
		this.damageDeal = damageDeal;
		this.action = action;
	}
	
	public inline function init_i_static(fixedStrikeTime:Float, targetHP:Health, damageDeal:Int, action:Int ):Void {
		curTime = 0;
		this.fixedStrikeTime = fixedStrikeTime;
		this.targetPos = null;
		this.targetEllipsoid = null;
		this.targetHP = targetHP;
		this.damageDeal = damageDeal;
		this.action = action;
	
	}
	
	public inline function dispose():Void {
		curTime = 0;
		fixedStrikeTime = 0;
		targetPos = null;
		rangeTargetPos = null;
		targetEllipsoid = null;
		targetHP = null;
		action = 0;
	}
	
}