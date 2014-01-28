package de.popforge.surface.io
{
	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	
	public class PopKeys
	{
		static private var state: Array = new Array();
		
		static public function initStage( stage: Stage ): void
		{
			stage.addEventListener( KeyboardEvent.KEY_DOWN, onKeyDown );
			stage.addEventListener( KeyboardEvent.KEY_UP, onKeyUp );
		}
		
		static public function isDown( code: uint ): Boolean
		{
			return state[ code ] == true;
		}
		
		static private function onKeyDown( event: KeyboardEvent ): void
		{
			state[ event.keyCode ] = true;
		}
		
		static private function onKeyUp( event: KeyboardEvent ): void
		{
			state[ event.keyCode ] = false;
		}
	}
}