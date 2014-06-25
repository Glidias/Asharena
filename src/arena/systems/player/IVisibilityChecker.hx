package arena.systems.player;
import arena.systems.player.PlayerAggroNode;
import components.Ellipsoid;
import components.Pos;

/**
 * ...
 * @author Glenn Ko
 */
interface IVisibilityChecker  
{

	function validateVisibility(enemyPos:Pos, enemyEyeHeight:Float, playerNode:PlayerAggroNode):Bool;
	
	
}