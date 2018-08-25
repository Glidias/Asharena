/**
 * Jump component to handle typical jumping behaviour in games. 
 * @author Glenn Ko
 */

package components;
import util.geom.Vec3;


class Jump 
{
	// State Settings
	public var JUMP_COOLDOWN:Float;
	
	// State for thing
	private var jump_timer:Float;
    private var jump_speed:Float;
	public var enabled:Bool;  // use this as a master lock to enable/disable jump depending on situation
	
	public static inline var EPSILON:Float = 0.00001;
	
	
	
	public function new(timeCooldown:Float, jumpSpeed:Float) 
	{
		JUMP_COOLDOWN = timeCooldown;
		jump_speed = jumpSpeed;
		jump_timer = 0;
		enabled = true;
	}
	
	inline public function update(time:Float ):Void {
		jump_timer = jump_timer-time < 0 ? 0 : jump_timer - time;
	}
	 
	
	inline public function attemptJump(velocity:Vec3, time:Float):Bool {
		var result:Bool = enabled && this.jump_timer <= 0;
		if (result)
		{
				
			velocity.z += jump_speed * .04;
			jump_timer = JUMP_COOLDOWN;     
			
		}
		return result;
	}
	
	inline public function attemptJumpY(velocity:Vec3, time:Float):Bool {
		var result:Bool = enabled && this.jump_timer <= 0;
		if (result)
		{
				
			velocity.y += jump_speed;
			jump_timer = JUMP_COOLDOWN;     
			
		}
		return result;
	}

}