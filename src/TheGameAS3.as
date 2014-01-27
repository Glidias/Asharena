package  
{
	import alternativa.engine3d.animation.AnimationClip;
	import alternativa.engine3d.animation.keys.Track;
	import alternativa.engine3d.animation.keys.TransformTrack;
	import alternativa.engine3d.objects.Mesh;
	import alternativa.engine3d.objects.WireFrame;
	import alternativa.engine3d.primitives.Box;
	import flash.geom.Vector3D;
	import systems.collisions.EllipsoidCollider;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.VertexAttributes;
	import alternativa.engine3d.loaders.ParserA3D;
	import alternativa.engine3d.loaders.ParserMaterial;
	import alternativa.engine3d.loaders.TexturesLoader;
	import alternativa.engine3d.materials.Material;
	import alternativa.engine3d.materials.TextureMaterial;
	import alternativa.engine3d.materials.TextureZClipMaterial;
	import alternativa.engine3d.objects.Skin;
	import alternativa.engine3d.objects.Surface;
	import alternativa.engine3d.RenderingSystem;
	import alternativa.engine3d.resources.ExternalTextureResource;
	import alternativa.engine3d.resources.TextureResource;
	import alternterrain.CollidableImpl;
	import ash.core.Entity;
	import components.Rot;
	import examples.WaterAndTerrain3rdPerson;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.utils.getDefinitionByName;
	import spawners.arena.GladiatorBundle;
	import util.geom.Geometry;
	import util.LogTracer;
	import util.SpawnerBundle;
	import util.SpawnerBundleLoader;

	import components.Pos;
	import flash.Boot;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.net.registerClassAlias;
	import flash.utils.ByteArray;
	import systems.player.a3d.AnimationManager;
	import systems.player.a3d.GladiatorStance;
	import systems.rendering.RenderNode;
	import systems.SystemPriorities;
	import views.Alternativa3DView;
	
	import alternativa.engine3d.alternativa3d;
	use namespace alternativa3d;

	/**
	 * This is running under AS3 using alternativa3d engine.
	 * @author Glenn Ko
	 */
	public class TheGameAS3 extends TheGame
	{
	
		private var arenaSpawner:ArenaSpawner;	
		private var _view:WaterAndTerrain3rdPerson = new WaterAndTerrain3rdPerson();
		private var spawnerBundle:GladiatorBundle;
		private var collideImpl:CollidableImpl;
		
		public function TheGameAS3(stage:Stage) 
		{
			super(stage);
			
			registerClassAlias("String", String);
						
	
			
			stage.addChild(_view);
			
			_view.addEventListener(Event.COMPLETE, onViewInitialized);
			
			LogTracer.log = getDefinitionByName("haxe::Log").trace;
			Boot.getTrace().blendMode = "invert";
			stage.addChild( Boot.getTrace() );
		}
		
		private function onViewInitialized(e:Event):void 
		{
			(e.currentTarget as IEventDispatcher).removeEventListener(e.type, onViewInitialized);
				
			SpawnerBundle.context3D = _view.stage3D.context3D;
			
			spawnerBundle = new GladiatorBundle(arenaSpawner);
			new SpawnerBundleLoader(stage, begin, new <SpawnerBundle>[spawnerBundle]);
			
			
			//begin();
		}
		
		private function begin():void 
		{
			spawnerBundle.textureMat.waterMode = true;

			engine.addSystem( new RenderingSystem(_view.scene, _view), SystemPriorities.render );
		

			arenaSpawner.addGladiator(ArenaSpawner.RACE_SAMNIAN, stage).add(keyPoll);
			_view.inject(arenaSpawner.currentPlayer, arenaSpawner.currentPlayer, arenaSpawner.currentPlayerEntity.get(Pos) as Pos,  arenaSpawner.currentPlayerEntity.get(Rot) as Rot, arenaSpawner.currentPlayerSkin,spawnerBundle.textureMat);
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			startGame();
		}
		

		private var testChunkEllipsoid:EllipsoidCollider = new EllipsoidCollider(32 * 256 * .5, 32 * 256 * .5, 888);
		
		private function onKeyDown(e:KeyboardEvent):void 
		{
			if (e.keyCode === Keyboard.P) {
				LogTracer.log( _view.terrainLOD.getTotalStats() );
			}
			else if (e.keyCode === Keyboard.L) {
				//var added:Number =  /(32 * 256)) + 128 * 32;
				//testChunkEllipsoid.radiusX = 
				var  pos:Vector3D = new Vector3D( int(arenaSpawner.currentPlayerEntity.get(Pos).x), int(arenaSpawner.currentPlayerEntity.get(Pos).y), arenaSpawner.currentPlayerEntity.get(Pos).z);
				//pos = _view.terrainLOD.globalToLocal(pos);
				collideImpl.alwaysIntersect = true;
				testChunkEllipsoid.calculateCollidableGeometry(pos, collideImpl); 
				_view.scene.addChild( createWireframeCollisionPreview(pos, 0.57357643635104609610803191282616) );
				//throw new Error(testChunkEllipsoid.numFaces);
			}
		}
		
		
		public function createWireframeCollisionPreview(pos:Vector3D, maxNormalZ:Number):WireFrame {
			var wireframe:WireFrame;
			var dummyMesh:Mesh = new Mesh();
		
		
			dummyMesh.geometry = new alternativa.engine3d.resources.Geometry(testChunkEllipsoid.vertices.length/3);
			dummyMesh.geometry.addVertexStream( [VertexAttributes.POSITION, VertexAttributes.POSITION, VertexAttributes.POSITION]);
			
//throw new Error( ( testChunkEllipsoid.vertices.length / 3 ) + ", "+ testChunkEllipsoid.vertices.length + ", "+(3*dummyMesh.geometry.numVertices) );
			dummyMesh.geometry.setAttributeValues(VertexAttributes.POSITION, testChunkEllipsoid.vertices);
			
			
			//dummyMesh.geometry.indices = extractUnsignedVector(testChunkEllipsoid.indices, testChunkEllipsoid.numFaces * 3);
			dummyMesh.geometry.indices = extractSteepPolygons(0.57357643635104609610803191282616);

			//dummyMesh = new Box(300, 300, 300);
		
		//	WireFrame.createLinesList(
			//wireframe =  WireFrame.createEdges(dummyMesh, 0xFFFFFF, 1, 1);
			wireframe = WireFrame.createLinesList(extractSteepEdges(0.57357643635104609610803191282616),0xFFFFFF,1,2);
			wireframe.matrix = _view.terrainLOD.matrix;
			
			wireframe.geometry.upload( _view.stage3D.context3D);
		//	wireframe.scaleX = 1/testChunkEllipsoid.radiusX;
		//	wireframe.scaleY = 1/testChunkEllipsoid.radiusY;
		//	wireframe.scaleZ = 1/testChunkEllipsoid.radiusZ;
			wireframe.boundBox = null;
			return wireframe;	
		}
		
		private function extractUnsignedVector(vec:Vector.<int>, sliceAmt:int):Vector.<uint> {
			var vect:Vector.<uint> = new Vector.<uint>(sliceAmt, true);
			for (var i:int = 0; i < sliceAmt; i++) {
				vect[i] = vec[i];
			}
			return vect;
		}
		
		private function extractSteepPolygons(threshold:Number):Vector.<uint> {
			var vect:Vector.<uint> = new Vector.<uint>();
			var len:int = testChunkEllipsoid.numFaces;
			var count:int = 0;
			
			for (var i:int = 0; i < len; i++) {
				if ( testChunkEllipsoid.normals[i*4 + 2] <= threshold ) {
					vect[count++] = testChunkEllipsoid.indices[i*3];
					vect[count++] = testChunkEllipsoid.indices[i*3+1];
					vect[count++] = testChunkEllipsoid.indices[i*3+2];
				}
			}
			vect.fixed = true;
			return vect;
		}
		
		private function extractSteepEdges(threshold:Number):Vector.<Vector3D> {
			var vect:Vector.<Vector3D> = new Vector.<Vector3D>();
			var len:int = testChunkEllipsoid.numFaces;
			var count:int = 0;
			
			for (var i:int = 0; i < len; i++) {
				if ( testChunkEllipsoid.normals[i * 4 + 2] <= threshold ) {
					var ax:Number =  testChunkEllipsoid.vertices[ testChunkEllipsoid.indices[i * 3] * 3];
					var ay:Number =  testChunkEllipsoid.vertices[ testChunkEllipsoid.indices[i * 3]*3+1];
					var az:Number =  testChunkEllipsoid.vertices[ testChunkEllipsoid.indices[i * 3] * 3 +2];
					var bx:Number =  testChunkEllipsoid.vertices[ testChunkEllipsoid.indices[i * 3 + 1] * 3  ];
					var by:Number=  testChunkEllipsoid.vertices[ testChunkEllipsoid.indices[i * 3 + 1] * 3 + 1 ];
					var bz:Number =  testChunkEllipsoid.vertices[ testChunkEllipsoid.indices[i * 3 + 1] * 3 + 2 ];
					var cx:Number =   testChunkEllipsoid.vertices[testChunkEllipsoid.indices[i * 3 + 2] * 3 ];
					var cy:Number =   testChunkEllipsoid.vertices[testChunkEllipsoid.indices[i * 3 + 2] * 3 + 1];
					var cz:Number =   testChunkEllipsoid.vertices[testChunkEllipsoid.indices[i * 3 + 2] * 3 + 2];
					if (az > bz && az > cz) {
						vect[count++] = new Vector3D(bx, by, bz);
						vect[count++] = new Vector3D(cx, cy, cz);
					}
					else if (bz > cz && bz > az) {
							vect[count++] = new Vector3D(cx,cy, cz);
						vect[count++] = new Vector3D(ax, ay, az);
					}
					else {
						vect[count++] = new Vector3D(ax,ay, az);
						vect[count++] = new Vector3D(bx, by, bz);
					}
				}
			}
			vect.fixed = true;
			return vect;
		}
	
		
		private function startGame():void {
					
			if (colliderSystem) {
				/*
				var geom:Geometry = new Geometry();
				geom.setVertices(  _view.box.geometry.getAttributeValues(VertexAttributes.POSITION)  );
				geom.setIndices(_view.box.geometry.indices);
				colliderSystem.collidable = geom;
				*/		
				colliderSystem._collider.threshold = 0.0001;
				colliderSystem.collidable =collideImpl =  new CollidableImpl(_view.terrainLOD, _view.getWaterPlane());
			}
			
			gameStates.engineState.changeState( "thirdPerson");
				
			// Setup rendering system
			ticker.add(enterFrame);
			ticker.start();	
		}
		
		private function enterFrame(time:Number):void 
		{
			//LogTracer.log( _view.terrainLOD.getTotalStats() );
		}

		
		override public function getSpawner():Spawner {	
			return (arenaSpawner=new ArenaSpawner(engine));
		}
			
		
		
	}
}
