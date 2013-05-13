package systems.animation;
import ash.tools.ListIteratingSystem;
/**
 * A generic reusable animation system that can work on individual IAnimatable components to perform specific animations rather than rely on (many) systems.
 * @author Glenn Ko
 */

class AnimationSystem extends ListIteratingSystem<AnimationNode>
{

	public function new() 
	{
		super(AnimationNode, updateNode);
	}
	
	public function updateNode(node:AnimationNode, time:Float):Void {
		node.animatable.animate(time);
	
	}
	
}

class AnimationNode extends ash.core.Node<AnimationNode>
{
	public var animatable:IAnimatable;

	public function new() 
	{
		
	}
}