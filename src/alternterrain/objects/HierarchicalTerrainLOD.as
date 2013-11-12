package alternterrain.objects 
{
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.alternativa3d;
	import alternativa.engine3d.materials.FillMaterial;
	import alternativa.engine3d.materials.Material;
	import alternterrain.core.QuadTreePage;
	import flash.display3D.Context3D;
	use namespace alternativa3d;
	
	/**
	 * A custom Object3D container setup of multiple TerrainLOD instances at varying LOD scales to display across varying distances.
	 * @author Glenn Ko
	 */
	public class HierarchicalTerrainLOD extends Object3D
	{
		public var lods:Vector.<TerrainLOD>;
		
		private static const PREVIEW_COLORS:Vector.<uint> = new <uint>[0xDDEEFF,0xFF0000, 0x00FF00, 0x0000FF];
		static private const NUM_LEVELS:int = 4;
		
		
		public function HierarchicalTerrainLOD() 
		{
			var numLevels:int = NUM_LEVELS;
			var scale:Number = 1;
			lods = new Vector.<TerrainLOD>();
			for (var i:int = 0; i < numLevels; i++) {
				var t:TerrainLOD = new TerrainLOD();
				
				t._scaleX = t._scaleY = scale;
				t.transformChanged = true;
				addChild(t);
				lods.push(t);
				scale *= 2;
			}
		}
		
		public function setupPages(context3D:Context3D,  numTiles:int, requirements:int=0, uvTileSize:int=0, tileSize:int = 256):void { 
			var dummyQuadTreePage:QuadTreePage = QuadTreePage.create(0, 0, numTiles*tileSize);
			//QuadTreePage.createFlat(0, 0,numTiles, tileSize);
			//QuadTreePage.create(0, 0, numTiles*tileSize);
			
			
			dummyQuadTreePage.requirements = requirements;
			dummyQuadTreePage.uvTileSize = uvTileSize;
			
			var numLevels:int = NUM_LEVELS;
			

			for (var i:int = 0; i < numLevels; i++) {
				var t:TerrainLOD = lods[i];
				//t.loadGridOfPages( context3D, new <QuadTreePage>[dummyQuadTreePage], new FillMaterial(PREVIEW_COLORS[i]) );
				t.loadNull(context3D, dummyQuadTreePage);
			}
		}
		
		
		
		
		
	}

}