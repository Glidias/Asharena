package saboteur.spawners 
{
	import alternativa.engine3d.core.BoundBox;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.loaders.ParserA3D;
	import alternativa.engine3d.materials.FillMaterial;
	import alternativa.engine3d.materials.Material;
	import alternativa.engine3d.materials.StandardMaterial;
	import alternativa.engine3d.materials.TextureMaterial;
	import alternativa.engine3d.objects.Mesh;
	import alternativa.engine3d.objects.Surface;
	import alternativa.engine3d.primitives.Plane;
	import alternativa.engine3d.resources.BitmapTextureResource;
	import alternativa.engine3d.utils.Object3DUtils;
	import ash.core.Engine;
	import ash.core.Entity;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display3D.Context3D;
	import saboteur.util.CardinalVectors;
	import saboteur.util.GameBuilder3D;
	import util.SpawnerBundle;
	import alternativa.engine3d.alternativa3d;
	use namespace alternativa3d;
	
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class JettySpawner extends SpawnerBundle
	{
		private var myAssets:JettyAssets;
		

	
		private var genesis:Object3D;
		private var blueprint:Object3D;
		private var injectMaterial:StandardMaterial;
		private var collision:Object3D;


		public function JettySpawner() 
		{
			myAssets = new JettyAssets();
			ASSETS = myAssets;
			
			super();
		}
		
		override public function init():void 
		{
			var diffuse:BitmapTextureResource = new BitmapTextureResource(new myAssets.$_TEXTURE().bitmapData);
			
		
			var normalResource:BitmapTextureResource = new BitmapTextureResource(    new BitmapData(16, 16, false, 0x8080FF) );
			injectMaterial = new StandardMaterial(diffuse, normalResource);
			injectMaterial.glossiness = 0;
			injectMaterial.specularPower = 0;
            
            
			var previewMaterial:StandardMaterial = injectMaterial.clone() as StandardMaterial;
			previewMaterial.alphaThreshold = .99;
			previewMaterial.alpha = .4;

			
			// Setup parsing of 3d stuff from a3d
			var parserA3D:ParserA3D = new ParserA3D();
            parserA3D.parse( new myAssets.$_MODEL() );
			
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

	
			uploadResources(rootCont.getResources(true, null));
			
			 
			super.init();
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
		
	
		public function spawn(engine:Engine, scene:Object3D):Entity {
			
			var root:Object3D = scene.addChild(new Object3D());
			var gameBuilder:GameBuilder3D = new GameBuilder3D(root, genesis, blueprint, collision, injectMaterial);
			var cardinal:CardinalVectors = new CardinalVectors();
			var entity:Entity = new Entity().add(cardinal).add(gameBuilder);
		blueprint.visible = true;
		blueprint.x = 40;
		blueprint.y = 30;
		engine.addEntity(entity);
			return entity;
		}
		
	}

}