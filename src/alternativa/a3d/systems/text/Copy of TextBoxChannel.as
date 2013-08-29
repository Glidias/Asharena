package alternativa.a3d.systems.text 
{
	import alternativa.engine3d.alternativa3d;
	use namespace alternativa3d;
	/**
	 * A message log container
	 * @author Glenn Ko
	 */
	public class TextBoxChannel 
	{
		alternativa3d var maxStoredItems:uint;
		
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
		
		public function TextBoxChannel(styles:Vector.<FontSettings>, maxDisplayedItems:uint=5, timeout:Number=-1, vSpacing:Number=3, maxStoredItems:uint=20) 
		{
			if (styles.length < 1) throw new Error("Please provide at least 1 style fontsetting!");
			setStyles(styles);
			if (maxDisplayedItems < 1) throw new Error("Max displayed Items should be higher than zero!");
			this.maxDisplayedItems = maxDisplayedItems;
			if (maxDisplayedItems > maxStoredItems) maxStoredItems = maxDisplayedItems;
			this.maxStoredItems = maxStoredItems;
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
		
			// Check current lines and split into multiple line messages if necessary
			/*
			var numLinesLeft:int = maxDisplayedItems;    // line case
			for (m = tail; m != null; m = m.prev) {
			//	/*
				var numLines:int;
				if (m.boundCache != null) {
					//numLines =  m.numLinesCache;  // assumed 1 line already
					numLines = 1;
				}
				else {
					style.cacheData(m.str, width, centered);
					m.boundHeight = style.boundParagraph.maxY - style.boundParagraph.minY;
					m.boundCache = style.boundsCache;
					m.referTextCache = style.referTextCache;
					numLines = style.numLinesCache;
				//	m.numLinesCache = numLines = style.numLinesCache;
					if (numLines > 1) {
						var tailM:Message;
						var headM:Message = new Message();
						
						var startIndex:int =  numLines - numLinesLeft;
						
						
						headM.str = style.splitLineCache[0];
						headM.span = m.span;
						tailM = headM;
						for (i = 0; i < numLines; i++) { // reformat message into multiple lines
							var cm:Message = new Message();
							cm.str = style.splitLineCache[i];
							cm.span = m.span;
							tailM.next =  cm;
							cm.prev = tailM;
							tailM = cm;
							displayedItems++;
						}
					
						
						if (m.prev) m.prev.next = headM
						else head = headM;  // assumed no previous current message is actuall yhead.
						
						
						if (m.next) m.next.prev = tailM;
						tailM.next = m.next;
						tailM.eom = true;
						m.prev = null;
						m.next = null;
						
						for (i =0; i < numLines - numLinesLeft; i++) {
							head = head.next;	
						}
						
					}
					else m.eom = true;
				}
				
				numLinesLeft -= numLines;
				
				if (numLinesLeft <=0) break;
			}
			*/
		
			
			var li:int = 0;
			var mi:int = 0;
			var heighter:Number = 0;
			
			_numScrollingMsgs = 0;
			
			for (m = head; m != null; m = m.next) {
				//m.str;
				if (m.boundCache != null) {
					style.boundsCache = m.boundCache;
					style.referTextCache = m.referTextCache;
					style.writeDataFromCache(0, heighter, centered, li, width);
					
				}
				else {
					//style.writeData(m.str, 0, heighter, 0, centered, li);  // line case
					//style.writeData(m.str, 0, heighter, width, centered, li); 
					
					var checkPara:String = style.fontSheet.fontV.getParagraph(m.str, 0, heighter, width, style.boundParagraph);
					if (checkPara.split("\n").length > 1) {
						_scrollMessages[_numScrollingMsgs++] = m;
					}
					style.writeData(m.str, 0, heighter, 0, centered, li, width);   // mask width case
					m.boundHeight = style.boundParagraph.maxY - style.boundParagraph.minY;
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
			
			
			
			if (countdown < 0) return;
			
			countdown -= time;
			if (countdown <= 0) {
				// remove topmost display message from list
				
				countdown = timeout;
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
	
	public var charIndexCache:int;
	//public var startXCache:Number;
	//public var numLinesCache:int;
	//public var eom:Boolean = false; // line case end of message flag
	
	public function Message() {
		
	}
}