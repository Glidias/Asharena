package tests.flocking 
{
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.loaders.ParserA3D;
	import alternativa.engine3d.materials.FillMaterial;
	import alternativa.engine3d.materials.StandardMaterial;
	import alternativa.engine3d.materials.TextureMaterial;
	import alternativa.engine3d.objects.Skin;
	import alternativa.engine3d.objects.SkinClonesContainer;
	import alternativa.engine3d.primitives.Plane;
	import alternativa.engine3d.RenderingSystem;
	import alternativa.engine3d.resources.BitmapTextureResource;
	import alternativa.engine3d.Template;
	import alternativa.stances.MechStance;
	import ash.core.Engine;
	import ash.core.Entity;
	import ash.tick.FrameTickProvider;
	import components.flocking.Flocking;
	import components.flocking.FlockSettings;
	import components.Pos;
	import components.Rot;
	import components.Vel;
	import flash.display.Bitmap;
	import flash.events.IEventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.system.Security;
	import flash.system.SecurityDomain;
	import flash.ui.Keyboard;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import systems.animation.AnimationSystem;
	import systems.animation.IAnimatable;
	import systems.movement.FlockingSystem;
	import systems.player.a3d.AnimationManager;

	import flash.display.DisplayObject;	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Vector3D;

	/**
	 * ...
	 * @author Glenn Ko
	 */
	//[SWF(width="600", height="400", frameRate="40", backgroundColor="0xddddff")]
	public class TestFlocking3D extends MovieClip
	{
			public var engine:Engine;
		public var ticker:FrameTickProvider;
		
		public static const WORLD_SCALE:Number = 8;
				
		private  var WORLD_WIDTH:Number = 600*WORLD_SCALE;
		private  var WORLD_HEIGHT:Number = 400*WORLD_SCALE;
		
		private static const NUMBOIDS:int = 100;
		static public const MIN_SPEED:Number = 4*WORLD_SCALE;
		static public const MAX_SPEED:Number = 32*WORLD_SCALE;
		static public const TURN_RATIO:Number = 0.5;
		static public const MIN_DIST:Number = 65*WORLD_SCALE;
		static public const SENSE_DIST:Number = 200*WORLD_SCALE;
		static public const DEFAULT_ROT_X:Number = Math.PI * .5; // for boid

		
		private var _skin:Skin;
		private var _animManager:AnimationManager;
		private var rootContainer:Object3D = new Object3D();
		public var myAssets:Assets;
		
		
		
		public function TestFlocking3D() 
		{
			super();
			// Wonderfl.disable_capture();
			
			//ReflectUtil.registerComponents([Pos,Rot,Vel,Flocking,Object3D,IAnimatable]);
			
			
			myAssets = new Assets();
			if (myAssets.MECH_SKIN != null) {
				init();
			}
			else {
				myAssets.addEventListener(Event.COMPLETE, init);
				var domain:SecurityDomain = loaderInfo.url.indexOf("file://") >= 0 ? null : SecurityDomain.currentDomain;
				if (domain != null) {
					Security.loadPolicyFile("http://glidias.uphero.com/crossdomain.xml");	
				}
				myAssets.load("http://glidias.uphero.com/flockmech.swf", "tests.flocking", new LoaderContext(true, null,domain));
			}
			
		}
		
		private function init(e:Event=null):void {
			
			engine = new Engine();
			
			engine.addSystem( new FlockingSystem(), 0 );
			engine.addSystem( new AnimationSystem(), 1 );
			//engine.addSystem( new DisplayObjectRenderingSystem(this), 1);
			
			ticker = new FrameTickProvider(stage);
			ticker.add(tick);
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			
			MechStance.RANGE = 1 / MAX_SPEED;
			addChild( _template3d = new Template());
			_template3d.settings.cameraSpeed *= 4;
			SkinClonesContainer;
			_template3d.settings.cameraSpeedMultiplier *= 2;
			_template3d.addEventListener(Template.VIEW_CREATE, onReady3D);
	
			//startGame();
		}
		
	
		private var _template3d:Template;
		private function onReady3D(e:Event):void 
		{
			
			
			(e.currentTarget as IEventDispatcher).removeEventListener(e.type, onReady3D);
			engine.addSystem( new RenderingSystem(rootContainer), 2 );
			
			var child:Object3D = _template3d.scene.addChild( new Plane( WORLD_WIDTH, WORLD_HEIGHT, 1, 1, false, false, null, new FillMaterial(0x222222, 1) ) );
			child.x += WORLD_WIDTH * .5;
			child.y += WORLD_HEIGHT * .5;
			//rootContainer.rotationZ = Math.PI;

			var parser:ParserA3D = new ParserA3D();
			parser.parse(new myAssets.MECH_KAYRATH());
			var skin:Skin = findSkin(parser.objects);
			
			var standardMaterial:StandardMaterial = new StandardMaterial( new BitmapTextureResource(new myAssets.MECH_SKIN().bitmapData), _template3d.normalResource);
			skin.geometry.calculateNormals();
			skin.geometry.calculateTangents(0);
			skin.rotationX = Math.PI * .5;
			skin.rotationZ = Math.PI*.5;
			
			standardMaterial.specularPower = 0;
			skin.boundBox = null;
			skin.setMaterialToAllSurfaces(standardMaterial);
			//_template3d.scene.addChild(skin); 
			_skin = skin;
			
			_animManager = new AnimationManager();
			var animBytes:ByteArray =  new myAssets.MECH_ANIMS();
			animBytes.uncompress();
			_animManager.readExternal(animBytes );
			
			_template3d.cameraController.setObjectPos(new Vector3D(WORLD_WIDTH * .5, WORLD_HEIGHT * .5, 100));
			//_template3d.camera.transformChanged = true;
			//_template3d.cameraController.update();
			//throw new Error(_animManager.animClips[0].name);
			
			_template3d.scene.addChild(rootContainer);
			_template3d.uploadResources(_template3d.scene.getResources(true));
			_template3d.uploadResources(skin.getResources());
			
			startGame();
		}
		
		private function startGame():void 
		{
			createBoids();
			ticker.start();
		}
		private function findSkin(objects:Vector.<Object3D>):Skin {
			for each(var obj:Object3D in objects) {
				if (obj is Skin) return obj as Skin;
			}
			throw new Error("Could not find skin:");
			return null;
		}
		
		
		private var playing:Boolean = true;
		
		private function onKeyDown(e:KeyboardEvent):void 
		{
			var kc:uint = e.keyCode;
			if (kc === Keyboard.P) {
				playing = !playing;
				if (playing) ticker.start()
				else ticker.stop();
			}
			else if (kc === Keyboard.F6) {
				_template3d.takeScreenshot(screenieMethod);
			}
			else if (kc === Keyboard.F7) {
				_scrnie=_template3d.takeScreenshot(screenieMethod2);
			}
		}
		
		  private function screenieMethod():Boolean 
        {
        //    Wonderfl.capture(); //
			return true;
        
        }
		
		 private function screenieMethod2():Boolean 
        {
			stage.addEventListener(MouseEvent.CLICK, removeScreenie);
            return false;
        }
		private var _scrnie:Bitmap;
		  private function removeScreenie(e:Event=null):void {
            if (_scrnie == null) return;
            stage.removeEventListener(MouseEvent.CLICK, removeScreenie);
            _scrnie.parent.removeChild(_scrnie);
            _scrnie = null;
        }
		
		
		private function tick(time:Number):void 
		{
			engine.update(time);
			
			_template3d.cameraController.update(time);
			_template3d.camera.render(_template3d.stage3D); // onRenderTick();
		}
		
		
		private function createBoids():void 
		{
			
			 var tmp:Number = 2.0 * Math.PI / NUMBOIDS;
			 
				var tmpw:int = WORLD_WIDTH / 2 , tmph:int = WORLD_HEIGHT / 2;
				var flockSettings:FlockSettings = Flocking.createFlockSettings(MIN_DIST,SENSE_DIST,0,0,tmpw*2, tmph*2, MIN_SPEED, MAX_SPEED, TURN_RATIO);
			  
			for (var i:int = 0; i < NUMBOIDS; ++i) {
				 const ph:Number = i * tmp;
				var pos:Pos = new Pos(  tmpw + ((i % 4) * 0.2 + 0.3) * tmpw * Math.cos(ph), tmph + ((i % 4) * 0.2 + 0.3) * tmph * Math.sin(ph));
				
				
				var vel:Vel = new Vel( ((i%4)*(-4) + 16) * Math.cos(ph + Math.PI / 6 * (1+i%4) * (Math.random() - 0.5)),  ((i%4)*(-4) + 16) * Math.sin(ph + Math.PI / 6 * (1+i%4) * (Math.random() - 0.5)));
				
				var rot:Rot = new Rot(0, 0, Math.random() * 2 * Math.PI);
				

				
				var entity:Entity = new Entity().add(pos).add(rot).add(vel).add( new Flocking().setup(flockSettings )) ;
				
				//entity.add( new BoidGraphic(), DisplayObject);
				var obj:Object3D = new Object3D();
				var skin:Skin = _skin.clone() as Skin;
				obj.addChild(skin);

				entity.add( new MechStance( _animManager.cloneFor(skin), vel, SkinClonesContainer ), IAnimatable).add(obj);
				
				
				engine.addEntity(entity);
			}
		}
		
		
		
	
	}
		

}
