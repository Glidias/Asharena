package arena.systems.player;
import components.Ellipsoid;
import components.Pos;

/**
 * ...
 * @author Glenn Ko
 */
interface IWeaponLOSChecker  
{

	 function validateWeaponLOS(attacker:Pos, sideOffset:Float, heightOffset:Float, target:Pos, targetSize:Ellipsoid):Bool;
	
}