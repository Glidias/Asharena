package tests.islands 
{
	import alternterrainxtras.util.TerrainProcesses;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	/**
	 * ...
	 * @author Glidias
	 */
	public class TestTerrainNoiseProcess extends Sprite
	{
		
		private var filterNoise:TerrainProcesses = new TerrainProcesses();
		private var bmp:Bitmap;
		private var bmd:BitmapData;
		private const BMD_SIZE:int = 128;
		
		public function TestTerrainNoiseProcess() 
		{
			filterNoise.setupHeights(new Vector.<int>(BMD_SIZE*BMD_SIZE), BMD_SIZE, BMD_SIZE);
			
			
		//	filterNoise.maxDisp = 600;
		//	filterNoise.minDisp = -600;
			//filterNoise.terrainRandomSeed = Math.random() * 99999;
		//	filterNoise.terrainApplyNoise(20, 4, 3.4, .2);
			
		//	filterNoise.terrainApplyNoise(20, 4, 2.4, .4);
			
			filterNoise.maxDisp = 3200;
			filterNoise.minDisp = -3200;
			filterNoise.terrainRandomSeed = 0; Math.random() * 99999;
			//filterNoise.terrainApplyNoise(40, 4, 2.4, .4);
			//filterNoise.terrainApplyNoise(4, 512, 128);
			
		
			
			//addEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onEnterFrame);
			
			bmd = new BitmapData(BMD_SIZE, BMD_SIZE, false, 0);
			bmp = new Bitmap(bmd);
			addChild( bmp);
		}
		
		private function reset():void {
			var len:int = filterNoise.terrainHeights.length;
			var arr:Vector.<int> = filterNoise.terrainHeights;
			for (var i:int = 0; i < len; i++) {
				arr[i] = 0;
			}
		}
		
		private function onEnterFrame(e:Event):void 
		{
			filterNoise.offsetX = 0;// 8192 * Math.sqrt(uint.MAX_VALUE);
			//filterNoise.offsetY+=1;
			reset();
			
			filterNoise.terrainApplyNoise(40 , 4, 2.4, .4);
			previewBitmap();
		}
		
		private function previewBitmap():void 
		{
			bmd.lock();
			
			var maxDisp:int = filterNoise.maxDisp;
			var minDisp:int = filterNoise.minDisp;
			var rangeMult:Number = 1 / (maxDisp - minDisp);
			var len:int = filterNoise.terrainHeights.length;
			var arr:Vector.<int> = filterNoise.terrainHeights;
			for (var y:int = 0; y < BMD_SIZE; y++) {
				for (var x:int = 0; x < BMD_SIZE; x++) {
					var val:uint = (arr[y * BMD_SIZE + x] - minDisp) * rangeMult * 255;
					bmd.setPixel(x,y, (val << 16) | (val << 8) | val );
				}
			}
			bmd.unlock();
		}
		
	}

}