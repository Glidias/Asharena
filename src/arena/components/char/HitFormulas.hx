package arena.components.char;
import arena.components.enemy.EnemyAggro;
import arena.components.weapon.Weapon;
import arena.components.weapon.WeaponState;
import arena.systems.player.IStance;
import ash.core.Entity;
import components.Ellipsoid;
import components.Health;
import components.Pos;
import components.Rot;
import components.Vel;
import haxe.Log;
import util.geom.Vec3Utils;
import util.TypeDefs;
import util.geom.PMath;

/**
 * Hit formulas to determine combat results
 * @author Glidias
 */
class HitFormulas
{
	
	public static inline var ROT_FACING_OFFSET:Float = ( -1.5707963267948966);
	
	// this should factor out to Defense rating as well..which is dpeending on the type of shiled/weapon combo u r using. 
	// It basically describes whether you can block WHILE swinging your weapon at the same time. Without a shield or blocking mechanism, this value should be zero.
	static public inline var CAN_BLOCK_THRESHOLD:Float = .35; 

	
	
	public static inline function targetIsWithinArcAndRangeSq2(diffAngle:Float, arcAng:Float, sqDist:Float, rangeSq:Float):Bool {  // TODO: Depeciate

		return sqDist <= rangeSq && diffAngle <= arcAng;
		
	}
	
	public static inline function targetIsWithinFOV(posA:Pos, rotA:Rot, posB:Pos, fov:Float):Bool { // this doesn't take into account size of target, but should be okay in most cases...
		
		return targetIsWithinFOV2( posB.x - posA.x, posB.y - posA.y, rotA, fov);
	}
	
	
	public static inline function targetIsWithinFOV2(dx:Float, dy:Float, rotA:Rot, fov:Float):Bool { // this doesn't take into account size of target, but should be okay in most cases...
		return PMath.abs(getDiffAngle(rotA.z, Math.atan2(dy, dx)+ROT_FACING_OFFSET ) ) <= fov*.5;
	}
	
	
	public static inline function targetIsWithinArcAndRangeSq(posA:Pos, rotA:Rot, posB:Pos, rangeSq:Float, arcAng:Float):Bool { // TODO: Convert to 3D
		var dx:Float = posB.x - posA.x;
		var dy:Float = posB.y - posA.y;
		var dz:Float = posB.z - posA.z;
		var withinRange:Bool = dx * dx + dy * dy  + dz*dz <= rangeSq;
		
		var withinAng:Bool = PMath.abs(getDiffAngle(rotA.z, Math.atan2(dy, dx)+ROT_FACING_OFFSET ) ) <= arcAng;
		
		return withinRange && withinAng;
		
	}
	
	public static inline function get3DDist(posA:Pos,  posB:Pos, ellipsoidB:Ellipsoid):Float {	
		var dx:Float = posB.x - posA.x;
		var dy:Float = posB.y - posA.y;
		var dz:Float = posB.z - posA.z;
		var d:Float = Math.sqrt(dx * dx + dy * dy + dz * dz);
		var dm:Float = 1 / d;
		
		return d - PMath.abs(dx*dm*ellipsoidB.x + dy*dm*ellipsoidB.y + dz*dm*ellipsoidB.z);
	}
	
	public static inline function get3DDistOffseted(posA:Pos,  posB:Pos, ellipsoidB:Ellipsoid, ox:Float, oy:Float, oz:Float ):Float {	
		
		var dx:Float = posB.x - posA.x;
		var dy:Float = posB.y - posA.y;
		var dz:Float = posB.z - posA.z;
		var d:Float = Math.sqrt(dx * dx + dy * dy + dz * dz);
		var dm:Float = 1 / d;
		
		return d - PMath.abs(dx*dm*ellipsoidB.x + dy*dm*ellipsoidB.y + dz*dm*ellipsoidB.z);
	}

