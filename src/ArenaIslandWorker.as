package  
{
	import arena.systems.islands.IslandChannels;
	import arena.systems.islands.IslandGeneration;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.system.MessageChannel;
	import flash.system.Worker;
	import flash.utils.ByteArray;
	import spawners.arena.IslandGenWorker;
	import terraingen.island.mapgen2;
	import util.LogTracer;
	/**
	 * To manage generation of islands, terrain, props, etc. asyncronously.
	 * @author Glenn Ko
	 */
	public class ArenaIslandWorker extends Sprite
	{
		// TIER 1
		private var islandGen:IslandGeneration;
		private var channels:IslandChannels;
		
	

		// TIER 2
		//private var ; // to notify main
		
		public function ArenaIslandWorker() 
		{
		
			
			if (!Worker.current.isPrimordial) {
				try {
					init();
				}
				catch (e:Error) {
					channels.sendError(e);
				}
			}
			else {
			
				IslandGenWorker.BYTES = loaderInfo.bytes;
			}
		}
		
		private function init():void 
		{
			
			channels = new IslandChannels();
			channels.initFromChild();
			
			LogTracer.log = channels.sendTrace;
			
			
			// TIER 1
		
			channels.initZoneChannel.addEventListener(Event.CHANNEL_MESSAGE, onZoneInitHandler);
			channels.initIslandChannel.addEventListener(Event.CHANNEL_MESSAGE, onIslandInitHandler);
			
			
			
			islandGen = new IslandGeneration();
			islandGen.addEventListener(Event.COMPLETE, onIslandGenerated);
			
			addChild(islandGen);
		
			
			
			
		}
		
		private function onIslandInitHandler(e:Event):void 
		{
			try {
			
				channels.initIslandChannel.receive();
			
				requestAnyIsland();
			}
			catch (e:Error) {
				channels.sendError(e);
			}
		}
		
		public function onZoneInitHandler(e:Event):void {
				try {
				
					var arr:Array = channels.initZoneChannel.receive();
					islandGen.init(arr[0], arr[1]); 
					LogTracer.log("INIT request:" + arr);
				}
				catch (e:Error) {
					channels.sendError(e);
				}
		}
		
		private function requestRegionAtPoint(x:Number, y:Number):void {
			islandGen.generateNode(islandGen.findNode(x, y));
		}
		
		private function requestAnyIsland():void {

			var obj:* = islandGen.findAnyIslandNode();
						LogTracer.log("REQUEST ISLAND:"+obj);
			if (obj) islandGen.generateNode(obj);
			
			
		}
		
		
		private var lastMapGen:mapgen2;
		public function onIslandGenerated(e:Event):void {
			try {
				var mapGen:mapgen2 = islandGen.mapGen;
				lastMapGen = mapGen;
				var elevationBytes:ByteArray = mapGen.makeExport("elevation");
					LogTracer.log("ISLADN EXPORT GENERATED");
				channels.islandInitedChannel.send([elevationBytes, 0]);  // send required island information from it's mapgen blueprint instance
			}
			catch (e:Error) {
				channels.sendError(e);
				
			}
			
			
		}
		
	
		
	}

}