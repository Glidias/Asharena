package;
import arena.components.char.HitFormulas;
import arena.systems.enemy.AggroMemManager;
import arena.systems.enemy.EnemyAggroSystem;
import arena.systems.player.LimitedPlayerMovementSystem;
import ash.core.Engine;
import ash.fsm.EngineState;
import ash.fsm.EngineStateMachine;
import ash.tick.FrameTickProvider;
import components.ActionUIntSignal;
import arena.components.weapon.Weapon;
import arena.components.weapon.WeaponSlot;
import flash.display.Stage;
import input.KeyPoll;
import systems.animation.AnimationSystem;
import systems.collisions.EllipsoidColliderSystem;
import systems.collisions.GroundPlaneCollisionSystem;
import systems.movement.FlockingSystem;
import systems.movement.MovementSystem;
import systems.movement.PlayerSurfaceMovementSystem;
import systems.movement.QPhysicsSystem;
import systems.player.PlayerTargetingSystem;
import systems.sensors.HealthTrackingSystem;
import systems.sensors.RadialSensorSystem;

import systems.SystemPriorities;
import systems.tweening.TweenSystem;
import util.geom.Geometry;

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
	//public var engineState:EngineStateMachine;
	
	public var spawner:Spawner; 
	
	public var stage:Stage;
	public var ticker:FrameTickProvider;
	public var keyPoll:KeyPoll;
	
	public var gameStates:GameStates;
	
	
	public function new(stage:Stage) 
	{
		Type.getClass(stage);
		
		keyPoll = new KeyPoll(stage);
		
		engine = new Engine();
		this.stage = stage;
		spawner =  getSpawner();
		

		// Craete ticker
		ticker = new FrameTickProvider(stage, 1000/15);
		ticker.add(engine.update);
		
		colliderSystem = new EllipsoidColliderSystem( new Geometry(), 0.001);
		
		gameStates = new GameStates(engine, colliderSystem, keyPoll);
		
		
		ActionUIntSignal;
		RenderSystem;
		FlockingSystem;
		Spawner;
		GroundPlaneCollisionSystem;
		TweenSystem;
		
		LimitedPlayerMovementSystem;
		PlayerTargetingSystem;
		
		Weapon;
		WeaponSlot;
		
		RadialSensorSystem;
		HealthTrackingSystem;
		
		AggroMemManager;
		EnemyAggroSystem;
		HitFormulas;
		
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