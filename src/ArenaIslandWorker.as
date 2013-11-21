package  
{
	import alternterrain.core.HeightMapInfo;
	import alternterrain.core.QuadChunkCornerData;
	import alternterrain.core.QuadCornerData;
	import alternterrain.core.QuadSquare;
	import alternterrain.core.QuadSquareChunk;
	import arena.systems.islands.IslandChannels;
	import arena.systems.islands.IslandGeneration;
	import arena.systems.islands.jobs.CreateIslandResource;
	import arena.systems.islands.jobs.IslandResource;
	import arena.systems.islands.jobs.IsleJob;
	import arena.systems.islands.jobs.SampleScaledHeight;
	import arena.systems.islands.KDZone;
	import arena.systems.islands.KDNode;
	import de.polygonal.ds.LinkedQueue;
	import de.polygonal.ds.mem.IntMemory;
	import de.polygonal.ds.mem.MemoryManager;
	import de.polygonal.ds.mem.ShortMemory;
	import de.polygonal.ds.Prioritizable;
	import de.polygonal.ds.PriorityQueue;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.system.MessageChannel;
	import flash.system.Worker;
	import flash.utils.ByteArray;
	import flash.utils.clearTimeout;
	import flash.utils.Dictionary;
	import flash.utils.Endian;
	import flash.utils.setTimeout;
	import hashds.ds.alchemy.GrayscaleMap;
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
		
		private var heightMapSample:HeightMapInfo;
		private var quadCornerDataSample:QuadCornerData;
		private var quadChunkDataSample:QuadChunkCornerData;
		private var heightDataSample:IntMemory;
		
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
			LogTracer.error = channels.sendError;
			
			var tilesAcross:int = channels ?  channels.minLODTreeTileDistance : 128;
			QuadCornerData.setFixedBufferSize(21844);  // for(n...levels) count += tilesAcross*tilesAcross; tilesAcross *=.5;
			QuadCornerData.fillBuffer();
			heightMapSample = new HeightMapInfo();
			heightMapSample.RowWidth = tilesAcross+1;
			heightMapSample.XSize = heightMapSample.RowWidth;
			heightMapSample.ZSize = heightMapSample.RowWidth;
			heightMapSample.XOrigin = 0;
			heightMapSample.ZOrigin = 0;
			heightMapSample.setFlat(tilesAcross, 256); // hardcoded tileSize
			quadCornerDataSample = QuadCornerData.createRoot(0, 0, tilesAcross * 256);  // hardcoded tileSize
			quadCornerDataSample.Square.AddHeightMap(quadCornerDataSample, heightMapSample);
			quadChunkDataSample = new QuadChunkCornerData();
			quadChunkDataSample.Square = quadCornerDataSample.Square.GetQuadSquareChunk(quadCornerDataSample, 0 );
			quadCornerDataSample.Square.WriteQuadSquareChunkInline(quadChunkDataSample.Square, quadCornerDataSample, 0);
			
			heightDataSample = new IntMemory(heightMapSample.RowWidth * heightMapSample.RowWidth);
			SampleScaledHeight.MEM = heightDataSample;
			//throw new Error(QuadSquare.DEBUG_ADDCOUNT);
			

			
			//IntMemory.toVector(heightDataSample, -1, -1, heightMapSample.Data);
			//ShortMemory.toVector
			//quadCornerDataSample.Square.RecomputeErrorAndLighting(quadCornerDataSample);
			//throw new Error(quadCornerDataSample.Square.errorList);
			
			loaderOffsets =  Worker.current.getSharedProperty("loaderOffsets");
			loaderAmount = Worker.current.getSharedProperty("loaderAmount");
			loaderTilesAcross = channels.zoneTileDistance / channels.minLODTreeTileDistance;
			
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
			_curRunningJob = null;
					_jobRunning = false;
			//if (_jobRunning) channels.sendError( new Error("SHOULD NOT BE!:"+_curRunningJob) );
			resumeNewJob();
		}
		
		private function onIslandInitHandler(e:Event):void 
		{
			try {

				var requestCode:* = channels.initIslandChannel.receive();
				
				// Job queue deployment
				if (requestCode === IslandChannels.ON_POSITION_CHANGE) {
					handlePositionChange();
					if (!_jobRunning && jobQueue.head) attemptStartNewCurJob();
				}
				else if (requestCode === IslandChannels.ON_LODTREE_CHANGE) {
					handlePositionChange(true);
					handleLODChange();
					if (!_jobRunning && jobQueue.head) attemptStartNewCurJob();
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
				
				try {
					
					if (preExecuteJob(job)) {
					//	validateJobQueue();
						jobQueue.remove(job);
						//if (jobQueue.contains(job)) throw new Error("STIll contains job!");
					
						_curRunningJob = job;
						job.next = null;
						job.prev = null;
						_jobRunning = true;	
						job.execute();
					}
					else {
						attemptStartNewCurJob();
					}
				}
				catch (e:Error) {
					channels.sendError( e  );
				}
			}
			else {
				_jobRunning = false;
				LogTracer.log("Jobqueue finsihed.");
			}
		}
		
		
		private function preExecuteJob(job:IsleJob):Boolean   // handle any specific special cases for specific job types, only called from attemptStartNewCurJob
		{
			
			var classe:Class = Object(job).constructor;
			
			
			if (classe === CreateIslandResource) {
				LogTracer.log("Starting job:"+job);
				if ( (job as CreateIslandResource).pending  ) {
					
					throw new Error("SHOULD NOT BE!111");
				}
				if ( (job as CreateIslandResource).index == -1  ) {
					
					throw new Error("SHOULD NOT BE!222");
				}
				
				// if job is outside visual range....consider adding it to defered list instead, or just replacing it at the tail
				
				(job as CreateIslandResource).zone.createIslandJobs.remove(job);	
			}
			else if (classe === SampleScaledHeight) {
				
				if ( validateSampleJob( job as SampleScaledHeight) ) {
					
					(job as SampleScaledHeight).zone.samplingJobs[job.index] = null;
					return true;
				}
				else {
					setTimeoutToResumeNewJob(1);
					return false;
				}
				// consider if sampleScaledHeight has all IslandResource dependencies parsed, else lookup releavant CreateIslandResource to prioritize to jobQueue.head and recall attemptStartNewCurJob!!
				
				//attemptStartNewCurJob();
				// or
				// job.execute();
				//return;
			}
			return true;
		}
		
		private function validateSampleJob(job:SampleScaledHeight):Boolean 
		{
			
			var allAvailable:Boolean = true;
			///*
			for each( var node:KDNode in job.foundNodes) {
				if (node.islandResource == null) {
					if ( !(node.job.pending ? pendingJobQueue : jobQueue).contains(node.job)) {
						throw new Error("Doesnt't have job in list!");
					}
					(node.job.pending ? pendingJobQueue : jobQueue).remove(node.job);
					node.job.pending = false;
					
					LogTracer.log("VIsiting create island job! " + node.job);
					
					node.job.next = null;
					node.job.prev = null;
					jobQueue.prepend( node.job );
					
					allAvailable = false;
				}
			}
			//*/
			
		
			return allAvailable;
		}
		
		private var _curTimeout:uint = 0;

		private function setTimeoutToResumeNewJob(delay:Number):void {
			clearTimeout(_curTimeout);
			_curTimeout = setTimeout( resumeNewJob, delay);
		}
		
		private function onJobFinished(job:IsleJob):void {
			var classe:Class = Object(job).constructor;
		
			

			
			if (classe === CreateIslandResource) {  // can do a specific setTimeout to resumeNewJob...
				
				LogTracer.log("Job finished:"+job);
				// is CreateIslandResource kdZone within 1 visible range bound? If so, can notify main that island has been spotted??
				if (false) {  // send request to Main first, handle async response cases from Main
					
				}
				else {
					_curRunningJob = null;
					_jobRunning = false;
					setTimeoutToResumeNewJob(  200);
				
				}
			}
			else if (classe === SampleScaledHeight) {  // send request to Main first, handle async response cases from Main
				if ( !(job as SampleScaledHeight).cancelled && !GrayscaleMap.isFlat(heightDataSample, 0) ) {  // TODO: consider predetermine flatness instaed of adding in job!
					(job as SampleScaledHeight).zone.samplingJobs[job.index] = null;
					sendHeightSample(job as SampleScaledHeight);
				}
				else {
					_curRunningJob = null;
					_jobRunning = false;
					setTimeoutToResumeNewJob(  200);
				}
	
			}
			else { // can do a default setTimeout to resumeNewJob
				_curRunningJob = null;
				_jobRunning = false;
				setTimeoutToResumeNewJob(  200);
			}
		}
		
		private function sendHeightSample(job:SampleScaledHeight):void 
		{
			
			var mem:IntMemory = heightDataSample;
			channels.workerByteArray.position = 0;
			//LogTracer.log([job.zone.x, job.zone.y, job.sampleX , job.sampleY]);
			channels.workerByteArray.writeInt( job.zone.x );
			channels.workerByteArray.writeInt(job.zone.y);
			
			channels.workerByteArray.writeFloat(job.sampleX);
			channels.workerByteArray.writeFloat(job.sampleY);
			channels.workerByteArray.writeByte(job.level);

			channels.workerByteArray.writeBytes(MemoryManager._instance._bytes, mem.offset , mem.bytes);
		
		
			IntMemory.toVector(mem, -1, -1, heightMapSample.Data);
			QuadCornerData.BI = 0;
			quadCornerDataSample.Square.AddHeightMapInlineFast(quadCornerDataSample, heightMapSample);
			//quadCornerDataSample.Square.AddHeightMap(quadCornerDataSample, heightMapSample);
			QuadCornerData.BI = 0;
			var error:int = quadCornerDataSample.Square.RecomputeErrorAndLightingInline(quadCornerDataSample);
			//var error:int = quadCornerDataSample.Square.RecomputeErrorAndLighting(quadCornerDataSample);
			QuadCornerData.BI = 0;
			//quadCornerDataSample.Square.WriteQuadSquareChunkInline(quadChunkDataSample.Square, quadCornerDataSample, error);
			quadChunkDataSample.Square = quadCornerDataSample.Square.GetQuadSquareChunk(quadCornerDataSample, error);
			//LogTracer.log("BOUNDS:" + [quadCornerDataSample.Square.MinY, quadCornerDataSample.Square.MaxY]);
			quadChunkDataSample.Square.writeByteArray(channels.workerByteArray);
			
			QuadCornerData.BI = 0;
			// TODO: create quadSquareChunk bytes form above sample!
			
			
			
			channels.islandInitedChannel.send(IslandChannels.INITED_DETAIL_HEIGHT);
		}
		
		public function resumeNewJob():void {
			if (!_jobRunning) attemptStartNewCurJob();
		}
		
		
		private var lodChangeCount:int = int.MIN_VALUE;
		
		private function handleLODChange():void // this is triggered as well if LOD hierahical tree grid changes.
		{
		
			var node:KDNode;
			lodChangeCount++;
			
			var jobInsertCount:int = 0;
			var jobsKept:int = 0;
			
			channels.mainByteArray.position = 0;
			
			var numLevels:int = channels.mainParamsArray.readByte();
			//var notYetLoadedKDNodes:Dictionary = new Dictionary();
			var bmSizeSml:int = IslandGeneration.BM_SIZE_SMALL;
			
			for (var level:int = 0 ; level < numLevels; level++)  {  // per level
				var offset:int = loaderOffsets[level];
				var len:int = channels.mainParamsArray.readInt();
				var tilesAcross:int = (loaderTilesAcross >> level);
				var kdWidth:Number = bmSizeSml/tilesAcross;
				for (var i:int = 0; i < len; i++) {  // samples per level
					var fx:Number=channels.mainByteArray.readFloat();
					var fy:Number = channels.mainByteArray.readFloat();
	
					var xi:int = Math.floor(fx);
					var yi:int = Math.floor(fy);
					var seed:uint = islandGen.getSeed( xi, yi );
					var zone:KDZone = zoneHash[seed];
					if (zone == null) {
						LogTracer.log("ExCEPTION!::: Zone not found at: "+xi + ", "+yi);
						continue;
					}
					//if (zone && zone.x != xi && zone.y != yi) throw new Error("Mismatch seed:" + [zone.x, xi, zone.y, yi]);
					
					fx -= xi;
					fy -= yi;
					
					var lx:int= int(fx* tilesAcross);
					var ly:int =  int(fy*tilesAcross);
					//
					
					
					var sampleJob:SampleScaledHeight = zone.samplingJobs[offset + ly * tilesAcross + lx];
					if (sampleJob != null) {  // simply prioritize already-created sampling job??
						//jobQueue.remove(sampleJob);
						//jobQueue.prepend(sampleJob);
						nodes = sampleJob.foundNodes;
						sampleJob.timestamp = lodChangeCount;
						if (!jobQueue.contains(sampleJob)) {
							throw new Error("EXCEPTION:  sampleJob in array not found in JobQueue!!!");
						}
						jobsKept++;
						
						/*
						for each(node in nodes) {
							if (node.islandResource == null && node.job != _curRunningJob) {
								notYetLoadedKDNodes[node] = true;
							}
						}
						*/
					}
					else {  // create new sample job if required by querying sample region into zone's KDTree to gather any possible islands. With, that , create sampling job for that area.
						//if (zone.x == 0 && zone.y == 0) throw new Error("A");
						//LogTracer.log(zone+" finding nodes:"+[zone.root, fx*bmSizeSml, fy*bmSizeSml, kdWidth,kdWidth]);
						var nodes:Vector.<KDNode> = islandGen.findNodes(zone.root, fx*bmSizeSml, fy*bmSizeSml, kdWidth,kdWidth );
						if (nodes!=null) {
							//LogTracer.log("Found island KDNodes in vincitity..." + islandGen.numFoundNodes);
							sampleJob = new SampleScaledHeight();
							sampleJob.init(nodes, fx, fy, level);
							jobInsertCount++;
							sampleJob.zone = zone;
							sampleJob.index = offset + ly*tilesAcross + lx;
							zone.samplingJobs[sampleJob.index] = sampleJob;
							jobQueue.prepend(sampleJob);
							validateJobQueue("EARLY");
							sampleJob.timestamp = lodChangeCount;
							//LogTracer.log("Prioritizing sample job:" + sampleJob);
							
							/*
							for each(node in nodes) {	
								if (node.islandResource == null && node.job != _curRunningJob) {
									notYetLoadedKDNodes[node] = true;
								}
							}
							*/
						}
						
					}
				}
			}
			
			/*
			for (var k:* in notYetLoadedKDNodes) {
				node = k;
				(node.job.pending ? pendingJobQueue : jobQueue).remove(node.job);
				node.job.pending = false;
				node.job.next = null;
				node.job.prev = null;
				jobQueue.prepend( node.job );
				//LogTracer.log("Prioritizing node job:" + node.job + ", "+(node.job === jobQueue.head));
			}
			*/
			
			//	LogTracer.log("Final head job:" + jobQueue.head);
			
			for (var j:IsleJob = jobQueue.head; j != null; j = nextJob) {
				var nextJob:IsleJob = j.next;
				var jobSample:SampleScaledHeight = j as SampleScaledHeight;
				if (jobSample && jobSample.timestamp != lodChangeCount) {
					if (checkHits(jobQueue.head, j) > 1) throw new Error("EXCEESS:"+checkHits(jobQueue.head, j));
					jobQueue.remove(j);
					
					jobSample.zone.samplingJobs[jobSample.index] = null; 
					j.next = null;
					j.prev = null;
					///*
					
					if (jobQueue.contains(j)) {
						//jobQueue.remove(j);
						//if (jobQueue.contains(j)) 
						//LogTracer.log("ERR");
						
						throw new Error("Error: STILL CONTAINS jobNode even though removed it!" + checkIndexOf(jobQueue.head, j)  + ", "+ (j===jobQueue.head) + ", "+(j===jobQueue.tail));
					}
					
					//*/
					//LogTracer.log("removing outdated sampling job:" + jobSample);
				}
			}
			
			
			// Debug asserts
			if (_jobRunning && _curRunningJob is SampleScaledHeight) {
				jobSample = _curRunningJob as SampleScaledHeight;
				if ( jobSample.timestamp != lodChangeCount) {
					jobSample.cancel();
					jobSample.zone.samplingJobs[jobSample.index] = null;
					LogTracer.log("Cur running sampling job cancelled");
				}
			}
			
			
			for (j = jobQueue.head; j != null; j = j.next) {
				
				jobSample = j as SampleScaledHeight;
				if (jobSample && jobSample.timestamp != lodChangeCount) {  // TODO: fix this exception
					LogTracer.log("Serious exceptioN!: Outdated job sample still detected in jobQueue!");
				}
				
			}
			
		
			
			LogTracer.log("Sampling jobs inserted:"+jobInsertCount + " :: pending:"+jobsKept);
			validateJobQueue();
			
			
		}
		
		private function checkHits(h:IsleJob, target:IsleJob):int {
			var count:int = 0;
			while (h != null) {
				if (h === target) count++;
				h = h.next;
			}
			return count;
		}
		
		private function checkIndexOf(h:IsleJob, target:IsleJob):int {
			var count:int = 0;
			while (h != null) {
				if (h === target) return count;
				count++;
				h = h.next;
			}
			return -1;
		}
		
		
		

		///*
		private function handlePositionChange(debug:Boolean=false):void   // this is triggered when moving a certain distance threshold, or when teleporting-in initially.
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
			
			if (debug) LogTracer.log("REceiving center position:" + x + ", " + y);
			
					//(job.zone.x + job.node.boundMaxX * IslandGeneration.BM_SIZE_SMALL_I < minX ||  job.zone.y + job.node.boundMaxY * IslandGeneration.BM_SIZE_SMALL_I < minY || job.zone.x + job.node.boundMinX * IslandGeneration.BM_SIZE_SMALL_I > maxX || job.zone.y + job.node.boundMinY * IslandGeneration.BM_SIZE_SMALL_I > maxY)
			/*
			for (job = pendingJobQueue.head as CreateIslandResource; job != null; job = nextJob) {
				var nextJob:CreateIslandResource = job.next as CreateIslandResource;
				if (job.zone.x + job.node.boundMaxX * IslandGeneration.BM_SIZE_SMALL_I < minX ||  job.zone.y + job.node.boundMaxY * IslandGeneration.BM_SIZE_SMALL_I < minY || job.zone.x + job.node.boundMinX * IslandGeneration.BM_SIZE_SMALL_I > maxX || job.zone.y + job.node.boundMinY * IslandGeneration.BM_SIZE_SMALL_I > maxY) {
					continue;
				}
				pendingJobQueue.remove(job);
				if (pendingJobQueue.contains(job)) throw new Error("XCEPTION!: SHould not be in pendingJobQueue!");
				job.pending = false;
				job.next = null;
				job.prev = null;
				LogTracer.log("Out of view island added:" + job);
				if (jobQueue.contains(job)) throw new Error("EXCEPTION:  SHould not be in jobqueue!");
				jobQueue.append(job);
				
			}
			*/
			
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
									//validateJobQueue();
								}
							}
							else {		// already parsed, no longer in jobQueue
								job.dispose();
							}
						}
						
						///*
						len = zone.samplingJobs.length;
						for (i = 0; i < len; i++) {
							var samplingJob:SampleScaledHeight = zone.samplingJobs[i];
							//samplingJob.cancel();
							if (samplingJob) {
								// this is a syncronous job at the moment, so remove it instantly is fine!
								jobQueue.remove(samplingJob);
								samplingJob.zone.samplingJobs[samplingJob.index] = null;
								samplingJob.dispose();
								//validateJobQueue();
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
							
							zone = new KDZone(); // inzstantly set up a zone tree
							zone.x = xii;
							zone.y = yii;
							zone.samplingJobs = new Vector.<SampleScaledHeight>(loaderAmount, true);
							LogTracer.log("New zone created:" + zone.x + " , " + zone.y);
							//LogTracer.log("Adding zone to generate at: "+[xii, yii]);
							islandGen.init(xii, yii);
							zone.root = islandGen.rootNode;
							for each(var node:KDNode in islandGen.seededNodes) {  // for any newly instantiated KDZone, add jobs to create islands accordignly!
								
								// naively create jobs regardless of range or within range?
								job = new CreateIslandResource();
								job.zone = zone;
								job.node = node;
								node.job = job;
								//LogTracer.log("Adding island to generate: "+node.seed);
								job.init(new IslandResource(), node.seed + "-1");
								
								if ( true || (job.zone.x + job.node.boundMaxX * IslandGeneration.BM_SIZE_SMALL_I < minX ||  job.zone.y + job.node.boundMaxY * IslandGeneration.BM_SIZE_SMALL_I < minY || job.zone.x + job.node.boundMinX * IslandGeneration.BM_SIZE_SMALL_I > maxX || job.zone.y + job.node.boundMinY * IslandGeneration.BM_SIZE_SMALL_I > maxY) ) {
									job.pending = true;
									pendingJobQueue.append(job);
									LogTracer.log("Pending job:" + job + ", "+job.getLocation(IslandGeneration.BM_SIZE_SMALL_I));
								}
								else {
									//LogTracer.log("Inserting job:" + job);
									job.priority = getDist(x, y, zone, node);
									jobInsertion.add(job); // insertion sort by priority distance
									//jobQueue.append(job);  // naive add
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
			validateJobQueue();
		}
		
		private function validateJobQueue(appednStr:String=""):Boolean {
			var lastJ:IsleJob = null;

			for (var j:IsleJob = jobQueue.head; j != null; j = j.next) {
				if (j.prev != lastJ) throw new Error("Previous mismatch!:"+lastJ + " , "+j.prev + appednStr);
				lastJ = j;
			}
			if (lastJ != jobQueue.tail) throw new Error("Tail mismatch!"+ appednStr);
			
			return true;
			
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
		private var loaderOffsets:Vector.<int>;
		private var loaderAmount:int;
		private var loaderTilesAcross:int;
		
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