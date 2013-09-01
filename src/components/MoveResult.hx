package components;
import ash.core.Entity;
import systems.collisions.CollisionEvent;
import util.geom.Vec3;

/**
 * A component that is specific to each entity instance, storing it's unique result for any collisions that might occur
 * when it moves.  It also allows supply of custom collision event handlers for an entity to hook onto.
 * @author Glenn Ko
 */
class MoveResult extends Vec3
{
	public var collisions:CollisionEvent;  // any collisions that occur if any
	

	
	// Collision Event handlers
	// If no handler is used, default behaviour occurs.
	
	// MoveResult, Vel,  ENtity
	public var preSolve:MoveResult->Vel->Entity->Bool; 
	//   return  true to preventDefault behaviour, otherwise, any behaviour which the system will use by default (depending on entity's components) will occur. This can be used to overwrite
	// default collision behaviour of any entity.
	
	// MoveResult, Vel, Pos, ENtity
	public var postSolve:MoveResult->Vel->Pos->Entity->Void;  
	//  after physical collision has been solved by given system and entity has moved to intended position, any further action can occur here. 

	public var preventDefault:Bool; // for system use only. Basically stored result of preSolve callback.
	
	public function new() 
	{
		super();
	}
	
	public inline function init():Void {
		preventDefault = false;
	}
	
	public inline function disposeCollisions():Void {
		//while ( collisions != null) collisions = collisions.next;
	
		if (collisions != null) {
			var tail:CollisionEvent = collisions;
			while (tail.next != null) {
			    tail = tail.next;
			}
			tail.next = CollisionEvent.COLLECTOR;
			CollisionEvent.COLLECTOR = collisions;
			collisions = null;
		}
		
	}
	
	
	
}