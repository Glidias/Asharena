package tests.pvp
{
	import alternativa.a3d.collisions.CollisionBoundNode;
	import alternativa.a3d.collisions.CollisionUtil;
	import alternativa.a3d.controller.SimpleFlyController;
	import alternativa.a3d.controller.ThirdPersonController;
	import alternativa.a3d.objects.ArrowLobMeshSet;
	import alternativa.a3d.objects.ArrowLobMeshSet2;
	import alternativa.a3d.objects.UVMeshSet;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.VertexAttributes;
	import alternativa.engine3d.loaders.ParserA3D;
	import alternativa.engine3d.materials.FillMaterial;
	import alternativa.engine3d.materials.Material;
	import alternativa.engine3d.materials.StandardMaterial;
	import alternativa.engine3d.materials.TextureMaterial;
	import alternativa.engine3d.materials.VertexLightTextureMaterial;
	import alternativa.engine3d.objects.Mesh;
	import alternativa.engine3d.primitives.Box;
	import alternativa.engine3d.primitives.Plane;
	import alternativa.engine3d.RenderingSystem;
	import alternativa.engine3d.resources.BitmapTextureResource;
	import alternterrain.CollidableMesh;
	import ash.core.Entity;
	import ash.tick.FrameTickProvider;
	import com.greensock.TweenLite;
	import components.Pos;
	import flash.display.Bitmap;
	import flash.display.MovieClip;
	import flash.geom.Vector3D;
	import systems.collisions.CollidableNode;
	import systems.collisions.EllipsoidCollider;
	import systems.collisions.GroundPlaneCollisionSystem;
	import systems.SystemPriorities;
	import util.SpawnerBundle;
	import util.SpawnerBundleLoader;
	import views.engine3d.MainView3D;
	import views.ui.bit101.PreloaderBar;
	
	import alternativa.engine3d.alternativa3d;
	use namespace alternativa3d;
	
	/**
	 * A boilerplate example from TestBuild3DPreload, containing the common stuff needed for all Ash-Arena games.
	 * 
	 * @author Glidias
	 */
	public class TestArrows extends MovieClip 
	{
		private var _template3D:MainView3D;
		private var game:TheGame;
		private var ticker:FrameTickProvider;
		private var _preloader:PreloaderBar = new PreloaderBar()
		private var bundleLoader:SpawnerBundleLoader;
		
		private var spectatorPerson:SimpleFlyController;
		private var arenaSpawner:ArenaSpawner;
		private var collisionScene:Object3D;
		private var arrows:ArrowLobMeshSet2;
		
		[Embed(source="../../../bin/assets/models/pvk/projectiles/arrow/model.a3d", mimeType="application/octet-stream")]
		private var MODEL:Class;
		
		[Embed(source="../../../bin/assets/models/pvk/projectiles/arrow/texture.jpg")]
		private var TEXTURE:Class;
		
		
		public function TestArrows() 
		{
			haxe.initSwc(this);
		
			
			ArrowLobMeshSet;
			game = new TheGame(stage);
	
			addChild( _template3D = new MainView3D() );
			_template3D.onViewCreate.add(onReady3D);
			
			UVMeshSet;
			_template3D.visible = false;
			addChild(_preloader);
		}
		
		
		// customise methods accordingly here...
				
		private function getSpawnerBundles():Vector.<SpawnerBundle> 
		{
			return new <SpawnerBundle>[];
		}
		
		private function setupViewSettings():void 
		{
			_template3D.viewBackgroundColor = 0xEEEEEE;
		}
		
		private function setupEnvironment():void 
		{
			// example visual scene
			var planeFloor:Mesh = new Plane(2048, 2048, 1, 1, false, false, null, new FillMaterial(0xBBBBBB, 1) );
			_template3D.scene.addChild(planeFloor);
			//arenaSpawner.addCrossStage(SpawnerBundle.context3D);
			SpawnerBundle.uploadResources(planeFloor.getResources(true, null));
			
			//var box:Box = new Box(26, 3, 3, 1, 1, 1, false, null);
			var parser:ParserA3D = new ParserA3D();
			parser.parse(new MODEL());
		
			var box:Mesh =   parser.objects[1] as Mesh || parser.objects[0] as Mesh;
			
			var mat:Material  =new TextureMaterial( new BitmapTextureResource(new TEXTURE().bitmapData) ) ;
			arrows = new ArrowLobMeshSet2(box.geometry, mat);
			//arrows.z = 1333;
			arrows.setGravity(266*3);
			startPosition = new Vector3D(0,0,0);
			endPosition = new Vector3D();
			for (var i:int = 0; i < 1522; i++) {
				TweenLite.delayedCall(i*.004, launchProjectile);
				//arrows.launchNewProjectileWithTimeSpan(startPosition, endPosition, 5);
			}
			
			arrows.setPermanentArrows();
			
			_template3D.scene.addChild ( arrows);
			
			SpawnerBundle.uploadResources(arrows.getResources(true, null));
		//throw new Error(planeFloor.geometry.getVertexBuffer(VertexAttributes.POSITION));
			// collision scene (can be something else)
			collisionScene = planeFloor;
			game.colliderSystem.collidable = CollisionUtil.getCollisionGraph(collisionScene);
			game.colliderSystem._collider.threshold = 0.00001;
			// (Optional) Enforced ground plane collision
			//game.gameStates.thirdPerson.addInstance( new GroundPlaneCollisionSystem(0, true) ).withPriority(SystemPriorities.resolveCollisions);

	
			spectatorPerson.setObjectPosXYZ(1100, 1400, 133);
			spectatorPerson.lookAt(new Vector3D(0, 0, 0));
		}
		
		private function launchProjectile():void 
		{
			var randAng:Number = Math.random() * Math.PI;
				var d:Number = Math.random() * 555 + 1410;
				
				endPosition.x = Math.cos(randAng)*d;
				endPosition.y =  Math.sin(randAng) * d;
				endPosition.z = 72 ;
				arrows.launchNewProjectile( startPosition, endPosition, 777);
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
			
			// (Optional) Go straight to 3rd person
			//game.gameStates.engineState.changeState("thirdPerson");
			
			
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
						GameSettings.SPECTATOR_SPEED_SHIFT_MULT);
			
						game.gameStates.spectator.addInstance(spectatorPerson).withPriority(SystemPriorities.postRender);
		
	
			
			
			
			setupEnvironment();
			setupStartingEntites();
			setupGameplay();

			
			ticker = new FrameTickProvider(stage);
			ticker.add(tick);
			ticker.start();
		}
		

		
		private var timePassed:Number = 0;
		private var startPosition:Vector3D;
		private var endPosition:Vector3D;
		private function tick(time:Number):void 
		{
			timePassed += time;
			game.engine.update(time);
			
			arrows.update(time);
			_template3D.render();
			
			if (timePassed >= 7) {
				timePassed = 0;
				//arrows.reset();
			}
		}
		
	}

}