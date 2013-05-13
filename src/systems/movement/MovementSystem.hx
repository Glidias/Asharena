package systems.movement;
import ash.core.Engine;
import ash.core.Node;
import ash.core.NodeList;
import ash.core.NodeList;
import ash.core.System;
import ash.tools.ListIteratingSystem;
import components.Pos;
import components.Vel;

/**
 * 
 * @author Glenn Ko
 */
class MovementSystem extends System
{
	private var nodeList:NodeList<MovementNode>;
	
	public function new() 
	{
		super();
	}
	
		override public function addToEngine(engine:Engine):Void {
		nodeList = engine.getNodeList(MovementNode);
	}
	
	override public function update(time:Float):Void {
		var n:MovementNode = nodeList.head;
		
		while (n != null) {
			n.pos.x += (n.vel.x * time);
			n.pos.y += (n.vel.y * time);
			n.pos.z += (n.vel.z * time);
			n = n.next;
		}
	}
}

class MovementNode extends Node<MovementNode> {
	public var pos:Pos;
	public var vel:Vel;
}