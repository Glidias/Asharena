package systems.player;
import ash.core.Engine;
import ash.core.Node;
import ash.core.NodeList;
import ash.core.System;
import ash.tools.ListIteratingSystem;
import components.ActionIntSignal;
import components.ActionSignal;
import components.CollisionResult;
import components.DirectionVectors;
import components.Rot;
import components.Vel;
import haxe.io.Input;
import input.KeyBindings;
import input.KeyCode;
import input.KeyPoll;
import util.geom.Vec3;
import util.geom.Vec3Utils;

/**
 * Uses PC keyboard keypoll at the moment. For consoles,  a fake keypoll emulator can be used though an alternate class and using IKeyPoll implementaion.
 * 
 * Determines which keys are pressed and current velocity/physics state of player to determine what animation actions to play (normally, this is for lower-body only
 * and covers basic animation notifications for surface movement only. It does not assume whether player is able crouch/jump/crawl/etc.) That would require
 * another app-specific class to  handle each PlayerAction signal accordignly.
 * 
 * Currnetly, this system is hardcoded to only move 1 entity via keyboard controls.
 *
 * @author Glenn Ko
 */
class PlayerControlActionSystem extends System
{

	private var nodeList:NodeList<PlayerActionNode>;
	
	// You can adjust this value for minimum amount of resultant speed required to consider whether to walk/run
	public static inline var WALK_MOVEMENT_THRESHOLD:Float = 0;
	public static inline var RUN_MOVEMENT_THRESHOLD:Float = 0;
	
	public static inline var WALK_STRAFE_THRESHOLD:Float = 0;
	public static inline var RUN_STRAFE_THRESHOLD:Float = 0;
	
	public function new() 
	{
		super();	
	}
	
	
	override public function addToEngine(engine:Engine):Void {
		nodeList = engine.getNodeList(PlayerActionNode);
		//key.dispObj.addEventListener();
		nodeList.nodeRemoved.add( onNodeRemoved);
	}
	
	
	
	function onNodeRemoved(n:PlayerActionNode):Void
	{
		n.action.set(PlayerAction.IDLE);
			n.keyPoll.resetAllStates();
			//n.vel.x = 0;
			//n.vel.y = 0;
	}
	
	
	
	override public function removeFromEngine(engine:Engine):Void {
		//
		var n:PlayerActionNode = nodeList.head;
		while (n != null) {
			n.action.set(PlayerAction.IDLE);
			//n.keyPoll.disable();
			n.keyPoll.resetAllStates();
			
			n = n.next;
		}
		
		nodeList.nodeRemoved.remove( onNodeRemoved);
		
	}
	

	
	
	
	
	
	override public function update(time:Float):Void {
		var n:PlayerActionNode = nodeList.head;
		//while (n != null) {
		if (n == null) return;
		
		// START
		var d:Vec3;
		var v:Vel;
		var value:Float;
		var boo:Bool; 
		var key:KeyPoll = n.keyPoll;
		
		if (n.action.locked) return;
		
		var actionToSet:Int = PlayerAction.IDLE;
		
		// Consider turning to look around with key-controls (if no mouse avilable)
		if ( key.isDown(KeyCode.RIGHT)) {
			n.rot.z -= .05;
		}
		if (key.isDown(KeyCode.LEFT)) {
			n.rot.z += .05;
		}
		
		// Consider walkign animations
			if (n.collision.gotGroundNormal) {  // on ground
				
				v = n.vel;

				if ( (boo = key.isDown(KeyBindings.RIGHT)) || key.isDown(KeyBindings.LEFT) ) {  // determine whether to strafe left/right/none
					d = n.direction.right;
					value =  abs(Vec3Utils.dot(d, v)) * time;
					if (value >= WALK_STRAFE_THRESHOLD ) {  // got strafing
						actionToSet = 
							( key.isDown(KeyBindings.ACCELERATE) && value > RUN_STRAFE_THRESHOLD) ?  boo ? PlayerAction.STRAFE_RIGHT_FAST : PlayerAction.STRAFE_LEFT_FAST
							:
							boo ? PlayerAction.STRAFE_RIGHT : PlayerAction.STRAFE_LEFT; 
					}
				}
				
				if ( (boo=key.isDown(KeyBindings.FORWARD)) || key.isDown(KeyBindings.BACK ) ) {  // determine whether to move forward/backward/none
					d = n.direction.forward;
					value =  abs( Vec3Utils.dot(d, v) ) * time;
					if ( value >= WALK_MOVEMENT_THRESHOLD ) {  // got movement
						actionToSet = 
							( key.isDown(KeyBindings.ACCELERATE) ) ?  boo ? ( value >= RUN_MOVEMENT_THRESHOLD ? PlayerAction.MOVE_FORWARD_FAST : PlayerAction.MOVE_FORWARD) : (value >= RUN_MOVEMENT_THRESHOLD ?  PlayerAction.MOVE_BACKWARD_FAST : PlayerAction.MOVE_BACKWARD)
							:
							boo ? PlayerAction.MOVE_FORWARD : PlayerAction.MOVE_BACKWARD; 
					}
				}
				n.action.set(actionToSet);
			}
			else { // in air
				// TODO: Threshold to determine how long in air or air speed to determine animation to choose
				//if (n.action.current == PlayerAction.STATE_JUMP) return;  // Player is still in user-induced jumping state, do not cancel it while in air!
				//n.action.set( n.vel.z >= 0 ? PlayerAction.IN_AIR : PlayerAction.IN_AIR_FALLING );
			}

			//n = n.next;
		//}
	}
	
	private inline function abs(dot:Float):Float
	{
		return dot > 0 ? dot : -dot;
	}
	
}

class PlayerActionNode extends Node<PlayerActionNode> {
	public var collision:CollisionResult;
	public var vel:Vel;
	public var rot:Rot;
	public var direction:DirectionVectors;
	public var action:ActionIntSignal;
	public var keyPoll:KeyPoll;
	
}