package components.weapon;

/**
 * ...
 * @author ...
 */
class Weapon
{
	public var name:String;
	public var range:Float;
	public var damage:Int;
	//public var  

	public function new() 
	{
		
	}
	
	public function init(name:String, range:Float, damage:Int):Weapon {
		this.name = name;
		this.range = range;
		this.damage = damage;
		return this;
	}
	
}