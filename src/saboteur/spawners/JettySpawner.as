package saboteur.spawners 
{
	import alternativa.a3d.collisions.CollisionBoundNode;
	import alternativa.engine3d.core.BoundBox;
	import alternativa.engine3d.core.Camera3D;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.VertexAttributes;
	import alternativa.engine3d.loaders.ParserA3D;
	import alternativa.engine3d.materials.FillMaterial;
	import alternativa.engine3d.materials.Material;
	import alternativa.engine3d.materials.StandardMaterial;
	import alternativa.engine3d.materials.TextureMaterial;
	import alternativa.engine3d.materials.VertexLightTextureMaterial;
	import alternativa.engine3d.materials.VertexLightZClipMaterial;
	import alternativa.engine3d.objects.Mesh;
	import alternativa.engine3d.objects.Surface;
	import alternativa.engine3d.primitives.Plane;
	import alternativa.engine3d.resources.BitmapTextureResource;
	import alternativa.engine3d.spriteset.materials.TextureAtlasMaterial;
	import alternativa.engine3d.utils.A3DUtils;
	import alternativa.engine3d.utils.Object3DUtils;
	import ash.core.Engine;
	import ash.core.Entity;
	import components.DirectionVectors;
	import components.Pos;
	import de.popforge.revive.geom.BoundingBox;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.Stage3D;
	import flash.display3D.Context3D;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	import saboteur.util.CardinalVectors;
	import saboteur.util.GameBuilder3D;
	import saboteur.util.SaboteurPathUtil;
	import saboteur.views.SaboteurMinimap;
	import util.SpawnerBundle;
	import alternativa.engine3d.alternativa3d;
	use namespace alternativa3d;
	
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class JettySpawner extends SpawnerBundle
	{

		public var editorMat:FillMaterial = new FillMaterial(0, .1);
		static public const SPAWN_SCALE:Number = 17;
		private var genesis:Object3D;
		private var blueprint:Object3D;
		private var injectMaterial:VertexLightZClipMaterial;
		private var collision:Object3D;
		private var _floor:Plane;
		public var diffuse:BitmapTextureResource;
		public var minimap:SaboteurMinimap;
		
		public function get jettyMaterial():Material {
			return injectMaterial;
		}
		

		public function JettySpawner() 
		{
		
			ASSETS = [JettyAssets];
			
			super();
		}
		
		override protected function init():void 
		{
			 var plane:Plane = new Plane(1, 1, 1, 1, false, false, editorMat, editorMat);
			 editorMat.color = GameBuilder3D.COLOR_OCCUPIED;
		
			_floor = plane;	
		 _floor.z += 8;
		 
			plane.geometry.upload(context3D);
			
			diffuse = new BitmapTextureResource(new JettyAssets.$_TEXTURE().bitmapData);
			
		
		//	var normalResource:BitmapTextureResource = new BitmapTextureResource(    new BitmapData(16, 16, false, 0x8080FF) );
			injectMaterial = new VertexLightZClipMaterial(diffuse);
			//injectMaterial.glossiness = 0;
		//	injectMaterial.specularPower = 0;
            
            
			var previewMaterial:TextureMaterial = injectMaterial.clone() as TextureMaterial;
			previewMaterial.alphaThreshold = .99;
			previewMaterial.alpha = .4;

			
			// Setup parsing of 3d stuff from a3d
			var parserA3D:ParserA3D = new ParserA3D();
            parserA3D.parse( new JettyAssets.$_MODEL() );
			
			var rootCont:Object3D = parserA3D.hierarchy[0];

			//throw new Error(rootCont.getChildByName("genesis"));
			genesis =  rootCont.getChildByName("genesis");
			if (genesis == null) throw new Error("Could not find genesis!");
			setMaterialToCont( injectMaterial, genesis );
			blueprint = genesis.clone();
			blueprint.name = "blueprint";
		
			setMaterialToCont( previewMaterial, blueprint );
			collision = rootCont.getChildByName("collision");
			if (collision == null) throw new Error("Could not find collision!");

			uploadResources(collision.getResources(true));
			uploadResources(rootCont.getResources(true, null));
			
	
			 
			super.init();
		}
		
		
		public static const H:Number = 24.24136702238381;  // upon 32
		
		public function createBlueprintSheet(camera:Camera3D, stage3D:Stage3D, hud:Object3D):BitmapData {
		
		
			var pathUtil:SaboteurPathUtil = SaboteurPathUtil.getInstance();
			var combinations:Vector.<uint> = pathUtil.combinations;
			var len:int = combinations.length;
			var y:int = 0;
			var x:int = 0;
			var rowLimit:int = 8;
			var boundBox:BoundBox = genesis.boundBox;
			var w:Number = boundBox.maxX * 2;
			var h:Number = boundBox.maxY * 2;
		
		
			var cont:Object3D = new Object3D();
			hud.addChild(cont);
			// testing
			var cloned:Object3D = genesis.clone();
			//cont.addChild(cloned);
			GameBuilder3D.setMaterialToCont(new TextureMaterial(diffuse), cloned);
	
			
			cloned.scaleX =  32 / w;
			cloned.scaleY = cloned.scaleX;
			//	(cloned.getChildAt(0)).setMaterialToAllSurfaces( new FillMaterial(0xFF0000) );
			
			w = 32;
			h *= cloned.scaleX;
			var xOffset:Number = -128+ w * .5;
			var yOffset:Number = -128+ h * .5;
			
			//throw new Error(xOffset + ", " + yOffset + ", "+boundBox.maxX + ", "+boundBox.maxY);
	
			//camera.view.backgroundAlpha
			
			//throw new Error( h);
			
			
			for (var i:int = 0; i < len; i++) {
				var value:uint = combinations[i];
				
				
				
				var child:Object3D = cloned.clone();
				child.scaleY = -1;
				cont.addChild(child);
				child.x = xOffset + x * w;
				child.y = yOffset + y * w;
			
				GameBuilder3D.visJetty3DByValue(pathUtil, child, value);
				x++;
				if (x >= rowLimit) {
					x = 0;
					y++;
				}
				
			}
			
			var lastWidth:Number = camera.view.width;
			var lastHeight:Number = camera.view.height;
			camera.view.width = 256;
			camera.view.height = 256;
			var lastParent:Object3D = camera._parent;
			if (lastParent != null) lastParent.removeChild(camera);
			
			
				var lastBackgroundAlpha:Number = camera.view.backgroundAlpha;
			camera.view.backgroundAlpha = 0;
		//	camera.view.backgroundColor  = 0xFF000000;
	//	camera.view.opaqueBackground = false;
			camera.view.renderToBitmap = true;
		
			camera.render(stage3D);
			camera.view.backgroundAlpha = lastBackgroundAlpha;
			var snapshot:BitmapData = new BitmapData(camera.view.canvas.width, camera.view.canvas.height * 2, true, 0);
			//camera.view.canvas.clone();
			
			snapshot.draw(camera.view);
			snapshot.fillRect(new Rectangle(0, snapshot.height*.5, snapshot.width, snapshot.height * .5), 0xFFCCCCCC );
			snapshot.draw(camera.view, new Matrix(1, 0, 0, 1, 0, camera.view.canvas.height), new ColorTransform(1,1,1,1), null, null, false );
			camera.view.renderToBitmap = false;
			hud.removeChild(cont);
			
			
			
			camera.view.width = lastWidth;
			camera.view.height = lastHeight;
			if (lastParent != null) lastParent.addChild(camera);
			
		//	var bytes:ByteArray = new ByteArray();
		//	bytes.encode();
			var diffuser:BitmapTextureResource = new BitmapTextureResource(snapshot);
			diffuser.upload(context3D);
			if (minimap == null) {
				minimap = new SaboteurMinimap( new TextureAtlasMaterial(diffuser), 8, new Point(32, H), cloned.scaleX );
				minimap.upload(context3D);
			}
			return snapshot;
			
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
		
		private var firstSpawn:Boolean = true;
		//public var collisionRoot:CollisionBoundNode = new CollisionBoundNode();
	
		public function spawn(engine:Engine, scene:Object3D, pos:Pos=null, rayDir:DirectionVectors=null):Entity {
			var root:Object3D = scene.addChild(new Object3D());
			root._scaleX = root._scaleY = root._scaleZ =  SPAWN_SCALE;
			
			
			if (firstSpawn) {
			//var bb:BoundBox = 	Object3DUtils.calculateHierarchyBoundBox(genesis);
			//	.calculateBoundBox();
			//throw new Error((bb.maxX - bb.minZ)*SPAWN_SCALE)
			
				GameBuilder3D.addMeshSetsToScene(scene, genesis, jettyMaterial, root, context3D);
				firstSpawn = false;
			}
			
			
			
			var gameBuilder:GameBuilder3D = new GameBuilder3D(root, genesis, blueprint, collision, injectMaterial, editorMat, _floor);
			
			//collisionRoot.addChild(gameBuilder.collisionGraph);
			
			var cardinal:CardinalVectors = new CardinalVectors();
			var entity:Entity = new Entity().add(cardinal).add(gameBuilder);
			if (pos != null) entity.add(pos, Pos);
			if (rayDir != null) entity.add(rayDir, DirectionVectors);
			engine.addEntity(entity);
			
			return entity;
		}
		
	}

}