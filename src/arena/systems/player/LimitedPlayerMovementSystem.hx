package arena.systems.player;
import arena.components.char.MovementPoints;
import ash.core.Engine;
import ash.core.Node;
import ash.core.NodeList;
import ash.core.System;
import ash.signals.Signal0;
import components.ActionIntSignal;
import components.controller.SurfaceMovement;
import components.Gravity;
import components.Vel;
import input.KeyPoll;
import systems.player.PlayerAction;

/**
 * A transcient limited-displacement time-fuel-per-player-node approach for BLitz combat system! Place this right before MovementSystem?
 * @author Glenn Ko
 */
class LimitedPlayerMovementSystem extends System
{

	private var nodeList:NodeList<LimitedPlayerMovementNode>;
	
	private static inline var STATE_FALLING_MASK:Int = (1 << PlayerAction.IN_AIR) | ( 1 << PlayerAction.IN_AIR_FALLING);
	private static inline var STATE_STRAFE_MASK:Int = (1 << PlayerAction.STRAFE_LEFT) | ( 1 << PlayerAction.STRAFE_LEFT_FAST) | (1 << PlayerAction.STRAFE_RIGHT_FAST) | (1 << PlayerAction.STRAFE_RIGHT);
	private static inline var STATE_MOVE_MASK:Int = (1 << PlayerAction.MOVE_FORWARD) | ( 1 << PlayerAction.MOVE_FORWARD_FAST);
	private static inline var STATE_MOVEBACK_MASK:Int = (1 << PlayerAction.MOVE_BACKWARD) | (1 << PlayerAction.MOVE_BACKWARD_FAST);
	
	private var _playerPointsOut:MovementPoints;  // to defer timeElapsed to zero after movement poitns are out
	
	public var outOfFuel:Signal0;
	
	public function new() 
	{
		super();
		outOfFuel = new Signal0();
	}
	
	
	override public function addToEngine(engine:Engine):Void {
		nodeList = engine.getNodeList(LimitedPlayerMovementNode);
		nodeList.nodeRemoved.add( onNodeRemoved);
		engine.updateComplete.add(onUpdateComplete);
	}
	
	function onNodeRemoved(node:LimitedPlayerMovementNode) 
	{
		_playerPointsOut = node.movementPoints;   
	//	node.movementPoints.timeElapsed = 0;
	}
	
	override public function removeFromEngine(engine:Engine):Void {
		engine.updateComplete.remove(onUpdateComplete);
	}
	
	function onUpdateComplete() 
	{
		
		if (_playerPointsOut == null) return;  // should use a push list if using multiple nodes of this
		
		
		_playerPointsOut.timeElapsed = 0;
		_playerPointsOut = null;
	}
	



	
	override public function update(time:Float):Void {
		var n:LimitedPlayerMovementNode = nodeList.head;
		if (n == null) return;
		//while (n != null) {
		
			var vel:Vel = n.vel;
			var displacement:Float = vel.lengthSqr();
			n.movementPoints.timeElapsed = 0;
			if (displacement == 0) return;
			
			displacement = Math.sqrt(displacement);
			n.movementPoints.moveOnGround = false;
			
			// determine time passed by comparing velocity and surfaceMovement speeds
			//moveStats.WALK_SPEED
			var testMoveState:Int = ( 1 << n.action.current );
			if (testMoveState == 0) return;
			var baseSpeed:Float = (testMoveState  & STATE_MOVE_MASK )!=0? n.moveStats.WALK_SPEED : (testMoveState & STATE_STRAFE_MASK )!=0 ? n.moveStats.STRAFE_SPEED : (testMoveState & STATE_MOVEBACK_MASK )!=0 ? n.moveStats.WALKBACK_SPEED : (testMoveState & STATE_FALLING_MASK)!=0 ? -1 : 0; 
			//if ((testMoveState & STATE_FALLING_MASK) != 0) throw "A";
			if (baseSpeed == 0) return;
			
			n.movementPoints.moveOnGround =  baseSpeed >= 0;  // not really true, since unit could be sliding on ground. May need another PlayerAction for sliding because now currently using FALLING_IN_AIR for it!
			n.movementPoints.deplete( n.movementPoints.moveOnGround ? displacement / baseSpeed * time : time);
			
			if (n.movementPoints.movementTimeLeft <= 0) {  // this mayb e slightly exploitable if moiving, should cap the velocity???
				_playerPointsOut = n.movementPoints;
				
				n.movementPoints.movementTimeLeft = 0;
				n.keyPoll.resetAllStates();
				n.moveStats.resetAllStates();
				n.movementPoints.timeElapsed = 0;
			//	n.moveStats.setAllSpeeds(0);
				
				n.entity.remove(KeyPoll);
				outOfFuel.dispatch();
			}
			//n = n.next;
		//}
	}
	
}

class LimitedPlayerMovementNode extends Node<LimitedPlayerMovementNode> {
	public var keyPoll:KeyPoll;
	public var vel:Vel;
	public var movementPoints:MovementPoints;
	public var moveStats:SurfaceMovement;
	public var action:ActionIntSignal;
	
	public var gravity:Gravity;
	
	//public var stats:ArenaCharSheet;
}