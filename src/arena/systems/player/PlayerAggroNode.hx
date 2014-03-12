package arena.systems.player;
import arena.components.char.MovementPoints;
import ash.core.Node;
import components.Ellipsoid;
import components.Pos;

/**
 * ...
 * @author Glidias
 */
class PlayerAggroNode extends Node<PlayerAggroNode> {
	public var pos:Pos;
	public var size:Ellipsoid;
	
	// by assigning dummy Frozen movementPoints with timeElapsed == 0, enemy aggro can be stuck on this Node...without performing any action! Enemy aggro will only change if another node gets closer than this node!
	public var movementPoints:MovementPoints;   
}