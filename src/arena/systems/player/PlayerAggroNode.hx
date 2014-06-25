package arena.systems.player;
import arena.components.char.CharDefense;
import arena.components.char.EllipsoidPointSamples;
import arena.components.char.MovementPoints;
import ash.core.Node;
import components.Ellipsoid;
import components.Health;
import components.Pos;
import components.Rot;

/**
 * ...
 * @author Glidias
 */
class PlayerAggroNode extends Node<PlayerAggroNode> {
	public var pos:Pos;
	public var size:Ellipsoid;
	public var pointSamples:EllipsoidPointSamples;
	
	// by assigning dummy Frozen movementPoints with timeElapsed == 0, enemy aggro can be stuck on this Node...without performing any action! Enemy aggro will only change if another node gets closer than this node!
	public var movementPoints:MovementPoints;   
	
		
	// for hitting player only (this should/could be factored out elsewhere to a diff node/system)
	public var health:Health;
	public var rot:Rot;
	public var def:CharDefense;
	
	
	public function new() {
		
		
	}
	
	
}