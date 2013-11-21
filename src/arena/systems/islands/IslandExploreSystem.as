package arena.systems.islands 
{
	import alternativa.engine3d.core.Camera3D;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.materials.FillMaterial;
	import alternterrain.core.HeightMapInfo;
	import alternterrain.core.QuadSquareChunk;
	import alternterrain.core.QuadTreePage;
	import alternterrain.objects.HierarchicalTerrainLOD;
	import alternterrain.objects.TerrainLOD;
	import alternterrain.util.TerrainLODTreeUtil;
	import ash.core.Engine;
	import ash.core.System;
	import components.Pos;
	import eu.nekobit.alternativa3d.materials.WaterMaterial;
	import flash.display.Shape;
	import flash.display.Sprite;
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
	 * For exploring the entire infinite carribean, syncronoising with background AS3 workers to generate island terrains!
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
		private var _zoneLODX:Number;
		private var _zoneLODY:Number;
		
		
		/*
		 
		SPECS:
		 * HierTreeRegion: (16 km by 16km)
			 Hiertree travel threshold update distance: 8km (half of above)
			Bucket: (8km by 8km)
			  Bucket travel threshold update distance: 4km (half of above)
		 * Zone: (16km by 16km)
			  Sample: (250m by 250m  to  2km by 2km (or higher)..at varying LODs.)
		 * Tile (2m by 2m or higher ..at varying LODs)

		 1) terrainlodTreeUtil.update() -> creates hier grid array of quadTreePages -> list of drawn indices + levels
1a) For always available case, create from list of drawn indices as new QuadTreePage(s) into hier grid array (if not yet inside) and into HierTerrainLOD array and set lengths accoridngly. (avakilble case) (DONE)

when TL reference changes, hier grid array of quadTreePages must reshuffle their quadrant positions at all levels. Todo this:
	a) With new TL reference, check for any quadrants that are no longer applicable. Dispose off all available quadtreePages in those quadrants by iterating hier Grid array. (or cache them temporarily before disposal). 
	b) With new TL reference, check for any available cached quadrant segments... (if got cache)
	c) With new TL reference, check for any quadrants taht are still applcaible. Move quad tree pages in those quadrants respective to the new TL location to their correct hier grid array position. Adjust the QuadTreePages xOrg/zOrg values to match the new TL location.
 Move the terrainLOD object or (or camera+sceneItems), to match the position of camera in relation to terrainLOD TL origin.
 By successfully performing this shift, the next few steps would 


2) with list of drawn idnices + levels, send respective zonePos+level requests to worker for any missing null QuadTreePages not found in hier grid array cache. (worker to remove any unrequested/unlisted requests on his side). For non-null QuadTreePages within hier grid array cache, it's assumed those were already preloaded beforehand, so just assign them to the rendering HierTerrainLOD array. (DONE)

3) receive zone+level key from Worker, create/retreive from pool QuadTreePage at hier grid array position and push into HierTerrainLOD array for rendering if applciable (this shuld be applicaable for high priority on demand requests), so long as the position is found in stateLookup bitmapData slot. Update QuadTreePage height data, quadSquare data, and material information accordingly.  (wip...)

4) TODO: Remove outdated Job requests on Worker end...for LOD sample requests... For any zones that are removed off context, need to ensure their samplign jobs ar eremoved as well (Doesn't seem to happen....).

))
*/

		public var debugShape:Shape = new Shape();
		public var debugSprite:Sprite = new Sprite();
		private var debugRectDict:Dictionary = new Dictionary();
		private function createDebugRect(x:Number, y:Number, width:Number, height:Number, color:uint):Shape {
			var shape:Shape = new Shape();
			shape.graphics.beginFill(color, .25);
			shape.graphics.drawRect(0, 0, width, height);
			shape.x = x;
			shape.y = y;
			debugSprite.addChild(shape);
			return shape;
		}
		
		/**
		 * @param   camera		Camera reference to determine what LOD to use.
		 * @param	position	Reference position to determine what zones and islands regions gets spotted while traveling
		 */
		public function IslandExploreSystem(camera:Camera3D, position:Pos=null, zoneSizeT:Number = 2048, tileSize:Number=256, terrainLOD:HierarchicalTerrainLOD=null, waterMaterial:WaterMaterial=null) 
		{
			this.waterMaterial = waterMaterial;
			//this.waterPlane = waterPlane || (new Object3D());
			QuadSquareChunk.registerClassAliases();
			
			this.tileSize = tileSize;
			this.camera = camera;
			autoFollowCam = position == null; 
			this.position = position || (new Pos());  
			setUpdateRadius(256);
			
			this.zoneSizeTiles = zoneSizeT;
			zoneSizeT *= tileSize;
			this.zoneSize = zoneSizeT;
			this.zoneSizeDiv = 1 / zoneSizeT;
			
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
		//private var waterPlane:Object3D;
		private var waterMaterial:WaterMaterial;
		private static const PREVIEW_COLORS:Vector.<uint> = new <uint>[0x44EEFF,0xFFFF00, 0x00FF00, 0x0000FF];
		private var zoneSizeTiles:int;
		
		private function setupPreviewMats():void 
		{
			previewMats = new Vector.<FillMaterial>();
			var len:int = PREVIEW_COLORS.length;
			for ( var i:int = 0; i < len; i++) {
				previewMats.push( new FillMaterial(PREVIEW_COLORS[i], 1) );
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

			private function reshuffle(x:int, y:int):void 
		{
			
			//throw new Error("Reshuffling! Not yet DONE!");
			LogTracer.log("Reshuffling required");
			
			
			return;
			
			var toShuffle:Vector.<QuadTreePage> = loadedPages.concat();
			var len:int = loadedPages.length;
			for (var i:int = 0; i < len; i++) {
				// TODO: remove loadedPages[i]
				var page:QuadTreePage = loadedPages[i];
				
				loadedPages[i] = null;
			}
			
			// need to flush moved pages (for now) if not using xy transform procedure
			
			// check NE

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
			
			debugFlushAll = false;
	
			
			if (x * x + y * y < _squaredDistUpdate ) return;
			
			
			// determine if camera position needs to be resetted and "startZonePosition" needs to be readjusted.
			wd =  treeUtil.boundingSpace.width * tileSize * .5; 
			hd =  treeUtil.boundingSpace.height * tileSize *.5; 

			var hWrap:Boolean = Math.abs(camera._x) >= wd;
			var vWrap:Boolean = Math.abs(camera._y) >= hd;
			if (  hWrap || vWrap ) {
	
				
				if (hWrap) {
					if (Math.floor(camera._x / wd) >= 2) throw new Error("SHOU>LD NOT ECCEED WD");
					startZonePosition.x += Math.floor(camera._x / wd);  // offset relatively
					camera._x %= wd;
					camera.transformChanged = true;
				}
				if (vWrap) {
					if (Math.floor(camera._y / hd) >= 2) throw new Error("SHOU>LD NOT ECCEED  HD");
					startZonePosition.y -= Math.floor(camera._y / hd);
					camera._y %= hd;
					camera.transformChanged = true;
				}
							
				if (waterMaterial != null) {
					waterMaterial.syncFollowCamera(camera);
				
				}

				LogTracer.log("Resetting startZonePosition bucket offsets:"+(startZonePosition.x*2) + ", "+(startZonePosition.y*2));
			}
			
			
			// Send workd update
				// distance threshold met to request for world update
					if (autoFollowCam) {
					position.x = camera._x;
					position.y = camera._y;
				//	position.z = camera.z;
				}
				x = position.x;
				y = position.y;
				lastX = x;
				lastY = y;
				//throw new Error(y*zoneSizeDiv);
				channels.mainParamsArray.position = 0;
				channels.mainByteArray.position = 0;
				
				x = x * zoneSizeDiv + startZonePosition.x * wd*zoneSizeDiv;
				y = -y * zoneSizeDiv + startZonePosition.y * hd * zoneSizeDiv;	
				// send camera center position in zone units
				channels.mainParamsArray.writeFloat(x);
				channels.mainParamsArray.writeFloat(y);
				// LogTracer.log("Writing position:" + x + ", "+y);
				
				// Hardcoded determination
				_zoneLODX = -.5 + Math.round(x*2) *.5;
				_zoneLODY = -.5 + Math.round(y*2) *.5;
				
		
			// natively use rounded off camera position x/y to determine center position of 2x2 boundingSpaceGrid and thus it's TL location.
			wd = treeUtil.boundingSpace.width * .5;
			hd = treeUtil.boundingSpace.height * .5;
			var tileMult:Number = 1 / tileSize;
	
			cx =  (camera._x);
			cy =  -(camera._y);
			x = Math.round(cx * tileMult);
			y = Math.round(cy * tileMult);
			x = Math.round( x / wd );  // get top left
			y = Math.round( y / hd );
			

			var lx:int = Math.floor( x )  +startZonePosition.x*2;
			var ly:int = Math.floor( y ) + startZonePosition.y * 2;
		
			
			
			
			var refPositionChanged:Boolean = false;
			if (lastTreeX != lx || lastTreeY != ly) {
			// If boundingSpaceGridCenter/TL location change, the camera position - boundingSpaceGrid TL location and that's it and readjust world item positions + camera to fit that. Can consider, at this stage, to remove off any items out of view. 
			
			// Now, with the relative camera positsion, call TerrainLODTreeUtil.update(). With any drawn items, update the list of QuadTreePages accordingly across all levels with the TL origin,  determining the zone positions of each quadTreePage to send to worker for processing.	
				
			
			// TODO: try and figure out position 
				
				
				x--;
				y--;
				
				
				
				if (lastTreeX != int.MIN_VALUE && lastTreeY != int.MIN_VALUE) {
					reshuffle(x, y);
					
					debugFlushAll = true;
				}
				lastTreeX = lx;
				lastTreeY = ly;

				LogTracer.log("Tree update:" + [lx, ly]);
				
			
				terrainLOD.x =  x*wd*tileSize;
				terrainLOD.y =  -y * hd * tileSize;
				//waterPlane.x = terrainLOD._x + wd*tileSize;
				//waterPlane.y = terrainLOD._y - hd*tileSize;
	
				refPositionChanged = true;

			}
			else if (hWrap || vWrap) LogTracer.log(" !!! SHOULD  NOT not be! Should reshuffle tree due to change!:"+[lastTreeX,lastTreeY,lx,ly]);
			
			// get actual tile coordinates of rounded off TL location for treeUtil

				if ( treeUtil.update((camera._x - terrainLOD.x) *tileMult, -(camera._y - terrainLOD.y)*tileMult, refPositionChanged) ) { // (for now, assume camera isn't re-translated...)
					
	
					LogTracer.log("LOD Tree state update: "+_zoneLODX + ", "+_zoneLODY );
					
					resolveLODTreeState();
					channels.initIslandChannel.send(IslandChannels.ON_LODTREE_CHANGE);
				}
				else {
					channels.initIslandChannel.send(IslandChannels.ON_POSITION_CHANGE);
				}
			
		}
		
		private var debugFlushAll:Boolean = false;
		
		private function createDummyPage(level:int):QuadTreePage {
			var page:QuadTreePage = lenPooledPages > 0 ? pooledPages[--lenPooledPages] : sampleQuadTreePage.clonePage();
			page.material = previewMats[level];
			return page; 
		}
		
		//public var debugResolved:Boolean = false;
		private function resolveLODTreeState():void 
		{
			//x * zoneSizeDiv + startZonePosition.x * wd*zoneSizeDiv;
			
			//if (debugResolved) return;
			//debugResolved = true;
			
			var len:int = treeUtil.levelNumSquares.length;
			var count:int = 0;
			channels.mainParamsArray.writeByte(len);
			
			debugShape.graphics.clear();
			//debugShape.graphics.beginFill(0xFF0000, .5);
			debugShape.graphics.lineStyle(1, 0);

			
			
			
			//var debugCount:int =  0;
			var data:Vector.<int> = treeUtil.indices;
			
			var size:int = treeUtil.smallestSquareSize * tileSize;
			
			for (var level:int = 0; level < len; level++) {
				
				var sqCount:int;
				
		
				var rowMult:Number = 1 / (treeUtil.boundWidth >> level);
				
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
					if ( debugFlushAll || treeUtil.drawBits.get(indexer ) == 0 ) {
						page = loadedPages[indexer]; 
					
						if (page != null) {
							//	LogTracer.log("To remove page");
							loadedPages[indexer] = null;
							pooledPages[lenPooledPages++] = page;
							if (debugRectDict[page]) {  // debug
								//LogTracer.log("To remove sprite");
									debugSprite.removeChild(debugRectDict[page]);
									delete debugRectDict[page];
									
								}
							if (page.index >= 0) {
								lod.removePage(page, pageLen);  // TODO: Importatn! Recycle any chunk states within page tree if available.
								pageLen--;
								
								lod.flushPage(page);
							}
						}	
					}
					/*
					else {
						debugShape.graphics.beginFill(0xFF0000, .5);
						var realIndex:int = indexer - lvlOffset;
						debugShape.graphics.drawRect( (realIndex%numColumns) * (8<< level),int(realIndex/numColumns)*(8<<level),(8 << level),(8 << level));
						debugShape.graphics.beginFill(0xFF0000, 0);
					}
					*/
				}
				lod.gridPagesVector.length = pageLen;
				
				
				sqCount = treeUtil.levelNumSquares[level];   // add necessary pages
				lastDraws.length = sqCount;

				
				var rqcount:int = 0;

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
						/*
						page = createDummyPage(level);
						loadedPages[lvlOffset + yi * numColumns + xi] = page;
						lod.addPage(page);
						page.xorg  = (xi * size);
						page.zorg =  (yi * size);
						page.heightMap.XOrigin = page.xorg;
						page.heightMap.ZOrigin = page.zorg;
						
						*/
						// request
						//LogTracer.log("Logging request..." + (xi*rowMult) + ", "+(yi*rowMult));
						///*
						channels.mainByteArray.writeFloat(_zoneLODX+xi*rowMult);
						channels.mainByteArray.writeFloat(_zoneLODY+ yi*rowMult);
						debugShape.graphics.drawRect(xi*(8<<level), yi*(8<<level), (8<<level),(8<<level));
						rqcount++;
						//*/
						
					}
					else {
					//  ensure page is added to render list
						if (page.index < 0) {
							lod.addPage(page);
						}
						// ensure page is positioned correctly		
						page.xorg  = (xi * size);
						page.zorg =  (yi * size);
						page.heightMap.XOrigin = page.xorg;
						page.heightMap.ZOrigin = page.zorg;
						if (debugRectDict[page]) {
							debugRectDict[page].x = xi * (8 << level);
							debugRectDict[page].y = yi * (8 << level);
						}
					}
					
					
					lod.visible = lod.gridPagesVector.length != 0;
					
					
				}
				
				channels.mainParamsArray.writeInt(rqcount);
				
				//throw new Error(data);
				// debugging
			//	lod.visible = lod.gridPagesVector.length != 0;  // this isn't needed for none (create) case.
				lod.debug = true;
				//debugCount+=lod.gridPagesVector.length;
				//break;
			}//
			
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
			channels.initPrimordial(bgWorker, zoneSizeTiles, maxLowResSample, zoneVisDistance, 4, 128 );
			bgWorker.setSharedProperty("loaderAmount", treeUtil.loaderAmount);
			bgWorker.setSharedProperty("loaderOffsets", treeUtil.loaderOffsets);
			
			//channels.doTrace = trace;
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
				
				//LogTracer.log("Received bytes:" + channels.workerByteArray);
				//	LogTracer.log("Received params:" + channels.workerParamsArray.readUTF());
				// Set up mesh
			}
			else if (notifyCode === IslandChannels.INITED_DETAIL_HEIGHT) {
				//LogTracer.log("Received height detail bytes:" + channels.workerByteArray.length);
				setupHeightDetail();
			}
			//LogTracer.log("ping back");
			// continue process by sending signal success!
			channels.mainResponseDone.send(1);
		 }
		 
		 private function setupHeightDetail():void 
		 {
			
						
			 var data:ByteArray = channels.workerByteArray;
			 data.position = 0;
			 
			 // read data without alchemy opodes atm
			 	
			var zoneX:int = data.readInt();
			var zoneY:int =  data.readInt();
			var sampleX:Number= data.readFloat();
			var sampleY:Number=data.readFloat();
			var level:int =  data.readByte();
			
			sampleX = zoneX + sampleX -_zoneLODX;
			sampleY = zoneY + sampleY - _zoneLODY;
			
			// TODO: check if sampleX and sampleY is within proper range before continuiniung
			
			
			var lvlOffset:int = treeUtil.loaderOffsets[level];
			var numColumns:int = (treeUtil.boundWidth >> level);


			var xi:int = Math.round( (sampleX) * numColumns);
			var yi:int = Math.round((sampleY) * numColumns);
			if (treeUtil.drawBits.get(lvlOffset + yi * numColumns + xi) == 0) {
				//throw new Error("No longer valid received!");
				LogTracer.log("Exception: no longer valid sample received...");
				return;
			}
			
			//if (zoneX + sampleX
		//	LogTracer.log("Receiving:"+[sampleX, sampleY]);
			///*
			var myIndex:int = lvlOffset + yi * numColumns + xi;
			if (loadedPages[myIndex] != null) return;
			
			///*
			var page:QuadTreePage = createDummyPage(level);
			loadedPages[myIndex] = page;
			
			var size:Number = treeUtil.smallestSquareSize * tileSize;
			// ensure page is added to render list
			terrainLOD.lods[level].addPage(page);
			
			page.xorg  = xi * size;
			page.zorg =  yi * size;
			page.heightMap.XOrigin = page.xorg;
			page.heightMap.ZOrigin = page.zorg;
			
			// debug
			debugRectDict[page] = createDebugRect(xi * (8<<level), yi*(8<<level), (8 << level), (8 << level), PREVIEW_COLORS[level] );
			terrainLOD.lods[level].visible = true;
		//	LogTracer.log("adding sample at:"+level + ", "+sampleX + ", "+sampleY);
		//	*/
			
		
			// read heightmap data  (td-optimization: alchemy)
			var limit:int = channels.minLODTreeTileDistance + 1;  // 128
			limit *= limit;
			var heightData:Vector.<int> = page.heightMap.Data;
			for (var i:int = 0; i < limit; i++) {
				heightData[i] = data.readInt();
				
				//;
			}
			
			// setup quadtree page; (td-optimization: alchemy)
			page.Square.readByteArray(data);
			if (data.position != data.length) throw new Error("EOF not reached yet!");
			
		 }
		 
		
		 
		 private function removeWorker():void {  // tbd
			 
		 }
		
	}

}