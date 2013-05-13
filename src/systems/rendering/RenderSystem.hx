package systems.rendering;
import ash.core.Engine;
import ash.core.Node;
import ash.core.NodeList;
import ash.core.System;

/**
 * ...
 * @author Glenn Ko
 */
class RenderSystem extends System
{

	public var nodeList:NodeList<RenderNode>; 
	
	public function new() 
	{
		super();
	}
	
	
	override public function addToEngine(engine:Engine):Void {
		nodeList = engine.getNodeList(RenderNode);  
		nodeList.nodeAdded.add( onAddedNode );
		nodeList.nodeRemoved.add( onRemovedNode );
	}
	
	public function onAddedNode(node:RenderNode):Void 
	{
		
	}
	
	public function onRemovedNode(node:RenderNode):Void {
		
	}
	
	
}

