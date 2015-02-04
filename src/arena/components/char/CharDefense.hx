package arena.components.char;
import util.geom.PMath;

/**
 * Character defense ratings
 * @author ...
 */
class CharDefense
{
	/*
	 * 	- fixed 8 sides octagon armor-covering percentages (inverse of percentage is weakenesses, exposed parts)
-OR/AND-
	(( Protection list (sets of Protection: 2d arc of protection, total bodily protection, base dmg reduction) ))
	// base chance of critical hti : 2D Arc of protection percentage coverage against enemy's attack trigger cone * lack of total bodily protection
	//damage reduction due to hitting 1 piece of armor for non-critical hit= 2D Arc of protection percentage coverage against enemy's attack trigger cone * base dmg reduction;
	- (advanced) base dmg reduction could vary according to differnet types of weapon
	
	// base values
	Blocking rating  (based off whether got shield or some good means to block blows)
	Evasion rating  (based off speed/manuevability of character )
	(( PArry rating = weapon parry rating * character's parrying ability?))  <- can just use weapon directly instead
	
	Frontal alert arc (from/to angle, presence of shield can affect this assymetrically)
	*/
	
	public var block:Float;
	public var evasion:Float;
	//public var parry:Float;
	
	public var frontalArc:Float;  // the arc for both directions, leftwards and rightwards from forward vector
	// leftArcAdd, rightArcAdd  // this can be included in later to factor in presence of shields on left/right hand side of body
	
	public static inline var BACKSIDE_ARC:Float = 75 * PMath.DEG_RAD;  // the backside arc which is considered a backstab
	
	public var critDamageMult:Float;

	public function new() 
	{
		
	}
	
	public  function init(block:Float, evasion:Float, frontalArc:Float, critDamageMult:Float = 1.5):CharDefense {
		init_i(block , evasion, frontalArc, critDamageMult);
		
		return this;
	}
	
	public  inline function init_i(block:Float, evasion:Float, frontalArc:Float, critDamageMult:Float = 1.5):Void {
		this.block = block;
		this.evasion = evasion;
		this.frontalArc = frontalArc;
		this.critDamageMult = critDamageMult;
	}
	
}