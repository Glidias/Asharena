package tests.pathbuilding
{
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.RenderingSystem;
	import alternativa.engine3d.Template;
	import ash.core.Engine;
	import ash.tick.FrameTickProvider;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import saboteur.spawners.JettySpawner;
	import saboteur.systems.PathBuilderSystem;
	import saboteur.util.GameBuilder3D;
	import util.SpawnerBundle;
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class TestPathBuilding extends Sprite
	{
		public var engine:Engine;
		public var ticker:FrameTickProvider;
		
		private var _template3D:Template;
		private var jettySpawner:JettySpawner;
		
		public function TestPathBuilding() 
		{
			engine = new Engine();
			ticker = new FrameTickProvider(stage);
			
				
			
	
			addChild( _template3D = new Template());
			//_template3d.settings.cameraSpeed *= 4;
			//_template3d.settings.cameraSpeedMultiplier *= 2;
			_template3D.addEventListener(Template.VIEW_CREATE, onReady3D);
			
			ticker.add(tick);
			ticker.start();
		}
		
		private function onReady3D(e:Event):void 
		{
			SpawnerBundle.context3D = _template3D.stage3D.context3D;
			
			
			engine.addSystem( new PathBuilderSystem(_template3D.camera), 0 );
			
			jettySpawner = new JettySpawner();
			jettySpawner.spawn(engine,_template3D.scene);
			
			
			(e.currentTarget as IEventDispatcher).removeEventListener(e.type, onReady3D);
			engine.addSystem( new RenderingSystem(_template3D.scene), 2 );
			
			
		}
		
		public function tick(time:Number):void 
		{
			
			engine.update(time);
			_template3D.cameraController.update();
			_template3D.camera.render(_template3D.stage3D);
		}
		
	}

}