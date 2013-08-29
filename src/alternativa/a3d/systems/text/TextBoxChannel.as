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
		
		
		public var width:Number = 300;
		public var centered:Boolean = false;
		
		public function TextBoxChannel(styles:Vector.<FontSettings>, maxDisplayedItems:uint=5, timeout:Number=-1, vSpacing:Number=3) 
		{
			if (styles.length < 1) throw new Error("Please provide at least 1 style fontsetting!");
			setStyles(styles);
			if (maxDisplayedItems < 1) throw new Error("Max displayed Items should be higher than zero!");
			this.maxDisplayedItems = maxDisplayedItems;
			this.timeout = timeout;
			this.countdown = timeout;
			this.vSpacing = 10;
			
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
				me.boundCache = null;
				
			}
			else {		// append new message
				if (head == null) {
					head = me = new Message();
				}
				else tail.next = me = new Message();
			}
			
			tail = me;
			
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
			
		
			
			var li:int = 0;
			var mi:int = 0;
			var heighter:Number = 0;
			for (var m:Message = head; m != null; m = m.next) {
				//m.str;
				if (m.boundCache != null) {
					style.boundsCache = m.boundCache;
					style.referTextCache = m.referTextCache;
					style.writeDataFromCache(0, heighter, centered, li);
					
				}
				else {
					style.writeData(m.str, 0, heighter, width, centered, li);
					m.boundHeight = style.boundParagraph.maxY - style.boundParagraph.minY;
					m.boundCache = style.boundsCache;
					m.referTextCache = style.referTextCache;
				}
				
				li += style.boundsCache.length;
				
			
				//if (m.boundCache != null ) throw new Error("A");
				heighter += m.boundHeight + vSpacing;
				
				mi++;
			}

				//	throw new Error(arr);
				style.spriteSet._numSprites = li;// ,
		
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
	
	public var boundCache:Array;
	public var referTextCache:String;
	public var boundHeight:Number;
	
	public function Message() {
		
	}
}