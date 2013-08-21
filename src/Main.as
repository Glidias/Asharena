package  
{
	import flash.Boot;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	/**
	 * ...
	 * @author Glenn Ko
	 */
	CONFIG::usePreloader{[Frame(factoryClass="Preloader")]}
	public class Main extends MovieClip
	{
		private var game:TheGameAS3;
		
		public function Main() 
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			haxe.initSwc(this);
			game = new TheGameAS3(stage);
		}
		
	}

}