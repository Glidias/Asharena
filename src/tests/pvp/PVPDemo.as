package tests.pvp 
{
	import alternativa.a3d.collisions.CollisionBoundNode;
	import alternativa.a3d.collisions.CollisionUtil;
	import alternativa.a3d.controller.SimpleFlyController;
	import alternativa.a3d.controller.ThirdPersonController;
	import alternativa.engine3d.controller.OrbitCameraMan;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.materials.FillMaterial;
	import alternativa.engine3d.objects.Mesh;
	import alternativa.engine3d.primitives.Plane;
	import alternativa.engine3d.RenderingSystem;
	import alternterrain.CollidableMesh;
	import ash.core.Entity;
	import ash.fsm.EngineState;
	import ash.tick.FrameTickProvider;
	import com.greensock.easing.Cubic;
	import com.greensock.easing.Linear;
	import components.Pos;
	import components.Rot;
	import components.tweening.Tween;
	import components.Vel;
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.utils.setTimeout;
	import spawners.arena.GladiatorBundle;
	import systems.animation.IAnimatable;
	import systems.collisions.CollidableNode;
	import systems.collisions.EllipsoidCollider;
	import systems.collisions.GroundPlaneCollisionSystem;
	import systems.player.a3d.GladiatorStance;
	import systems.SystemPriorities;
	import systems.tweening.TweenSystem;
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
	public class PVPDemo extends MovieClip 
	{
		private var _template3D:MainView3D;
		private var game:TheGame;
		private var ticker:FrameTickProvider;
		private var _preloader:PreloaderBar = new PreloaderBar()
		private var bundleLoader:SpawnerBundleLoader;
		
		private var spectatorPerson:SimpleFlyController;
		private var arenaSpawner:ArenaSpawner;
		private var collisionScene:Object3D;
		
		public function PVPDemo() 
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
			return new <SpawnerBundle>[new GladiatorBundle(arenaSpawner)];
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
			
		
			// collision scene (can be something else)
			collisionScene = planeFloor;
			game.colliderSystem.collidable = CollisionUtil.getCollisionGraph(collisionScene);
			game.colliderSystem._collider.threshold = 0.00001;
			// (Optional) Enforced ground plane collision
			//game.gameStates.thirdPerson.addInstance( new GroundPlaneCollisionSystem(0, true) ).withPriority(SystemPriorities.resolveCollisions);

		}
		
		private var testArr:Array = [];
		private var testIndex:int = 0;
		private var thirdPersonController:ThirdPersonController;
		private var commanderCameraController:ThirdPersonController;
		private var engineStateCommander:EngineState; 
		private var engineStateTransiting:EngineState;	
		
		private var _commandLookTarget:Object3D;
		private var _commandLookEntity:Entity;
		
		private function setupStartingEntites():void {
			
			// Register any custom skins needed for this game
			//arenaSpawner.setupSkin(, ArenaSpawner.RACE_SAMNIAN);
		
			// spawn any beginning entieies
			var curPlayer:Entity;
			
			curPlayer = arenaSpawner.addGladiator(ArenaSpawner.RACE_SAMNIAN, null, 0, 0, 0); testArr.push(curPlayer);
			curPlayer = arenaSpawner.addGladiator(ArenaSpawner.RACE_SAMNIAN, null, 48, 0, 0); testArr.push(curPlayer);
			curPlayer = arenaSpawner.addGladiator(ArenaSpawner.RACE_SAMNIAN, null, 48*2, 0, 0); testArr.push(curPlayer);
			curPlayer = arenaSpawner.addGladiator(ArenaSpawner.RACE_SAMNIAN, null, 48*3, 0, 0); testArr.push(curPlayer);
			curPlayer = arenaSpawner.addGladiator(ArenaSpawner.RACE_SAMNIAN, null, 48 * 4, 0, 0); testArr.push(curPlayer);
			curPlayer = arenaSpawner.addGladiator(ArenaSpawner.RACE_SAMNIAN, null, 48 * 5, 0, 0); testArr.push(curPlayer);
			curPlayer = arenaSpawner.addGladiator(ArenaSpawner.RACE_SAMNIAN, null, 48 * 6, 0, 0); testArr.push(curPlayer);
			curPlayer = arenaSpawner.addGladiator(ArenaSpawner.RACE_SAMNIAN, null, 48 * 7, 0, 0); testArr.push(curPlayer);
			curPlayer = arenaSpawner.addGladiator(ArenaSpawner.RACE_SAMNIAN, null, 48 * 8, 0, 0); testArr.push(curPlayer);
			curPlayer = arenaSpawner.addGladiator(ArenaSpawner.RACE_SAMNIAN, null, 48 * 9, 0, 0); testArr.push(curPlayer);
			curPlayer = arenaSpawner.addGladiator(ArenaSpawner.RACE_SAMNIAN, null, 48 * 10, 0, 0); testArr.push(curPlayer);
			
			
			//arenaSpawner.switchPlayer(testArr[testIndex], stage);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false, 1);
			
		}
		
		private function onKeyDown(e:KeyboardEvent):void 
		{

			if (e.keyCode === Keyboard.TAB  &&   !game.keyPoll.isDown(Keyboard.TAB)  ) {
				cyclePlayerChoice();
			}
			else if (e.keyCode === Keyboard.L &&   !game.keyPoll.isDown(Keyboard.L) ) {
				changeCameraView("commander");
			}
			else if (e.keyCode === Keyboard.K &&   !game.keyPoll.isDown(Keyboard.K) ) {
				switchToPlayer();
			}
			
			
		}
		
		private var centerPlayerTween:Tween;

		private function cyclePlayerChoice():void   // cycling players only allowed in commander view
		{
			if (game.gameStates.engineState.currentState != engineStateCommander) {
				
				changeCameraView("commander");
				
			}
			
		
			
			if ( game.gameStates.engineState.currentState === engineStateCommander )  {
				 testIndex++;
				 	if (testIndex >= testArr.length) testIndex = 0;
					focusOnTargetChar(testArr[testIndex]);
			}
		
		}
		
		private static const CMD_Z_OFFSET:Number = 72 + 40;
		private static var CMD_DIST:Number = 730;
		private var transitionCamera:ThirdPersonController;
		
		private function focusOnTargetChar(targetEntity:Entity):void 
		{

			var pos:Pos = targetEntity.get(Pos) as Pos;
			if ( centerPlayerTween == null) {
				centerPlayerTween =	new Tween(_commandLookEntity.get(Pos), 2, { x:pos.x, y:pos.y, z:pos.z + CMD_Z_OFFSET } );
			}
			else {
				centerPlayerTween.updateProps( _commandLookEntity.get(Pos), pos );
				centerPlayerTween.t = 0;
			
			}
			if (centerPlayerTween.dead) {
				centerPlayerTween.dead = false;
				game.engine.addEntity( new Entity().add(  centerPlayerTween ) );
			}
		}

		
		private function switchToPlayer():void {
			if (game.gameStates.engineState.currentState === game.gameStates.thirdPerson) {
				return;
			}
			game.keyPoll.resetAllStates();
			arenaSpawner.switchPlayer(testArr[testIndex], stage);
			thirdPersonController.thirdPerson.setFollowComponents( arenaSpawner.currentPlayer, arenaSpawner.currentPlayerEntity.get(Rot) as Rot);
			changeCameraView("thirdPerson");
			
			
		}
		
		
		private function changeCameraView(targetState:String):void {
			
			// TODO: interrupt case.
			
			if (targetState === "thirdPerson" && game.gameStates.engineState.currentState === engineStateCommander) {
				
				game.gameStates.engineState.changeState("transiting");
				transitionCameras(commanderCameraController.thirdPerson, thirdPersonController.thirdPerson, targetState);
			}
			else if (targetState === "commander" && game.gameStates.engineState.currentState === game.gameStates.thirdPerson) {
				game.gameStates.engineState.changeState("transiting");
				transitionCameras(thirdPersonController.thirdPerson, commanderCameraController.thirdPerson, targetState, arenaSpawner.currentPlayer.x, arenaSpawner.currentPlayer.y, arenaSpawner.currentPlayer.z, Cubic.easeIn);
			}
			else {
				game.gameStates.engineState.changeState("spectator");
				game.gameStates.engineState.changeState(targetState);
			}
		}
		
		private var _targetTransitState:String;
		private function transitionCameras(fromCamera:OrbitCameraMan, toCamera:OrbitCameraMan, targetState:String=null, customX:Number=Number.NaN, customY:Number = Number.NaN, customZ:Number = Number.NaN, customEase:Function=null, duration:Number=1):void 
		{
	
			fromCamera.controller.angleLatitude %= 360;
			fromCamera.controller.angleLongitude %= 360;
			
			toCamera.controller.angleLatitude %= 360;
			toCamera.controller.angleLongitude %= 360;
			
			transitionCamera.thirdPerson.instantZoom = fromCamera.preferedZoom;
			transitionCamera.thirdPerson.controller.angleLatitude = fromCamera.controller.angleLatitude;
			transitionCamera.thirdPerson.controller.angleLongitude = fromCamera.controller.angleLongitude;
		
			
			var transitCameraTarget:Object3D = transitionCamera.thirdPerson.followTarget;
			transitCameraTarget.x = isNaN(customX) ?  fromCamera.followTarget.x : customX;
			transitCameraTarget.y = isNaN(customY) ?fromCamera.followTarget.y : customY;
			transitCameraTarget.z = isNaN(customZ) ? fromCamera.followTarget.z : customZ;

		//	transitionCamera.update(0);
		
			var tarX:Number = toCamera.followTarget.x;
			var tarY:Number = toCamera.followTarget.y;
			var tarZ:Number = toCamera.followTarget.z;
			

		//	if (!isNaN(customX)) return;

			var ease:Function = customEase != null ? customEase : Cubic.easeOut;
			var tween:Tween =new Tween(transitionCamera.thirdPerson.controller, duration, {  setDistance:toCamera.controller.getDistance(), angleLatitude:toCamera.controller.angleLatitude, angleLongitude:toCamera.controller.angleLongitude  }, { ease:ease }  );
			var tween2:Tween = new Tween(transitionCamera.thirdPerson.followTarget, duration, { x:tarX, y:tarY, z:tarZ   }, { ease:ease }  );
			
			game.engine.addEntity( new Entity().add( tween  ) );
			game.engine.addEntity( new Entity().add( tween2  ) );
			
			if (targetState != null) {
				_targetTransitState = targetState;
				tween.onComplete = onTransitComplete;
				//game.gameStates.engineState.changeState(targetState);
			}
			
		}
		
		private function onTransitComplete():void {
			game.gameStates.engineState.changeState(_targetTransitState);
			_targetTransitState = null;
		}
		
		
		
		private function setupGameplay():void 
		{
			
			// Tweening system
			game.engine.addSystem( new TweenSystem(), SystemPriorities.animate );
			
			
			// Third person
			///*
			var dummyEntity:Entity = arenaSpawner.getNullEntity(); // arenaSpawner.getPlayerBoxEntity(SpawnerBundle.context3D);
			// arenaSpawner.getNullEntity();
			dummyEntity.get(Pos).z =CMD_Z_OFFSET;
			_commandLookTarget = dummyEntity.get(Object3D) as Object3D;
			_commandLookEntity = dummyEntity;
			game.engine.addEntity(dummyEntity);
			//*/
			// possible to  set raycastScene  parameter to something else besides "collisionScene"...
			thirdPersonController = new ThirdPersonController(stage, _template3D.camera, collisionScene, _commandLookTarget, _commandLookTarget, dummyEntity, null, null, false);
			thirdPersonController.thirdPerson.preferedZoom = 140;
	
			game.gameStates.thirdPerson.addInstance(thirdPersonController).withPriority(SystemPriorities.postRender);
			
			
			
			commanderCameraController =  new ThirdPersonController(stage, _template3D.camera, collisionScene, _commandLookTarget, _commandLookTarget, dummyEntity, null, null, false );
			//commanderCameraController.thirdPerson.preferedMinDistance = CMD_DIST;
			commanderCameraController.thirdPerson.instantZoom = CMD_DIST; 
		////	commanderCameraController.thirdPerson.controller.maxDistance = CMD_DIST;
		//	commanderCameraController.thirdPerson.controller.minDistance = CMD_DIST;
			
			
			engineStateCommander = game.gameStates.getNewSpectatorState();
			engineStateCommander.addInstance( commanderCameraController).withPriority(SystemPriorities.postRender);
			game.gameStates.engineState.addState("commander", engineStateCommander);
		
			
			transitionCamera =new ThirdPersonController(stage, _template3D.camera, collisionScene, _commandLookTarget, _commandLookTarget, dummyEntity, null, null, false);
			transitionCamera.thirdPerson.controller.disablePermanently();
			transitionCamera.thirdPerson.controller.stopMouseLook ();
			transitionCamera.thirdPerson.mouseWheelSensitivity  = 0;
			engineStateTransiting = game.gameStates.getNewSpectatorState();
			transitionCamera.thirdPerson.preferedMinDistance = transitionCamera.thirdPerson.controller.minDistance = Number.MIN_VALUE;
			 transitionCamera.thirdPerson.controller.maxDistance= Number.MAX_VALUE;
			engineStateTransiting.addInstance( transitionCamera).withPriority(SystemPriorities.postRender);
			game.gameStates.engineState.addState("transiting", engineStateTransiting);
			
			
			// (Optional) Go straight to 3rd person
			//throw new Error(game.gameStates.engineState.currentState);
			//game.gameStates.engineState.changeState("thirdPerson");
			
			
			game.gameStates.engineState.changeState("commander");
		
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