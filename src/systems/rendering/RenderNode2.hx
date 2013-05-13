package systems.rendering;
import ash.core.Node;
import components.Pos;
import components.Rot;
import components.Scale;

import alternativa.engine3d.core.Object3D;  // point this to a different path for different engines

/**
 * Render node with position and scale only.
 * @author Glenn Ko
 */
class RenderNode2 extends Node<RenderNode2>
{
	public var object:Object3D;
	public var pos:Pos;
	public var scale:Scale;

	public function new() 
	{
		
	}
	
}