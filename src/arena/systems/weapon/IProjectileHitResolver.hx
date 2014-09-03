package arena.systems.weapon;
import ash.core.Entity;

/**
 * @author Glenn Ko
 */

interface IProjectileHitResolver 
{
  function processHit(srcEntity:Entity, targetEntity:Entity, targetDamage:Int, ex:Float = 0, ey:Float=0, ez:Float=0 ):Void;
}