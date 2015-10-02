package arena.components.char;

/**
 * This class determines a character class's habits and interception fire+strikes aggro abilities for Blitz battle system. This can also be applied to other games that involve some form of reaction fire on AI-driven/static units.
 * 
 * @author Glenn Ko
 */
class AggroSpecs
{
	// -- OVERWATCH

	// Max Overwatch responses allowed per phase. Use -1 for infinity. Use 0 to disable overwatch.
	public var sentinel:Int;

	// Generic Aggro magnet rating. Determines the max amount of reserved aggro mutual closeness engagements he can receive from others and other aggro-related stuff. Use 0 for target to be ignored completely. Use -1 for infinite amount of aggro.
	public var aggro:Int;

	// Determine how many passes of mutual closeness engagement checks this character can reserve overwatch aim on
	public var engagePassChecks:Int;

	// Required number of valid exposure counts on a target before firing can commence while on Overwatch
	public var reqOverwatchExposures:Int;

	// Percentage of target body exposure to exceed in order be deemed a valid exposure for Overwatch and firing an overwatch shot
	public var reqOverExposurePerc:Float;

	// Required percentage chance to hit for an Overwatch shot during an exposure to determine whether to fire or not. Use 0 to disable this feature.
	public var reqPercChanceOverwatchHit:Float;

	// Accruacy penalty incured for Overwatch shots. Use 0 to not have any effect on the accruacy. Use a negative number for a fixed ratio reduction. Use a positive number for a ratio reduction by pencentage of the current accruacy.
	public var overwatchFireAccruacyPenalty:Float;
	
	// -- INTERCEPTION FIRE
	
	// Determines the amount of movement time reduced. A value of -1 will permanently remove whatever reversible movement points that are currently expended. A value of zero won't do anything.
	public var reducedMovementTime:Float;

	// -- RETAILIATORY FIRE
	
	public static inline var BIT_MELEE_UNITS:Int = 1;
	public static inline var BIT_RANGED_UNITS:Int = 2;
	
	// Deals retailiatory covering fire for others on overwatch? 1 - After shot Only, 2- Before and After shot.
	public var coveringFire:Int;
	
	// Restricts covering fire by a certain unit-type bitflag mask.
	public var coveringFireMask:Int;

	// Deals personal retailiatory after-shots/strikes whenever possible if being attacked?
	public var retailiatePersonal:Bool;
	
	// Restrict personal retailiatory after-shots/strikes by a certain unit-type bitflag mask.
	public var retailiatePersonalMask:Int;

	// ----------------------------------
	
	// -- TARGET FOCUSED OVERWATCH

	// Required number of valid exposure counts on a target before firing can commence while on Target Focused Overwatch.
	public var reqTargetedOverwatchExposures:Int;

	// -- SUPPRESSIVE FIRE

	// Required number of valid exposure counts on a target before firing can commence while dealing Suppression Fire on the target
	public var reqSupExposures:Int;
	
	// Percentage of target body exposure to exceed in order be deemed a valid exposure for Suppressive Fire and firing a suppressive fire shot
	public var reqSuppExposurePerc:Float;
	
	// Accruacy penalty incured for Suppressive Fire shots.  Use 0 to not have any effect on the accruacy. Use a negative number for a fixed ratio reduction. Use a positive number for a ratio reduction by pencentage of the current accruacy.
	public var supFireAccruacyPenalty:Float;

	// Determines if suppressive fire causes enemy target's trigger pull to be shortened, forcing suppressed enemy target to dish less rounds out.
	public var interruptEnemyTrigger:Bool;

	// Determines reduction of enemy's accruacy while dealing suppressive fire on enemy. Use 0 to not have any effect on enemy's accruacy. Use a negative number for a fixed ratio reduction. Use a positive number for a ratio reduction by pencentage of existing enemy accruacy.
	public var supFireEnemyAccruacyPenalty:Float;
	
	
	// -----------------------------------

	// MELEE OPPURTUNIST
	
	// Determines whether this unit can deal a free opputunity attack with a melee weapon when an enemy runs out of the engagement range of the carried melee weapon.
	public var opputunityMelee:Bool;

	public function new() 
	{
		
	}
	
	public function setupValkyriaChronicles(interceptionFire:Bool=true):AggroSpecs {
		aggro = -1;
		coveringFire = 2;
		coveringFireMask = 0;
		engagePassChecks = 0;
		interruptEnemyTrigger = false; 
		opputunityMelee = false;
		overwatchFireAccruacyPenalty = 0;
		reqOverExposurePerc = 5/100;
		reqOverwatchExposures = 0;
		reqPercChanceOverwatchHit = 0;
		reducedMovementTime = 0;
		reqSupExposures = 0;
		reqSuppExposurePerc = 5 / 100; 
		reqTargetedOverwatchExposures = 0;
		retailiatePersonal = interceptionFire; 
		retailiatePersonalMask = 0;
		sentinel = interceptionFire ? -1 : 0;  
		supFireAccruacyPenalty = 0;
		supFireEnemyAccruacyPenalty = 0;
		return this;
	}
	
	public function setupAsharenaStandard(ranged:Bool=false, canRetailiate:Bool=true):AggroSpecs {
		aggro = 1;
		coveringFire = 2;
		
		engagePassChecks = -1;
		interruptEnemyTrigger = true; 
		opputunityMelee = true;
		overwatchFireAccruacyPenalty = 0;
		reqOverExposurePerc = 50/100;
		reqOverwatchExposures = 2;
		reqPercChanceOverwatchHit = 0;
		reducedMovementTime = -1;
		reqSupExposures = 0;
		reqSuppExposurePerc = 5 / 100; 
		reqTargetedOverwatchExposures = 1;
		
		retailiatePersonalMask = 0;
		sentinel = -1; 
		supFireAccruacyPenalty = -0.3;
		supFireEnemyAccruacyPenalty = 0.3;
		
		setAsharenaValues(ranged, canRetailiate);
		return this;
	}
	
	public inline function setAsharenaValues(ranged:Bool = false, canRetailiate:Bool = true):Void {
		coveringFireMask = ranged ? BIT_RANGED_UNITS : 0;  
		retailiatePersonal = canRetailiate; 
	}
	
	
	
}