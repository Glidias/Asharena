package tests.water 
{
	import alternativa.a3d.controller.SimpleFlyController;
	import alternativa.engine3d.core.Camera3D;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.loaders.ParserA3D;
	import alternativa.engine3d.materials.FillMaterial;
	import alternativa.engine3d.materials.TextureMaterial;
	import alternativa.engine3d.materials.TextureZClipMaterial;
	import alternativa.engine3d.objects.Mesh;
	import alternativa.engine3d.primitives.Plane;
	import alternativa.engine3d.primitives.PlaneWavy;
	import alternativa.engine3d.RenderingSystem;
	import alternativa.engine3d.resources.BitmapTextureResource;
	import alternativa.engine3d.resources.TextureResource;
	import flash.geom.Vector3D;
	import spawners.arena.water.WaterUIAdjust;
	import util.ModelBundle;

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

	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.ui.Keyboard;
	import flash.utils.ByteArray;
	import flash.utils.getDefinitionByName;
	import flash.utils.setTimeout;
	import spawners.grounds.CarribeanTextures;
	import util.LogTracer;
	//import haxe.Log;
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
	
	/**
	 */
	[SWF(width='512',height='512',backgroundColor='#ffffff',frameRate='60')]
	public class WaterShipTest extends MovieClip 
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
		private var _modelBundle:ModelBundle;
		private var waterPlaneWavy:PlaneWavy;
		private var testPlane:PlaneWavy;
		private var shipModel:Mesh;

		
		public function WaterShipTest() 
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
		
			_water = new WaterBase(NormalWaterAssets, PlaneWavy);  //
			
			_skybox = new SkyboxBase(ClearBlueSkyAssets, WaterBase.SIZE);
			
			bundleLoader = new SpawnerBundleLoader(stage, onSpawnerBundleLoaded, new <SpawnerBundle>[
				_skybox, _water, new SpawnerBundleA([CarribeanTextures])
				, _modelBundle = new ModelBundle([])
			]);
			bundleLoader.progressSignal.add( _preloader.setProgress );
			bundleLoader.loadBeginSignal.add( _preloader.setLabel );

		}
		
		private function onSpawnerBundleLoaded():void 
		{
			removeChild(_preloader);			
			_template3D.visible = true;
		//	_water.setupFollowCamera();
	
			waterPlaneWavy = _water.plane as PlaneWavy;
			int.MAX_VALUE
			
			var plane:PlaneWavy = new PlaneWavy(500, 500, 32, 32, false, false, new FillMaterial(0xFF0000), new FillMaterial(0xFF0000));
			testPlane = plane;
			SpawnerBundle.uploadResources(plane.getResources());
			//_template3D.scene.addChild(plane);
			
			
		
			_modelBundle.processClasse(new ParserA3D(), Assets);
			_modelBundle.uploadAll();
			
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
			
		
			
			var res:TextureResource  = new BitmapTextureResource( new CarribeanTextures.SAND().bitmapData );
		res.upload(SpawnerBundle.context3D);
		
		var mat:TextureZClipMaterial =  new TextureZClipMaterial(res ); 	
		mat.waterLevel = 1;

	
		
		addChild( new WaterUIAdjust(_water.waterMaterial) );
			

			_water.addToScene(_template3D.scene);
				_skybox.addToScene(_template3D.scene);
				_water.plane.z = mat.waterLevel;
				
			
				_template3D.scene.addChild(shipModel=_modelBundle.getModel("ship"));
		
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
				
			}
			else if (e.keyCode === Keyboard.L) {
				spectatorPerson.maxPitch = -Math.PI*.5;
				spectatorPerson.minPitch = -Math.PI*.5;
			}
			else if (e.keyCode === Keyboard.I) {
				
			}
		}

		private var testPos:Vector3D = new Vector3D();
		
		private function tick(time:Number):void 
		{
			game.engine.update(time);
			if (waterPlaneWavy) waterPlaneWavy.update(time);
			if (testPlane) testPlane.update(time);
			//shipModel.rotationX += .002;
		//	waterPlaneWavy.updatePosition(
			
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

class Assets {
	
	[Embed(source="../../../bin/assets/models/pvk/vikingship/vikingship.a3d", mimeType="application/octet-stream")]
	public static var MODEL_ship:Class;
	
	[Embed(source="../../../bin/assets/models/pvk/vikingship/spritesheet.png")]
	public static var TEXTURE_ship:Class;
	
	
}