package tests.pvp
{
	import alternativa.a3d.controller.SimpleFlyController;
	import alternativa.a3d.objects.LineSegmentSet;
	import alternativa.engine3d.alternativa3d;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.Transform3D;
	import alternativa.engine3d.core.VertexAttributes;
	import alternativa.engine3d.loaders.ParserA3D;
	import alternativa.engine3d.materials.FillMaterial;
	import alternativa.engine3d.materials.FogMode;
	import alternativa.engine3d.materials.Material;
	import alternativa.engine3d.materials.NormalMapSpace;
	import alternativa.engine3d.materials.StandardMaterial;
	import alternativa.engine3d.materials.StandardTerrainMaterial;
	import alternativa.engine3d.objects.Mesh;
	import alternativa.engine3d.objects.MeshSet;
	import alternativa.engine3d.objects.MeshSetClone;
	import alternativa.engine3d.objects.MeshSetClonesContainer;
	import alternativa.engine3d.objects.MeshSetClonesContainerMod;
	import alternativa.engine3d.primitives.Box;
	import alternativa.engine3d.primitives.Plane;
	import alternativa.engine3d.RenderingSystem;
	import alternativa.engine3d.resources.BitmapTextureResource;
	import alternativa.engine3d.resources.Geometry;
	import alternterrain.core.HeightMapInfo;
	import alternterrain.core.QuadTreePage;
	import alternterrain.objects.TerrainLOD;
	import arena.pathfinding.GKEdge;
	import arena.pathfinding.GraphGrid;
	import ash.tick.FrameTickProvider;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.KeyboardEvent;
	import flash.geom.Point;
	import flash.geom.Transform;
	import flash.geom.Vector3D;
	import flash.ui.Keyboard;
	import systems.collisions.EllipsoidCollider;
	import systems.SystemPriorities;
	import util.SpawnerBundle;
	import views.engine3d.MainView3D;
	import alternativa.engine3d.alternativa3d;
	use namespace alternativa3d;
	/**
	 * ...
	 * @author Glidias
	 */
	public class TestDots3D extends MovieClip 
	{
		private var _template3D:MainView3D;
		private var game:TheGame;
		private var ticker:FrameTickProvider;
		
		static public const GRID_SIZE:Number = 32;
		public var MOVEMENT_POINTS:Number = 15 * 2;
		public var HEIGHTMAPMULT:Number =  100;
		
		private var _across:int = 80;
		private var _graphGrid:GraphGrid;
		private var _arrDots:Array = [];
		
		private var _x:int = -1;
		private var _y:int = -1;
		
		private var startPt:Sprite;
		
		private var heightMap:BitmapData;
		private var heightBmp:Bitmap;
		private var heightMapData:Vector.<int> = new Vector.<int>();
		
		private var startBox:Mesh;
		private var outliner:Vector.<int> = new Vector.<int>();
		
		
		private var _lock:Boolean = false;
		
		private var borderMeshset:MeshSetClonesContainerMod;
		
		[Embed(source="../../../resources/hud/linesegment2.a3d", mimeType="application/octet-stream")]
		private var LINE_SEGMENT:Class;
		
		public function TestDots3D() 
		{
			haxe.initSwc(this);
		
			MeshSetClonesContainerMod;
			 Transform3D
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			game = new TheGame(stage);
	
			addChild( _template3D = new MainView3D() );
			_template3D.onViewCreate.add(onReady3D);
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
				
			setup();
		}
		
		private function onKeyDown(e:KeyboardEvent):void 
		{
			if (e.keyCode === Keyboard.P) {
				_lock = !_lock;
			}
		}
		
		private function setup():void {
			heightMap = new BitmapData(_across, _across, false, 0);
			heightMap.perlinNoise(_across / 1, _across / 1, 4, 440, false, true, 7, true);
			addChild(heightBmp =  new Bitmap(heightMap));
			heightBmp.smoothing = true;
			heightBmp.scaleX = GRID_SIZE;
			heightBmp.scaleY = GRID_SIZE;
		
			
			_graphGrid = new GraphGrid(_across);
			for (var y:int = 0; y < _across; y++) {
				for (var x:int = 0; x < _across; x++) {
					var spr:Sprite = new Sprite();
					spr.x = GRID_SIZE * x;
					spr.y = GRID_SIZE * y;
					spr.graphics.beginFill(0x0000FF, 1);
					spr.graphics.drawCircle(0, 0, 8);
					_arrDots.push(spr);
					addChild(spr);
				}
			}

			setupHeightmap();
			
			spr = startPt = new Sprite();
			spr.graphics.beginFill(0xFF0000, 1);
			spr.graphics.drawCircle(0, 0, 5);
			addChild(spr);
			
		
		}
		
		private function setupHeightmap():void 
		{

			var samples:Vector.<uint> = heightMap.getVector(heightMap.rect);
			
			heightMapData.length = samples.length;
			var i:int;
			var len:int = samples.length;
			for (i = 0; i < len; i++) {
				heightMapData[i] =  ((samples[i] & 0x0000FF) * HEIGHTMAPMULT);// .1115;
			}
			
			
			_graphGrid.sampleHeightmap(heightMapData, 256 );
			
			//| GKEdge.FLAG_GRADIENT_UNSTABLE | GKEdge.FLAG_CLIFF
			_graphGrid.djTraversal.edgeDisableMask = GKEdge.FLAG_INVALID;
			
		}
		
		
		private function onReady3D():void 
		{
			SpawnerBundle.context3D = _template3D.stage3D.context3D;
			
			_template3D.scene.scaleX = .25;
			_template3D.scene.scaleY = .25;
			_template3D.scene.scaleZ = .25;
			game.engine.addSystem( new RenderingSystem(_template3D.scene), SystemPriorities.render );

			
			var spectatorPerson:SimpleFlyController =new SimpleFlyController( 
						new EllipsoidCollider(GameSettings.SPECTATOR_RADIUS.x, GameSettings.SPECTATOR_RADIUS.y, GameSettings.SPECTATOR_RADIUS.z), 
						null ,
						stage, 
						_template3D.camera, 
						GameSettings.SPECTATOR_SPEED,
						GameSettings.SPECTATOR_SPEED_SHIFT_MULT);
			
						game.gameStates.spectator.addInstance(spectatorPerson).withPriority(SystemPriorities.postRender);
		
	
			
			game.engine.addSystem( spectatorPerson, SystemPriorities.postRender ) ;
		
		
			ticker = new FrameTickProvider(stage);
			ticker.add(tick);
			ticker.start();
			
			
			replace2D();
			
			
			
	
		spectatorPerson.setObjectPosXYZ(256*_across*.5, -256*_across*.5, 1000+HEIGHTMAPMULT*255);
		spectatorPerson.lookAtXYZ(256 * _across * .5, -256 * _across * .5, 0);
		
		spectatorPerson.speedMultiplier = 8;
			
			
		}
		
		private function replace2D():void 
		{
			
			//alpha = .25;
			
			removeChild(startPt);
			removeChild(heightBmp);
			
			startBox = new Box(256*2,256*2,  256*2,256*2*(72/32) ,1,1,false, new FillMaterial(0xFF0000, .5));
			_template3D.scene.addChild(startBox);
			
			LineSegmentSet;
			
			var parserA3D:ParserA3D = new ParserA3D();
			parserA3D.parse( new LINE_SEGMENT() );
			//;
			
			var i:int = _arrDots.length;
			StandardMaterial.fogMode = FogMode.SIMPLE;
			StandardMaterial.fogColorR = .12;
			StandardMaterial.fogColorG = .12;
			StandardMaterial.fogColorB = .12;
			StandardMaterial.fogNear = 1;
			StandardMaterial.fogFar = 13000;
			var box:Box = new Box(16, 16, 1, 1, 1, 1, false, new StandardMaterial( new BitmapTextureResource( new BitmapData(4,4,false,0x00FF00)), new BitmapTextureResource( new BitmapData(4,4,false,0x0000FF))));
			var boxClones:MeshSetClonesContainer = new MeshSetClonesContainer(box, box.getSurface(0).material );
		//	_template3D.scene.addChild(boxClones);
			
			//
			var borderItem:Mesh = parserA3D.objects[0] as Mesh || parserA3D.objects[1] as Mesh;
			
			borderItem.scaleX = 88;
			borderItem.scaleY = 88;
			borderItem.scaleZ = 88;
			
			
			//new Box(100,100,42,1,1,1)
			// | MeshSetClonesContainer.FLAG_PREVENT_Z_FIGHTING)
				borderMeshset = new MeshSetClonesContainerMod(borderItem, new FillMaterial(0x00FF00, 1), 0, null, 1);
				borderMeshset.setThicknesses(88, 88);
			_template3D.scene.addChild(borderMeshset);
			
			
			boxClones.scaleX = boxClones.scaleY = 256 / GRID_SIZE;
			while (--i > -1) {
				var boxClone:MeshSetClone = boxClones.addClone( boxClones.createClone() );
				boxClone.root.x = _arrDots[i].x ;
				boxClone.root.y = -_arrDots[i].y ;
				
			
				removeChild(_arrDots[i]);
				_arrDots[i] = boxClone.root;
			}
			
				var plane:Plane = new Plane((_across + 1) * GRID_SIZE, (_across + 1) * GRID_SIZE, _across + 1, _across + 1, false, false, null, box.getSurface(0).material);
		
			//	/*
			var terrainLOD:TerrainLOD = new TerrainLOD();
			var terrainMat:StandardTerrainMaterial =  new StandardTerrainMaterial(  new BitmapTextureResource(new BitmapData(4, 4, false, 0x0000FF)), new BitmapTextureResource( new BitmapData(4, 4, false, 0x0000FF)))
			terrainMat.normalMapSpace = NormalMapSpace.OBJECT;
			terrainMat.alphaThreshold = .999;
			terrainMat.alpha = .4;
			//QuadTreePage.createFlat(0, 0, _across, 256),
		//	QuadTreePage.createFlat(0, 0, _across, 256),
		
			var heightMapForTerrain:BitmapData = new BitmapData(128, 128, false, 0);
			heightMapForTerrain.copyPixels(heightMap, heightMap.rect, new Point());
			terrainLOD.loadSinglePage( SpawnerBundle.context3D, TerrainLOD.installQuadTreePageFromHeightMap(HeightMapInfo.createFromBmpData(heightMapForTerrain, 0, 0, HEIGHTMAPMULT, 0, 256), 0, 0, 256, 0),   terrainMat);
			terrainLOD.debug = true;
				_template3D.scene.addChild(terrainLOD);
			//	*/
				
			for (var y:int = 0; y < _across; y++) {
				for (var x:int = 0; x < _across; x++) {
					_arrDots[y * _across + x].z = heightMapData[y*_across+x] ;
				}
			}
			
			setupTerrainLighting();
		
			
			SpawnerBundle.uploadResources(_template3D.scene.getResources(true));
		}
		
		private function setupTerrainLighting():void {
			 //   _template3D.directionalLight.x = 0;
         //  _template3D.directionalLight.y = -100;
        //   _template3D. directionalLight.z = -100;
			_template3D.directionalLight.x = 44;
             _template3D.directionalLight.y = -100;
             _template3D.directionalLight.z = 100;
             _template3D.directionalLight.lookAt(0, 0, 0);
			 _template3D.directionalLight.intensity = .65;
			 
			
             _template3D.ambientLight.intensity = 0.4;
           
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
		
		private function tick(time:Number):void 
		{
			var across:int = _across;
			var x:int = Math.round( _template3D.camera.x / 256 );
			var y:int = Math.round( -_template3D.camera.y / 256 );
			x = x >= _across ? across - 1 : x < 0 ? 0 : x;
			y = y >= _across ? across - 1 : y< 0 ? 0 : y;
			
			
		//	x = _across * .5;
			//y = _across * .5;
			
			if (!_lock && (x != _x || y != _y)) {
				
				 _x=x;
				 _y = y
			
				 startPt.x = x * GRID_SIZE;
				 startPt.y = y * GRID_SIZE;
				 startBox.x = x * 256;
				 startBox.y = -y * 256;
				 startBox.z =  heightMapData[y*_across+x];
				 
				 	 _graphGrid.search(_x, _y, MOVEMENT_POINTS);
				 _graphGrid.renderVisitedToScaledImages(_arrDots, .25);
				 _graphGrid.renderOutlineBorderToScaledImages(_arrDots,0);
				 
				// /*
			
				 var total:int = 	 _graphGrid.performIsoOutlineRender(outliner);
				// _graphGrid.renderBordersAlgo(outliner); 
				 // _graphGrid.performOutlineBorderRender(outliner);
				 // _graphGrid.performOutlineRender(outliner);
//
				
				//	total = 80;
				 borderMeshset.numClones = 0;
				 for (var i:int = 0; i < total; i+=2) {
					// outliner[i];
					// outliner[i + 1];
					var clone:MeshSetClone = borderMeshset.addNewOrAvailableClone();
					clone.root.x =  outliner[i] * 256;
					clone.root.y =  -outliner[i + 1] * 256;
					 clone.root.z =  heightMapData[ outliner[i + 1] * _across + outliner[i]];
					 
					 var i2:int = i + 2;
					 if (i2 >= total) {
						 i2 = 0;
					 }
					  var x2:Number= outliner[i2] * 256;
						 var y2:Number = -outliner[i2 + 1] * 256;
							x2-= clone.root.x;
							y2 -= clone.root.y;
							var d:Number = x2 == 0 || y2 == 0 ? 1 : GKEdge.DIAGONAL_LENGTH;
							d *= 256;
							d = 1 / d;
							x2 *= d;
							y2 *= d;
							
							///*
							clone.root.rotationZ =  Math.atan2(y2, x2);
							clone.root.scaleX = 1 / d;
							clone.root.composeTransforms();
							var transform:Transform3D = clone.root.transform;
							var forwardNormal:Vector3D = new Vector3D(transform.a, transform.b, transform.c);
							forwardNormal.normalize();
							//throw new Error(clone.root.transform.toString().split(",").join("\n") + ", "+( Vector3D.Z_AXIS.crossProduct( forwardNormal) ) );
						//	clone.root.scaleY = -32;
							//*/
							
							//clone.root.x += x2 * 50* clone.root.scaleX;
							//clone.root.y += y2 * 50 ;
						
							
					 
				//	 clone.root.scaleZ = .015 * i / 2;
				 }
				// */
				 
			}
			
			
			game.engine.update(time);
			_template3D.render();
		}
		
	}

}