package arena.components.enemy;
import arena.components.char.AggroMem;
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
	
	public var mem:AggroMem;
	
	public var exposureCount:Int;
	public var exposureCountdown:Float;
	
	// might be depeciaated?
	public var rotDirty:Bool;  // normally used if transitioning from EnemyAggro state
	
	public function new() 
	{
		
	}
	
	public function init(watch:EnemyIdle, target:PlayerAggroNode, rotDirty:Bool=false):EnemyWatch {
		//target = null;
		this.watch = watch;
		this.target = target;
		this.rotDirty = rotDirty;
		
		
		
		return this;
	}
	
	public inline function dispose():Void {
		target = null;
	
	}
	
}