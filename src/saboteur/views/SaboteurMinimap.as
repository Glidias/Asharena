package saboteur.views 
{
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
	import flash.utils.Dictionary;
	import saboteur.models.IBuildModel;
	import saboteur.util.CardinalVectors;
	import saboteur.util.GameBuilder3D;
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
		private var jettyMaterial:TextureAtlasMaterial;
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
		private var builder:GameBuilder3D;
		
		public function setupBuildModelAndView(model:IBuildModel, builder3:GameBuilder3D,  blueprintColorFloor:Mesh=null):void  {
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
			
			var fromX:Number = builder.startScene._x;
			var fromY:Number = builder.startScene._y;
			var x:int = builder.floorGridEast;
			var y:int = builder.floorGridSouth;
			var cardinal:CardinalVectors = builder.cardinal;
			var dx:Number =  x * cardinal.east.x + y * cardinal.east.y;
			var dy:Number =  x * cardinal.south.x + y * cardinal.south.y;
			blueprint.root._x =fromX+ dx * jettyTileSize.x;
			blueprint.root._y = fromY + dy * jettyTileSize.y - 2;
			
			blueprint.root.transformChanged = true;
			var index:int = pathUtil.getIndexByValue(buildId);
			var rowIndex:int = int(index / jettyColumns);
			var colIndex:int = index - rowIndex * jettyColumns;
			
			blueprint.u = (jettyTileSize.x * colIndex ) / jettySheetWidth;
			blueprint.v = .5+ (jettyTileSize.x * rowIndex ) / jettySheetHeight;
			
			blueprintColorFloor._x = blueprint.root._x;// builder.blueprint.x;
			blueprintColorFloor._y = blueprint.root._y;// builder.blueprint.y;
			blueprintColorFloor.transformChanged = true;
			
			if (blueprintMaterial != null ) {
				blueprintMaterial.color = builder.editorMat.color;
				blueprintMaterial.alpha = builder.editorMat.alpha;
			}
	
			activateFloorBlueprintPosition();
		}
		
		public function activateFloorBlueprintPosition():void {
			
			if (blueprint.index < 0) {
				jettySet.addCloneQuick(blueprint);
				
			}
			blueprintColorFloor.visible = true;
		}
		
		public function deactivateFloorBlueprintPosition():void {
			if (blueprint.index >= 0) {
				jettySet.removeCloneQuick(blueprint);
			}
			blueprintColorFloor.visible = false;
		}
		
		public function SaboteurMinimap(jettyMaterial:TextureAtlasMaterial, jettyColumns:int, jettyTileSize:Point, pixelToMinimapScale:Number) 
		{
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
		
		
		public function createJettyWithBuilder(value:uint, builder:GameBuilder3D):void {
			var buildDict:Dictionary = builders[builder];
			if (buildDict == null) buildDict = builders[builder] = new Dictionary();
			buildDict[pathUtil.getGridKey( builder.floorGridEast, builder.floorGridSouth)] = createJettyAt(builder.floorGridEast, builder.floorGridSouth, pathUtil.getIndexByValue(value), builder.cardinal, builder.startScene.x, builder.startScene.y);
		}
		
		public function removeJettyWithBuilder(builder:GameBuilder3D):void {
			var key:uint = pathUtil.getGridKey(builder.floorGridEast, builder.floorGridSouth);	
			var buildDict:Dictionary = builders[builder];
			jettySet.removeClone(buildDict[key]);
			delete buildDict[key];
		}
		
		
		public function createJettyAt(x:int, y:int, index:int, cardinal:CardinalVectors=null, fromX:Number=0, fromY:Number=0 ):SpriteMeshSetClone {
		//jettyTileSize.y = 28;

			cardinal = cardinal || DEFAULT_CARDINAL;
			var spr:SpriteMeshSetClone = jettySet.createClone() as SpriteMeshSetClone;
			var rowIndex:int = int(index / jettyColumns);
			var colIndex:int = index - rowIndex * jettyColumns;
			var dx:Number =  x * cardinal.east.x + y * cardinal.east.y;
			var dy:Number =  x * cardinal.south.x + y * cardinal.south.y;
			spr.root.x =fromX+ dx * jettyTileSize.x;
			spr.root.y =fromY+ dy * jettyTileSize.y-2;
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