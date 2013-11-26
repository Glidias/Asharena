package tests.islands 
{
	import alternativa.a3d.controller.SimpleFlyController;
	import alternativa.engine3d.core.Camera3D;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.materials.TextureMaterial;
	import alternativa.engine3d.materials.TextureZClipMaterial;
	import alternativa.engine3d.RenderingSystem;
	import alternativa.engine3d.resources.BitmapTextureResource;
	import alternativa.engine3d.resources.TextureResource;
	import alternterrain.objects.HierarchicalTerrainLOD;
	import alternterrain.objects.TerrainLOD;
	import arena.systems.islands.IslandChannels;
	import arena.systems.islands.IslandExploreSystem;
	import arena.systems.islands.IslandGeneration;
	import ash.tick.FrameTickProvider;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.system.ApplicationDomain;
	import flash.system.MessageChannel;
	import flash.system.WorkerDomain;
	import flash.system.WorkerState;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.ui.Keyboard;
	import flash.utils.ByteArray;
	import flash.utils.getDefinitionByName;
	import flash.utils.setTimeout;
	import spawners.grounds.CarribeanTextures;
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
	 * 1) Infinite traveling coordinates (to avoid "farlands problem") by resetting position in relation to HierTreeRegion size. (DONE)
	 * 2) 4 Level of TerrainLOD arranged hierahically at 4 levels of LOD scales. (DONE)
	 * 3) Generate out terrain procedurally with/without AS3 Workers while traveling around. Using AS3 Workers allows islands and their terrain to be generated seamelssly WITHOUT having to pause-load/freeze the game performance. Sample terrain at varying LOD scales to generate on the fly. (wip)
	 * @author Glidias
	 */
	[SWF(width='512',height='512',backgroundColor='#ffffff',frameRate='60')]
	public class IslandWorkerSystemTest extends MovieClip 
	{
		static public const DISTANCE:Number = 8192;// * .25;
		static public const FAR_CLIP_DIST:Number = 512*8;
		static public const ZONE_SIZE:Number = DISTANCE * 256;
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
		private var terrainLOD:HierarchicalTerrainLOD;
		
		
	
		
		
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
		
			_water = new WaterBase(NormalWaterAssets);
			_skybox = new SkyboxBase(ClearBlueSkyAssets, WaterBase.SIZE);
			
			bundleLoader = new SpawnerBundleLoader(stage, onSpawnerBundleLoaded, new <SpawnerBundle>[_skybox, _water, new SpawnerBundleA([IslandGenWorker,CarribeanTextures])]);
			bundleLoader.progressSignal.add( _preloader.setProgress );
			bundleLoader.loadBeginSignal.add( _preloader.setLabel );

		}
		
		private function onSpawnerBundleLoaded():void 
		{
			removeChild(_preloader);			
			_template3D.visible = true;
			_water.setupFollowCamera();
		
		
			int.MAX_VALUE
		
			
			game.engine.addSystem( new RenderingSystem(_template3D.scene), SystemPriorities.render );
		
			//5252710400
			_template3D.viewBackgroundColor = 0xFFFFFF;
				var dist:Number = DISTANCE;
			_template3D.camera.z = 128+72;	
			_template3D.camera.x = 0;// 971610521;// 97161052160;	
			_template3D.camera.y = 0;	
			
		//	_template3D.scene.x = Math.sqrt(int.MAX_VALUE);

		//	_template3D.camera.x = 64 * 256;
	//	_template3D.camera.y = 64 * 256;
				
			spectatorPerson =new SimpleFlyController( 
						new EllipsoidCollider(GameSettings.SPECTATOR_RADIUS.x, GameSettings.SPECTATOR_RADIUS.y, GameSettings.SPECTATOR_RADIUS.z), 
						null ,
						stage, 
						_template3D.camera, 
						27*512*256/60/60,
						144);
			
						game.gameStates.spectator.addInstance(spectatorPerson).withPriority(SystemPriorities.postRender);
		

			
			game.engine.addSystem( spectatorPerson, SystemPriorities.postRender ) ;
			
			terrainLOD  = new HierarchicalTerrainLOD();
			terrainLOD.setupPages(SpawnerBundle.context3D, 128, 0);
			
			var res:TextureResource  = new BitmapTextureResource( new CarribeanTextures.SAND().bitmapData );
		res.upload(SpawnerBundle.context3D);
		
		var mat:TextureZClipMaterial =  new TextureZClipMaterial(res ); 	
		mat.waterLevel = 1;

		var exploreSystem:IslandExploreSystem = new IslandExploreSystem(_template3D.camera, null, dist, 256, terrainLOD, _water.waterMaterial);
		exploreSystem.waterLevel = mat.waterLevel;
		exploreSystem.dummyTexture = mat
		exploreSystem.dummyTextureOverWater = new TextureMaterial(res);
		
		exploreSystem.zoneVisDistance = VIS_DIST;
			game.engine.addSystem(exploreSystem, SystemPriorities.preRender);
			
			_template3D.scene.addChild(terrainLOD);
			_water.addToScene(_template3D.scene);
				_skybox.addToScene(_template3D.scene);
				_water.plane.z = mat.waterLevel;
				
			
		
			//addChild(exploreSystem.debugShape);
			//addChild(exploreSystem.debugSprite);
			
			ticker = new FrameTickProvider(stage);
			ticker.add(tick);
			ticker.start();
		
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			
			
		}
		
		private function onKeyDown(e:KeyboardEvent):void 
		{
			if (e.keyCode === Keyboard.P) {
				LogTracer.log(terrainLOD.getTotalStats());
			}
			else if (e.keyCode === Keyboard.L) {
				spectatorPerson.maxPitch = -Math.PI*.5;
				spectatorPerson.minPitch = -Math.PI*.5;
			}
			else if (e.keyCode === Keyboard.I) {
				terrainLOD.matchDetailWithScale = !terrainLOD.matchDetailWithScale;
			}
		}

		
		private function tick(time:Number):void 
		{
			game.engine.update(time);
			var camera:Camera3D = _template3D.camera;
			
				_skybox.update(_template3D.camera);
			
			_template3D.camera.startTimer();

			// adjust offseted waterlevels
	
			_water.waterMaterial.update(_template3D.stage3D, _template3D.camera, _water.plane, hideFromReflection);
			_template3D.camera.stopTimer();

			// set to default waterLevels

			_template3D.render();
		}
		

		
	}

}