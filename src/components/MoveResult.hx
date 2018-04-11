package components;
import ash.core.Entity;
import systems.collisions.CollisionEvent;
import util.geom.PMath;
import util.geom.Vec3;
import util.geom.Vec3Utils;

/**
 * A component that is specific to each entity instance, storing it's unique result for any collisions that might occur
 * when it moves.  It also allows supply of custom collision event handlers for an entity to hook onto. Also stores the final result move positions.
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
	
	/**
	 * Find in-between values from given timestamp
	 * @param	startPos	The starting original position of the entity
	 * @param	resultPos	The integreated position to input results
	 *  @param	resultVel	The integreated velocity to input results
	 * @param	t			Normalized unit time globally
	 */
	/*
	public inline function tweenResultPosVel(startPos:Pos, resultPos:Vec3, resultVel:Vec3, t:Float, ellip:Ellipsoid):Void {
		var c:CollisionEvent = collisions;
		if (c != null) {
			var earliestCollision:CollisionEvent = null; 
			var nextCollision:CollisionEvent = null;
			while (c != null) {
				earliestCollision = c;
				c = c.next;
				if (c == null || t > c.t) break;
				//if (c.t > 0) 
				nextCollision = c;
			}
			
			if (t >= earliestCollision.t) {
				// determine values beteween   earliestCollision and   (nextCollision or resultPos)
				
				// save position of earliest collision
				Vec3Utils.matchValues(resultPos, earliestCollision.pos);
				
				// use ResultVel as target destination
				
				if (nextCollision != null) {
					nextCollision.calcFallbackPosition(ellip.x, ellip.y, ellip.z, resultVel);	
				}
				else {
					Vec3Utils.matchValues(resultVel, this);
				}
				
				t = t - earliestCollision.t;
				
				resultVel.x -= resultPos.x;
				resultVel.y -= resultPos.y;
				resultVel.z -= resultPos.z;
				
				resultPos.x += resultVel.x*t;
				resultPos.y += resultVel.y*t;
				resultPos.z += resultVel.z*t;
				
			}
			else {
				// determine values beteween  startPos and earliestCollision 
				earliestCollision.calcFallbackPosition(ellip.x, ellip.y, ellip.z, resultVel);
				resultVel.x -= startPos.x;
				resultVel.y -= startPos.y;
				resultVel.z -= startPos.z;
			
				t = earliestCollision.t - t;
				resultPos.x = startPos.x + resultVel.x*t;
				resultPos.y = startPos.y + resultVel.y*t;
				resultPos.z = startPos.z + resultVel.z*t;
			}
		}
		else {  // between start Position and this MoveResult position
			resultVel.x = x - startPos.x;
			resultVel.y = y - startPos.y;
			resultVel.z = z - startPos.z;
			resultPos.x = startPos.x + resultVel.x*t;
			resultPos.y = startPos.y + resultVel.y*t;
			resultPos.z = startPos.z + resultVel.z*t;
		}
	}
	*/
	
	
	// exact matches will update their velocities to match new path
	inline
	public  function setIntegrationNewVelAtCollideTime(resultPos:Vec3, resultVel:Vec3, ellip:Ellipsoid, t:Float):Void {
		var c:CollisionEvent = collisions;
		
		var laterCollision:CollisionEvent = null;
		var earliestCollision:CollisionEvent = null;
		while (c != null) {  // iterating from latest to earliest
			if (c.t == t) {
				earliestCollision = c;
				break;
			}
			laterCollision = c;
			c = c.next;
		}
		
		if (earliestCollision != null) {
			if (laterCollision != null) {   // determine new velocity beteween earliestCollision and laterCollision timespan
				t = laterCollision.t - earliestCollision.t;
				t = 1 / t;
				laterCollision.calcFallbackPosition(ellip.x, ellip.y, ellip.z, resultVel);
				resultVel.x -= resultPos.x;  // assumed resultPos is at earliestCollision.t
				resultVel.y -= resultPos.y;
				resultVel.z -= resultPos.z;
				
			//	/*
				resultVel.x *= t;
				resultVel.y *= t;
				resultVel.z *= t;
			//	*/
			}
			else {    // determine new velocity from earliestCollision to final position
				t = 1 - earliestCollision.t;
				t = 1 / t;
				
				resultVel.x = x -resultPos.x; 
				resultVel.y = y - resultPos.y;
				resultVel.z = z - resultPos.z;
				
				///*
				resultVel.x *= t;
				resultVel.y *= t;
				resultVel.z *= t;
			//	*/
			}
		}
	
	}
	
	/**
	 * Find starting velocity and position values at timestamp=0
	 * @param	startPos
	 * @param	resultPos
	 * @param	resultVel
	 * @param	ellip
	 */
	public inline function initIntegration(startPos:Pos, resultPos:Vec3, resultVel:Vec3, ellip:Ellipsoid):Void {
		resultPos.x = startPos.x;
		resultPos.y = startPos.y;
		resultPos.z = startPos.z;
		var t:Float;
		
		var c:CollisionEvent = collisions;
		if (c != null) {
			var earliestCollision:CollisionEvent = null;
			var nextCollision:CollisionEvent = null;
			
			while (c != null) {  // iterate from latest to earliest
				earliestCollision = c;
				c = c.next;
				if (c == null) break;
				if (c.t != 0) nextCollision = c;
			}
			
			if (earliestCollision.t != 0) {
				// determine velocity beteween startPos and earliestCollision timespan
				earliestCollision.calcFallbackPosition(ellip.x, ellip.y, ellip.z, resultVel);
				t = 1/earliestCollision.t;
				resultVel.x -= startPos.x;
				resultVel.y -= startPos.y;
				resultVel.z -= startPos.z;
				
				/*
				resultVel.x *= t;
				resultVel.y *= t;
				resultVel.z *= t;
				*/
			
			}
			else {
				// if got next collision that is assumably not t==0........determine velocity between these 2 events! (ie. startPos and nextCollision) timespan
				if (nextCollision != null) {
					nextCollision.calcFallbackPosition(ellip.x, ellip.y, ellip.z, resultVel);
					t = 1/nextCollision.t;   
					
					resultVel.x -= startPos.x;
					resultVel.y -= startPos.y;
					resultVel.z -= startPos.z;
					
					/*
					resultVel.x *= t;
					resultVel.y *= t;
					resultVel.z *= t;
					*/
					
					/*
					resultVel.x = x - startPos.x;
					resultVel.y = y - startPos.y;
					resultVel.z = z - startPos.z;
					*/
				
				}	
				else {  // beginning to end
					resultVel.x = x - startPos.x;
					resultVel.y = y - startPos.y;
					resultVel.z = z - startPos.z;
					
				}
			}
		}
		else {  // beginning to end
			resultVel.x = x - startPos.x;
			resultVel.y = y - startPos.y;
			resultVel.z = z - startPos.z;
		}
	}
	
	public inline function findNearestCollisionEvent(fromTime:Float):CollisionEvent
	{
		var c:CollisionEvent = collisions;
		if (c == null) {
			return null;
		}
		else {
			var earliestCollision:CollisionEvent = null;
			
			while (c != null) {  // iterate from latest to earliest
				if (c.t <= fromTime) {
					break;
				}
				earliestCollision = c;
				c = c.next;
				//if (c == null) break;
				//if (c.t != 0) nextCollision = c;
			}
			return earliestCollision;
		}
		
	}
	
	inline
	public function truncateCollisionEvents(afterTime:Float) 
	{
		var c:CollisionEvent = collisions;
		var tailCollisionEvent:CollisionEvent = null;
		while ( c != null) {  // latest to earlier
			if (c.t <= afterTime) {
				break;
			}
			tailCollisionEvent = c; 
			//c.thing = null;
			c = c.next;
		}
		
		if (tailCollisionEvent != null) {
			var lastHead:CollisionEvent = collisions;
			collisions = tailCollisionEvent.next;
			
			tailCollisionEvent.next = CollisionEvent.COLLECTOR;
			CollisionEvent.COLLECTOR = lastHead;
			
		}
	}
	
	inline
	public function addCollisionEvent(e:CollisionEvent) 
	{
		e.next = collisions;
		collisions = e;
	}
	

	
	
	
}