package arena.systems.weapon ;
import ash.core.Entity;
import ash.signals.Signal3;
import ash.signals.SignalAny;
import components.Ellipsoid;
import components.Pos;

/**
 * @author Glenn Ko
 */

interface IProjectileDomain 
{ 
  function launchStaticProjectile(sx:Float, sy:Float, sz:Float, ex:Float, ey:Float, ez:Float, speed:Float):Float;
  //function launchStaticProjectileWithTime(sx:Float, sy:Float, sz:Float, ex:Float, ey:Float, ez:Float, time:Float):Void;
  
  function launchDynamicProjectile(sx:Float, sy:Float, sz:Float, pos:Pos, speed:Float, launcherEntity:Entity, targetEntity:Entity, targetEllipsoid:Ellipsoid, hpDeal:Int ):Float;
  //function launchDynamicProjectileWithTime(sx:Float, sy:Float, sz:Float, pos:Pos, time:Float, launcherEntity:Entity, targetHP:Health, hpDeal:Int):Void;
  function setHitResolver(resolver:IProjectileHitResolver):Void;
   
  function update(time:Float):Float;
}