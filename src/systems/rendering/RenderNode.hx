package systems.rendering;
import ash.core.Node;
import components.Pos;
import components.Rot;

import alternativa.engine3d.core.Object3D;  // point this to a different path for different engines

/**
 * The most common type of render node to use for 3d engines, supporting position and rotation only.
 * @author Glenn Ko
 */
class RenderNode extends Node<RenderNode>
{
	public var object:Object3D;
	public var pos:Pos;
	public var rot:Rot;

	public function new() 
	{
		
	}
	
}