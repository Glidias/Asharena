package views.ui.bit101 
{
	import ash.signals.Signal0;
	import ash.signals.Signal1;
	import com.bit101.components.HBox;
	import com.bit101.components.Label;
	import com.bit101.components.NumericStepper;
	import com.bit101.components.PushButton;
	import com.bit101.components.VBox;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.events.Event;
	import saboteur.util.SaboteurPathUtil;
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class BuildStepper extends Sprite
	{
		public var delBtn:PushButton;
		public var onBuild:Signal0 = new Signal0();
		public var onDelete:Signal0 = new Signal0();
		public var onStep:Signal1 = new Signal1();
		public var buildBtn:PushButton;
		public var stepper:NumericStepper;
		
		public function BuildStepper() 
		{
			createStepper(this);
		}
		
		private  function createStepper(parent:DisplayObjectContainer):void 
        {
            var stepper:NumericStepper;
            
            var vLayout:VBox = new VBox(parent);
			var pathUtil:SaboteurPathUtil = SaboteurPathUtil.getInstance();
			var hBox:HBox = new HBox(vLayout);
     
            
            var label:Label = new Label(vLayout, 0, 0, (pathUtil.combinations.length) + " found.");
			label.blendMode = "invert";
            stepper = new NumericStepper(hBox, 0, 0, stepHandler);
            stepper.minimum = 0;
            stepper.maximum = pathUtil.combinations.length - 1;
			
            
            stepper.value = 0;
            
		
			buildBtn = new PushButton(hBox, 0, 0, "Build", buildHandler);
			delBtn = new PushButton(hBox, 0, 0, "Delete", delHandler);
			
               
                this.stepper = stepper;
           
        }
		
		private function delHandler(e:Event):void 
		{
			onDelete.dispatch();
		}
		
		private function buildHandler(e:Event):void 
		{
			onBuild.dispatch();
		}
		
		private function stepHandler(e:Event):void 
		{
			onStep.dispatch(stepper.value);
		}
		
	}

}