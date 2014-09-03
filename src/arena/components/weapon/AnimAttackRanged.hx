package arena.components.weapon;
import arena.systems.weapon.IProjectileDomain;
import ash.core.Entity;
import components.Ellipsoid;
import components.Health;
import components.Pos;

/**
 * @author Glidias
 */
class AnimAttackRanged
{
	public var curTime:Float;
	
	// precalculated position
	public var originX:Float;
	public var originY:Float;
	public var originZ:Float;
	
	// targeted end position at time of strike
	public var targetEntity:Entity;
	public var targetPos:Pos;
	public var targetOffsetX:Float;
	public var targetOffsetY:Float;
	public var targetOffsetZ:Float;
	public var targetEllipsoid:Ellipsoid;
	public var projectileSpeed:Float;
	public var damageDeal:Int;

	public var fixedStrikeTime:Float;
	public var domain:IProjectileDomain;
	
	public function new() 
	{
		
	}
	
	public inline function init_i(originX:Float, originY:Float, originZ:Float, targetEntity:Entity, targetPos:Pos, targetEllipsoid:Ellipsoid, fixedStrikeTime:Float, projectileSpeed:Float, domain:IProjectileDomain):Void {
		this.targetEllipsoid = targetEllipsoid;
		this.fixedStrikeTime = fixedStrikeTime;
		this.domain = domain;
		this.targetPos = targetPos;
		this.targetEntity = targetEntity;
		this.originZ = originZ;
		this.originY = originY;
		this.originX = originX;
		this.projectileSpeed = projectileSpeed;
		
		targetOffsetX = 0;
		targetOffsetY = 0;
		targetOffsetZ = 0;
	}
	
	
	
	public inline function dispose():Void {
		curTime = 0;
		fixedStrikeTime = 0;
		targetPos = null;
		targetEntity = null;
		
		domain = null;
	}
	
}