package tests.islands 
{
	import alternativa.a3d.controller.SimpleFlyController;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.RenderingSystem;
	import arena.systems.islands.IslandChannels;
	import arena.systems.islands.IslandExploreSystem;
	import arena.systems.islands.IslandGeneration;
	import ash.tick.FrameTickProvider;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.system.MessageChannel;
	import flash.system.WorkerDomain;
	import flash.system.WorkerState;
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
		private var _template3D:MainView3D;
		private var game:TheGame;
		private var ticker:FrameTickProvider;
		private var _preloader:PreloaderBar = new PreloaderBar()
		private var bundleLoader:SpawnerBundleLoader;
		
		private var _water:WaterBase;
		private var _skybox:SkyboxBase;
		
		private var hideFromReflection:Vector.<Object3D> = null;// new Vector.<Object3D>();
	
		
		
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
			
			_template3D.camera.z = 120;	
				
			var spectatorPerson:SimpleFlyController =new SimpleFlyController( 
						new EllipsoidCollider(GameSettings.SPECTATOR_RADIUS.x, GameSettings.SPECTATOR_RADIUS.y, GameSettings.SPECTATOR_RADIUS.z), 
						null ,
						stage, 
						_template3D.camera, 
						GameSettings.SPECTATOR_SPEED,
						GameSettings.SPECTATOR_SPEED_SHIFT_MULT);
			
						game.gameStates.spectator.addInstance(spectatorPerson).withPriority(SystemPriorities.postRender);
		
	
			
			game.engine.addSystem( spectatorPerson, SystemPriorities.postRender ) ;
			

			IslandExploreSystem;
			
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