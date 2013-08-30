package alternativa.a3d.systems.text 
{
	import alternativa.engine3d.alternativa3d;
	use namespace alternativa3d;
	/**
	 * A message alert container to hold transcient messages, also supports updating to scroll any scrolling marquee messages.
	 * @author Glenn Ko
	 */
	public class TextBoxChannel 
	{
		
		alternativa3d var maxDisplayedItems:uint;
		public function setMaxDisplayedItems(val:uint):void {
			// TODO: check if < than current,  cache maxList list
			maxDisplayedItems = val;
			
		}
		alternativa3d var displayedItems:uint = 0;
		alternativa3d var countdown:Number;
		
		private var styles:Vector.<FontSettings>;
		
		private var head:Message;
		private var tail:Message;
		private var _numScrollingMsgs:int = 0;
		private var _scrollMessages:Vector.<Message> = new Vector.<Message>();
		
		//Settings
		public var timeout:Number;
		public var vSpacing:Number;
		public var lineSpacing:Number = 4;
		// additional settings
		
		
		public var width:Number = 200;
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
				me.scrolling = false;
				//me.numLinesCache = 0;
			}
			else {		// append new message
				if (head == null) {
					head = me = new Message();
				}
				else tail.next = me = new Message();
			}
		//	me.prev = tail;
			
			tail = me;
			
			me.str = val;
			
			dirty = true;
		}
		
		public function appendSpanTagMessage(val:String):void {
			throw new Error("Not supported yet!");
			dirty = true;
		}
		
		public function refresh():void {
			var i:int;
			var m:Message;
			
			dirty = false;
			
			// for now, just 1 style
			var style:FontSettings = styles[0];
			var data:Vector.<Number> = style.spriteSet.spriteData;
		
			
			var li:int = 0;
			var mi:int = 0;
			var heighter:Number = 0;
			
			_numScrollingMsgs = 0;
			var spareLines:int = maxDisplayedItems - displayedItems;
			for (m = head; m != null; m = m.next) {
				//m.str;
				m.charIndexCache = li;
				m.yValueCache = heighter;
				if (m.boundCache != null) {
					style.boundsCache = m.boundCache;
					style.referTextCache = m.referTextCache;
					
					if (m.numLines > 1) {
						spareLines -= m.numLines - 1;
						if (!m.scrolling)	{
							if (spareLines < 0) {  // convert paragraph to scrolling
							_scrollMessages[_numScrollingMsgs++]  = m;
							 m.scrolling = true;
							 style.writeData(m.str, 0, heighter, 0, centered, li, width); 
							 	m.boundHeight = style.boundParagraph.maxY - style.boundParagraph.minY;
								m.boundWidth = style.boundParagraph.maxX - style.boundParagraph.minX;
								m.boundCache = style.boundsCache;
								m.referTextCache = style.referTextCache;
							}
							else style.writeDataFromCache(0, heighter, centered, li, width);
						}
						else _scrollMessages[_numScrollingMsgs++]  = m;  // continue scrolling
							
					}
					else style.writeDataFromCache(0, heighter, centered, li, width);
				}
				else {
					//style.writeData(m.str, 0, heighter, 0, centered, li);  // line case
					//style.writeData(m.str, 0, heighter, width, centered, li); 
					
					var checkPara:String = style.fontSheet.fontV.getParagraph(m.str, 0, heighter, width, style.boundParagraph);
					m.numLines = checkPara.split("\n").length;
					
					if (m.numLines > 1) {
						spareLines -= m.numLines - 1;
						if (spareLines < 0) {
							_scrollMessages[_numScrollingMsgs++]  = m;
							m.scrolling = true;
							 style.writeData(m.str, 0, heighter, 0, centered, li, width); 
						}
						else {
							 style.writeData(checkPara, 0, heighter, 0, centered, li); 
						}
					}
					else style.writeData(m.str, 0, heighter, 0, centered, li, width); 
					m.boundHeight = style.boundParagraph.maxY - style.boundParagraph.minY;
					m.boundWidth = style.boundParagraph.maxX - style.boundParagraph.minX;
					m.boundCache = style.boundsCache;
					m.referTextCache = style.referTextCache;
					
				//	m.numLinesCache = style.numLinesCache
				}
				
				li += style.boundsCache.length;
				
			
				//if (m.boundCache != null ) throw new Error("A");
				//heighter += m.boundHeight + (m.eom ? vSpacing : lineSpacing);  // line case
				heighter += m.boundHeight + vSpacing;
				
				mi++;
				if (mi >= maxDisplayedItems) break;
			}

				//	throw new Error(arr);
				style.spriteSet._numSprites = li;// ,
		
		}
		
		public function update(time:Number):void {
			
			if (dirty) {  // update buffer
				refresh();
			}
	
			if (_numScrollingMsgs > 0) updateScrollingMsgs();
			

			if (countdown < 0) return;
			
			countdown -= time;
			if (countdown <= 0) {
				// TODO: remove topmost display message from list
				
				countdown = timeout;
			}
			
		}
		
		private function updateScrollingMsgs():void 
		{
			var style:FontSettings = styles[0];
			for (var i:int = 0; i < _numScrollingMsgs; i++) {
				var m:Message = _scrollMessages[i];
				m.startX -= .5;
				style.boundsCache = m.boundCache;
				style.referTextCache = m.referTextCache;
				style.writeMarqueeDataFromCache(m.startX, m.yValueCache, centered, m.charIndexCache, width, m.boundWidth + 32);
				
			}
		}
		
	}

}

class Message {
	public var str:String;
	public var span:Boolean = false;
	public var next:Message;
	//public var prev:Message;
	
	public var boundCache:Array;
	public var referTextCache:String;
	public var boundHeight:Number;
	public var boundWidth:Number;
	
	public var numLines:int;
	
	// for horizontal scolling items 
	public var scrolling:Boolean = false;
	public var charIndexCache:int;
	public var yValueCache:Number;
	public var startX:Number = 0;
	
	//public var numLinesCache:int;
	//public var eom:Boolean = false; // line case end of message flag
	
	public function Message() {
		
	}
}