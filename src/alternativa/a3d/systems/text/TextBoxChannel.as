package alternativa.a3d.systems.text 
{
	import alternativa.engine3d.alternativa3d;
	use namespace alternativa3d;
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class TextBoxChannel 
	{
		alternativa3d var maxDisplayedItems:uint;
		alternativa3d var displayedItems:uint = 0;
		alternativa3d var countdown:Number;
		
		private var styles:Vector.<FontSettings>;
	
		
		//Settings
		public var timeout:Number;
		public var vSpacing:Number;
		// additional settings
	
		
		
		public function TextBoxChannel(styles:Vector.<FontSettings>, maxDisplayedItems:uint=5, timeout:Number=-1, vSpacing:Number=3) 
		{
			setStyles(styles);
			this.maxDisplayedItems = maxDisplayedItems;
			this.timeout = timeout;
			this.countdown = timeout;
			this.vSpacing = 3;
			
		}
		
		private function setStyles(styles:Vector.<FontSettings>):void 
		{
			this.styles = styles;
		}
		
		alternativa3d var dirty:Boolean = false;
		
		public function appendMessage(val:String):void {
		
			dirty = true;
		}
		
		public function appendSpanTagMessage(val:String):void {
			
			dirty = true;
		}
		
		private function refresh():void {
			
		}
		
		public function update(time:Number):void {
			
			if (dirty) {  // update buffer
				refresh();
				
			}
			if (countdown < 0) return;
			
			
			
		}
		
	}

}