package tests.pathbuilding 
{
	import alternativa.a3d.controller.SimpleFlyController;
	import alternativa.a3d.controller.SimpleObjectController;
	import alternativa.engine3d.effects.TextureAtlas;
	import alternativa.engine3d.materials.FillMaterial;
	import alternativa.engine3d.materials.TextureMaterial;
	import alternativa.engine3d.primitives.Plane;
	import alternativa.engine3d.RenderingSystem;
	import alternativa.engine3d.resources.BitmapTextureResource;
	import alternativa.engine3d.spriteset.materials.SpriteSheet8AnimMaterial;
	import alternativa.engine3d.spriteset.materials.TextureAtlasMaterial;
	import alternativa.engine3d.spriteset.SpriteSet;
	import alternativa.engine3d.spriteset.util.SpriteGeometryUtil;
	import ash.tick.FrameTickProvider;
	import flash.display.MovieClip;
	import flash.geom.Vector3D;
	import flash.utils.setTimeout;
	import systems.collisions.EllipsoidCollider;
	import systems.SystemPriorities;
	import util.SpawnerBundle;
	import views.engine3d.MainView3D;
	/**
	 * ...
	 * @author Glidias
	 */
	public class TestDirectionalSprites extends MovieClip 
	{
		private var _template3D:MainView3D;
		private var game:TheGame;
		private var ticker:FrameTickProvider;
		private var sprite8Mat:*;
		private var spectatorPerson:SimpleObjectController;
		
		
		[Embed(source = "../../../resources/daggerfl/lich.png")]
		public static var SHEET_TEST:Class;
		
		
		
		public function TestDirectionalSprites() 
		{
			haxe.initSwc(this);
		
			
			game = new TheGame(stage);
	
			addChild( _template3D = new MainView3D() );
			_template3D.onViewCreate.add(onReady3D);
			
				
		
		}
		
		private function onReady3D():void 
		{
			SpawnerBundle.context3D = _template3D.stage3D.context3D;
			
			game.engine.addSystem( new RenderingSystem(_template3D.scene), SystemPriorities.render );
/*
			new EllipsoidCollider(GameSettings.SPECTATOR_RADIUS.x, GameSettings.SPECTATOR_RADIUS.y, GameSettings.SPECTATOR_RADIUS.z), 
						null ,
						*/
			spectatorPerson =new SimpleObjectController( 
						
						stage, 
						_template3D.camera, 
						GameSettings.SPECTATOR_SPEED,
						GameSettings.SPECTATOR_SPEED_SHIFT_MULT);
			
					//	game.gameStates.spectator.addInstance(spectatorPerson).withPriority(SystemPriorities.postRender);
		
	
			
			game.engine.addSystem( spectatorPerson, SystemPriorities.postRender ) ;
		
			
			var diffuse:BitmapTextureResource = new BitmapTextureResource(new SHEET_TEST().bitmapData);
			
			//diffuse.upload( _template3D.stage3D.context3D );
			var numSprites:int =1455;
			var numRegistersPerSprite:int = 3;
			var sprSet:SpriteSet = new SpriteSet(numSprites, false, sprite8Mat = new SpriteSheet8AnimMaterial(diffuse), diffuse.data.width, diffuse.data.height, 35, numRegistersPerSprite, SpriteGeometryUtil.createNormalizedSpriteGeometry(numSprites, 0, 1, 1,0,-1,numRegistersPerSprite) );
			sprite8Mat.alphaThreshold = 0.99;
			//sprSet.alwaysOnTop = true;
			//sprSet.setupAxisAlignment(0, 0, 1);
			_template3D.scene.addChild(sprSet);
			//sprite8Mat.flags = (TextureAtlasMaterial.FLAG_MIPNONE | TextureAtlasMaterial.FLAG_PIXEL_NEAREST);
			
			if (numSprites > 1) sprSet.randomisePositions(4, 0, 4000);
			
			if (sprite8Mat is SpriteSheet8AnimMaterial) {
				var spriteMat:SpriteSheet8AnimMaterial = sprite8Mat as SpriteSheet8AnimMaterial;
				spriteMat.vSpacing = 128 / 1024;
				var ang:Number = Math.PI / 8;
				
				spriteMat.firstSlope =  new Vector3D( Math.cos(ang), Math.sin(ang), 0).dotProduct( new Vector3D(1,0,0) );
				
				ang =   Math.PI / 3;
				
				spriteMat.secondSlope = new Vector3D( Math.cos(ang), Math.sin(ang), 0).dotProduct( new Vector3D(1, 0, 0) );
				
				//throw new Error( new Vector3D(spriteMat.firstSlope, spriteMat.secondSlope));
			
			}
			
			
			
			var data:Vector.<Number> = sprSet.spriteData;
			var facingDirection:Vector3D = new Vector3D(1,0);
			var len:int = data.length;
			for (var i:int = 0; i < len; i+=12) {
				var baseI:int = i + 4;
				data[baseI] = 0;
				data[baseI + 1] = .5;// 0.625;
				data[baseI + 2] =  .5;
				data[baseI + 3] = 128 / 1024;
				
				facingDirection.x = Math.random();
				facingDirection.y = Math.random();
				facingDirection.normalize();
				data[baseI+4] = facingDirection.x;
				data[baseI + 5] = facingDirection.y;
				data[baseI + 6] =  0;
				data[baseI + 7] = 0;
			}
			
			if (sprite8Mat is TextureAtlasMaterial) {
				(sprite8Mat as TextureAtlasMaterial).considerWHFlip = true;
			}
			
			var plane:Plane = new Plane(4000, 4000, 1, 1, false, false, null, new FillMaterial(0x111111));
		
			plane.z = -1;
			_template3D.scene.addChild(plane);
			
			SpawnerBundle.uploadResources(_template3D.scene.getResources(true));
			
			// Let's go
	
			ticker = new FrameTickProvider(stage);
			ticker.add(tick);
			ticker.start();
			
		//	setTimeout(disable, 5000)
			
		}
		
		private var _disabled:Boolean = false;
		private function disable():void 
		{
			_disabled = true;
			game.engine.removeSystem(spectatorPerson);
		}
		
		private function tick(time:Number):void 
		{
			if (sprite8Mat is SpriteSheet8AnimMaterial) {
				
			//	var dir:Vector3D = new Vector3D();
			//	_template3D.camera.calculateRay( new Vector3D(), dir, _template3D.camera.view.width * .5, _template3D.camera.view.height * .5);
			//	dir.z = 0;
			//	dir.normalize();
				
				var spriteMat:SpriteSheet8AnimMaterial = sprite8Mat as SpriteSheet8AnimMaterial;
				spriteMat.camForward.x = Math.cos(_template3D.camera.rotationZ);
				spriteMat.camForward.y = Math.sin(_template3D.camera.rotationZ);
				
				
				//spriteMat.camRight =  spriteMat.camForward.crossProduct(spriteMat.camR
				spriteMat.camRight.x = spriteMat.camForward.y;
				spriteMat.camRight.y = -spriteMat.camForward.x;
			}
			
			

			if (_disabled) {
				_template3D.camera.rotationZ += .01;
					_template3D.camera.x += spriteMat.camForward.x;
					_template3D.camera.y += spriteMat.camForward.y;
			}
			game.engine.update(time);
			_template3D.render();
		}
		
	}

}