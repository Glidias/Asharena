package views.ui 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class UISpriteLayer extends Sprite
	{
		
		public function UISpriteLayer() 
		{
			addEventListener(MouseEvent.MOUSE_DOWN, stopEvent);
		}
		
		private function stopEvent(e:Event):void 
		{
			e.stopPropagation();
		}
		
	}

}