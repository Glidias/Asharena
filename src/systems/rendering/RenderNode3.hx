package systems.rendering;
import ash.core.Node;
import components.Pos;
import components.Rot;
import components.Scale;

import alternativa.engine3d.core.Object3D;  // point this to a different path for different engines

/**
 * Render node that considers all 3 euler values for position, rotation, and scale.
 * @author Glenn Ko
 */
class RenderNode3 extends Node<RenderNode3>
{
	public var object:Object3D;
	public var pos:Pos;
	public var rot:Rot;
	public var scale:Scale;

	public function new() 
	{
		
	}
	
}