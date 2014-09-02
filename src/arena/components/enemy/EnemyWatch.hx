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
	public var rotDirty:Bool;  // normally used if transitioning from EnemyAggro state

	public var engaged:Bool;
	
	public function new() 
	{
		
	}
	
	public function init(watch:EnemyIdle, target:PlayerAggroNode, rotDirty:Bool=false, engaged:Bool=false):EnemyWatch {
		//target = null;
		this.watch = watch;
		this.target = target;
		this.rotDirty = rotDirty;
		this.engaged = engaged;
		return this;
	}
	
	public inline function dispose():Void {
		target = null;
	
	}
	
}