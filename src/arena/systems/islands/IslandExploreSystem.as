package arena.systems.islands 
{
	import alternativa.engine3d.core.Camera3D;
	import ash.core.System;
	import components.Pos;
	import flash.events.Event;
	import flash.system.Worker;
	import flash.system.WorkerDomain;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import spawners.arena.IslandGenWorker;
	import util.LogTracer;
	/**
	 * For exploring the entire carribean, syncronoising with background AS3 workers to generate island terrains!
	 * @author Glenn Ko
	 */
	public class IslandExploreSystem extends System
	{
		private var bgWorker:Worker;
		private var channels:IslandChannels;
		private var camera:Camera3D;

		public var position:Pos;
		
		private var quadTreePageDict:Dictionary = new Dictionary();
		private var numQuadTreePages:int = 0
		
		/**
		 * @param   camera		Camera reference to determine what LOD to use.
		 * @param	position	Reference position to determine what zones and islands regions gets spotted while traveling
		 */
		public function IslandExploreSystem(camera:Camera3D, position:Pos=null) 
		{
			this.camera = camera;
			this.position = position || (new Pos());  
		}
		
		override public function update(time:Number):void {
			// poll position change to ask worker to check for zones and thus potentially visible islands
			
			
			// poll camera position constantly for a change in minimum LOD tree, fill with dummy QuadTreePages, than send area segment requests to worker if minimum LOD tree chnages.
			
		}
		
		private function createWorker():void
		 {
		   // create the background worker
		   var workerBytes:ByteArray = IslandGenWorker.BYTES;
		   bgWorker = WorkerDomain.current.createWorker(workerBytes);
		 
		   // listen for worker state changes to know when the worker is running
		 //  bgWorker.addEventListener(Event.WORKER_STATE, workerStateHandler);
		   
		   // set up communication between workers using 
		   // setSharedProperty(), createMessageChannel(), etc.
		   // ... (not shown)
			channels = new IslandChannels();
			channels.initPrimordial(bgWorker);
			LogTracer.log = channels.doTrace;
			 channels.islandInitedChannel.addEventListener(Event.CHANNEL_MESSAGE, onChannelIslandRecieved);
		    
			bgWorker.start();
			
			
		 }
		 
		 private function onChannelIslandRecieved(e:Event):void 
		 {
			 var notifyCode:int = channels.islandInitedChannel.receive();
			channels.receiveParams();
			
			if (notifyCode === IslandChannels.INITED_BLUEPRINT_HEIGHT) {
				LogTracer.log("Received bytes:" + channels.workerByteArray.length);
				LogTracer.log("Received params:" + channels.workerParamsArray.readUTF());
				// Set up new hardcoded Terrain Mesh heights and add island to scene if island is faraway enough
				// Otherwise, if island is close enough, call to sample it accordignly!
				
				//	setTimeout(requestWorkerIslandColors, 700);
				//requestWorkerIslandColors();
			}
			else if (notifyCode === IslandChannels.INITED_BLUEPRINT_COLOR) {
				// Apply material to currently active terrain mesh that was previously added to scene
				
				LogTracer.log("Received bytes:" + channels.workerByteArray.length);
					LogTracer.log("Received params:" + channels.workerParamsArray.readUTF());
				// Set up mesh
			}
			else if (notifyCode === IslandChannels.INITED_DETAIL_HEIGHT) {
				
			}
			
			// continue process by sending signal success!
		 }
		 
		 private function removeWorker():void {  // tbd
			 
		 }
		
	}

}