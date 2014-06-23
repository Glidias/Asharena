package tests.pvp 
{
	import alternativa.a3d.collisions.CollisionBoundNode;
	import alternativa.a3d.collisions.CollisionUtil;
	import alternativa.a3d.controller.SimpleFlyController;
	import alternativa.a3d.controller.ThirdPersonController;
	import alternativa.a3d.controller.ThirdPersonTargetingSystem;
	import alternativa.a3d.objects.ArrowLobMeshSet;
	import alternativa.a3d.rayorcollide.TerrainRaycastImpl;
	import alternativa.a3d.systems.enemy.A3DEnemyAggroSystem;
	import alternativa.a3d.systems.enemy.A3DEnemyArcSystem;
	import alternativa.engine3d.controllers.OrbitCameraMan;
	import alternativa.engine3d.core.Camera3D;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.VertexAttributes;
	import alternativa.engine3d.materials.FillMaterial;
	import alternativa.engine3d.materials.Grid2DMaterial;
	import alternativa.engine3d.materials.Material;
	import alternativa.engine3d.materials.NormalMapSpace;
	import alternativa.engine3d.materials.StandardTerrainMaterial2;
	import alternativa.engine3d.materials.VertexLightTextureMaterial;
	import alternativa.engine3d.objects.Mesh;
	import alternativa.engine3d.primitives.Box;
	import alternativa.engine3d.primitives.PlanarRim;
	import alternativa.engine3d.primitives.Plane;
	import alternativa.engine3d.RenderingSystem;
	import alternativa.engine3d.resources.BitmapTextureResource;
	import alternativa.engine3d.resources.Geometry;
	import alternterrain.CollidableMesh;
	import arena.components.char.MovementPoints;
	import arena.components.enemy.EnemyIdle;
	import arena.components.weapon.Weapon;
	import arena.components.weapon.WeaponState;
	import arena.systems.enemy.AggroMemManager;
	import arena.systems.enemy.EnemyAggroNode;
	import arena.systems.enemy.EnemyAggroSystem;
	import arena.systems.player.AnimAttackSystem;
	import arena.systems.player.LimitedPlayerMovementSystem;
	import arena.views.hud.ArenaHUD;
	import ash.core.Entity;
	import ash.fsm.EngineState;
	import ash.tick.FrameTickProvider;
	import com.bit101.components.Label;
	import com.bit101.components.ProgressBar;
	import com.greensock.easing.Cubic;
	import com.greensock.easing.Linear;
	import com.greensock.TweenLite;
	import components.controller.SurfaceMovement;
	import components.Health;
	import components.ImmovableCollidable;
	import components.MovableCollidable;
	import components.Pos;
	import components.Rot;
	import components.tweening.Tween;
	import components.Vel;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.utils.setTimeout;
	import haxe.ds.StringMap;
	import haxe.io.BytesInput;
	import input.KeyPoll;
	import spawners.arena.GladiatorBundle;
	import spawners.arena.skybox.ClearBlueSkyAssets;
	import spawners.arena.skybox.SkyboxBase;
	import spawners.arena.terrain.MistEdge;
	import spawners.arena.terrain.TerrainBase;
	import spawners.arena.terrain.TerrainTest;
	import spawners.arena.water.NormalWaterAssets;
	import spawners.arena.water.WaterBase;
	import spawners.grounds.CarribeanTextures;
	import spawners.grounds.GroundBase;
	import systems.animation.IAnimatable;
	import systems.collisions.CollidableNode;
	import systems.collisions.EllipsoidCollider;
	import systems.collisions.GroundPlaneCollisionSystem;
	import systems.player.a3d.GladiatorStance;
	import systems.player.PlayerAction;
	import systems.player.PlayerTargetingSystem;
	import systems.player.PlayerTargetNode;
	import systems.sensors.HealthTrackingSystem;
	import systems.SystemPriorities;
	import systems.tweening.TweenSystem;
	import util.geom.PMath;
	import util.SpawnerBundle;
	import util.SpawnerBundleLoader;
	import views.engine3d.MainView3D;
	import views.ui.bit101.PreloaderBar;

	
	import alternativa.engine3d.alternativa3d;
	use namespace alternativa3d;
	
	/**

	 *  WIP pvp demo. This will later act as the main controller, for combat mode encounters in the RPG.
	 * 
	 * todo:
		 * 
		 *  Obstacles and stuffs in environment. Integrate to terrain!
		 *  Attack animation swing arc blocking
		 * 
		 * ((Chance to stun, Special abilities like:  Dodge Tumble, Kick, Throw dirt up))
		 * ______________________
		 * 
		 *
		 * 
		 * Add variety of units with ranged/guns. 
		 * 
		 * PC Top-view command mode with mouse camera scrolling and select individuals with mouse. (RTS style)
		 * 
		 * Formation support with:
		 * Console individual + follower list mechanic for roster..Cycle through menu of individuals/leaders.
		 * PC Mouse Drag Box or Shift + Select mechanic for Roster, (can cycle left/right) based on selected leaders to allow moving as formation.
		 * 
		 * [[Link attacks (combined non-critical attacks from nearby in-range units around target)]]
		 * Coordinate attacks (moving from formation movement to individual/movement unit actions)
		 * 
		 * 
	 * @author Glidias
	 */
	public class PVPDemo2 extends MovieClip 
	{
		private var _template3D:MainView3D;
		private var game:TheGame;
		private var ticker:FrameTickProvider;
		private var _preloader:PreloaderBar = new PreloaderBar()
		private var bundleLoader:SpawnerBundleLoader;
		
		private var spectatorPerson:SimpleFlyController;
		private var arenaSpawner:ArenaSpawner;
		private var collisionScene:Object3D;
		
		private var _gladiatorBundle:GladiatorBundle;
		private var arenaHUD:ArenaHUD;
		
		private var aggroMemManager:AggroMemManager;
		
			private var _waterBase:WaterBase;
		private var _skyboxBase:SkyboxBase;
		private var _terrainBase:TerrainBase;
		
	
		public function PVPDemo2() 
		{
			haxe.initSwc(this);
			
			game = new TheGame(stage);
	
			addChild( _template3D = new MainView3D() );
			_template3D.onViewCreate.add(onReady3D);
			
			_template3D.visible = false;
			addChild(_preloader);
			
			ArrowLobMeshSet;
			PlanarRim;
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
		
		
		
		private function setupTerrainAndWater():void 
		{
				_waterBase.plane.z =  (-64000 +84);//_terrainBase.loadedPage.Square.MinY + 444;
			_waterBase.addToScene(_template3D.scene);
			
			_skyboxBase.addToScene(_template3D.scene);
			_waterBase.setupFollowCamera();
			_waterBase.hideFromReflection.push(_template3D.camera);
			_waterBase.hideFromReflection.push(arenaHUD.hud);
			
			
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

				//if (camera.z < _waterBase.plane.z) camera.z = _waterBase.plane.z;
			camera.z += 122;
			spectatorPerson.setObjectPosXYZ(camera.x, camera.y, camera.z);
		//	*/
	
		_waterBase.plane.z *= _terrainBase.TERRAIN_HEIGHT_SCALE;
		}
		
		// customise methods accordingly here...
				
		private function getSpawnerBundles():Vector.<SpawnerBundle> 
		{
			return new <SpawnerBundle>[_gladiatorBundle = new GladiatorBundle(arenaSpawner), arenaHUD = new ArenaHUD(stage) ,
			
				_terrainBase = new TerrainBase(TerrainTest,1),
				_skyboxBase = new SkyboxBase(ClearBlueSkyAssets),
				_waterBase = new WaterBase(NormalWaterAssets),
				new GroundBase([CarribeanTextures])
			];
		}
		
		private function setupViewSettings():void 
		{
			_template3D.viewBackgroundColor = 0xDDDDDD;
		}
		
		private function randomiseHeights(amt:Number, geom:Geometry):void {
			var pos:Vector.<Number> = geom.getAttributeValues(VertexAttributes.POSITION);
			for (var i:int = 0; i < pos.length; i+=3) {
				pos[i + 2] = Math.random()*amt;
			}
			geom.setAttributeValues(VertexAttributes.POSITION, pos);
		}
		
		private function setupEnvironment():void 
		{
			
			TerrainBase;
		
			_template3D.stage3D.addEventListener(Event.CONTEXT3D_CREATE, onContextCreated);
			
			// example visual scene
			var box:Object3D = new Box(100, 13, 100 + 64, 1, 1, 1, false, new FillMaterial(0xCCCCCC) );
			box.z = 0;
			
			
			SpawnerBundle.uploadResources(box.getResources());
			
			//var mat:VertexLightTextureMaterial = new VertexLightTextureMaterial(new BitmapTextureResource(new BitmapData(4, 4, false, 0xBBBBBB),
		//	var planeFloor:Mesh = new Plane(2048, 2048, 8, 8, false, false, null, new Grid2DMaterial(0xBBBBBB, 1) );
		//	randomiseHeights( -177, planeFloor.geometry);
		//	planeFloor.calculateBoundBox();
		//	_template3D.scene.addChild(planeFloor);
			//arenaSpawner.addCrossStage(SpawnerBundle.context3D);
			//SpawnerBundle.uploadResources(planeFloor.getResources(true, null));
			
			setupTerrainLighting();
			setupTerrainAndWater();
		//	_terrainBase.terrain.z = -_terrainBase.terrain.boundBox.minZ;
		
			// collision scene (can be something else)
		
			var rootCollisionNode:CollisionBoundNode;
			game.colliderSystem.collidable = rootCollisionNode =  new CollisionBoundNode();
			rootCollisionNode.addChild(  _terrainBase.getTerrainCollisionNode() );
		//	rootCollisionNode.addChild( CollisionUtil.getCollisionGraph(_waterBase.plane)  );
			game.colliderSystem._collider.threshold = 0.00001;
			// (Optional) Enforced ground plane collision
			game.gameStates.thirdPerson.addInstance( new GroundPlaneCollisionSystem(_waterBase.plane.z, true) ).withPriority(SystemPriorities.resolveCollisions);

		}
		
		private function onContextCreated(e:Event):void 
		{
			throw new Error("Created again! Context loss earlier");
		}
		
		private var markedTargets:Vector.<Object3D> = new Vector.<Object3D>();
		private var _enemyAggroSystem:EnemyAggroSystem;
		
		
		// CAMERA CONTROLLING
		private var testArr:Array = [];
		private var testArr2:Array = [];
		private var curArr:Array = testArr;
		private var arrayOfSides:Array = [testArr, testArr2];
		private var sideIndex:int = 0;
		
		private var testIndex:int = 0;
		private var thirdPersonController:ThirdPersonController;
		private var commanderCameraController:ThirdPersonController;
		private var engineStateCommander:EngineState; 
		private var engineStateTransiting:EngineState;	
		
		private var _commandLookTarget:Object3D;
		private var _commandLookEntity:Entity;
		
		private static const CHASE_Z_OFFSET:Number = 44;
		private static const CMD_Z_OFFSET:Number = 72 + 40;
		 private var TARGET_MODE_ZOOM:Number = 40;
		private static var CMD_DIST:Number = 730;
		private var transitionCamera:ThirdPersonController;
		private var centerPlayerTween:Tween;
		private var _transitCompleteCallback:Function;
		
		
		// RULES
		private var movementPoints:MovementPoints = new MovementPoints();	
		private  var MAX_MOVEMENT_POINTS:Number = 5;// 9999;// 7;
		private  var MAX_COMMAND_POINTS:int = 5;
		private  var ASSIGNED_HP:int = 100;
		private var COMMAND_POINTS_PER_TURN:int = 5;
		private var commandPoints:Vector.<int> = new <int>[0,0];
		private var enemyWatchSettings:EnemyIdle = new EnemyIdle().init(9000, 100, 1.88495559215388, 28 );
		private var collOtherClass:Class = ImmovableCollidable;
			
		// Deault weapon stats
		private var TEST_MELEE_WEAPON:Weapon = getTestWeaponFireModes();
		
		private function getTestWeaponFireModes():Weapon {
			var head:Weapon;
			head = getTestWeapon(false);  // swing
			head.nextFireMode = getTestWeapon(true); // thrust
			
			return head;
		}
		
		
		private function getTestWeapon(thrust:Boolean=false):Weapon {
			/*
			var w:Weapon =   new Weapon();
			w.name = "Some Melee weapon";
			w.range = 0.74 * ArenaHUD.METER_UNIT_SCALE + ArenaHUD.METER_UNIT_SCALE * .25;
			w.minRange = 16;
			w.damage =  25;
			w.cooldownTime = 1.0;
			w.hitAngle =  22 * 180 / Math.PI;
			
			w.damageRange = 7;		// damage up-range variance
	
			w.critMinRange = w.range * .35;
			w.critMaxRange  = w.range * .70;
			if (w.critMinRange < 16) {
				var corr:Number = (16 - w.critMinRange);
				w.critMinRange += corr;
				w.critMaxRange += corr;
			}
			if (w.critMaxRange > w.range) w.critMaxRange = w.range;
			
			w.timeToSwing  =.15;
			w.strikeTimeAtMaxRange = .8; 
			w.strikeTimeAtMinRange = w.timeToSwing+.005;  // usually close to time to swing
			
			
			w.parryEffect = .4;
			
			w.stunEffect = 0;
			w.stunMinRange = 0;
			w.stunMaxRange = 0;
			
			return w;
			*/
			A3DEnemyAggroSystem;
			A3DEnemyArcSystem;
			
			var w:Weapon =   new Weapon();
			w.name = "Melee weapon";
			w.fireMode = thrust ? Weapon.FIREMODE_THRUST : Weapon.FIREMODE_SWING;
			w.sideOffset =thrust ?  15 : 36+16;// thrust ? 15 : 36;
			w.heightOffset = 0;
			w.range = 0.74 * ArenaHUD.METER_UNIT_SCALE + ArenaHUD.METER_UNIT_SCALE * .25;
			w.minRange = 16;
			w.damage = thrust  ? 10 : 25;
			w.cooldownTime = thrust ? 0.7 : 0.96;
			//w.cooldownTime = thrust ? 0.3 : 0.36666666666666666666666666666667;
			w.hitAngle =  45 *  PMath.DEG_RAD;
			
			w.damageRange = thrust ? 10 : 5;		// damage up-range variance
			// Thrust: 10-20 : Swing 25-30
	
			w.critMinRange = w.range * .35;
			w.critMaxRange  = w.range * .70;
			if (w.critMinRange < 16) {
				var corr:Number = (16 - w.critMinRange);
				w.critMinRange += corr;
				w.critMaxRange += corr;
			}
			if (w.critMaxRange > w.range) w.critMaxRange = w.range;
			
			w.timeToSwing  = thrust ? 0.13333333333333333333333333333333 : 0.26666666666666666666666666666667;
			w.strikeTimeAtMaxRange =  thrust ? 0.4 : 0.6; 
			w.strikeTimeAtMinRange = thrust ? 0.33 : 0.5;  // usually close to time to swing
			
			
			w.parryEffect = .4;
			
			w.stunEffect = 0;
			w.stunMinRange = 0;
			w.stunMaxRange = 0;
			
			w.matchAnimVarsWithStats();
			w.anim_fullSwingTime = 0.96;
			
			return w;
		}
		
		
		
		private function getDeductionCP():int {
			return 1;
		}
		

		// -- code goes here
		
		private function setupStartingEntites():void {
			
			// Register any custom skins needed for this game
			//arenaSpawner.setupSkin(, ArenaSpawner.RACE_SAMNIAN);
		
			// spawn any beginning entieies
			var curPlayer:Entity;
			
			arenaSpawner.addTextureResourceSide(SpawnerBundle.context3D, ArenaSpawner.RACE_SAMNIAN, 1, _gladiatorBundle.getSideTexture(1)  );
			
			curPlayer = arenaSpawner.addGladiator(ArenaSpawner.RACE_SAMNIAN, null, 0, -520, _terrainBase.sample(0,-520)+44, 0, 0, "0"); curPlayer.add(TEST_MELEE_WEAPON, Weapon); testArr.push(curPlayer);
			curPlayer = arenaSpawner.addGladiator(ArenaSpawner.RACE_SAMNIAN, null, 66, -520, _terrainBase.sample(66,-520)+44, 0, 0, "1"); curPlayer.add(TEST_MELEE_WEAPON, Weapon);testArr.push(curPlayer);
			curPlayer = arenaSpawner.addGladiator(ArenaSpawner.RACE_SAMNIAN, null, 66*2, -520, _terrainBase.sample(66*2,-520)+44, 0, 0, "2"); curPlayer.add(TEST_MELEE_WEAPON, Weapon);testArr.push(curPlayer);
			curPlayer = arenaSpawner.addGladiator(ArenaSpawner.RACE_SAMNIAN, null, 66*3, -520, _terrainBase.sample(66*3,-520)+44, 0, 0, "3"); curPlayer.add(TEST_MELEE_WEAPON, Weapon);testArr.push(curPlayer);
			curPlayer = arenaSpawner.addGladiator(ArenaSpawner.RACE_SAMNIAN, null, 66 * 4, -520, _terrainBase.sample(66*4,-520)+44, 0, 0, "4"); curPlayer.add(TEST_MELEE_WEAPON, Weapon);testArr.push(curPlayer);

			
			curPlayer = arenaSpawner.addGladiator(ArenaSpawner.RACE_SAMNIAN, null, 66 * 6, 520, _terrainBase.sample( 66 * 6, 520)+44, Math.PI, 1, "0"); curPlayer.add(TEST_MELEE_WEAPON, Weapon);testArr2.push(curPlayer);
			curPlayer = arenaSpawner.addGladiator(ArenaSpawner.RACE_SAMNIAN, null, 66 * 7, 520, _terrainBase.sample(66 * 7, 520)+44, Math.PI, 1, "1"); curPlayer.add(TEST_MELEE_WEAPON, Weapon);testArr2.push(curPlayer);
			curPlayer = arenaSpawner.addGladiator(ArenaSpawner.RACE_SAMNIAN, null, 66 * 8, 520, _terrainBase.sample(66 * 8, 520)+44, Math.PI, 1, "2"); curPlayer.add(TEST_MELEE_WEAPON, Weapon);testArr2.push(curPlayer);
			curPlayer = arenaSpawner.addGladiator(ArenaSpawner.RACE_SAMNIAN, null, 66 * 9, 520, _terrainBase.sample(66*9,520)+44, Math.PI, 1, "3"); curPlayer.add(TEST_MELEE_WEAPON, Weapon);testArr2.push(curPlayer);
			curPlayer = arenaSpawner.addGladiator(ArenaSpawner.RACE_SAMNIAN, null, 66 * 10, 520, _terrainBase.sample(66*10,520)+44, Math.PI, 1, "4"); curPlayer.add(TEST_MELEE_WEAPON, Weapon);testArr2.push(curPlayer);
			
			
			var health:Health;
			var i:int = testArr.length;
			while (--i > -1) {
				
				testArr[i].add( new Counter());
				health = testArr[i].get(Health) as Health;
				health.hp = ASSIGNED_HP;
				//health.onDamaged.add(onDamaged);
				//health.onDamaged.add(onDamaged);
			}
			i = testArr2.length;
			while (--i > -1) {
				
				testArr2[i].add( new Counter());
				
				health = testArr2[i].get(Health) as Health;
				health.hp = ASSIGNED_HP;
			//	health.onDamaged.add(onDamaged);
			//	health.onDamaged.add(onDamaged);
			}
			
			//arenaSpawner.switchPlayer(testArr[testIndex], stage);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false, 1);
			
		}
		

		
		private function onKeyDown(e:KeyboardEvent):void 
		{
			if (game.gameStates.engineState.currentState === engineStateTransiting) {
				// for now until interupt case is available
				return;
			}
			
			var keyCode:uint = e.keyCode;
			if (keyCode === Keyboard.TAB  &&   !game.keyPoll.isDown(Keyboard.TAB)  ) {
				cyclePlayerChoice();
			}
			else if (keyCode === Keyboard.L &&   !game.keyPoll.isDown(Keyboard.L) ) {
				changeCameraView("commander");
			}
			else if (keyCode === Keyboard.K &&   !game.keyPoll.isDown(Keyboard.K) ) {
				if (commandPoints[sideIndex] - getDeductionCP()  >= 0 ) {
					switchToPlayer();
				}
			}
			else if (keyCode === Keyboard.Z && !game.keyPoll.isDown(Keyboard.Z) ) {
				if (arenaHUD.charWeaponEnabled) toggleTargetingMode();
			}
			else if (keyCode === Keyboard.BACKSPACE && !game.keyPoll.isDown(Keyboard.BACKSPACE)) {
				endPhase();
			}
			else if (keyCode === Keyboard.F && !game.keyPoll.isDown(Keyboard.F)) {
				if (  arenaHUD.checkStrike(keyCode) ) {  // for now, HP reduction is insntatneous within this method
					// remove controls, perform animation, before toggling targeting mode and restoring back controls
					resolveStrikeAction();
					//toggleTargetingMode();
				}
			}
			else if (keyCode >= Keyboard.NUMBER_1 && keyCode <= Keyboard.NUMBER_9  && !game.keyPoll.isDown(keyCode)  ) {
				if (  arenaHUD.checkStrike(keyCode) ) {  // for now, HP reduction is insntatneous within this method
					// remove controls, perform animation, before toggling targeting mode and restoring back controls
					resolveStrikeAction();
					//toggleTargetingMode();
				}
			}
			else if (keyCode === Keyboard.B && !game.keyPoll.isDown(Keyboard.B)) {
				testAnim(1);
			}
			else if (keyCode === Keyboard.N && !game.keyPoll.isDown(Keyboard.N)) {
				testAnim2(1);
			}
			else if (keyCode === Keyboard.G && !game.keyPoll.isDown(Keyboard.G)) {
				testAnim(.5);
			}
			else if (keyCode === Keyboard.Y && !game.keyPoll.isDown(Keyboard.Y)) {
				testAnim2(0);
			}
			else if (keyCode === Keyboard.H && !game.keyPoll.isDown(Keyboard.H)) {
				testAnim2(.5);
			}
			else if (keyCode === Keyboard.T && !game.keyPoll.isDown(Keyboard.T)) {
				testAnim(0);
			}
		}
		
		
		
		private function resolveStrikeAction():void 
		{
			
			AnimAttackSystem.performMeleeAttackAction(arenaHUD.playerWeaponModeForAttack, arenaSpawner.currentPlayerEntity, arenaHUD.targetNode.entity, arenaHUD.strikeResult > 0 ? arenaHUD.playerDmgDealRoll : 0);
			_animAttackSystem.resolved.addOnce(resolveStrikeAction2);
			aggroMemManager.addToAggroMem(arenaSpawner.currentPlayerEntity, arenaHUD.targetNode.entity);
			if (arenaHUD.strikeResult > 0) {
				var targetHP:Health = (arenaHUD.targetNode.entity.get(Health) as Health);
				if (targetHP.hp > arenaHUD.playerDmgDealRoll) targetHP.onDamaged.addOnce(onEnemyTargetDamaged);
			}
		}
		
		
		private function onEnemyTargetDamaged(hp:int, amount:int):void {
			if (amount > 0) {
				var stance:GladiatorStance = arenaHUD.targetNode.entity.get(IAnimatable) as GladiatorStance;
				stance.flinch();
			}
			else {
				
			}
		}
		
		private function onPlayerDamaged(hp:int, amount:int):void {
			if (amount > 0) {
				var stance:GladiatorStance = arenaSpawner.currentPlayerEntity.get(IAnimatable) as GladiatorStance;
				stance.flinch();
			}
			else {
				
			}
		}
		
		private function resolveStrikeAction2():void 
		{
			if (arenaHUD.strikeResult > 0) TweenLite.delayedCall(.5, resolveStrikeAction3);
			else resolveStrikeAction3();
		}
		
		private function resolveStrikeAction3():void 
		{
			if (arenaHUD.enemyStrikeResult != 0) {
				AnimAttackSystem.performMeleeAttackAction(arenaHUD.enemyWeaponModeForAttack, arenaHUD.targetNode.entity, arenaSpawner.currentPlayerEntity, arenaHUD.enemyStrikeResult > 0 ? arenaHUD.enemyDmgDealRoll : 0);
				_animAttackSystem.resolved.addOnce(resolveStrikeActionFully);
				if (arenaHUD.enemyStrikeResult > 0) {
					var targetHP:Health = (arenaSpawner.currentPlayerEntity.get(Health) as Health);
					if (targetHP.hp > arenaHUD.enemyDmgDealRoll) targetHP.onDamaged.addOnce(onPlayerDamaged);
				}
			}
			else {
				resolveStrikeActionFully(true);
			}
		}
		
		private function resolveStrikeActionFully(instant:Boolean=false):void 
		{
			if (!instant&& arenaHUD.enemyStrikeResult > 0) TweenLite.delayedCall(.3, toggleTargetingMode)
			else toggleTargetingMode();
		}
		
		private function testAnim(blend:Number=.5):void 
		{
			var stance:GladiatorStance = (arenaSpawner.currentPlayerEntity || curArr[testIndex]).get(IAnimatable) as GladiatorStance;
			if (stance ==null) stance = curArr[testIndex].get(IAnimatable) as GladiatorStance;
			stance.swing(blend);
			
		}
		private function testAnim2(blend:Number=.5):void 
		{
			var stance:GladiatorStance = (arenaSpawner.currentPlayerEntity || curArr[testIndex]).get(IAnimatable) as GladiatorStance;
			if (stance ==null) stance = curArr[testIndex].get(IAnimatable) as GladiatorStance;
			stance.thrust(blend);
			
		}
		
		private var _targetMode:Boolean = false;
		private var _lastTargetZoom:Number;
		private var _lastTargetStance:int;
		
		private function toggleTargetingMode():void 
		{
			if ( game.gameStates.engineState.currentState !=  game.gameStates.thirdPerson) {
				return;
			}
			
			var gladiatorStance:GladiatorStance = arenaSpawner.currentPlayerEntity.get(IAnimatable) as GladiatorStance;
			
			
			if (!_targetMode) {
				_lastTargetZoom = thirdPersonController.thirdPerson.controller.getDistance();
				_lastTargetStance = gladiatorStance.stance;
			}
			_targetMode = !_targetMode;
			
			gladiatorStance.standEnabled = !_targetMode;
			arenaHUD.setTargetMode(_targetMode);
			if (_targetMode) {
				thirdPersonController.thirdPerson.preferedZoom = TARGET_MODE_ZOOM;
				thirdPersonController.thirdPerson.controller.disableMouseWheel();
				
				(arenaSpawner.currentPlayerEntity.get(SurfaceMovement) as SurfaceMovement).resetAllStates();
				game.keyPoll.resetAllStates(); 
				
				arenaSpawner.currentPlayerEntity.remove(KeyPoll); 
				
				
				if (gladiatorStance.stance == 0) {
					//gladiatorStance.stance = 1;
					gladiatorStance.setIdleStance( 1);
				}
				//arenaSpawner.currentPlayerEntity.add(game.keyPoll, KeyPoll); 
			}
			else {
				exitTargetMode();
				gladiatorStance.setIdleStance( _lastTargetStance);
			}
			
		}
		
		private function exitTargetMode():void 
		{
			_targetMode = false;
			arenaHUD.setTargetMode(_targetMode);
			
			thirdPersonController.thirdPerson.preferedZoom = _lastTargetZoom;
			thirdPersonController.thirdPerson.controller.enableMouseWheel();
		
			var gladiatorStance:GladiatorStance = arenaSpawner.currentPlayerEntity.get(IAnimatable) as GladiatorStance;
		
			
			if (movementPoints.movementTimeLeft > 0) arenaSpawner.currentPlayerEntity.add(game.keyPoll, KeyPoll);
		}
		
		
		private  var CAMERA_PHASETO_AVERAGE:Boolean = false; // switch phase new side average position?  else selected target
		private  var CAMERA_PHASEFROM_AVERAGE:Boolean = true;  // old side average position? else nearest target from above
		
		
		private function startPhase():void {
			
			sideIndex = 0;
			curArr = arrayOfSides[sideIndex];
			
			commandPoints[sideIndex] += COMMAND_POINTS_PER_TURN;
			if (commandPoints[sideIndex] > MAX_COMMAND_POINTS) commandPoints[sideIndex] = MAX_COMMAND_POINTS;
			
			updateCP();
			
			if (game.gameStates.engineState.currentState != engineStateCommander) {
				_transitCompleteCallback = selectFirstMan;
				changeCameraView("commander");
			
			}
			
			aggroMemManager.notifyStartPhase(sideIndex);
		}
		
		private function selectFirstMan():void {
			setTimeout(selectFirstMan2, 0);
			
		}
		
		private function selectFirstMan2():void {
			cyclePlayerChoice(0);
			
		}
		
		private function endPhase():void {
			
			
			if (game.gameStates.engineState.currentState != engineStateCommander) {
				
				_transitCompleteCallback = endPhase;
				changeCameraView("commander");
				return;
			}
			
			
			
			
	
			var oldArr:Array = arrayOfSides[sideIndex];
			

			sideIndex++;
			if (sideIndex >= commandPoints.length) {
				sideIndex = 0;
			}
			curArr = arrayOfSides[sideIndex];
			aggroMemManager.notifyStartPhase(sideIndex);
			
			
			
			
			var x:Number = 0;
			var y:Number = 0;
			var x2:Number = 0;
			var y2:Number = 0;
			var i:int;
			var len:int;
			var obj:Object3D;
			var dx:Number;
			var dy:Number;
			var d:Number = Number.MAX_VALUE;
			
			
			
		
			commandPoints[sideIndex] += COMMAND_POINTS_PER_TURN;
			if (commandPoints[sideIndex] > MAX_COMMAND_POINTS) commandPoints[sideIndex] = MAX_COMMAND_POINTS;
			
			
			updateCP();
			
			i = testArr.length;
			while (--i > -1) {
				var counter:Counter = testArr[i].get(Counter) as Counter;
				counter.value = 0;
			}
			
			i = testArr2.length;
			while (--i > -1) {
				counter = testArr2[i].get(Counter) as Counter;
				counter.value = 0;
			}
			
			
			len = curArr.length;
			
			// TODO: visibility awareness determination required... before adding them in...
			
			if (CAMERA_PHASETO_AVERAGE) {
				for (i = 0; i < len; i++) {
					obj = curArr[i].get(Object3D);
					
					x += obj.x;
					y += obj.y;
				}
				x /= len;
				y /= len;
			}
			else {
				obj = curArr[0].get(Object3D);
				x = obj.x;
				y = obj.y;
			}
			
			
			len = oldArr.length;
			
			if (CAMERA_PHASEFROM_AVERAGE) {
				for (i = 0; i < len; i++) {
					obj = oldArr[i].get(Object3D);
					
					x2 += obj.x;
					y2 += obj.y;
				}
				x2 /= len;
				y2 /= len;
			}
			else {
				var nx:Number = 0;
				var ny:Number = 0;
				for (i = 0; i < len; i++) {
					obj = oldArr[i].get(Object3D);
					
					x2 = obj.x;
					y2 = obj.y;
					dx = x2 - x;
					dy = y2 - y;
					var testD:Number = dx * dx + dy * dy ;
					if (testD < d) {
						d = testD;
						nx = x2;
						ny = y2;
					}
					
				}
				x2 = nx;
				y2 = ny;
			}
			
			
			
			
			x = x2 - x;
			y = y2 - y;
			
			var fromAng:Number = commanderCameraController.thirdPerson.controller.angleLongitude;
			var ang:Number = (Math.atan2(y, x) - Math.PI*.5) * (180 / Math.PI);
			//ang = curArr != testArr ? 180 : 0;
			
			game.engine.addEntity( new Entity().add( new Tween(commanderCameraController.thirdPerson.controller, 3, { angleLongitude: getDestAngle(fromAng,ang) } ) ) ); 

			testIndex = 0;
			cyclePlayerChoice(0);
			arenaHUD.newPhase();
			
		
		}
		
		private function focusOnCurPlayer():void {
			arenaSpawner.switchPlayer(null, stage);
			
			focusOnTargetChar(curArr[testIndex]);
		}

		private function cyclePlayerChoice(cycleAmount:int=1):void   // cycling players only allowed in commander view
		{
			if (game.gameStates.engineState.currentState != engineStateCommander) {
				if (_targetMode) exitTargetMode();
				changeCameraView("commander");
				return;
			}

			
			if ( game.gameStates.engineState.currentState === engineStateCommander )  {
				 testIndex+=cycleAmount;
				 	if (testIndex >= curArr.length) testIndex = 0;
					focusOnTargetChar(curArr[testIndex]);
			}
			
			
		
		}
		

		
		private function focusOnTargetChar(targetEntity:Entity, friendly:Boolean=true):void 
		{

			var pos:Object3D = targetEntity.get(Object3D) as Object3D;
			
			if (friendly) {
				arenaHUD.setChar(targetEntity);
			}

			markedTargets[0] = pos;
			arenaHUD.showArrowMarkers(markedTargets);
			
			var counter:Counter = targetEntity.get(Counter) as Counter;
			movementPoints.movementTimeLeft=  MAX_MOVEMENT_POINTS / (1 << counter.value);
				
		
			var props:Object = { x:pos.x, y:pos.y, z:pos.z + CMD_Z_OFFSET };
			if ( centerPlayerTween == null) {
				
				centerPlayerTween =	new Tween(_commandLookEntity.get(Object3D), 2, props );
			}
			else {
				centerPlayerTween.updateProps( _commandLookEntity.get(Object3D), props );
				centerPlayerTween.t = 0;
			
			}
			if (centerPlayerTween.dead) {
				centerPlayerTween.dead = false;
				game.engine.addEntity( new Entity().add(  centerPlayerTween ) );
			}
			
			
		}
		
		private function updateTargetCharFocus():void {
			if (arenaSpawner.currentPlayer != null) {
					_commandLookTarget._x = arenaSpawner.currentPlayer.x;
						_commandLookTarget._y = arenaSpawner.currentPlayer.y;
							_commandLookTarget._z = arenaSpawner.currentPlayer.z + CMD_Z_OFFSET;
							arenaSpawner.disableStanceControls(stage);
			}
		
		}

	

		
		
		
		private function switchToPlayer():void {
			if (game.gameStates.engineState.currentState === game.gameStates.thirdPerson) {
				return;
			}
			
			_targetMode = false;
			arenaHUD.setTargetMode(_targetMode);
			commandPoints[sideIndex] -= getDeductionCP();
			updateCP();
			
			game.keyPoll.resetAllStates();
			
			
		
			
			
			if (arenaSpawner.currentPlayerEntity) arenaSpawner.currentPlayerEntity.remove(MovementPoints);
			arenaSpawner.switchPlayer(curArr[testIndex], stage);
			
			
			var counter:Counter = arenaSpawner.currentPlayerEntity.get(Counter) as Counter;
			movementPoints.movementTimeLeft = MAX_MOVEMENT_POINTS / (1 << counter.value);
			
			counter.value++;
			
			arenaSpawner.currentPlayerEntity.add( movementPoints, MovementPoints);
			//var untyped:* = arenaSpawner.currentPlayerSkin.getSurface(0).material;
			//arenaSpawner.currentPlayerSkin.getSurface(0).material as 
			//arenaSpawner.currentPlayerSkin.getSurface(0).material
			thirdPersonController.thirdPerson.setFollowComponents( arenaSpawner.currentPlayer, arenaSpawner.currentPlayerEntity.get(Rot) as Rot);
			changeCameraView("thirdPerson");		
			
			
		}
		
		private function getDestAngle(actualangle:Number, destangle:Number):Number {
			 var difference:Number = destangle - actualangle;
        if (difference < -180) difference += 360;
        if (difference > 180) difference -= 360;
			return difference + actualangle;

		}
		
		private function changeCameraView(targetState:String):void {
			
			// TODO: interrupt case.
			arenaHUD.clearArrows();
			
			if (targetState === "thirdPerson" && game.gameStates.engineState.currentState === engineStateCommander) {
		
				
				game.gameStates.engineState.changeState("transiting");
				arenaHUD.setState("transiting");
				transitionCameras(commanderCameraController.thirdPerson, thirdPersonController.thirdPerson, targetState);
			}
			else if (targetState === "commander" && game.gameStates.engineState.currentState === game.gameStates.thirdPerson) {
				_transitCompleteCallback = focusOnCurPlayer;
				updateTargetCharFocus();
				if (arenaSpawner.currentPlayerEntity) arenaSpawner.currentPlayerEntity.remove(MovableCollidable);
				arenaHUD.setTargetChar(null);
				endTurnAI();
				
				
				game.gameStates.engineState.changeState("transiting");
				arenaHUD.setState("transiting");
				transitionCameras(thirdPersonController.thirdPerson, commanderCameraController.thirdPerson, targetState, NaN, NaN, NaN, Cubic.easeIn);
			}
			/*
			else if (targetState === "commander" && game.gameStates.engineState.currentState === game.gameStates.spectator) {
				game.gameStates.engineState.changeState("transiting");
				transitionCameras(spectatorPerson, commanderCameraController.thirdPerson, targetState, arenaSpawner.currentPlayer.x, arenaSpawner.currentPlayer.y, arenaSpawner.currentPlayer.z, Cubic.easeIn);
			}
			*/
			else {
				//throw new Error("NO transition");
				game.gameStates.engineState.changeState("spectator");
				game.gameStates.engineState.changeState(targetState);
				arenaHUD.setState(targetState);
			}
		}
		
	
		
		private var _targetTransitState:String;
		private var _animAttackSystem:AnimAttackSystem;


		
		private function transitionCameras(fromCamera:OrbitCameraMan, toCamera:OrbitCameraMan, targetState:String=null, customX:Number=Number.NaN, customY:Number = Number.NaN, customZ:Number = Number.NaN, customEase:Function=null, duration:Number=1):void 
		{
	
			//fromCamera.controller.angleLatitude %= 360;
			//fromCamera.controller.angleLongitude %= 360;
			
			//toCamera.controller.angleLatitude %= 360;
			//toCamera.controller.angleLongitude %= 360;
			
			//transitionCamera.thirdPerson.validateFollowTarget();
			fromCamera.validateFollowTarget();
			toCamera.validateFollowTarget();
			
			transitionCamera.thirdPerson.instantZoom =  fromCamera.preferedZoom;
			transitionCamera.thirdPerson.controller.angleLatitude = fromCamera.controller.angleLatitude;
			transitionCamera.thirdPerson.controller.angleLongitude = fromCamera.controller.angleLongitude;
		
			
			var transitCameraTarget:Object3D = transitionCamera.thirdPerson.followTarget;
			transitCameraTarget.x = isNaN(customX) ?  fromCamera.controller._followTarget.x : customX;
			transitCameraTarget.y = isNaN(customY) ?fromCamera.controller._followTarget.y : customY;
			transitCameraTarget.z = isNaN(customZ) ? fromCamera.controller._followTarget.z : customZ;

		
			var tarX:Number = toCamera.controller._followTarget.x;
			var tarY:Number = toCamera.controller._followTarget.y;
			var tarZ:Number = toCamera.controller._followTarget.z;
		


			var ease:Function = customEase != null ? customEase : Cubic.easeOut;
			var tween:Tween =new Tween(transitionCamera.thirdPerson.controller, duration, {  setDistance:toCamera.controller.getDistance(), angleLatitude:getDestAngle(transitionCamera.thirdPerson.controller.angleLatitude, toCamera.controller.angleLatitude), angleLongitude:getDestAngle(transitionCamera.thirdPerson.controller.angleLongitude, toCamera.controller.angleLongitude)  }, { ease:ease }  );
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
			arenaHUD.setState(_targetTransitState);
			
			if (_targetTransitState != "commander") {
				arenaHUD.hideStars();
				if ( _targetTransitState === "thirdPerson" ) activateEnemyAggro();
			}
			else  {
				arenaHUD.showStars();
				if (arenaSpawner.currentPlayerEntity) arenaSpawner.currentPlayerEntity.remove(MovementPoints);
			}
			
		
			_targetTransitState = null;
			
			if (_transitCompleteCallback != null) {
				_transitCompleteCallback();
				_transitCompleteCallback = null;
			}
		}
		
			private function endTurnAI():void 
		{
			aggroMemManager.notifyEndTurn();
			
			
			var otherSide:int = aggroMemManager.activeSide == 0 ? 1 : 0;
			var enemySide:Array = arrayOfSides[otherSide];
			var len:int = enemySide.length;
			for ( var i:int = 0; i < len; i++) {
				var e:Entity = enemySide[i];
				e.remove( collOtherClass );
			
			
			}
			
			var mySide:Array = arrayOfSides[aggroMemManager.activeSide];
			len = mySide.length;
			for ( i = 0; i < len; i++) {
				e = mySide[i];
				if (e === arenaSpawner.currentPlayerEntity) continue;
				e.remove( collOtherClass );
			
			
			}
			
			
		}

		
		private function activateEnemyAggro():void 
		{
			arenaSpawner.currentPlayerEntity.add( new MovableCollidable().init() ); // temp, for testing only
			aggroMemManager.notifyTurnStarted(arenaSpawner.currentPlayerEntity);
			
			// temporary, considering putting this in aggroMemManager???
			///*
			var otherSide:int = aggroMemManager.activeSide == 0 ? 1 : 0;
			var enemySide:Array = arrayOfSides[otherSide];
			var len:int = enemySide.length;
			for ( var i:int = 0; i < len; i++) {
				var e:Entity = enemySide[i];
				e.add( new collOtherClass().init() );
			
			
			}
			
			var mySide:Array = arrayOfSides[aggroMemManager.activeSide];
			len = mySide.length;
			for ( i = 0; i < len; i++) {
				e= mySide[i];
				if (e === arenaSpawner.currentPlayerEntity) continue;
				e.add( new collOtherClass().init() );
			
			
			}
		//	*/
			
		}
		
		private function onOutOfFuel():void {
			
			//arenaSpawner.currentPlayerEntity.get(Vel).x = 0;
		//	arenaSpawner.currentPlayerEntity.get(SurfaceMovement);
		//	cyclePlayerChoice();
		
		// TODO: Fix out of fuel dispatch bug from LimitedPlayerMOvementSystem
			arenaHUD.outOfFuel();
		}
		
		
		private function onStanceChange(val:int):void {
			arenaHUD.setStance(val);
		}
		
		private function setupGameplay():void 
		{
			
		
			
			GladiatorStance.ON_STANCE_CHANGE.add(onStanceChange);
			
			// Tweening system
			game.engine.addSystem( new TweenSystem(), SystemPriorities.animate );
			
			
			collisionScene = new Object3D();
			
			
			// Third person
			///*
			var dummyEntity:Entity = arenaSpawner.getNullEntity(); // arenaSpawner.getPlayerBoxEntity(SpawnerBundle.context3D);
			// arenaSpawner.getNullEntity();
		
			_commandLookTarget = dummyEntity.get(Object3D) as Object3D;
			_commandLookEntity = dummyEntity;
			_commandLookTarget.z = CMD_Z_OFFSET;
			//game.engine.addEntity(dummyEntity);
			//*/
			// possible to  set raycastScene  parameter to something else besides "collisionScene"...
			thirdPersonController = new ThirdPersonController(stage, _template3D.camera, collisionScene, _commandLookTarget, _commandLookTarget, null, null, null, true);
			thirdPersonController.thirdPerson.instantZoom = 140;
			collisionScene.addChild( new TerrainRaycastImpl(_terrainBase.terrain) );
			
		thirdPersonController.thirdPerson.preferedMinDistance = 100;
		thirdPersonController.thirdPerson.controller.minDistance = 0;
		thirdPersonController.thirdPerson.controller.maxDistance = 240;
		thirdPersonController.thirdPerson.offsetZ = CHASE_Z_OFFSET;
			game.gameStates.thirdPerson.addInstance(thirdPersonController).withPriority(SystemPriorities.postRender);
			
			var arcSystem:A3DEnemyArcSystem = new A3DEnemyArcSystem(_template3D.scene);
			arenaHUD.arcContainer = arcSystem.arcs;
			game.gameStates.thirdPerson.addInstance(arcSystem ).withPriority(SystemPriorities.postRender);
			_waterBase.hideFromReflection.push(arenaHUD.arcContainer);
			
			// setup targeting system
			var targetingSystem:ThirdPersonTargetingSystem = new ThirdPersonTargetingSystem(thirdPersonController.thirdPerson);
			game.gameStates.thirdPerson.addInstance(targetingSystem).withPriority(SystemPriorities.postRender);
			targetingSystem.targetChanged.add(onTargetChanged);
			targetingSystem.targetChanged.add(arenaHUD.setTargetChar);
			
			
			// special PVP movement limited time
			var movementPointSystem:LimitedPlayerMovementSystem;
			game.gameStates.thirdPerson.addInstance( movementPointSystem= new LimitedPlayerMovementSystem() ).withPriority(SystemPriorities.preMove);
			movementPointSystem.outOfFuel.add( onOutOfFuel);
			
			
			commanderCameraController =  new ThirdPersonController(stage, _template3D.camera, collisionScene, _commandLookTarget, _commandLookTarget, null, null, null, true );
			//commanderCameraController.thirdPerson.preferedMinDistance = CMD_DIST;
			commanderCameraController.thirdPerson.instantZoom = CMD_DIST; 
		////	commanderCameraController.thirdPerson.controller.maxDistance = CMD_DIST;
		//	commanderCameraController.thirdPerson.controller.minDistance = CMD_DIST;
			
			
			engineStateCommander = game.gameStates.getNewSpectatorState();
			engineStateCommander.addInstance( commanderCameraController).withPriority(SystemPriorities.postRender);
			game.gameStates.engineState.addState("commander", engineStateCommander);
		
			
			transitionCamera =new ThirdPersonController(stage, _template3D.camera, collisionScene, _commandLookTarget, _commandLookTarget, null, null, null, false);
			transitionCamera.thirdPerson.controller.disablePermanently();
			transitionCamera.thirdPerson.controller.stopMouseLook ();
			transitionCamera.thirdPerson.mouseWheelSensitivity  = 0;
			engineStateTransiting = game.gameStates.getNewSpectatorState();
			transitionCamera.thirdPerson.controller.minAngleLatitude = -Number.MAX_VALUE;
			transitionCamera.thirdPerson.controller.maxAngleLatidude = Number.MAX_VALUE;
				transitionCamera.thirdPerson.controller.minAngleLatitude = -Number.MAX_VALUE;
			transitionCamera.thirdPerson.controller.maxAngleLatidude = Number.MAX_VALUE;
			 transitionCamera.thirdPerson.controller.minDistance = -Number.MAX_VALUE;
			 transitionCamera.thirdPerson.controller.maxDistance= Number.MAX_VALUE;
			engineStateTransiting.addInstance( transitionCamera).withPriority(SystemPriorities.postRender);
			game.gameStates.engineState.addState("transiting", engineStateTransiting);
			
			
			// (Optional) Go straight to 3rd person
			//throw new Error(game.gameStates.engineState.currentState);
			//game.gameStates.engineState.changeState("thirdPerson");
			
			arenaSpawner.currentPlayer = _commandLookTarget;
			
			arenaHUD.setCamera(_template3D.camera);
			_template3D.camera.addChild( arenaHUD.hud);
			
			
			game.gameStates.thirdPerson.addInstance( _animAttackSystem=  new AnimAttackSystem() ).withPriority(SystemPriorities.stateMachines);
			game.gameStates.thirdPerson.addInstance( _enemyAggroSystem = new A3DEnemyAggroSystem(transitionCamera.thirdPerson.scene) ).withPriority(SystemPriorities.stateMachines);
			arenaHUD.weaponLOSCheck = _enemyAggroSystem;
			//_enemyAggroSystem.onEnemyAttack.add(onEnemyAttack);
		//	_enemyAggroSystem.onEnemyReady.add(onEnemyReady);
		//	_enemyAggroSystem.onEnemyStrike.add(onEnemyStrike);
			//_enemyAggroSystem.onEnemyCooldown.add(onEnemyCooldown);
			
			
			// aggro mem manager
			aggroMemManager = new AggroMemManager();
			aggroMemManager.init(game.engine, _enemyAggroSystem);
			aggroMemManager.aggroList.nodeAdded.add(onEnemyAggroNodeAdded);
			
			game.gameStates.engineState.changeState("thirdPerson");
			arenaHUD.setState("thirdPerson");
			startPhase();
		}
		
		private function onEnemyAggroNodeAdded(node:EnemyAggroNode):void 
		{
			
			var gStance:GladiatorStance = node.entity.get(IAnimatable) as GladiatorStance;

			if (gStance != null && gStance.stance == 0) {
				gStance.stance = 1;
				
				gStance.setIdleStance( 1);
			}
		}
		
		private function onEnemyCooldown(e:Entity, cooldown:Number):void 
		{
			var obj:Object3D = e.get(Object3D) as Object3D;
			arenaHUD.appendMessage(obj.name+" is on cooldown! "+cooldown);
		}
		
		private function onEnemyAttack(e:Entity):void 
		{
			var obj:Object3D = e.get(Object3D) as Object3D;
			arenaHUD.appendMessage(obj.name+" swings weapon at player!");
		}
		private function onEnemyStrike(e:Entity):void 
		{
			var obj:Object3D = e.get(Object3D) as Object3D;
			arenaHUD.appendMessage(obj.name+" finiished his strike!");
		}
		
		private function onEnemyReady(e:Entity):void 
		{
			var obj:Object3D = e.get(Object3D) as Object3D;
			arenaHUD.appendMessage(obj.name+" is ready to attack!");
		}
		
		private function onDamaged(e:Entity, hp:int, amount:int):void 
		{
			if (e != arenaSpawner.currentPlayerEntity) {  // assume damage taken from active currentPlayerEntity
				arenaHUD.txtPlayerStrike(e, hp, amount);
			}
			else {  // assume damage taken from entity under aggro system
				arenaHUD.txtTookDamageFrom(_enemyAggroSystem.currentAttackingEnemy, hp, amount); 
			}
		}
		
		private function onMurdered(e:Entity, hp:int, amount:int):void 
		{
			if (e != arenaSpawner.currentPlayerEntity) {  // assume active currentPlayerEntity killed entity
				arenaHUD.txtPlayerStrike(e, hp, amount, true);
				unregisterEntity(e);
				game.engine.removeEntity(e);
				
			}
			else {  // assume currentePlayerNEtity killed by entity under aggro system!
				arenaHUD.txtTookDamageFrom(_enemyAggroSystem.currentAttackingEnemy, hp, amount, true);
				unregisterEntity(arenaSpawner.currentPlayerEntity);
				if (curArr[testIndex] == null) {  // do a naive reset for this case.
					testIndex = 0;
					//throw new Error("null pointer after unregistration...");
				}
				game.engine.removeEntity(arenaSpawner.currentPlayerEntity);
			}
		}
		
		private function unregisterEntity(e:Entity):void 	//naive approach for roster atm.
		{
			var arr:Array;
			var removeIndex:int = testArr.indexOf(e);
			
			arr = testArr;
			if (removeIndex < 0) {
				removeIndex = testArr2.indexOf(e);
				arr = testArr2;
			}
			
			if (removeIndex < 0) {
				//throw new Error("COUld not find entity in registry!");
				return;
			}
			arr.splice(removeIndex, 1);
			
			
			
		}
		
		
	
		
		private function onTargetChanged(node:PlayerTargetNode ):void 
		{
			//throw new Error("A:"+node.obj.name);
			
			
			if (node != null) {
				markedTargets[0] = node.obj;
			
				arenaHUD.showArrowMarkers(markedTargets);
				
			}
			else {
				arenaHUD.clearArrows();
				//markedTargets.length  = 0;
				//arenaHUD.showArrowMarkers(markedTargets);
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

			
			// Add a Health trackign listenining system
			game.engine.addSystem( new HealthTrackingSystem(), SystemPriorities.stateMachines);
			HealthTrackingSystem.SIGNAL_DAMAGE.add(onDamaged);
			HealthTrackingSystem.SIGNAL_MURDER.add(onMurdered);
			
			setupEnvironment();
			setupInterface();
			setupStartingEntites();
			setupGameplay();

			
			ticker = new FrameTickProvider(stage);
			ticker.add(tick);
			ticker.start();
		}
		
		private function setupInterface():void 
		{
		


		}
		
		private function updateCP():void 
		{
		//	testCPLabel.text = (sideIndex > 0 ? "Ghost army" : "Player army" )+" CP left: "+commandPoints[sideIndex] +" / "+MAX_COMMAND_POINTS;
			arenaHUD.updateTurnInfo( commandPoints[sideIndex], MAX_COMMAND_POINTS, (sideIndex > 0 ? "Ghost army" : "Player army" ), sideIndex, COMMAND_POINTS_PER_TURN );
		}
		

		
		private function tick(time:Number):void 
		{
			//thirdPersonController.thirdPerson.followAzimuth = !_targetMode;
			game.engine.update(time);
			arenaHUD.updateFuel( movementPoints.movementTimeLeft / MAX_MOVEMENT_POINTS );
			arenaHUD.update();
		
			var camera:Camera3D = _template3D.camera;
			
			_skyboxBase.update(_template3D.camera);
			
			_template3D.camera.startTimer();

			// adjust offseted waterlevels
	
			_waterBase.waterMaterial.update(_template3D.stage3D, _template3D.camera, _waterBase.plane, _waterBase.hideFromReflection);
			_template3D.camera.stopTimer();

			// set to default waterLevels

			_template3D.render();
			
		}
		
	}

}
import ash.core.Entity;
import components.Health;


class Counter {
	public var value:int = 0;
	
}
