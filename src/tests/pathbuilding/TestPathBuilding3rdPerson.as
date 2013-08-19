package tests.pathbuilding
{
	import alternativa.a3d.collisions.CollisionBoundNode;
	import alternativa.a3d.controller.SimpleFlyController;
	import alternativa.a3d.controller.ThirdPersonController;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.RenderingSystem;
	import alternativa.engine3d.Template;
	import ash.core.Engine;
	import ash.core.Entity;
	import ash.tick.FrameTickProvider;
	import com.bit101.components.ComboBox;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import input.KeyPoll;
	import saboteur.spawners.JettySpawner;
	import saboteur.systems.PathBuilderSystem;
	import saboteur.util.GameBuilder3D;
	import saboteur.util.SaboteurPathUtil;
	import spawners.arena.GladiatorBundle;
	import systems.collisions.EllipsoidCollider;
	import systems.SystemPriorities;
	import util.SpawnerBundle;
	import views.engine3d.MainView3D;
	import views.ui.bit101.BuildStepper;
	import views.ui.UISpriteLayer;
	/**
	 * Spectator ghost flyer with wall collision against builded paths
	 * @author Glenn Ko
	 */
	public class TestPathBuilding3rdPerson extends MovieClip
	{
		//public var engine:Engine;
		public var ticker:FrameTickProvider;
		public var game:TheGame;
		static public const START_PLAYER_Z:Number = 134;
		
		private var _template3D:MainView3D;
		
		private var uiLayer:UISpriteLayer = new UISpriteLayer();
		private var stepper:BuildStepper;
		private var thirdPerson:ThirdPersonController;
		

		
		public function TestPathBuilding3rdPerson() 
		{
	haxe.initSwc(this);
			game = new TheGame(stage);
	
			addChild( _template3D = new MainView3D() );
			_template3D.onViewCreate.add(onReady3D);
			addChild(uiLayer);
			
		}
		
		
		
		
		private function onReady3D():void 
		{
			SpawnerBundle.context3D = _template3D.stage3D.context3D;

			game.engine.addSystem( new RenderingSystem(_template3D.scene), SystemPriorities.render );
			
			var pathBuilder:PathBuilderSystem;
			game.engine.addSystem( pathBuilder = new PathBuilderSystem(_template3D.camera), SystemPriorities.postRender );
			pathBuilder.signalBuildableChange.add( onBuildStateChange);
	
			var jettySpawner:JettySpawner = new JettySpawner();
			var ent:Entity = jettySpawner.spawn(game.engine,_template3D.scene);
			
			var arenaSpawner:ArenaSpawner;
			var gladiatorBundle:GladiatorBundle = new GladiatorBundle(arenaSpawner=new ArenaSpawner(game.engine));
			
			gladiatorBundle.arenaSpawner.addGladiator(ArenaSpawner.RACE_SAMNIAN, stage, 0,0,START_PLAYER_Z+33).add( game.keyPoll );

			if (game.colliderSystem) {
				
				game.colliderSystem.collidable = (ent.get(GameBuilder3D) as GameBuilder3D).collisionGraph;
				game.colliderSystem._collider.threshold = 0.0001;
			}
			/*
			_template3D.camera.z = 200;
			_template3D.rotationX = Math.PI * .5;
			
			game.engine.addSystem(  new SimpleFlyController( 
						new EllipsoidCollider(GameSettings.SPECTATOR_RADIUS.x, GameSettings.SPECTATOR_RADIUS.y, GameSettings.SPECTATOR_RADIUS.z), 
						(ent.get(GameBuilder3D) as GameBuilder3D).collisionGraph ,
						stage, 
						_template3D.camera, 
						GameSettings.SPECTATOR_SPEED,
						GameSettings.SPECTATOR_SPEED_SHIFT_MULT)
						,preRender);
				*/		
		thirdPerson = new ThirdPersonController(stage, _template3D.camera, new Object3D(), arenaSpawner.currentPlayer, arenaSpawner.currentPlayer, arenaSpawner.currentPlayerEntity);
			game.engine.addSystem( thirdPerson, SystemPriorities.postRender ) ;
			
			
		
			
			uiLayer.addChild( stepper = new BuildStepper());
			stepper.onBuild.add(pathBuilder.attemptBuild);
			stepper.onStep.add(pathBuilder.setBuildIndex);
			stepper.onDelete.add(pathBuilder.attemptDel);
			
			ticker = new FrameTickProvider(stage);
			ticker.add(tick);
			ticker.start();
		}
		
		private function tick(time:Number):void {
			game.engine.update(time);
			_template3D.render();
		}
		
		private function onBuildStateChange(result:int):void 
		{
			stepper.buildBtn.enabled = result === SaboteurPathUtil.RESULT_VALID;
			stepper.delBtn.enabled = result === SaboteurPathUtil.RESULT_OCCUPIED;
		}
		
		
		
	}

}