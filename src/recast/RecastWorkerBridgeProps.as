package recast 
{
	import flash.concurrent.Mutex;
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class RecastWorkerBridgeProps 
	{
		public var MAX_AGENTS:int = 60;
		public var MAX_AGENT_RADIUS:Number = 0.24*RecastWorkerBridge.WORLD_SCALE;
		public var MAX_SPEED:Number = 3.5*3
		public var MAX_ACCEL:Number = 8.0 * 3

		public var toMainAgentPosBytes:ByteArray;  // agent positions written from AS3 worker (consider using alchemy mem from worker??)
		public var toMainAgentPosMutex:Mutex;
		public var targetAgentPosBytes:ByteArray; // target agent waypoint positions written from primodial
		public var targetAgentPosMutex:Mutex;
		
		public var leaderPosBytes:ByteArray; // leader agent position from center origin written from primodidal 	
		public var originPosBytes:ByteArray; // center origin world position written from primodial
		public var leaderIndex:int = 3;
		
		public var usingChannel2:Boolean = false;
		public var toWorkerVertexBuffer:ByteArray;  
		public var toWorkerIndexBuffer:ByteArray; 
		public var toWorkerBytes:ByteArray; // for generic sync(emulate-sync) use. Ensure RESPONSE_SYNC code is pinged back via toMainChannelSync before continuing.
		public var toWorkerBytesMutex:Mutex;  // to ensure read-only access to workerBytes rource, without writing from outside
		public var toMainBytes:ByteArray;  
		
		public function RecastWorkerBridgeProps() 
		{
			
		}
		
	}

}