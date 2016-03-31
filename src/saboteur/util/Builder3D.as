package saboteur.util 
{
	import alternativa.a3d.collisions.CollisionBoundNode;
	import alternativa.a3d.collisions.CollisionUtil;
	import alternativa.a3d.cullers.BVHCuller;
	import alternativa.engine3d.alternativa3d;
	import alternativa.engine3d.core.BoundBox;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.Transform3D;
	import alternativa.engine3d.core.VertexAttributes;
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
	import ash.signals.SignalAny;
	import flash.display3D.Context3D;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Transform;
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;
	import flash.utils.getDefinitionByName;
	import alternativa.engine3d.alternativa3d;
	import ash.signals.Signal2;
	import haxe.Log;
	import util.geom.Vec3;
	use namespace alternativa3d;
	
	/**
	 * Refactored GameBuilder3D with better sepeartion of concerns. Alternativa3D specific class.
	 * @author Glenn Ko
	 */
	public class Builder3D 
	{
		private var gameBuilder:GameBuilder;
		
		private var applyMaterial:Material;
		public var startScene:Object3D;
		public var genesis:Object3D;
		public var collision:Object3D;
		public var blueprint:Object3D;
		
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
		static public const Z_BOUND_PADDING:Number = 45;
		
		public var _gridSquareBound:BoundBox;
	
		alternativa3d var gridEastWidth:Number = 1;
		alternativa3d var gridSouthWidth:Number = 1;
		alternativa3d var gridEastWidth_i:Number = 1;
		alternativa3d var gridSouthWidth_i:Number = 1;
		
		// projected blueprint grid-build position
		private var gridBuildAt:Point = new Point();
		public function get floorGridEast():int {
			return gridBuildAt.x;
		}
		public function get floorGridSouth():int {
			return gridBuildAt.y;
		}
		
		alternativa3d var _floor:Object3D;
		public var collisionScene:Object3D;
		
		private var _value:uint;
		private var startEditorAlpha:Number;
		private var _boundGridBoxConvex3D:CollisionBoundNode;
		public var minSquareBuildDistance:Number;
		
		public var collisionGraph:CollisionBoundNode;
		public var showOccupied:Boolean = false;
		
		private var pathUtil:SaboteurPathUtil;

		
		public function Builder3D(gameBuilder:GameBuilder, startScene:Object3D, genesis:Object3D, blueprint:Object3D, collision:Object3D, applyMaterial:Material, editorMat:FillMaterial, floor:Plane) 
		{
			this.gameBuilder = gameBuilder;
			gameBuilder.onBuildMade.add(onBuildMade);
			gameBuilder.onRemoved.add(onRemovedPath);
			
			var startSceneMatrix:Matrix3D = startScene.matrix;
			/*
			var matrixer:Matrix3D =startSceneMatrix.clone();
			matrixer.invert();
			var localStartOffset:Vector3D =matrixer.deltaTransformVector( new Vector3D(startOffsetX, startOffsetY, 0) );
			startOffsetXLocal = localStartOffset.x;// startOffsetX / startScene._scaleX;
			startOffsetYLocal = localStartOffset.y ;// startOffsetY / startScene._scaleY;
			*/
			
			startScene.composeTransforms();
			
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
			

			blueprint.visible = false;
				_floor = floor;
			//this.startScene.addChild(genesis);
			this.startScene.addChild(blueprint);
		
			
			
			
			
			refreshValue();
			
			setup();
			
		}
		
		
		private function setup():void 
		{
			var bounds:BoundBox;
			_gridSquareBound = bounds = genesis.boundBox.clone();  // new BoundBox();  // we assume already set up correctly for now, even though there mayh be slight discrepancy
		
			var xd:Number = bounds.maxX - bounds.minX;
			var yd:Number = bounds.maxY - bounds.minY;
				 _floor.scaleX = xd;
			 _floor.scaleY = yd;
			
	
				_gridSquareBound.maxZ += Z_BOUND_PADDING;
				_gridSquareBound.minZ -= Z_BOUND_PADDING;
				
				_boundGridBoxConvex3D = CollisionUtil.getCollisionGraph(new Box((_gridSquareBound.maxX - _gridSquareBound.minX), (_gridSquareBound.maxY - _gridSquareBound.minY), (_gridSquareBound.maxZ - _gridSquareBound.minZ) ) );
				
				collisionGraph._prepend(_boundGridBoxConvex3D);
				
			
			gridEastWidth  =localCardinal.getDist(localCardinal.east, _gridSquareBound, 1);
			gridSouthWidth = localCardinal.getDist(localCardinal.south, _gridSquareBound, 1);
			minSquareBuildDistance = gridEastWidth * gridEastWidth + gridSouthWidth * gridSouthWidth;

				
			gridEastWidth_i = 1 / gridEastWidth;
			gridSouthWidth_i = 1 / gridSouthWidth;
			
		
			this.startScene.addChild(_floor);
		}
		
		private function refreshValue():void {
		   for (var c:Object3D = blueprint.childrenList; c != null; c = c.next) {
				 c.visible = pathUtil.visJetty(_value, c.name);
			 }
		}
		
		
	
		
			private static function checkIdentityRotScale(obj:Object3D):void {
			if (obj._rotationX != 0 || obj._rotationZ != 0 || obj._rotationY != 0 || obj._scaleX != 1 || obj._scaleY != 1 || obj._scaleZ != 1) throw new Error("not normalized Rot scale meshes!:" + (new Vector3D(obj._rotationX, obj._rotationY, obj._rotationZ) ));
		}
		
		
		private static function globalizeMesh(mesh:Mesh):void {
			if (mesh.transformChanged) mesh.composeTransforms();
			var vertices:Vector.<Number> = mesh.geometry.getAttributeValues(VertexAttributes.POSITION);
			var len:int = vertices.length;
			var t:Transform3D = mesh.transform;
			for (var i:int = 0; i < len; i += 3) {
				var x:Number = vertices[i];
				var y:Number = vertices[i+1];
				var z:Number = vertices[i + 2];
				vertices[i] = t.a * x + t.b * y + t.c * z + t.d;
				vertices[i+1] = t.e * x + t.f * y + t.g * z + t.h;
				vertices[i+2] = t.i * x + t.j * y + t.k * z + t.l;
				
			}
			
			mesh._x = 0;
			mesh._y = 0;
			mesh._z = 0;
			mesh._rotationX = 0;
			mesh._rotationY = 0;
			mesh._rotationZ = 0;
				mesh._scaleX = 1;
			mesh._scaleY = 1;
			mesh._scaleZ = 1;
			
			mesh.composeTransforms();
			
			
			mesh.geometry.setAttributeValues(VertexAttributes.POSITION, vertices);
			
			mesh.boundBox = Object3DUtils.calculateHierarchyBoundBox(mesh);
		}

		private static var MESH_SETS:Object = { };
		public static function addMeshSetsToScene(scene:Object3D, sampleBlueprint:Object3D, material:Material, startScene:Object3D, context3D:Context3D):void {
			var meshSet:MeshSetClonesContainer;
			const meshSetHash:Object = MESH_SETS;
			//checkIdentityRotScale(scene);
			

			
		
			for (var c:Object3D = sampleBlueprint.childrenList; c != null; c = c.next) {
				var mesh:Mesh = c as Mesh;
				if (mesh != null) {
					mesh = mesh.clone() as Mesh;	
					globalizeMesh(mesh);
					meshSetHash[c.name] = meshSet = new MeshSetClonesContainer( mesh, material);
					meshSet.name = c.name + "_meshset";
					meshSet.geometry.upload(context3D);
					meshSet.culler = new BVHCuller(meshSet);  
					//meshSet.culler = new BoundingBoxCuller();
				}
			}
			
			//var count:int = 0;
			for (var prop:String in meshSetHash) {
				scene.addChild(meshSetHash[prop]);
				//	count++;
			}
			//throw new Error(count + " meshsets.");
		}
		
		private function onBuildMade(value:uint, gameBuilder:GameBuilder, gridEast:int, gridSouth:int):void 
		{
			//if ( (gameBuilder.signalFlags & GameBuilder.FLAG_ATTEMPTED) )
			var key:uint = pathUtil.getGridKey(gridEast, gridSouth);
			var payload:BuildPayload3D = build3DGrid[key];	
			if (payload == null) return;
			collisionGraph.removeChild(payload.collisionNode);
			//startScene.removeChild(payload.object);
			payload.clearObjects(MESH_SETS);

			delete build3DGrid[key];
			
		}
		
		private function onRemovedPath(gridEast:int, gridSouth:int):void {
			//if ( (gameBuilder.signalFlags & GameBuilder.FLAG_ATTEMPTED) )
			
			
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