package arena.systems.player;
import arena.components.weapon.Weapon;

/**
 * 
 * @author Glenn Ko
 */

interface IStance 
{
	/**
	 * Aim controls for independant aiming pitch and yaw accordingly.
	 */
  function setPitchAim(ratio:Float):Void;
  function getPitchAim():Float;
  function setTorsoTwist(ratio:Float):Void;
  function getTorsoTwist():Float;
  
  /*
	 A kind of combat alertness stance with variable degrees. 
	 Example of tension with variable degrees:
	-------------------------------
	Melee with shield up... (either fully up, half up, a bit up, etc.)
	Ranged Unit with pulled arrow... (how much of the arrow is pulled back..)
	*/
  function updateTension(ratio:Float, time:Float):Void;
  function getTension():Float;
  

  function isAttacking():Bool;
  function movingSlow():Bool;
  function getJoggingSpeed():Float;
  function getStance():Int;
  function setStance(val:Int):Void;
  
  /* Weapon switching */
  function switchWeapon(weapon:Weapon):Void;
  
  // killdeath anim
  function kill(id:Int):Void;
  
  function standAndFight():Void;
}