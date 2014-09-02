package arena.systems.enemy;
import arena.components.enemy.EnemyAggro;
import arena.components.weapon.Weapon;
import arena.components.weapon.WeaponState;
import arena.systems.player.IStance;
import ash.core.Node;
import components.ActionUIntSignal;
import components.Ellipsoid;
import components.Pos;
import components.Rot;

/**
 * ...
 * @author Glenn Ko
 */
// For enemies that are already aggroing a target, possibly engaging him, or standing ground and rotating to always face target, attacking them if within range. They might change targets if another target gets closer, so long as they aren't attacking with their weapons at the moment.

class EnemyAggroNode extends Node<EnemyAggroNode> {
	public var pos:Pos;
	public var ellipsoid:Ellipsoid;
	public var weapon:Weapon;
	public var weaponState:WeaponState;
	public var rot:Rot;
	
	public var stance:IStance;
	
	public var state:EnemyAggro;
	public var signalAttack:ActionUIntSignal;
	
	//public var stateMachine:EntityStateMachine;
}
