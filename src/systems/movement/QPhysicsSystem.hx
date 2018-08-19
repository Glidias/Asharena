package systems.movement;
import ash.core.Engine;
import ash.core.Node;
import ash.core.NodeList;
import ash.core.System;
import components.Bounce;
import components.CollisionResult;
import components.Jump;
import components.MoveResult;
import components.Pos;
import components.Rot;
import components.Sticky;
import components.Vel;
import systems.collisions.CollisionEvent;
import util.geom.Vec3;
import util.geom.Vec3Utils;
import util.geom.Vec3;

/**
 * "Q" is for Quake-like physics. Works with EllipsoidCollider system or any other system that creates MoveResults as a result of a move query!
 * 
 * Handles move results and dispatching of collision event signals for entities that require it. Also supports entity-specific event callbacks across various
 * phases for collisions and canceling  of default system behaviours depending on entity. (Basically, users need only to adjust the MoveResult.x/y/z to match final intended position).
 * 
 * Handles entity's components like Bounce/Sticky and Jump against their Move/Collision Results. 
 * NOTE: Bounce and Sticky shuld not be used at the same time! 
 * 
 * This should be used before MovementSystem, unless  you aren't using MovementSystem but simply using QPhysics to drive everything,
 * in which case you can use this to handle movement of positions directly as well.
 * 
 * Currently, everything is bundled in here for convenience, even though these could be seperated out into several seperate systems.
 * 
 * Manually comment away (or flag out) stuff which you don't need, depending on your app, for the sake of performance once you've finalised everything.
 *
 * 
 * @author Glenn Ko
 */
class QPhysicsSystem extends System
{
	// Required
	private var moveResultList:NodeList<MoveResultNode>;
	private var collisionResultList:NodeList<CollisionResultNode>;
	
	// Optionals
	private var stickyList:NodeList<QStickyNode>;
	private var bounceList:NodeList<QBounceNode>;
	
	// Optional Flags to enable/disable features without commenting, showing what optional features this system supports.
	public static inline var FLAG_BOUNCE:Int = (1 << 0);
	public static inline var FLAG_STICKY:Int = (1 << 1);
	public static inline var FLAGS:Int = (FLAG_BOUNCE | FLAG_STICKY);

	public function new() 
	{
		super();
	}
	
	override public function addToEngine(engine:Engine):Void {
		moveResultList = engine.getNodeList(MoveResultNode);
		collisionResultList = engine.getNodeList(CollisionResultNode);
		
		if ((FLAGS & FLAG_BOUNCE) != 0) bounceList = engine.getNodeList(QBounceNode);
		if ((FLAGS & FLAG_STICKY)!=0) stickyList = engine.getNodeList(QStickyNode);
	}
	
	public static inline function applyBounce(collisions:CollisionEvent, velocity:Vec3, T_BOUNCE:Float, N_BOUNCE:Float ):Void {
		var coll:CollisionEvent = collisions;
		applyBounceWith(velocity, coll.normal, T_BOUNCE, N_BOUNCE);
		coll = coll.next;
		while (coll != null) {
			applyBounceWith(velocity, coll.normal, T_BOUNCE, N_BOUNCE);
			coll = coll.next;
		}
	}
	static inline function applyBounceWith(velocity:Vec3, normal:Vec3, T_BOUNCE:Float, N_BOUNCE:Float):Void {
		var _loc_2:Float = normal.dotProduct( velocity);
        var _loc_3:Vec3 = normal.clone();
        _loc_3.scale(-_loc_2);
        velocity.add(_loc_3);
        velocity.scale(T_BOUNCE);
        _loc_3.scale(N_BOUNCE);
        velocity.add(_loc_3);
	}
	
	// This is rather engine specific? Could be overwritten..
	public function setRotationFromNormal(rot:Rot, normal:Vec3):Void {
		/*
		var v = normal.deepCopy();
		v.scale(-1);
		elevation = Math.atan2(v.z, Math.sqrt(v.x * v.x + v.y * v.y));
		var dTest = 0.01;
		if (v.x * v.x + v.y * v.y > dTest*dTest)
		{
			azimuth = Math.atan2(v.y, v.x);
		}
		*/
	}
	
	
	override public function update(time:Float):Void {
		
		var pos:Pos;
		var vel:Vel;
		var result:MoveResult;
		var cResult:CollisionResult;
		
		var m:MoveResultNode;
		
		// preSolveCollisions
		m = moveResultList.head;
		while (m != null) {
			result = m.move;
			
			result.preventDefault = result.collisions == null || result.preSolve == null ?  false : result.preSolve(m.move, m.vel,  m.entity);
			m = m.next;
		}
		
		// start solveCollisions
		
		if ((FLAGS & FLAG_BOUNCE)!=0) {  // solveCollisions (by system)
			var b:QBounceNode = bounceList.head;
			while (b != null) {
				if (b.move.collisions == null || b.move.preventDefault) {
					b = b.next; 	
					continue;
				}
				applyBounce(b.move.collisions, b.vel, b.bounce.t, b.bounce.n);
				b = b.next;
			}
		}
	
		
		if ( (FLAGS & FLAG_STICKY) != 0) {  // solveCollisions (by system)
			var s:QStickyNode = stickyList.head;
			while (s != null) {
				if (s.move.collisions == null || s.move.preventDefault) {
					s = s.next; 	
					continue;
				}
				s.pos.copyFrom( s.move.collisions.pos );
				s.vel.x = 0;
				s.vel.y = 0;
				s.vel.z = 0;
				var rot:Rot;
				if (s.stick.align && (rot=s.entity.get(Rot))!=null ) {
					setRotationFromNormal(rot, s.move.collisions.normal);
				}
				s = s.next;
			}
		}
		
		// end solveCollisions
		

		// record results for collisions
		var c:CollisionResultNode = collisionResultList.head;   // process collision events  from moveResult  and set to CollisionResult, if any
		while (c != null) {
			cResult = c.result;
			if (c.vel.lengthSqr() !=0) cResult.gotGroundNormal = false;
			cResult.gotCollision = false;
			if ( (cResult.flags & CollisionResult.FLAG_MAX_GROUND_NORMAL) != 0) {  // calc max ground normal
				processFlags(cResult, c.move.collisions, c.vel, CollisionResult.FLAG_MAX_GROUND_NORMAL);
			}
			if ( (cResult.flags & CollisionResult.FLAG_MAX_NORMAL_IMPULSE) != 0) {  // calc max normal impulse
				processFlags(cResult, c.move.collisions, c.vel, CollisionResult.FLAG_MAX_NORMAL_IMPULSE);
			}
			c = c.next;
		}
	
		// postSolveCollisions
		m = moveResultList.head;
		while (m != null) {
			if (m.move.collisions != null && m.move.postSolve != null) m.move.postSolve(m.move, m.vel, m.pos, m.entity);
			m = m.next;
		}
		
		
		var invT:Float = 1 / time;  // required because MovementSystem integreates forward by time
		
		// preMove
		m = moveResultList.head;
		while (m != null) {
			if (m.move.collisions != null) {
				vel = m.vel;
				pos = m.pos;
				result = m.move;	
				
				vel.x = (result.x - pos.x) * invT; 
				vel.y = (result.y - pos.y) * invT; 
				vel.z = (result.z - pos.z) * invT; 
				
				result.disposeCollisions();  // consider returnig collisionEvents to POOL, assumin git's no longer needed 
			}
			m = m.next;
		}

	}
	
