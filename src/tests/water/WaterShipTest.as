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
	import com.flashartofwar.fcss.utils.FSerialization;
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.geom.Matrix3D;
	import spawners.ModelBundle;
	import spawners.arena.models.VikingShip;

	import flash.geom.Vector3D;
	import spawners.arena.water.WaterUIAdjust;


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
		private var shipModel:Object3D;

		private var waterSettings:String = "waterMaterial { waterTintAmount:0; fresnelMultiplier:0.43; waterColorR:0; waterColorG:0.15; waterColorB:0.115; reflectionMultiplier:0; perturbReflectiveBy:0.5; perturbRefractiveBy:0.5;  }";
		
		public function WaterShipTest() 
		{
		//	haxe
		
			haxe.initSwc(this);

			game = new TheGame(stage);
	
			addChild( _template3D = new MainView3D() );
			_template3D.onViewCreate.add(onReady3D);
			
			_template3D.visible = false;
			addChild(_preloader);
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		
		}
		
		private function onReady3D():void 
		{
			
			SpawnerBundle.context3D = _template3D.stage3D.context3D;
			
				_template3D.camera.farClipping = FAR_CLIP_DIST*256;
		
				WaterBase.SEGMENTS = 200;
				WaterBase.SCALER *= .01;
				WaterBase.SIZE = 10000;
				WaterBase.UV_SCALER *= .01;
			_water = new WaterBase(NormalWaterAssets, PlaneWavy);  //
			
			_skybox = new SkyboxBase(ClearBlueSkyAssets, WaterBase.SIZE);
			
			bundleLoader = new SpawnerBundleLoader(stage, onSpawnerBundleLoaded, new <SpawnerBundle>[
				_skybox, _water, new SpawnerBundleA([CarribeanTextures])
				, _modelBundle = new ModelBundle(VikingShip)
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
			_water.waterMaterial.forceRenderPriority = -1;
			
			FSerialization.applyStyle(_water.waterMaterial, FSerialization.parseStylesheet(waterSettings).getStyle("waterMaterial") );
		
			windDirUV = waterPlaneWavy.windDir.clone();
			windDirUV.normalize();
			windDirUV.scaleBy(.003);
			_water.waterMaterial.windDirectionUV = windDirUV;
			
			
			var plane:PlaneWavy = new PlaneWavy(500, 500, 32, 32, false, false, new FillMaterial(0xFF0000), new FillMaterial(0xFF0000));
			testPlane = plane;
		//	plane.randomiseVertices();
			
			//_water.waterMaterial.windShadeDirector = plane.windDir;
			SpawnerBundle.uploadResources(plane.getResources());
			//_template3D.scene.addChild(plane);
			
			

			
			game.engine.addSystem( new RenderingSystem(_template3D.scene), SystemPriorities.render );
		
			//5252710400
			_template3D.viewBackgroundColor = 0xFFFFFF;
				var dist:Number = DISTANCE;
			_template3D.camera.z = 128+112;	
			_template3D.camera.x = 0;// 971610521;// 97161052160;	
			_template3D.camera.y = 0;	
			_template3D.camera.rotationX = -Math.PI * .5;
		
			_template3D.camera.rotationZ = -Math.PI * .25;
			
		//	_template3D.scene.x = Math.sqrt(int.MAX_VALUE);

		//	_template3D.camera.x = 64 * 256;
	//	_template3D.camera.y = 64 * 256;
				
	var speedCam:Number = 27 * 512 * 256 / 60 / 60  * .5;
			spectatorPerson =new SimpleFlyController( 
						new EllipsoidCollider(GameSettings.SPECTATOR_RADIUS.x, GameSettings.SPECTATOR_RADIUS.y, GameSettings.SPECTATOR_RADIUS.z), 
						null ,
						stage, 
						_template3D.camera, 
						speedCam,
						2);
			
						game.gameStates.spectator.addInstance(spectatorPerson).withPriority(SystemPriorities.postRender);
		

			
			game.engine.addSystem( spectatorPerson, SystemPriorities.postRender ) ;
			
		
			
			var res:TextureResource  = new BitmapTextureResource( new CarribeanTextures.SAND().bitmapData );
		res.upload(SpawnerBundle.context3D);
		
		var mat:TextureZClipMaterial =  new TextureZClipMaterial(res ); 	
		mat.waterLevel = 1;

	
		
		addChild(_waterUIAdjust  = new WaterUIAdjust(_water.waterMaterial) );
			

			_water.addToScene(_template3D.scene);
				_skybox.addToScene(_template3D.scene);
				_water.plane.z = mat.waterLevel;
				
			//shipModel = new Object3D();
			
			var child:Object3D = shipModel = _modelBundle.getSubModelPacket("ship").model;
			//child.rotationY = Math.PI * .5;
				_template3D.scene.addChild(child);
				
				shipModel.x = 500;
				shipModel.y = 500;
		
			//addChild(exploreSystem.debugShape);
			//addChild(exploreSystem.debugSprite);
			
			ticker = new FrameTickProvider(stage);
			ticker.add(tick);
			ticker.start();
		
			
			
			
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
				Clipboard.generalClipboard.setData( ClipboardFormats.TEXT_FORMAT , _waterUIAdjust.saveMaterialSettings() );
			}
		}

		private var testPos:Vector3D = new Vector3D();
		private var accumT:Number = 0;
		private var windDirUV:Vector3D = new Vector3D();
		private var _waterUIAdjust:WaterUIAdjust;
		
		

		
		
	//	/*
		private function adjustBoatOrientation2():void {
			var NUM_DETAILS:int = WaterBase.SEGMENTS + 1;
			var MESH_SIZE:Number = _water.plane.boundBox.maxX * 2;
			var segmentSize:Number = MESH_SIZE / WaterBase.SEGMENTS;
			 var duckX:Number = shipModel.x;
            var duckY:Number = shipModel.y;
            var i:int = NUM_DETAILS * (duckX + 0.5 * MESH_SIZE) / MESH_SIZE;
            var j:int = NUM_DETAILS * (duckY + 0.5 * MESH_SIZE) / MESH_SIZE;
            i = Math.min (NUM_DETAILS - 2, Math.max (1, i));
            j = Math.min (NUM_DETAILS - 2, Math.max (1, j));
            var duckZ:Number = waterPlaneWavy.getHeightAt( shipModel.x, shipModel.y);
			
			
			        // water normal (idea stolen from reflection code,
            // so I'm not even sure this is correct formula :)
            var n:Vector3D = new Vector3D (
                waterPlaneWavy.getHeightAt( i*segmentSize,(j+1)*segmentSize) - waterPlaneWavy.getHeightAt( i*segmentSize,(j-1)*segmentSize) * 0.010,
                ( waterPlaneWavy.getHeightAt( (i+1)*segmentSize,j*segmentSize) - waterPlaneWavy.getHeightAt( (i-1)*segmentSize,j*segmentSize) ) * 0.025,
                1
            ); n.normalize ();
			
		

            // duck tilt matrix corresponding to this normal
            var m:Matrix3D = new Matrix3D();
            var r:Vector3D = n.crossProduct (Vector3D.Z_AXIS);
		//	/*
            if (r.length > 0.00001) {
                r.normalize ();
                m.prependRotation (
                    Math.acos (n.dotProduct (Vector3D.Z_AXIS)) * 180 / Math.PI,
                    r
                );
            }
			m.appendRotation(90, Vector3D.X_AXIS);

            shipModel.matrix = m;
			//*/
			
			shipModel.x = duckX;
			shipModel.y = duckY;
			shipModel.z = duckZ + 20;
			shipModel.rotationZ  = 0;

		}
		//*/
		
		private function tick(time:Number):void 
		{
			game.engine.update(time);
			
			if (waterPlaneWavy) {
				
				waterPlaneWavy.update(time);
				waterPlaneWavy.z = shipModel.z;
				
			//	adjustBoatOrientation2();
			}
			if (testPlane) testPlane.update(time);
			//shipModel.rotationX += .002;
		//	waterPlaneWavy.updatePosition(
		accumT += time;
	//	shipModel.rotationX= Math.cos( accumT / 400 ) * 6 *Math.PI/180;
		//	shipModel.rotationY= Math.cos( accumT / 300 ) * 6*Math.PI/180;
			
			var camera:Camera3D = _template3D.camera;
			
				_skybox.update(_template3D.camera);
			
			_template3D.camera.startTimer();

			// adjust offseted waterlevels
	
			_water.waterMaterial.update(_template3D.stage3D, _template3D.camera, _water.plane, hideFromReflection);
			_template3D.camera.stopTimer();

			if (waterPlaneWavy) {
				waterPlaneWavy.z = 0;
				
				adjustBoatOrientation2();
			}
			
			// set to default waterLevels
			
			//shipModel.z = 0;
			_template3D.render();
		}
		

		
	}

}

