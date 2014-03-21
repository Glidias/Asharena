package arena.components.weapon;

/**
 * Unique weapon state per entity.
 * @author ...
 */
class WeaponState
{
	public var cooldown:Float; // recovery before attempting next attempt to strike  (A miss or strike.., cooldown intiated)
	public var attackTime:Float; //  time elapsed during attack
	public var trigger:Bool;
	
	public function new() 
	{
		
	}
	
	public inline function pullTrigger():Void {	// for triggering attack animation before hammer-time strike
		trigger = true;
		attackTime = 0;
		cooldown = 0;
	}
	
	public inline function cancelTrigger():Void {  // for attack animation cancelling, or force-resetting/unpulling the trigger
		trigger = false;
		attackTime = 0;
		cooldown = 0;
	}
	
	public function init():WeaponState {
		init_i();
		return this;
	}
	
	public inline function init_i():Void {
		cooldown = 0;
		attackTime = 0;
		trigger = false;
		
	}
	
	public function forceCooldown(val:Float) 
	{
		attackTime = 9999;
		cooldown = val;
	}
	

	
}