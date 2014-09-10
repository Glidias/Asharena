package spawners.arena.water 
{
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.Renderer;
	import alternativa.engine3d.core.VertexAttributes;
	import alternativa.engine3d.materials.Material;
	import alternativa.engine3d.materials.StandardMaterial;
	import alternativa.engine3d.materials.VertexLightTextureMaterial;
	import alternativa.engine3d.primitives.Plane;
	import alternativa.engine3d.resources.BitmapTextureResource;
	import alternterrain.materials.CheckboardFillMaterial;
	import eu.nekobit.alternativa3d.materials.WaterMaterial;
	import flash.display.BitmapData;
	
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
		
		public static var SCALER:Number = 4;
		public static var SIZE:Number = 2048 * 256 * SCALER;
		public static var SEGMENTS:int = 64;
		public static var UV_SCALER:Number = 16 * 32 * SCALER;
		public var hideFromReflection:Vector.<Object3D> = new Vector.<Object3D>();
		
		public function WaterBase(assetClasse:Class, planeClasse:Class=null) 
		{
			if (planeClasse == null) planeClasse = Plane;
			this.planeClasse = planeClasse;
			
			this.assetClasse = assetClasse;
			ASSETS = [assetClasse];
			super();
		}
		
		private var planeClasse:Class;
		private var uvFollowOffsetScale:Number = 1;
		
		
		
		override protected function init():void {

			var normalRes:BitmapTextureResource = new BitmapTextureResource(new assetClasse.NORMAL().bitmapData);
			waterMaterial = new WaterMaterial(normalRes, normalRes);
			waterMaterial.forceRenderPriority =  Renderer.SKY ;
	
			
			
			
			// distanceTravelled / (size of plane / numberOfRepeats)
			
				
			// Reflective plane
			var scaler:Number = SCALER;
			var size:Number = SIZE;
			var uvScale:Number = UV_SCALER;
			var testMat:Material =  new CheckboardFillMaterial();// new StandardMaterial(new BitmapTextureResource(new BitmapData(16, 16, false, 0xFFFFFF)), new BitmapTextureResource(new BitmapData(16, 16, false, 0x0000FF)) );
			
			//size = 10000;
			
			plane = new planeClasse(size, size, SEGMENTS, SEGMENTS, false, false, null, waterMaterial);
			//plane.transformProcedure
			
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