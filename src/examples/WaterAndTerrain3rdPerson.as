package examples
{
	import alternativa.engine3d.controller.OrbitCameraController;
	import alternativa.engine3d.controller.OrbitCameraMan;
	import alternativa.engine3d.controllers.SimpleObjectController;
	import alternativa.engine3d.core.Camera3D;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.RayIntersectionData;
	import alternativa.engine3d.core.Renderer;
	import alternativa.engine3d.core.Resource;
	import alternativa.engine3d.core.VertexAttributes;
	import alternativa.engine3d.core.View;
	import alternativa.engine3d.lights.AmbientLight;
	import alternativa.engine3d.lights.DirectionalLight;
	import alternativa.engine3d.loaders.ParserCollada;
	import alternativa.engine3d.materials.FillMaterial;
	import alternativa.engine3d.materials.Material;
	import alternativa.engine3d.materials.NormalMapSpace;
	import alternativa.engine3d.materials.StandardTerrainMaterial2;
	import alternativa.engine3d.materials.TextureZClipMaterial;
	import alternativa.engine3d.materials.TextureMaterial;
	import alternativa.engine3d.materials.VertexLightZClipMaterial;
	import alternativa.engine3d.objects.Mesh;
	import alternativa.engine3d.objects.SkyBox;
	import alternativa.engine3d.primitives.Box;
	import alternativa.engine3d.primitives.Plane;
	import alternativa.engine3d.resources.BitmapTextureResource;
	import alternterrain.core.QuadTreePage;
	import alternterrain.objects.TerrainLOD;
	import alternterrain.resources.LoadAliases;
	import com.bit101.components.CheckBox;
	import components.Pos;
	import components.Rot;
	import eu.nekobit.alternativa3d.materials.WaterMaterial;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.events.KeyboardEvent;
	import flash.geom.Vector3D;
	import flash.ui.Keyboard;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	import systems.rendering.IRenderable;
	
	import flash.display.Sprite;
	import flash.display.Stage3D;
	import flash.display.StageAlign;
	import flash.display.StageDisplayState;
	import flash.display.StageScaleMode;
	import flash.display3D.Context3DRenderMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import alternativa.engine3d.alternativa3d;
	use namespace alternativa3d;
	
	/**
	 * Integrating LOD terrain with water.
	 * 
	 * @author Varnius  http://nekobit.puslapiai.lt/water-material-for-alternativa3d/
	 * @author Glidias	LOD terrain on water
	 */
	[SWF(width="1100", height="600", frameRate="60")]
	public class WaterAndTerrain3rdPerson extends Sprite implements IRenderable
	{
		public var scene:Object3D = new Object3D();
		public var stage3D:Stage3D;
		
		public var camera:Camera3D;

		
		public var raycastImpl:RaycastImpl;
		
		// Embeds
		
		[Embed(source="assets/water/sand.png")]
		static private const Ground:Class;
		
		[Embed(source="assets/water/plated-metal.png")]
		static private const PlatedMetal:Class;
		
		//[Embed("assets/water/teapot.DAE", mimeType="application/octet-stream")]
		//static private const Teapot:Class;		
		
		[Embed(source="assets/water/normal1.png")]
		static private const Normal1:Class;
		
		// Skybox
		
		private var sb:SkyBox;
		[Embed(source="assets/water/skybox/top.png")]
		static private const SBTop:Class;
		[Embed(source="assets/water/skybox/bottom.png")]
		static private const SBBottom:Class;
		[Embed(source="assets/water/skybox/front.png")]
		static private const SBFront:Class;
		[Embed(source="assets/water/skybox/back.png")]
		static private const SBBack:Class;
		[Embed(source="assets/water/skybox/left.png")]
		static private const SBLeft:Class;
		[Embed(source="assets/water/skybox/right.png")]
		static private const SBRight:Class;
		
		static public const START_LOD:Number = 1;
		
		private var _normalMapData:BitmapData;
		private var settings:TemplateSettings = new TemplateSettings();
		
		
		/* Map scale distances and land area
		512  x1- 6 km2 ~ 5km2
		1024 x2- 24 km2 ~  19km2
		2048 x4- 100 km2 ~ 80km2
		4016 x8- 400km2  ~ 320km2
		*/
		
		[Embed(source="assets/myterrainx2.tre", mimeType="application/octet-stream")]
		private var TERRAIN_DATA:Class;
		private static const TERRAIN_HEIGHT_SCALE:Number =2;
		private static const MAP_SCALE:Number = 1;
		
		private var waterLevel:Number =   (-64000 +84); // * (MAP_SCALE > 1 ? MAP_SCALE : 1) 
		
		[Embed(source="assets/myterrain_normal.jpg")]
		private var NORMAL_MAP:Class;
		
		[Embed(source="assets/edgeblend_mist.png")]
		private var EDGE:Class;
		
		private var crosshair:DisplayObject;
		
		
		
		
		public function WaterAndTerrain3rdPerson()
		{
			
			addEventListener(Event.ADDED_TO_STAGE, addedInit);

		}

		
		public function inject(cameraTarget:Object3D, followTarget:Object3D, playerPos:Pos, playerRot:Rot, skinRenderable:Object3D, teapotMaterial:VertexLightZClipMaterial=null):void {
			this.playerPos = playerPos;
			this.teapotMaterial = teapotMaterial;
			this.followTarget = followTarget;
			this.cameraTarget = cameraTarget;
			this.skinRenderable = skinRenderable;
			
			
			followTarget.x = camera.x;
			followTarget.y = camera.y;
			followTarget.z = camera.z;
			playerPos.x = camera.x;
			playerPos.y = camera.y;
			playerPos.z = camera.z;
		

			 // -- Player-Specific stuff for Client	 
			 // TODO: look at object could be higher!
            thirdPerson = new OrbitCameraMan(camera, followTarget, stage, raycastImpl, followTarget, playerRot, true); 
			thirdPerson.offsetZ = 44;
			
            //thirdPerson.controller.easingSeparator  = 12;
            thirdPerson.preferedZoom = 160 ;
            thirdPerson.controller.minDistance = 30;
			thirdPerson.preferedMinDistance = 60;
			thirdPerson.fadeDistance = thirdPerson.preferedMinDistance-1;
			thirdPerson.minFadeAlpha = 0;
            thirdPerson.controller.maxDistance =256*32 * MAP_SCALE;
            //thirdPerson.controller.minAngleLatitude = 5;  // LEFT HANDED SYSTEM with thumb being latitude
            thirdPerson.controller.minAngleLatitude = -85;  // pitch up
            thirdPerson.controller.maxAngleLatidude = 75;  // pitch down
            thirdPerson.followAzimuth = true;
		
			if (teapotMaterial != null) thirdPerson.alphaSetter = teapotMaterial;
            thirdPerson.useFadeDistance = true;
            thirdPerson.maxFadeAlpha = 1;
			
			//stage.addEventListener(Event.ENTER_FRAME, think);
		}
		
		private function addedInit(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, addedInit);
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			var loadAliases:LoadAliases = new LoadAliases();
			settings.cameraSpeed = 2100;
			settings.cameraSpeedMultiplier = 14;
			settings.viewBackgroundColor = 0x86a1b8;

			
			_normalMapData = new NORMAL_MAP().bitmapData;

			processDataAsLoadedPage( new TERRAIN_DATA() );
			
			stage3D = stage.stage3Ds[0];
			stage3D.addEventListener(Event.CONTEXT3D_CREATE, onContext3DCreated);
			stage3D.requestContext3D(Context3DRenderMode.AUTO);
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			
			crosshair = new CrossHair();
			crosshair.x = stage.stageWidth * .5;
			crosshair.y = stage.stageHeight * .5;
			addEventListener(Event.RESIZE, onStageResize);
			
			tileTrace = new Box(16, 16, 3344, 1, 1, 1, false, new FillMaterial(0xFFFF00, .4) );
			

		}
		
		private function onKeyUp(e:KeyboardEvent):void 
		{
			if (e.keyCode === Keyboard.R) {
				_orbitKeyDown = false;
			}
		}
		
		private function onStageResize(e:Event):void 
		{
			crosshair.x = stage.stageWidth * .5;
			crosshair.y = stage.stageHeight * .5;
		}
		
		private function onKeyDown(e:KeyboardEvent):void 
		{
			var key:uint = e.keyCode;
			if (key === Keyboard.TAB) {
				terrainLOD.debug = !terrainLOD.debug;
			}
			else if (key === Keyboard.R) {
				_orbitKeyDown = true;
			}
			else if (key === Keyboard.PAGE_UP) {
				thirdPerson.mouseWheelHandler(null, 5);
				
			}
			else if (key === Keyboard.PAGE_DOWN) {
				thirdPerson.mouseWheelHandler(null, -5);
				
			}
			
		}
		
		
		
			private function processDataAsLoadedPage(data:ByteArray):void 
	{
		data.uncompress();
		
		_loadedPage = new QuadTreePage();
		_loadedPage.readExternal(data);
	
	
	}
	
		public var reflectClipOffset:Number = 2;
		
		private static const MAX_POSSIBLE_HEIGHT:Number = Math.sqrt( 64 * 255 + 256) * TERRAIN_HEIGHT_SCALE;
		private static const FAR_CLIPPING:Number = Math.sqrt(MAX_POSSIBLE_HEIGHT*MAX_POSSIBLE_HEIGHT + 2* 333901639.34426229508196721311475 * MAX_POSSIBLE_HEIGHT) * 1  * 3;
		
		private function onContext3DCreated(e:Event):void			
		{
			// Container
			
			// Camera
			camera = new Camera3D(1, FAR_CLIPPING);  //1024*256
			camera.x = 0*256;
			camera.y = 0*256;
			camera.z = waterLevel + 66400;
			camera.rotationX = -1.595;
			camera.rotationZ = -0.6816;
			
			
			camera.view = new View(stage.stageWidth, stage.stageHeight);
			camera.view.antiAlias = 4;
			camera.diagramAlign = "left";
			camera.diagramHorizontalMargin = 5;
			camera.diagramVerticalMargin = 5;
			addChild(camera.view);
			addChild(camera.diagram);
			camera.view.hideLogo();			
			scene.addChild(camera);
			//addChild(crosshair);
			
			uploadResources( tileTrace.getResources() );
			
		
			
			// Skybox
			// create skybox textures
			var topres:BitmapTextureResource = new BitmapTextureResource(new SBTop().bitmapData);			
			var top:TextureMaterial = new TextureMaterial(topres);
			var bottomres:BitmapTextureResource = new BitmapTextureResource(new SBBottom().bitmapData);
			var bottom:TextureMaterial = new TextureMaterial(bottomres);
			var frontres:BitmapTextureResource = new BitmapTextureResource(new SBFront().bitmapData);
			var front:TextureMaterial = new TextureMaterial(frontres);
			var backres:BitmapTextureResource = new BitmapTextureResource(new SBBack().bitmapData);
			var back:TextureMaterial = new TextureMaterial(backres);
			var leftres:BitmapTextureResource = new BitmapTextureResource(new SBLeft().bitmapData);
			var left:TextureMaterial = new TextureMaterial(leftres);
			var rightres:BitmapTextureResource = new BitmapTextureResource(new SBRight().bitmapData);
			var right:TextureMaterial = new TextureMaterial(rightres);			
			topres.upload(stage3D.context3D);
			bottomres.upload(stage3D.context3D);
			leftres.upload(stage3D.context3D);
			rightres.upload(stage3D.context3D);
			frontres.upload(stage3D.context3D);
			backres.upload(stage3D.context3D);		
			camera.nearClipping = 1;
			camera.farClipping = FAR_CLIPPING;
			var fogMat:FillMaterial = new FillMaterial(settings.viewBackgroundColor);
			//sb = new SkyBox(camera.farClipping * 10, fogMat, fogMat, fogMat, fogMat, fogMat, fogMat, 0.005);  //left,right,front,back,bottom,top
			sb = new SkyBox(8192*256*2, left,right,front,back,bottom,top,0.005);
			sb.geometry.upload(stage3D.context3D);
			scene.addChild(sb);
			
			var groundTextureResource:BitmapTextureResource = new BitmapTextureResource(new Ground().bitmapData);
			var ground:TextureMaterial = new TextureMaterial(groundTextureResource);
			var uvScaler:Number = 32;
	
			
			// Reflective plane
			var normalRes:BitmapTextureResource = new BitmapTextureResource(new Normal1().bitmapData);
			waterMaterial = new WaterMaterial(normalRes, normalRes);
		var scaler:Number = 4*MAP_SCALE;
			waterMaterial.setFollowCamera(  waterMaterial.getUVOffsetScaling(2048 * 256*scaler, uvScaler * 32) );
			plane = new Plane(2048 * 256*scaler, 2048 * 256*scaler, 64, 64, false, false, null, waterMaterial);
			var uvs:Vector.<Number>= plane.geometry.getAttributeValues(VertexAttributes.TEXCOORDS[0]);
			for (var i:int = 0; i < uvs.length; i++) {
				uvs[i] *= uvScaler * 32;
			}
			 plane.geometry.setAttributeValues(VertexAttributes.TEXCOORDS[0],uvs);	
			
			
			plane.z = waterLevel;
			uploadResources(plane.getResources());
			scene.addChild(plane);			
			waterMaterial.forceRenderPriority = Renderer.SKY + 1;
			
			// Underwater plane with ground texture
			/*
			underwaterPlane = new Plane(80000, 80000, 1, 1, false, false, null, ground);
			underwaterPlane.z = -1000;
			underwaterPlane.geometry.setAttributeValues(VertexAttributes.TEXCOORDS[0], uvs);
			uploadResources(underwaterPlane.getResources());
			scene.addChild(underwaterPlane);
			hideFromReflection.push(underwaterPlane);
			*/
			
			  //Lightを追加
           var  ambientLight:AmbientLight = new AmbientLight(0xFFFFFF);
            ambientLight.intensity = 0.4;
            scene.addChild(ambientLight);
            
            //Lightを追加
           var  directionalLight:DirectionalLight = new DirectionalLight(0xFFFFFF);
            //手前右上から中央へ向けた指向性light
            directionalLight.x = 100;
            directionalLight.y = -100;
            directionalLight.z = 100;
            directionalLight.lookAt(0, 0, 0);
			directionalLight.intensity = .7;
            scene.addChild(directionalLight);
			
			
			// TerrainLOD
			terrainLOD = new TerrainLOD();
			
			terrainLOD.scaleX = MAP_SCALE;
			terrainLOD.scaleY = MAP_SCALE;
		//terrainLOD.scaleZ =  MAP_SCALE;
			terrainLOD.setUpdateRadius(256);
			terrainLOD.setupUpdateCullingMode(TerrainLOD.CULL_NONE);
			//terrainLOD.debug = true;
			terrainLOD.detail = START_LOD;
			terrainLOD.waterLevel = waterLevel ;
			raycastImpl = new RaycastImpl(terrainLOD);
			
			standardMaterial = new StandardTerrainMaterial2(groundTextureResource , new BitmapTextureResource( _normalMapData), null, null  );
			standardMaterial.uvMultiplier2 =MAP_SCALE;
			//throw new Error([standardMaterial.opaquePass, standardMaterial.alphaThreshold, standardMaterial.transparentPass]);
			//standardMaterial.transparentPass = false;
			standardMaterial.normalMapSpace = NormalMapSpace.OBJECT;
			standardMaterial.specularPower = 0;
			standardMaterial.glossiness = 0;
			standardMaterial.mistMap = new BitmapTextureResource(new EDGE().bitmapData);
			StandardTerrainMaterial2.fogMode = 1;
			StandardTerrainMaterial2.fogFar =  FAR_CLIPPING;
			StandardTerrainMaterial2.fogNear = 256 * 32;
			StandardTerrainMaterial2.fogColor = settings.viewBackgroundColor;
			standardMaterial.waterLevel = waterLevel;
			standardMaterial.waterMode = 1;
			//standardMaterial.tileSize = 512;
			standardMaterial.pageSize = _loadedPage.heightMap.RowWidth - 1;
			//_loadedPage.xorg += 255 * 256  - 256;
		//	_loadedPage.zorg += 255*256  - 256;
			_loadedPage.heightMap.XOrigin = _loadedPage.xorg;
			_loadedPage.heightMap.ZOrigin = _loadedPage.zorg;
		//	_loadedPage.heightMap.Scale += 1;
		//	_loadedPage.Level+=1;


			terrainLOD.loadSinglePage(stage3D.context3D, _loadedPage, standardMaterial, 0, -1, 256);  //new FillMaterial(0xFF0000, 1)
			
			
			var hWidth:Number = (terrainLOD.boundBox.maxX-terrainLOD.boundBox.minX) * .5 * terrainLOD.scaleX;
	//terrainLOD.x -= terrainLOD.boundBox.minX;
	//terrainLOD.x -= terrainLOD.boundBox.minX;
	
			terrainLOD.x -= hWidth;
			terrainLOD.y += hWidth;
		//throw new Error([(camera.x - terrainLOD.x) / terrainLOD.scaleX, -(camera.y - terrainLOD.y) / terrainLOD.scaleX]);
				camera.z = _loadedPage.heightMap.Sample((camera.x - terrainLOD.x)/terrainLOD.scaleX, -(camera.y - terrainLOD.y)/terrainLOD.scaleX) ;
			camera.z *=  terrainLOD.scaleZ;
				if (camera.z < waterLevel) camera.z = waterLevel;
			camera.z += 1600;	
	
		
		uploadResources(terrainLOD.getResources());
			scene.addChild(terrainLOD);
			//	hideFromReflection.push(terrainLOD);
			

		
		
			
			
			// Teapot	 (there's a problem with including teapot in the scene). DOesn't work with other objects!
			////*

		//	teapot.x = 1500;
		//	teapot.z = -500;
	
			

			//*/
		//	scene.removeChild(terrainLOD);
			// Uncomment and see how this affects rendered reflection
			///*
			 obstacle = OBSTACLE = new Box(400,400,400,1,1,1,false, obstacleMat = new FillMaterial(0xFF000F, .5));
			obstacle.x = terrainLOD.x + terrainLOD.boundBox.minX; 
			obstacle.y = terrainLOD.y + terrainLOD.boundBox.minY;
			obstacle.z = waterLevel;
			
			uploadResources(obstacle.getResources());		
			scene.addChild(obstacle);
			
			//*/
			
	
		
			
			// Render loop
			//stage.addEventListener(Event.ENTER_FRAME, think);
			stage.addEventListener(Event.RESIZE, onResize);
			
			
			dispatchEvent( new Event(Event.COMPLETE) );

			
		}
		
		private function onResize(e:Event):void
		{
			camera.view.width = stage.stageWidth;
			camera.view.height = stage.stageHeight;
			
			
		}
		
		private var waterMaterial:WaterMaterial;
		private var plane:Plane;
		public function getWaterPlane():Mesh {
			return plane;
		}

		private var underwaterPlane:Plane;

		
		// todo: some custom culling method to make up for absence of clipping planes?
		private var hideFromReflection:Vector.<Object3D> = new Vector.<Object3D>();
		
		public var _baseWaterLevelOscillate:Number =  10;
		public var _baseWaterLevel:Number = waterLevel;// -20000 + _baseWaterLevelOscillate;
		public var _waterSpeed:Number =  2.0 * .001;
		public var clipReflection:Boolean = true;
		public var teapotMaterial:VertexLightZClipMaterial;
		private var _lastTime:int = -1;
		private var _waterOscValue:Number = 0;
	
		public function render():void
		{
			var curTime:int = getTimer();
			
			//optionsWindow.title = String(new Vector3D(camera.x, camera.y, camera.z));
			
			camera.startTimer();	
			
			var follower:Object3D = thirdPerson.controller._followTarget;

			
			thirdPerson.followAzimuth = _orbitKeyDown ? false : true;
			 thirdPerson.update();
			 
			// plane.rotationZ += .005*.04;
			//teapot.rotationZ -= 0.02;
			
			//teapotContainer.rotationZ = camera.rotationZ + .5* Math.PI;
				//teapotContainer.x = camera.x;
		//	teapotContainer.z = camera.z;
		//	teapotContainer.y = camera.y;
			
			
		//	plane.rotationZ += .003;
			
				if (_lastTime < 0) _lastTime = curTime;
			var timeElapsed:int = curTime - _lastTime;
	
			_waterOscValue += timeElapsed * _waterSpeed;
			
			 waterLevel = _baseWaterLevel + Math.sin(_waterOscValue) * (_waterSpeed != 0 ? _baseWaterLevelOscillate : 0);
			 
		
			
		
			if (teapotMaterial != null) {
				var waterLocalPos:Vector3D = skinRenderable.globalToLocal(new Vector3D(0, 0, waterLevel));
				teapotMaterial.waterLevel =  waterLocalPos.y-reflectClipOffset; 
				
			}
			plane.z = waterLevel;
			
			standardMaterial.waterLevel = waterLevel - reflectClipOffset;
			terrainLOD.waterLevel = waterLevel - reflectClipOffset;
			
	
			//standardMaterial.waterLevel = terrainLOD.waterLevel = waterLevel - perturbReflectiveBy.value * 200;
			waterMaterial.update(stage3D, camera, plane, hideFromReflection);
			camera.stopTimer();
			
			// Update teapot rotation		
			///*
		//	teapotContainer.rotationZ = 0.5;
	
			//*/
			
			if (teapotMaterial != null) teapotMaterial.waterLevel =  waterLocalPos.y; 
			standardMaterial.waterLevel  = waterLevel;
			terrainLOD.waterLevel = waterLevel;
			

			camera.render(stage3D);
			
				_lastTime = curTime;
		
		}
		

		

		private function uploadResources(resources:Vector.<Resource>):void
		{
			for each(var res:Resource in resources)
			{
				if(!res.isUploaded)
				{
					res.upload(stage3D.context3D);
				}				
			}
		}
		

		

	
		private var _loadedPage:QuadTreePage;
		private var standardMaterial:StandardTerrainMaterial2;
		public var terrainLOD:TerrainLOD;
		public var obstacle:Box;
		public static var OBSTACLE:Box;
		private var obstacleMat:FillMaterial;
		private var tileTrace:Box;
		private var _traceTiles:Vector.<Object3D> = new Vector.<Object3D>();
		private var thirdPerson:OrbitCameraMan;
		private var cameraTarget:Object3D;
		private var followTarget:Object3D;
		private var playerPos:Pos;
		private var skinRenderable:Object3D;
		private var _orbitKeyDown:Boolean;


		
	
		
		private function stopPropagation(e:MouseEvent):void 
		{
			e.stopPropagation();
		}
		

	}
}
import alternativa.engine3d.core.Object3D;
import alternativa.engine3d.core.RayIntersectionData;
import alternterrain.objects.TerrainLOD;
import flash.display.Sprite;
import flash.filters.DropShadowFilter;
import flash.geom.Vector3D;

