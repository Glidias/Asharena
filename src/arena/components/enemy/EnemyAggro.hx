package arena.components.enemy;
import arena.components.weapon.Weapon;
import arena.systems.player.PlayerAggroNode;
import ash.core.Entity;
import util.geom.PMath;

/**
 * Component state for possible activated enemies that will attack/engage if possible. 
 * This can be used to trick friendly targets to attack enemy targets as well during support/assist fire situation.
 * @author ...
 */
class EnemyAggro
{
	public var target:PlayerAggroNode;   // the target to aim at
	public var attackRangeSq:Float; // this is variable, randomly assign prefered attackRange within attack range margin before any attack.

	public var watch:EnemyIdle; 
	public var flag:Int;  //for debugging or state checking
	public var fixed:Bool;  // a flag to indicate permanent locking to this state or no changing of state
	
	// 0 -idle
	// 1 - swining weapon (already triggered attack)
	// 2 - striked already with weapon
	// 3 - cooling down
	
	
	
	public function new() 
	{
		
	}
	
	public inline function init(target:PlayerAggroNode, attackingRange:Float, watch:EnemyIdle):Void {
		this.target = target;
		//flag = 0;
		attackRangeSq = attackingRange*attackingRange;
		this.watch  = watch;
		this.fixed = false;
		
	}
	
	public  function initSimple(target:PlayerAggroNode, watch:EnemyIdle):EnemyAggro {
		this.target = target;
		this.watch  = watch;
		this.fixed = false;
		return this;
	}
	public inline function setAttackRange(range:Float):Void {
		attackRangeSq = range*range;
	}
	
	public inline function dispose():Void {
	
		target = null;
		flag = 0;
	}
	
	/*
	function get_attackRangeSq():Float
	{
		return attackRange*attackRange;
	}
	
	public var attackRangeSq(get_attackRangeSq, null):Float;
	*/
	
	
}