package  
{
	import alternativa.engine3d.animation.AnimationClip;
	import alternativa.engine3d.animation.keys.Track;
	import alternativa.engine3d.animation.keys.TransformTrack;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.VertexAttributes;
	import alternativa.engine3d.loaders.ParserA3D;
	import alternativa.engine3d.loaders.ParserMaterial;
	import alternativa.engine3d.loaders.TexturesLoader;
	import alternativa.engine3d.materials.Material;
	import alternativa.engine3d.materials.TextureMaterial;
	import alternativa.engine3d.materials.TextureZClipMaterial;
	import alternativa.engine3d.objects.Skin;
	import alternativa.engine3d.objects.Surface;
	import alternativa.engine3d.RenderingSystem;
	import alternativa.engine3d.resources.ExternalTextureResource;
	import alternativa.engine3d.resources.TextureResource;
	import alternterrain.CollidableImpl;
	import ash.core.Entity;
	import components.Rot;
	import examples.WaterAndTerrain3rdPerson;
	import spawners.arena.GladiatorBundle;
	import util.geom.Geometry;
	import util.SpawnerBundle;
	import util.SpawnerBundleLoader;

	import components.Pos;
	import flash.Boot;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.net.registerClassAlias;
	import flash.utils.ByteArray;
	import systems.player.a3d.AnimationManager;
	import systems.player.a3d.GladiatorStance;
	import systems.rendering.RenderNode;
	import systems.SystemPriorities;
	import views.Alternativa3DView;

	/**
	 * This is running under AS3 using alternativa3d engine.
	 * @author Glenn Ko
	 */
	public class TheGameAS3 extends TheGame
	{
	
		private var arenaSpawner:ArenaSpawner;	
		private var _view:WaterAndTerrain3rdPerson = new WaterAndTerrain3rdPerson();
		private var spawnerBundle:GladiatorBundle;
		
		public function TheGameAS3(stage:Stage) 
		{
			super(stage);
			
			registerClassAlias("String", String);
						
	
			
			stage.addChild(_view);
			
			_view.addEventListener(Event.COMPLETE, onViewInitialized);
			
					
			Boot.getTrace().blendMode = "invert";
			stage.addChild( Boot.getTrace() );
		}
		
		private function onViewInitialized(e:Event):void 
		{
			(e.currentTarget as IEventDispatcher).removeEventListener(e.type, onViewInitialized);
				
			SpawnerBundle.context3D = _view.stage3D.context3D;
			
			spawnerBundle = new GladiatorBundle(arenaSpawner);
			new SpawnerBundleLoader(stage, begin, new <SpawnerBundle>[spawnerBundle]);
			
			begin();
		}
		
		private function begin():void 
		{
			spawnerBundle.textureMat.waterMode = true;

			engine.addSystem( new RenderingSystem(_view.scene, _view), SystemPriorities.render );
		

			arenaSpawner.addGladiator(ArenaSpawner.RACE_SAMNIAN, stage).add(keyPoll);
			_view.inject(arenaSpawner.currentPlayer, arenaSpawner.currentPlayer, arenaSpawner.currentPlayerEntity.get(Pos) as Pos,  arenaSpawner.currentPlayerEntity.get(Rot) as Rot, arenaSpawner.currentPlayerSkin,spawnerBundle.textureMat);
			
			startGame();
		}
	
		
		private function startGame():void {
					
			if (colliderSystem) {
				/*
				var geom:Geometry = new Geometry();
				geom.setVertices(  _view.box.geometry.getAttributeValues(VertexAttributes.POSITION)  );
				geom.setIndices(_view.box.geometry.indices);
				colliderSystem.collidable = geom;
				*/		
				colliderSystem._collider.threshold = 0.0001;
				colliderSystem.collidable = new CollidableImpl(_view.terrainLOD, _view.getWaterPlane());
			}
			
			gameStates.engineState.changeState( "thirdPerson");
				
			// Setup rendering system
			ticker.start();	
		}

		
		override public function getSpawner():Spawner {	
			return (arenaSpawner=new ArenaSpawner(engine));
		}
			
		
		
	}
}