class TemplateSettings {
	public var cameraSpeedMultiplier:Number = 3;
	public var cameraSpeed:Number = 100;
	public var cameraSensitivity:Number = 1;
	public var viewBackgroundColor:uint;
	
}

class CrossHair extends Sprite {
    public function CrossHair() {
        graphics.lineStyle(1, 0xDDEE44, 1);
        graphics.moveTo(0, -2);
        graphics.lineTo(0, -6);
        
        graphics.moveTo(0, 2);
        graphics.lineTo(0, 6);
        
        graphics.moveTo(2, 0);
        graphics.lineTo(6, 0);
        
        graphics.moveTo(-2, 0);
        graphics.lineTo( -6, 0);
        
        filters = [new DropShadowFilter(1,45,0,1,0,0,1,1,false,false, false)];
    }
}

import alternativa.engine3d.alternativa3d;
use namespace alternativa3d;
	
class RaycastImpl extends Object3D {
	

	private var childOrigin:Vector3D = new Vector3D();
	private var childDirection:Vector3D = new Vector3D();
	private var terrainLOD:TerrainLOD;
	
	public var ddaMaxRange:Number = 8192;
	
	public function RaycastImpl(terrainLOD:TerrainLOD) {
		this.terrainLOD = terrainLOD;
		
		transformChanged = false;
	}
				
