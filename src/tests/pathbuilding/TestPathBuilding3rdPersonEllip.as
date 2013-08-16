package tests.pathbuilding
{
	import alternativa.a3d.collisions.CollisionBoundNode;
	import alternativa.engine3d.collisions.EllipsoidCollider;
	import alternativa.engine3d.controller.SimpleFlyController;

	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.RenderingSystem;
	import alternativa.engine3d.Template;
	import ash.core.Engine;
	import ash.core.Entity;
	import ash.tick.FrameTickProvider;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import saboteur.spawners.JettySpawner;
	import saboteur.systems.PathBuilderSystem;
	import saboteur.util.GameBuilder3D;
	import spawners.arena.GladiatorBundle;
	import util.SpawnerBundle;
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class TestPathBuilding3rdPersonEllip extends Sprite
	{
		public var engine:Engine;
		public var ticker:FrameTickProvider;
		
		private var _template3D:Template;
		private var jettySpawner:JettySpawner;
		private var _simpleFlyController:SimpleFlyController;
		private var collisionScene:Object3D = new Object3D();
		
		public function TestPathBuilding3rdPersonEllip() 
		{
			engine = new Engine();
			ticker = new FrameTickProvider(stage);
			
			
			
	
			addChild( _template3D = new Template());
			// 0.001 / 8
			_template3D.cameraController = _simpleFlyController = new SimpleFlyController(new EllipsoidCollider(4, 4, 4), collisionScene, stage, new Object3D(), 22, 3, 1); 
			// _simpleFlyController =  new SimpleFlyController( new EllipsoidCollider(4, 4, 4, 0.001/8), null, stage, new Object3D, 50,  4, 1);
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
			
			
			engine.addSystem( new PathBuilderSystem(_template3D.camera), 0 );
			
			GladiatorBundle;
			
			jettySpawner = new JettySpawner();
			var ent:Entity = jettySpawner.spawn(engine,_template3D.scene);
			//if (ent!=null) _simpleFlyController.collidable = (ent.get(GameBuilder3D) as GameBuilder3D).collisionGraph;
			collisionScene.addChild((ent.get(GameBuilder3D) as GameBuilder3D).collision);
			_template3D.scene.addChild(collisionScene);
			
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