package tests.ds 
{
	import ash.core.Engine;
	import ash.tick.FrameTickProvider;
	import de.polygonal.ds.mem.ByteMemory;
	import de.polygonal.ds.mem.MemoryManager;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.system.ApplicationDomain;
	import hashds.ds.alchemy.ColorMap;

	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class TestColorMap extends MovieClip
	{
		public var engine:Engine;
		public var ticker:FrameTickProvider;
		
		[Embed(source="../../../resources/skybox/clearblue/right.png")]
		public static const IMAGE_1:Class;
		
		[Embed(source = "../../examples/assets/grayscale.jpg")]
		public static const IMAGE_2:Class;
		
		public function TestColorMap() 
		{

		stage.scaleMode = StageScaleMode.NO_SCALE;
		stage.align = StageAlign.TOP_LEFT;
			
			engine = new Engine();
			ticker = new FrameTickProvider(stage);
			
			var bmp:BitmapData = new IMAGE_2().bitmapData;
			addChild( new Bitmap(bmp));
			
			var child:DisplayObject;
			
			
	
				
		//	var map:ColorMap = new ColorMap();
		//	map.init(bmp.width, bmp.height);
			//MemoryManager.get()
		//	throw new Error( MemoryManager.get()._bytes.length);
		//	/*
		
		//bmp.fillRect(bmp.rect, 0xFF0000);
			var map:ColorMap = ColorMap.createFromBitmapData(bmp);
			child = addChild( new Bitmap( map.previewUpscaled(8) ) );
			child.x = bmp.width;
		//	*/
			
		
			
			//
			ticker.add(tick);
			ticker.start();
		}
		
		public function tick(time:Number):void 
		{
			engine.update(time);
		}
		
	}

}