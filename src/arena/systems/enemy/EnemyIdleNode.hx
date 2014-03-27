package arena.systems.enemy;
import arena.components.enemy.EnemyIdle;
import ash.core.Node;
import components.Pos;
import components.Rot;

/**
 * ...
 * @author Glenn Ko
 */

// For calm enemies that aren't alerted (situation safe).
class EnemyIdleNode extends Node<EnemyIdleNode> {  
	public var pos:Pos;
	public var rot:Rot;
	
	public var state:EnemyIdle;	
	
	//public var stateMachine:EntityStateMachine;
}
