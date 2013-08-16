package tests.pathbuilding
{
	import alternativa.a3d.collisions.CollisionBoundNode;
	import alternativa.a3d.controller.SimpleFlyController;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.RenderingSystem;
	import alternativa.engine3d.Template;
	import ash.core.Engine;
	import ash.core.Entity;
	import ash.tick.FrameTickProvider;
	import com.bit101.components.ComboBox;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import saboteur.spawners.JettySpawner;
	import saboteur.systems.PathBuilderSystem;
	import saboteur.util.GameBuilder3D;
	import saboteur.util.SaboteurPathUtil;
	import spawners.arena.GladiatorBundle;
	import systems.collisions.EllipsoidCollider;
	import util.SpawnerBundle;
	import views.engine3d.MainView3D;
	import views.ui.bit101.BuildStepper;
	import views.ui.UISpriteLayer;
	/**
	 * Spectator ghost flyer with wall collision against builded paths
	 * @author Glenn Ko
	 */
	public class TestPathBuildingGhost extends Sprite
	{
		public var engine:Engine;
		public var ticker:FrameTickProvider;
		
		private var _template3D:MainView3D;
		
		private var uiLayer:UISpriteLayer = new UISpriteLayer();
		private var stepper:BuildStepper;
		
		public function TestPathBuildingGhost() 
		{
			engine = new Engine();
			ticker = new FrameTickProvider(stage);
			

	
			addChild( _template3D = new MainView3D() );
			_template3D.onViewCreate.add(onReady3D);
			addChild(uiLayer);
	

			
			ticker.add(tick);
			ticker.start();
		}
		
		
		private function onReady3D():void 
		{
			SpawnerBundle.context3D = _template3D.stage3D.context3D;

			
			var pathBuilder:PathBuilderSystem;
			engine.addSystem( pathBuilder = new PathBuilderSystem(_template3D.camera), 0 );
			pathBuilder.signalBuildableChange.add( onBuildStateChange);
			
			var jettySpawner:JettySpawner = new JettySpawner();
			var ent:Entity = jettySpawner.spawn(engine,_template3D.scene);
			
			
			engine.addSystem( new SimpleFlyController( 
						new EllipsoidCollider(GameSettings.SPECTATOR_RADIUS.x, GameSettings.SPECTATOR_RADIUS.y, GameSettings.SPECTATOR_RADIUS.z), 
						(ent.get(GameBuilder3D) as GameBuilder3D).collisionGraph ,
						stage, 
						_template3D.camera, 
						GameSettings.SPECTATOR_SPEED,
						GameSettings.SPECTATOR_SPEED_SHIFT_MULT)
						, 2);
						
			engine.addSystem( new RenderingSystem(_template3D.scene, _template3D), 3 );
			
			
			uiLayer.addChild( stepper = new BuildStepper());
			stepper.onBuild.add(pathBuilder.attemptBuild);
			stepper.onStep.add(pathBuilder.setBuildIndex);
			stepper.onDelete.add(pathBuilder.attemptDel);
		}
		
		private function onBuildStateChange(result:int):void 
		{
			stepper.buildBtn.enabled = result === SaboteurPathUtil.RESULT_VALID;
			stepper.delBtn.enabled = result === SaboteurPathUtil.RESULT_OCCUPIED;
		}
		
		public function tick(time:Number):void 
		{
			engine.update(time);
		}
		
	}

}