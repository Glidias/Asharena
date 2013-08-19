package views.ui 
{
	import flash.display.Graphics;
	import flash.display.Shape;
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class ColorShape extends Shape
	{
		protected var _graphics:Graphics;
		
		public function ColorShape() 
		{
			_graphics = graphics;
			color = _color;
		}
		
		protected var _color:uint = 0;
		
		public function get color():uint 
		{
			return _color;
		}
		
		public function set color(value:uint):void 
		{
			_color = value;
			_graphics.clear();
			_graphics.beginFill(value);
			_graphics.drawRect(0, 0, 32, 32);
		}
		
	}

}