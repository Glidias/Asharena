package arena.components.enemy;
import arena.systems.player.PlayerAggroNode;
import ash.core.Entity;
import components.Ellipsoid;

/**
 *  Component state for watchful enemies.
 * @author ...
 */
class EnemyWatch
{
	public var target:PlayerAggroNode; 
	
	public var watch:EnemyIdle;  // the old previous idle watch state  settings


	public function new() 
	{
		
	}
	
	public function init(watch:EnemyIdle, target:PlayerAggroNode):EnemyWatch {
		//target = null;
		this.watch = watch;
		this.target = target;

		return this;
	}
	
	public inline function dispose():Void {
		target = null;
		watch = null;

	}
	
}