package arena.systems.islands.jobs 
{
	import arena.systems.islands.IslandGeneration;
	import arena.systems.islands.KDZone;
	import arena.systems.islands.KDNode;
	import de.polygonal.ds.mem.ShortMemory;
	/**
	 * With location key and list of KD Zones, find any avaliable island based on location Key. If got island, check if got land.
	 * If got land, than sample(scaled) bitmapdata from specific isladn resources heightMaps to a 128x128 heigth data sample, expand if needed, and than apply noise to sample. Create 128x128 normal map from heightmap. Send entire data to Main.
	 * @author Glenn Ko
	 */
	public class SampleScaledHeight extends IsleJob
	{
		private var foundNodes:Vector.<KDNode>;

		public var level:int;
		public var sampleX:Number;
		public var sampleY:Number;
		public var zone:KDZone;
		
		public static var MEM:ShortMemory = new ShortMemory(128 * 128);
		public static var ZONE_SIZE:Number = 8912;

		public function SampleScaledHeight() // 1, 2, 4, 8 - stride is basically the result of the bitshift. It determines the scale for the noise.
		{
			super();
		}
		
		/** 
		 * @param	foundNodes  Relavant island region resources that touch sample bounds governed by locationKey & stride.
		 * @param	loaderIndex		
		 * @param	level			The up-scaling factor of the sample bounds.
		 */
		public function init(foundNodes:Vector.<KDNode>,  sampleX:Number, sampleY:Number, level:int):void {
			this.sampleY = sampleY;
			this.sampleX = sampleX;
			this.level = level;

			this.foundNodes = foundNodes;
		
		}
		
		
		override public function execute():void {
			var stride:int = (1 << level);
	
			
			var zoneSize:Number = ZONE_SIZE;
			var bmSizeSmlI:Number = IslandGeneration.BM_SIZE_SMALL_I * zoneSize;
			
			var len:int = foundNodes.length;
			
			for (var i:int = 0; i < len ; i++) {
				var node:KDNode = foundNodes[i];  
				
				// sampling is done via relative position of sample against node
				
				//  consider if can do sampling via copy pixels instead of bilinearly-intepolated/nearest neighbor sampling??
				var nodeSize:Number = node.getMeasuredShortSide() * bmSizeSmlI;
				
				var sx:Number;
				var sy:Number;
				sx = sampleX * zoneSize - node.boundMinX * bmSizeSmlI;
				sy = sampleY * zoneSize - node.boundMinY * bmSizeSmlI;
				
				var ratio:Number;
			//	if (node.islandResource == null) throw new Error("SHOULD NOT BE!");
				
				ratio = node.islandResource.heightMap.width / nodeSize * stride; 
				
				var width:Number = node.islandResource.heightMap.width ;
				var height:Number = node.islandResource.heightMap.height;
				var dx:int = 0;
				var dy:int = 0;
				if (sx < 0) {
					width += sx;
					sx = 0;
				}
				if (sy < 0) {
					height += sy;
					sy = 0;
				}
				
				width *= ratio;
				height *= ratio;
				
				if (nodeSize <= node.islandResource.heightMap.width) { // either noScale (ratio 1) or downScale (ratio > 1 whole)
					
					
				}
				else {  // always upScale  (floating point ratio)
				
				}
 
				// For now, naive impl
				node.islandResource.heightMap.samplePixelsTo3(MEM, sx, sy, ratio, width, height, dx, dy, 128, 64, 0); 
				
			}
			
			ON_COMPLETE.dispatch(this);
		}
		
		override public function dispose():void {
		
			foundNodes = null;
			zone = null;
			
		}
		
	}

}