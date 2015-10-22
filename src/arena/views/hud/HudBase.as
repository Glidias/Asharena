package arena.views.hud 
{
	import alternativa.a3d.systems.text.FontSettings;
	import alternativa.engine3d.core.Camera3D;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.Resource;
	import alternativa.engine3d.materials.Material;
	import alternativa.engine3d.objects.Hud2D;
	import alternativa.engine3d.objects.SpriteMeshSetClone;
	import alternativa.engine3d.objects.SpriteMeshSetClonesContainer;
	import alternativa.engine3d.resources.BitmapTextureResource;
	import alternativa.engine3d.resources.Geometry;
	import alternativa.engine3d.spriteset.materials.MaskColorAtlasMaterial;
	import alternativa.engine3d.spriteset.materials.TextureAtlasMaterial;
	import alternativa.engine3d.spriteset.SpriteSet;
	import assets.fonts.ConsoleFont;
	import assets.fonts.Fontsheet;
	import flash.display.BitmapData;
	import flash.display.Stage;
	import flash.events.Event;
	import util.SpawnerBundle;
	
	import alternativa.engine3d.alternativa3d;
	use namespace alternativa3d;
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class HudBase  extends SpawnerBundle
	{
		public var hud:Hud2D;
		protected var stage:Stage;
		
		protected var layoutTop:Object3D = new Object3D();
		protected var layoutTopLeft:Object3D = new Object3D();
		protected var layoutTopRight:Object3D = new Object3D();
		protected var layoutBottom:Object3D = new Object3D();
		protected var layoutBottomLeft:Object3D = new Object3D();
		protected var layoutBottomRight:Object3D = new Object3D();
		protected var layoutLeft:Object3D = new Object3D();
		protected var layoutRight:Object3D = new Object3D();
		
		protected var fontConsole:Fontsheet;
		protected var _textGeometry:Geometry;
		
		
		
		private var focalLength:Number;
		private var viewSizeX:Number;
		private var viewSizeY:Number;
		private var camera:Camera3D;
		public function setCamera(camera:Camera3D):void {
			this.camera = camera;
			 onStageResize();
		}
		
		public function HudBase(stage:Stage) 
		{
			hud = new Hud2D();
			this.stage = stage;
			super();
		}
		
		/*
		public function manualInit():void {
			ASSETS = null;
			init();
		}
		*/
		
		override protected function init():void {
		
			
			// layout
			hud.addChild(layoutTop);
			hud.addChild(layoutBottom);
			hud.addChild(layoutLeft);
			hud.addChild(layoutRight);
			hud.addChild(layoutBottomRight);
			hud.addChild(layoutBottomLeft);
			hud.addChild(layoutTopRight);
			hud.addChild(layoutTopLeft);
			
			
			// setup basic fonts
			fontConsole = new ConsoleFont();
			

			 super.init();
			 
			 stage.addEventListener(Event.RESIZE, onStageResize);
			 onStageResize();
		}
		
		private function onStageResize(e:Event=null):void 
		{
			if (camera != null) {
				viewSizeX = camera.view._width * 0.5;
				viewSizeY = camera.view._height * 0.5;
				focalLength = Math.sqrt(viewSizeX * viewSizeX + viewSizeY * viewSizeY) / Math.tan(camera.fov * 0.5);
			}
			
			var sh:Number = camera != null ? camera.view.height : stage.stageHeight;
			var sw:Number = camera != null ? camera.view.width :  stage.stageWidth;
			var halfWidth:Number = sw * .5;
			var halfHeight:Number = sh * .5;
			
			layoutTop._y = -halfHeight;
			layoutTop.transformChanged = true;
			
			layoutBottom._y =halfHeight;
			layoutBottom.transformChanged = true;
			
			layoutLeft._x =-halfWidth;
			layoutLeft.transformChanged = true;
			
			layoutRight._x =halfWidth;
			layoutRight.transformChanged = true;
			
			
			layoutTopLeft._x = -halfWidth;
			layoutTopLeft._y = -halfHeight;
			layoutTopLeft.transformChanged = true;
			
			layoutTopRight._x = halfWidth;
			layoutTopRight._y = -halfHeight;
			layoutTopRight.transformChanged = true;
			
			layoutBottomLeft._x = -halfWidth;
			layoutBottomLeft._y = halfHeight;
			layoutBottomLeft.transformChanged = true;
			
			layoutBottomRight._x = halfWidth;
			layoutBottomRight._y = halfHeight;
			layoutBottomRight.transformChanged = true;

		}
		
		protected function getNewFontMaterial(color:uint):MaskColorAtlasMaterial {
			var mat:MaskColorAtlasMaterial =  new MaskColorAtlasMaterial(fontConsole.bmpResource);
			mat.transparentPass = false;
			mat.color = color;
			mat.alphaThreshold = .8;
			mat.flags = (MaskColorAtlasMaterial.FLAG_MIPNONE | MaskColorAtlasMaterial.FLAG_PIXEL_NEAREST);
			return mat;
		}
		protected function getNewDefaultFontMaterial(color:uint):TextureAtlasMaterial {
			var mat:TextureAtlasMaterial =  new TextureAtlasMaterial(fontConsole.bmpResource);
			//mat.transparentPass = false;
			mat.alphaThreshold =.8;
			mat.flags = (TextureAtlasMaterial.FLAG_MIPNONE | TextureAtlasMaterial.FLAG_PIXEL_NEAREST);
			return mat;
		}
		
		protected function getNewTextSpriteSet(estimatedMaxChars:int, material:Material, geom:Geometry):SpriteSet {
			var spr:SpriteSet = new SpriteSet(0, true, material, fontConsole.bmpResource.data.width, fontConsole.bmpResource.data.height, estimatedMaxChars, 2 );
			
			return spr;
		}
		
		protected function getNewFontSettings(fontSheet:Fontsheet, fontMat:Material, estimatedAmt:int):FontSettings {
			return new FontSettings( fontConsole, fontMat, getNewTextSpriteSet(estimatedAmt, fontMat, _textGeometry ));
		}
		
		protected function getSprite(meshSet:SpriteMeshSetClonesContainer, px:Number, py:Number, width:Number, height:Number, x:Number = 0, y:Number = 0, parenter:Object3D=null):SpriteMeshSetClone {
			
			var spr:SpriteMeshSetClone = meshSet.getNewSprite();

			var resources:Vector.<Resource> =  meshSet.material.getResources(BitmapTextureResource);
			var bitmapRes:BitmapTextureResource =  resources.length ? (resources[0] as BitmapTextureResource) : null;
			if (bitmapRes == null) throw new Error("Could not find bitmap resource!");
			var data:BitmapData = bitmapRes.data;
			if (data == null)    throw new Error("Could not find bitmap resource bitmapData!");
			spr.u = px / data.width;
			spr.v = py / data.height;
			spr.uw = width / data.width;
			spr.vw =  height / data.height;
			
			
			spr.root._x = x;
			spr.root._y = y;
			spr.root._scaleX = width;
			spr.root._scaleY = height;
			

			spr.root._rotationX = Math.PI;
			
			spr.root._parent = parenter;
			
			return spr;
		}
		
		
	}

}