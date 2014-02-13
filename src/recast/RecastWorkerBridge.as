package recast 
{
	import flash.concurrent.Mutex;
	import flash.system.MessageChannel;
	import flash.system.Worker;
	import flash.utils.ByteArray;
	import util.AS3WorkerBridge;
	/**
	 * App-specific bridge class to communicate with Recast/Detour AS3 Worker and Main app vicey-versa.
	 * @author Glenn Ko
	 */
	public class RecastWorkerBridge extends AS3WorkerBridge
	{
		
		public static const WORLD_SCALE:Number = 5;
		
		

		private var _props:RecastWorkerBridgeProps;	
		
		public var toWorkerChannel:MessageChannel;

		
		public var toMainChannelSync:MessageChannel;  
		
		// currently for RESPONSE_CREATE_ZONE_DONE only
		public var toMainChannel:MessageChannel;
	

		
		// toWorkerBytes commands
		public static const CMD_ADD_AGENTS:int = 0; // not yet
		public static const CMD_SET_AGENTS:int = 1;  //  (removes all existing agents. setup a new list of agents to use within the simulation using toWorkerBytes!)
		public static const CMD_REMOVE_AGENTS:int = 2; // not yet (need to add later.)
		public static const CMD_MOVE_AGENTS:int = 3; // not yet (required.)
		public static const CMD_CREATE_ZONE:int = 4;  //  (create a new set of wavefront obstacles under toWorkerVertex/Index buffers on app-specific default plane)
		
		public static const CMD_3D_NEW_ZONE:int = 5; // not yet (create a new 3d zone under toWorkerVertex/Index buffers using standard 3d notation)
		public static const CMD_CREATE_NEW_WAVEFRONT:int = 6; // not yet (create a new zone directly from wavefront .obj bytes under toWorkerBytes!)
		
		// toMainChannel commands
		public static const RESPONSE_CREATE_ZONE_DONE:int = 0;	

		public function RecastWorkerBridge() 
		{
			if (!ignoreConstructor) {
				_props = new RecastWorkerBridgeProps();
				sharedProperties = _props;
			}
		}
		
		
		 public function $initAsPrimordial(worker:Worker):void {
			
			super.initAsPrimordial(worker);
			
		}
		
		public function get props():RecastWorkerBridgeProps 
		{
			return _props;
		}
		
	
		/*
		override public function initAsPrimordial(worker:Worker):void {
			
			super.initAsPrimordial(worker);
			
		}
		*/
		
		
		
	}

}