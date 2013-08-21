package views.ui.bit101 
{
	import com.bit101.components.Label;
	import com.bit101.components.ProgressBar;
	import flash.display.Sprite;
	import flash.events.Event;
	/**
	 * ...
	 * @author Glidias
	 */
	public class PreloaderBar extends Sprite
	{
	
		
		private var progressBar:ProgressBar;
		private var label:Label;
		
		public function PreloaderBar() 
		{
			label = new Label(this, 0, 0, "Loading...");
			progressBar = new ProgressBar(this);
			progressBar.width = 400;
			
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			
		}
		
		private function onAddedToStage(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			stage.addEventListener(Event.RESIZE, onStageResize);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			onStageResize();
			
			
		}
		
		public function setProgress(val:Number):void {
			progressBar.value = val;
		}
				
		public function setProgressAndLabel(val:Number, str:String):void {
			progressBar.value = val;
			label.text = str;
		}
		public function setLabel( str:String):void {
		
			label.text = "Loading..." + str;
			
		}
		
		private function onRemovedFromStage(e:Event):void 
		{
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
			stage.removeEventListener(Event.RESIZE, onStageResize);
		}
		
		private function onStageResize(e:Event=null):void 
		{
			progressBar.x = stage.stageWidth * .5 - progressBar.width*.5;
			progressBar.y = stage.stageHeight * .5 - progressBar.height * .5;
			label.x = progressBar.x;
			label.y = progressBar.y - 32;
		}
		
	}

}