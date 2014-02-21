package ;
import ash.core.Engine;
import ash.core.System;
import ash.fsm.EngineState;
import ash.fsm.EngineStateMachine;
import input.KeyPoll;
import systems.animation.AnimationSystem;
import systems.collisions.EllipsoidColliderSystem;
import systems.collisions.GroundPlaneCollisionSystem;
import systems.movement.GravitySystem;
import systems.movement.MovementSystem;
import systems.movement.PlayerSurfaceMovementSystem;
import systems.movement.QPhysicsSystem;
import systems.movement.SurfaceMovementSystem;
import systems.player.PlayerControlActionSystem;
import systems.player.PlayerJumpSystem;
import systems.sensors.RadialSensorSystem;

import systems.SystemPriorities;

/**
 * ...
 * @author Glenn Ko
 */
class GameStates
{
	public var radialSensorSystem:RadialSensorSystem;
	
	public var engineState:EngineStateMachine;
	public var thirdPerson:EngineState;
	public var spectator:EngineState;
	
	
	public var colliderSystem:EllipsoidColliderSystem;

	
	public function new(engine:Engine, colliderSystem:EllipsoidColliderSystem, keyPoll:KeyPoll) 
	{
		this.colliderSystem = colliderSystem;
		init(engine, keyPoll);
	}
	
	function init(engine:Engine, keyPoll:KeyPoll) 
	{
		engineState = new EngineStateMachine(engine);
		

		thirdPerson = new EngineState();
		thirdPerson.addSingleton( GravitySystem ).withPriority( SystemPriorities.update);
		thirdPerson.addInstance( new PlayerJumpSystem() ).withPriority( SystemPriorities.update);
		thirdPerson.addInstance( new PlayerSurfaceMovementSystem()).withPriority( SystemPriorities.update);
		thirdPerson.addInstance(colliderSystem).withPriority( SystemPriorities.preSolveCollisions);
		thirdPerson.addSingleton( QPhysicsSystem ).withPriority( SystemPriorities.solveCollisions);
	
		thirdPerson.addSingleton( MovementSystem  ).withPriority( SystemPriorities.move);
		thirdPerson.addSingleton( SurfaceMovementSystem  ).withPriority( SystemPriorities.stateMachines);
		thirdPerson.addInstance( new PlayerControlActionSystem() ).withPriority(SystemPriorities.stateMachines);
		thirdPerson.addSingleton( AnimationSystem  ).withPriority( SystemPriorities.animate);
		radialSensorSystem = new RadialSensorSystem();
		thirdPerson.addInstance(radialSensorSystem).withPriority(SystemPriorities.stateMachines);
		engineState.addState("thirdPerson", thirdPerson);
		
		
		spectator = new EngineState();
		spectator.addSingleton( GravitySystem ).withPriority( SystemPriorities.update);
		spectator.addInstance(colliderSystem).withPriority( SystemPriorities.preSolveCollisions);
		spectator.addSingleton( QPhysicsSystem ).withPriority( SystemPriorities.solveCollisions);
		spectator.addSingleton( MovementSystem  ).withPriority( SystemPriorities.move);
		spectator.addSingleton( SurfaceMovementSystem  ).withPriority( SystemPriorities.stateMachines);
		spectator.addSingleton( AnimationSystem  ).withPriority( SystemPriorities.animate);
		engineState.addState("spectator", spectator);

		
	
	}
	
	
}