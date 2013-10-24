package tests.water 
{
	import alternativa.a3d.controller.SimpleFlyController;
	import alternativa.engine3d.core.Debug;
	import alternativa.engine3d.core.VertexAttributes;
	import alternativa.engine3d.materials.FillMaterial;
	import alternativa.engine3d.objects.WireFrame;
	import alternativa.engine3d.primitives.Box;
	import alternativa.engine3d.RenderingSystem;
	import alternativa.engine3d.resources.Geometry;
	import ash.tick.FrameTickProvider;
	import flash.display.MovieClip;
	import flash.geom.Vector3D;
	import flash.media.Camera;
	import systems.collisions.EllipsoidCollider;
	import systems.SystemPriorities;
	import util.SpawnerBundle;
	import views.engine3d.MainView3D;
	/**
	 * ...
	 * @author Glidias
	 */
	public class CubicSphere extends MovieClip 
	{
		private var _template3D:MainView3D;
		private var game:TheGame;
		private var ticker:FrameTickProvider;
		
		public function CubicSphere() 
		{
			haxe.initSwc(this);
		
			
			game = new TheGame(stage);
	
			addChild( _template3D = new MainView3D() );
		
			_template3D.onViewCreate.add(onReady3D);
			
				
		
		}
		
		
		private function spherify(geo:Geometry, radius:Number, boxWidth:Number):void {
			
			var vertices:Vector.<Number> = geo.getAttributeValues(VertexAttributes.POSITION);
			var normals:Vector.<Number> = geo.getAttributeValues(VertexAttributes.NORMAL);
		
			var len:int = vertices.length;
			for (var i:int = 0; i < len; i += 3) {
				var v:Vector3D = new Vector3D( vertices[i], vertices[i + 1], vertices[i + 2] );
				var n:Vector3D = new Vector3D( normals[i], normals[i + 1], normals[i + 2]   );
				var variant:Number = 0;
				
				variant = (n.x == 0 && Math.abs(v.x) == boxWidth) || (n.y==0 && Math.abs(v.y) == boxWidth) || (n.z==0 && Math.abs(v.z) == boxWidth) ? 0 : Math.random() * 62;
				
				var r:Number = radius + variant;
				
				v.normalize();
				v.scaleBy(r);
				vertices[i] = v.x;
				vertices[i+1] = v.y;
				vertices[i+2] = v.z;
			}
			
			
			geo.setAttributeValues(VertexAttributes.POSITION,vertices);
			
		}
		
		private function onReady3D():void 
		{
			SpawnerBundle.context3D = _template3D.stage3D.context3D;
			game.engine.addSystem( new RenderingSystem(_template3D.scene), SystemPriorities.render );

			var box:Box;
				_template3D.scene.addChild( box = new Box(1, 1, 1, 16, 16, 16, false, new FillMaterial(0xFF0000, 1)));
				box.boundBox = null;
			spherify(box.geometry, 333, 1 * .5);
			
			_template3D.camera.x = -333;
			

			box.geometry.upload( _template3D.stage3D.context3D);
			
			var wireFrame:WireFrame =  WireFrame.createEdges(box, 0xFFFFFF, 1, 1);
			_template3D.scene.addChild(wireFrame);
			SpawnerBundle.uploadResources( wireFrame.getResources(true) );
				
			var spectatorPerson:SimpleFlyController =new SimpleFlyController( 
						new EllipsoidCollider(GameSettings.SPECTATOR_RADIUS.x, GameSettings.SPECTATOR_RADIUS.y, GameSettings.SPECTATOR_RADIUS.z), 
						null ,
						stage, 
						_template3D.camera, 
						GameSettings.SPECTATOR_SPEED,
						GameSettings.SPECTATOR_SPEED_SHIFT_MULT);
			
						game.gameStates.spectator.addInstance(spectatorPerson).withPriority(SystemPriorities.postRender);
		
	
			
			game.engine.addSystem( spectatorPerson, SystemPriorities.postRender ) ;
		
			ticker = new FrameTickProvider(stage);
			ticker.add(tick);
			ticker.start();
			
		}
		
		private function tick(time:Number):void 
		{
				game.engine.update(time);
			_template3D.render();
		}
		
	}

}