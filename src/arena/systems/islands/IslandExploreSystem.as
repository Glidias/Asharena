package arena.systems.islands 
{
	import alternativa.engine3d.core.Camera3D;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.materials.FillMaterial;
	import alternterrain.core.QuadSquareChunk;
	import alternterrain.core.QuadTreePage;
	import alternterrain.objects.HierarchicalTerrainLOD;
	import alternterrain.objects.TerrainLOD;
	import alternterrain.util.TerrainLODTreeUtil;
	import ash.core.Engine;
	import ash.core.System;
	import components.Pos;
	import flash.display.Shape;
	import flash.display3D.Context3D;
	import flash.events.Event;
	import flash.geom.Point;
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
		public var pooledPages:Vector.<QuadTreePage>;
		public var lenPooledPages:int = 0;
		
		private var lodDrawIndices:Vector.<Vector.<int>>;
		private var sampleQuadTreePage:QuadTreePage;
		private var previewMats:Vector.<FillMaterial>;
		
		public var startZonePosition:Point =  new Point(0,0);
		
		
		
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

		public var debugShape:Shape = new Shape();
		
		
		/**
		 * @param   camera		Camera reference to determine what LOD to use.
		 * @param	position	Reference position to determine what zones and islands regions gets spotted while traveling
		 */
		public function IslandExploreSystem(camera:Camera3D, position:Pos=null, zoneSize:Number = 2048, tileSize:Number=256, terrainLOD:HierarchicalTerrainLOD=null, sceneTransform:Object3D=null) 
		{
			this.sceneTransform = sceneTransform;
			QuadSquareChunk.registerClassAliases();
			
			this.tileSize = tileSize;
			this.camera = camera;
			autoFollowCam = position == null; 
			this.position = position || (new Pos());  
			setUpdateRadius(256);
			
			this.zoneSize = zoneSize;
			zoneSize *= tileSize;
			this.zoneSizeDiv = 1 / zoneSize;
			
			this.terrainLOD = terrainLOD;
			loadedPages = new Vector.<QuadTreePage>(treeUtil.loaderAmount, true);
			pooledPages = new Vector.<QuadTreePage>();
			sampleQuadTreePage = QuadTreePage.createFlat(0, 0, 128);
			
			if (terrainLOD == null) {
				this.terrainLOD = new HierarchicalTerrainLOD();  // create a dummy terrainLOD privately
			}
			
			setupDrawIndices();
			
			clearTerrainLOD();
			
			setupPreviewMats();
			
			//terrainLOD.visible = false;
		}
		
		private function setupDrawIndices():void 
		{
			lodDrawIndices = new Vector.<Vector.<int>>();
			for (var i:int = 0; i < terrainLOD.lods.length; i++) {
				lodDrawIndices[i] = new Vector.<int>();
			}
		}
		

		
		private var tileSize:Number;
		private var sceneTransform:Object3D;
		private static const PREVIEW_COLORS:Vector.<uint> = new <uint>[0x44EEFF,0xFF0000, 0x00FF00, 0x0000FF];
		
		private function setupPreviewMats():void 
		{
			previewMats = new Vector.<FillMaterial>();
			var len:int = PREVIEW_COLORS.length;
			for ( var i:int = 0; i < len; i++) {
				previewMats.push( new FillMaterial(PREVIEW_COLORS[i], .4) );
			}
		}
		
		private function clearTerrainLOD():void 
		{

			for (var i:int = 0; i < terrainLOD.lods.length; i++) {  // reset
				terrainLOD.lods[i].gridPagesVector = new Vector.<QuadTreePage>();
				terrainLOD.lods[i].visible = false;
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
			var cy:Number;
			var cx:Number;
			var hd:Number;
			var wd:Number;
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
			
	
			// determine if camera position needs to be resetted and "startZonePosition" needs to be readjusted.
			wd =  treeUtil.boundingSpace.width * tileSize * .5;
			hd =  treeUtil.boundingSpace.height * tileSize * .5;
			var hWrap:Boolean = Math.abs(camera._x) >= wd;
			var vWrap:Boolean = Math.abs(camera._y) >= hd;
			if (  hWrap || vWrap ) {
				LogTracer.log("Resetting startZonePosition:"+(camera._x) + ", "+camera._y + [startZonePosition.x + ", "+startZonePosition.y]);
				if (hWrap) {
					startZonePosition.x += camera._x / wd;  // offset relatively
					camera._x %= wd;
					camera.transformChanged = true;
				
				
				}
				if (vWrap) {
					startZonePosition.y += camera._y / hd;
					camera._y %= hd;
					camera.transformChanged = true;
				}
				
			}
		
			// natively use rounded off camera position x/y to determine center position of 2x2 boundingSpaceGrid and thus it's TL location.
			wd = treeUtil.boundingSpace.width * .5;
			hd = treeUtil.boundingSpace.height * .5;
			var tileMult:Number = 1 / tileSize;
	
			cx =  (camera._x);
			cy =  -(camera._y);
			x = Math.floor(cx * tileMult);
			y = Math.floor(cy * tileMult);
			x = Math.round( x / wd ) + treeUtilOffsetX;  // get top left
			y = Math.round( y / hd ) + treeUtilOffsetY;
			x--;
			y--;
			
			var lx:int = Math.floor( x +startZonePosition.x);
			var ly:int = Math.floor( y +startZonePosition.y);
			
			var refPositionChanged:Boolean = false;
			if (lastTreeX != lx || lastTreeY != ly) {
			// If boundingSpaceGridCenter/TL location change, the camera position - boundingSpaceGrid TL location and that's it and readjust world item positions + camera to fit that. Can consider, at this stage, to remove off any items out of view. 
			
			// Now, with the relative camera positsion, call TerrainLODTreeUtil.update(). With any drawn items, update the list of QuadTreePages accordingly across all levels with the TL origin,  determining the zone positions of each quadTreePage to send to worker for processing.	
			
			
				if (lastTreeX != int.MIN_VALUE && lastTreeY != int.MIN_VALUE) {
					reshuffle(x, y);
				}
				lastTreeX = lx;
				lastTreeY = ly;

				
				LogTracer.log("Update tree util reference:"+[lx,ly]);
				
			
				terrainLOD.x =  x*wd*tileSize;
				terrainLOD.y =  -y*hd*tileSize;
	
				refPositionChanged = true;

			}
			
			// get actual tile coordinates of rounded off TL location for treeUtil

				if ( treeUtil.update((camera._x - terrainLOD.x) *tileMult, -(camera._y - terrainLOD.y)*tileMult, refPositionChanged) ) { // (for now, assume camera isn't re-translated...)
					
	
				//	LogTracer.log("Tree update:" );
					
					resolveLODTreeState();
				}
			
		}
		
		
		
		private function createDummyPage(level:int):QuadTreePage {
			var page:QuadTreePage = lenPooledPages > 0 ? pooledPages[--lenPooledPages] : sampleQuadTreePage.clonePage();
			page.material = previewMats[level];
			return page; 
		}
		
		//public var debugResolved:Boolean = false;
		private function resolveLODTreeState():void 
		{
			//if (debugResolved) return;
			//debugResolved = true;
			
			var len:int = treeUtil.levelNumSquares.length;
			var count:int = 0;
			
			debugShape.graphics.clear();
			debugShape.graphics.beginFill(0xFF0000, .5);
			debugShape.graphics.lineStyle(1, 0);

			
			
			var size:int = treeUtil.smallestSquareSize * tileSize;
			//var debugCount:int =  0;
			var data:Vector.<int> = treeUtil.indices;
			for (var level:int = 0; level < len; level++) {
				var sqCount:int;
				var lvlOffset:int =  treeUtil.loaderOffsets[level];
				var numColumns:int = (treeUtil.boundWidth >> level);
				var lod:TerrainLOD = terrainLOD.lods[level];
				var lastDraws:Vector.<int> = lodDrawIndices[level];
				var u:int;
				var page:QuadTreePage;
				var pageLen:int = lod.gridPagesVector.length;
				
				sqCount = lastDraws.length;
				for ( u = 0 ; u < sqCount; u++) {   // remove currently viewed pages
					var indexer:int =  lastDraws[u];
					if (treeUtil.drawBits.get(indexer ) == 0 ) {
						page = loadedPages[indexer]; 
						if (page != null) {
							loadedPages[indexer] = null;
							pooledPages[lenPooledPages++] = page;
							if (page.index >= 0) {
								lod.removePage(page, pageLen);  // TODO: Importatn! Recycle any chunk states within page tree if available.
								pageLen--;
								lod.flushPage(page);
							}
						}	
					}
				}
				lod.gridPagesVector.length = pageLen;
				
				
				sqCount = treeUtil.levelNumSquares[level];   // add necessary pages
				lastDraws.length = sqCount;
				for (u=0; u < sqCount; u++) {
					// (create)/request/reference QuadTreePages to later set into terrainLOD 
					
					var xi:int = data[count++];
					var yi:int = data[count++];
					//if (level !=2) continue;
					lastDraws[u] = indexer= lvlOffset + yi * numColumns + xi;
					// reference - (if available in loadedPages cache)
					page = loadedPages[indexer];
		
					
					if (page== null) {  	// (create) testing phase only / or request - actual worker generation
						// (create)
						page = createDummyPage(level);
						loadedPages[lvlOffset + yi * numColumns + xi] = page;
					}
					//else {
					//  ensure page is added to render list
						if (page.index < 0) {
							lod.addPage(page);
						}
						// ensure page is positioned correctly		
						page.xorg  = (xi * size);
						page.zorg =  (yi * size);
						page.heightMap.XOrigin = page.xorg;
						page.heightMap.ZOrigin = page.zorg;
					//}
					
					
	
					debugShape.graphics.drawRect(xi*(8<<level), yi*(8<<level), (8<<level),(8<<level));
					
				}
				
				//throw new Error(data);
				// debugging
				lod.visible = lod.gridPagesVector.length != 0;  // this isn't needed for none (create) case.
				//lod.debug = true;
				//debugCount+=lod.gridPagesVector.length;
				//break;
			}//
			
		}
		
		private function reshuffle(x:int, y:int):void 
		{
			LogTracer.log("Reshuffling!");
			return;
			
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