	// Used for actual combat..
	public static inline function getPercChanceToHitDefender(posA:Pos, ellipsoidA:Ellipsoid, weaponA:Weapon, posB:Pos, rotB:Rot, defB:CharDefense, ellipsoidB:Ellipsoid, defense:Float=0, timeToHitOffset:Float=0):Float {
		var facinPerc:Float ;
		var facingNotRequired:Bool = defense < 0;
		defense = facingNotRequired ? -defense : defense;
		
		var basePerc:Float = facinPerc = calculateFacingPerc(posA, posB, rotB, defB); 
		basePerc  = 75 + ((facinPerc - 60)*0.01)*25;  // renoramlzie to diff range
		//basePerc = 100;
		var dx:Float = posB.x - posA.x;
		var dy:Float = posB.y - posA.y;
		var dz:Float = posB.z  - posA.z;
		var d:Float = Math.sqrt(dx * dx + dy * dy + dz * dz); // we assume x and y is the same!
		var dm:Float = 1 / d;
		d -=   PMath.abs(dx*dm*ellipsoidB.x + dy*dm*ellipsoidB.y + dz*dm*ellipsoidB.z);

		
		//if (facinPerc >60) {
			//	calculateOptimalRangeFactor(  1 - (time taken to hit between at range)/1 between 100%  - 30%
			
			// Detemine overall time taken  for weapon to strike target in seconds, according to range to target
			var rangeFactor:Float =  calculateOptimalRangeFactor(weaponA.minRange, weaponA.range, d);
			var totalTimeToHit:Float = weaponA.fireMode <= 0 ? (d > weaponA.muzzleLength ? d : weaponA.muzzleLength) / weaponA.muzzleVelocity + weaponA.timeToSwing : PMath.lerp(weaponA.strikeTimeAtMinRange, weaponA.strikeTimeAtMaxRange, rangeFactor) - timeToHitOffset;// weaponA.timeToSwing+ rangeFactor * (weaponA.strikeTimeAtMaxRange - weaponA.strikeTimeAtMinRange); 
			var totalTimeToHitInSec:Float = totalTimeToHit;
			
			//
			
			if (totalTimeToHitInSec > 1 ) totalTimeToHitInSec = 1; //|| weaponA.fireMode<=0
		
			/*
			if (weaponA.fireMode <= 0) {
				if (totalTimeToHitInSec < .3) totalTimeToHitInSec = .2;
				totalTimeToHitInSec += defB.block * .5 * .2;
			}
			*/
			//totalTimeToHitInSec
		
			
			totalTimeToHit = 1 - calculateOptimalRangeFactor( 0, 1, totalTimeToHit);
	
		
			totalTimeToHit = PMath.lerp(.3, 1, totalTimeToHit);
		//	if (facinPerc < 67) basePerc *= totalTimeToHit;   // Based off ~ frontal aspect of character
			
			//Enemy's /Block/Evade factor , if facing in a direction where he can react, determine how fast/effective he can evade/block the blow in time to cushion any possible impact. Based off ~ peripherical vision of character
			
				if  (facinPerc <= 90 || facingNotRequired ) {
		basePerc *=  PMath.lerp( 1, .1, (defense != 0 ? defense : defB.evasion > defB.block ? defB.evasion : defB.block) * totalTimeToHitInSec);
				}
		
		
		return basePerc;
	}
	
	public static inline function getPercChanceToRangeHitDefender(posA:Pos, ellipsoidA:Ellipsoid, weaponA:Weapon, posB:Pos, rotB:Rot, defB:CharDefense, ellipsoidB:Ellipsoid, defense:Float=0, timeToHitOffset:Float=0):Float {
		
		var prob:Float = getPercChanceToHitDefender(posA, ellipsoidA, weaponA, posB, rotB, defB, ellipsoidB, defense, timeToHitOffset) / 100;
		//return prob;
		 prob *= prob > 0 ? getChanceToRangeHitWithinCone(posA, weaponA, posB, ellipsoidB) : 1;
		 // provide block bonus if crouched and with at least 256 units of 2D space apart. Defense !=0
		 if ( defense > 0 && Vec3Utils.sqDist2DBetween(posA, posB) >= CROUCH_EFFECT_RANGE_SQ ) {
			 prob *= .7;
		 }
		return Math.ceil(prob * 100);
		
	}
	
	private static inline var CROUCH_EFFECT_RANGE_SQ:Float = 256 * 256;
	
