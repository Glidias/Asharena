package alternterrain.objects 
{
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.alternativa3d;
	use namespace alternativa3d;
	
	/**
	 * A custom Object3D container setup of multiple TerrainLOD instances at varying LOD scales to display across varying distances.
	 * @author Glenn Ko
	 */
	public class HierarchicalTerrainLOD extends Object3D
	{
		public var lods:Vector.<TerrainLOD>;
		
		public function HierarchicalTerrainLOD() 
		{
			var numLevels:int = 4;
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
		
		
		
	}

}