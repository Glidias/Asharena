package ;
import ash.core.Engine;
import ash.tick.FrameTickProvider;
import flash.display.Stage;
import input.KeyPoll;
import systems.animation.AnimationSystem;
import systems.collisions.EllipsoidColliderSystem;
import systems.collisions.GroundPlaneCollisionSystem;
import systems.movement.MovementSystem;
import systems.movement.PlayerSurfaceMovementSystem;
import systems.movement.QPhysicsSystem;
import systems.SystemPriorities;
import util.geom.Geometry;
import util.geom.room.RoomCreator;

import systems.collisions.EllipsoidCollider;
import systems.movement.GravitySystem;
import systems.movement.SurfaceMovementSystem;
import systems.player.PlayerControlActionSystem;
import systems.player.PlayerJumpSystem;
import systems.rendering.RenderSystem;

/**
 * ...
 * @author Glenn Ko
 */

class TheGame 
{
	public var colliderSystem:EllipsoidColliderSystem;
	
	public var engine:Engine;
	public var spawner:Spawner;
	public var stage:Stage;
	public var ticker:FrameTickProvider;
	public var keyPoll:KeyPoll;

	
	public function new(stage:Stage) 
	{
		keyPoll = new KeyPoll(stage);
		
		engine = new Engine();
		this.stage = stage;
		spawner =  getSpawner();
		

		// Craete ticker
		ticker = new FrameTickProvider(stage, 1000/15);
		ticker.add(engine.update);
		
		// Create systems
		//EllipsoidCollider;
		//SurfaceMovementSystem;
	
		
		engine.addSystem( new GravitySystem(), SystemPriorities.update );
		engine.addSystem( new PlayerJumpSystem(keyPoll), SystemPriorities.update);
		engine.addSystem( new PlayerSurfaceMovementSystem(), SystemPriorities.update );
		engine.addSystem( colliderSystem= new EllipsoidColliderSystem( new Geometry(), 0.001), SystemPriorities.preSolveCollisions );
		engine.addSystem( new QPhysicsSystem(), SystemPriorities.solveCollisions );
		engine.addSystem( new MovementSystem(), SystemPriorities.move );
		//engine.addSystem( new GroundPlaneCollisionSystem(), SystemPriorities.resolveCollisions );
		engine.addSystem( new SurfaceMovementSystem(), SystemPriorities.stateMachines );
		engine.addSystem( new PlayerControlActionSystem(keyPoll), SystemPriorities.stateMachines );
		engine.addSystem( new AnimationSystem(), SystemPriorities.animate);
		
		RenderSystem;
	
		
		// Spawn starting entities
	
		// Start
		//ticker.start(); 
	}
	
	public function getSpawner():Spawner {
		return new Spawner(engine);
	}
	
	public static function main():Void {
		
	}

	
}