package saboteur.util 
{
	/**
	 * ...
	 * @author Glenn Ko
	 */
	import alternativa.engine3d.core.BoundBox;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.loaders.TexturesLoader;
	import alternativa.engine3d.materials.FillMaterial;
	import alternativa.engine3d.materials.Material;
	import alternativa.engine3d.objects.Mesh;
	import alternativa.engine3d.objects.MeshSetClone;
	import alternativa.engine3d.primitives.Plane;
	import alternativa.engine3d.resources.ExternalTextureResource;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	import alternativa.engine3d.alternativa3d;
	use namespace alternativa3d;

	public class GameBuilder3D {
		private var applyMaterial:Material;
		
		public var startScene:Object3D;
		public var genesis:Object3D;
		public var collision:Object3D;
		public var blueprint:Object3D;
		
		private static var PATH_UTIL:SaboteurPathUtil;
		public var  pathUtil:SaboteurPathUtil;
		
		private var buildDict:Dictionary;
		
		public static var CARDINAL_VECTORS:CardinalVectors;
		public var cardinal:CardinalVectors;
		
		public static var EDITOR_MAT:FillMaterial;
		private var editorMat:FillMaterial;
		
		static private const COLOR_OCCUPIED:uint = 0x99AA44;
		static private const COLOR_INVALID:uint = 0xFF6666;
		static private const COLOR_VALID:uint = 0x00FF00;
		static private const COLOR_OUTSIDE:uint = 0x333333;
		
		public var _gridSquareBound:BoundBox;
		
		private var gridEast:int = 0; // along east
		private var gridSouth:int = 0 // along south
		private var gridEastWidth:Number = 1;
		private var gridSouthWidth:Number = 1;
		private var gridEastWidth_i:Number = 1;
		private var gridSouthWidth_i:Number = 1;
		
		private var _floor:Object3D;
		public var collisionScene:Object3D;
		
		private var _value:uint;
		
		public function GameBuilder3D(startScene:Object3D, genesis:Object3D, blueprint:Object3D, collision:Object3D, applyMaterial:Material) {
			if (PATH_UTIL == null) PATH_UTIL = new SaboteurPathUtil();
			if (CARDINAL_VECTORS == null) CARDINAL_VECTORS = new CardinalVectors();
			if (EDITOR_MAT == null) EDITOR_MAT = new FillMaterial(0, .3);
			
			cardinal = CARDINAL_VECTORS;
			pathUtil = PATH_UTIL;
			editorMat = EDITOR_MAT;
			
			this.applyMaterial = applyMaterial;
			
			this.collision = collision;
			this.genesis = genesis;
			this.startScene = startScene;
			this.blueprint = blueprint;
			
			collisionScene = new Object3D();
			collisionScene.matrix = startScene.matrix;
			collisionScene.addChild(collision);
			
			
			buildDict = new Dictionary();
			
			blueprint.visible = false;
			
			this.startScene.addChild(genesis);
			this.startScene.addChild(blueprint);
		
			
			_value = pathUtil.getValue( SaboteurPathUtil.EAST | SaboteurPathUtil.NORTH | SaboteurPathUtil.WEST | SaboteurPathUtil.SOUTH, SaboteurPathUtil.ARC_HORIZONTAL | SaboteurPathUtil.ARC_VERTICAL);
			refreshValue();
			
			setup();
			
		}
		
		public function setBlueprintVis(val:Boolean):void {
			blueprint.visible = val;
			if (val && blueprint._parent != startScene) startScene.addChild(blueprint);
			
		}
		
		private function setup():void 
		{
			var bounds:BoundBox;
			_gridSquareBound = bounds = genesis.boundBox.clone();  // new BoundBox();  // we assume already set up correctly for now, even though there mayh be slight discrepancy
			
			var xd:Number = bounds.maxX - bounds.minX;
			var yd:Number = bounds.maxY - bounds.minY;
			
			gridEastWidth  =cardinal.getDist(cardinal.east, _gridSquareBound, 1);
			gridSouthWidth =cardinal.getDist(cardinal.south, _gridSquareBound, 1);
				
			gridEastWidth_i = 1 / gridEastWidth;
			gridSouthWidth_i = 1 / gridSouthWidth;
			
			
			 var plane:Plane = new Plane(1, 1, 1, 1, false, false, editorMat, editorMat);
			 editorMat.color = COLOR_OCCUPIED;
			 plane.scaleX = xd;
			 plane.scaleY = yd;
			_floor = plane;
			this.startScene.addChild(_floor);
			
			
			pathUtil.buildAt(buildDict, gridEast, gridSouth, _value  ); 
			
		}
		
		public function buildAt(gridEast:int, gridSouth:int, value:uint):void 
		{
				pathUtil.buildAt(buildDict, gridEast, gridSouth, value  );
					var newBuilding:Object3D = genesis.clone();  // should be genesis or blueprint and re-apply material? depends...for now, just use genesis!
					startScene.addChild( newBuilding);
					visJetty3DByValue(newBuilding, value);
					cardinal.transform(cardinal.east, newBuilding, cardinal.getDist(cardinal.east, _gridSquareBound)* gridEast );
					cardinal.transform(cardinal.south, newBuilding, cardinal.getDist(cardinal.south, _gridSquareBound) * gridSouth );
					
					var collisionBuilding:Object3D = collision.clone();
					collisionBuilding.x = newBuilding.x;
					collisionBuilding.y = newBuilding.y;
					visJetty3DByValue(newBuilding, value);
					collisionScene.addChild(collisionBuilding);
		}
		
			public function tryBuild():void 
			{

				if (checkBuildableResult(_value) > 0) {
					buildAt(gridEast, gridSouth, _value);	
					checkBuildableResult(_value);
				}
			}
			
			

		
		
		private function setMaterialToCont(mat:Material, cont:Object3D):void 
		{
			for (var c:Object3D = cont.childrenList; c != null; c = c.next) {
				var mesh:Mesh = c as Mesh;
				if (mesh != null) {
					mesh.setMaterialToAllSurfaces(mat);
				}
			}
		}
		
		public function updateFloorPosition(ge:int, gs:int):int 
			{
					gridEast = ge;
					gridSouth = gs;
					//_floor.x = ge*gridEastWidth;
					//_floor.y = gs * gridSouthWidth;
					var eastD:Number = gridEastWidth * ge;
					var southD:Number = gridSouthWidth * gs;
					
					_floor._x = eastD * cardinal.east.x;
					_floor._y = eastD * cardinal.east.y;
					_floor._x += southD * cardinal.south.x;
					_floor._y += southD * cardinal.south.y;
					
					blueprint._x = _floor._x;
					blueprint._y = _floor._y;
					
					blueprint.transformChanged = true;
					_floor.transformChanged = true;
					
					return checkBuildableResult(_value);
					
			}
			
			private function visJetty3DByValue(obj:Object3D, value:uint):void {

				for (var c:Object3D = obj.childrenList; c != null; c = c.next) {
				  c.visible = pathUtil.visJetty(value, c.name);
				}
			}
			
			private function checkBuildableResult(value:uint):int 
			{

				var result:int = pathUtil.getValidResult(buildDict, gridEast, gridSouth, value );
					if (result === SaboteurPathUtil.RESULT_OCCUPIED) {
					
						editorMat.color = COLOR_OCCUPIED;
						//throw new Error(pathUtil.getGridKey(ge, gs));
					}
					else if (result === SaboteurPathUtil.RESULT_INVALID) {
						editorMat.color = COLOR_INVALID;
						
					}
					else if (result === SaboteurPathUtil.RESULT_OUT) {
							editorMat.color = COLOR_OUTSIDE;
					}
					else {
						editorMat.color = COLOR_VALID;
					}
					return result;
			}
			
			public function get value():uint 
			{
				return _value;
			}
			
			public function set value(value:uint):void 
			{
				if (_value === value) return;
				_value = value;
				refreshValue();
			}
			
			private function refreshValue():void {
			   for (var c:Object3D = blueprint.childrenList; c != null; c = c.next) {
					 c.visible = pathUtil.visJetty(_value, c.name);
				 }
			}
		
		
		
		
	}

}