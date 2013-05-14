package  
{
	import flash.Boot;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.Point;
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class Main extends MovieClip
	{
		private var game:TheGameAS3;
		
		public function Main() 
		{
			haxe.init(this);
			game = new TheGameAS3(stage);
		
			
		}
		
	}

}