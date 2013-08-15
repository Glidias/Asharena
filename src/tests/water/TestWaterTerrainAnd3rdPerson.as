package tests.water 
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class TestWaterTerrainAnd3rdPerson extends MovieClip
	{
		private var game:TheGameAS3;
		
		public function TestWaterTerrainAnd3rdPerson() 
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			haxe.init(this);
			game = new TheGameAS3(stage);
		}
		
		
	}

}