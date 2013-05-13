package systems;
import ash.core.Node;
import ash.tools.ListIteratingSystem;

/**
 * ...
 * @author Glenn Ko
 */
class TemplateSystem extends ListIteratingSystem<TemplateNode>
{

	public function new() 
	{
		super(TemplateNode, updateNode);
	}
	
	public function updateNode(node:TemplateNode, time:Float):Void {
		
	}
	
}

class TemplateNode extends Node<TemplateNode> {
	
	
}