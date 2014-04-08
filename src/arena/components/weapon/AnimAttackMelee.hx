package arena.components.weapon;
import components.Ellipsoid;
import components.Health;
import components.Pos;

/**
 * ...
 * @author Glidias
 */
class AnimAttackMelee
{
	public var curTime:Float;
	
	public var targetPos:Pos;
	public var targetEllipsoid:Ellipsoid;
	public var targetHP:Health;
	public var damageDeal:Int;
	
	public var fixedStrikeTime:Float;
	
	public function new() 
	{
		
	}
	
	public inline function init_i(pos:Pos, targetEllipsoid:Ellipsoid, targetHP:Health, damageDeal:Int ):Void {
		curTime = 0;
		fixedStrikeTime = 0;
		this.targetPos = pos;
		this.targetEllipsoid = targetEllipsoid;
		this.targetHP = targetHP;
		this.damageDeal = damageDeal;
	}
	
	public inline function init_i_static(fixedStrikeTime:Float, targetHP:Health, damageDeal:Int ):Void {
		curTime = 0;
		this.fixedStrikeTime = fixedStrikeTime;
		this.targetPos = null;
		this.targetEllipsoid = null;
		this.targetHP = targetHP;
		this.damageDeal = damageDeal;
	}
	
	public inline function dispose():Void {
		curTime = 0;
		fixedStrikeTime = 0;
		targetPos = null;
		targetEllipsoid = null;
		targetHP = null;
	}
	
}