package tests.pvp
{
	import alternativa.a3d.collisions.CollisionBoundNode;
	import alternativa.a3d.collisions.CollisionUtil;
	import alternativa.a3d.controller.SimpleFlyController;
	import alternativa.a3d.controller.ThirdPersonController;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.materials.FillMaterial;
	import alternativa.engine3d.materials.Material;
	import alternativa.engine3d.objects.Decal;
	import alternativa.engine3d.objects.Mesh;
	import alternativa.engine3d.objects.MeshSetClone;
	import alternativa.engine3d.objects.MeshSetClonesContainer;
	import alternativa.engine3d.primitives.Plane;
	import alternativa.engine3d.RenderingSystem;
	import alternterrain.CollidableMesh;
	import ash.core.Entity;
	import ash.tick.FrameTickProvider;
	import components.Pos;
	import flash.display.MovieClip;
	import systems.collisions.CollidableNode;
	import systems.collisions.EllipsoidCollider;
	import systems.collisions.GroundPlaneCollisionSystem;
	import systems.SystemPriorities;
	import util.SpawnerBundle;
	import util.SpawnerBundleLoader;
	import views.engine3d.MainView3D;
	import views.ui.bit101.PreloaderBar;
	
	//import alternativa.engine3d.alternativa3d;
	//use namespace alternativa3d;
	
	/**
	 * A boilerplate example from TestBuild3DPreload, containing the common stuff needed for all Ash-Arena games.
	 * 
	 * @author Glidias
	 */
	public class TestDecalMeshSet extends MovieClip 
	{
		private var _template3D:MainView3D;
		private var game:TheGame;
		private var ticker:FrameTickProvider;
		private var _preloader:PreloaderBar = new PreloaderBar()
		private var bundleLoader:SpawnerBundleLoader;
		
		private var spectatorPerson:SimpleFlyController;
		private var arenaSpawner:ArenaSpawner;
		private var collisionScene:Object3D;
		
		public function TestDecalMeshSet() 
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
			return new <SpawnerBundle>[];
		}
		
		private function setupViewSettings():void 
		{
			_template3D.viewBackgroundColor = 0xDDDDDD;
		}
		
		private function setupEnvironment():void 
		{
			// example visual scene
			var planeFloor:Mesh = new Plane(2048, 2048, 1, 1, false, false, null, new FillMaterial(0xBBBBBB, 1) );
			_template3D.scene.addChild(planeFloor);
			//arenaSpawner.addCrossStage(SpawnerBundle.context3D);
			SpawnerBundle.uploadResources(planeFloor.getResources(true, null));
			
			
			var mat:Material = new FillMaterial(0xFF0000, 1);
			
			var meshSetClonesContainer:MeshSetClonesContainer = new MeshSetClonesContainer(new Plane(128, 128, 1, 1, false, false, null, null ) , mat, 0, null, (1| MeshSetClonesContainer.FLAG_PREVENT_Z_FIGHTING ));

			var c:MeshSetClone = meshSetClonesContainer.addClone( meshSetClonesContainer.createClone() );
			
			c = meshSetClonesContainer.addClone( meshSetClonesContainer.createClone() );
			c.root.x = 256;
			c  = meshSetClonesContainer.addClone( meshSetClonesContainer.createClone() );
			c.root.x = 512;
			c  = meshSetClonesContainer.addClone( meshSetClonesContainer.createClone() );
			c.root.x = 960+55;
			
			SpawnerBundle.uploadResources(meshSetClonesContainer.getResources());
			_template3D.scene.addChild(meshSetClonesContainer);
				
				
			var decal:Decal = new Decal();
			decal.geometry = new Plane(128, 128, 1, 1, false, false, mat, mat ).geometry;
			decal.addSurface( mat, 0, decal.geometry.numTriangles);
				SpawnerBundle.uploadResources(decal.getResources());
					_template3D.scene.addChild(decal);
					decal.x = 0;
					decal.y = 140;
			
			// collision scene (can be something else)
			collisionScene = planeFloor;
			game.colliderSystem.collidable = CollisionUtil.getCollisionGraph(collisionScene);
			game.colliderSystem._collider.threshold = 0.00001;
			// (Optional) Enforced ground plane collision
			//game.gameStates.thirdPerson.addInstance( new GroundPlaneCollisionSystem(0, true) ).withPriority(SystemPriorities.resolveCollisions);

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
		

		
		private function tick(time:Number):void 
		{
			game.engine.update(time);
			_template3D.render();
		}
		
	}

}
