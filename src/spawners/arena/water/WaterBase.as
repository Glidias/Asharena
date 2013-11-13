package spawners.arena.water 
{
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.Renderer;
	import alternativa.engine3d.core.VertexAttributes;
	import alternativa.engine3d.primitives.Plane;
	import alternativa.engine3d.resources.BitmapTextureResource;
	import eu.nekobit.alternativa3d.materials.WaterMaterial;
	
	import util.SpawnerBundle;
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class WaterBase extends SpawnerBundle
	{
		private var assetClasse:Object;
		public var waterMaterial:WaterMaterial;
		public var plane:Plane;
		

		
		public function WaterBase(assetClasse:Class) 
		{
			this.assetClasse = assetClasse;
			ASSETS = [assetClasse];
			super();
		}
		
		override protected function init():void {

			var normalRes:BitmapTextureResource = new BitmapTextureResource(new assetClasse.NORMAL().bitmapData);
			waterMaterial = new WaterMaterial(normalRes, normalRes);
			waterMaterial.forceRenderPriority =  Renderer.SKY + 1;
			var scaler:Number = 1;
			var uvScaler:Number = 16;
	
			
			// Reflective plane

			plane = new Plane(2048 * 256, 2048 * 256, 64, 64, false, false, null, waterMaterial);
			var uvs:Vector.<Number>= plane.geometry.getAttributeValues(VertexAttributes.TEXCOORDS[0]);
			for (var i:int = 0; i < uvs.length; i++) {
				uvs[i] *= uvScaler * 32;
			}
			 plane.geometry.setAttributeValues(VertexAttributes.TEXCOORDS[0],uvs);	
			
			uploadResources(plane.getResources());
			
			super.init();
		}
		
		public function addToScene(scene:Object3D):void {
			// Reflective plane
			scene.addChild(plane);			
			
		}

	}

}