package systems.rendering;
import ash.core.Node;
import components.Pos;
import components.Rot;

import alternativa.engine3d.core.Object3D;  // point this to a different path for different engines

/**
 * Simplified render node with position only.
 * @author Glenn Ko
 */
class RenderNode1 extends Node<RenderNode1>
{
	public var object:Object3D;
	public var pos:Pos;

	public function new() 
	{
		
	}
	
}