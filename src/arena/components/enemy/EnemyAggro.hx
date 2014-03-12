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
	
	public var attackRangeSq:Float; // this is variable, randomly assign prefered attackRange within attack range margin before any attack.

	public var watch:EnemyWatch;
	
	public function new() 
	{
		
	}
	
	public inline function init(attackingRange:Float, lastWatch:EnemyWatch):Void {
		attackRangeSq = PMath.getSquareDist(attackingRange);
		watch  = lastWatch;
	}
	
	public inline function dispose():Void {
		watch = null;
		
	}
	
	
	
}