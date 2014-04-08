package arena.components.weapon;
import ash.signals.Signal0;
import ash.signals.Signal2;
import components.Health;

/**
 * Base weapon stats. SHarable component between entities.
 * @author ...
 */
class Weapon
{
	public var name:String;
	public var range:Float;
	public var damage:Int;  // min damage applied
	public var cooldownTime:Float;
	public var hitAngle:Float;
	
	// advanced Arena properties below
	public var damageRange:Int;		// damage up-range variance

	public var minRange:Float;
	
	
	public var critMinRange:Float;
	public var critMaxRange:Float;
	
	// timings cannot be a non-zero value! For weapons like guns and crossbows, use tiny floating point values to simulate time taken to pull the trigger/strike the firing pin, etc..
	public var timeToSwing:Float;
	public var strikeTimeAtMaxRange:Float;  
	public var strikeTimeAtMinRange:Float;
	
	public var parryEffect:Float;
	
	public var stunEffect:Float;
	public var stunMinRange:Float;
	public var stunMaxRange:Float;
	
	public var anim_startSwingTime:Float;
	public var anim_strikeTimeAtMaxRange:Float;
	public var anim_strikeTimeAtMinRange:Float;
	public var anim_minRange:Float;
	public var anim_maxRange:Float;
	
	public var anim_fullSwingTime:Float;

	
	public inline function matchAnimVarsWithStats():Void {
		anim_startSwingTime = timeToSwing;
		anim_strikeTimeAtMaxRange = strikeTimeAtMaxRange;
		anim_strikeTimeAtMinRange = strikeTimeAtMinRange;
		anim_minRange = minRange;
		anim_maxRange = range;
	}
	
	//public var  

	public function new() 
	{
		
	}
	
	public function init(name:String, range:Float, damage:Int, cooldownTime:Float, hitAngle:Float):Weapon {
		this.name = name;
		this.range = range;
		this.damage = damage;
		this.hitAngle = hitAngle;
		this.cooldownTime = cooldownTime;
		return this;
	}

}