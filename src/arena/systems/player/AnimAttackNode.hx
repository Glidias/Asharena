package arena.systems.player;
import arena.components.weapon.AnimAttackMelee;
import arena.components.weapon.Weapon;
import ash.core.Node;
import components.ActionIntSignal;

/**
 * ...
 * @author Glidias
 */
class AnimAttackNode extends Node<AnimAttackNode>
{
	public var animMelee:AnimAttackMelee;
	public var signal:ActionIntSignal;
	public var weapon:Weapon;
	
	public function new() 
	{
		
	}
	
}