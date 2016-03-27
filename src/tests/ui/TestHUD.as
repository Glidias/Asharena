package tests.ui
{
	import alternativa.a3d.collisions.CollisionBoundNode;
	import alternativa.a3d.collisions.CollisionUtil;
	import alternativa.a3d.controller.SimpleFlyController;
	import alternativa.a3d.controller.ThirdPersonController;
	import alternativa.a3d.cullers.BVHCuller;
	import alternativa.a3d.rayorcollide.TerrainITCollide;
	import alternativa.a3d.rayorcollide.TerrainRaycastImpl;
	import alternativa.a3d.systems.radar.RadarMinimapSystem;
	import alternativa.a3d.systems.text.FontSettings;
	import alternativa.a3d.systems.text.StringLog;
	import alternativa.a3d.systems.text.TextMessageSystem;
	import alternativa.a3d.systems.text.TextSpawner;
	import alternativa.engine3d.alternativa3d;
	import alternativa.engine3d.core.events.MouseEvent3D;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.VertexAttributes;
	import alternativa.engine3d.loaders.ParserA3D;
	import alternativa.engine3d.materials.FillMaterial;
	import alternativa.engine3d.materials.TextureMaterial;
	import alternativa.engine3d.objects.Hud2D;
	import alternativa.engine3d.objects.Mesh;
	import alternativa.engine3d.objects.MeshSetClone;
	import alternativa.engine3d.objects.MeshSetClonesContainer;
	import alternativa.engine3d.objects.MeshSetClonesContainerMod;
	import alternativa.engine3d.objects.Sprite3D;
	import alternativa.engine3d.primitives.Box;
	import alternativa.engine3d.primitives.Plane;
	import alternativa.engine3d.RenderingSystem;
	import alternativa.engine3d.resources.Geometry;
	import alternativa.engine3d.spriteset.materials.MaskColorAtlasMaterial;
	import alternativa.engine3d.spriteset.materials.SpriteSheet8AnimMaterial;
	import alternativa.engine3d.spriteset.materials.TextureAtlasMaterial;
	import alternativa.engine3d.spriteset.SpriteSet;
	import alternativa.engine3d.Template;
	import alternativa.engine3d.utils.GeometryUtil;
	import alternativa.engine3d.utils.Object3DTransformUtil;
	import ash.core.Engine;
	import ash.core.Entity;
	import ash.tick.FrameTickProvider;
	import assets.fonts.ConsoleFont;
	import com.bit101.components.ComboBox;
	import components.Pos;
	import components.Rot;
	import de.polygonal.ds.BitVector;
	import de.polygonal.ds.GraphNode;
	import de.polygonal.motor.geom.primitive.AABB2;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import flash.system.System;
	import flash.ui.Keyboard;
	import hxGeomAlgo.IsoContours;
	import input.KeyPoll;
	import saboteur.models.PlayerInventory;
	import saboteur.spawners.JettySpawner;
	import saboteur.spawners.PickupItemSpawner;
	import saboteur.spawners.SaboteurHud;
	import saboteur.systems.PathBuilderSystem;
	import saboteur.systems.PlayerInventoryControls;
	import saboteur.util.GameBuilder3D;
	import saboteur.util.SaboteurPathUtil;
	import spawners.arena.GladiatorBundle;
	import systems.collisions.EllipsoidCollider;
	import systems.collisions.GroundPlaneCollisionSystem;
	import systems.SystemPriorities;
	import util.SpawnerBundle;
	import util.SpawnerBundleLoader;
	import views.engine3d.MainView3D;
	import views.ui.bit101.BuildStepper;
	import views.ui.bit101.PreloaderBar;
	import views.ui.indicators.CanBuildIndicator;
	import views.ui.UISpriteLayer;
	import alternativa.engine3d.alternativa3d;
	use namespace alternativa3d;
	/**
	 * Third person view and Spectator ghost flyer switching with wall collision against builded paths
	 * @author Glenn Ko
	 */
	public class TestHUD extends MovieClip
	{
		//public var engine:Engine;
		public var ticker:FrameTickProvider;
		public var game:TheGame;
		static public const START_PLAYER_Z:Number = 134;
		
		private var _template3D:MainView3D;
		
		private var uiLayer:UISpriteLayer = new UISpriteLayer();
		private var stepper:BuildStepper;
		private var thirdPerson:ThirdPersonController;
		
		private var bundleLoader:SpawnerBundleLoader;
		private var gladiatorBundle:GladiatorBundle;
		private var jettySpawner:JettySpawner;
		private var arenaSpawner:ArenaSpawner;
		private var _preloader:PreloaderBar = new PreloaderBar();
		
		private var spectatorPerson:SimpleFlyController;
		
		private var borderMeshset:MeshSetClonesContainerMod;
		
		[Embed(source="../../../resources/hud/linesegment2.a3d", mimeType="application/octet-stream")]
		private var LINE_SEGMENT:Class;

		
		public function TestHUD() 
		{
			haxe.initSwc(this);
			addChild(_preloader);
			
			game = new TheGame(stage);
	
			addChild( _template3D = new MainView3D() );
			_template3D.onViewCreate.add(onReady3D);
		//	addChild(uiLayer);
				
			
			_template3D.visible = false;
		}
		
		private function clampGeometryX(geometry:Geometry):void {
			var vec:Vector.<Number>  = geometry.getAttributeValues(VertexAttributes.POSITION);
			
			for (var i:int = 0; i < vec.length; i += 3) {
				vec[i] = Math.round(vec[i ]);
				vec[i+ 1] = Math.round(vec[i + 1]);
				vec[i+2] = Math.round(vec[i + 2]);
			//	if (vec[i] < 0) vec[i] = 0;
				//if (vec[i] > 1) vec[i] = 1;
				
			//	if (vec[i] < 0) vec[i] = 0;
			
			
			}
			//throw new Error(vec);
			geometry.setAttributeValues(VertexAttributes.POSITION, vec);
		}
		
		private function setupDebugMeshContainer():void 
		{
			var mat:FillMaterial = new FillMaterial(0xFF0000, 1);
			debugMeshContainer = new MeshSetClonesContainer(new Box(5, 5, 5, 1, 1, 1, false, mat), mat);
			
						var tileX:Number = gameBuilder._gridSquareBound.maxX *2;
				var tileY:Number = gameBuilder._gridSquareBound.maxY *2;
				SpawnerBundle.uploadResourcesOf(debugMeshContainer);
		
			//debugMeshContainer.x = -tileX * .5;
			//debugMeshContainer.y = tileY * .5;
			debugMeshContainer.z = gameBuilder._gridSquareBound.maxZ - GameBuilder3D.Z_BOUND_PADDING - 83/JettySpawner.SPAWN_SCALE;// (gameBuilder._gridSquareBound.maxZ + gameBuilder._gridSquareBound.minZ) * .5;// gameBuilder._gridSquareBound.maxZ * .5;
			gameBuilder.startScene.addChild(debugMeshContainer);
			
			
		}
		
		private function setupLineDrawer():void { 
				var parserA3D:ParserA3D = new ParserA3D();
			parserA3D.parse( new LINE_SEGMENT() );
			
					var borderItem:Mesh = parserA3D.objects[0] as Mesh || parserA3D.objects[1] as Mesh;
				//clampGeometryX(borderItem.geometry);
				
				var HORIZONTAL_THICKNESS:Number = 8;
				var VERTICAL_THICKNESS:Number = 8;
		//	borderItem.scaleX =HORIZONTAL_THICKNESS/JettySpawner.SPAWN_SCALE;
		//	borderItem.scaleY = HORIZONTAL_THICKNESS/JettySpawner.SPAWN_SCALE;
		//	borderItem.scaleZ = 1 / JettySpawner.SPAWN_SCALE;
			var tileX:Number = gameBuilder._gridSquareBound.maxX *2;
			var tileY:Number = gameBuilder._gridSquareBound.maxY *2;
		
		borderMeshset = new MeshSetClonesContainerMod(borderItem, new FillMaterial(0x00FF00, 1), 38, null, 1|MeshSetClonesContainerMod.FLAG_PREVENT_Z_FIGHTING);
	
		borderMeshset.x = -tileX * .5;
		borderMeshset.y = tileY * .5;
		borderMeshset.z = gameBuilder._gridSquareBound.maxZ - GameBuilder3D.Z_BOUND_PADDING - 83/JettySpawner.SPAWN_SCALE;// (gameBuilder._gridSquareBound.maxZ + gameBuilder._gridSquareBound.minZ) * .5;// gameBuilder._gridSquareBound.maxZ * .5;
		
		borderMeshset.setThicknesses(HORIZONTAL_THICKNESS/JettySpawner.SPAWN_SCALE, VERTICAL_THICKNESS/JettySpawner.SPAWN_SCALE);
		SpawnerBundle.uploadResources(borderMeshset.getResources());
		
			borderMeshset2 = new MeshSetClonesContainerMod(borderItem, new FillMaterial(0xFF0000, 1), 38, null, 1|MeshSetClonesContainerMod.FLAG_PREVENT_Z_FIGHTING);
	
		borderMeshset2.x = -tileX * .5;
		borderMeshset2.y = tileY * .5;
		borderMeshset2.z = gameBuilder._gridSquareBound.maxZ - GameBuilder3D.Z_BOUND_PADDING - 83/JettySpawner.SPAWN_SCALE;// (gameBuilder._gridSquareBound.maxZ + gameBuilder._gridSquareBound.minZ) * .5;// gameBuilder._gridSquareBound.maxZ * .5;
		
		borderMeshset2.setThicknesses(HORIZONTAL_THICKNESS/JettySpawner.SPAWN_SCALE, VERTICAL_THICKNESS/JettySpawner.SPAWN_SCALE);
		SpawnerBundle.uploadResources(borderMeshset2.getResources());  // TODO: re-use geometry from first borderMeshset
		
			// _template3D.scene.addChild(borderMeshset);
		
			 gameBuilder.startScene.addChild(borderMeshset);
			  gameBuilder.startScene.addChild(borderMeshset2);
			 
			 var outliner:Vector.<int>;
			  var total:int;
			  var planeTest:Plane = createOffsetPlane();
			  	SpawnerBundle.uploadResourcesOf(planeTest);
			contPlaneTest = new Object3D();
			contPlaneTest.x = borderMeshset.x;
		contPlaneTest.y = borderMeshset.y;
			contPlaneTest.z = borderMeshset.z;
			
			
			 outliner = getCardinalRadiusOutline(1, true); // new <int>[0,0 , -1,0, -1,1, 0,1, 0,2 ,1,2  ,1,1  ,2,1   ,2,0    ,1,0  ,1,-1   ,0,-1   ]; 
			 total = outliner.length;
				drawOutline(borderMeshset, outliner, total, tileX, tileY, true);
							
				
				 outliner = getCardinalRadiusOutline(MOVEMENT_ALLOWANCE, true);// new <int>[-2,0 , -3,0, -3,1, -2,1, -2,2 , -1,2  ,-1,3  ,0,3   ,0,4,  1,4, 1,3,  2,3, 2,2,  3,2,  3,1,   4,1,  4,0,  3,0,  3,-1,  2,-1, 2,-2,  1,-2,  1,-3,  0,-3,   0,-2,   -1,-2,    -1,-1,  -2,-1  ]; 
				 total = outliner.length;
				drawOutline(borderMeshset2, outliner, total, tileX, tileY, true);
				
					addToCont(createPlanesWithEdgePoints(planeTest, outliner, total, tileX, tileY), contPlaneTest);
				gameBuilder.startScene.addChild(contPlaneTest  );
				contPlaneTest.visible = false;
				 contPlaneGraph = CollisionUtil.getCollisionGraph(contPlaneTest) ;
				//gameBuilder.collisionGraph.addChild(contPlaneGraph);
				var across:int =  1 + MOVEMENT_ALLOWANCE * 2 + 1;

				traversibleContours = new IsoContours(new BitVector(across*across),across);
				
			 
		
		}
		private static var MOVEMENT_ALLOWANCE:Number = 3;
		private var debugMeshContainer:MeshSetClonesContainer;
		
		private var _currentOutlinerPos:Vector3D = new Vector3D();
		
		private function moveOutliners2(ge:int, gs:int):void {
			var startNode:GraphNode = gameBuilder.pathGraph.getNode(ge, gs);
			gameBuilder.pathGraph.graph.clearMarks();
			 gameBuilder.pathGraph.graph.DLBFS(MOVEMENT_ALLOWANCE, false, startNode, dummyProcess); 
		}
		private function moveOutliners(ge:int, gs:int):void {
			/*

			//var lastGridEast:Number = 
			
			var startNode:GraphNode = gameBuilder.pathGraph.getNode(ge, gs);
			gameBuilder.pathGraph.graph.clearMarks();
			//debugMeshContainer.numClones = 0;
			//if (startNode != null) gameBuilder.pathGraph.graph.DFS( false, startNode, processNodeTraversibleDebug); 
			
			debugMeshContainer.numClones = 0;
			borderMeshset.numClones = 0;
			borderMeshset2.numClones = 0;
		
			gameBuilder.pathGraph.graph.DLBFS(MOVEMENT_ALLOWANCE, false, startNode, processNodeTraversibleOutlineTiles); 
		
			
		
			//return;
			*/
			
		//	gameBuilder.setObjectLocally(
			
	//	/*
	
			
			var startNode:GraphNode = gameBuilder.pathGraph.getNode(ge, gs);
			gameBuilder.pathGraph.graph.clearMarks();
			traversibleContours.pixels.setAll();
			//	traversibleContours.pixels.set(MOVEMENT_ALLOWANCE * traversibleContours.width + MOVEMENT_ALLOWANCE);
			gameBuilder.pathGraph.graph.DLBFS(MOVEMENT_ALLOWANCE, false, startNode, flagBitVector); 
			var arrOfPoints:Array = traversibleContours.find();
			
			
			drawContours(arrOfPoints);
			 
			var tileX:Number = gameBuilder._gridSquareBound.maxX * 2;
			var tileY:Number = gameBuilder._gridSquareBound.maxY * 2;
			gameBuilder.setVectorPositionLocally(_currentOutlinerPos,	ge, gs);
			var tarX:Number = -tileX * .5 + _currentOutlinerPos.x;
			var tarY:Number = tileY * .5 + _currentOutlinerPos.y;
	
			borderMeshset.x = tarX ;
			borderMeshset.y = tarY;
			borderMeshset2.x = tarX;
			borderMeshset2.y = tarY;
			contPlaneTest.x = tarX;
			contPlaneTest.y = tarY;
			contPlaneGraph.updateTransform(tarX, tarY, contPlaneTest.z, contPlaneTest.rotationX, contPlaneTest.rotationY, contPlaneTest.rotationZ, contPlaneTest.scaleX, contPlaneTest.scaleY, contPlaneTest.scaleZ);
		//	*/
		}
		
		private function drawContours(arrOfPoints:Array):void 
		{
			borderMeshset2.numClones = 0;
			
			var tileX:Number = gameBuilder._gridSquareBound.maxX * 2;
			var tileY:Number = gameBuilder._gridSquareBound.maxY * 2;
			var i:int = arrOfPoints.length;
			while (--i > -1) {
				var list:Vector.<int> = hxPointToVector(arrOfPoints[i]);
			//	throw new Error("A:"+arrOfPoints[i]);
			//throw new Error(list);
				drawOutline( borderMeshset2, list, list.length, tileX, tileY);
			}
		}
		private function hxPointToVector(arr:Array):Vector.<int> {
			var vec:Vector.<int> = new Vector.<int>(arr.length * 2, true);
			var count:int = 0;
			for (var i:int = 0; i < arr.length; i++) {
				var pt:Object = arr[i];
				vec[count++] = pt.x - MOVEMENT_ALLOWANCE;
				vec[count++] = pt.y - MOVEMENT_ALLOWANCE;
			}
			return vec;
			
			
		}
		
		
		private var outlinePathList:Vector.<int> = new Vector.<int>();
		private var offsetVec:Vector3D = new Vector3D();
		private function drawTile(borderMeshset:MeshSetClonesContainerMod, ge:int, gs:int):void {
				var tileX:Number = gameBuilder._gridSquareBound.maxX * 2;
			var tileY:Number = gameBuilder._gridSquareBound.maxY * 2;
			var count:int = 0;
			gameBuilder.setVectorPositionLocally(offsetVec, ge, gs);
			
			outlinePathList[count++] = 0; outlinePathList[count++] = 1;
				outlinePathList[count++] = 1; outlinePathList[count++] = 1;
			outlinePathList[count++] = 1; outlinePathList[count++] = 0;
			outlinePathList[count++] = 0; outlinePathList[count++] = 0;
			
			drawOutline(borderMeshset, outlinePathList, count, tileX, tileY, true, offsetVec.x, offsetVec.y);
		}
		
		private function drawTile2(borderMeshset:MeshSetClonesContainerMod, ge:int, gs:int):void {
				var tileX:Number = gameBuilder._gridSquareBound.maxX * 2;
			var tileY:Number = gameBuilder._gridSquareBound.maxY * 2;
			var count:int = 0;
			gameBuilder.setVectorPositionLocally(offsetVec, ge, gs);
			
			outlinePathList[count++] = 0; outlinePathList[count++] = 1;
			outlinePathList[count++] = 1; outlinePathList[count++] = 1;
			
			outlinePathList[count++] = 1; outlinePathList[count++] = 1;
			outlinePathList[count++] = 1; outlinePathList[count++] = 0;
			
			outlinePathList[count++] = 1; outlinePathList[count++] = 0;
			outlinePathList[count++] = 0; outlinePathList[count++] = 0;
			
			outlinePathList[count++] = 0; outlinePathList[count++] = 0;
			outlinePathList[count++] = 0; outlinePathList[count++] = 1;
			
			// 0,1, 0,0, 0,0, 1,0, 0,1
			
			drawOutline(borderMeshset, outlinePathList, count, tileX, tileY, true, offsetVec.x, offsetVec.y);
		}
		
		private function processNodeTraversibleDebug(node:GraphNode, preflight:Boolean, data:Object=null):Boolean 
		{
			var clone:MeshSetClone = debugMeshContainer.addNewOrAvailableClone();
			var dataArr:Array = node.val as Array;
			clone.root.scaleX = clone.root.scaleY = node.depth > 1 ? .5 : 1;
			gameBuilder.setObjectLocally( clone.root, dataArr[0], dataArr[1]);
		//	if (node.depth >= MOVEMENT_ALLOWANCE) return false;
			return true;
		}
		private function dummyProcess(node:GraphNode, preflight:Boolean, data:Object=null):Boolean 
		{

			return true;
		}
		
		private function flagBitVector(node:GraphNode, preflight:Boolean, data:Object=null):Boolean 
		{
			var dataArr:Array = node.val as Array;
			traversibleContours.pixels.clr((MOVEMENT_ALLOWANCE  + dataArr[1] ) * traversibleContours.width + (MOVEMENT_ALLOWANCE  + dataArr[0] ));
			traversibleContours.pixels.clr((MOVEMENT_ALLOWANCE + dataArr[1]  +1) * traversibleContours.width + (MOVEMENT_ALLOWANCE + dataArr[0] ));
			traversibleContours.pixels.clr((MOVEMENT_ALLOWANCE  + dataArr[1] ) * traversibleContours.width + (MOVEMENT_ALLOWANCE + dataArr[0] +1));
			traversibleContours.pixels.clr((MOVEMENT_ALLOWANCE  + dataArr[1] +1) * traversibleContours.width + (MOVEMENT_ALLOWANCE + dataArr[0] + 1));
			
			return true;
		}
		private function processNodeTraversibleOutlineTiles(node:GraphNode, preflight:Boolean, data:Object=null):Boolean 
		{
			var dataArr:Array = node.val as Array;
			drawTile2( node.depth > 1 ? borderMeshset2 : borderMeshset, dataArr[0], dataArr[1]);
		//	if (node.depth >= MOVEMENT_ALLOWANCE) return false;
			return true;
		}
		
		public static function createOffsetPlane(height:Number=100):Plane {
			var mat:FillMaterial = new FillMaterial(0x000000, .3);
			var plane:Plane = new Plane(1, height, 1, 1, false , false, mat, mat);
			plane.rotationX = Math.PI * .5;
			plane.x = .5;
			plane.z =height*.5;
			GeometryUtil.globalizeMesh(plane);
			return plane;
		}
		
		public static function addToCont(list:Vector.<Object3D>, cont:Object3D):Object3D {
			var len:int = list.length;
			for (var i:int = 0; i < len; i++) {
				cont.addChild(list[i]);
			}
			return cont;
		}
		
		public static function getCardinalRadiusOutline(radius:int, reverse:Boolean=false):Vector.<int> {
			 var i:int;
			 var vec:Vector.<int> = new Vector.<int>();
			 
			 var quart:int = radius - 1;
			var count:int = 0;
			var dx:int;
			var dy:int; 
			var dx2:int;
			var dy2:int;
			var x:int;
			var y:int;
			
			// north cardinal
			//vec[count++] = 1; vec[count++] =radius;
			vec[count++] =  1; vec[count++] = radius+1;
			vec[count++] =  0; vec[count++] =  radius+1;
			vec[count++] = x = 0; vec[count++] = y = radius; 
			dx = -1; dy = 0;
		    dx2 = 0; dy2 = -1;
			 for (i = 0; i < quart; i++) {
				vec[count++] = x += dx; vec[count++] = y += dy;
				vec[count++] = x += dx2; vec[count++] = y += dy2;
			 }
			
			 
			 // west cardinal
			//vec[count++] = -radius+1; vec[count++] = 1;
			vec[count++] =  -radius; vec[count++]  = 1;
			vec[count++] = -radius; vec[count++]  = 0;
			vec[count++] = x = -radius + 1; vec[count++] = y = 0;
			dx = 0; dy = -1;
		    dx2 = 1; dy2 = 0;
			 for (i = 0; i < quart; i++) {
				vec[count++] = x += dx; vec[count++] = y += dy;
				vec[count++] = x += dx2; vec[count++] = y += dy2;
			 }
			  

			 // south cardinal
			//vec[count++] =  0; vec[count++] = -radius+1;
			vec[count++] = 0; vec[count++] = -radius;
			vec[count++] = 1; vec[count++]  = -radius;
			vec[count++] = x = 1; vec[count++] = y = -radius+1;
			dx = 1; dy = 0;
		    dx2 = 0; dy2 = 1;
			 for (i = 0; i < quart; i++) {
				vec[count++] = x += dx; vec[count++] = y += dy;
				vec[count++] = x += dx2; vec[count++] = y += dy2;
			 }
			 
			 
			  
			 // east cardinal
			//vec[count++] =  radius; vec[count++] = 0;		
			vec[count++] = radius+1; vec[count++] = 0;
			vec[count++] =  radius+1; vec[count++] = 1;
			vec[count++] = x = radius; vec[count++] = y = 1;

			dx = 0; dy = 1;
		    dx2 = -1; dy2 = 0;
			 for (i = 0; i < quart; i++) {
				vec[count++] = x += dx; vec[count++] = y += dy;
				vec[count++] = x += dx2; vec[count++] = y += dy2;
			 }
			 
			
			 return reverse ? vec.reverse() : vec;
		}
		
		
		
		public static function createPlanesWithEdgePoints( toClone:Object3D, outliner:Vector.<int>, total:int, tileX:Number, tileY:Number, loopClose:Boolean=true):Vector.<Object3D> {
			var list:Vector.<Object3D> = new Vector.<Object3D>();
			var clone:Object3D;
				var diagonalEdgeLength:Number = Math.sqrt(tileX * tileX + tileY * tileY);
			var diagonalEdgeLengthX:Number = diagonalEdgeLength / tileX;
			var diagonalEdgeLengthY:Number = diagonalEdgeLength / tileY;
			var limit:int = total;
			var count:int = 0;
			if (!loopClose) limit -= 2;
			var startIndex:int = 0;
		//if (startIndex > 0) startIndex += 1;
			 for (var i:int = 0; i < limit; i+=2) {
					// outliner[i];
					// outliner[i + 1];
					var i2:int;
					
					clone = toClone.clone();
					list[count++] = clone;
					clone.x =  outliner[i] * tileX;
					clone.y =  -outliner[i + 1] * tileY;
					 clone.z =  0;// Math.random() * 11;//
					 
					 i2 = i + 2;
					 if (i2 >= total) {
						 i2 = 0;
					 }
					  var x2:Number= outliner[i2] * tileX;
						 var y2:Number = -outliner[i2 + 1] * tileY;
							x2-= clone.x;
							y2 -= clone.y;
							var d:Number;  // check distance with a particular method
							d = Math.sqrt(x2 * x2 + y2 * y2); // euler distance check
							//d = x2 == 0 || y2 == 0 ? (x2 != 0 ? tileX : tileY) : (x2 != 0 ? diagonalEdgeLengthX*tileX : diagonalEdgeLengthY*tileY);  // 1 tile move assumption check
							
							d = 1 / d;
							x2 *= d;
							y2 *= d;
							
							///*
							clone.rotationZ =  Math.atan2(y2, x2);
							clone.scaleX = 1 / d;
						
				}
				if (!loopClose) {
					startIndex = list.length - 1;// borderMeshset.numClones - 1;
				}
				clone = toClone.clone();
				list[count++] = clone;
			//	clone.root.transform = borderMeshset.clones[0].root.transform;
				
				clone.x = list[startIndex].x;
			 	clone.y = list[startIndex].y;
			 	clone.z =  list[startIndex].z;
				 clone.scaleX = 0;
				  clone.scaleY = 0;
				    clone.scaleZ = 0;
					return list;
		}
		
		
		public static function drawOutline(borderMeshset:MeshSetClonesContainerMod, outliner:Vector.<int>, total:int, tileX:Number, tileY:Number, loopClose:Boolean = true , x:int = 0, y:int=0 ):void {
				var clone:MeshSetClone;
			
				var diagonalEdgeLength:Number = Math.sqrt(tileX * tileX + tileY * tileY);
		var diagonalEdgeLengthX:Number = diagonalEdgeLength / tileX;
		var diagonalEdgeLengthY:Number = diagonalEdgeLength / tileY;
		var limit:int = total;
		if (!loopClose) limit -= 2;
		var startIndex:int = ( borderMeshset.numClones );
	//if (startIndex > 0) startIndex += 1;
			 for (var i:int = 0; i < limit; i+=2) {
					// outliner[i];
					// outliner[i + 1];
					var i2:int;
					
					clone = borderMeshset.addNewOrAvailableClone();
					clone.root.x = x+  outliner[i] * tileX;
					clone.root.y =  y+ -outliner[i + 1] * tileY;
					 clone.root.z =  0;// Math.random() * 11;//
					 
					 i2 = i + 2;
					 if (i2 >= total) {
						 i2 = 0;
					 }
					  var x2:Number= x+ outliner[i2] * tileX;
						 var y2:Number =y+ -outliner[i2 + 1] * tileY;
							x2-= clone.root.x;
							y2 -= clone.root.y;
							var d:Number;  // check distance with a particular method
							d = Math.sqrt(x2 * x2 + y2 * y2); // euler distance check
							//d = x2 == 0 || y2 == 0 ? (x2 != 0 ? tileX : tileY) : (x2 != 0 ? diagonalEdgeLengthX*tileX : diagonalEdgeLengthY*tileY);  // 1 tile move assumption check
							
							d = 1 / d;
							x2 *= d;
							y2 *= d;
							
							///*
							clone.root.rotationZ =  Math.atan2(y2, x2);
							clone.root.scaleX = 1 / d;
						
				}
				if (!loopClose) {
					startIndex = borderMeshset.numClones-1;
				}
				clone = borderMeshset.addNewOrAvailableClone();
			//	clone.root.transform = borderMeshset.clones[0].root.transform;
				
				clone.root.x = borderMeshset.clones[startIndex].root.x;
			 	clone.root.y = borderMeshset.clones[startIndex].root.y;
			 	clone.root.z =  borderMeshset.clones[startIndex].root.z;
				 clone.root.scaleX = 0;
				  clone.root.scaleY = 0;
				    clone.root.scaleZ = 0;
			
				
		}
		
		
		
		private function onReady3D():void 
		{
			
			
			SpawnerBundle.context3D = _template3D.stage3D.context3D;
			
			gladiatorBundle = new GladiatorBundle(arenaSpawner = new ArenaSpawner(game.engine, game.keyPoll));
			jettySpawner = new JettySpawner();
			
			hudAssets = new SaboteurHud(game.engine, stage, game.keyPoll);
			pickupSpawner = new PickupItemSpawner(game.engine);
			
			bundleLoader = new SpawnerBundleLoader(stage, onSpawnerBundleLoaded, new <SpawnerBundle>[gladiatorBundle, jettySpawner, hudAssets, pickupSpawner]);
			bundleLoader.progressSignal.add( _preloader.setProgress );
			bundleLoader.loadBeginSignal.add( _preloader.setLabel );
		}
		
		private function onSpawnerBundleLoaded():void 
		{
			//game.gameStates.engineState.changeState("thirdPerson");
				
			_template3D.visible = true;
			removeChild(_preloader);			
			game.engine.addSystem( new RenderingSystem(_template3D.scene), SystemPriorities.render );
			

			
		
			gladiatorBundle.arenaSpawner.addGladiator(ArenaSpawner.RACE_SAMNIAN, stage, 0, 0, START_PLAYER_Z + 33).add( game.keyPoll );
		
		
			
			
			pathBuilder = new PathBuilderSystem(_template3D.camera);
			 pathBuilder.onPositionTileChange.add(onPositionTileChange);
			game.gameStates.thirdPerson.addInstance(pathBuilder).withPriority(SystemPriorities.render);
			//game.engine.addSystem(pathBuilder, SystemPriorities.postRender );
			pathBuilder.signalBuildableChange.add( onBuildStateChange);
			var canBuildIndicator:CanBuildIndicator = new CanBuildIndicator();
			addChild(canBuildIndicator);
			pathBuilder.onEndPointStateChange.add(canBuildIndicator.setCanBuild);
			
		
	
			thirdPerson = new ThirdPersonController(stage, _template3D.camera, new Object3D(), arenaSpawner.currentPlayer, arenaSpawner.currentPlayer, arenaSpawner.currentPlayerEntity);
			//game.engine.addSystem( thirdPerson, SystemPriorities.postRender ) ;
			game.gameStates.thirdPerson.addInstance(thirdPerson).withPriority(SystemPriorities.postRender);
			
		
			game.engine.addSystem(new TextMessageSystem(), SystemPriorities.render );
			game.gameStates.thirdPerson.addInstance( new GroundPlaneCollisionSystem(102, true) ).withPriority(SystemPriorities.resolveCollisions);
			
			BVHCuller;
		
			
			
			uiLayer.addChild( stepper = new BuildStepper());
			stepper.onBuild.add(pathBuilder.attemptBuild);
			stepper.onStep.add(pathBuilder.setBuildIndex);
			stepper.onDelete.add(pathBuilder.attemptDel);
			
			ticker = new FrameTickProvider(stage);
			ticker.add(tick);
			ticker.start();
			
		
			//_template3D.camera.orthographic = true;
			_template3D.camera.addChild( hud = new Hud2D() );
			hud.z = 1.1;
			
	

			
			_template3D.viewBackgroundColor = 0xDDDDDD;
	
		
			
			spriteSet = hudAssets.txt_chat.spriteSet;
			
				var bitmapData:BitmapData = jettySpawner.createBlueprintSheet(_template3D.camera, _template3D.stage3D, hud);
			//	addChild( new Bitmap(bitmapData));
				GameBuilder3D
				//jettySpawner.minimap.createJettyAt(0, 0, SaboteurPathUtil.getInstance().getIndexByValue(63),  );
				
				jettySpawner.minimap.addToContainer( hudAssets.radarGridHolder);
				jettySpawner.minimap.setCuller(hudAssets.circleRadarCuller);
			
				
			
			var ent:Entity = jettySpawner.spawn(game.engine,_template3D.scene, arenaSpawner.currentPlayerEntity.get(Pos) as Pos);

			jettySpawner.minimap.createJettyWithBuilder(63, (gameBuilder=ent.get(GameBuilder3D) as GameBuilder3D) );
			pathBuilder.onBuildSucceeded.add(jettySpawner.minimap.createJettyWithBuilder);
			pathBuilder.onBuildSucceeded.add(onBuildUpdateBorder);
			pathBuilder.onDelSucceeded.add(jettySpawner.minimap.removeJettyWithBuilder);
			
		

			var playerControls:PlayerInventoryControls = new PlayerInventoryControls(game.keyPoll, new PlayerInventory(), hudAssets, pathBuilder, jettySpawner.minimap, stage);
			game.gameStates.thirdPerson.addInstance(playerControls).withPriority(SystemPriorities.preRender);
			
			if (game.colliderSystem) {
				
				game.colliderSystem.collidable = (ent.get(GameBuilder3D) as GameBuilder3D).collisionGraph;
				game.colliderSystem._collider.threshold = 0.00001;
			}
			
			TerrainITCollide;
			TerrainRaycastImpl;
			
			spectatorPerson =new SimpleFlyController( 
						new EllipsoidCollider(GameSettings.SPECTATOR_RADIUS.x, GameSettings.SPECTATOR_RADIUS.y, GameSettings.SPECTATOR_RADIUS.z), 
						(ent.get(GameBuilder3D) as GameBuilder3D).collisionGraph ,
						stage, 
						_template3D.camera, 
							30*512*256/60/60, //GameSettings.SPECTATOR_SPEED,
						GameSettings.SPECTATOR_SPEED_SHIFT_MULT);
			
						game.gameStates.spectator.addInstance(spectatorPerson).withPriority(SystemPriorities.postRender);
						
						var radarSystem:RadarMinimapSystem;
						
			game.engine.addSystem(radarSystem = new RadarMinimapSystem( 1 / JettySpawner.SPAWN_SCALE * jettySpawner.minimap.pixelToMinimapScale, hudAssets.radarHolder, arenaSpawner.currentPlayerEntity.get(Rot) as Rot,  _template3D.camera, hudAssets.radarGridHolder, arenaSpawner.currentPlayerEntity.get(Pos) as Pos, _template3D.camera, hudAssets.radarGridMaterial.gridCoordinates, (ent.get(GameBuilder3D) as GameBuilder3D).startScene, hudAssets.radarGridSprite), SystemPriorities.preRender);
			radarSystem.setGridPixels(32, JettySpawner.H);
			
			
			game.gameStates.thirdPerson.addInstance(jettySpawner.minimap).withPriority(SystemPriorities.postRender);
			
			
			hudAssets.addToHud3D(hud);
			hudAssets.txt_chatChannel.appendSpanTagMessage('The quick brown <span u="2">fox</span> jumps over the lazy dog. The <span u="1">quick brown fox</span> jumps over the lazy <span u="3">dog</span>. The <span u="1">quick brown fox</span> jumps over the lazy dog.');
			setupLineDrawer();
			setupDebugMeshContainer();
		
			game.gameStates.engineState.changeState("thirdPerson");
			jettySpawner.minimap.setupBuildModelAndView(pathBuilder, pathBuilder.getCurBuilder(), hudAssets.radarBlueprintOverlay);  //
		
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false,1);
		
		}
		
	
		
		private function onBuildUpdateBorder(value:uint, builder:GameBuilder3D ):void 
		{
			updateToCurrentPos();
		//	hudAssets.txt_chatChannel.appendMessage("You've built a path!");
		}
		
		private function updateToCurrentPos():void 
		{
			_lastES.x = pathBuilder.lastGe;
			_lastES.y = pathBuilder.lastGs;
			moveOutliners(pathBuilder.lastGe, pathBuilder.lastGs);
		}
		
		private var _lastES:Point = new Point();
		private var _foundWithinRange:Boolean = false;
		private function onPositionTileChange(ge:int, gs:int ):void 
		{
			/*
			var rootNode:GraphNode = gameBuilder.pathGraph.getNode(ge, gs);
			gameBuilder.pathGraph.graph.clearMarks();
			
		hudAssets.txt_chatChannel.appendMessage("moved:"+Math.random());
			
			if (rootNode != null) {
				var startNode:GraphNode = gameBuilder.pathGraph.getNode(_lastES.x, _lastES.y);
				if (startNode != null) {
						_foundWithinRange = false;
					gameBuilder.pathGraph.graph.DLBFS(MOVEMENT_ALLOWANCE, false, rootNode, checkIfNodeIsWithinRange, startNode); 
					if (!_foundWithinRange) {
						_lastES.x = pathBuilder.lastGe;
						_lastES.y = pathBuilder.lastGs;
						moveOutliners(pathBuilder.lastGe, pathBuilder.lastGs);
					}
				}
			}
			*/
			
		//	/*
			if (getCardinalDist(ge, gs, _lastES) > MOVEMENT_ALLOWANCE) {
				_lastES.x = pathBuilder.lastGe;
				_lastES.y = pathBuilder.lastGs;
				moveOutliners(pathBuilder.lastGe, pathBuilder.lastGs);
		
			}
		//	*/
		}
		
		private function checkIfNodeIsWithinRange(node:GraphNode, preflight:Boolean, data:Object=null):Boolean 
		{
			
			
			
			if (node === data) {
				_foundWithinRange = true;
				return false;
			}
			
		
			return true;
		}
		
		
		private function getCardinalDist(ge:int, gs:int, pt:Point):int {
			ge -= pt.x;
			ge = ge < 0 ? -ge : ge;
			gs -= pt.y;
			gs = gs < 0 ? -gs : gs;
			return ge + gs;
		}
		
		
		
		
		
		private function trim( s:String ):String
{
  return s.replace( /^([\s|\t|\n]+)?(.*)([\s|\t|\n]+)?$/gm, "" );
}
		
		
		
		private var _isThirdPerson:Boolean = true;
		private var spriteSet:SpriteSet;
		private var hudAssets:SaboteurHud;
		private var hud:Hud2D;
		private var pickupSpawner:PickupItemSpawner;
		private var gameBuilder:GameBuilder3D;
		private var borderMeshset2:MeshSetClonesContainerMod;
		private var contPlaneTest:Object3D;
		private var contPlaneGraph:CollisionBoundNode;
		private var pathBuilder:PathBuilderSystem;
		private var traversibleContours:IsoContours;
		
		private function onKeyDown(e:KeyboardEvent):void 
		{
				
			if (!game.keyPoll.disabled) {
				if (e.keyCode === Keyboard.L &&   !game.keyPoll.isDown(Keyboard.L)) { // && 
					
					_isThirdPerson = !_isThirdPerson;
					game.gameStates.engineState.changeState(_isThirdPerson ? "thirdPerson" : "spectator");
					
				}
				
				if (e.keyCode === Keyboard.U &&   !game.keyPoll.isDown(Keyboard.U)) { // && 
					
					if (	hudAssets.txt_chatChannel.getShowItems() == 5) {
						hudAssets.txt_chatChannel.setShowItems(12);
					}
					else hudAssets.txt_chatChannel.setShowItems(5);
				
				}
				
				if (e.keyCode === Keyboard.PAGE_UP &&   !game.keyPoll.isDown(Keyboard.PAGE_UP) ) {
					hudAssets.txt_chatChannel.scrollUpHistory();
				}
				else if (e.keyCode === Keyboard.PAGE_DOWN &&   !game.keyPoll.isDown(Keyboard.PAGE_DOWN)) {
					hudAssets.txt_chatChannel.scrollDownHistory();
				}
				else if  (e.keyCode === Keyboard.END &&   !game.keyPoll.isDown(Keyboard.END)) {
					hudAssets.txt_chatChannel.scrollEndHistory();
				}
				else if  (e.keyCode === Keyboard.BACKSPACE &&   !game.keyPoll.isDown(Keyboard.BACKSPACE)) {
					updateToCurrentPos();
				}
				
				if (e.keyCode === Keyboard.BACKSLASH &&   !game.keyPoll.isDown(Keyboard.BACKSLASH)) { // && 
					hudAssets.txt_chatChannel.resetAllScrollingMessages();
					/*
					if (	hudAssets.txt_chatChannel.getShowItems() == 5) {
						hudAssets.txt_chatChannel.setShowItems(12);
					}
					else hudAssets.txt_chatChannel.setShowItems(5);
				*/
				}
			}
			if (e.keyCode === Keyboard.F11) {
				System.pauseForGCIfCollectionImminent();
				
			}
			else if (e.keyCode === Keyboard.NUMPAD_ADD) {
				borderMeshset.increaseThicknesses(1/JettySpawner.SPAWN_SCALE, 1/JettySpawner.SPAWN_SCALE);
			}
			else if (e.keyCode === Keyboard.NUMPAD_SUBTRACT) {
				borderMeshset.increaseThicknesses(-1/JettySpawner.SPAWN_SCALE, -1/JettySpawner.SPAWN_SCALE);
			}
		
		}
		
	
		
		private function tick(time:Number):void {
			
			game.engine.update(time);
			_template3D.render();
		}
		
		private function onBuildStateChange(result:int):void 
		{
			stepper.buildBtn.enabled = result === SaboteurPathUtil.RESULT_VALID;
			stepper.delBtn.enabled = result === SaboteurPathUtil.RESULT_OCCUPIED;
		}
		
		
		
	}

}