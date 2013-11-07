package  
{
	import arena.systems.islands.IslandChannels;
	import arena.systems.islands.IslandGeneration;
	import arena.systems.islands.jobs.CreateIslandResource;
	import arena.systems.islands.jobs.IslandResource;
	import arena.systems.islands.jobs.IsleJob;
	import arena.systems.islands.jobs.SampleScaledHeight;
	import arena.systems.islands.KDZone;
	import arena.systems.islands.KDNode;
	import de.polygonal.ds.LinkedQueue;
	import de.polygonal.ds.Prioritizable;
	import de.polygonal.ds.PriorityQueue;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.system.MessageChannel;
	import flash.system.Worker;
	import flash.utils.ByteArray;
	import flash.utils.clearTimeout;
	import flash.utils.Dictionary;
	import flash.utils.setTimeout;
	import hashds.ds.DLMixList_arena_systems_islands_jobs_IsleJob;
	import hashds.ds.DMixPriorityList_arena_systems_islands_jobs_IsleJob;
	import jp.progression.commands.lists.SerialList;
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
		
		private var pendingJobQueue:DLMixList_arena_systems_islands_jobs_IsleJob;
		
		private var jobQueue:DLMixList_arena_systems_islands_jobs_IsleJob;
		private var jobInsertion:DMixPriorityList_arena_systems_islands_jobs_IsleJob;
		
		private var zoneRect:RectI;
		private var zoneHash:Dictionary;
		
		private var _jobRunning:Boolean = false;
		private var _curRunningJob:IsleJob;
		
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
			
			
			zoneRect = new RectI();
			zoneHash = new Dictionary();
			
			channels = new IslandChannels();
			channels.initFromChild();
			
			LogTracer.log = channels.sendTrace;
			
			// Job management
			jobQueue = new DLMixList_arena_systems_islands_jobs_IsleJob();
			jobInsertion = new DMixPriorityList_arena_systems_islands_jobs_IsleJob();
			IsleJob.ON_COMPLETE.add(onJobFinished);
			_jobRunning = false;
			
			pendingJobQueue = new DLMixList_arena_systems_islands_jobs_IsleJob();
			
			
			
			
			// Island channels
			islandGen = new IslandGeneration();
			CreateIslandResource.GENERATOR = islandGen;
			CreateIslandResource.ZONE_TILE_LENGTH = channels.zoneTileDistance;
			CreateIslandResource.MAX_GENERATE_TILE_LENGTH = channels.maxIslandTileDistance;
			
			//islandGen.addEventListener(Event.COMPLETE, onIslandGenerated);
			
			addChild(islandGen);
			
			
			// TIER 1
		
			channels.initZoneChannel.addEventListener(Event.CHANNEL_MESSAGE, onZoneInitHandler);
			channels.initIslandChannel.addEventListener(Event.CHANNEL_MESSAGE, onIslandInitHandler);
			
			
			// ALL TIERS
			channels.mainResponseDone.addEventListener(Event.CHANNEL_MESSAGE, onMainResponseDone);
		

		}
		
		private function onMainResponseDone(e:Event):void 
		{
			resumeNewJob();
		}
		
		private function onIslandInitHandler(e:Event):void 
		{
			try {
			
				var requestCode:* = channels.initIslandChannel.receive();
				
				// Job queue deployment
				if (requestCode === IslandChannels.ON_POSITION_CHANGE) {
					handlePositionChange();
				}
				else if (requestCode === IslandChannels.ON_LODTREE_CHANGE) {
					handleLODChange();
				}
				
				/*  // For testing
				if (requestCode is String) {
					islandGen.generateIslandSeed(requestCode);
				//	islandGen.size *= .5;
				}
				else if (requestCode === IslandChannels.INITED_BLUEPRINT_HEIGHT) {
					requestAnyIsland();  //
				}
				else if (requestCode === IslandChannels.INITED_BLUEPRINT_COLOR) {
					onIslandGenerated2();
				}
				*/
				 
			}
			catch (e:Error) {
				channels.sendError(e);
			}
		}
		
		
		
	

		
		private function attemptStartNewCurJob():void { 
			clearTimeout(_curTimeout);
			var job:IsleJob;
			job = jobQueue.head;
			if (job != null) {
				
				jobQueue.remove(job);
				_curRunningJob = job;
				job.next = null;
				job.prev = null;
				_jobRunning = true;
				preExecuteJob(job);
			}
			else {
				_jobRunning = false;
				LogTracer.log("Jobqueue finsihed.");
			}
		}
		
		
		private function preExecuteJob(job:IsleJob):void   // handle any specific special cases for specific job types, only called from attemptStartNewCurJob
		{
			
			var classe:Class = Object(job).constructor;
			LogTracer.log("Starting job:"+job);
			
			if (classe === CreateIslandResource) {
				if ( (job as CreateIslandResource).pending  ) {
					
					throw new Error("SHOULD NOT BE!111");
				}
				if ( (job as CreateIslandResource).index == -1  ) {
					
					throw new Error("SHOULD NOT BE!222");
				}
				
				// if job is outside visual range....consider adding it to defered list instead, or just replacing it at the tail
				if (false) {
					//jobQueue.append(job);
					LogTracer.log("Defering CreateIslandResource");
					_jobRunning = false;
					_curRunningJob = null;
					setTimeoutToResumeNewJob( 200); // avoid unnecessary recursion by setting timeout instead
					return;
				}
				else {
					(job as CreateIslandResource).zone.createIslandJobs.remove(job);	
				}
			
			}
			else if (classe === SampleScaledHeight) {
				// consider if sampleScaledHeight has all IslandResource dependencies parsed, else lookup releavant CreateIslandResource to prioritize to jobQueue.head and recall attemptStartNewCurJob!!
				
				//attemptStartNewCurJob();
				// or
				// job.execute();
				//return;
			}
			
			job.execute();
			
		}
		
		private var _curTimeout:uint = 0;

		private function setTimeoutToResumeNewJob(delay:Number):void {
			clearTimeout(_curTimeout);
			_curTimeout = setTimeout( resumeNewJob, delay);
		}
		
		private function onJobFinished(job:IsleJob):void {
			var classe:Class = Object(job).constructor;
			_jobRunning = false;
			_curRunningJob = null;
			LogTracer.log("Job finsihed:"+job);

			
			if (classe === CreateIslandResource) {  // can do a specific setTimeout to resumeNewJob...
				
				// is CreateIslandResource kdZone within 1 visible range bound? If so, can notify main that island has been spotted??
				if (false) {  // send request to Main first, handle async response cases from Main
					
				}
				else {
					setTimeoutToResumeNewJob(  300);
				
				}
			}
			else if (classe === SampleScaledHeight) {  // send request to Main first, handle async response cases from Main
				
				
			}
			else { // can do a default setTimeout to resumeNewJob
				setTimeoutToResumeNewJob(  300);
			}
		}
		
		public function resumeNewJob():void {
			if (!_jobRunning) attemptStartNewCurJob();
		}
		
		
		
		private function handleLODChange():void // this is triggered if LOD hierahical tree grid changes.
		{
			
			/*
			var seed:uint;
			var zone:KDZone;
			var createIslandJob:CreateIslandResource;
			var createIslandRes:IslandResource;
			var len:int;
			var i:int;
			for (key in zoneHash) {
				zone = zoneHash[seed];
				
				len = zone.createIslandJobs.length;
				for (i = 0; i < len; i++) {
					createIslandJob = zone.createIslandJobs[i];
					createIslandRes = createIslandJob.resource;
					if (createIslandRes.heightMap != null) { 
						
					}
					else {
						
					}
				}
				
			}
			*/
		}
		
		
		

		///*
		private function handlePositionChange():void   // this is triggered when moving a certain distance threshold, or when teleporting-in initially.
		{
			var seed:uint;
			var key:*;
			var zone:KDZone;
			channels.mainParamsArray.position = 0;
			var x:Number = channels.mainParamsArray.readFloat();
			var y:Number = channels.mainParamsArray.readFloat();
			const RADIUS:Number = channels.zoneDistance;
			var posX:Number = x;
			var posY:Number = y;
			
		
			var minX:Number = x - RADIUS;
			var minY:Number =  y - RADIUS;
			var maxX:Number =  x + RADIUS;
			var maxY:Number =  y + RADIUS;
			
			// determine any possible new zones to set up
			var xi:int = Math.floor(minX);
			var yi:int = Math.floor(minY);
			var xD:int= Math.ceil(maxX);  
			var yD:int = Math.ceil(maxY);
			var job:CreateIslandResource;
			
			
			///*
			for (job = pendingJobQueue.head as CreateIslandResource; job != null; job = nextJob) {
				var nextJob:CreateIslandResource = job.next as CreateIslandResource;
				if (job.zone.x + job.node.boundMaxX * IslandGeneration.BM_SIZE_SMALL_I < minX ||  job.zone.y + job.node.boundMaxY * IslandGeneration.BM_SIZE_SMALL_I < minY || job.zone.x + job.node.boundMinX * IslandGeneration.BM_SIZE_SMALL_I > maxX || job.zone.y + job.node.boundMinY * IslandGeneration.BM_SIZE_SMALL_I > maxY) {
					continue;
				}
				pendingJobQueue.remove(job);
				job.pending = false;
				job.next = null;
				job.prev = null;
				LogTracer.log("Out of view island added:" + job);
				jobQueue.append(job);
			}
			//*/
			
			if (zoneRect.x != xi || zoneRect.y != yi || zoneRect.maxX != xD || zoneRect.maxY != yD) {
				// if zoneRect has changed..
				LogTracer.log("Zoning has changed!");
				// update current zoneRect to new zoneRect
				zoneRect.x = xi;
				zoneRect.y = yi;
				zoneRect.maxX = xD;
				zoneRect.maxY = yD;
				
				// BASIC PROCEDURES
					// BASIC PROCEDURES				
				// delete any zones that lie outside new zoneRect!
			//	/*
			
				var jobsToRemove:Array = [];
				for (key in zoneHash) {
					zone = zoneHash[key];
					if ( zone.x >= xD || zone.y >= yD || zone.x + RADIUS  <= xi || zone.y + RADIUS  <= yi ) {
						//LogTracer.log("Removing zone...:" + zone);
						var len:int = zone.createIslandJobs.len;
						
						for (var i:int = 0; i < len; i++) {
							job = zone.createIslandJobs.vec[i] as CreateIslandResource;
							
							if (job.resource.heightMap == null) { // not yet parsed,
								if (_jobRunning && job=== _curRunningJob) {  // job is currently running outside jobQueue and needs to be cancelled 
									LogTracer.log("Cancelling current job!:"+job);
									job.cancel();
									_jobRunning = false;
									_curRunningJob = null;
								}
								else {		// job is still pending in jobQueue or pendingJobQueue
									jobsToRemove.push(job);
									(job.pending ? pendingJobQueue : jobQueue).remove(job );
								}
							}
							else {		// already parsed, no longer in jobQueue
								job.dispose();
							}
						}
						delete zoneHash[key];  
					}
				}
				
				for each( job in jobsToRemove) {
					job.zone.createIslandJobs.remove(job);
				}
			//	*/
				

				
				// go through all possible zone grid coordinates and check for any new zones that are not yet created. (for naive mode, simply 9 zones!)
				for (var xii:int = xi; xii < xD; xii++) {
					for (var yii:int = yi; yii < yD; yii++ ) {
						
						seed = islandGen.getSeed(xii, yii);
						zone = zoneHash[seed];
						
						if (!zone) {
							
							zone = new KDZone(); // instantly set up a zone tree
							zone.x = xii;
							zone.y = yii;
							//LogTracer.log("Adding zone to generate at: "+[xii, yii]);
							islandGen.init(xii, yii);
							zone.root = islandGen.rootNode;
							for each(var node:KDNode in islandGen.seededNodes) {  // for any newly instantiated KDZone, add jobs to create islands accordignly!
								
								// naively create jobs regardless of range or within range?
								job = new CreateIslandResource();
								job.zone = zone;
								job.node = node;
								
								//LogTracer.log("Adding island to generate: "+node.seed);
								job.init(new IslandResource(), node.seed + "-1");
								
								if (job.zone.x + job.node.boundMaxX * IslandGeneration.BM_SIZE_SMALL_I < minX ||  job.zone.y + job.node.boundMaxY * IslandGeneration.BM_SIZE_SMALL_I < minY || job.zone.x + job.node.boundMinX * IslandGeneration.BM_SIZE_SMALL_I > maxX || job.zone.y + job.node.boundMinY * IslandGeneration.BM_SIZE_SMALL_I > maxY) {
									job.pending = true;
									pendingJobQueue.append(job);
									//LogTracer.log("Pending job:" + job + ", "+job.getLocation(IslandGeneration.BM_SIZE_SMALL_I) + " ::: "+[x,y]);
								}
								else {
									//LogTracer.log("Inserting job:" + job);
									job.priority = getDist(x, y, zone, node);
									jobInsertion.add(job); // insertion sort by priority distance
								}
								zone.createIslandJobs.push(job);
							}
							
							zoneHash[seed] = zone;
						}
					}
				}
				
				
				if (jobInsertion.head != null) {
					jobQueue.append2(jobInsertion.head, jobInsertion.tail);
					jobInsertion.head = null;
					jobInsertion.tail = null;
					LogTracer.log("JOBs inserted: Are there new jobs running atm?"+_jobRunning);
					
				}
				//
				

			}
			if (!_jobRunning && jobQueue.head) attemptStartNewCurJob();
		}
		
	//	
		private function getDist(posX:Number, posY:Number, zone:KDZone, node:KDNode):Number 
		{
			var bmSizeI:Number = IslandGeneration.BM_SIZE_SMALL_I;
			
			var minX:Number = zone.x + node.boundMinX * bmSizeI;
			var maxX:Number= zone.x + node.boundMaxX * bmSizeI;
			var minY:Number= zone.y + node.boundMinY * bmSizeI;
			var maxY:Number = zone.y + node.boundMaxY * bmSizeI;
			
			if (posX > maxX || posY > maxY || posX < minX || posY < minY) {  // if position is outside node's bounds
				 // get squared distances between position and outer boundary along each dimension
				var x:Number = posX < minX ? minX : maxX;
				var y:Number = posY < minY ? minY : maxY;
				// square distances along each dimension and check which dimension is longer and use that as the L1-norm distance
				x -= posX;  
				y -= posY;
				x *= x;
				y *= y;
				return x >= y ? x : y;
			}
			//else {  // position is inside node bounds, this should only happen once or none at all!

			
			return 0;
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
		/*
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
		*/
		
	
		
	}

}

 class RectI {
	public var x:int=-int.MAX_VALUE;
	public var y:int=-int.MAX_VALUE;
	public var maxX:int=0;
	public var maxY:int=0;
	
	public function RectI() {
		
	
	}
	
}