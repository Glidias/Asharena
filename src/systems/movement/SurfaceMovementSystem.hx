package systems.movement;

import ash.core.Engine;
import ash.core.Node;
import ash.core.NodeList;
import ash.core.System;
import ash.tools.ListIteratingSystem;
import components.CollisionResult;
import components.controller.SurfaceMovement;
import components.DirectionVectors;
import components.MoveResult;
import components.Pos;
import components.Rot;
import components.Vel;
import input.KeyPoll;
import util.geom.Vec3;

/**
 * Handles surface movement of all entities.
 * 
 * @author Glenn Ko
 */
class SurfaceMovementSystem extends System
{
	private var defaultGroundNormal:Vec3;
	
	public var nodeList:NodeList<SurfaceMovementNode>;
	
	public function new() 
	{
		super();
		defaultGroundNormal = new Vec3(0, 0, 1);
	}	
	
	
	override public function addToEngine(engine:Engine):Void {
		nodeList = engine.getNodeList(SurfaceMovementNode);
	}
	
	override public function update(time:Float):Void {
		var n:SurfaceMovementNode = nodeList.head;
		
		while (n != null) {
			

			var movement:SurfaceMovement = n.movement;
			SurfaceMovement.updateWith(time, n.rot, n.vel, movement.walk_state, movement.strafe_state, n.directions.forward, n.directions.right, movement.WALK_SPEED, movement.WALKBACK_SPEED, movement.STRAFE_SPEED, movement.friction, n.collision.gotGroundNormal ? defaultGroundNormal : null );
			
			n = n.next;
			
		}
	}

}



class SurfaceMovementNode extends Node<SurfaceMovementNode> {
	
	public var vel:Vel;
	public var rot:Rot;
	public var movement:SurfaceMovement;
	public var directions:DirectionVectors;
	public var collision:CollisionResult;  // this is used to determine whther person is on surface or not..

}



