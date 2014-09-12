package arena.components.weapon;
import arena.components.weapon.Weapon;

/**
 * Unique weapon state per entity.
 * @author ...
 */
class WeaponState
{
	public var fireMode:Weapon;
	public var cooldown:Float; // recovery before attempting next attempt to strike  (A miss or strike.., cooldown intiated)
	public var attackTime:Float; //  time elapsed during attack
	public var trigger:Bool;
	public var randomDelay:Float;
	
	public function new() 
	{
		
	}
	
	public inline function pullTrigger(fireMode:Weapon):Void {	// for triggering attack animation before hammer-time strike
		trigger = true;
		attackTime = 0;
		cooldown = 0;
		this.fireMode = fireMode;
	}
	
	public inline function cancelTrigger():Void {  // for attack animation cancelling, or force-resetting/unpulling the trigger
		trigger = false;
		attackTime = 0;
		cooldown = 0;
		fireMode = null;
	}
	
	public function init():WeaponState {
		init_i();
		return this;
	}
	
	public inline function init_i():Void {
		cooldown = 0;
		attackTime = 0;
		trigger = false;
		fireMode = null;
		randomDelay =1;
		
	}
	
	public function forceCooldown(val:Float) 
	{
		attackTime = 9999;
		cooldown = val;
		
	}
	

	
}