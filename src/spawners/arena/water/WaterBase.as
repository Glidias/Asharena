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
		
		private var uvFollowOffsetScale:Number = 1;
		
		override protected function init():void {

			var normalRes:BitmapTextureResource = new BitmapTextureResource(new assetClasse.NORMAL().bitmapData);
			waterMaterial = new WaterMaterial(normalRes, normalRes);
			waterMaterial.forceRenderPriority =  Renderer.SKY ;
		
			var uvScaler:Number = 16;
	
			
			// distanceTravelled / (size of plane / numberOfRepeats)
			
			
			
			// Reflective plane
			var scaler:Number = 2;
			var size:Number = 2048 * 256 * scaler;
			var uvScale:Number = uvScaler * 32 * scaler;
			plane = new Plane(size, size, 64, 64, false, false, null, waterMaterial);
			var uvs:Vector.<Number>= plane.geometry.getAttributeValues(VertexAttributes.TEXCOORDS[0]);
			for (var i:int = 0; i < uvs.length; i++) {
				uvs[i] *= uvScale;
			}
			 plane.geometry.setAttributeValues(VertexAttributes.TEXCOORDS[0],uvs);	
			
			 uvFollowOffsetScale = 1/size * uvScale;
			 
			uploadResources(plane.getResources());
			
			super.init();
		}
		
		public function addToScene(scene:Object3D,depth:int=-1):void {
			// Reflective plane
			if (depth < 0) scene.addChild(plane)
			else scene.addChildAt(plane,depth);
			
		}
		
		public function setupFollowCamera():void 
		{
			waterMaterial.setFollowCamera(uvFollowOffsetScale);
		}

	}

}