	override public function intersectRay(origin:Vector3D, direction:Vector3D):RayIntersectionData {
		
			if (terrainLOD.transformChanged) terrainLOD.composeTransforms();
					
			var child:Object3D = terrainLOD;
			childOrigin.x = child.inverseTransform.a*origin.x + child.inverseTransform.b*origin.y + child.inverseTransform.c*origin.z + child.inverseTransform.d;
			childOrigin.y = child.inverseTransform.e*origin.x + child.inverseTransform.f*origin.y + child.inverseTransform.g*origin.z + child.inverseTransform.h;
			childOrigin.z = child.inverseTransform.i*origin.x + child.inverseTransform.j*origin.y + child.inverseTransform.k*origin.z + child.inverseTransform.l;
			childDirection.x = child.inverseTransform.a*direction.x + child.inverseTransform.b*direction.y + child.inverseTransform.c*direction.z;
			childDirection.y = child.inverseTransform.e*direction.x + child.inverseTransform.f*direction.y + child.inverseTransform.g*direction.z;
			childDirection.z = child.inverseTransform.i * direction.x + child.inverseTransform.j * direction.y + child.inverseTransform.k * direction.z;
			
			var waterData:RayIntersectionData = terrainLOD.intersectRayWater(childOrigin, childDirection);
			var data:RayIntersectionData = direction.w <= ddaMaxRange ? terrainLOD.intersectRayDDA(childOrigin, childDirection) : terrainLOD.intersectRay(childOrigin, childDirection);
			
			if (data != null || waterData != null) {
				//if (waterData) throw new Error(waterData.time + ", "+childOrigin + ", "+childDirection);
				if (data != null) {
					// TODO: time in TerrainLOD is a bit wrong at the moment. Need to check. FOr now, use this temp dotProduct fix!
					data.time = (data.point.x - childOrigin.x) * direction.x + (data.point.y - childOrigin.y) * direction.y + (data.point.z - childOrigin.z) * direction.z;
				}
				return data != null ? waterData == null || data.time < waterData.time ? data : waterData : waterData;
			}
			return null;
			
	}
	
}
    