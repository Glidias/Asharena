package  
{
	import arena.systems.islands.IslandChannels;
	import arena.systems.islands.IslandGeneration;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.system.MessageChannel;
	import flash.system.Worker;
	import flash.utils.ByteArray;
	import flash.utils.setTimeout;
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
			
				var requestCode:* = channels.initIslandChannel.receive();
				
				if (requestCode is String) {
					islandGen.generateIslandSeed(requestCode);
				}
				else if (requestCode === IslandChannels.INITED_BLUEPRINT_HEIGHT) {
					requestAnyIsland();  //
				}
				else if (requestCode === IslandChannels.INITED_BLUEPRINT_COLOR) {
					onIslandGenerated2();
				}
				 
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
				channels.workerByteArray.position  = 0;
				channels.workerByteArray.length = 0;
				channels.workerParamsArray.position = 0;
				channels.workerParamsArray.writeUTF( mapGen.savedSeed);
				channels.workerParamsArray.position = 0;
				
				
				var elevationBytes:ByteArray = mapGen.makeExport("elevation", 0, false, channels.workerByteArray );
				LogTracer.log("ISLADN EXPORT GENERATED: INITED_BLUEPRINT_HEIGHT:" + channels.workerByteArray.length + " bytes.");
				elevationBytes.position = 0;
				channels.islandInitedChannel.send(IslandChannels.INITED_BLUEPRINT_HEIGHT);  // send required island information from it's mapgen blueprint instance
				
		
			}
			catch (e:Error) {
				channels.sendError(e);
				
			}
			
			
			
			
		}
		
		public function onIslandGenerated2():void {
			try {
			
				var mapGen:mapgen2 = lastMapGen;
				
				channels.workerByteArray.position  = 0;
				channels.workerByteArray.length = 0;
				
				channels.workerParamsArray.position = 0;
				channels.workerParamsArray.writeUTF( mapGen.savedSeed);
				
				
				var elevationBytes:ByteArray = mapGen.makeExport("biomediffuse", 0, false, channels.workerByteArray );
					LogTracer.log("ISLADN EXPORT GENERATED: INITED_BLUEPRINT_COLOR:" + channels.workerByteArray.length + " bytes." );
				elevationBytes.position  = 0;
				channels.islandInitedChannel.send(IslandChannels.INITED_BLUEPRINT_COLOR);  // send required island information from it's mapgen blueprint instance
				
			
			}
			catch (e:Error) {
				channels.sendError(e);
			}
			
		}
		
	
		
	}

}