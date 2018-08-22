package ashpc;

/**
 * ...
 * @author Glidias
 */
// -- usually core
import systems.movement.MovementSystem;
// TODO: Prescribed playcanvas rendering system with entity/graphNode

// -- This can be omitted if you aren't coding any IAnimatable stuff of your own.
import systems.animation.AnimationSystem;

// -- any physic effects (usually GravitySystem is the common one)
import systems.movement.GravitySystem;
import systems.movement.DampingSystem;

// --all reqiored for surface movement + GravitySystem (PlayerSurfaceMOvement can be omitted if no player KeyPoll controls involved)
import systems.movement.SurfaceMovementSystem;
import systems.movement.QPhysicsSystem;
//import systems.movement.PlayerSurfaceMovementSystem;

// -- jumping/jetting ability for player's Keypoll (if needed)
//import systems.player.PlayerJumpSystem;

// -- to clamp player ellipsoid position to a global altitude ground surface
import systems.collisions.GroundPlaneCollisionSystem;

// -- health tracking
import systems.sensors.HealthTrackingSystem;

// -- tweening
import systems.tweening.TweenSystem;

@:build(ashpc.macro.MacroUtil.buildSystems())
class Systems
{
	
}