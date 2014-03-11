package components.weapon;

/**
 * Unique weapon state per entity.
 * @author ...
 */
class WeaponState
{
	public var cooldown:Float; // recovery before attempting next attempt to strike  (A miss or strike.., cooldown intiated)
	public var attackTime:Float; //  time elapsed during attack
	
	public function new() 
	{
		
	}
	
	public function init():WeaponState {
		init_i();
		return this;
	}
	
	public inline function init_i():Void {
		cooldown = 0;
		attackTime = 0;
		
	}
	
}