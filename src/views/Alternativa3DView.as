package views 
{
	import alternativa.engine3d.Template;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class Alternativa3DView extends Template
	{
		
		public function Alternativa3DView() 
		{
			super();
			
			addEventListener(VIEW_CREATE, onViewCreated);
			
			
		}
		
		private function onViewCreated(e:Event):void 
		{
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			
				cameraController.speed = 0;
				
			startRendering();
			
			dispatchEvent( new Event(Event.COMPLETE) );
		}
		
		private function onKeyDown(e:KeyboardEvent):void 
		{
			if (e.keyCode === Keyboard.V) {
				cameraController.speed = 33;
			}
		}
		
		private function onKeyUp(e:KeyboardEvent):void 
		{
				if (e.keyCode === Keyboard.V) {
				cameraController.speed = 0;
			}
		}
		
	}

}