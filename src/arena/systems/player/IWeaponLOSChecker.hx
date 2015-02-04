package arena.systems.player;
import arena.components.char.EllipsoidPointSamples;
import arena.components.weapon.Weapon;
import components.Ellipsoid;
import components.Pos;

/**
 * ...
 * @author Glenn Ko
 */
interface IWeaponLOSChecker  
{

	 function validateWeaponLOS(attacker:Pos, sideOffset:Float, heightOffset:Float, target:Pos, targetSize:Ellipsoid):Bool;
	 function getTotalExposure( attacker:Pos, weapon:Weapon, target:Pos, targetSize:Ellipsoid, targetStance:IStance, targetPts:EllipsoidPointSamples):Float;
	
}