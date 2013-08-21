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
import flash.errors.Error;
import input.KeyBindings;
import input.KeyPoll;
import util.geom.Vec3;

/**
 * Handles surface movement for player entity, ie . entity with keypoll
 * 
 * @author Glenn Ko
 */
class PlayerSurfaceMovementSystem extends System
{
	
	public var nodeList:NodeList<PlayerSurfaceMovementNode>;
	
	

	
	
	public function new() 
	{
		super();
		
	}	
	
	override public function removeFromEngine(engine:Engine):Void {
		var n:PlayerSurfaceMovementNode = nodeList.head;
		while ( n != null) {
			n.movement.strafe_state = 0;
			n.movement.walk_state = 0;
			n = n.next;
		}
	}
	
	
	override public function addToEngine(engine:Engine):Void {
		nodeList = engine.getNodeList(PlayerSurfaceMovementNode);
	}
	
	override public function update(time:Float):Void {
		var n:PlayerSurfaceMovementNode = nodeList.head;
		
		while (n != null) {
			var val:Int;
			var key:KeyPoll = n.keys;
			
			val = 0;
			val -= key.isDown(KeyBindings.LEFT) ? 1 : 0;
			val += key.isDown(KeyBindings.RIGHT) ? 1 : 0;
			n.movement.strafe_state = val;
			
			val = 0;
			val += key.isDown(KeyBindings.FORWARD) ? 1 : 0;
			val -= key.isDown(KeyBindings.BACK) ? 1 : 0;
			n.movement.walk_state = val;
			
			n = n.next;
			
		}
	}

}



class PlayerSurfaceMovementNode extends Node<PlayerSurfaceMovementNode> {
	
	
	public var keys:KeyPoll;
	public var movement:SurfaceMovement;
	
}