	public static function getPercChanceToHitDefenderMethod(weapon:Weapon):Pos->Ellipsoid->Weapon->Pos->Rot->CharDefense-> Ellipsoid->Float->Float->Float {
		return weapon.fireMode <= 0 ? getPercChanceToRangeHitDefender : getPercChanceToHitDefender;
		
	}
	
	
	
	
	// Used for actual combat...
	public static inline function getPercChanceToCritDefender(posA:Pos, ellipsoidA:Ellipsoid, weaponA:Weapon, posB:Pos, rotB:Rot, defB:CharDefense, ellipsoidB:Ellipsoid):Float {

		var basePerc:Float =  calculateFacingPerc(posA, posB, rotB, defB); 
		var dx:Float = posB.x - posA.x;
		var dy:Float = posB.y - posA.y;
		var dz:Float = posB.z - posA.z;
		var d:Float = Math.sqrt(dx * dx + dy * dy + dz*dz); // we assume x and y is the same!
		var dm:Float = 1 / d;
		d -= PMath.abs(dx * dm * ellipsoidB.x + dy * dm * ellipsoidB.y + dz * dm * ellipsoidB.z);
		// Detemine best range to crit for given weapon
		var  critOptimalRangeFactor:Float = calculateOptimalRangeFactorMidpoint(ellipsoidA.x, weaponA.range, weaponA.critMinRange, weaponA.critMaxRange, d); 
		basePerc *= PMath.lerp( .3, 1, critOptimalRangeFactor);

		return basePerc;
	}
	

	
	
	
	
	// a prediction only...not an actual roll against. Doesn't count critical strikes, only regular hits.
	public static inline function getPercChanceForHitToKillDefender(posA:Pos, ellipsoidA:Ellipsoid, weaponA:Weapon, posB:Pos, rotB:Rot, defB:CharDefense, ellipsoidB:Ellipsoid, healthB:Health, defense:Float=0):Float {
		var toDie:Float = calculateOptimalRangeFactor( weaponA.damage , weaponA.damage + weaponA.damageRange, healthB.hp);
		toDie = 1 - toDie;
		
		var perc:Float = toDie != 0 ?  getPercChanceToHitDefender(posA, ellipsoidA, weaponA, posB, rotB, defB, ellipsoidB, defense) : 0;
		perc *= toDie;
	
		return perc;
	}
	
	public static inline function getUnionProbabilityExclusive(vec:Vector<Float>, len:Int = 0):Float {
		if (len == 0) len  = vec.length;
		var remainingProb:Float = 1;
		var result:Float = 0;
		for (i in 0...len) {
			result = vec[i] * remainingProb;
			remainingProb -= result;
		}
		return result;
	}
	
	public static inline function getChanceToRangeHitWithinCone(posA:Pos, weaponA:Weapon, posB:Pos, ellipsoidB:Ellipsoid):Float {
		
		var dx:Float = posB.x - posA.x;
		var dy:Float = posB.y - posA.y;
		var dz:Float = posB.z - posA.z;
		var dist:Float =  Math.sqrt(dx * dx + dy * dy + dz * dz) ;
	//	weaponA.deviation = 99999999;
		// naive squuare difference
		dist = HitFormulas.getDeviationForRange(dist, ellipsoidB.x);
		dist = dist  / weaponA.deviation;
		
		dist = dist > 1 ? 1 : dist < 0 ? 0 : dist;
		return dist;
	}
	
	public static inline function getRangeForDeviation(deviation:Float, size:Float):Float {
		return size / deviation;
	}
	
	
	
	public static inline function getDeviationForRange(range:Float, size:Float):Float {
		//range = size/deviation
		return size / range;
	}
	
	
	
	// TODO: factor in z value for 3D

