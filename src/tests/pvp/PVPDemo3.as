package tests.pvp 
{
	import alternativa.a3d.collisions.CollisionBoundNode;
	import alternativa.a3d.collisions.CollisionUtil;
	import alternativa.a3d.controller.SimpleFlyController;
	import alternativa.a3d.controller.ThirdPersonController;
	import alternativa.a3d.controller.ThirdPersonTargetingSystem;
	import alternativa.a3d.materials.HealthBarFillMaterial;
	import alternativa.a3d.objects.ArrowLobMeshSet2;
	import alternativa.a3d.objects.HealthBarSet;
	import alternativa.a3d.objects.ProjectileDomain;
	import alternativa.a3d.rayorcollide.TerrainRaycastImpl;
	import alternativa.a3d.systems.enemy.A3DEnemyAggroSystem;
	import alternativa.a3d.systems.enemy.A3DEnemyArcSystem;
	import alternativa.a3d.systems.hud.EdgeRaycastTester;
	import alternativa.a3d.systems.hud.TargetBoardTester;
	import alternativa.engine3d.core.Occluder;
	import alternativa.engine3d.materials.TextureMaterial;
	import spawners.ModelBundle;
	//import alternativa.a3d.systems.hud.DestCalcTester;
	import alternativa.a3d.systems.hud.HealthBarRenderSystem;
	import alternativa.a3d.systems.hud.TrajRaycastTester;
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
	import arena.components.char.AggroMem;
	import arena.components.char.HealthFlags;
	import arena.components.char.HitFormulas;
	import arena.components.char.MovementPoints;
	import arena.components.enemy.EnemyAggro;
	import arena.components.enemy.EnemyIdle;
	import arena.components.weapon.Weapon;
	import arena.components.weapon.WeaponSlot;
	import arena.components.weapon.WeaponState;
	import arena.systems.enemy.AggroMemManager;
	import arena.systems.enemy.EnemyAggroNode;
	import arena.systems.enemy.EnemyAggroSystem;
	import arena.systems.player.AnimAttackSystem;
	import arena.systems.player.IStance;
	import arena.systems.player.LimitedPlayerMovementSystem;
	import arena.systems.weapon.IProjectileDomain;
	import arena.views.hud.ArenaHUD;
	import ash.core.Entity;
	import ash.fsm.EngineState;
	import ash.tick.FixedTickProvider;
	import ash.tick.FrameTickProvider;
	import ash.tick.ITickProvider;
	import components.Ellipsoid;
	import components.Gravity;
	import util.geom.Vec3;
	//import ash.tick.MultiUnitTickProvider;
	//import ash.tick.UnitTickProvider;
	import com.bit101.components.Label;
	import com.bit101.components.ProgressBar;
	import com.flashartofwar.fcss.utils.FSerialization;
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
	import spawners.arena.projectiles.Projectiles;
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
	import systems.player.a3d.ThirdPersonAiming;
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
	public class PVPDemo3 extends MovieClip 
	{
		private var _template3D:MainView3D;
		private var deadScene:Object3D = new Object3D();
		private var game:TheGame;
		private var ticker:FrameTickProvider;
		private var _preloader:PreloaderBar = new PreloaderBar()
		private var bundleLoader:SpawnerBundleLoader;
		private var _modelBundle:ModelBundle;
		private var _followAzimuth:Boolean = false;
		private var spectatorPerson:SimpleFlyController;
		private var arenaSpawner:ArenaSpawner;
		private var collisionScene:Object3D = new Object3D();
		
		
		private var _gladiatorBundle:GladiatorBundle;
		private var arenaHUD:ArenaHUD;
		
		private var aggroMemManager:AggroMemManager;
		
		private var _waterBase:WaterBase;
		private var _skyboxBase:SkyboxBase;
		private var _terrainBase:TerrainBase;
		
		private var arrowProjectileDomain:ProjectileDomain = new ProjectileDomain();
		
		
		public var SHOW_PREFERED_STANCES_ENDTURN:int = 2;
		private var waterSettings:String = "XwaterMaterial { perturbReflectiveBy:0.5; perturbRefractiveBy:0.5; waterTintAmount:0.3; fresnelMultiplier:0.43; reflectionMultiplier:0.5; waterColorR:0; waterColorG:0.15; waterColorB:0.115;  }";
		
	
		public function PVPDemo3() 
		{
			haxe.initSwc(this);
			//throw new Error(bico(4,0));
		//	throw new Error(findNumSucceedProb(90, 13, 10)*100);
			
			
			
			if (root.loaderInfo.parameters.waterSettings) {
				waterSettings = root.loaderInfo.parameters.waterSettings;
			}
			
			game = new TheGame(stage);
	
			addChild( _template3D = new MainView3D() );
			_template3D.onViewCreate.add(onReady3D);
			
			_template3D.visible = false;
			addChild(_preloader);
			
			
			ArrowLobMeshSet2;
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
			
		//	_terrainBase.loadedPage.heightMap.flatten(standardMaterial.waterLevel + 130);  // flat test
		//	_terrainBase.loadedPage.heightMap.randomise(255);  // randomise test
		//	 _terrainBase.loadedPage.heightMap.slopeAltAlongY(88);  // slope zig zag test
		//	 _terrainBase.loadedPage.heightMap.slopeAlongY(122);  // slope linear test
			 
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
				FSerialization.applyStyle(_waterBase.waterMaterial, FSerialization.parseStylesheet(waterSettings).getStyle("waterMaterial") );
				
				_waterBase.plane.z = -50+ (-64000 +84);//_terrainBase.loadedPage.Square.MinY + 444;
			_waterBase.addToScene(_template3D.scene);
			
			_skyboxBase.addToScene(_template3D.scene);
			_waterBase.setupFollowCamera();
			_waterBase.hideFromReflection.push(_template3D.camera);
			_waterBase.hideFromReflection.push(arenaHUD.hud);
			
			
			var terrainMat:Material = setupTerrainMaterial();
			_template3D.scene.addChild( _terrainBase.getNewTerrain(terrainMat , 0, 1) );
		_terrainBase.terrain.waterLevel = _waterBase.plane.z;
			//_terrainBase.terrain.debug = true;
			
				var hWidth:Number = (_terrainBase.terrain.boundBox.maxX - _terrainBase.terrain.boundBox.minX) * .5 * _terrainBase.terrain.scaleX;
					_terrainBase.terrain.x -= hWidth*.5;
			_terrainBase.terrain.y += hWidth*.5;
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
				_modelBundle = new ModelBundle(Projectiles, null, true),
				_terrainBase = new TerrainBase(TerrainTest,1, 144/256), //.25*.25 // 0.09375
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
			
			arenaSpawner.getNewDummyBox(SpawnerBundle.context3D);

			_template3D.scene.addChild(deadScene);
			
			_template3D.stage3D.addEventListener(Event.CONTEXT3D_CREATE, onContextCreated);
			
			// example visual scene
			var box:Mesh = new Box(100, 13, 100 + 64, 1, 1, 1, false, new FillMaterial(0xCCCCCC) );
			//box.z = 0;
			//box.visible = false;
			occluderTest = new Occluder();
			_targetBoardTester.testOccluder = occluderTest;

		
			occluderTest.createForm(box.geometry);
			_template3D.scene.addChild(box);
			box.addChild(occluderTest);
			
			
			_debugBox = new Box(32, 32, 72, 1, 1, 1, false, new FillMaterial(0xFF0000) );
			_template3D.scene.addChild(_debugBox);
			
				SpawnerBundle.uploadResources(_debugBox.getResources());
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
			
			box.z =  _terrainBase.sample(box.x, box.y);
			
			collisionScene.addChild(box.clone());
			
		//	_gladiatorBundle.textureMat.waterLevel = _waterBase.plane.z;
		//	_terrainBase.terrain.z = -_terrainBase.terrain.boundBox.minZ;
		
			// collision scene (can be something else)
		
			var rootCollisionNode:CollisionBoundNode;
			game.colliderSystem.collidable = rootCollisionNode =  new CollisionBoundNode();
			rootCollisionNode.addChild(  _terrainBase.getTerrainCollisionNode() );
			rootCollisionNode.addChild( CollisionUtil.getCollisionGraph(box) );
		//	rootCollisionNode.addChild( CollisionUtil.getCollisionGraph(_waterBase.plane)  );
			game.colliderSystem._collider.threshold = 0.00001;
			// (Optional) Enforced ground plane collision
			game.gameStates.thirdPerson.addInstance( new GroundPlaneCollisionSystem(_waterBase.plane.z - 20, true) ).withPriority(SystemPriorities.resolveCollisions);
			


		}
		
		private function setupProjectiles():void 
		{
			
			 game.engine.addEntity( new Entity().add(arrowProjectileDomain, IProjectileDomain) );
			  arrowProjectileDomain.setHitResolver(_animAttackSystem);
			  if (_modelBundle.getSubModelPacket("arrow").getMaterial() is TextureMaterial) {
					// do nothing, basic texture material is fine for current  batch amount
			  }
			  else {
				  ArrowLobMeshSet2.BATCH_AMOUNT = 58;
			  }
			
			 var arrowLob:ArrowLobMeshSet2 =  new ArrowLobMeshSet2( (_modelBundle.getSubModelPacket("arrow").model as Mesh).geometry, _modelBundle.getSubModelPacket("arrow").getMaterial() );
			_template3D.scene.addChild(arrowLob);
			 arrowProjectileDomain.init( arrowLob );
			 arrowLob.setGravity(216 * 3);
			 SpawnerBundle.uploadResources(arrowLob.getResources());
			
			 arrowLob.setPermanentArrows();
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
		 private var TARGET_MODE_ZOOM:Number = 55;
		private static var CMD_DIST:Number = 730;
		private var transitionCamera:ThirdPersonController;
		private var centerPlayerTween:Tween;
		private var _transitCompleteCallback:Function;
		
		
		private var _sceneLocked:Boolean = false;
		
		// RULES
		private var movementPoints:MovementPoints = new MovementPoints();	
		private  var MAX_MOVEMENT_POINTS:Number = 1000;// 4;// 9999;// 7;
		private  var MAX_COMMAND_POINTS:int = 5;
		private  var ASSIGNED_HP:int = 1120; // 120;
		private var COMMAND_POINTS_PER_TURN:int = 5;
		private var commandPoints:Vector.<int> = new <int>[0,0];
		private var collOtherClass:Class = ImmovableCollidable;
			
		// Deault weapon stats
		private var TEST_WEAPON_LIST:WeaponSlot = getTestWeaponList();
		//private var TEST_MELEE_WEAPON:Weapon = getTestRangedWeapon(); //getTestWeaponFireModes(); //
		
		private var testRangeWeapon:Weapon;
		
		private function getTestWeaponList():WeaponSlot {
			var weapSlot:WeaponSlot = new WeaponSlot().init();
			weapSlot.slots[0] = getTestRangedWeapon();
			weapSlot.slots[1] = getTestWeaponFireModes();
			
	//	weapSlot.slots[0] = getTestWeaponFireModes();
			return weapSlot;
		}

		private function getTestWeaponFireModes():Weapon {
			var head:Weapon;
			var tail:Weapon;
			
			head = getTestWeapon(false);  // swing
			head.nextFireMode =  tail = getTestWeapon(true); // thrust
			
			//tail.nextFireMode = tail =  testRangeWeapon = getTestRangedWeapon();
			return head;
		}
		
	
		
		
		
		private function getTestRangedWeapon():Weapon {
			var w:Weapon =   new Weapon();
			w.projectileSpeed =  20.4318 * ArenaHUD.METER_UNIT_SCALE;

			
			w.name = "Longbow";
			w.fireMode =  Weapon.FIREMODE_TRAJECTORY;
			w.fireModeLabel = "Shoot arrow";
			w.sideOffset =11;
			w.heightOffset = 13;
		
			
			w.minRange = 40;
			w.damage =  15;
			w.cooldownTime = 5;// .8;
			//w.cooldownTime = thrust ? 0.3 : 0.36666666666666666666666666666667;
			w.hitAngle =  45 *  PMath.DEG_RAD;
			
			w.damageRange =  6;		// damage up-range variance
			// Thrust: 10-20 : Swing 25-30
	
			w.critMinRange = 800;
			w.critMaxRange  = 1600;
		
			w.deviation = .25; 
			w.range  = ArenaHUD.METER_UNIT_SCALE * 50;
			w.deviation =  HitFormulas.getDeviationForRange(512, 16);
			
			
			w.timeToSwing  = .3;
			
			w.strikeTimeAtMaxRange = 0; //0.0001;
			w.strikeTimeAtMinRange = 0;// 0.0001;
		
			w.muzzleVelocity =   16.4318 * ArenaHUD.METER_UNIT_SCALE;// *  197.206;
			w.muzzleLength = 40;
			w.parryEffect = .4;
			
			w.stunEffect = 0;
			w.stunMinRange = 0;
			w.stunMaxRange = 0;
			
			w.matchAnimVarsWithStats();
			w.anim_fullSwingTime = 0.96;
			
			w.minPitch = -Math.PI*.2;
			w.maxPitch = Math.PI * .2;
			
			w.rangeMode = Weapon.RANGEMODE_BOW;
			w.id = "bow";
			
			w.projectileDomain = arrowProjectileDomain;
			
			return w;	
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
			ProjectileDomain;
			
			var w:Weapon =   new Weapon();
			w.minPitch = -Math.PI*.25;
			w.maxPitch = Math.PI*.25;
			
			w.projectileSpeed = 0;
			w.deviation = 0;
			
			w.name = "Melee weapon";
			w.fireMode = thrust ? Weapon.FIREMODE_THRUST : Weapon.FIREMODE_SWING;
			w.sideOffset =thrust ?  15 : 36+16;// thrust ? 15 : 36;
			w.heightOffset = 0;
		//	w.range = 0.74 * ArenaHUD.METER_UNIT_SCALE + ArenaHUD.METER_UNIT_SCALE * .25;
			//w.range += 32;
			
			w.range = 68;
			//w.range += 16;
			
			w.minRange = 16;
			w.damage = thrust  ? 13 : 25;
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
			
			w.timeToSwing  =  thrust ? 0.3 : 0.4; // thrust ? 0.13333333333333333333333333333333 : 0.26666666666666666666666666666667;
			w.strikeTimeAtMaxRange = w.timeToSwing;//  thrust ? 0.4 : 0.6; 
			w.strikeTimeAtMinRange = w.timeToSwing;  // usually close to time to swing
			
			
			w.parryEffect = .4;
			
			w.stunEffect = 0;
			w.stunMinRange = 0;
			w.stunMaxRange = 0;
			
			w.matchAnimVarsWithStats();
			w.anim_fullSwingTime = 0.96;
			
			return w;
		}
		
		
		


		  /// <summary>
		/// Calculates the binomial coefficient (nCk) (N items, choose k)
		/// </summary>
		/// <param name="n">the number items</param>
		/// <param name="k">the number to choose</param>
		/// <returns>the binomial coefficient</returns>
	//	/*
		public function bico( n:Number, k:Number):Number
		{
			if (k > n) { return 0; }
			if (n == k) { return 1; } // only one way to chose when n == k
			if (k > n - k) { k = n - k; } // Everything is symmetric around n-k, so it is quicker to iterate over a smaller k than a larger one.
			var c:Number = 1;
			for (var i:int = 1; i <= k; i++)
			{
				c *= n--;
				c /= i;
			}
			return c;
		}
	//	*/
			
		
		private function findNumCombiProb(s:int, n:int, x:int):Number {
				return findNumCombi(s, n, x) / Math.pow(x, n);
		}
		
		
		private function findNumSucceedProb(s:int, n:int, x:int):Number {
				var total:Number =  Math.pow(x, n);
				var max:Number = x * n;
				
				var accum:Number = 0;
				for (var i:int = s; i <= max; i++) {
					
					accum += findNumCombi(i, n, x) ;
				}
				return accum / total;
		}
		
		
		private function findNumCombi(s:int, n:int, x:int):Number {
			
			var accum:Number = 0;
			
			var limit:int =  (s - n) / x;
			
			for (var k:int = 0; k <= limit; k++) {
				accum += Math.pow( -1, k) * bico(n, k) * bico(s - x * k - 1, n - 1);
			}
			return accum;
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
			
			curPlayer = arenaSpawner.addGladiator(ArenaSpawner.RACE_SAMNIAN, null, 0, -520, _terrainBase.sample(0,-520)+44, 0, 0, "0", null, null, TEST_WEAPON_LIST); testArr.push(curPlayer);  
			curPlayer = arenaSpawner.addGladiator(ArenaSpawner.RACE_SAMNIAN, null, 66, -520, _terrainBase.sample(66,-520)+44, 0, 0, "1", null, null, TEST_WEAPON_LIST); testArr.push(curPlayer);
			curPlayer = arenaSpawner.addGladiator(ArenaSpawner.RACE_SAMNIAN, null, 66*2, -520, _terrainBase.sample(66*2,-520)+44, 0, 0, "2", null, null, TEST_WEAPON_LIST); testArr.push(curPlayer);
			curPlayer = arenaSpawner.addGladiator(ArenaSpawner.RACE_SAMNIAN, null, 66*3, -520, _terrainBase.sample(66*3,-520)+44, 0, 0, "3", null, null, TEST_WEAPON_LIST); testArr.push(curPlayer);
			curPlayer = arenaSpawner.addGladiator(ArenaSpawner.RACE_SAMNIAN, null, 66 * 4, -520, _terrainBase.sample(66*4,-520)+44, 0, 0, "4", null, null, TEST_WEAPON_LIST); testArr.push(curPlayer);

			
			curPlayer = arenaSpawner.addGladiator(ArenaSpawner.RACE_SAMNIAN, null, 66 * 6, 520, _terrainBase.sample( 66 * 6, 520)+44, Math.PI, 1, "0", null, null, TEST_WEAPON_LIST); testArr2.push(curPlayer);
			curPlayer = arenaSpawner.addGladiator(ArenaSpawner.RACE_SAMNIAN, null, 66 * 7, 520, _terrainBase.sample(66 * 7, 520)+44, Math.PI, 1, "1", null, null, TEST_WEAPON_LIST); testArr2.push(curPlayer);
			curPlayer = arenaSpawner.addGladiator(ArenaSpawner.RACE_SAMNIAN, null, 66 * 8, 520, _terrainBase.sample(66 * 8, 520)+44, Math.PI, 1, "2", null, null, TEST_WEAPON_LIST); testArr2.push(curPlayer);
			curPlayer = arenaSpawner.addGladiator(ArenaSpawner.RACE_SAMNIAN, null, 66 * 9, 520, _terrainBase.sample(66*9,520)+44, Math.PI, 1, "3", null, null, TEST_WEAPON_LIST); testArr2.push(curPlayer);
			curPlayer = arenaSpawner.addGladiator(ArenaSpawner.RACE_SAMNIAN, null, 66 * 10, 520, _terrainBase.sample(66*10,520)+44, Math.PI, 1, "4", null, null, TEST_WEAPON_LIST); testArr2.push(curPlayer);
			
			
			var health:Health;
			var i:int = testArr.length;
			while (--i > -1) {
				
				testArr[i].add( new Counter());
				health = testArr[i].get(Health) as Health;
				health.hp = health.maxHP = ASSIGNED_HP;
				//health.onDamaged.add(onDamaged);
				//health.onDamaged.add(onDamaged);
			}
			i = testArr2.length;
			while (--i > -1) {
				
				testArr2[i].add( new Counter());
				
				health = testArr2[i].get(Health) as Health;
				health.hp = health.maxHP =  ASSIGNED_HP;
			//	health.onDamaged.add(onDamaged);
			//	health.onDamaged.add(onDamaged);
			}
			
			//arenaSpawner.switchPlayer(testArr[testIndex], stage);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false, 1);
			
		}
		

		
		private function onKeyDown(e:KeyboardEvent):void 
		{
			if ( game.gameStates.engineState.currentState === engineStateTransiting || _sceneLocked) {
				// for now until interupt case is available
				return;
			}
			
		
			
			
			var keyCode:uint = e.keyCode;
			if (keyCode === Keyboard.TAB  &&   !game.keyPoll.isDown(keyCode)  ) {
				cyclePlayerChoice();
			}
			else if (keyCode === Keyboard.B  &&   !game.keyPoll.isDown(keyCode)  ) {
				if ( game.gameStates.engineState.currentState === game.gameStates.thirdPerson && !sceneLocked && !_targetMode ) {  //
					cycleWeapon();
				}
			}
			else if (keyCode === Keyboard.R && !game.keyPoll.isDown(keyCode)) {
				if (!_targetMode && game.gameStates.engineState.currentState === game.gameStates.thirdPerson  && !sceneLocked ) attemptReloadTurn();
			}
			else if (keyCode === Keyboard.L &&   !game.keyPoll.isDown(keyCode) ) {
				changeCameraView("commander");
			}
			else if (keyCode === Keyboard.K &&   !game.keyPoll.isDown(keyCode) ) {
				if (commandPoints[sideIndex] - getDeductionCP()  >= 0 ) {
					switchToPlayer();
				}
			}
			else if (keyCode === Keyboard.Z && !game.keyPoll.isDown(keyCode) ) {
				if (arenaHUD.charWeaponEnabled ) toggleTargetingMode();
			}
			else if (keyCode === Keyboard.BACKSPACE && !game.keyPoll.isDown(keyCode)) {
				endPhase();
			}
			else if (keyCode === Keyboard.F && !game.keyPoll.isDown(keyCode)) {
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
			
			//else if (keyCode === Keyboard.B && !game.keyPoll.isDown(keyCode)) {
			//	testAnim(1);
			//}
			
			else if (keyCode === Keyboard.N && !game.keyPoll.isDown(keyCode)) {
				testAnim2(1);
			}
			else if (keyCode === Keyboard.G && !game.keyPoll.isDown(keyCode)) {
				testAnim(.5);
			}
			else if (keyCode === Keyboard.Y && !game.keyPoll.isDown(keyCode)) {
				testAnim2(0);
			}
			else if (keyCode === Keyboard.H && !game.keyPoll.isDown(keyCode)) {
				testAnim2(.5);
			}
			else if (keyCode === Keyboard.T && !game.keyPoll.isDown(keyCode)) {
				testAnim(0);
			}
			
			else if (keyCode === Keyboard.P &&  !game.keyPoll.isDown(keyCode)) {
				if ( game.gameStates.engineState.currentState === engineStateCommander ) showPreferedStances();
			}
			else if (keyCode === Keyboard.RIGHTBRACKET) {
				_terrainBase.terrain.debug = ! _terrainBase.terrain.debug;
			}
			else if (keyCode === Keyboard.NUMPAD_ADD) {
				_template3D.camera.fov += 1 * Math.PI/180;
			}
			else if (keyCode === Keyboard.NUMPAD_SUBTRACT) {
				_template3D.camera.fov -= 1 * Math.PI/180;
			}
			//*/
		}
		
		private function onEnemyInterrupt():void {
				disablePlayerMovement();
					sceneLocked = true;
				//	_followAzimuth = true;
				arcSystem.setVisible(false);
				arenaHUD.notifyEnemyInterrupt();
				_animAttackSystem.resolved.addOnce(onFinishEnemyInterrupt);
		}
		
		private function onFinishEnemyInterrupt():void 
		{
				arenaHUD.appendMessage("Finished interrupt !");
				sceneLocked = false;
				arcSystem.setVisible(true);
				arenaHUD.notifyEnemyInterrupt(false);
				//	_followAzimuth = false;
					if (movementPoints.movementTimeLeft > 0)  arenaSpawner.currentPlayerEntity.add(game.keyPoll, KeyPoll);
		}
		
		private function attemptReloadTurn():void 
		{
			if (commandPoints[sideIndex] <= 0) {
				return;
			}
			if (!arenaSpawner.currentPlayerEntity.has(Health)) return;
			var counter:Counter = arenaSpawner.currentPlayerEntity.get(Counter) as Counter;
			var measure:Number = MAX_MOVEMENT_POINTS / (1 << (counter.value-1));
			
			if ( !arenaHUD.charWeaponEnabled || movementPoints.movementTimeLeft < measure*.5)  {  // attempt reload turn
				
				movementPoints.movementTimeLeft = MAX_MOVEMENT_POINTS / (1 << counter.value);
				counter.value++;
			
				arenaHUD.reloadTurn();
				targetingSystem.reset();
				
				commandPoints[sideIndex]--;
				updateCP();
				arenaHUD.hideStars();
				
				// reset all cooldowns of enemies
				//_enemyAggroSystem.resetCooldownsOfAllAggro();
				//aggroMemManager.processAllEnemyAggroNodes();
				
				/*
				arenaSpawner.currentPlayerEntity.remove( KeyPoll);
				movementPoints.timeElapsed = .75;
				
				
				game.engine.updateComplete.addOnce(onReloadFrameDone);
				
				else
				*/
				if (!arenaSpawner.currentPlayerEntity.has(KeyPoll)) {
					arenaSpawner.currentPlayerEntity.add(game.keyPoll, KeyPoll);
				}
			};
			
		
		}
		
		private function onReloadFrameDone():void 
		{
			arenaSpawner.currentPlayerEntity.add(game.keyPoll, KeyPoll);
		}
		
		private function cycleWeapon():void 
		{
			var index:int = arenaHUD.cycleWeapon();
			if (index < 0) return;
			
			var weapSlot:WeaponSlot =  arenaSpawner.currentPlayerEntity.get(WeaponSlot) as WeaponSlot;
			var gladiatorStance:GladiatorStance =arenaSpawner.currentPlayerEntity.get(IStance) as GladiatorStance;
		
			var toReset:Boolean = false;
			if (gladiatorStance != null) {
				
				if (_targetMode) {  // kiv
					toReset = true;
					toggleTargetingMode();
					//gladiatorStance.setIdleStance( _lastTargetStance);
				}
				gladiatorStance.switchWeapon( weapSlot.slots[index] );
				
				if (toReset) {
					
					toggleTargetingMode();
					TweenLite.delayedCall(0, toggleTargetingMode);
				}
			}
			delayTimeElapsed = arcSystem.setTimeElapsed(arenaSpawner.currentPlayerEntity.get(Weapon) as Weapon);
			//throw new Error(delayTimeElapsed);
			//game.keyPoll.resetAllStates();
			
		}
		
		
		
		
		
		private function resolveStrikeAction():void 
		{
			
			sceneLocked = true;
			playerStriking = true;
			(arenaSpawner.currentPlayerEntity.get(IStance) as GladiatorStance).attacking = true;
			
		
			
			_followAzimuth = false;
					if (!_animAttackSystem.getResolved()) {
					
					arenaHUD.appendSpanTagMessage("Resolving action...");
					_animAttackSystem.resolved.addOnce(resolveStrikeAction);
					return;
				}
				
				if ( isPlayerDead() ) { // assumed player has died before action can be executed!
					return;
				}
				
			arenaHUD.appendSpanTagMessage("Player executed action!");
			
			//delayTimeElapsed = 0;
			
			
			var showSimult:Boolean = showAttacksSimulatenously();
			//arenaHUD.appendMessage("ENemy is aggroing? " + (arenaHUD.enemyStrikeResult!=0) + ", "+ showSimult);
			arenaHUD.delayEnemyStrikeT = 0;
		
			
			if (showSimult) {
				var timeEnemySwing:Number = performEnemyCounterAttack();
				
				// ensure always player strikes last
				var delayPlayer:Number = arenaHUD.playerChosenWeaponStrike.anim_fullSwingTime > timeEnemySwing  ?  .3 :  timeEnemySwing -  arenaHUD.playerChosenWeaponStrike.anim_fullSwingTime + .3;
				//_animAttackSystem.checkTime(.3);
				game.engine.addEntity( new Entity().add(new Tween(arenaHUD, delayPlayer, { delayEnemyStrikeT:1 }, {onComplete:doPlayerStrikeAction} ) ) );
			}
			else {
				doPlayerStrikeAction();
			}
			
			
			
			
		}
		
		private function doPlayerStrikeAction():void {
						var timeToDeplete:Number;
			if (arenaHUD.playerChosenWeaponStrike.fireMode > 0) {
				
				AnimAttackSystem.performMeleeAttackAction(arenaHUD.playerWeaponModeForAttack, arenaSpawner.currentPlayerEntity, arenaHUD.targetEntity, arenaHUD.strikeResult > 0 ? arenaHUD.playerDmgDealRoll : 0);
				
				//game.engine.updateComplete.addOnce(onUpdateTimeActionDone);
				
				// delayTimeElapsed = .3 +  Math.random() * .15  + arenaHUD.playerChosenWeaponStrike.strikeTimeAtMaxRange;
				 timeToDeplete = arenaHUD.playerChosenWeaponStrike.strikeTimeAtMaxRange + arenaHUD.playerChosenWeaponStrike.timeToSwing;
				
			}
			else {
			
				 Weapon.shootWeapon( arenaHUD.playerChosenWeaponStrike.rangeMode, arenaSpawner.currentPlayerEntity, arenaHUD.targetEntity,  arenaHUD.strikeResult > 0 ? arenaHUD.playerDmgDealRoll : 0, _animAttackSystem, true);
				
				 	//game.engine.updateComplete.addOnce(onUpdateTimeActionDone);
					
				// delayTimeElapsed =  .3 + Math.random() * .15 + arenaHUD.playerChosenWeaponStrike.timeToSwing; 
				 timeToDeplete =  arenaHUD.playerChosenWeaponStrike.timeToSwing;
			}
			var tarTimeLeft:Number = movementPoints.movementTimeLeft - timeToDeplete;
			if (tarTimeLeft < 0) tarTimeLeft = 0;
			TweenLite.to( movementPoints, delayTimeElapsed, { movementTimeLeft:tarTimeLeft } );
			_animAttackSystem.resolved.addOnce(resolveStrikeAction2);
			aggroMemManager.addToAggroMem(arenaSpawner.currentPlayerEntity, arenaHUD.targetEntity);
			if (arenaHUD.strikeResult > 0) {
				var targetHP:Health = (arenaHUD.targetEntity.get(Health) as Health);
				if (targetHP.hp > arenaHUD.playerDmgDealRoll) targetHP.onDamaged.addOnce(onEnemyTargetDamaged);
			}
		}
		
		private function showAttacksSimulatenously():Boolean 
		{
			return arenaHUD.enemyStrikeResult != 0 && arenaHUD.strikeResult > 0 &&  arenaHUD.enemyGoesFirst
		}
		
		private function performEnemyCounterAttack():Number 
		{
			return AnimAttackSystem.performMeleeAttackAction(arenaHUD.enemyWeaponModeForAttack, arenaHUD.targetEntity, arenaSpawner.currentPlayerEntity, arenaHUD.enemyStrikeResult > 0 ? arenaHUD.enemyDmgDealRoll : 0);
		}
		
		private function isPlayerDead():Boolean 
		{
			var hp:Health = arenaSpawner.currentPlayerEntity.get(Health) as Health;
			return hp == null || hp.hp <= 0;
		}
		
		private var delayTimeElapsed:Number;
		
		private function onUpdateTimeActionDone():void 
		{
			movementPoints.timeElapsed = 0;
		
			
		}
		
		
		private function onEnemyTargetDamaged(hp:int, amount:int):void {
			if (amount > 0) {
				var stance:GladiatorStance = arenaHUD.targetEntity.get(IAnimatable) as GladiatorStance;
				stance.updateTension( -1*Math.random(), 0);
				stance.flinch();
			}
			else {
				
			}
		}
		
		private function onPlayerDamaged(hp:int, amount:int):void {
			if (amount > 0) {
				var stance:GladiatorStance = arenaSpawner.currentPlayerEntity.get(IAnimatable) as GladiatorStance;
				//stance.flinch();
			}
			else {
				
			}
		}
		
		private function resolveStrikeAction2():void 
		{
			
			
			
			if (arenaHUD.strikeResult == -1) {
				arenaHUD.notifyPlayerActionMiss();
			}
			else {
			//	/*
				var weapState:WeaponState = arenaHUD.targetEntity.get(WeaponState) as WeaponState;
				if (weapState!=null && weapState.trigger && weapState.fireMode != null && weapState.fireMode.fireMode<=0) {
					weapState.cancelTrigger();
					var e:EnemyAggro = arenaHUD.targetEntity.get(EnemyAggro) as EnemyAggro;
					if (e != null) e.flag = 0;
				}
				//*/
			}
			
			
			
			 if (arenaHUD.strikeResult > 0) {
				// TweenLite.delayedCall(.5, resolveStrikeAction3);
				game.engine.addEntity( new Entity().add( new Tween(arenaHUD, .5, { }, { onComplete:resolveStrikeAction3 } )));
			 }
			else resolveStrikeAction3();
		}
		
		
		
		private function resolveStrikeAction3():void 
		{
			
			
		//	resolveStrikeActionFully(true);
		//	return;
			
			if ( arenaHUD.enemyStrikeResult != 0 && !showAttacksSimulatenously() ) {
				//if (arenaHUD.targetEntity.get(Health) == null  || arenaHUD.targetEntity.get(Health).hp <= 0) {
					
				//	throw new Error("Exception healthdeead");
				//}
				
				
					AnimAttackSystem.performMeleeAttackAction(arenaHUD.enemyWeaponModeForAttack, arenaHUD.targetEntity, arenaSpawner.currentPlayerEntity, arenaHUD.enemyStrikeResult > 0 ? arenaHUD.enemyDmgDealRoll : 0);
				_animAttackSystem.resolved.addOnce(resolveStrikeActionFully);
				
				if (arenaHUD.enemyStrikeResult > 0) {
					
					var targetHP:Health = (arenaSpawner.currentPlayerEntity.get(Health) as Health);
					if (targetHP.hp > arenaHUD.enemyDmgDealRoll) targetHP.onDamaged.addOnce(onPlayerDamaged);
				}
				/*
				else {
					resolveStrikeActionFully(true);
				}
				*/
			}
			else {
				
				resolveStrikeActionFully(true);
			}
		}
		
		private function resolveStrikeActionFully(instant:Boolean=false):void 
		{
			// new stuff here
			instant = false;
			EnemyAggroSystem.AGGRO_HAS_CRITICAL = false;
			
			aggroMemManager.setupSupportFireOnTarget(arenaHUD.targetEntity, arenaSpawner.currentPlayerEntity, delayTimeElapsed);
			//(arenaHUD.targetEntity.get(IStance) as GladiatorStance).attacking = true;
			
			playerStriking = false;
			
			
			
			if (aggroMemManager._supportCount != 0) {
				game.engine.addEntity( new Entity().add( new Tween({}, .45, { }, { onComplete:resolveStrikeActionFully2 } )));
			//	TweenLite.delayedCall(.45, resolveStrikeActionFully2); //, [instant]
				//trace("Support fire: +" + aggroMemManager._supportCount);
			}
			else resolveStrikeActionFully2(instant);
			
		}

		private function resolveStrikeActionFully2(instant:Boolean=false):void {
			if (delayTimeElapsed > 0) {
				game.engine.updateComplete.addOnce(onUpdateTimeActionDone);
				movementPointSystem.enabled = false;
				movementPoints.timeElapsed = delayTimeElapsed;	
				
			}
		//	throw new Error("A"+instant);
			//instant = true;
			if (!instant ) {  //&& arenaHUD.enemyStrikeResult > 0
				//TweenLite.delayedCall(delayTimeElapsed+.3, resolveToggleTargetingMode);
				game.engine.addEntity( new Entity().add( new Tween(arenaHUD, .3, { }, { onComplete:resolveToggleTargetingMode } )))
				//resolveToggleTargetingMode();
			}
			else {
				resolveToggleTargetingMode();
			}
		}
		
		private function resolveToggleTargetingMode():void 
		{
			if ( !_animAttackSystem.getResolved()  ) {
				_animAttackSystem.resolved.addOnce(resolveToggleTargetingMode2);
			}
			else {
				resolveToggleTargetingMode2();
			}
			
		}
		
		private function resolveToggleTargetingMode2():void {
			playerStriking = true;
			EnemyAggroSystem.AGGRO_HAS_CRITICAL = true;
			aggroMemManager.removeSupportFire(arenaSpawner.currentPlayerEntity);
			
			toggleTargetingMode();
			sceneLocked = false;
			(arenaSpawner.currentPlayerEntity.get(IStance) as GladiatorStance).attacking = false;
			_followAzimuth = (arenaSpawner.currentPlayerEntity.get(Health) != null);
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
			//arcSystem.arcs.visible = !_targetMode;
			
			if (_targetMode) {
				
				thirdPersonController.thirdPerson.preferedZoom = TARGET_MODE_ZOOM;
				thirdPersonController.thirdPerson.controller.disableMouseWheel();
				movementPointSystem.noDeplete = true;

				_animAttackSystem.checkTime( movementPointSystem.addRealFreeTime(.3) );
				//movementPoints.timeElapsed = movementPointSystem._freeTime;
				//movementPointSystem.enabled = false;
				
				disablePlayerMovement();
				
				
				if (gladiatorStance.stance == 0) {
					//gladiatorStance.stance = 1;
					gladiatorStance.setIdleStance( 1);
				}
				//arenaSpawner.currentPlayerEntity.add(game.keyPoll, KeyPoll); 
			}
			else {
				exitTargetMode();
			
				//gladiatorStance.setIdleStance( _lastTargetStance);
			}
			gladiatorStance.setTargetMode(_targetMode);
		}
		
		private function disablePlayerMovement():void 
		{
			(arenaSpawner.currentPlayerEntity.get(SurfaceMovement) as SurfaceMovement).resetAllStates();
				game.keyPoll.resetAllStates(); 
				
			arenaSpawner.currentPlayerEntity.remove(KeyPoll); 
			//movementPoints.timeElapsed = 0;
			//movementPointSystem._freeTime = 0;
		}
		
		private function exitTargetMode():void 
		{
			_targetMode = false;
			
			arenaHUD.setTargetMode(_targetMode);
			
			thirdPersonController.thirdPerson.preferedZoom = _lastTargetZoom;
			thirdPersonController.thirdPerson.controller.enableMouseWheel();
		
			var gladiatorStance:GladiatorStance = arenaSpawner.currentPlayerEntity.get(IAnimatable) as GladiatorStance;
		
			
			if (movementPoints.movementTimeLeft > 0)  arenaSpawner.currentPlayerEntity.add(game.keyPoll, KeyPoll);
			movementPointSystem.enabled = true;
			movementPointSystem.noDeplete = false;
			gladiatorStance.setTargetMode(_targetMode);
				
		}
		
		
		private  var CAMERA_PHASETO_AVERAGE:Boolean = false; // switch phase new side average position?  else selected target
		private  var CAMERA_PHASEFROM_AVERAGE:Boolean = true;  // old side average position? else nearest target from above
		
		
		private function startPhase():void {
			
			
			sideIndex = 0;
			curArr = arrayOfSides[sideIndex];
			_newPhase = true;
			
			// TODO: Naive vs Exploratory version
			//setSideDanger(curArr);
			for (var i:int = 0; i < arrayOfSides.length; i++) {
				setSideDanger( arrayOfSides[i] );
			}
			
			commandPoints[sideIndex] += COMMAND_POINTS_PER_TURN;
			if (commandPoints[sideIndex] > MAX_COMMAND_POINTS) commandPoints[sideIndex] = MAX_COMMAND_POINTS;
			
			updateCP();
			
			if (game.gameStates.engineState.currentState != engineStateCommander) {
				_transitCompleteCallback = selectFirstMan;
				changeCameraView("commander");
			
			}
			
			aggroMemManager.notifyStartPhase(sideIndex);
		}
		
		private function setSideDanger(arr:Array):void 
		{
			var len:int = arr.length;
			for (var i:int = 0; i < len; i++) {
				var stance:GladiatorStance = arr[i].get(IAnimatable) as GladiatorStance;
				if (stance != null) {
					stance.danger = true;
					stance.setStanceAndRefresh(stance.preferedStance);
				}
				
			}
		}
		
		private function selectFirstMan():void {
			setTimeout(selectFirstMan2, 0);
			
		}
		
		private function selectFirstMan2():void {
			cyclePlayerChoice(0);
			
		}
		
		private function endPhase():void {
			
		
			
			
			if (game.gameStates.engineState.currentState != engineStateCommander) {
				doEndTurn();
				return;
			}
			
			
			
			
	
			var oldArr:Array = arrayOfSides[sideIndex];
			len = oldArr.length;
			for (i = 0; i < len; i++ ) {
				var stance:GladiatorStance = oldArr[i].get(IAnimatable) as GladiatorStance;
				if (stance !=null && stance.stance != stance.preferedStance) stance.setStanceAndRefresh(stance.preferedStance);
			}

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

	

		
		private function unsetPlayerHP():void {
			var hp:Health = arenaSpawner.currentPlayerEntity.get(Health) as Health;
			if (hp != null) {
				hp.unsetFlags( HealthFlags.FLAG_PLAYER );
			}
		}
		
		private function setPlayerHP():void {
			var hp:Health = arenaSpawner.currentPlayerEntity.get(Health) as Health;
			if (hp != null) {
				hp.setFlags( HealthFlags.FLAG_PLAYER );
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
			
			
		
			
			
			if (arenaSpawner.currentPlayerEntity) {
				
				arenaSpawner.currentPlayerEntity.remove(MovementPoints);
				unsetPlayerHP();
			}
			arenaSpawner.switchPlayer(curArr[testIndex], stage);
			
			var stance:GladiatorStance;
		
			stance = arenaSpawner.currentPlayerEntity.get(IAnimatable) as GladiatorStance;
			stance.setTargetMode(_targetMode);
			stance.attacking = false;
			
			
			for (var i:int = 0; i < curArr.length; i++) {
				if (i != testIndex) {
					stance = curArr[i].get(IAnimatable) as GladiatorStance;
					if (stance == null) continue;
					if (stance.stance==0) stance.setStanceAndRefresh(1);
					//setTimeout(stance.crouch, Math.random() * 600);
					stance.setStanceAndRefresh(2);
					
				}
			}
			
			
			
			
			var counter:Counter = arenaSpawner.currentPlayerEntity.get(Counter) as Counter;
			movementPoints.movementTimeLeft = MAX_MOVEMENT_POINTS / (1 << counter.value);
			
			counter.value++;
			
			setPlayerHP();
			arenaSpawner.currentPlayerEntity.add( movementPoints, MovementPoints);
			//var untyped:* = arenaSpawner.currentPlayerSkin.getSurface(0).material;
			//arenaSpawner.currentPlayerSkin.getSurface(0).material as 
			//arenaSpawner.currentPlayerSkin.getSurface(0).material
			thirdPersonController.thirdPerson.setFollowComponents( arenaSpawner.currentPlayer, arenaSpawner.currentPlayerEntity.get(Rot) as Rot);
			thirdPersonController.thirdPerson.setVisAlphaInstance( arenaSpawner.currentPlayer, .95 );
			thirdPersonAiming.setCameraParameters(thirdPersonController.thirdPerson.followTarget, _template3D.camera, thirdPersonController.thirdPerson.cameraForward);
			thirdPersonAiming.setEntity( arenaSpawner.currentPlayerEntity);
			
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
		
				_transitCompleteCallback = onCharacterZoomedInTurnStartl
				game.gameStates.engineState.changeState("transiting");
				arenaHUD.setState("transiting");
				
				transitionCameras(commanderCameraController.thirdPerson, thirdPersonController.thirdPerson, targetState);
			}
			else if (targetState === "commander" && game.gameStates.engineState.currentState === game.gameStates.thirdPerson) {
				doEndTurn();
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
		
		private function doEndTurn():void 
		{
			///*
			if (!_animAttackSystem.getResolved()) {
					disablePlayerMovement();
					sceneLocked = true;
					_followAzimuth = false;
					arenaHUD.appendSpanTagMessage("Resolving turn...");
					_animAttackSystem.resolved.addOnce(doEndTurn);
					
				
					return;
				}
			
				_followAzimuth = true;
				var targetState:String = "commander";
				//throw new Error("A");
				if (!_newPhase) arenaHUD.appendSpanTagMessage("Turn resolved!");
				//*/
				
				_newPhase = false;
			
				sceneLocked = false;
			_transitCompleteCallback = focusOnCurPlayer;
				updateTargetCharFocus();
				if (arenaSpawner.currentPlayerEntity) arenaSpawner.currentPlayerEntity.remove(MovableCollidable);
				arenaHUD.setTargetChar(null);
				endTurnAI();
				
				
				game.gameStates.engineState.changeState("transiting");
				arenaHUD.setState("transiting");
				transitionCameras(thirdPersonController.thirdPerson, commanderCameraController.thirdPerson, targetState, NaN, NaN, NaN, Cubic.easeIn);
		}
		
		private function onCharacterZoomedInTurnStartl():void 
		{
			var stance:GladiatorStance = arenaSpawner.currentPlayerEntity.get(IAnimatable) as GladiatorStance;
			if (stance.stance != stance.preferedStance) stance.setStanceAndRefresh(stance.preferedStance);
			stance.enableFast = true
			
			/*
			for (var i:int = 0; i < curArr.length; i++) {
				if (i != testIndex) {
					var stance:GladiatorStance = curArr[i].get(IAnimatable) as GladiatorStance;
					if (stance.stance==0) stance.setStanceAndRefresh(1);
					setTimeout(stance.crouch, Math.random() * 600);
					
				}
			}
			*/
		}
		
	
		
		private var _targetTransitState:String;
		private var _animAttackSystem:AnimAttackSystem;
		private var arcSystem:A3DEnemyArcSystem;
		private var thirdPersonAiming:ThirdPersonAiming;
		private var _newPhase:Boolean;

		
		

		
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
				if ( _targetTransitState === "thirdPerson" ) {
		
					/*
					if (destCalcTester) {
					destCalcTester.pos = arenaSpawner.getPlayerEntity().get(Pos) as Pos;
					destCalcTester.rot = arenaSpawner.getPlayerEntity().get(Rot) as Rot;
					destCalcTester.ellipsoid = arenaSpawner.getPlayerEntity().get(Ellipsoid) as Ellipsoid;
					destCalcTester.gravity = arenaSpawner.getPlayerEntity().get(Gravity) as Gravity;
					destCalcTester.surfaceMovement = arenaSpawner.getPlayerEntity().get(SurfaceMovement) as SurfaceMovement;
					destCalcTester.movementPoints = arenaSpawner.getPlayerEntity().get(MovementPoints) as MovementPoints;
					}
					*/
					activateEnemyAggro();
					
				}
			}
			else  {
				arenaHUD.showStars();
				if (SHOW_PREFERED_STANCES_ENDTURN==2) {
					showPreferedStances();
				}
				if (arenaSpawner.currentPlayerEntity) {
					unsetPlayerHP();
					arenaSpawner.currentPlayerEntity.remove(MovementPoints);
				}
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
			
			
			if (SHOW_PREFERED_STANCES_ENDTURN==1) showPreferedStances();
		
		}
		
		private function showPreferedStances():void {
			var i:int;
			var len:int = curArr.length;
			for (i = 0; i < len; i++) {
				var stance:GladiatorStance = curArr[i].get(IAnimatable) as GladiatorStance;
				if (stance.stance != stance.preferedStance) stance.setStanceAndRefresh(stance.preferedStance);
			}
		}

		
		private function activateEnemyAggro():void 
		{
			arenaSpawner.currentPlayerEntity.add( new MovableCollidable().init() ); // temp, for testing only
			aggroMemManager.notifyTurnStarted(arenaSpawner.currentPlayerEntity);
			delayTimeElapsed= arcSystem.setTimeElapsed(arenaSpawner.currentPlayerEntity.get(Weapon) as Weapon);
			
			// temporary, considering putting this in aggroMemManager???
			///*
			var otherSide:int = aggroMemManager.activeSide == 0 ? 1 : 0;
			var enemySide:Array = arrayOfSides[otherSide];
			var len:int = enemySide.length;
			for ( var i:int = 0; i < len; i++) {
				var e:Entity = enemySide[i];
				e.add( new collOtherClass().init() );
				(e.get(IStance) as GladiatorStance).attacking = true;
			
			}
			
			var mySide:Array = arrayOfSides[aggroMemManager.activeSide];
			len = mySide.length;
			for ( i = 0; i < len; i++) {
				e= mySide[i];
				if (e === arenaSpawner.currentPlayerEntity) continue;
				e.add( new collOtherClass().init() );
				(e.get(IStance) as GladiatorStance).attacking = false;
			
			}
		//	*/
			
		}
		
		private function onOutOfFuel():void {
			
			//arenaSpawner.currentPlayerEntity.get(Vel).x = 0;
		//	arenaSpawner.currentPlayerEntity.get(SurfaceMovement);
		//	cyclePlayerChoice();
			game.keyPoll.resetAllStates()
			arenaSpawner.currentPlayerEntity.remove(KeyPoll); 
			//movementPoints.timeElapsed = 0;
			
		
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

			var terrainRaycast:TerrainRaycastImpl;
			collisionScene.addChild( terrainRaycast = new TerrainRaycastImpl(_terrainBase.terrain) );
			
		thirdPersonController.thirdPerson.preferedMinDistance = 0.1;// 100;
		thirdPersonController.thirdPerson.controller.minDistance = 0;
		thirdPersonController.thirdPerson.controller.maxDistance = 2240;
		thirdPersonController.thirdPerson.offsetZ = 22;// CHASE_Z_OFFSET;
		//thirdPersonController.thirdPerson.offsetX = 22;
			game.gameStates.thirdPerson.addInstance( thirdPersonAiming = new ThirdPersonAiming() ).withPriority(SystemPriorities.preRender);
			game.gameStates.thirdPerson.addInstance(thirdPersonController).withPriority(SystemPriorities.postRender);
			
			
			arcSystem = new A3DEnemyArcSystem(_template3D.scene);
			//arenaHUD.arcContainer = arcSystem.arcs;
			game.gameStates.thirdPerson.addInstance(arcSystem ).withPriority(SystemPriorities.postRender);
			_waterBase.hideFromReflection.push(arcSystem.arcs);
			
			// setup targeting system
			var myTargetingSystem:ThirdPersonTargetingSystem = new ThirdPersonTargetingSystem(thirdPersonController.thirdPerson);
			targetingSystem = myTargetingSystem;
			game.gameStates.thirdPerson.addInstance(targetingSystem).withPriority(SystemPriorities.postRender);
			targetingSystem.targetChanged.add(onTargetChanged);
			targetingSystem.targetChanged.add(arenaHUD.setTargetChar);
			
			/*
			game.gameStates.thirdPerson.addInstance( new TrajRaycastTester(terrainRaycast, thirdPersonController.thirdPerson.rayOrigin, thirdPersonController.thirdPerson.rayDirection) ).withPriority(SystemPriorities.postRender);
			*/
			
			/*
			game.gameStates.thirdPerson.addInstance( new EdgeRaycastTester(terrainRaycast as TerrainRaycastImpl,thirdPersonController) ).withPriority(SystemPriorities.postRender);
			*/
			
		//	game.gameStates.thirdPerson.addInstance( destCalcTester = new DestCalcTester(new Ellipsoid(20, 20, 36), new Vec3(), new Vec3(), game.colliderSystem.collidable, _debugBox  ) );
			
		
			
		
			// special PVP movement limited time
			movementPointSystem;
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
			
			
			game.gameStates.thirdPerson.addInstance( _animAttackSystem =  new AnimAttackSystem() ).withPriority(SystemPriorities.stateMachines);
		//	game.gameStates.( _animAttackSystem=  new AnimAttackSystem() ).withPriority(SystemPriorities.stateMachines);
			game.gameStates.thirdPerson.addInstance( _enemyAggroSystem = new A3DEnemyAggroSystem(collisionScene) ).withPriority(SystemPriorities.stateMachines);
			
			_enemyAggroSystem.timeChecker = _animAttackSystem;
			//_enemyAggroSystem.onEnemyAttack.add(onEnemyAttack);
		//	_enemyAggroSystem.onEnemyReady.add(onEnemyReady);
	
		//		_enemyAggroSystem.onEnemyStrike.add(onEnemyStrike);
		
		//_enemyAggroSystem.onEnemyCooldown.add(onEnemyCooldown);
			
			
			// aggro mem manager
			aggroMemManager = new AggroMemManager();
			aggroMemManager.weaponLOSChecker = _enemyAggroSystem;
			arenaHUD.weaponLOSCheck = _enemyAggroSystem;
			aggroMemManager.init(game.engine, _enemyAggroSystem, _enemyAggroSystem);
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
				
				gStance.setIdleStance(1);
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
			if ((e.get(WeaponState) as WeaponState).fireMode.fireMode > 0) {
			arenaHUD.appendMessage("Enemy interrupt occured!");
			//arenaHUD.appendMessage(obj.name+" finiished his strike!");
			onEnemyInterrupt();
			}
			
		}
		
		private function onEnemyReady(e:Entity):void 
		{
			var obj:Object3D = e.get(Object3D) as Object3D;
			arenaHUD.appendMessage(obj.name+" is ready to attack!");
		}
		
		private var playerStriking:Boolean = false;
		
		
		private function onDamaged(e:Entity, hp:int, amount:int):void 
		{
			var stance:GladiatorStance;
			if (e != arenaSpawner.currentPlayerEntity) {  // assume damage inflicted by active currentPlayerEntity
				if ( playerStriking ) {
					arenaHUD.txtPlayerStrike(e, hp, amount);
				}
				else {
					arenaHUD.txtEnemyGotHit(e, hp, amount);
					stance = e.get(GladiatorStance) as GladiatorStance;
					if (stance != null) stance.flinch();
				}
			}
			else {  // assume damage taken from entity under aggro system
				
				if (amount > 0)  {
					arenaHUD.txtTookDamageFrom(_enemyAggroSystem.currentAttackingEnemy, hp, amount);
			//		movementPoints.movementTimeLeft -= .5;
					if ( movementPoints.movementTimeLeft < 0) movementPoints.movementTimeLeft = 0;
					var gladiatorStance:GladiatorStance = arenaSpawner.currentPlayerEntity.get(IStance) as GladiatorStance;
					if (gladiatorStance != null) {
						//gladiatorStance.enableFast = false;
						if (sceneLocked) gladiatorStance.flinch();
					
					}
					
					
				}
				
			}
		}
		
		private function onMurdered(e:Entity, hp:int, amount:int):void 
		{
			if (e != arenaSpawner.currentPlayerEntity) {  // assume active currentPlayerEntity killed entity
				arenaHUD.txtPlayerStrike(e, hp, amount, true);
				unregisterEntity(e);
				
				arenaSpawner.killGladiator2(e, deadScene);
			
			
			}
			else {  // assume currentePlayerNEtity killed by entity under aggro system!
				arenaHUD.txtTookDamageFrom(_enemyAggroSystem.currentAttackingEnemy, hp, amount, true);
				unregisterEntity(arenaSpawner.currentPlayerEntity);
				if (curArr[testIndex] == null) {  // do a naive reset for this case.
					testIndex = 0;
					//throw new Error("null pointer after unregistration...");
				}
				
				arenaSpawner.killGladiator2(arenaSpawner.currentPlayerEntity, deadScene);
				
				_followAzimuth = false;
				arenaHUD.killPlayer();
				
				//game.engine.removeEntity(arenaSpawner.currentPlayerEntity);
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
		
		private function createHPBarSet():HealthBarSet {
			
			var hpBarSet:HealthBarSet = new HealthBarSet(100, new HealthBarFillMaterial(0xFFFFFF, 1), 10, 64, 4);
			
			SpawnerBundle.uploadResources(hpBarSet.getResources());
			_template3D.scene.addChild(hpBarSet);
			_waterBase.hideFromReflection.push(hpBarSet);
			return hpBarSet;
		}
		
		
		private function onSpawnerBundleLoaded():void 
		{
			removeChild(_preloader);			
			_template3D.visible = true;
			
		
		//	_template3D.scene.addChild( 
	
			game.gameStates.thirdPerson.addInstance( _targetBoardTester = new TargetBoardTester(_template3D.scene, null, _template3D.camera) ).withPriority(SystemPriorities.preRender);
			
			
			game.engine.addSystem( new HealthBarRenderSystem( createHPBarSet(), ~HealthFlags.FLAG_PLAYER ), SystemPriorities.render );
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
			setupProjectiles();
			
			ticker = new FrameTickProvider(stage);
			ticker.add(renderTick);
			ticker.start();
			
			updateTicker =  new FrameTickProvider(stage);// new UnitTickProvider(stage, fixedTime);
			updateTicker.add(updateTick);
			updateTicker.start();
		}
		
		private var fixedTime:Number = 1 / 40;

		
		private var updateTicker:ITickProvider;
		private var targetingSystem:ThirdPersonTargetingSystem;
		private var movementPointSystem:LimitedPlayerMovementSystem;
		private var _debugBox:Box;
		private var occluderTest:Occluder;
		private var _targetBoardTester:TargetBoardTester;
		//private var destCalcTester:DestCalcTester;
		
		private function setupInterface():void 
		{


		}
		
		private function updateCP():void 
		{
		//	testCPLabel.text = (sideIndex > 0 ? "Ghost army" : "Player army" )+" CP left: "+commandPoints[sideIndex] +" / "+MAX_COMMAND_POINTS;
			arenaHUD.updateTurnInfo( commandPoints[sideIndex], MAX_COMMAND_POINTS, (sideIndex > 0 ? "Ghost army" : "Player army" ), sideIndex, COMMAND_POINTS_PER_TURN );
		}
		

		private function updateTick(time:Number):void {
			//if (time != 1 / 60) throw new Error("DIFF");
			//time *= 4;
			
			game.engine.update(time);
			arenaHUD.updateFuel( movementPoints.movementTimeLeft / MAX_MOVEMENT_POINTS );
			arenaHUD.update();
		}
		
		private function renderTick(time:Number):void {
			thirdPersonController.thirdPerson.followAzimuth = _followAzimuth || game.keyPoll.isDown(Keyboard.V);
			var camera:Camera3D = _template3D.camera;
			
			_skyboxBase.update(_template3D.camera);
			
			_template3D.camera.startTimer();

			// adjust offseted waterlevels
	
			
			_waterBase.waterMaterial.update(_template3D.stage3D, _template3D.camera, _waterBase.plane, _waterBase.hideFromReflection);
			_template3D.camera.stopTimer();

			// set to default waterLevels

			_template3D.render();
		}
		
		private function tick(time:Number):void 
		{
			thirdPersonController.thirdPerson.followAzimuth = _followAzimuth || game.keyPoll.isDown(Keyboard.V);
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
		
		public function get sceneLocked():Boolean 
		{
			return _sceneLocked;
		}
		
		public function set sceneLocked(value:Boolean):void 
		{
			_sceneLocked = value;
		}
		
	}

}
import ash.core.Entity;
import components.Health;


class Counter {
	public var value:int = 0;
	
}
