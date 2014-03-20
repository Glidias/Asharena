package arena.components.char;
import arena.components.weapon.Weapon;
import arena.components.weapon.WeaponState;
import components.Ellipsoid;
import components.Pos;
import components.Rot;
import util.geom.PMath;

/**
 * Hit formulas to determine combat results
 * @author Glidias
 */
class HitFormulas
{
	
	public static inline var ROT_FACING_OFFSET:Float = ( -1.5707963267948966);

	public static inline function getPercChanceToHitDefender(posA:Pos, ellipsoidA:Ellipsoid, weaponA:Weapon, posB:Pos, rotB:Rot, defB:CharDefense, ellipsoidB:Ellipsoid):Float {
		var facinPerc:Float ;
		var basePerc:Float = facinPerc=calculateFacingPerc(posA, posB, rotB, defB); 
		var dx:Float = posB.x - posA.x;
		var dy:Float = posB.y - posA.y;
		var d:Float = Math.sqrt(dx * dx + dy * dy) - ellipsoidB.x; // we assume x and y is the same!
		
		//if (facinPerc >60) {
			//	calculateOptimalRangeFactor(  1 - (time taken to hit between at range)/1 between 100%  - 30%
			
			// Detemine overall time taken  for weapon to strike target in seconds, according to range to target
			var rangeFactor:Float =  calculateOptimalRangeFactor(weaponA.minRange, weaponA.range, d);
			var totalTimeToHit:Float = PMath.lerp(weaponA.strikeTimeAtMinRange, weaponA.strikeTimeAtMaxRange, rangeFactor);// weaponA.timeToSwing+ rangeFactor * (weaponA.strikeTimeAtMaxRange - weaponA.strikeTimeAtMinRange); 
			var totalTimeToHitInSec:Float = totalTimeToHit;
			if (totalTimeToHitInSec > 1) totalTimeToHitInSec = 1;
			
			totalTimeToHit = 1 - calculateOptimalRangeFactor( 0, 1, totalTimeToHit);
	
		
			totalTimeToHit = PMath.lerp(.3, 1, totalTimeToHit);
			if (facinPerc <= 67) basePerc *= totalTimeToHit;   // Based off ~ frontal aspect of character
			
			//Enemy's /Block/Evade factor , if facing in a direction where he can react, determine how fast/effective he can evade/block the blow in time to cushion any possible impact. Based off ~ peripherical vision of character
			if  (facinPerc <= 90 )basePerc *=  PMath.lerp( 1, .1, defB.evasion*totalTimeToHitInSec);
		//}
		
		return basePerc;
	}
	
	public static inline function getPercChanceToCritDefender(posA:Pos, ellipsoidA:Ellipsoid, weaponA:Weapon, posB:Pos, rotB:Rot, defB:CharDefense, ellipsoidB:Ellipsoid):Float {

		var basePerc:Float =  calculateFacingPerc(posA, posB, rotB, defB); 
		var dx:Float = posB.x - posA.x;
		var dy:Float = posB.y - posA.y;
		var d:Float = Math.sqrt(dx * dx + dy * dy) - ellipsoidB.x; // we assume x and y is the same!
	
		// Detemine best range to crit for given weapon
		var  critOptimalRangeFactor:Float = calculateOptimalRangeFactorMidpoint(ellipsoidA.x, weaponA.range, weaponA.critMinRange, weaponA.critMaxRange, d); 
		basePerc *= PMath.lerp( .3, 1, critOptimalRangeFactor);

		return basePerc;
	}
	
	// TODO: Non passive cases once EnemyAggro can strike back with Weapon!
	
	public static inline function getPercChanceToHitAttacker(posA:Pos, defA:CharDefense, ellipsoidA:Ellipsoid, weaponA:Weapon,  posB:Pos, rotB:Rot, defB:CharDefense, ellipsoidB:Ellipsoid, weaponB:Weapon, weaponBState:WeaponState):Float {
		return 0;
	}
	
		public static inline function getPercChanceToCritAttacker(posA:Pos, defA:CharDefense, ellipsoidA:Ellipsoid, weaponA:Weapon, posB:Pos, rotB:Rot, defB:CharDefense, ellipsoidB:Ellipsoid, weaponB:Weapon, weaponBState:WeaponState):Float {
		return 0;
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
	
	public static inline function rollDamageForWeapon(weapon:Weapon):Int {
		return Math.round(weapon.damage + Math.random()*weapon.damageRange);
	}
	
	
	
}