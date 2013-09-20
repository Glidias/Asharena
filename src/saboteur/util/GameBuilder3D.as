package saboteur.util 
{
	/**
	 * ...
	 * @author Glenn Ko
	 */
	import alternativa.a3d.collisions.CollisionBoundNode;
	import alternativa.a3d.collisions.CollisionUtil;
	import alternativa.a3d.cullers.BVHCuller;
	import alternativa.engine3d.core.BoundBox;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.Transform3D;
	import alternativa.engine3d.loaders.TexturesLoader;
	import alternativa.engine3d.materials.FillMaterial;
	import alternativa.engine3d.materials.Material;
	import alternativa.engine3d.objects.Mesh;
	import alternativa.engine3d.objects.MeshSetClone;
	import alternativa.engine3d.objects.MeshSetClonesContainer;
	import alternativa.engine3d.primitives.Box;
	import alternativa.engine3d.primitives.Plane;
	import alternativa.engine3d.resources.ExternalTextureResource;
	import alternativa.engine3d.utils.Object3DUtils;
	import flash.display3D.Context3D;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	import alternativa.engine3d.alternativa3d;
	import haxe.Log;
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
		private var localCardinal:CardinalVectors;
	
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
		public function get floorGridEast():int {
			return gridEast;
		}
		public function get floorGridSouth():int {
			return gridSouth;
		}
		
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
		
		
		

		private static var MESH_SETS:Object = { };
		public static function addMeshSetsToScene(scene:Object3D, sampleBlueprint:Object3D, material:Material, context3D:Context3D):void {
			var meshSet:MeshSetClonesContainer;
			const meshSetHash:Object = MESH_SETS;
			
			
		
			for (var c:Object3D = sampleBlueprint.childrenList; c != null; c = c.next) {
				var mesh:Mesh = c as Mesh;
				if (mesh != null) {
					meshSetHash[c.name] = meshSet = new MeshSetClonesContainer( mesh, material);
					meshSet.name = c.name + "_meshset";
					meshSet.geometry.upload(context3D);
					if (mesh.boundBox == null) {
						 mesh.boundBox = Object3DUtils.calculateHierarchyBoundBox(mesh);
					}
					meshSet.culler = new BVHCuller(meshSet);  
				}
			}
			
			//var count:int = 0;
			for (var prop:String in meshSetHash) {
				scene.addChild(meshSetHash[prop]);
				//	count++;
			}
			//throw new Error(count + " meshsets.");
		}
		
		
		
		//alternativa3d var startOffsetX:Number;
		//alternativa3d var startOffsetY:Number;
		
		//private var startOffsetXLocal:Number;
		//private var startOffsetYLocal :Number;
		
		
		public function GameBuilder3D(startScene:Object3D, genesis:Object3D, blueprint:Object3D, collision:Object3D, applyMaterial:Material, editorMat:FillMaterial, floor:Plane) {
		
		
			// TODO:  MeshSet BVHculler implementation doesn't seem to do any form of culling
			
			// PathBuilderSystem raycasting wrong when including BOTH position and rotation offsets
			///*
			//startOffsetX = 555;
			//startOffsetY = 313;
			//startScene.x = 444;
			//startScene.y = 344;
			//	*/
			// TODO: Circle radius culling for radar not accruate with rotation!!
			//startScene.rotationZ = Math.PI * .37;
			//	startScene.rotationX= Math.PI*.15;  // currenty rotation on other axes NOT supported
			
			//this.startOffsetX = startOffsetX;
			//this.startOffsetY = startOffsetY;
			
			var startSceneMatrix:Matrix3D = startScene.matrix;
			/*
			var matrixer:Matrix3D =startSceneMatrix.clone();
			matrixer.invert();
			var localStartOffset:Vector3D =matrixer.deltaTransformVector( new Vector3D(startOffsetX, startOffsetY, 0) );
			startOffsetXLocal = localStartOffset.x;// startOffsetX / startScene._scaleX;
			startOffsetYLocal = localStartOffset.y ;// startOffsetY / startScene._scaleY;
			*/
			
			localCardinal = CARDINAL_VECTORS;
			cardinal = new CardinalVectors();   //  global coordinate space cardinal vectors based off startScene's rotationZ!
						
			cardinal.east = startSceneMatrix.deltaTransformVector(cardinal.east);
			cardinal.south = startSceneMatrix.deltaTransformVector(cardinal.south);
			cardinal.east.normalize();
			cardinal.south.normalize();
			
			cardinal.syncNorthWest();
			//var eastGlobal:Vector3D = new Vector3D( Math.cos( startScene._rotationZ), Math.sin(startScene._rotationZ), 0);
			//cardinal.setupEastSouth( eastGlobal, new Vector3D(eastGlobal.y, eastGlobal.x) );
			
			pathUtil =  SaboteurPathUtil.getInstance();
			pathGraph = new SaboteurGraph();
		
			this.editorMat = editorMat;
			startEditorAlpha = editorMat.alpha;
			this.applyMaterial = applyMaterial;
			
			this.collision = collision;
			collision.x = 0;// startOffsetXLocal;
			collision.y = 0;// startOffsetYLocal;
			this.genesis = genesis;
			genesis._x = 0;
			genesis._y = 0;
			this.startScene = startScene;
			this.blueprint = blueprint;
			
			collisionScene = new Object3D();
			//collisionScene.matrix = startSceneMatrix;
			collisionScene._x = startScene._x;
			collisionScene._y = startScene._y;
			collisionScene._z = startScene._z;
			
			collisionScene._rotationX = startScene._rotationX;
			collisionScene._rotationY = startScene._rotationY;
			collisionScene._rotationZ = startScene._rotationZ;
	
			collisionScene._scaleX = startScene._scaleX;
			collisionScene._scaleY = startScene._scaleY;
			collisionScene._scaleZ = startScene._scaleZ;
			
			collisionScene.composeTransforms();
			collisionScene.boundBox = null;
			
			collisionGraph = CollisionUtil.getCollisionGraph(collisionScene);
			
			
			buildDict = new Dictionary();
			
			blueprint.visible = false;
				_floor = floor;
			//this.startScene.addChild(genesis);
			this.startScene.addChild(blueprint);
		
			
			
			
			_value = pathUtil.getValue( SaboteurPathUtil.EAST | SaboteurPathUtil.NORTH | SaboteurPathUtil.WEST | SaboteurPathUtil.SOUTH, SaboteurPathUtil.ARC_HORIZONTAL | SaboteurPathUtil.ARC_VERTICAL);
	
			refreshValue();
			
			setup();
				addRenderable(genesis);
		}
		
		private function addRenderable(obj:Object3D):Vector.<MeshSetClone> {
			var meshSets:Object = MESH_SETS;
			var meshSetClones:Vector.<MeshSetClone> = new Vector.<MeshSetClone>();
			for (var c:Object3D = obj.childrenList; c != null; c = c.next) {
				if (c.visible) {
					var cont:MeshSetClonesContainer = meshSets[c.name];
					var cloned:MeshSetClone = cont.createClone();
					cloned.root._x += blueprint._x;
					cloned.root._y += blueprint._y;
					cloned.root._z += blueprint._z;
					cloned.root.transformChanged = true;
					cloned.root._parent = startScene;
					meshSetClones.push(cloned);
					cont.addCloneWithCuller( cloned );
					//startScene.addChild(obj);
					
				}
			}
			
			return meshSetClones;
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
				
			
			gridEastWidth  =localCardinal.getDist(localCardinal.east, _gridSquareBound, 1);
			gridSouthWidth = localCardinal.getDist(localCardinal.south, _gridSquareBound, 1);
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
			//startScene.removeChild(payload.object);
			payload.clearObjects(MESH_SETS);
			
			delete buildDict[key];
			delete build3DGrid[key];
			pathGraph.removeNode(gridEast, gridSouth);
			pathGraph.recalculateEndpoints();
			return true;	
		}
		
		public function buildAt(gridEast:int, gridSouth:int, value:uint):void 
		{
			
				pathUtil.buildAt(buildDict, gridEast, gridSouth, value  );
					var newBuilding:Object3D =genesis;  // should be genesis or blueprint and re-apply material? depends...for now, just use genesis!
					
					visJetty3DByValue(newBuilding, value);
					
					localCardinal.transform(localCardinal.east, newBuilding, localCardinal.getDist(localCardinal.east, _gridSquareBound)* gridEast );
					localCardinal.transform(localCardinal.south, newBuilding, localCardinal.getDist(localCardinal.south, _gridSquareBound) * gridSouth );
					
					var collisionBuilding:Object3D = collision; // .clone();
					collisionBuilding._x = newBuilding._x;
					collisionBuilding._y = newBuilding._y;
					collisionBuilding.transformChanged = true;
					visJetty3DByValueRecursive(collisionBuilding, value);
					var renderableClones:Vector.<MeshSetClone> = addRenderable( newBuilding);
					
					
					var node:CollisionBoundNode;
					collisionGraph.addChild( node = CollisionUtil.getCollisionGraph(collisionBuilding) );
				//		node.debug = true;
					//collisionScene.addChild(collisionBuilding);
					
					build3DGrid[pathUtil.getGridKey(gridEast, gridSouth)] =  new BuildPayload3D(renderableClones, node);
					
					pathGraph.addNode(gridEast, gridSouth, _value);
					pathGraph.recalculateEndpoints();
		}
		
		private function buildCollidablesAt(gridEast:int, gridSouth:int, refer:Object3D, value:uint):void {
		
			visJetty3DByValueRecursive(refer, value);
			
			localCardinal.transform(localCardinal.east, refer, localCardinal.getDist(localCardinal.east, _gridSquareBound)* gridEast );
			localCardinal.transform(localCardinal.south, refer, localCardinal.getDist(localCardinal.south, _gridSquareBound) * gridSouth );
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
		
		public static function setMaterialToCont(mat:Material, cont:Object3D):void 
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
					
					_floor._x = eastD * localCardinal.east.x;
					_floor._y = eastD * localCardinal.east.y;
					_floor._x += southD * localCardinal.south.x;
					_floor._y += southD * localCardinal.south.y;
					
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
					
					_floor._x = eastD * localCardinal.east.x;
					_floor._y = eastD * localCardinal.east.y;
					_floor._x += southD * localCardinal.south.x;
					_floor._y += southD * localCardinal.south.y;
					
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
			
			
			public function attemptBuild():Boolean 
			{
				if (getCurBuildableResult() === SaboteurPathUtil.RESULT_VALID) {
					buildAt(gridEast, gridSouth, _value);
					return true;
				}
				return false;
			}
			
			public function attemptRemove():Boolean 
			{
				if (getCurBuildableResult() === SaboteurPathUtil.RESULT_OCCUPIED) {
					removeAt(gridEast, gridSouth);
					return true;
				}
				
				return false;
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
import alternativa.engine3d.objects.MeshSetClone;
import alternativa.engine3d.objects.MeshSetClonesContainer;

class BuildPayload3D {
	public var objects:Vector.<MeshSetClone>
	public var collisionNode:CollisionBoundNode;
	public function BuildPayload3D(objects:Vector.<MeshSetClone>, collisionNode:CollisionBoundNode) {
		this.collisionNode = collisionNode;
		this.objects = objects;
		
	}
	
	public function clearObjects(contHash:Object):void {
		var i:int = objects.length;
		while (--i > -1) {
			var c:MeshSetClone = objects[i];
			(contHash[c.root.name] as MeshSetClonesContainer).removeCloneWithCuller(c);
		}
	}

}