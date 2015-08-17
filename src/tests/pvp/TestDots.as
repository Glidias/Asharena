package tests.pvp
{
	import alternativa.types.Float;
	import arena.pathfinding.GKEdge;
	import arena.pathfinding.GraphGrid;
	import ash.core.Engine;
	import ash.tick.FrameTickProvider;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class TestDots extends Sprite
	{
		public var engine:Engine;
		public var ticker:FrameTickProvider;
		static public const GRID_SIZE:Number = 32;
		public var MOVEMENT_POINTS:Number = 16;
		
		private var _across:int = 32;
		private var _graphGrid:GraphGrid;
		private var _arrDots:Array = [];
		
		private var _x:int = -1;
		private var _y:int = -1;
		
		private var startPt:Sprite;
		
		private var heightMap:BitmapData;
		private var heightBmp:Bitmap;
		private var heightMapData:Vector.<int> = new Vector.<int>();
		
		public function TestDots() 
		{
			engine = new Engine();
			ticker = new FrameTickProvider(stage);
			
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			
			heightMap = new BitmapData(_across, _across, false, 0);
			heightMap.perlinNoise(_across / 1, _across / 1, 4, 440, false, true, 7, true);
			addChild(heightBmp =  new Bitmap(heightMap));
			heightBmp.smoothing = true;
			heightBmp.scaleX = GRID_SIZE;
			heightBmp.scaleY = GRID_SIZE;
		
			
			_graphGrid = new GraphGrid(_across);
			for (var y:int = 0; y < _across; y++) {
				for (var x:int = 0; x < _across; x++) {
					var spr:Sprite = new Sprite();
					spr.x = GRID_SIZE * x;
					spr.y = GRID_SIZE * y;
					spr.graphics.beginFill(0x0000FF, 1);
					spr.graphics.drawCircle(0, 0, 8);
					_arrDots.push(spr);
					addChild(spr);
				}
			}

			setupHeightmap();
			
			spr = startPt = new Sprite();
			spr.graphics.beginFill(0xFF0000, 1);
			spr.graphics.drawCircle(0, 0, 5);
			addChild(spr);
			

			
			//
			ticker.add(tick);
			ticker.start();
		}
		
		private function setupHeightmap():void 
		{

			var samples:Vector.<uint> = heightMap.getVector(heightMap.rect);
			
			heightMapData.length = samples.length;
			var i:int;
			var len:int = samples.length;
			for (i = 0; i < len; i++) {
				heightMapData[i] = samples[i];
			}
			
			
			_graphGrid.sampleHeightmap(heightMapData, 225555 );
			
			_graphGrid.djTraversal.edgeDisableMask = GKEdge.FLAG_INVALID | GKEdge.FLAG_GRADIENT_UNSTABLE;
			
		}
		
	
		
		public function tick(time:Number):void 
		{
			var across:int = _across;
			var x:int = Math.round( mouseX / GRID_SIZE );
			var y:int = Math.round( mouseY / GRID_SIZE );
			x = x >= _across ? across - 1 : x < 0 ? 0 : x;
			y = y >= _across ? across - 1 : y< 0 ? 0 : y;

			if (x != _x || y != _y) {
				
				 _x=x;
				 _y = y
			
				 startPt.x = x * GRID_SIZE;
				 startPt.y = y * GRID_SIZE;
				 
				 	 _graphGrid.search(_x, _y, MOVEMENT_POINTS);
				 _graphGrid.renderVisitedToScaledImages(_arrDots, .5);
			}
			engine.update(time);
		}
		
	}

}