	/**
	 * Used for actual combat...against attacking enemies
	 *	If returned value is higher than zero, it means the attacker will strike you first before you can strike him. So, he'll roll attempt hit against you first according
	 * to this percentage, before you can roll against him (as per normal against defender).
	 */
	public static inline function getPercChanceToBeHitByAttacker(posA:Pos, rotA:Rot, defA:CharDefense, ellipsoidA:Ellipsoid, weaponA:Weapon,  posB:Pos, rotB:Rot,  ellipsoidB:Ellipsoid, weaponB:Weapon, weaponBState:WeaponState):Float {
		// determine who will strike faster
		var dx:Float = posB.x - posA.x;
		var dy:Float = posB.y - posA.y;
		var dz:Float = posB.z - posA.z;
		var sqDist:Float =  Math.sqrt(dx * dx + dy * dy + dz * dz) ;
		var dm:Float = 1 / sqDist;
		var d:Float = sqDist - PMath.abs(dx * dm * ellipsoidB.x + dy * dm * ellipsoidB.y + dz * dm * ellipsoidB.z); // we assume x and y is the same!
		
		
		var timeFactor:Float;  
		var totalTimeToHit:Float;
		var totalTimeToHit2:Float;
	
		totalTimeToHit  = calculateStrikeTimeAtRange(weaponA, d);
		
		d = sqDist - dx * dm * ellipsoidA.x + dy * dm * ellipsoidA.y + dz * dm * ellipsoidA.z;
		totalTimeToHit2 = calculateStrikeTimeAtRange(weaponB, d) - weaponBState.attackTime;
		
		if (totalTimeToHit2 > totalTimeToHit) {  // enemy strikes first, will he hit you?
			timeFactor = totalTimeToHit2 < weaponA.timeToSwing ? 0 : calculateOptimalRangeFactor(weaponA.timeToSwing, weaponA.strikeTimeAtMaxRange, totalTimeToHit2) < CAN_BLOCK_THRESHOLD ? defA.block : weaponA.parryEffect;
			
			
			weaponBState.forceCooldown(weaponB.cooldownTime);
			
			return  getPercChanceToHitDefender(posB, ellipsoidB, weaponB, posA, rotA, defA, ellipsoidA, timeFactor);
			
		}
		else {  // you will strike first, so no worries
			return 0;
		}
	}
	

	
	

	/**
	 * Used for actual combat.....against attacking enemies
	 *	This is the roll against slower attacker,  assuming you will strike first.
	 */
		public static inline function getPercChanceToHitSlowerAttacker(posA:Pos, rotA:Rot, ellipsoidA:Ellipsoid, weaponA:Weapon, posB:Pos, rotB:Rot, defB:CharDefense, ellipsoidB:Ellipsoid, weaponB:Weapon, weaponBState:WeaponState):Float {
			
		var dx:Float = posB.x - posA.x;
		var dy:Float = posB.y - posA.y;
		var dz:Float = posB.z - posA.z;
	
		var d:Float;
		d =  Math.sqrt(dx * dx + dy * dy + dz * dz);
		var dm:Float = 1 / d;
		d -= PMath.abs(dx * dm * ellipsoidA.x + dy * dm * ellipsoidA.y + dz * dm * ellipsoidA.z); // ellipsoidA.x;
		
		var totalTimeToHit2:Float = calculateStrikeTimeAtRange(weaponB, d) - weaponBState.attackTime;
		
			// determine if attacker is going to evade, block or parry, because you will strike  first
			// for 0 timefactor case, enemy would cancel his attack...
			d = weaponBState.attackTime < weaponB.timeToSwing ? 0 : calculateOptimalRangeFactor(weaponB.timeToSwing, weaponB.strikeTimeAtMaxRange, totalTimeToHit2) < CAN_BLOCK_THRESHOLD ? defB.block : weaponB.parryEffect;
			
			weaponBState.forceCooldown(weaponB.cooldownTime);
			
			return getPercChanceToHitDefender(posA, ellipsoidA, weaponA, posB, rotB, defB, ellipsoidB, d);
		}
		
