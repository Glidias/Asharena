package saboteur.views 
{
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.Renderer;
	import alternativa.engine3d.materials.Material;
	import alternativa.engine3d.objects.SpriteMeshSetClone;
	import alternativa.engine3d.objects.SpriteMeshSetClonesContainer;
	import alternativa.engine3d.resources.BitmapTextureResource;
	import alternativa.engine3d.spriteset.materials.TextureAtlasMaterial;
	import ash.core.NodeList;
	import flash.display.BitmapData;
	import flash.display3D.Context3D;
	import flash.geom.Point;
	import flash.utils.Dictionary;
	import saboteur.util.SaboteurPathUtil;
	/**
	 * ...
	 * @author Glidias
	 */
	public class SaboteurMinimap 
	{
		public var jettySet:SpriteMeshSetClonesContainer;

		public var jettyColumns:int;
		
		
		private var pathUtil:SaboteurPathUtil = SaboteurPathUtil.getInstance();
		private var jettyMaterial:TextureAtlasMaterial;
		private var jettySheetWidth:int;
		private var jettySheetHeight:int;
		private var jettyTileSize:Point;
		public var pixelToMinimapScale:Point;
		
		public function SaboteurMinimap(jettyMaterial:TextureAtlasMaterial, jettyColumns:int, jettyTileSize:Point, pixelToMinimapScale:Point) 
		{
			this.pixelToMinimapScale = pixelToMinimapScale;
			this.jettyTileSize = jettyTileSize;
		//	jettyMaterial.alphaThreshold = 0.99;
			var bmpData:BitmapData = (jettyMaterial.diffuseMap as BitmapTextureResource).data;
			jettySheetWidth = bmpData.width;
			jettySheetHeight = bmpData.height;
			this.jettyColumns = jettyColumns;
			
			jettySet = new SpriteMeshSetClonesContainer(jettyMaterial);
			jettySet.objectRenderPriority = Renderer.NEXT_LAYER;
			jettySet.z = -.02;
		}
		
		public function createJettyAt(x:int, y:int, index:int):SpriteMeshSetClone {
			var spr:SpriteMeshSetClone = jettySet.createClone() as SpriteMeshSetClone;
			var rowIndex:int = int(index / jettyColumns);
			var colIndex:int = index - rowIndex;
			spr.root.x = x * jettyTileSize.x + .5 *jettyTileSize.x;
			spr.root.y = y * jettyTileSize.y + .5 * jettyTileSize.y;
			spr.root.scaleX = jettyTileSize.x *.5;
			spr.root.scaleY = jettyTileSize.y*.5;
					//	spr.root.rotationX = Math.PI;
			spr.u= (jettyTileSize.x * colIndex ) / jettySheetWidth;
			spr.v= (jettyTileSize.y * rowIndex ) / jettySheetHeight;
			spr.uw = jettyTileSize.x / jettySheetWidth;
			spr.vw = jettyTileSize.y / jettySheetHeight;

			jettySet.addClone(spr);
			return spr;
		}
		
		
		
		public function addToContainer(obj:Object3D):void {
			obj.addChildAt(jettySet,0);
		}
		
		public function upload(context3D:Context3D):void 
		{
			jettySet.geometry.upload(context3D);
		}
		
	}

}