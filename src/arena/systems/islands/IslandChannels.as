package arena.systems.islands 
{
	import flash.events.Event;
	import flash.system.MessageChannel;
	import flash.system.Worker;
	import flash.utils.getDefinitionByName;
	/**
	 * ...
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
		
		public function IslandChannels() 
		{
			
		}
		
		public function initPrimordial(worker:Worker):void {
			worker.setSharedProperty("initZoneChannel", initZoneChannel=Worker.current.createMessageChannel(worker) );
			worker.setSharedProperty("initIslandChannel", initIslandChannel=Worker.current.createMessageChannel(worker));
			worker.setSharedProperty("islandInitedChannel", islandInitedChannel = worker.createMessageChannel(Worker.current));
			worker.setSharedProperty("toMainErrorChannel", toMainErrorChannel = worker.createMessageChannel(Worker.current));
			worker.setSharedProperty("toMainTraceChannel", toMainTraceChannel = worker.createMessageChannel(Worker.current));
			
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
		}
		
		public function sendTrace(str:Object):void {
			toMainTraceChannel.send(str.toString());
		}
		
		public function sendError(err:Error):void {
			toMainErrorChannel.send(err.name + "\n"+err.message + "\n"+ err.getStackTrace());
		}
		
	
		
	}

}