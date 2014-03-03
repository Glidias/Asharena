package systems.player;
import alternativa.engine3d.core.Object3D;
import ash.core.Node.Node;
import components.Ellipsoid;
import components.Pos;

/**
 * 
 * @author Glenn Ko
 */
class PlayerTargetNode extends Node<PlayerTargetNode>
{
	public var ellipsoid:Ellipsoid;
	public var obj:Object3D; 
	public var pos:Pos;
	
	public function new() 
	{
		
	}
	
}