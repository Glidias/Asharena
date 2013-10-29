package arena.systems.islands 
{
	import flash.events.Event;
	import flash.system.MessageChannel;
	import flash.system.Worker;
	import flash.utils.ByteArray;
	import flash.utils.getDefinitionByName;
	/**
	 * Cross-communication between IslandGen worker and Main application
	 * @author Glenn Ko
	 */
	public class IslandChannels 
	{
		public var doTrace:Function;
		public var initZoneChannel:MessageChannel;      // to listen from main
		public var initIslandChannel:MessageChannel;  // to listen from main
		public var islandInitedChannel:MessageChannel;  // to notify main
		public var toMainErrorChannel:MessageChannel;  // to notify main
		public var toMainTraceChannel:MessageChannel;  // to notify main
		
		public var workerByteArray:ByteArray;   // edit from worker, readonly from main
		
		// event codes
		// Tier 1
		public static const INITED_BLUEPRINT_HEIGHT:int = 0;	 // low-res height data (33x33)
		public static const INITED_BLUEPRINT_COLOR:int = 1;  	 // low-res color texture map ( <= 1024x1024 )
		
		// Tier 2
		public static const INITED_DETAIL_SPLAT:int = 2; 	 // detail rgb splat map. SplatTexureMaterial to be created on Main  
		public static const INITED_DETAIL_BIOMETILES:int = 3;  // detail tile map. TileAtlasTextureMaterial to be created on Main  (<= 1024x1024 )
		public static const INITED_DETAIL_HEIGHT:int = 4; // detail height map   (<= 129x129 ) // naively recalculated for the different TerrainLODs
	
		public function IslandChannels() 
		{
			
		}
		
		public function initPrimordial(worker:Worker):void {
			worker.setSharedProperty("initZoneChannel", initZoneChannel=Worker.current.createMessageChannel(worker) );
			worker.setSharedProperty("initIslandChannel", initIslandChannel=Worker.current.createMessageChannel(worker));
			worker.setSharedProperty("islandInitedChannel", islandInitedChannel = worker.createMessageChannel(Worker.current));
			worker.setSharedProperty("toMainErrorChannel", toMainErrorChannel = worker.createMessageChannel(Worker.current));
			worker.setSharedProperty("toMainTraceChannel", toMainTraceChannel = worker.createMessageChannel(Worker.current));
			
			workerByteArray = new ByteArray();
			workerByteArray.shareable = true;
			worker.setSharedProperty("workerByteArray", workerByteArray);
			
			
			toMainErrorChannel.addEventListener(Event.CHANNEL_MESSAGE, onErrorReceived);
			toMainTraceChannel.addEventListener(Event.CHANNEL_MESSAGE, onTraceReceived);
			
			doTrace = getDefinitionByName("haxe::Log").trace;
		}
		
		private function onErrorReceived(e:Event):void 
		{
			throw new Error( toMainErrorChannel.receive() );
		}
		
		private function onTraceReceived(e:Event):void {
			doTrace( toMainTraceChannel.receive());
		}
		
		public function initFromChild():void {
			initZoneChannel = Worker.current.getSharedProperty("initZoneChannel");
			initIslandChannel = Worker.current.getSharedProperty("initIslandChannel");
			islandInitedChannel = Worker.current.getSharedProperty("islandInitedChannel");
			toMainErrorChannel = Worker.current.getSharedProperty("toMainErrorChannel");
			toMainTraceChannel = Worker.current.getSharedProperty("toMainTraceChannel");
			workerByteArray = Worker.current.getSharedProperty("workerByteArray");
		}
		
		public function sendTrace(str:Object):void {
			toMainTraceChannel.send(str.toString());
		}
		
		public function sendError(err:Error):void {
			toMainErrorChannel.send(err.name + "\n"+err.message + "\n"+ err.getStackTrace());
		}
		
	
		
	}

}