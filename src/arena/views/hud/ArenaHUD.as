package arena.views.hud 
{
	import alternativa.engine3d.core.Camera3D;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.Renderer;
	import alternativa.engine3d.core.Transform3D;
	import alternativa.engine3d.materials.Material;
	import alternativa.engine3d.materials.TextureMaterial;
	import alternativa.engine3d.objects.Hud2D;
	import alternativa.engine3d.objects.SpriteMeshSetClone;
	import alternativa.engine3d.objects.SpriteMeshSetClonesContainer;
	import alternativa.engine3d.resources.BitmapTextureResource;
	import alternativa.engine3d.spriteset.materials.TextureAtlasMaterial;
	import assets.fonts.ConsoleFont;
	import flash.display.BitmapData;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;
	import saboteur.spawners.SaboteurHudAssets;
	import util.SpawnerBundle;
	import alternativa.engine3d.alternativa3d;
	use namespace alternativa3d;
	/**
	 * ...
	 * @author ...
	 */
	public class ArenaHUD  extends SpawnerBundle
	{
		
	
		// standard boilerplate
		public var hud:Hud2D;
		
		public var hudMeshSetBase:SpriteMeshSetClonesContainer;
		private var hudMeshMaterial:TextureAtlasMaterial
		private var hudTextureWidth:int;
		private var hudTextureHeight:int;
		
		private var stage:Stage;
	
		private var layoutTop:Object3D = new Object3D();
		private var layoutTopLeft:Object3D = new Object3D();
		private var layoutTopRight:Object3D = new Object3D();
		private var layoutBottom:Object3D = new Object3D();
		private var layoutBottomLeft:Object3D = new Object3D();
		private var layoutBottomRight:Object3D = new Object3D();
		private var layoutLeft:Object3D = new Object3D();
		private var layoutRight:Object3D = new Object3D();
		
		private var visHash:Object = { };
		
		private var fontConsole:ConsoleFont;
		
		// additional stuff
		private var arrowMarkers:Vector.<SpriteMeshSetClone> = new Vector.<SpriteMeshSetClone>();
		private var arrowZOffset:Number = 64;
		private var maxArrowScale:Number = 2;
		private var minArrowScale:Number = .75;
		
		
		public function ArenaHUD(stage:Stage) 
		{
			hud = new Hud2D();
			
		
			ASSETS = [SaboteurHudAssets];
			this.stage = stage;
			super();
		}
		
		
		private var _state:String = "";
		
		public function setState(string:String):void 
		{
			if (_state === string) return;
			
			var arr:Array = visHash[_state];
			if (arr) hideList(arr);
			
			
			_state = string;
			arr =  visHash[string];
			if (arr) showList(arr);
		}
		
		private function hide(hudItem:SpriteMeshSetClone):void {
			if (hudItem.index >= 0) hudMeshSetBase.removeClone(hudItem);
		}
		private function show(hudItem:SpriteMeshSetClone):void {
			if (hudItem.index < 0) hudMeshSetBase.addClone(hudItem);
		}
		
		private function hideList(arr:Array):void {
			var i:int = arr.length;
			while (--i > -1) {
				hide(arr[i]);
			}
		}
		
		private function showList(arr:Array):void {
			var i:int = arr.length;
			while (--i > -1) {
				show(arr[i]);
			}
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
		
		override protected function init():void {
		
			var hudBmpData:BitmapData = new SaboteurHudAssets.$_SHEET().bitmapData;
			hudTextureWidth = hudBmpData.width;
			hudTextureHeight = hudBmpData.height;
			var hudResource:BitmapTextureResource = new BitmapTextureResource( hudBmpData );
			hudResource.upload(context3D);
			
			hudMeshMaterial = new TextureAtlasMaterial(hudResource);// null, 1);
			hudMeshMaterial.alphaThreshold = .8;
			hudMeshMaterial.flags = TextureAtlasMaterial.FLAG_MIPNONE;  // | TextureAtlasMaterial.FLAG_PIXEL_NEAREST
			
			hudMeshSetBase =  new SpriteMeshSetClonesContainer(hudMeshMaterial, 0 );
			hudMeshSetBase.objectRenderPriority = Renderer.NEXT_LAYER;
			hudMeshSetBase.name = "hud";
			hudMeshSetBase.geometry.upload(context3D);
			
			hud.addChild(hudMeshSetBase);
				
			setupHUD();
			
			 super.init();
			 
			 stage.addEventListener(Event.RESIZE, onStageResize);
			 onStageResize();
		}
		
		
		private function registerVisState(state:String, instance:SpriteMeshSetClone):void {
			var arr:Array = visHash[state];
			if (arr == null) {
				arr = [];
				visHash[state] = arr;
			}
			
			arr.push(instance);
		}
		
		
		
		private function setupHUD():void 
		{
			var spr:SpriteMeshSetClone;
			
			// crosshair
			spr = addSprite(281, 259, 21, 20);
			registerVisState("thirdPerson",spr);
			
			
			
			// movement meter
			_movementBar = spr = addSprite( 392, 19, 42, 20, 0, -20, layoutBottom);
			spr.root._scaleX = MOVEMENT_BAR_SCALE;
			spr.root._scaleY = 12;
		
			// movement meter skin
			 spr = addSprite(0, 0, 32, 256, 0, -20, layoutBottom);
			spr.root._scaleX *= .75;
			spr.root._scaleY *= .75;
			spr.root._rotationZ = Math.PI * .5;
			
			// msg above movement meter
			
			
			// target info + options from  top LEFT
			
			
			// Message meter on top
			
			
			// stance key cues on bottom left
			
			
			// your stats on bottom right

		}
		

		private var camera:Camera3D;
		public function setCamera(camera:Camera3D):void {
			this.camera = camera;
			 onStageResize();
		}
		
		
		
		private var vec3:Vector3D = new Vector3D();
		private var projectedPoint:Vector3D = new Vector3D();
	//	/*
		
		private var visibleArrowMarkers:int = 0;
		private var visibleArrowMarkerPoints:Vector.<Number> = new Vector.<Number>();
		private var visibleArrowTargets:Vector.<Object3D>;
		private var focalLength:Number;
		private var viewSizeX:Number;
		private var viewSizeY:Number;
		private var _movementBar:SpriteMeshSetClone;
		static private const MOVEMENT_BAR_SCALE:Number = 180;
		
		public function showArrowMarkers(targets:Vector.<Object3D>):void {
			var len:int = targets.length;
			visibleArrowTargets = targets;
			visibleArrowMarkers = len;

			var hx:Number = camera.view.width * .5;
			var hy:Number = camera.view.height * .5;
			var t:Transform3D = camera.globalToLocalTransform;
			
			for (var i:int = 0; i < len; i++) {
				var arrowMarker:SpriteMeshSetClone;
				if (i >= arrowMarkers.length) {
					arrowMarkers[i] = addSprite( 2, 256, 16, 16, 0, -16) ;
				}
				arrowMarker  = arrowMarkers[i];
			
				
				if (arrowMarker.index < 0) hudMeshSetBase.addClone(arrowMarker);
			}
			
			i = len;
			len = arrowMarkers.length;
			while ( i  < len) {
				arrowMarker = arrowMarkers[i];
				if (arrowMarker.index >= 0) hudMeshSetBase.removeClone( arrowMarker );
				i++;
			}
			
			
		}
	//	*/
	
	
		public function clearArrows():void {
			for (var i:int = 0; i < visibleArrowMarkers; i++) {
					hudMeshSetBase.removeClone( arrowMarkers[i] );
		
					
				}
			 visibleArrowMarkers = 0;
			
		}
		
	
		public function update():void {
			var len:int;
		
			//if ( camera.transformChanged ) {
				
				var t:Transform3D = camera.globalToLocalTransform;
				len = visibleArrowMarkers;
				
				for (var i:int = 0; i < len; i++) {
					var arrowMarker:SpriteMeshSetClone  = arrowMarkers[i];
					var targ:Object3D = visibleArrowTargets[i];
					vec3.x = targ._x;
					vec3.y = targ._y;
					vec3.z = targ._z +  arrowZOffset;
					projectedPoint.x = t.a * vec3.x + t.b * vec3.y + t.c * vec3.z + t.d;
					projectedPoint.y = t.e * vec3.x + t.f * vec3.y + t.g * vec3.z + t.h;
					projectedPoint.z = t.i * vec3.x + t.j * vec3.y + t.k * vec3.z + t.l;
					var scaleRatio:Number = focalLength / projectedPoint.z;
					projectedPoint.x =projectedPoint.x* scaleRatio;
					projectedPoint.y =projectedPoint.y *scaleRatio;
					arrowMarker.root._x =  projectedPoint.x;
					arrowMarker.root._y =  projectedPoint.y;
					
					scaleRatio = scaleRatio < minArrowScale ? minArrowScale : scaleRatio > maxArrowScale ? maxArrowScale : scaleRatio;
					arrowMarker.root._scaleX = scaleRatio * 16;
					arrowMarker.root._scaleY =  scaleRatio * 16;
					arrowMarker.root._y -= 8 *scaleRatio;
					
					arrowMarker.root.transformChanged = true;
					
				}
			//}	
		}
		
		public function updateFuel(ratio:Number):void 
		{
			ratio *= MOVEMENT_BAR_SCALE;
			if (_movementBar.root._scaleX !=ratio ) {
				_movementBar.root._scaleX = ratio;
				_movementBar.root._x = -(MOVEMENT_BAR_SCALE -ratio)*.5;
				_movementBar.root.transformChanged = true;
			}
		}
		

		
		
		private function addSprite(px:Number, py:Number, width:Number, height:Number, x:Number = 0, y:Number = 0, parenter:Object3D=null):SpriteMeshSetClone {
			var spr:SpriteMeshSetClone = hudMeshSetBase.getNewSprite();

			
			spr.u = px / hudTextureWidth;
			spr.v = py / hudTextureHeight;
			spr.uw = width / hudTextureWidth;
			spr.vw =  height / hudTextureHeight;
			
			
			spr.root._x = x;
			spr.root._y = y;
			spr.root._scaleX = width;
			spr.root._scaleY = height;
			

			spr.root._rotationX = Math.PI;
			
			spr.root._parent = parenter;
			
			hudMeshSetBase.addClone(spr);
			
			return spr;
		}
		
	}

}