package saboteur.util 
{
	/**
	 * ...
	 * @author Glenn Ko
	 */
	import alternativa.a3d.collisions.CollisionBoundNode;
	import alternativa.a3d.collisions.CollisionUtil;
	import alternativa.engine3d.core.BoundBox;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.loaders.TexturesLoader;
	import alternativa.engine3d.materials.FillMaterial;
	import alternativa.engine3d.materials.Material;
	import alternativa.engine3d.objects.Mesh;
	import alternativa.engine3d.objects.MeshSetClone;
	import alternativa.engine3d.primitives.Box;
	import alternativa.engine3d.primitives.Plane;
	import alternativa.engine3d.resources.ExternalTextureResource;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	import alternativa.engine3d.alternativa3d;
	use namespace alternativa3d;

	/**
	 * Class to help handle building of saboteur jetty structures for Alternativa3D, including collision graph.
	 */
	public class GameBuilder3D {
		private var applyMaterial:Material;
		
		public var startScene:Object3D;
		public var genesis:Object3D;
		public var collision:Object3D;
		public var blueprint:Object3D;
		

		
		public var buildDict:Dictionary;
		private var build3DGrid:Dictionary = new Dictionary();
		
		public static const CARDINAL_VECTORS:CardinalVectors = new CardinalVectors();
		public var cardinal:CardinalVectors;
		
	
		public var editorMat:FillMaterial;
		
		static public const COLOR_OCCUPIED:uint = 0x99AA44;
		static public const COLOR_INVALID:uint = 0xFF6666;
		static public const COLOR_VALID:uint = 0x00FF22;
		static public const COLOR_OUTSIDE:uint =0xAAFF66   ;
		static public const OCCUPIED_FLOOR_ALPHA:Number = .4;
		
		public var _gridSquareBound:BoundBox;
		
		private var gridEast:int = 0; // along east
		private var gridSouth:int = 0 // along south
		alternativa3d var gridEastWidth:Number = 1;
		alternativa3d var gridSouthWidth:Number = 1;
		alternativa3d var gridEastWidth_i:Number = 1;
		alternativa3d var gridSouthWidth_i:Number = 1;
		
		alternativa3d var _floor:Object3D;
		public var collisionScene:Object3D;
		
		private var _value:uint;
		private var startEditorAlpha:Number;
		private var _boundGridBoxConvex3D:CollisionBoundNode;
		private var pathUtil:SaboteurPathUtil;
		public var minSquareBuildDistance:Number;
		
		public var collisionGraph:CollisionBoundNode;
		public var showOccupied:Boolean = false;
		public var pathGraph:SaboteurGraph;
		
		public function GameBuilder3D(startScene:Object3D, genesis:Object3D, blueprint:Object3D, collision:Object3D, applyMaterial:Material, editorMat:FillMaterial, floor:Plane) {

			
			
			cardinal = CARDINAL_VECTORS;
			pathUtil =  SaboteurPathUtil.getInstance();
			pathGraph = new SaboteurGraph();
		
			this.editorMat = editorMat;
			startEditorAlpha = editorMat.alpha;
			this.applyMaterial = applyMaterial;
			
			this.collision = collision;
			this.genesis = genesis;
			this.startScene = startScene;
			this.blueprint = blueprint;
			
			collisionScene = new Object3D();
			collisionScene.matrix = startScene.matrix;
			collisionScene.composeTransforms();
			collisionScene.boundBox = null;
			
			collisionGraph = CollisionUtil.getCollisionGraph(collisionScene);
			
			
			buildDict = new Dictionary();
			
			blueprint.visible = false;
				_floor = floor;
			this.startScene.addChild(genesis);
			this.startScene.addChild(blueprint);
		
			
			_value = pathUtil.getValue( SaboteurPathUtil.EAST | SaboteurPathUtil.NORTH | SaboteurPathUtil.WEST | SaboteurPathUtil.SOUTH, SaboteurPathUtil.ARC_HORIZONTAL | SaboteurPathUtil.ARC_VERTICAL);
			
			refreshValue();
			
			setup();
			
		}
		
		public function setBlueprintVis(val:Boolean):void {
			blueprint.visible = val;
			_floor.visible = val;
			if (val && blueprint._parent != startScene) startScene.addChild(blueprint);
			if (!val) {
				if ( _boundGridBoxConvex3D._parent ) collisionGraph._removeHead()
			}
			else {
				if ( !_boundGridBoxConvex3D._parent ) collisionGraph._prepend(_boundGridBoxConvex3D)
			}
			
		}
		
		
		
		private function setup():void 
		{
			var bounds:BoundBox;
			_gridSquareBound = bounds = genesis.boundBox.clone();  // new BoundBox();  // we assume already set up correctly for now, even though there mayh be slight discrepancy
		
			var xd:Number = bounds.maxX - bounds.minX;
			var yd:Number = bounds.maxY - bounds.minY;
				 _floor.scaleX = xd;
			 _floor.scaleY = yd;
			
	
				_gridSquareBound.maxZ += 45;
				_gridSquareBound.minZ -= 45;
				
				_boundGridBoxConvex3D = CollisionUtil.getCollisionGraph(new Box((_gridSquareBound.maxX - _gridSquareBound.minX), (_gridSquareBound.maxY - _gridSquareBound.minY), (_gridSquareBound.maxZ - _gridSquareBound.minZ) ) );
				
				collisionGraph._prepend(_boundGridBoxConvex3D);
				
			
			gridEastWidth  =cardinal.getDist(cardinal.east, _gridSquareBound, 1);
			gridSouthWidth = cardinal.getDist(cardinal.south, _gridSquareBound, 1);
			minSquareBuildDistance = gridEastWidth * gridEastWidth + gridSouthWidth * gridSouthWidth;

				
			gridEastWidth_i = 1 / gridEastWidth;
			gridSouthWidth_i = 1 / gridSouthWidth;
			
		
			this.startScene.addChild(_floor);
			
			pathGraph.addStartNodeDirectly( pathGraph.addNode(gridEast, gridSouth, _value) );
			pathGraph.recalculateEndpoints();
			
			pathUtil.buildAt(buildDict, gridEast, gridSouth, _value  ); 
			buildCollidablesAt( gridEast, gridSouth, collision, _value );	
			//buildAt(1, 1, 63);
		}
		
	
		
		public function removeAt(gridEast:int, gridSouth:int):Boolean { 
			var key:uint = pathUtil.getGridKey(gridEast, gridSouth);
			var payload:BuildPayload3D = build3DGrid[key];	
			if (payload == null) return false;
			collisionGraph.removeChild(payload.collisionNode);
			startScene.removeChild(payload.object);
			
			delete buildDict[key];
			delete build3DGrid[key];
			pathGraph.removeNode(gridEast, gridSouth);
			pathGraph.recalculateEndpoints();
			return true;	
		}
		
		public function buildAt(gridEast:int, gridSouth:int, value:uint):void 
		{
			
				pathUtil.buildAt(buildDict, gridEast, gridSouth, value  );
					var newBuilding:Object3D = genesis.clone();  // should be genesis or blueprint and re-apply material? depends...for now, just use genesis!
					startScene.addChild( newBuilding);
					visJetty3DByValue(newBuilding, value);
					cardinal.transform(cardinal.east, newBuilding, cardinal.getDist(cardinal.east, _gridSquareBound)* gridEast );
					cardinal.transform(cardinal.south, newBuilding, cardinal.getDist(cardinal.south, _gridSquareBound) * gridSouth );
					
					var collisionBuilding:Object3D = collision; // .clone();
					collisionBuilding._x = newBuilding._x;
					collisionBuilding._y = newBuilding._y;
					collisionBuilding.transformChanged = true;
					visJetty3DByValueRecursive(collisionBuilding, value);
					
					var node:CollisionBoundNode;
					collisionGraph.addChild( node= CollisionUtil.getCollisionGraph(collisionBuilding) );
					//collisionScene.addChild(collisionBuilding);
					
					build3DGrid[pathUtil.getGridKey(gridEast, gridSouth)] =  new BuildPayload3D(newBuilding, node);
					
					pathGraph.addNode(gridEast, gridSouth, _value);
					pathGraph.recalculateEndpoints();
		}
		
		private function buildCollidablesAt(gridEast:int, gridSouth:int, refer:Object3D, value:uint):void {
		
			visJetty3DByValueRecursive(refer, value);
			
			cardinal.transform(cardinal.east, refer, cardinal.getDist(cardinal.east, _gridSquareBound)* gridEast );
			cardinal.transform(cardinal.south, refer, cardinal.getDist(cardinal.south, _gridSquareBound) * gridSouth );
			collisionGraph.addChild( CollisionUtil.getCollisionGraph(refer) );

	
		}
		
			public function tryBuild(buildToValidity:Boolean):void 
			{

				if (checkBuildableResult(_value, buildToValidity) > 0) {
					buildAt(gridEast, gridSouth, _value);	
					checkBuildableResult(_value, buildToValidity);
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
		
		public function updateFloorPosition(ge:int, gs:int, buildToValidity:Boolean):int 
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
					
					_boundGridBoxConvex3D.updateTransform(blueprint._x, blueprint._y, blueprint.z);
					blueprint.transformChanged = true;
					_floor.transformChanged = true;
					
					return checkBuildableResult(_value, buildToValidity);
					
			}
			
			public function setFloorPosition(ge:int, gs:int):void {
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
					
					_boundGridBoxConvex3D.updateTransform(blueprint._x, blueprint._y, blueprint.z);
					blueprint.transformChanged = true;
					_floor.transformChanged = true;
			}
			
			
			private function visJetty3DByValue(obj:Object3D, value:uint):void {

				for (var c:Object3D = obj.childrenList; c != null; c = c.next) {
				  c.visible = pathUtil.visJetty(value, c.name);
				}
			}
			
			public static function visJetty3DByValue(pathUtil:SaboteurPathUtil, obj:Object3D, value:uint):void {
				
				for (var c:Object3D = obj.childrenList; c != null; c = c.next) {
				  c.visible = pathUtil.visJetty(value, c.name);
				}
			}
			
			private function visJetty3DByValueRecursive(obj:Object3D, value:uint):void {
			
				//if (obj is Mesh) (obj as Mesh).setMaterialToAllSurfaces(new FillMaterial(0xFF0000));
				//obj.visible = pathUtil.visJetty(value, obj.name);
				for (var c:Object3D = obj.childrenList; c != null; c = c.next) {
					c.visible = pathUtil.visJetty(value, c.name);
					//if (c is Mesh) (c as Mesh).setMaterialToAllSurfaces(new FillMaterial(0xFF0000));
					if (c.childrenList != null) visJetty3DByValueRecursive(c, value);	 
				}
			}
			
			public function isOccupiedAt(ge:int, gs:int):Boolean {
				return buildDict[pathUtil.getGridKey(ge, gs)] != null;
			}
			
			private function checkBuildableResult(value:uint, buildToValidity:Boolean):int 
			{
		
				var result:int = pathUtil.getValidResult(buildDict, gridEast, gridSouth, value,  pathGraph  );
					if (result === SaboteurPathUtil.RESULT_OCCUPIED) {
						if (gridEast!=0 || gridSouth != 0) {
							editorMat.alpha =  OCCUPIED_FLOOR_ALPHA;
							editorMat.color = COLOR_OCCUPIED;
							blueprint.visible = showOccupied;
							if ( _boundGridBoxConvex3D._parent ) collisionGraph._removeHead();
						}
						else {  // outta range
							blueprint.visible = false;
							_floor.visible = false;
							if ( _boundGridBoxConvex3D._parent ) collisionGraph._removeHead();
							result =  SaboteurPathUtil.RESULT_OUT;
						}
					//	_floor.visible = showOccupied;
						//throw new Error(pathUtil.getGridKey(ge, gs));
					}
					else if (result === SaboteurPathUtil.RESULT_INVALID) {
						editorMat.color = COLOR_INVALID;
						editorMat.alpha = startEditorAlpha;
						
					}
					else if (result === SaboteurPathUtil.RESULT_OUT) {
							editorMat.color = COLOR_OUTSIDE;
							editorMat.alpha = startEditorAlpha;
					}
					else {  // result valid (doublecheck buildToValidity if required!)
						
						editorMat.color = COLOR_VALID;
						editorMat.alpha = startEditorAlpha;
						
					}
					
					return result;
			}
			
			private function getCurBuildableResult():int 
			{
			
				return pathUtil.getValidResult(buildDict, gridEast, gridSouth, _value, null );
					
			}
			
			public function setBlueprintIdVis(val:uint):void 
			{
				for (var obj:Object3D = blueprint.childrenList; obj != null; obj = obj.next) {
					obj.visible = pathUtil.visJetty(val, obj.name);
				}
			}
			
			
			public function attemptBuild():void 
			{
				if (getCurBuildableResult() === SaboteurPathUtil.RESULT_VALID) {
					buildAt(gridEast, gridSouth, _value);
				}
			}
			
			public function attemptRemove():void 
			{
				if (getCurBuildableResult() === SaboteurPathUtil.RESULT_OCCUPIED) {
					removeAt(gridEast, gridSouth);
				}
			}
			
			
			
			public function get value():uint 
			{
				return _value;
			}
			
			public function set value(value:uint):void 
			{
				if (_value === value) return;
				_value = value;
				
				if (_value >= 0) refreshValue();
			}
			
			private function refreshValue():void {
			   for (var c:Object3D = blueprint.childrenList; c != null; c = c.next) {
					 c.visible = pathUtil.visJetty(_value, c.name);
				 }
			}
		
		
		
		
	}

}
import alternativa.a3d.collisions.CollisionBoundNode;
import alternativa.engine3d.core.Object3D;

class BuildPayload3D {
	public var object:Object3D
	public var collisionNode:CollisionBoundNode;
	public function BuildPayload3D(object:Object3D, collisionNode:CollisionBoundNode) {
		this.collisionNode = collisionNode;
		this.object = object;
		
	}

}