		// same as above but different method below
		public static inline function getPercChanceToRangeHitSlowerAttacker(posA:Pos, rotA:Rot, ellipsoidA:Ellipsoid, weaponA:Weapon, posB:Pos, rotB:Rot, defB:CharDefense, ellipsoidB:Ellipsoid, weaponB:Weapon, weaponBState:WeaponState):Float {
			
		var dx:Float = posB.x - posA.x;
		var dy:Float = posB.y - posA.y;
		var dz:Float = posB.z - posA.z;
	
		var d:Float;
		d =  Math.sqrt(dx * dx + dy * dy + dz * dz);
		var dm:Float = 1 / d;
		d -= PMath.abs(dx * dm * ellipsoidA.x + dy * dm * ellipsoidA.y + dz * dm * ellipsoidA.z); // ellipsoidA.x;
		
		var totalTimeToHit2:Float = calculateStrikeTimeAtRange(weaponB, d) - weaponBState.attackTime;
		
			// determine if attacker is going to evade, block or parry, because you will strike  first
			// for 0 timefactor case, enemy would cancel his attack...
			d = weaponBState.attackTime < weaponB.timeToSwing ? 0 : calculateOptimalRangeFactor(weaponB.timeToSwing, weaponB.strikeTimeAtMaxRange, totalTimeToHit2) < CAN_BLOCK_THRESHOLD ? defB.block : weaponB.parryEffect;
			
			weaponBState.forceCooldown(weaponB.cooldownTime);
			
			return getPercChanceToRangeHitDefender(posA, ellipsoidA, weaponA, posB, rotB, defB, ellipsoidB, d);
		}
		
		public static function getPercChanceToHitSlowerAttackerMethod(weaponCheck:Weapon):Pos->Rot->Ellipsoid->Weapon->Pos->Rot->CharDefense->Ellipsoid->Weapon->WeaponState->Float {
			return weaponCheck.fireMode < 0 ? getPercChanceToRangeHitSlowerAttacker : getPercChanceToHitSlowerAttacker;
		}
		
		
	
	/*
	 * Used as a predictor.
	 * If you strike triggered aggro first, aggro will revenge attack. You either pick evade or block in response to his revenge attack, depending on which is higher rating. 
	So, this attack runs as per normal as if you were defending.

	If triggered aggro strikes you first, you either pick evade, block or parry against him, according to timing of his strike. Your return attack occurs as per normal, with the 
	aggro being able to choose between evade or block according to his preference.
	*/
	public static inline function getPercChanceToHitAttacker(posA:Pos, rotA:Rot, defA:CharDefense, ellipsoidA:Ellipsoid, weaponA:Weapon, healthA:Health,  posB:Pos, rotB:Rot, defB:CharDefense, ellipsoidB:Ellipsoid, weaponB:Weapon, weaponBState:WeaponState):Float {
		// determine who will strike faster
		var dx:Float = posB.x - posA.x;
		var dy:Float = posB.y - posA.y;
		var dz:Float = posB.z - posA.z;
		var sqDist:Float =  Math.sqrt(dx * dx + dy * dy + dz*dz) ;
		var dm:Float = 1 / sqDist;
		var d:Float = sqDist - PMath.abs(dx * dm * ellipsoidB.x + dy * dm * ellipsoidB.y + dz * dm * ellipsoidB.z); // we assume x and y is the same!
		
		var timeFactor:Float;  
		var totalTimeToHit:Float;
		var totalTimeToHit2:Float;
	
		totalTimeToHit  = calculateStrikeTimeAtRange(weaponA, d);
		
		d = sqDist -ellipsoidA.x;
		totalTimeToHit2 = calculateStrikeTimeAtRange(weaponB, d) - weaponBState.attackTime;
		
		if (totalTimeToHit2 > totalTimeToHit) {  // in most cases, if both guys have the same weapon, this would occur, attacker would hit you first because you intiaited the attack later than him, so you have to defend his blow first (by either evading/blocking/parrying) before attacking him back. Time factor affects whether you evade/block/parry accordingly.
			
			timeFactor = totalTimeToHit2 < weaponA.timeToSwing ? 0 : calculateOptimalRangeFactor(weaponA.timeToSwing, weaponA.strikeTimeAtMaxRange, totalTimeToHit2) < CAN_BLOCK_THRESHOLD ? defA.block : weaponA.parryEffect;
			var prematurelyKilledFactor:Float = getPercChanceForHitToKillDefender(posB, ellipsoidB, weaponB, posA, rotA, defA, ellipsoidA, healthA, timeFactor) / 100;
			
			return getPercChanceToHitDefender(posA, ellipsoidA, weaponA, posB, rotB, defB, ellipsoidB, 0) * prematurelyKilledFactor;
			
		}
		else {
			// determine if attacker is going to evade, block or parry, because you will strike  first
			// for 0 timefactor case, enemy would cancel his attack...and might retaliate similar to getPercChanceToHitdefender
			timeFactor = weaponBState.attackTime < weaponB.timeToSwing ? 0 : calculateOptimalRangeFactor(weaponB.timeToSwing, weaponB.strikeTimeAtMaxRange, totalTimeToHit2) < CAN_BLOCK_THRESHOLD ? defB.block : weaponB.parryEffect;
return getPercChanceToHitDefender(posA, ellipsoidA, weaponA, posB, rotB, defB, ellipsoidB, timeFactor);
		}
		
	
	}
	
