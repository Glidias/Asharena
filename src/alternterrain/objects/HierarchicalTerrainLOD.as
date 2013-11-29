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
		
	
		static private const NUM_LEVELS:int = 4;
		private var _matchDetailWithScale:Boolean;
		
		
		public function HierarchicalTerrainLOD(doMatchDetailWithScale:Boolean=true) 
		{
			var numLevels:int = NUM_LEVELS;
			var scale:Number = 1;
			_matchDetailWithScale = doMatchDetailWithScale;
			lods = new Vector.<TerrainLOD>();
			for (var i:int = 0; i < numLevels; i++) {
				var t:TerrainLOD = new TerrainLOD();
			
				t._scaleX = t._scaleY = scale;
				t.transformChanged = true;
				addChild(t);
				lods.push(t);
				if (doMatchDetailWithScale) t.detail /= scale; 
				scale *= 2;
			}
		}
		
		public function setupPages(context3D:Context3D,  numTiles:int, requirements:int=0, uvTileSize:int=0, tileSize:int = 256):void { 
			var dummyQuadTreePage:QuadTreePage = QuadTreePage.createFlat(0, 0,numTiles, tileSize);
			//
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
		
		public function getTotalStats():String {
			var newly_instantiated:int = 0;
			var pool_retrieved:int = 0;
			var cached_retrieved:int = 0;
			for (var i:int = 0; i < NUM_LEVELS; i++) {
				var t:TerrainLOD = lods[i];
				newly_instantiated +=t.newly_instantiated ;
				pool_retrieved += t.pool_retrieved;
				cached_retrieved += t.cached_retrieved;
			}
			return newly_instantiated + ", " + pool_retrieved + ", " + cached_retrieved;
		}
		
		public function get matchDetailWithScale():Boolean 
		{
			return _matchDetailWithScale;
		}
		
		public function set matchDetailWithScale(value:Boolean):void 
		{
				_matchDetailWithScale = value;
				var scale:Number = 2;
				var baseDetail:Number = lods[0].detail;
				for (var i:int = 1; i < NUM_LEVELS; i++) {
					var t:TerrainLOD = lods[i];
					lods[i].detail = value ? baseDetail / scale : baseDetail;
					scale *= 2;
					lods[i].invalidateUpdatePosition();
				}
		}
		
		public function setUpdateRadius(val:Number):void {
			for (var i:int = 0; i < NUM_LEVELS; i++) {
					var t:TerrainLOD = lods[i];
					t.setUpdateRadius(val);
					val *= .5;
				}
				
		}
		
		
		
		
		
	}

}