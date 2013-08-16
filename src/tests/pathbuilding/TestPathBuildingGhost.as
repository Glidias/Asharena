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
		
		private var _template3D:Template;
		private var jettySpawner:JettySpawner;
		private var _simpleFlyController:SimpleFlyController;
		
		private var uiLayer:UISpriteLayer = new UISpriteLayer();
		private var stepper:BuildStepper;
		
		public function TestPathBuildingGhost() 
		{
			engine = new Engine();
			ticker = new FrameTickProvider(stage);
			

	
			addChild( _template3D = new Template() );
			addChild(uiLayer);
			
		
			
			
			_template3D.cameraController = _simpleFlyController =  new SimpleFlyController( new EllipsoidCollider(4, 4, 4), null, stage, new Object3D, 22, _template3D.settings.cameraSpeedMultiplier, 1);
			//_template3d.settings.cameraSpeed *= 4;
			//_template3d.settings.cameraSpeedMultiplier *= 2;
			_template3D.addEventListener(Template.VIEW_CREATE, onReady3D);
			
			ticker.add(tick);
			ticker.start();
		}
		
		
		private function onReady3D(e:Event):void 
		{
			SpawnerBundle.context3D = _template3D.stage3D.context3D;
			_simpleFlyController.object = _template3D.camera;
			
			var pathBuilder:PathBuilderSystem;
			engine.addSystem( pathBuilder = new PathBuilderSystem(_template3D.camera), 0 );
			pathBuilder.signalBuildableChange.add( onBuildStateChange);
			
			jettySpawner = new JettySpawner();
			var ent:Entity = jettySpawner.spawn(engine,_template3D.scene);
			_simpleFlyController.collidable = (ent.get(GameBuilder3D) as GameBuilder3D).collisionGraph;
			
			(e.currentTarget as IEventDispatcher).removeEventListener(e.type, onReady3D);
			engine.addSystem( new RenderingSystem(_template3D.scene), 2 );
			
			
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
			_template3D.cameraController.update();
			_template3D.camera.render(_template3D.stage3D);
		}
		
	}

}