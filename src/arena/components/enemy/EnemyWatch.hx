package arena.components.enemy;
import arena.systems.player.PlayerAggroNode;
import ash.core.Entity;
import components.Ellipsoid;

/**
 *  Component state for watchful enemies
 * @author ...
 */
class EnemyWatch
{
	public var target:PlayerAggroNode; 
	public var watchSettings:EnemyIdle;

	public function new() 
	{
		
	}
	
	public function init(settings:EnemyIdle, target:PlayerAggroNode):EnemyWatch {
		//target = null;
		settings = watchSettings;
		this.target = target;
		return this;
	}
	
	public inline function dispose():Void {
		target = null;
		watchSettings = null;
	}
	
}