package tests.pvp
{
	import alternativa.a3d.collisions.CollisionBoundNode;
	import alternativa.a3d.collisions.CollisionUtil;
	import alternativa.a3d.controller.SimpleFlyController;
	import alternativa.a3d.controller.ThirdPersonController;
	import alternativa.engine3d.core.Camera3D;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.lights.AmbientLight;
	import alternativa.engine3d.materials.FillMaterial;
	import alternativa.engine3d.materials.Material;
	import alternativa.engine3d.materials.NormalMapSpace;
	import alternativa.engine3d.materials.StandardTerrainMaterial2;
	import alternativa.engine3d.objects.Mesh;
	import alternativa.engine3d.primitives.Plane;
	import alternativa.engine3d.RenderingSystem;
	import alternativa.engine3d.resources.BitmapTextureResource;
	import alternterrain.CollidableMesh;
	import ash.core.Entity;
	import ash.tick.FrameTickProvider;
	import components.Pos;
	import flash.display.MovieClip;
	import spawners.arena.skybox.ClearBlueSkyAssets;
	import spawners.arena.skybox.SkyboxBase;
	import spawners.arena.terrain.MistEdge;
	import spawners.arena.terrain.TerrainBase;
	import spawners.arena.water.NormalWaterAssets;
	import spawners.arena.water.WaterBase;
	import spawners.grounds.CarribeanTextures;
	import spawners.grounds.GroundBase;
	
	import spawners.arena.terrain.TerrainTest;
	import systems.collisions.CollidableNode;
	import systems.collisions.EllipsoidCollider;
	import systems.collisions.GroundPlaneCollisionSystem;
	import systems.SystemPriorities;
	import util.SpawnerBundle;
	import util.SpawnerBundleLoader;
	import views.engine3d.MainView3D;
	import views.ui.bit101.PreloaderBar;
	
	//import spawners.arena.terrain.TerrainBase;
	
	//import alternativa.engine3d.alternativa3d;
	//use namespace alternativa3d;
	
	/**
	 * A boilerplate example from TestBuild3DPreload, containing the common stuff needed for all Ash-Arena games.
	 * 
	 * @author Glidias
	 */
	public class TestLoadTerrain extends MovieClip 
	{
		private var _template3D:MainView3D;
		private var game:TheGame;
		private var ticker:FrameTickProvider;
		private var _preloader:PreloaderBar = new PreloaderBar()
		private var bundleLoader:SpawnerBundleLoader;
		
		private var spectatorPerson:SimpleFlyController;
		private var arenaSpawner:ArenaSpawner;
		private var collisionScene:Object3D;
		private var _waterBase:WaterBase;
		private var _skyboxBase:SkyboxBase;
		private var _terrainBase:TerrainBase;
		
		public function TestLoadTerrain() 
		{
			haxe.initSwc(this);
		
			
			game = new TheGame(stage);
	
			addChild( _template3D = new MainView3D() );
			_template3D.onViewCreate.add(onReady3D);
			
			_template3D.visible = false;
			addChild(_preloader);
		}
		
		
		// customise methods accordingly here...
				
		private function getSpawnerBundles():Vector.<SpawnerBundle> 
		{
			return new <SpawnerBundle>[
			
				_terrainBase = new TerrainBase(TerrainTest, .5),
				_skyboxBase = new SkyboxBase(ClearBlueSkyAssets),
				_waterBase = new WaterBase(NormalWaterAssets),
				new GroundBase([CarribeanTextures])
			];
		}
		
		private function setupViewSettings():void 
		{
			_template3D.viewBackgroundColor = 0xDDDDDD;
		}
		
		
		
		private function setupTerrainMaterial():Material {
			var standardMaterial:StandardTerrainMaterial2 = new StandardTerrainMaterial2(new BitmapTextureResource( new CarribeanTextures.SAND().bitmapData ) , new BitmapTextureResource( _terrainBase.normalMap), null, null  );
		//	standardMaterial.uvMultiplier2 = _terrainBase.mapScale;
		
			//throw new Error([standardMaterial.opaquePass, standardMaterial.alphaThreshold, standardMaterial.transparentPass]);
			//standardMaterial.transparentPass = false;
			standardMaterial.normalMapSpace = NormalMapSpace.OBJECT;
			standardMaterial.specularPower = 0;
			standardMaterial.glossiness = 0;
			standardMaterial.mistMap = new BitmapTextureResource(new MistEdge.EDGE().bitmapData);
			StandardTerrainMaterial2.fogMode = 1;
			StandardTerrainMaterial2.fogFar =  _terrainBase.FAR_CLIPPING;
			StandardTerrainMaterial2.fogNear = 256 * 32;
			StandardTerrainMaterial2.fogColor = _template3D.viewBackgroundColor;
			standardMaterial.waterLevel = _waterBase.plane.z;
			standardMaterial.waterMode = 1;
			//standardMaterial.tileSize = 512;
			standardMaterial.pageSize = _terrainBase.loadedPage.heightMap.RowWidth - 1;
			
			return standardMaterial;
		}
		
		private function setupTerrainLighting():void {
			 //   _template3D.directionalLight.x = 0;
         //  _template3D.directionalLight.y = -100;
        //   _template3D. directionalLight.z = -100;
				 _template3D.directionalLight.x = 44;
             _template3D.directionalLight.y = -100;
             _template3D.directionalLight.z = 100;
             _template3D.directionalLight.lookAt(0, 0, 0);
			 _template3D.directionalLight.intensity = .65;
			 
			
             _template3D.ambientLight.intensity = 0.4;
           
		}
		
		private function setupEnvironment():void 
		{
			// example visual scene
			//var planeFloor:Mesh = new Plane(2048, 2048, 1, 1, false, false, null, new FillMaterial(0xBBBBBB, 1) );
		//	_template3D.scene.addChild(planeFloor);
		//	arenaSpawner.addCrossStage(SpawnerBundle.context3D);
		//	SpawnerBundle.uploadResources(planeFloor.getResources(true, null));
		
		
			
	
			setupTerrainLighting();
			setupTerrainAndWater();
		
			_template3D.camera.farClipping = _terrainBase.FAR_CLIPPING;
			// collision scene (can be something else)
			collisionScene = _terrainBase.terrain;
			game.colliderSystem.collidable = _terrainBase.terrainCollision;// collisionScene);
			game.colliderSystem._collider.threshold = 0.00001;
			// (Optional) Enforced ground plane collision
			//game.gameStates.thirdPerson.addInstance( new GroundPlaneCollisionSystem(0, true) ).withPriority(SystemPriorities.resolveCollisions);

		}
		
		private function setupTerrainAndWater():void 
		{
				_waterBase.plane.z =  (-64000 +84);//_terrainBase.loadedPage.Square.MinY + 444;
			_waterBase.addToScene(_template3D.scene);
			
			_skyboxBase.addToScene(_template3D.scene);
			_waterBase.setupFollowCamera();
			
			var terrainMat:Material = setupTerrainMaterial();
			_template3D.scene.addChild( _terrainBase.getNewTerrain(terrainMat , 0, 1) );
		_terrainBase.terrain.waterLevel = _waterBase.plane.z;
		//	_terrainBase.terrain.debug = true;
			
				var hWidth:Number = (_terrainBase.terrain.boundBox.maxX - _terrainBase.terrain.boundBox.minX) * .5 * _terrainBase.terrain.scaleX;
					_terrainBase.terrain.x -= hWidth;
			_terrainBase.terrain.y += hWidth;
		//throw new Error([(camera.x - terrainLOD.x) / terrainLOD.scaleX, -(camera.y - terrainLOD.y) / terrainLOD.scaleX]);
		///*
		var camera:Camera3D = _template3D.camera;
		_terrainBase.terrain.detail = 1;
	
				camera.z = _terrainBase.sampleObjectPos(camera) ;
			camera.z *=  _terrainBase.terrain.scaleZ;
				//if (camera.z < _waterBase.plane.z) camera.z = _waterBase.plane.z;
			camera.z += 122;
			spectatorPerson.setObjectPosXYZ(camera.x, camera.y, camera.z);
		//	*/
	
		_waterBase.plane.z *= _terrainBase.TERRAIN_HEIGHT_SCALE;
		}
		
		private function setupStartingEntites():void {
			
			// Register any custom skins needed for this game
			//arenaSpawner.setupSkin(, ArenaSpawner.RACE_SAMNIAN);
			

			// spawn any beginning entieies
			//arenaSpawner.addGladiator(
		}
		
		private function setupGameplay():void 
		{
			// Third person
			///*
			var dummyEntity:Entity = arenaSpawner.getNullEntity(); // arenaSpawner.getPlayerBoxEntity(SpawnerBundle.context3D);
			// arenaSpawner.getNullEntity();
			dummyEntity.get(Pos).z = 72*.5;
			game.engine.addEntity(dummyEntity);
			//*/
			// possible to  set raycastScene  parameter to something else besides "collisionScene"...
			var thirdPerson:ThirdPersonController = new ThirdPersonController(stage, _template3D.camera, collisionScene, dummyEntity.get(Object3D) as Object3D, dummyEntity.get(Object3D) as Object3D, dummyEntity );
			game.gameStates.thirdPerson.addInstance(thirdPerson).withPriority(SystemPriorities.postRender);
	
			game.gameStates.engineState.changeState("spectator");
		}
		
		
		// boilerplate below...
		
		private function onReady3D():void 
		{
			SpawnerBundle.context3D = _template3D.stage3D.context3D;
			
			setupViewSettings();
			
			arenaSpawner = new ArenaSpawner(game.engine, game.keyPoll);
			
			bundleLoader = new SpawnerBundleLoader(stage, onSpawnerBundleLoaded, getSpawnerBundles() );
			bundleLoader.progressSignal.add( _preloader.setProgress );
			bundleLoader.loadBeginSignal.add( _preloader.setLabel );		
		}
		
		
		private function onSpawnerBundleLoaded():void 
		{
			removeChild(_preloader);			
			_template3D.visible = true;
			
			
			game.engine.addSystem( new RenderingSystem(_template3D.scene), SystemPriorities.render );

			
			spectatorPerson =new SimpleFlyController( 
						new EllipsoidCollider(GameSettings.SPECTATOR_RADIUS.x, GameSettings.SPECTATOR_RADIUS.y, GameSettings.SPECTATOR_RADIUS.z), 
						null ,
						stage, 
						_template3D.camera, 
						GameSettings.SPECTATOR_SPEED,
						GameSettings.SPECTATOR_SPEED_SHIFT_MULT*3);
			
						game.gameStates.spectator.addInstance(spectatorPerson).withPriority(SystemPriorities.postRender);
		
	
			
			
			
			setupEnvironment();
			setupStartingEntites();
			setupGameplay();

			
			ticker = new FrameTickProvider(stage);
			ticker.add(tick);
			ticker.start();
		}
		

		
		private function tick(time:Number):void 
		{
			
			game.engine.update(time);
			
	
			var camera:Camera3D = _template3D.camera;
			
			_skyboxBase.update(_template3D.camera);
			
			_template3D.camera.startTimer();

			// adjust offseted waterlevels
	
			_waterBase.waterMaterial.update(_template3D.stage3D, _template3D.camera, _waterBase.plane, null);
			_template3D.camera.stopTimer();

			// set to default waterLevels

			_template3D.render();
		}
		
	}

}