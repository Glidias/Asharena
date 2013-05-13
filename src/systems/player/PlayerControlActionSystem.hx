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
 * 
 * @author Glenn Ko
 */
class PlayerControlActionSystem extends System
{

	private var nodeList:NodeList<PlayerActionNode>;
	
	// You can adjust this value for minimum amount of resultant speed required to consider whether to walk/run
	public static inline var WALK_MOVEMENT_THRESHOLD:Float = 0;
	public static inline var RUN_MOVEMENT_THRESHOLD:Float = 0;
	
	public static inline var WALK_STRAFE_THRESHOLD:Float = WALK_MOVEMENT_THRESHOLD;
	public static inline var RUN_STRAFE_THRESHOLD:Float = RUN_MOVEMENT_THRESHOLD;
	
	public var key:KeyPoll;
	
	public function new(key:KeyPoll) 
	{
		super();
		this.key = key;
	}
	
	
	override public function addToEngine(engine:Engine):Void {
		nodeList = engine.getNodeList(PlayerActionNode);
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
		
		if (n.action.locked) return;
		
		// Consider walkign animations
			if (n.collision.maximum_ground_normal != null) {  // on ground
				
				v = n.vel;
				
				
				
				if ( (boo = key.isDown(KeyBindings.RIGHT)) || key.isDown(KeyBindings.LEFT) ) {  // determine whether to strafe left/right/none
					d = n.direction.right;
					value =  Vec3Utils.dot(d, v);
					if (Vec3Utils.dot(d, v) >= WALK_STRAFE_THRESHOLD ) {  // got strafing
						n.action.set( 
							( key.isDown(KeyBindings.ACCELERATE) && value > RUN_STRAFE_THRESHOLD) ?  boo ? PlayerAction.STRAFE_RIGHT_FAST : PlayerAction.STRAFE_LEFT_FAST
							:
							boo ? PlayerAction.STRAFE_RIGHT : PlayerAction.STRAFE_LEFT
						); 
					}
					else n.action.set(PlayerAction.IDLE);
				}
				
				if ( (boo=key.isDown(KeyBindings.FORWARD)) || key.isDown(KeyBindings.BACK ) ) {  // determine whether to move forward/backward/none
					d = n.direction.forward;
					value =  Vec3Utils.dot(d, v);
					if (Vec3Utils.dot(d, v) >= WALK_MOVEMENT_THRESHOLD ) {  // got movement
						n.action.set( 
							( key.isDown(KeyBindings.ACCELERATE) && value > RUN_MOVEMENT_THRESHOLD) ?  boo ? PlayerAction.STRAFE_RIGHT_FAST : PlayerAction.STRAFE_LEFT_FAST
							:
							boo ? PlayerAction.STRAFE_RIGHT : PlayerAction.STRAFE_LEFT
						); 
					}
					else n.action.set(PlayerAction.IDLE);
				}
				
			}
			else { // in air
				// TODO: Threshold to determine how long in air or air speed to determine animation to choose
				//if (n.action.current == PlayerAction.STATE_JUMP) return;  // Player is still in user-induced jumping state, do not cancel it while in air!
				//n.action.set( n.vel.z >= 0 ? PlayerAction.IN_AIR : PlayerAction.IN_AIR_FALLING );
			}
			
			//n = n.next;
		//}
	}
	
}

class PlayerActionNode extends Node<PlayerActionNode> {
	public var collision:CollisionResult;
	public var vel:Vel;
	public var direction:DirectionVectors;
	public var action:ActionIntSignal;
	
}