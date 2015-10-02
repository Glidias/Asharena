package arena.components.char;

/**
 * This affects the character class's turn/time/movement/initiative related stats
 * @author Glenn Ko
 */
class CharTurnSpecs
{
	// -- TURN/INITIATIVE
	
	// Determines if there's a certain amount of game time in seconds that passes per unit turn when it comes to sequentially reacting as the "next unit".
	public var turnStaggerReactionTime:Float;
	
	// Does stagger reaction  game time that passes affect the time elapsed for enemy aggro weapan cooldowns?
	public var gotTimeStaggeredCooldown:Bool;
	
	// Determines the total time units available for the unit, and therefore it's movement allowance.
	public var totalTimeUnitsAvailable:Float;
	
	// Determines the amount of time it takes for the player to do a 180 degree turn from an un-ready weapon position and be ready to fire/strike at that point
	public var turnAimDuration:Float;
	

	public function new() 
	{
		
	}
	
	public function setupValkyriaChronicles(totalTimeUnitsInSec:Float=7):CharTurnSpecs {
		turnStaggerReactionTime = 0;
		gotTimeStaggeredCooldown = false;
		totalTimeUnitsAvailable = totalTimeUnitsInSec;
		turnAimDuration = 0.45;
		return this;
	}
	
	public function setupAsharena(totalTimeUnitsInSec:Float=7):CharTurnSpecs {
		turnStaggerReactionTime = 0.213;
		gotTimeStaggeredCooldown = false;
		totalTimeUnitsAvailable = totalTimeUnitsInSec;
		turnAimDuration = 0.45;
		
		return this;
	}
	
}