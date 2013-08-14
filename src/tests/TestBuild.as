package tests 
{
	import ash.core.Engine;
	import ash.tick.FrameTickProvider;
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class TestBuild 
	{
		public var engine:Engine;
		public var ticker:FrameTickProvider;
		
		public function TestBuild() 
		{
			engine = new Engine();
			ticker = new FrameTickProvider(stage);
			
			
			ticker.add(tick);
			ticker.start();
		}
		
		public function tick(time:Number):void 
		{
			engine.update(time);
		}
		
	}

}