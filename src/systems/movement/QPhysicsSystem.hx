package systems.movement;
import ash.core.Node;
import ash.core.System;
import components.Bounce;
import components.CollisionResult;
import components.Jump;
import components.MoveResult;
import components.Pos;
import components.Sticky;
import components.Vel;

/**
 * "Q" is for Quake-like physics.
 * 
 * Handles entity's components like Bounce/Sticky and Jump against their Move/Collision Results. 
 * NOTE: Bounce and Sticky shuld not be used at the same time! 
 * 
 * This should be used before MovementSystem, unless  you aren't using MovementSystem but simply using QPhysics to drive everything,
 * in which case you can use this to handle movement of positions directly as well.
 * 
 * Currently, everything is bundled in here for convenience, even though these could be seperated out into several seperate systems.
 * 
 * Manually comment away stuff which you don't need, depending on your app, for the sake of performance once you've finalised everything.
 *
 * 
 * @author Glenn Ko
 */
class QPhysicsSystem extends System
{

	public function new() 
	{
		
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
}
// (rmb, after this is done, postSolveHandler is called if available for MoveResult under each MoveResultNode!)


///*
// preMove
class QJumpNode extends Node<QJumpNode> {  // adjust jump lock according to CollisionResult, so long as user is touching ground
	public var result:CollisionResult;
	public var jump:Jump;   
	// if jump state changes, some trigger is required! This can be handled by optional component query of JumpSignal, 
	//  since change doesn't happen often.
}
//*/