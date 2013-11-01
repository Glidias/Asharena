package arena.systems.islands.jobs 
{
	/**
	 * With location key and list of KD Zones, find any avaliable island based on location Key. If got island, check if got land.
	 * If got land, than sample(scaled) bitmapdata from specific isladn resources heightMaps to a 128x128 heigth data sample, expand if needed, and than apply noise to sample. Create 128x128 normal map from heightmap. Send entire data to Main.
	 * @author Glenn Ko
	 */
	public class SampleScaledHeight extends IsleJob
	{
		private var islandResources:Vector.<IslandResource>;
		private var islandPositions:Vector.<int>;
		private var locationKey:Number;
		private var stride:int;

		public function SampleScaledHeight() // 1, 2, 4, 8 - stride is basically the result of the bitshift. It determines the scale for the noise.
		{
			super();
		}
		
		/** 
		 * @param	islandResources  Relavant island region resources that touch sample bounds governed by locationKey & stride.
		 * @param	islandPositions  Respective Positions of the islands relative to locationKey TL origin location in tile units.
		 * @param	locationKey		The floating-point location key to represents [zoneIndex].[gridPositionInZone] of the TL origin of the sample bound.
		 * @param	stride			The up-scaling factor of the sample bounds.
		 */
		public function init(islandResources:Vector.<IslandResource>, islandPositions:Vector.<int>, locationKey:Number, stride:int):void {
			this.stride = stride;
			this.locationKey = locationKey;
			this.islandPositions = islandPositions;
			this.islandResources = islandResources;
		}
		
		
		override public function execute():void {
			
		}
		
		override public function dispose():void {
		
			islandResources = null;
			islandPositions = null;
			
		}
		
	}

}