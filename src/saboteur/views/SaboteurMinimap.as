package saboteur.views 
{
	import alternativa.a3d.cullers.BVHCuller;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.Renderer;
	import alternativa.engine3d.materials.FillHudMaterial;
	import alternativa.engine3d.materials.FillMaterial;
	import alternativa.engine3d.materials.Material;
	import alternativa.engine3d.objects.IMeshSetCloneCuller;
	import alternativa.engine3d.objects.Mesh;
	import alternativa.engine3d.objects.SpriteMeshSetClone;
	import alternativa.engine3d.objects.SpriteMeshSetClonesContainer;
	import alternativa.engine3d.resources.BitmapTextureResource;
	import alternativa.engine3d.spriteset.materials.TextureAtlasMaterial;
	import ash.core.NodeList;
	import ash.core.System;
	import flash.display.BitmapData;
	import flash.display3D.Context3D;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;
	import saboteur.models.IBuildModel;
	import saboteur.spawners.JettySpawner;
	import saboteur.util.Builder3D;
	import saboteur.util.CardinalVectors;
	import saboteur.util.GameBuilder;
	import saboteur.util.SaboteurPathUtil;
	import alternativa.engine3d.alternativa3d;
	use namespace alternativa3d;
	
	/**
	 * ...
	 * @author Glidias
	 */
	public class SaboteurMinimap extends System
	{
		public var jettySet:SpriteMeshSetClonesContainer;
		public function setCuller(culler:IMeshSetCloneCuller):void {
			jettySet.culler = culler;
		}

		public var jettyColumns:int;
		
		private var pathUtil:SaboteurPathUtil = SaboteurPathUtil.getInstance();
		public var jettyMaterial:TextureAtlasMaterial;
		private var jettySheetWidth:int;
		private var jettySheetHeight:int;
		private var jettyTileSize:Point;
		public var pixelToMinimapScale:Number;
		static private var DUMMY:Object3D = new Object3D();
		
		private static var DEFAULT_CARDINAL:CardinalVectors = new CardinalVectors();
		
		private var blueprint:SpriteMeshSetClone;
		private var blueprintColorFloor:Object3D;
		private var blueprintMaterial:FillHudMaterial;
		private var buildModel:IBuildModel;
		private var builder:Builder3D;
		private var _scal:Number = 1;
		private var offsetGridPlaceVector:Vector3D = new Vector3D(0, -2,0);
		private var offsetDeltaPlaceVector:Vector3D = new Vector3D(0, -2, 0);
		
		private var jettySetParents:Dictionary = new Dictionary();
		
		public function setupBuildModelAndView(model:IBuildModel, builder3:Builder3D,  blueprintColorFloor:Mesh=null):void  {
			if (blueprint == null) {
				blueprint = jettySet.createClone() as SpriteMeshSetClone;
				blueprint.root.scaleX =  jettyTileSize.x ;
				blueprint.root.scaleY = jettyTileSize.y;
		
				blueprint.uw = jettyTileSize.x / jettySheetWidth;
				blueprint.vw = jettyTileSize.y / jettySheetHeight;
			}
			
			if (blueprintColorFloor != null) {
				blueprintColorFloor.setMaterialToAllSurfaces( blueprintMaterial = FillHudMaterial.fromFillMaterial(builder3.editorMat) );  // bind with gamebuilder3d
				
			}
			
			this.blueprintColorFloor = blueprintColorFloor || DUMMY;
			buildModel = model;
			builder = builder3;
			
			
			blueprint.root._parent = getSprParentContainerOf(builder3.startScene);
			
			blueprintColorFloor._rotationZ =builder3.startScene._rotationZ;
			
			
			offsetDeltaPlaceVector = builder3.startScene.matrix.deltaTransformVector(offsetGridPlaceVector);
			offsetDeltaPlaceVector.normalize();
			offsetDeltaPlaceVector.scaleBy(offsetGridPlaceVector.length);
			
			_scal =  pixelToMinimapScale / JettySpawner.SPAWN_SCALE;
			
		}
		
		public function setPixelToMinimapScale(val:Number):void {
			pixelToMinimapScale = val;
			var scal:Number = pixelToMinimapScale / JettySpawner.SPAWN_SCALE;
			_scal = scal;
			for (var key:* in  jettySetParents) {
				var p:Object3D = jettySetParents[key];
				p._x =  builder.startScene._x * scal;
				p._y =  builder.startScene._y * scal;
				p.composeTransforms();
			}	
		}
		
		override public function update(time:Number):void {
			if (buildModel == null) return;
		
			var buildId:int;
			if (!builder.blueprint.visible || (buildId=buildModel.getCurBuildID()) < 0) {
				deactivateFloorBlueprintPosition();
				return;
			}
			
			//blueprint.root._x = builder.blueprint._x * minimapModel.worldToMiniScale;
			//blueprint.root._y = builder.blueprint._y * minimapModel.worldToMiniScale;
			

			var x:int = builder.floorGridEast;
			var y:int = builder.floorGridSouth;
			var cardinal:CardinalVectors = DEFAULT_CARDINAL;// builder.cardinal;
			var dx:Number =  x * cardinal.east.x + y * cardinal.east.y;
			var dy:Number =  x * cardinal.south.x + y * cardinal.south.y;
			blueprint.root._x = dx * jettyTileSize.x + offsetGridPlaceVector.x;
			blueprint.root._y =  dy * jettyTileSize.y + offsetGridPlaceVector.y;
			blueprint.root.transformChanged = true;
			
			
			var index:int = pathUtil.getIndexByValue(buildId);
			var rowIndex:int = int(index / jettyColumns);
			var colIndex:int = index - rowIndex * jettyColumns;
			
			
			blueprint.u = (jettyTileSize.x * colIndex ) / jettySheetWidth;
			blueprint.v = .5+ (jettyTileSize.x * rowIndex ) / jettySheetHeight;
			
			
			// global cardinal coordinates for blueprint floor
			cardinal= builder.cardinal;
			dx =  x * cardinal.east.x + y * cardinal.east.y;
			dy =  x * cardinal.south.x + y * cardinal.south.y;
			
			blueprintColorFloor._x = builder.startScene._x*_scal + dx * jettyTileSize.x +offsetDeltaPlaceVector.x;// builder.blueprint.x;
			blueprintColorFloor._y = builder.startScene._y*_scal + dy * jettyTileSize.y +offsetDeltaPlaceVector.y;// builder.blueprint.y;
			blueprintColorFloor.transformChanged = true;
			
			if (blueprintMaterial != null ) {
				blueprintMaterial.color = builder.editorMat.color;
				blueprintMaterial.alpha = builder.editorMat.alpha;
			}
	
			activateFloorBlueprintPosition();
		}
		
		public function activateFloorBlueprintPosition():void {
			
			if (blueprint.index < 0) {
				jettySet.addClone(blueprint);
				
			}
			blueprintColorFloor.visible = true;
		}
		
		public function deactivateFloorBlueprintPosition():void {
			if (blueprint.index >= 0) {
				jettySet.removeClone(blueprint);
			}
			blueprintColorFloor.visible = false;
		}
		
		public function SaboteurMinimap(jettyMaterial:TextureAtlasMaterial, jettyColumns:int, jettyTileSize:Point, pixelToMinimapScale:Number, builder3D:Builder3D) 
		{
			this.builder3D = builder3D;
			this.jettyMaterial = jettyMaterial;
			this.pixelToMinimapScale = pixelToMinimapScale;
			this.jettyTileSize = jettyTileSize;
		//	jettyMaterial.alphaThreshold = 0.99;
			var bmpData:BitmapData = (jettyMaterial.diffuseMap as BitmapTextureResource).data;
			jettySheetWidth = bmpData.width;
			jettySheetHeight = bmpData.height;
			this.jettyColumns = jettyColumns;
			
			jettySet = new SpriteMeshSetClonesContainer(jettyMaterial);
			jettySet.objectRenderPriority = Renderer.NEXT_LAYER;
			jettySet.z = -.02;
			
		}
		
		private var builders:Dictionary = new Dictionary();
		private var builder3D:Builder3D;  // minimap can only be tied to 1 builder3D? by now, stick to this single-player convention, bleh.

		public function createJettyWithBuilder(value:uint, gameBuilder:GameBuilder, floorGridEast:int, floorGridSouth:int):void {

			var buildDict:Dictionary = builders[gameBuilder];
			if (buildDict == null) buildDict = builders[gameBuilder] = new Dictionary();
			var parentCont:Object3D = getSprParentContainerOf(builder3D.startScene);
			var cloned:SpriteMeshSetClone;
			buildDict[pathUtil.getGridKey( floorGridEast, floorGridSouth)] = cloned = createJettyAt(floorGridEast, floorGridSouth, pathUtil.getIndexByValue(value), DEFAULT_CARDINAL, builder3D.startScene.x, builder3D.startScene.y);
			
			cloned.root._parent = parentCont;
		}
		
		private function getSprParentContainerOf(startScene:Object3D):Object3D {
			var parentCont:Object3D = jettySetParents[startScene];
			if (!parentCont) {
				jettySetParents[startScene]  =  parentCont=getMatchingContainer(startScene);  // lazy init builder container, assumed doesn't move..
			}
			return parentCont;
		}
		
		private function getMatchingContainer(startScene:Object3D):Object3D 
		{
			var obj:Object3D = new Object3D();
			
			var scal:Number = pixelToMinimapScale/JettySpawner.SPAWN_SCALE;  // TODO: tie jettySet to custom parent 
			obj._x = startScene._x * scal;
			obj._y =  startScene._y * scal;
			obj._rotationZ = startScene._rotationZ;
			obj.composeTransforms();
			
			return obj;
		}
		
		public function removeJettyWithBuilder(builder:Builder3D):void {
			var key:uint = pathUtil.getGridKey(builder.floorGridEast, builder.floorGridSouth);	
			var buildDict:Dictionary = builders[builder];
			jettySet.removeClone(buildDict[key]);
			delete buildDict[key];
		}
		

	
		public function setSprJettyUVCoordinatesAndSizeByIndex(index:int, spr:SpriteMeshSetClone):void {
			
			var rowIndex:int = int(index / jettyColumns);
			var colIndex:int = index - rowIndex * jettyColumns; 
			spr.u = (jettyTileSize.x * colIndex ) / jettySheetWidth;
			spr.v = (jettyTileSize.x * rowIndex ) / jettySheetHeight;
			spr.uw = jettyTileSize.x / jettySheetWidth;
			spr.vw = jettyTileSize.y / jettySheetHeight;
			spr.root.scaleX =  jettyTileSize.x ;
			spr.root.scaleY = jettyTileSize.y;
		}
		
		
		private function createJettyAt(x:int, y:int, index:int, cardinal:CardinalVectors=null, fromX:Number=0, fromY:Number=0 ):SpriteMeshSetClone {
		//jettyTileSize.y = 28;
			
			cardinal = cardinal || DEFAULT_CARDINAL;
			var spr:SpriteMeshSetClone = jettySet.createClone() as SpriteMeshSetClone;
			var rowIndex:int = int(index / jettyColumns);
			var colIndex:int = index - rowIndex * jettyColumns;
			var dx:Number =  x * cardinal.east.x + y * cardinal.east.y;
			var dy:Number =  x * cardinal.south.x + y * cardinal.south.y;
			spr.root.x = dx * jettyTileSize.x + offsetGridPlaceVector.x;
			spr.root.y = dy * jettyTileSize.y + offsetGridPlaceVector.y;
			spr.root.scaleX =  jettyTileSize.x ;
			spr.root.scaleY = jettyTileSize.y;
			
			
			//spr.root.rotationZ = Math.PI;
		
				//	spr.root.rotationX = Math.PI;
				//	/*
			spr.u = (jettyTileSize.x * colIndex ) / jettySheetWidth;
			spr.v = (jettyTileSize.x * rowIndex ) / jettySheetHeight;
			spr.uw = jettyTileSize.x / jettySheetWidth;
			spr.vw = jettyTileSize.y / jettySheetHeight;
		//	*/
	//	throw new Error(jettyTileSize);
			jettySet.addClone(spr);
			return spr;
		}
		
		//public function 
		
		
		
		public function addToContainer(obj:Object3D):void {
			obj.addChild(jettySet);
		}
		
		public function upload(context3D:Context3D):void 
		{
			jettySet.geometry.upload(context3D);
		}
		
	}

}