package tests.pvp
{
	import alternativa.a3d.collisions.CollisionBoundNode;
	import alternativa.a3d.collisions.CollisionUtil;
	import alternativa.a3d.controller.SimpleFlyController;
	import alternativa.a3d.controller.ThirdPersonController;
	import alternativa.a3d.objects.ArrowLobMeshSet;
	import alternativa.a3d.objects.UVMeshSet;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.VertexAttributes;
	import alternativa.engine3d.materials.FillMaterial;
	import alternativa.engine3d.materials.Material;
	import alternativa.engine3d.objects.Mesh;
	import alternativa.engine3d.objects.MeshSet;
	import alternativa.engine3d.primitives.Box;
	import alternativa.engine3d.primitives.Plane;
	import alternativa.engine3d.RenderingSystem;
	import alternativa.engine3d.resources.Geometry;
	import alternativa.engine3d.spriteset.util.SpriteGeometryUtil;
	import alternativa.engine3d.utils.GeometryUtil;
	import alternterrain.CollidableMesh;
	import ash.core.Entity;
	import ash.tick.FrameTickProvider;
	import components.Pos;
	import flash.display.MovieClip;
	import flash.events.KeyboardEvent;
	import flash.geom.Vector3D;
	import flash.ui.Keyboard;
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
	public class TestTrajectoryDrawer extends MovieClip 
	{
		private var _template3D:MainView3D;
		private var game:TheGame;
		private var ticker:FrameTickProvider;
		private var _preloader:PreloaderBar = new PreloaderBar()
		private var bundleLoader:SpawnerBundleLoader;
		
		private var spectatorPerson:SimpleFlyController;
		private var arenaSpawner:ArenaSpawner;
		private var collisionScene:Object3D;
		private var arrows:UVMeshSet;
		
		public function TestTrajectoryDrawer() 
		{
			haxe.initSwc(this);
		
			
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
			_template3D.viewBackgroundColor = 0xDDDDDD;
		}
		
		private function alignGeometry(geom:Geometry):void {
			var ve:Vector.<Number> = geom.getAttributeValues(VertexAttributes.POSITION);
			var len:int = ve.length;
			for (var i:int = 0; i < len; i += 3) {
				ve[i] += .5;
			}
			geom.setAttributeValues(VertexAttributes.POSITION, ve);
		}
		
		private function createDoubleSidedPlane(mat:Material):Mesh {
			var plane1:Plane = new Plane(1,4,24,1,false,false,mat,mat);
			var plane2:Plane =new Plane(1,4,24,1,false,true,mat,mat);
			var root:Object3D = new Object3D();
			root.addChild(plane1);
			root.addChild(plane2);
			var combine:MeshSet = new MeshSet(root);
			return combine;
		}
		
		
		
		private function setupEnvironment():void 
		{
			// example visual scene
			var planeFloor:Mesh = new Plane(2048, 2048, 1, 1, false, false, null, new FillMaterial(0xBBBBBB, .4) );
			_template3D.scene.addChild(planeFloor);
			//arenaSpawner.addCrossStage(SpawnerBundle.context3D);
			SpawnerBundle.uploadResources(planeFloor.getResources(true, null));
			
			var mat:Material = new FillMaterial(0x0000FF, .1);
			var box:Mesh =  createDoubleSidedPlane(mat) ;// new Plane(1, 15, 12, 1, true, false, mat, mat);
			//var box:Box =  new Box(1, 16,16, 12,1,1, false, mat);
			alignGeometry(box.geometry);
			box.calculateBoundBox();
			arrows = new UVMeshSet(box.geometry, mat);
			arrows.setGravity(466*3);
			
			var startPosition:Vector3D = new Vector3D(0,0,0);
			var endPosition:Vector3D = new Vector3D(1024, 0, 0);
			for (var i:int = 0; i < 333; i++) {
				endPosition.x = Math.random() * 1222;
				endPosition.y = Math.random() * 1222;
				endPosition.z = Math.random() * 444;
				arrows.launchNewProjectile( startPosition, endPosition);
			}
			
			_template3D.scene.addChild ( arrows);
			var testBox:Object3D = 	_template3D.scene.addChild ( box)
			testBox.scaleX = 1024;
			//testBox.scaleY = 44;
			//testBox.z = 11;
			arrows.z = 11;
			arrows.x = 100;
			//testBox.visible = false;
			//arrows.setGravity(0);
			
			SpawnerBundle.uploadResources(testBox.getResources(true, null));
			SpawnerBundle.uploadResources(arrows.getResources(true, null));
		//throw new Error(planeFloor.geometry.getVertexBuffer(VertexAttributes.POSITION));
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
			//game.gameStates.engineState.changeState("thirdPerson");
			
			
			game.gameStates.engineState.changeState("spectator");
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		}
		
		private function onKeyDown(e:KeyboardEvent):void 
		{
			if (e.keyCode === Keyboard.PAGE_UP) {
				arrows.gravity-=44;
			}
			else if (e.keyCode === Keyboard.PAGE_DOWN) {
				arrows.gravity += 44;
				
			}
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
		private function tick(time:Number):void 
		{
			timePassed += time;
			
			/*
			var len:int = arrows.total;
			for (var i:int = 0; i < len; i++) {
				var base:int = i * 8 + 4;
				arrows.toUpload[base++] = _template3D.camera.x;
				arrows.toUpload[base++] = _template3D.camera.y;
				arrows.toUpload[base++] = _template3D.camera.z;
			}
			*/
			
			arrows.gravity = -800 + Math.sin(timePassed * 4) * 2277;
			
			game.engine.update(time);
			
			
			
			
			_template3D.render();
			
			
		}
		
	}

}