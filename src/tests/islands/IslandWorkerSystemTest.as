package tests.islands 
{
	import alternativa.a3d.controller.SimpleFlyController;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.RenderingSystem;
	import alternterrain.objects.HierarchicalTerrainLOD;
	import alternterrain.objects.TerrainLOD;
	import arena.systems.islands.IslandChannels;
	import arena.systems.islands.IslandExploreSystem;
	import arena.systems.islands.IslandGeneration;
	import ash.tick.FrameTickProvider;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.system.ApplicationDomain;
	import flash.system.MessageChannel;
	import flash.system.WorkerDomain;
	import flash.system.WorkerState;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.utils.ByteArray;
	import flash.utils.getDefinitionByName;
	import flash.utils.setTimeout;
	import util.LogTracer;
	//import haxe.Log;
	import spawners.arena.IslandGenWorker;
	import spawners.arena.skybox.ClearBlueSkyAssets;
	import spawners.arena.skybox.SkyboxBase;
	import spawners.arena.water.NormalWaterAssets;
	import spawners.arena.water.WaterBase;
	import systems.collisions.EllipsoidCollider;
	import systems.SystemPriorities;
	import terraingen.island.MapGenArena;
	import util.SpawnerBundle;
	import util.SpawnerBundleA;
	import util.SpawnerBundleLoader;
	import views.engine3d.MainView3D;
	import views.ui.bit101.PreloaderBar;
	import flash.system.Worker;
	
	/**
	 * Generate out island Meshes procedurally with/without AS3 Workers while traveling around. Using AS3 Workers allows islands to be generated seamelssly WITHOUT having to pause-load/freeze the game performance.
	 * @author Glidias
	 */
	public class IslandWorkerSystemTest extends MovieClip 
	{
		static public const DISTANCE:Number = 8192;// * .25;
		static public const FAR_CLIP_DIST:Number = 512*5;
		static private const VIS_DIST:Number = .25;
		private var _template3D:MainView3D;
		private var game:TheGame;
		private var ticker:FrameTickProvider;
		private var _preloader:PreloaderBar = new PreloaderBar()
		private var bundleLoader:SpawnerBundleLoader;
		
		private var _water:WaterBase;
		private var _skybox:SkyboxBase;
		
		private var hideFromReflection:Vector.<Object3D> = null;// new Vector.<Object3D>();
		private var spectatorPerson:SimpleFlyController;
	
		
		
		public function IslandWorkerSystemTest() 
		{
		//	haxe
		
			haxe.initSwc(this);

			game = new TheGame(stage);
	
			addChild( _template3D = new MainView3D() );
			_template3D.onViewCreate.add(onReady3D);
			
			_template3D.visible = false;
			addChild(_preloader);
		}
		
		private function onReady3D():void 
		{
			
			SpawnerBundle.context3D = _template3D.stage3D.context3D;
			
				_template3D.camera.farClipping = FAR_CLIP_DIST*256;
			_skybox = new SkyboxBase(ClearBlueSkyAssets, _template3D.camera.farClipping*10);
			_water = new WaterBase(NormalWaterAssets);
			
			
			bundleLoader = new SpawnerBundleLoader(stage, onSpawnerBundleLoaded, new <SpawnerBundle>[_skybox, _water, new SpawnerBundleA([IslandGenWorker])]);
			bundleLoader.progressSignal.add( _preloader.setProgress );
			bundleLoader.loadBeginSignal.add( _preloader.setLabel );

		}
		
		private function onSpawnerBundleLoaded():void 
		{
			removeChild(_preloader);			
			_template3D.visible = true;
			
		
			
		
			
			game.engine.addSystem( new RenderingSystem(_template3D.scene), SystemPriorities.render );
			_water.addToScene(_template3D.scene);
				_skybox.addToScene(_template3D.scene);
			
				var dist:Number = DISTANCE;
			_template3D.camera.z = 128+72;	
			_template3D.camera.x = 0;	
			_template3D.camera.y = 0;	
		//	_template3D.camera.x = 64 * 256;
	//	_template3D.camera.y = 64 * 256;
				
			spectatorPerson =new SimpleFlyController( 
						new EllipsoidCollider(GameSettings.SPECTATOR_RADIUS.x, GameSettings.SPECTATOR_RADIUS.y, GameSettings.SPECTATOR_RADIUS.z), 
						null ,
						stage, 
						_template3D.camera, 
						27*512*256/60/60,
						34);
			
						game.gameStates.spectator.addInstance(spectatorPerson).withPriority(SystemPriorities.postRender);
		

			
			game.engine.addSystem( spectatorPerson, SystemPriorities.postRender ) ;
			
			var terrainLOD:HierarchicalTerrainLOD  = new HierarchicalTerrainLOD();
			terrainLOD.setupPages(SpawnerBundle.context3D, 128, 0);
		var exploreSystem:IslandExploreSystem = new IslandExploreSystem(_template3D.camera, null, dist, 256, terrainLOD);
		exploreSystem.zoneVisDistance = VIS_DIST;
			game.engine.addSystem(exploreSystem, SystemPriorities.postRender);
			
			_template3D.scene.addChild(terrainLOD);
			terrainLOD.z = 14;
		
			addChild(exploreSystem.debugShape);

			
			ticker = new FrameTickProvider(stage);
			ticker.add(tick);
			ticker.start();
		
			
			
			
		}

		
		private function tick(time:Number):void 
		{
			game.engine.update(time);
			


			_template3D.camera.startTimer();

			// adjust offseted waterlevels

			_water.waterMaterial.update(_template3D.stage3D, _template3D.camera, _water.plane, hideFromReflection);
			_template3D.camera.stopTimer();

			// set to default waterLevels

			_template3D.render();
		}
		

		
	}

}