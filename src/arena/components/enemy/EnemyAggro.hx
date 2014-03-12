package arena.components.enemy;
import arena.systems.player.PlayerAggroNode;
import ash.core.Entity;
import util.geom.PMath;

/**
 * Component state for possible activated enemies that will attack/engage if possible.
 * @author ...
 */
class EnemyAggro
{
	public var target:PlayerAggroNode; 
	public var attackRangeSq:Float; // this is variable, randomly assign prefered attackRange within attack range margin before any attack.

	public var watch:EnemyIdle; 
	
	public function new() 
	{
		
	}
	
	public inline function init(target:PlayerAggroNode, attackingRange:Float, watch:EnemyIdle):Void {
		this.target = target;
		attackRangeSq = PMath.getSquareDist(attackingRange);
		this.watch  = watch;
	}
	
	public inline function dispose():Void {
		watch = null;
		target = null;
	}
	
	
	
}