package tests 
{
	import ash.core.Engine;
	import ash.tick.FrameTickProvider;
	import flash.display.Sprite;
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class TestBuild extends Sprite
	{
		public var engine:Engine;
		public var ticker:FrameTickProvider;
		
		public function TestBuild() 
		{
			engine = new Engine();
			ticker = new FrameTickProvider(stage);
			
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