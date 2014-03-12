package arena.components.weapon;

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

	//public var attackMinRange:Float;
	public var attackMaxRange:Float;
	
	public var critMinRange:Float;
	public var critMaxRange:Float;
	
	public var timeToSwing:Float;
	public var strikeTimeAtMaxRange:Float;
	public var strikeTimeAtMinRange:Float;
	
	public var parryEffect:Float;
	
	public var stunEffect:Float;
	public var stunMinRange:Float;
	public var stunMaxRange:Float;
	
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