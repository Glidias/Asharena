package systems.movement;
import ash.core.Engine;
import ash.core.Node;
import ash.core.NodeList;
import ash.core.System;
import components.Vel;

/**
 * ...
 * @author Glenn Ko
 */
class DampingSystem extends System
{
	private var nodeList:NodeList<DampingNode>;

	public function new() 
	{
		super();
	}
	override public function addToEngine(engine:Engine):Void {
		nodeList = engine.getNodeList(DampingNode);
	}
	
	override public function update(time:Float):Void {
		var n:DampingNode = nodeList.head;
		
		while (n != null) {
			n.damping.update(n.vel, time);
			n = n.next;
		}
	}
}


class DampingNode extends Node<DampingNode> {
	public var damping:Damping;
	public var vel:Vel;
	
	
}