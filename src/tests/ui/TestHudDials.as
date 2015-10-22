package tests.ui 
{
	import alternativa.a3d.collisions.CollisionBoundNode;
	import alternativa.a3d.collisions.CollisionUtil;
	import alternativa.a3d.controller.SimpleFlyController;
	import alternativa.a3d.controller.ThirdPersonController;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.Renderer;
	import alternativa.engine3d.materials.FillMaterial;
	import alternativa.engine3d.materials.Material;
	import alternativa.engine3d.objects.Hud2D;
	import alternativa.engine3d.objects.Mesh;
	import alternativa.engine3d.objects.SpriteMeshSetClone;
	import alternativa.engine3d.objects.SpriteMeshSetClonesContainer;
	import alternativa.engine3d.primitives.Plane;
	import alternativa.engine3d.RenderingSystem;
	import alternativa.engine3d.resources.BitmapTextureResource;
	import alternativa.engine3d.spriteset.materials.MaskColorAtlasMaterial;
	import alternterrain.CollidableMesh;
	import arena.views.hud.HudBase;
	import ash.core.Entity;
	import ash.tick.FrameTickProvider;
	import components.Pos;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
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
	public class TestHudDials extends MovieClip
	{
		private var _template3D:MainView3D;
		private var game:TheGame;
		private var ticker:FrameTickProvider;
		private var _preloader:PreloaderBar = new PreloaderBar()
		private var bundleLoader:SpawnerBundleLoader;
		
		private var spectatorPerson:SimpleFlyController;
		private var arenaSpawner:ArenaSpawner;
		private var collisionScene:Object3D;
		
		[Embed(source="../../../resources/fonts/dialsymbols.png")]
		private var DIAL_SYMBOLS:Class;
		
		public function TestHudDials() 
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
			game.gameStates.engineState.changeState("thirdPerson");
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
			setupHUD();
			setupStartingEntites();
			setupGameplay();

			
			ticker = new FrameTickProvider(stage);
			ticker.add(tick);
			ticker.start();
		}
		
		private function setupHUD():void 
		{
			var myHud:MyHud = new MyHud(stage, new DIAL_SYMBOLS().bitmapData );
				_template3D.camera.addChild(myHud.hud);
		//	myHud.manualInit();
			
			
		
			
		}
		

		
		private function tick(time:Number):void 
		{
			game.engine.update(time);
			_template3D.render();
		}
		
	}

}
import alternativa.engine3d.core.Object3D;
import alternativa.engine3d.objects.SpriteMeshSetClone;
import alternativa.engine3d.objects.SpriteMeshSetClonesContainer;
import alternativa.engine3d.resources.BitmapTextureResource;
import alternativa.engine3d.spriteset.materials.MaskColorAtlasMaterial;
import arena.views.hud.HudBase;
import flash.display.BitmapData;
import flash.display.Stage;
import flash.geom.Point;
import util.SpawnerBundle;
import alternativa.engine3d.alternativa3d;
use namespace alternativa3d;

class MyHud extends HudBase {
	private var _myDialSymbols:SpriteMeshSetClonesContainer;
	private var dialSymbols:BitmapData;
	private var c:SpriteMeshSetClone;
	public function MyHud(stage:Stage, dialSymbols:BitmapData) {
	
		this.dialSymbols = dialSymbols;
		
		super(stage);
	}
		
		
		

	override protected function init():void {
		
		
		var bmpData:BitmapData = dialSymbols;
		//addChild( new Bitmap(bmpData));
	
		var material:MaskColorAtlasMaterial = new MaskColorAtlasMaterial( new BitmapTextureResource( bmpData ) );
		//material.alphaThreshold =0.2;
		material.color = 0xFFFFFF;
	//	material.transparentPass = false;
		material.alphaThreshold = .8;
//		material.flags = (MaskColorAtlasMaterial.FLAG_MIPNONE | MaskColorAtlasMaterial.FLAG_PIXEL_NEAREST);
		
		
		
		var cont:SpriteMeshSetClonesContainer = _myDialSymbols =  new SpriteMeshSetClonesContainer( material);
		//cont.objectRenderPriority = Renderer.NEXT_LAYER;
		hud.addChild(cont);
		
		
		var dial:Array = createDial();
		//layoutBottomRight.addChild(  createDial() );
		setDialValues(dial, 6, 20, 0, 3, 4, 0, 0);
		SpawnerBundle.uploadResources(cont.getResources());
		
		super.init();
	}
	
	public static const DIAL_EMPTY:Number = 0/128;
	public static const DIAL_FILLED:Number = 1*16/128;
	public static const DIAL_PAIN:Number = 2*16/128;
	public static const DIAL_SHOCK:Number = 3*16/128;
	public static const DIAL_SPENT:Number = 4*16/128;
	public static const DIAL_PENALISE:Number = 5*16/128;
	public static const DIAL_DOT:Number = 6*16/128;
	public static const DIAL_BUY:Number = 7*16/128;
	
	public static const DIAL_BAR:Number = 6*16/128;
	
	public function setDialValues(dial:Array, usingCP:int, totalCP:int, spentCP:int=0, pain:int = 0, shock:int=0, manueverCost:int=0, intiativeBought:int=0):void {
		var i:int;
		
		
		var len:int = usingCP;
	
		c = dial[0];
		//c.u = DIAL_BAR;
		
		for (i = 0; i < len; i++) {
			c = dial[i];
			c.u = DIAL_FILLED;
			//c.u = ;
			
		}
		len = totalCP;
		for (i = i;  i < len; i++) {
			c = dial[i];
			c.u = DIAL_EMPTY;
			
		}
		
		c = dial[i];
		c.u = DIAL_EMPTY ;
		i++;
		
		len = dial.length;
		for (i = i; i < len ; i++ ) {
			c = dial[i];
			c.u = DIAL_DOT;
		}
		
		
		c = dial[totalCP];
		c.u = DIAL_BAR ;
		
		if (pain >= shock) shock = 0
		else shock = shock - pain;
		
		i = totalCP;
		while (--i > -1) {
			
			c = dial[i];
			c.u = DIAL_PAIN;
			pain--;
			if (pain == 0) break;
		}
		
		while (--i > -1) {
			if (shock == 0) break;
			c = dial[i];
			c.u = DIAL_SHOCK;
			shock--;
		}

	}
	
	public function setupSprite():void {
		
	}
	
	
	
	protected function createDial():Array {
		
		var c:SpriteMeshSetClone;

		var arr:Array = [];
		var radius:Number = 42;// 34;
		var len:int = 26;
		var division:Number = 2 * Math.PI / len;
		 for (var i:int = 0 ; i < len; i++) {
			 //  var pos:Point = Point.polar(radius, (i / len) * Math.PI * 2);
			  _myDialSymbols.addClone( c =  getSprite(_myDialSymbols, 16 * 0, 0, 16, 16, -8, -8, null) );
			  arr.push(c);
			 c.root._x =Math.cos( -Math.PI * .5 + division * i ) * radius;
			  c.root._y = Math.sin( -Math.PI * .5 + division * i) * radius;
			  c.root.rotationZ = division * i;
			//if (c.root.rotationZ == 0) c.root.rotationZ = 0.2;
		//	c.root.scaleX = 12;
		//	c.root.scaleY = 12;
		 }
		
		// obj.transform.copy(layoutBottomRight.transform);
		// obj.transform.append(
		
		return arr;
	}
	
	
}