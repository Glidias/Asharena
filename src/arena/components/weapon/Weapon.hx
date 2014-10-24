package arena.components.weapon;
import arena.systems.player.IStance;
import arena.systems.weapon.IProjectileDomain;
import arena.systems.weapon.ITimeChecker;
import ash.core.Entity;
import ash.signals.Signal0;
import ash.signals.Signal2;
import components.ActionUIntSignal;
import components.Ellipsoid;
import components.Health;
import components.Pos;

/**
 * Base weapon/weapon-attack-mode stats. Sharable component between entities. 
 * @author Glenn Ko
 */
class Weapon
{
	public var name:String;	// Label, can be  used as a primary key as well.
	public var id:String; // Identifier, can be used as a primary key as well. Good to look up animation names.
	
	public var range:Float;
	public var damage:Int;  // min damage applied
	public var cooldownTime:Float;
	public var hitAngle:Float;
	public var sideOffset:Float;
	public var heightOffset:Float;
	
	// advanced Arena properties below
	
	// Firemodes: Currently (might change), positive values indiciate melee attack modes. Zero or Negative values indicates ranged attack mode.
	// Each firemode denotes a unique firing animation
	public static inline var FIREMODE_THRUST:Int = 1;	 // thrusting motion
	public static inline var FIREMODE_SWING:Int = 2;	// swing (side) motion 
	public static inline var FIREMODE_STRIKE:Int = 3; 	 // strike (swing from top) chop motion
	public static inline var FIREMODE_RAY:Int = 0;		// ray hitscan shot (suitable for bullets and such..)
	public static inline var FIREMODE_TRAJECTORY:Int = -1;  // for thrown/launched projectiles with trajectory
	public static inline var FIREMODE_VELOCITY:Int = -2; 	// for velocity projectile weapons
	
	public var fireMode:Int;	// the firemode that the weapon uses
	public var nextFireMode:Weapon; // any next varying fire mode weapon to consider using
	
	public var fireModeLabel:String;
	
	public static inline var RANGEMODE_MELEE:Int = 0;
	public static inline var RANGEMODE_GUN:Int = 1;
	public static inline var RANGEMODE_BOW:Int = 2;
	
	public var rangeMode:Int;
	
	/*
	public static inline var AREA_EFFECT_IMPACT:Int = 0;	// dot or circular impact
	public static inline var AREA_EFFECT_ARC:Int = 1;	// for cleaving attack
	public var splashDamageRange:Float = 0;		// the range of spread
	public var splashDamageMultiplier:Float = 1;
	*/
	
	public var damageRange:Int;		// damage up-range variance

	public var minRange:Float;
	
	public var minPitch:Float;
	public var maxPitch:Float;
	
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
	
	public var anim_fullSwingTime:Float;  // or anim_cooldownTime for ranged
	
	public var deviation:Float;
	public var projectileSpeed:Float;
	public var projectileDomain:IProjectileDomain;
	
	public var muzzleVelocity:Float;
	public var muzzleLength:Float;
	
	

	
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
	
	public static inline function getPitchRatio(dx:Float, dy:Float, dz:Float, minPitch:Float, maxPitch:Float):Float {

		var sz:Float = Math.atan2(dz, Math.sqrt( dx * dx + dy * dy) );
		
		sz  = sz < minPitch ? minPitch : sz > maxPitch ? maxPitch : sz;
		return (sz-minPitch) / (maxPitch - minPitch);
	}
	
	
	
	public function init(name:String, range:Float, damage:Int, cooldownTime:Float, hitAngle:Float, sideOffset:Float=0, fireMode:Int=0, heightOffset:Float=0, deviation:Float=0, projectileSpeed:Float=0, minPitch:Float=0, maxPitch:Float=0):Weapon {
		this.name = name;
		this.range = range;
		this.damage = damage;
		this.hitAngle = hitAngle;
		this.cooldownTime = cooldownTime;
		this.sideOffset = sideOffset;
		this.fireMode = fireMode;
		this.heightOffset = heightOffset;
		this.deviation = deviation;
		this.projectileSpeed = projectileSpeed;
		this.minPitch = minPitch;
		this.maxPitch = maxPitch;
		this.muzzleVelocity = 512;
		this.muzzleLength = 40;
		this.rangeMode = 0;
		return this;
	}
	

	public static inline function shootWeapon(attackAction:UInt, attackerEntity:Entity, targetEntity:Entity, targetDamage:Int, timeChecker:ITimeChecker, isDynamic:Bool):Float {
		
		var weap:Weapon = attackerEntity.get(Weapon);
		var pos:Pos = attackerEntity.get(Pos);
		var targetPos:Pos = targetEntity.get(Pos);
		var time:Float = 0;
		var targetEllipsoid:Ellipsoid = targetEntity.get(Ellipsoid);
		
		if (weap.projectileDomain != null) {
			if ( !isDynamic ) {
				time = weap.projectileDomain.launchStaticProjectile(pos.x, pos.y, pos.z + weap.heightOffset, targetPos.x, targetPos.y, targetPos.z-targetEllipsoid.z, weap.projectileSpeed);
			}
			else {
				time = weap.projectileDomain.launchDynamicProjectile(pos.x, pos.y, pos.z + weap.heightOffset, targetPos, weap.projectileSpeed, attackerEntity, targetEntity, targetEllipsoid, targetDamage);
			}
		}
		
		
		var sig:ActionUIntSignal = attackerEntity.get(ActionUIntSignal);
		sig.forceSet(attackAction);
		
		
		timeChecker.checkTime(time);
		
		return time;
	}

}