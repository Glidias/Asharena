package arena.systems.islands.jobs 
{
	import arena.systems.islands.IslandGeneration;
	import arena.systems.islands.KDZone;
	import arena.systems.islands.KDNode;
	import de.polygonal.ds.mem.IntMemory;
	import de.polygonal.math.PM_PRNG;
	import util.LogTracer;
	/**
	 * With location key and list of KD Zones, find any avaliable island based on location Key. If got island, check if got land.
	 * If got land, than sample(scaled) bitmapdata from specific isladn resources heightMaps to a 128x128 heigth data sample, expand if needed, and than apply noise to sample. Create 128x128 normal map from heightmap. Send entire data to Main.
	 * @author Glenn Ko
	 */
	public class SampleScaledHeight extends IsleJob
	{
		public var foundNodes:Vector.<KDNode>;

		public var level:int;
		public var sampleX:Number;
		public var sampleY:Number;
		public var zone:KDZone;
		public var timestamp:int;
		public var cancelled:Boolean = false;
		
		public static var MEM:IntMemory;
		public static var ZONE_SIZE:Number = 8192;
		public static var MIN_SAMPLE_SIZE:int = 128;
		public static var PRNG:PM_PRNG = new PM_PRNG();

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
		
			cancelled = false;
			
			var zoneSize:Number = ZONE_SIZE;
			var bmSizeSmlI:Number = IslandGeneration.BM_SIZE_SMALL_I * zoneSize;  // to convert KD coorindate to tile coordinates
			var minSampleSize:int = MIN_SAMPLE_SIZE;
			
			var len:int = foundNodes.length;
			
			for (var i:int = 0; i < len ; i++) {
				var node:KDNode = foundNodes[i];  
				var ratio:Number;
				
					if (node.islandResource == null) throw new Error("SHOULD NOT BE!");
				
				var properHeightMapWidth:int =  node.islandResource.heightMap.width - 1;
				
				
				// sampling is done via relative position of sample against node
				
				//  consider if can do sampling via copy pixels instead of bilinearly-intepolated/nearest neighbor sampling??
				
				// Get island region size in tile coordinates
				var nodeSize:Number = node.getMeasuredShortSide() * bmSizeSmlI;
				
				// Get sampler x and y in tile coordinates
				var sx:Number;
				var sy:Number;
				sx = sampleX * zoneSize - node.boundMinX*bmSizeSmlI;
				sy = sampleY * zoneSize - node.boundMinY * bmSizeSmlI;
				
				//LogTracer.log("Start x and y in tile coordinates from island region top left:" + sx + ", " + sy + " ::: "+(sampleX*zoneSize)+ " , "+(sampleY*zoneSize) + ", "+(node.boundMinX*bmSizeSmlI) + ", "+(node.boundMinY * bmSizeSmlI));
				if (node.boundMinX + node.getMeasuredShortSide() < sampleX * 64) throw new Error("OUTTA BOUNDS X:");
				if (node.boundMinY + node.getMeasuredShortSide() < sampleY * 64) throw new Error("OUTTA BOUNDS Y:");

				
				
				
				// Get width and height in tile coordinates
				var width:Number = (minSampleSize << level);
				var height:Number = width;
				
				var dx:int = 0;
				var dy:int = 0;
				if (sx < 0) {
					width += sx;
					sx = 0;
					LogTracer.log("Minusing start x");
				}
				if (sy < 0) {
					height += sy;
					sy = 0;
					LogTracer.log("Minusing start y");
				}
				
				// Translate tile coordinates of sx,sy,width into pixel coordinates of heightmap
				sx = sx / nodeSize * properHeightMapWidth;
				sy = sy / nodeSize * properHeightMapWidth;
				
				ratio = properHeightMapWidth / nodeSize * (1 << level);  // is this correct?
				
				width = width / nodeSize * properHeightMapWidth;
				height = height/ nodeSize * properHeightMapWidth;
				
				//width *= ratio;
				//height *= ratio;

			//	width *= ratio;
				//height *= ratio;
				/*
				if (nodeSize <= node.islandResource.heightMap.width) { // either noScale (ratio 1) or downScale (ratio > 1 whole)
					
					
				}
				else {  // always upScale  (floating point ratio < 1 )
				
				}
				*/
			
				//LogTracer.log(level + " / " + node.islandResource.heightMap.width + " / " + nodeSize +" Sampling: " + sx + ", " + sy + ", " + ratio + ", " + width + ", " + height + ", " + dx + ", " + dy);
				// For now, naive impl
				
				width += ratio;
				height += ratio;
				
				// currently hardcoding height scales atm...this shuoudl be randomized..
				PRNG.setSeed(node.seed);
				var determineHtScale:Number = (1 << int(Math.log(nodeSize + .01) * Math.LOG2E)) * ( PRNG.nextDouble() > .5 ?  .15 : .1);
				if (determineHtScale < 7) determineHtScale = 7;
				node.islandResource.heightMap.samplePixelsTo2(MEM, sx, sy, ratio, width, height, dx, dy, minSampleSize+1,  determineHtScale, 0); 
			
				
			}
			
			ON_COMPLETE.dispatch(this);
		}
		
		
		
		override public function dispose():void {
		
			foundNodes = null;
			zone = null;
			
		}
		
		override public function cancel():void {
			cancelled = true;
		}
		
	}

}