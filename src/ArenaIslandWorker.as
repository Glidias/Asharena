package  
{
	import arena.systems.islands.IslandGeneration;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.system.MessageChannel;
	import flash.system.Worker;
	/**
	 * To manage generation of islands, terrain, props, etc. asyncronously.
	 * @author Glenn Ko
	 */
	public class ArenaIslandWorker extends Sprite
	{
		// TIER 1
		private var islandGen:IslandGeneration;
		private var initZoneChannel:MessageChannel;      // to listen from main
		private var islandInitedChannel:MessageChannel;  // to notify main

		// TIER 2
		//private var ; // to notify main
		
		public function ArenaIslandWorker() 
		{
			init();
		}
		
		private function init():void 
		{
			// TIER 1
			initZoneChannel = Worker.current.getSharedProperty("initZoneChannel");
			initZoneChannel.addEventListener(Event.CHANNEL_MESSAGE, onZoneInitHandler);
			
			islandInitedChannel = Worker.current.getSharedProperty("islandInitedChannel");
			
			islandGen = new IslandGeneration();
			islandGen.addEventListener(Event.COMPLETE, onIslandGenerated);
			
			addChild(islandGen);
		}
		
		public function onZoneInitHandler(e:Event):void {
			var params:Array = initZoneChannel.receive();
			islandGen.init(params[0], params[1]);
		}
		
		public function onIslandGenerated(e:Event):void {
			islandInitedChannel.send("");  // send required island information from it's mapgen blueprint instance
		}
		
	
		
	}

}