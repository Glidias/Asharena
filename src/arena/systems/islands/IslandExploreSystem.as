package arena.systems.islands 
{
	import alternativa.engine3d.core.Camera3D;
	import alternterrain.core.QuadTreePage;
	import alternterrain.objects.HierarchicalTerrainLOD;
	import alternterrain.objects.TerrainLOD;
	import alternterrain.util.TerrainLODTreeUtil;
	import ash.core.Engine;
	import ash.core.System;
	import components.Pos;
	import flash.display3D.Context3D;
	import flash.events.Event;
	import flash.geom.Vector3D;
	import flash.system.Worker;
	import flash.system.WorkerDomain;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import spawners.arena.IslandGenWorker;
	import alternativa.engine3d.alternativa3d;
	import util.SpawnerBundle;
	use namespace alternativa3d;
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
		private var autoFollowCam:Boolean;
		
		private var quadTreePageDict:Dictionary = new Dictionary();
		private var numQuadTreePages:int = 0;
		
		private var lastX:Number;
		private var lastY:Number;
		private var _squaredDistUpdate:Number;
		
		private var zoneSize:Number;

		private var zoneSizeDiv:Number;
		private var maxLowResSample:int = 1024;
		public var zoneVisDistance:Number = .25;
		
		private var treeUtil:TerrainLODTreeUtil = new TerrainLODTreeUtil();
		private var treeUtilOffsetX:int = 0;
		private var treeUtilOffsetY:int = 0;
		private var lastTreeX:int = int.MIN_VALUE;
		private var lastTreeY:int = int.MIN_VALUE;
		
		private var terrainLOD:HierarchicalTerrainLOD;// the list of TerrainLODs and their respective QuadTreePages
		public var loadedPages:Vector.<QuadTreePage>;  // the hierGridArray of loaded QuadTreePages across all levels. This needs to be reshuffled to match new TL location if needed.
		
		private var sampleQuadTreePage:QuadTreePage;
		
		
		
		/*
		 1) terrainlodTreeUtil.update() -> creates hier grid array of quadTreePages -> list of drawn indices + levels
1a) For always available case, create from list of drawn indices as new QuadTreePage(s) into hier grid array (if not yet inside) and into HierTerrainLOD array and set lengths accoridngly. (avakilble case)

when TL reference changes, hier grid array of quadTreePages must reshuffle their quadrant positions at all levels. Todo this:
	a) With new TL reference, check for any quadrants that are no longer applicable. Dispose off all available quadtreePages in those quadrants by iterating hier Grid array. (or cache them temporarily before disposal). 
	b) With new TL reference, check for any available cached quadrant segments... (if got cache)
	c) With new TL reference, check for any quadrants taht are still applcaible. Move quad tree pages in those quadrants respective to the new TL location to their correct hier grid array position. Adjust the QuadTreePages xOrg/zOrg values to match the new TL location.
 Move the terrainLOD object or (or camera+sceneItems), to match the position of camera in relation to terrainLOD TL origin.
 By successfully performing this shift, the next few steps would 


After the update(), (( Not yet available case is for defered instantation/re-get pool reference of QuadTreePage, since nothing needs to be rendered yet until the actual detailed data for QuadTreePage is received. 

Assert in the case where TL reference changes,  update() must return true, ie. occured!.

2) with list of drawn idnices + levels, send respective zonePos+level requests to worker for any missing null QuadTreePages not found in hier grid array cache. (worker to remove any unrequested/unlisted requests on his side). For non-null QuadTreePages within hier grid array cache, it's assumed those were already preloaded beforehand, so just assign them to the rendering HierTerrainLOD array.
3) receive zone+level key from Worker, create/retreive from pool QuadTreePage at hier grid array position and push into HierTerrainLOD array for rendering if applciable (this shuld be applicaable for high priority on demand requests), so long as the position is found in stateLookup bitmapData slot. Update QuadTreePage height data, quadSquare data, and material information accordingly.
))
*/
		
		
		/**
		 * @param   camera		Camera reference to determine what LOD to use.
		 * @param	position	Reference position to determine what zones and islands regions gets spotted while traveling
		 */
		public function IslandExploreSystem(camera:Camera3D, position:Pos=null, zoneSize:Number = 2048, tileSize:Number=256, terrainLOD:HierarchicalTerrainLOD=null) 
		{
			this.camera = camera;
			autoFollowCam = position == null; 
			this.position = position || (new Pos());  
			setUpdateRadius(256);
			
			this.zoneSize = zoneSize;
			zoneSize *= tileSize;
			this.zoneSizeDiv = 1 / zoneSize;
			
			this.terrainLOD = terrainLOD;
			loadedPages = new Vector.<QuadTreePage>(treeUtil.loaderAmount, true);
			sampleQuadTreePage = QuadTreePage.createFlat(0, 0, 128);
			
			if (terrainLOD == null) {
				terrainLOD = new HierarchicalTerrainLOD();  // create a dummy terrainLOD privately
				
			}
			
		}
		
		override public function addToEngine(engine:Engine):void {
			createWorker();
			lastX = -Number.MAX_VALUE;
			lastY = -Number.MAX_VALUE;
			
			
		}
		
		public function setUpdateRadius(val:Number):void {
			var a:Number = Math.sin(Math.PI * .125) * val;
			var b:Number = Math.cos(Math.PI * .125) * val;
			_squaredDistUpdate = a * a + b * b;
		}

		

		
		override public function update(time:Number):void {
			// poll 2d position change to ask worker to check for zones and thus potentially visible islands
			
			if (autoFollowCam) {
				position.x = camera._x;
				position.y = camera._y;
			//	position.z = camera.z;
			
			}
			var x:Number = position.x - lastX;
			var y:Number = position.y - lastY;
			
			if (x * x + y * y < _squaredDistUpdate ) return;
			
			// distance threshold met to request for world update
				x = position.x;
				y = position.y;
				lastX = x;
				lastY = y;
				//throw new Error(y*zoneSizeDiv);
				channels.mainParamsArray.position = 0;
				channels.mainParamsArray.writeFloat(x*zoneSizeDiv);
				channels.mainParamsArray.writeFloat(y*zoneSizeDiv);
				channels.initIslandChannel.send(IslandChannels.ON_POSITION_CHANGE);
				//LogTracer.log(x * zoneSizeDiv + ", " + y * zoneSizeDiv);
			
			

			// natively use rounded off camera position x/y to determine center position of 2x2 boundingSpaceGrid and thus it's TL location.
			var wd:Number = treeUtil.boundingSpace.width * .5;
			var hd:Number = treeUtil.boundingSpace.height * .5;
			var tileMult:Number = 1 / 256;
			var cx:Number = camera._x;
			var cy:Number = -camera._y;
			x = cx*tileMult + treeUtilOffsetX * wd;
			y = cy*tileMult + treeUtilOffsetY * hd;
			x = Math.round( x / wd );
			y = Math.round( y / hd );
			
			var refPositionChanged:Boolean = false;
			if (lastTreeX != x || lastTreeY != y) {
			// If boundingSpaceGridCenter/TL location change, the camera position - boundingSpaceGrid TL location and that's it and readjust world item positions + camera to fit that. Can consider, at this stage, to remove off any items out of view. 
			
			// Now, with the relative camera positsion, call TerrainLODTreeUtil.update(). With any drawn items, update the list of QuadTreePages accordingly across all levels with the TL origin,  determining the zone positions of each quadTreePage to send to worker for processing.	
				//treeUtilOffsetX = x;
				//treeUtilOffsetY = y;
			
				if (lastTreeX != int.MIN_VALUE && lastTreeY != int.MIN_VALUE) {
					reshuffle(x, y);
				}
				lastTreeX = x;
				lastTreeY = y;
				refPositionChanged = true;
				
				LogTracer.log("Update tree util reference:");
			}
			
			// get actual world coordinates of rounded off TL location for treeUtil
				x *= wd;
				y *= hd;
				x -= wd;
				y -= hd;
				if ( treeUtil.update(cx * tileMult - x, cy * tileMult - y, refPositionChanged) ) { // (for now, assume camera isn't re-translated...)
					
					
					
					LogTracer.log("Tree update:" + (lastTreeX) + ", " + (lastTreeY) + ", " + [camera._x * tileMult - x, camera._y * tileMult - y] + " ::: " + treeUtil.levelNumSquares);
					
					resolveLODTreeState();
				}
			
		}
		
		private function resolveLODTreeState():void 
		{
			var len:int = treeUtil.levelNumSquares.length;
			var count:int = 0;
			var data:Vector.<int> = treeUtil.indices;
			for (var level:int = 0; level < len; level++) {
				var sqCount:int = treeUtil.levelNumSquares[level];
				var lvlOffset:int =  treeUtil.loaderOffsets[level];
				for (var u:int; u < sqCount; u++) {
					// (create)/request/reference QuadTreePages to later set into terrainLOD 
					
					var xi:int = data[count++];
					var yi:int = data[count++];
					
					// reference - (if available in loadedPages cache)
					//loadedPages[yi*
					
					// (create) testing phase only
					
					
					// request  - actual worker generation
				}
			}
			
			//
			//if (terrainLOD != null) {  // readjust the render list to match given reference/create list!
				
			//}
		}
		
		private function reshuffle(x:int, y:int):void 
		{
			var toShuffle:Vector.<QuadTreePage> = loadedPages.concat();
			var len:int = loadedPages.length;
			for (var i:int = 0; i < len; i++) {
				// TODO: remove loadedPages[i]
				loadedPages[i] = null;
			}
			
			// check NE
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
			channels.initPrimordial(bgWorker, zoneSize, maxLowResSample, zoneVisDistance);
			LogTracer.log = channels.doTrace;
			 channels.islandInitedChannel.addEventListener(Event.CHANNEL_MESSAGE, onChannelIslandRecieved);
		    
			bgWorker.start();
			
			
		 }
		 
		 private function onChannelIslandRecieved(e:Event):void 
		 {
			 var notifyCode:int = channels.islandInitedChannel.receive();
			channels.receiveParams();
			
			if (notifyCode === IslandChannels.INITED_BLUEPRINT_HEIGHT) {
			//	LogTracer.log("Received bytes:" + channels.workerByteArray.length);
				//LogTracer.log("Received params:" + channels.workerParamsArray.readUTF());
				// Set up new hardcoded Terrain Mesh heights and add island to scene if island is faraway enough
				// Otherwise, if island is close enough, call to sample it accordignly!
				
				//	setTimeout(requestWorkerIslandColors, 700);
				//requestWorkerIslandColors();
			}
			else if (notifyCode === IslandChannels.INITED_BLUEPRINT_COLOR) {
				// Apply material to currently active terrain mesh that was previously added to scene
				
				//LogTracer.log("Received bytes:" + channels.workerByteArray.length);
				//	LogTracer.log("Received params:" + channels.workerParamsArray.readUTF());
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