	// Used as a predictor.
		public static inline function getPercChanceToCritAttacker(posA:Pos, rotA:Rot, defA:CharDefense, ellipsoidA:Ellipsoid, weaponA:Weapon, posB:Pos, rotB:Rot, defB:CharDefense, ellipsoidB:Ellipsoid, weaponB:Weapon, weaponBState:WeaponState):Float {
			// determine who will strike faster
		var dx:Float = posB.x - posA.x;
		var dy:Float = posB.y - posA.y;
		var dz:Float = posB.z - posA.z;
		var sqDist:Float =  Math.sqrt(dx * dx + dy * dy + dz * dz) ;
		var dm:Float = 1 / sqDist;
		var d:Float = sqDist - PMath.abs(dx * dm * ellipsoidB.x + dy * dm * ellipsoidB.y + dz * dm * ellipsoidB.z); // we assume x and y is the same!
		
		var totalTimeToHit:Float;
		var totalTimeToHit2:Float;
	
		totalTimeToHit  = calculateStrikeTimeAtRange(weaponA, d);
		
		d = sqDist -ellipsoidA.x;
		totalTimeToHit2 = calculateStrikeTimeAtRange(weaponB, d) - weaponBState.attackTime;
			
		var chanceToCritPerc:Float = getPercChanceToCritDefender(posA, ellipsoidA, weaponA, posB, rotB, defB, ellipsoidB);
	
		if (totalTimeToHit2 > totalTimeToHit) { // because you wouldn't strike faster than him, yr chance to crit is lessened, since he might hit you first
			d = totalTimeToHit2 < weaponA.timeToSwing ? 0 : calculateOptimalRangeFactor(weaponA.timeToSwing, weaponA.strikeTimeAtMaxRange, totalTimeToHit2) < CAN_BLOCK_THRESHOLD ? defA.block : weaponA.parryEffect;
			chanceToCritPerc *= getPercChanceToHitDefender(posB, ellipsoidB, weaponB, posA, rotA, defA, ellipsoidA, d,  weaponBState.attackTime)/100; //
		}
		
		return chanceToCritPerc;
	}
	
	public static inline function getPercChanceToRangeHitAttacker(posA:Pos, rotA:Rot, defA:CharDefense, ellipsoidA:Ellipsoid, weaponA:Weapon, healthA:Health,  posB:Pos, rotB:Rot, defB:CharDefense, ellipsoidB:Ellipsoid, weaponB:Weapon, weaponBState:WeaponState):Float {
		// determine who will strike faster
		var dx:Float = posB.x - posA.x;
		var dy:Float = posB.y - posA.y;
		var dz:Float = posB.z - posA.z;
		var sqDist:Float =  Math.sqrt(dx * dx + dy * dy + dz*dz) ;
		var dm:Float = 1 / sqDist;
		var d:Float = sqDist - PMath.abs(dx * dm * ellipsoidB.x + dy * dm * ellipsoidB.y + dz * dm * ellipsoidB.z); // we assume x and y is the same!
		
		var timeFactor:Float;  
		var totalTimeToHit:Float;
		var totalTimeToHit2:Float;
	
		totalTimeToHit  = calculateStrikeTimeAtRange(weaponA, d);
		
		d = sqDist -ellipsoidA.x;
		totalTimeToHit2 = calculateStrikeTimeAtRange(weaponB, d) - weaponBState.attackTime;
		
		if (totalTimeToHit2 > totalTimeToHit) {  // in most cases, if both guys have the same weapon, this would occur, attacker would hit you first because you intiaited the attack later than him, so you have to defend his blow first (by either evading/blocking/parrying) before attacking him back. Time factor affects whether you evade/block/parry accordingly.
			
			timeFactor = totalTimeToHit2 < weaponA.timeToSwing ? 0 :  defA.block;
			var prematurelyKilledFactor:Float =getPercChanceForHitToKillDefender(posB, ellipsoidB, weaponB, posA, rotA, defA, ellipsoidA, healthA, timeFactor)  / 100;
			
			return getPercChanceToRangeHitDefender(posA, ellipsoidA, weaponA, posB, rotB, defB, ellipsoidB, 0, 0) * prematurelyKilledFactor;
			
		}
		else {
			// determine if attacker is going to evade, block or parry, because you will strike  first
			// for 0 timefactor case, enemy would cancel his attack...and might retaliate similar to getPercChanceToHitdefender
			timeFactor = weaponBState.attackTime < weaponB.timeToSwing ? 0 : calculateOptimalRangeFactor(weaponB.timeToSwing, weaponB.strikeTimeAtMaxRange, totalTimeToHit2) < CAN_BLOCK_THRESHOLD ? defB.block : weaponB.parryEffect;
return getPercChanceToHitDefender(posA, ellipsoidA, weaponA, posB, rotB, defB, ellipsoidB, timeFactor);
		}
	}
	
