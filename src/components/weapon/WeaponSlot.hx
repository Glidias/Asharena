package components.weapon;

import util.TypeDefs;
/**
 * ...
 * @author ...
 */
class WeaponSlot
{
	public var slots:Vector<Weapon>;

	public function new() 
	{
		
	}
	
	public function init(size:Int=0, fixed:Bool = false):WeaponSlot {
		#if (flash9 || flash9doc) 
			slots = new Vector<Weapon>(size, fixed);
		#else
			slots = new Vector<Weapon>();
			TypeDefs.setVectorLen(slots, size, fixed ? 1 : 0);
		#end
		return this;
	}
	
}