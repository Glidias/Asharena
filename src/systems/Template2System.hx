package systems;
import ash.core.Engine;
import ash.core.Node;
import ash.core.NodeList;
import ash.core.System;

/**
 * ...
 * @author Glenn Ko
 */
class Template2System extends System
{

	private var nodeList:NodeList<Template2Node>;
	
	public function new() 
	{
		super();
	}
	
	
	override public function addToEngine(engine:Engine):Void {
		nodeList = engine.getNodeList(Template2Node);
	}
	
	override public function update(time:Float):Void {
		var n:Template2Node = nodeList.head;
		while (n != null) {
			
			n = n.next;
		}
	}
	
}

class Template2Node extends Node<Template2Node> {
	
	
}