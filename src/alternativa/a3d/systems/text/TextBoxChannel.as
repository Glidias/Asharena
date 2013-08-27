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
	
		private var head:Message;
		private var tail:Message;
		
		//Settings
		public var timeout:Number;
		public var vSpacing:Number;
		// additional settings
	
		
		
		public function TextBoxChannel(styles:Vector.<FontSettings>, maxDisplayedItems:uint=5, timeout:Number=-1, vSpacing:Number=3) 
		{
			if (styles.length < 1) throw new Error("Please provide at least 1 style fontsetting!");
			setStyles(styles);
			if (maxDisplayedItems < 1) throw new Error("Max displayed Items should be higher than zero!");
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
			var me:Message;
			
			displayedItems++;
			if (displayedItems > maxDisplayedItems) {  // loop back
				displayedItems = maxDisplayedItems;
				tail.next = me = head;
				head = me.next;
				me.next = null;
			}
			else {		// append new message
				if (head == null) {
					head = tail = me = new Message();
				}
				else tail.next = me = new Message();
			}
			
			me.str = val;
			
			dirty = true;
		}
		
		public function appendSpanTagMessage(val:String):void {
			throw new Error("Not supported yet!");
			dirty = true;
		}
		
		public function refresh():void {
			
			dirty = false;
			
			// for now, just 1 style
			var style:FontSettings = styles[0];
			var data:Vector.<Number> = style.spriteSet.spriteData;
			
			for (var m:Message = head; m != null; m = m.next) {
				
			}
			
		}
		
		public function update(time:Number):void {
			
			if (dirty) {  // update buffer
				refresh();
				
			}
			if (countdown < 0) return;
			
		}
		
	}

}

class Message {
	public var str:String;
	public var span:Boolean = false;
	public var next:Message;
	
	public function Message() {
		
	}
}