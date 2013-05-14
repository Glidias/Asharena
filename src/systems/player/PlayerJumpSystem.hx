package systems.player;
import ash.core.Engine;
import ash.core.Node;
import ash.core.NodeList;
import ash.core.System;
import components.ActionIntSignal;
import components.CollisionResult;
import components.Jump;
import components.Vel;
import input.KeyBindings;
import input.KeyPoll;
import systems.player.PlayerAction;

/**
 * 
 * 
 * For multiple players on the same computer, keyPoll could exist as a component within nodes be iterated. We assume the first node entry is the player.
 * @author Glenn Ko
 */
class PlayerJumpSystem extends System
{

	private var nodeList:NodeList<PlayerJumpNode>;
	
	private var key:KeyPoll;
	
	public function new(keyPoll:KeyPoll) 
	{
		super();
		this.key = keyPoll;
	}
	
	
	override public function addToEngine(engine:Engine):Void {
		nodeList = engine.getNodeList(PlayerJumpNode);
	}
	
	override public function update(time:Float):Void {
		var n:PlayerJumpNode = nodeList.head;
		if (n == null) return;
		
		n.jump.update(time);
		if (n.collision.gotGroundNormal) {
			if (key.isDown(KeyBindings.JUMP) && n.jump.attemptJump(n.vel, time) ) {
			
				
				n.trigger.set( PlayerAction.STATE_JUMP );
			}
		}
		
		// n = n.next;
		//while (n != null) {
		//	updateNode(n);
		//	n = n.next;
		//}
	}
	
	//public inline function updateNode(node:PlayerJumpNode):Void {
		
	//}
	
}

class PlayerJumpNode extends Node<PlayerJumpNode> {
	public var jump:Jump;
	public var collision:CollisionResult;
	public var trigger:ActionIntSignal;
	public var vel:Vel;
}