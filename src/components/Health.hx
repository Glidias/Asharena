package components;
import ash.signals.Signal1.Signal1;
import ash.signals.Signal2;

/**
 * A health component for player characters
 * @author Glenn Ko
 */
class Health
{
	public var maxHP:Int;
	public var minHP:Int;
	public var hp:Int;
	public var onDamaged:Signal2<Int,Int>;
	public var onMurdered:Signal2<Int,Int>;
	
	
	public function new() 
	{
		
	}
	
	public function init(amount:Int=100, max:Int=100, min:Int = -2147483647 ):Health {
		onDamaged = new Signal2<Int,Int>();
		onMurdered = new Signal2<Int,Int>();
		maxHP = max;
		minHP = min;
		hp = amount;
		return this;
	}
	
	
	/**
	 * Affects health by either increasing or decreasing HP, taking into account minimum health points only. 
	 * Using this can allow you to increase your hit points beyond the maximum amount. (eg. Quake2's Stimpack/Adrenaline)
	 * @param	amt	The amount of HP to reduce. Negative amounts will increase HP.
	 */
	public inline function damage(amt:Int):Void {
		hp -= amt;
		hp = hp < minHP ? minHP :  hp;
		( hp > 0 ? onDamaged : onMurdered).dispatch(hp,amt);	
	}
	
	/**
	 * Affects health by either increasing or decreasing HP, taking into account both minimum and maximum health points, though
	 * this is normally used for increasing HP due to the maximum HP cap.
	 * (eg. Quake2's Regular Medpack).
	 * @param	amt 	The amount of HP to reduce. Negative amounts will increase HP.
	 */
	public inline function damage2(amt:Int):Void {
		hp -= amt;
		hp = hp < minHP ? minHP : hp > maxHP ? maxHP : hp;
		( hp > 0 ? onDamaged : onMurdered).dispatch(hp,amt);	
	}
	
}