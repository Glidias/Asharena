package systems.movement;
import ash.core.Engine;
import ash.core.Node;
import ash.core.NodeList;
import ash.core.System;
import components.Gravity;
import components.Vel;

/**
 * ...
 * @author Glenn Ko
 */
class GravitySystem extends System
{
	private var nodeList:NodeList<GravityNode>;

	public function new() 
	{
		super();
	}
	override public function addToEngine(engine:Engine):Void {
		nodeList = engine.getNodeList(GravityNode);
	}
	
	override public function update(time:Float):Void {
		var n:GravityNode = nodeList.head;
		
		while (n != null) {
			n.gravity.update(n.vel, time);
			n = n.next;
		}
	}
}


class GravityNode extends Node<GravityNode> {
	public var gravity:Gravity;
	public var vel:Vel;
	
	
}