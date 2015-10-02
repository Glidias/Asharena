package arena.components.char;
import arena.components.enemy.EnemyIdle;
import de.polygonal.ds.BitVector;
import hashds.ds.Indexable;

/**
 * Contains per unit watch settings and team-side marker for phase/turn-based combat system. 
 * 
 * Contains a bit vector for each entity to keep track of
 * any "enemies" an ai entity encountered/remembered throughout a phase. Once an ai entity REMEMBERS an enemy, he'll
 * alawys be on alert against them at the start of that unit's turn, regardless of current facing. Memory bits are reset at the start of every phase, allowing sneak attacks to occur during that time from the active side, assuming some some active units lie outside certain units' FOV and therefore outside their aggro memory. A sneak attack is alaways undodgable/unblockable, for obvious reasons, and will always hit. Some weapons have sneak attack damage bonuses.
 * 
 * Since aggro memory is reset at the start of every phase, individual unit end-turn facing before ending a phase, is essential to ensure all vantage-points are covered before the enemy side begins his phase. 
 * 
 * @see arena.systems.enemy.AggroMemManager
 * 
 * @author Glenn Ko
 */
class AggroMem implements Indexable
{
	public var bits:BitVector;
	public var watchSettings:EnemyIdle;
	public var side:Int;
	public var index:Int;
	
	public var cooldown:Float;
	
	public var watchFlags:Int;

	
	
	public var engaged:Bool;

	public function new() 
	{
		
	}
	
	public function init(watchSettings:EnemyIdle, side:Int=0):AggroMem {
		bits = new BitVector(32);
		this.watchSettings = watchSettings;
		this.side = side;
		index = -1;
		cooldown = 0;
		watchFlags = 0;
		return this;
	}
	
	
	
}