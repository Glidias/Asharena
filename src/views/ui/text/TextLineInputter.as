package views.ui.text 
{
	import ash.signals.Signal1;
	import flash.display.Stage;
	import flash.events.IEventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class TextLineInputter 
	{
		private var _stage:IEventDispatcher;
		private var _activated:Boolean=false;
		public const onTextChange:Signal1 = new Signal1();
		public const onTextCommit:Signal1 = new Signal1();
		public const onTextEscape:Signal1 = new Signal1();
		public var autoClearOnCommit:Boolean = true;
		public var autoClearOnEscape:Boolean = true;
		
		public var glyphRange:Array;
		
		public var string:String = "";
		public function clear():void {
			if (string === "") return;
			string = "";
			onTextChange.dispatch(string);
		}
		
		public function TextLineInputter(stage:IEventDispatcher) 
		{
			_stage = stage;
		}
		
		public function activate():void {
			_stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false,4);
			_activated = true;
		}
		
		public function clearAndDeactivate():void {
			string = "";
			_stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			
		}
		
		public function deactivate():void {
			_stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			_activated = false;
		}
		

		
		private function onKeyDown(e:KeyboardEvent):void 
		{
			e.stopImmediatePropagation();
			var keyCode:uint = e.keyCode;
			var kc:uint = e.charCode;
			if (keyCode === Keyboard.ESCAPE) {
				onTextEscape.dispatch(string);
				if (autoClearOnEscape) { 
					string = "";
				}
				return;
			}
			var lastChar:String = string.charAt(string.length - 1);
			if ( string === "" && String.fromCharCode(kc) === "<") return;
			if (keyCode === Keyboard.SPACE && ( !(lastChar) || lastChar=== " ")) return;
			if (keyCode === Keyboard.ENTER || keyCode === Keyboard.NUMPAD_ENTER ) {
				onTextCommit.dispatch(string);
				if (autoClearOnCommit) { 
					string = "";
				}
				
				return;
			}
			
			
		
		//	throw new Error(String.fromCharCode(kc));
			var newStr:String = keyCode != Keyboard.BACKSPACE ?  string +  (glyphRange!=null  ? glyphRange[kc] ? String.fromCharCode(kc) : ""  : String.fromCharCode(kc).toString() ) : (string != "" ? string.slice(0,string.length-1) : "");

			if (newStr != string) {
				string = newStr;
				onTextChange.dispatch(newStr);
			}
		}
		
		public function get activated():Boolean 
		{
			return _activated;
		}
		
	}

}