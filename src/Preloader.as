package 
{
	import com.bit101.components.Label;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.utils.getDefinitionByName;
	
	import com.bit101.components.ProgressBar;
	
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class Preloader extends MovieClip 
	{
		private var progressBar:ProgressBar;
		private var label:Label;
		
		public function Preloader() 
		{
			if (stage) {
				stage.scaleMode = StageScaleMode.NO_SCALE;
				stage.align = StageAlign.TOP_LEFT;
			}
			addEventListener(Event.ENTER_FRAME, checkFrame);
			loaderInfo.addEventListener(ProgressEvent.PROGRESS, progress);
			loaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioError);

			label = new Label(this, 0, 0, "Loading...");
			progressBar = new ProgressBar(this);
			progressBar.width = 400;
		}
		
		private function ioError(e:IOErrorEvent):void 
		{
			label.text = e.text;
		}
		
		private function progress(e:ProgressEvent):void 
		{
			// TODO update loader
			progressBar.value = e.bytesLoaded / e.bytesTotal;
		}
		
		private function checkFrame(e:Event):void 
		{
			progressBar.x = stage.stageWidth * .5 - progressBar.width*.5;
			progressBar.y = stage.stageHeight * .5 - progressBar.height * .5;
			label.x = progressBar.x;
			label.y = progressBar.y - 32;
			if (currentFrame == totalFrames) 
			{
				stop();
				loadingFinished();
			}
		}
		
		private function loadingFinished():void 
		{
			removeEventListener(Event.ENTER_FRAME, checkFrame);
			loaderInfo.removeEventListener(ProgressEvent.PROGRESS, progress);
			loaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, ioError);
			
			// TODO hide loader
			removeChild(progressBar);
			removeChild(label);
			
			startup();
		}
		
		private function startup():void 
		{
			var mainClass:Class = getDefinitionByName("Main") as Class;
			addChild(new mainClass() as DisplayObject);
		}
		
	}
	
}