	public static function getPercChanceToHitAttackerMethod(weapon:Weapon):Pos->Rot->CharDefense->Ellipsoid->Weapon->Health->Pos->Rot->CharDefense->Ellipsoid->Weapon->WeaponState->Float {
		return weapon.fireMode <= 0 ? getPercChanceToRangeHitAttacker : getPercChanceToHitAttacker;
		
	}
	
	
	
	// HELPERS:
	
	public static inline function calculateFacingPerc(posA:Pos, posB:Pos, rotB:Rot, defB:CharDefense):Float {
		var dx:Float = posA.x - posB.x;
		var dy:Float = posA.y - posB.y;
		var toPosAAngle:Float = Math.atan2(dy, dx) + ROT_FACING_OFFSET;
		toPosAAngle = PMath.abs( getDiffAngle(rotB.z, toPosAAngle) );
		
		toPosAAngle= PMath.lerp(60,100,  calculateOptimalRangeFactor(defB.frontalArc,   (PMath.PI - CharDefense.BACKSIDE_ARC), toPosAAngle ) );
		
		return toPosAAngle;
	}
	
	public static inline  function getDiffAngle(actualangle:Float, destangle:Float):Float {
		 var difference:Float = destangle - actualangle;
        if (difference < -PMath.PI) difference += PMath.PI2;
        if (difference > PMath.PI) difference -= PMath.PI2;
		//if (PMath.abs(difference) > PMath.PI) throw "SHOULD NOT BE!";
		return difference;

	}
	
	
	public static inline function calculateOptimalRangeFactor(minRange:Float, maxRange:Float, sampleRange:Float):Float {  // the nearer to maxRange ,the higher the ratio
		// find t 
		// sampleRange =  a + (b - a) * t;   // LERP
		//  sampleRange = (b - a) * t + a
		// sampleRange - a = (b - a) * t
		// (sampleRange - a)/ (b-a) = t;
		sampleRange = (sampleRange - minRange) / (maxRange - minRange);
		sampleRange = sampleRange < 0 ? 0 : sampleRange > 1 ? 1 : sampleRange;
		return sampleRange;
	}
	
	 // the nearer to midpoint ,the higher the ratio
	public static inline function calculateOptimalRangeFactorMidpoint(minRange:Float, maxRange:Float, sampleMinRange:Float, sampleMaxRange:Float, sampleRange:Float):Float {  // the nearer to maxRange ,the higher the ratio
		var midPt:Float = sampleMinRange + sampleMaxRange;
		midPt *= .5;
		if ( sampleRange ==  midPt ) sampleRange = 1
		else if (sampleRange < midPt) {
			sampleRange = calculateOptimalRangeFactor(minRange, midPt, sampleRange);
		}
		else {
			sampleRange = calculateOptimalRangeFactor(maxRange, midPt, sampleRange);
		}
		return sampleRange;
	}
	