	inline public function processFlags(result:CollisionResult, event:CollisionEvent, velocity:Vec3,  flags:Int = 0):Void {
		
		
		if (result.gotCollision = event != null) {
			var coll:CollisionEvent = event;
			processCollision(result, coll, velocity, flags);
			coll = coll.next;
			while (coll != null) {	
				processCollision(result, coll, velocity, flags);
				coll = coll.next;
			}
		}
	}
	
	
	inline public function processCollision(result:CollisionResult, event:CollisionEvent, velocity:Vec3, flags:Int = 0):Void {
		
		if (flags & CollisionResult.FLAG_MAX_GROUND_NORMAL != 0) {
			if (event.normal.z >= result.max_ground_normal_threshold && event.geomtype != CollisionEvent.GEOMTYPE_THING)
            {
                if (!result.gotGroundNormal || result.maximum_ground_normal.z <= event.normal.z)
                {
                    Vec3Utils.matchValues( result.maximum_ground_normal, event.normal);
					if ( result.gotGroundNormal) {
						velocity.z = 0;
					}
					result.gotGroundNormal = true;
                }
            }
		}
		if (flags & CollisionResult.FLAG_MAX_NORMAL_IMPULSE != 0) {
			var normDist:Float;
			if ( (normDist = Vec3Utils.dot(event.normal, velocity)) > result.maximum_normal_impulse)
            {
                result.maximum_normal_impulse = -normDist;
            }
		}
	}
	
	
}

// Nodelists and their relavant priorities

// preSolveCollisions / postSolveCollisions / preMove
class MoveResultNode extends Node<MoveResultNode> { 
	
	// preSolveCollisions - if got collisions, run any callbacks if availble, to determine whether to solve collision or not
	// preMove - finalise move result by adjusting velocity in relation to current position for MovementSystem to handle....,
	//             or set position immediately if MovementSystem isn't available!
	// postSolveCollisions - if got collisions, run any callbacks if available to determine whether to post-notify collision solves
	
	public var move:MoveResult;    
	public var vel:Vel;				
	public var pos:Pos;
}


///*  // Old approach: Should we simply rely entity-specific physic-response flags for Sticky and Bounce behaviours??? 
//    Abstraction entity approach:  Or should we rely on pure entity-specific callbacks for any behaviours like bounce and sticky???

// These solvings should be done in seperate functions since not every Sticky/Bounce might have occyr at every given time.

// solveCollisions
class QStickyNode extends Node<QStickyNode> {  // if got collision, need to stick entity and set velocity to zero
	public var stick:Sticky;
	public var pos:Pos;
	public var vel:Vel;
	public var move:MoveResult;  // if sticky occurs, some trigger should be required! <<< This can be handled by post-solve handler
}

// solveCollisions
class QBounceNode extends Node<QBounceNode> { // if got collision, adjust velocities based on bounce values.
	public var bounce:Bounce;
	public var vel:Vel;
	public var move:MoveResult;  // if bounce occurs, some trigger  should be  required! <<<This can be handled by post-solve handler
}

//*/


// postSolveCollisions  
class CollisionResultNode extends Node<CollisionResultNode> {
	// record out collision results for any entities that require it
	public var move:MoveResult;
	public var result:CollisionResult;
	public var vel:Vel;
}
// (rmb, after this is done, postSolveHandler is called if available for MoveResult under each MoveResultNode!)


/*
// preMove
class QJumpNode extends Node<QJumpNode> {  // adjust jump lock according to CollisionResult, so long as user is touching ground
	public var result:CollisionResult;
	public var jump:Jump;   
	// if jump state changes, some trigger is required! This can be handled by optional component query of JumpSignal, 
	//  since change doesn't happen often.
}
*/