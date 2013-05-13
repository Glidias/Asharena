package views 
{
	import alternativa.engine3d.Template;
	import flash.events.Event;
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
				cameraController.speed = 0;
				
			startRendering();
			
			dispatchEvent( new Event(Event.COMPLETE) );
		}
		
	}

}