	 // the nearer to sampleMax/MinRange band ,the higher the ratio. If within band, ratio is 1.
	public static inline function calculateOptimalRangeFactorMidRange(minRange:Float, maxRange:Float, sampleMinRange:Float, sampleMaxRange:Float, sampleRange:Float):Float { 
		
		if ( sampleRange >= sampleMinRange && sampleRange <= sampleMaxRange) sampleRange = 1
		else if (sampleRange < sampleMinRange) {
			sampleRange = calculateOptimalRangeFactor(minRange, sampleMinRange, sampleRange);
		}
		else {
			sampleRange = calculateOptimalRangeFactor(maxRange, sampleMaxRange, sampleRange);
		}
		
		return sampleRange;
	}
	
	// this is just an approximation, using the rough 2D width added to the range accordingly
	public static inline function rollRandomAttackRangeForWeapon(w:Weapon, targetSize:Ellipsoid):Float {
		var range:Float = w.critMaxRange + Math.random() * ( w.range - w.critMaxRange) ;
		 range= (range +22 < w.range) ? w.range - 22 : range;  // min 22 margin
		range += targetSize.x;
		return range;
	}
	
	public static inline function rollDamageForWeapon(weapon:Weapon):Int {
		return Math.round(weapon.damage + Math.random()*weapon.damageRange);
	}
	
	static public inline function calculateStrikeTimeAtRange(aWeapon:Weapon, actualDist:Float):Float
	{
		var result:Float;
		
		if (aWeapon.fireMode > 0) {
			result = PMath.lerp( aWeapon.strikeTimeAtMinRange, aWeapon.strikeTimeAtMaxRange, HitFormulas.calculateOptimalRangeFactor(aWeapon.minRange, aWeapon.range,  actualDist) );
		}
		else {
			result = aWeapon.strikeTimeAtMaxRange + actualDist / (aWeapon.projectileSpeed != 0 ? aWeapon.projectileSpeed : -1);
			if (result < 0) result = 0;
		}
		
		return result;
	}
	
	static public inline function calculateAnimStrikeTimeAtRange(aWeapon:Weapon, actualDist:Float):Float
	{
		return PMath.lerp( aWeapon.anim_strikeTimeAtMinRange, aWeapon.anim_strikeTimeAtMaxRange, HitFormulas.calculateOptimalRangeFactor(aWeapon.anim_minRange, aWeapon.anim_maxRange,  actualDist) );
	}
	
	static public inline function getDefenseForMovingStance(posA:Pos, posB:Pos, defB:CharDefense, stanceB:IStance, velB:Vel, ranged:Bool):Float 
	{
		return stanceB.movingSlow() ? defB.block * 2 : ranged ? getRangedEvasionRating(posA, posB, defB, velB, stanceB) : defB.evasion;
	}
	
	/*
	static  public function getDefenseForEntity(entA:Entity, entB:Entity):Float {
		return getDefenseForStance(entA.get(Pos), entB.get(Pos), entB.get(CharDefense), entB.get(IStance));
	}
	*/
	
	static public inline function getFullyDefensiveRating(def:CharDefense):Float {
		return def.block * 2 > def.evasion ? def.block * 2 : def.evasion;
	}
	
	static public function getRangedEvasionRating(posA:Pos, posB:Pos, defB:CharDefense, velB:Vel, stanceB:IStance):Float {
		var dx:Float = posB.x - posA.x;
		var dy:Float = posB.y - posA.y;
		var dz:Float = posB.z - posA.z;
		//stanceB.getJoggingSpeed() 
		var d:Float = 1 / Math.sqrt(dx * dx + dy * dy + dz * dz);
		dx *= d;
		dy *= d;
		dz *= d;
		
		var len:Float = velB.length();
		var d:Float = 1 / len;
		var vx:Float = velB.x * d;
		var vy:Float = velB.y * d;
		var vz:Float = velB.z * d;
		d = PMath.lerp( .5 * defB.evasion, 2 * defB.evasion, 1 - PMath.abs( vx * dx + vy * dy + vz * dz) );
		d *=  len / stanceB.getJoggingSpeed();

		return -d;
	}
	
	static public inline function fullyAggroing(ent:Entity):Bool
	{
		return ent.has(EnemyAggro) && ent.get(EnemyAggro).flag > 0;
	}
	
	
	
	
	
}