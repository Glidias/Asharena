package alternativa.a3d.systems.text 
{
	import alternativa.engine3d.alternativa3d;
	import ash.core.NodeList;
	import ash.signals.Signal1;
	use namespace alternativa3d;
	/**
	 * A message alert container to hold transcient/permanent messages, also supports updating to scroll any scrolling marquee messages.
	 * @author Glenn Ko
	 */
	public class TextBoxChannel 
	{

		private var styles:Vector.<FontSettings>;
		
		private var head:Message;
		private var tail:Message;
		private var _numScrollingMsgs:int = 0;
		private var _scrollMessages:Vector.<Message> = new Vector.<Message>();
		alternativa3d var _heightOffset:Number;
		public const onContentHeightChange:Signal1 = new Signal1();
		
		// Key settings
		alternativa3d var maxDisplayedItems:uint;
		public function setMaxDisplayedItems(val:uint):void {
			if (val === maxDisplayedItems) return;
			maxDisplayedItems = val;
			dirty = true;
			dirtyFlags |= 1;
			
		}
		
		
		alternativa3d var displayedItems:uint = 0;
		alternativa3d var countdown:Number;
		// More Settings
		public var timeout:Number;   // the timeout before topmost message vanishes, set to negative value to have no timeout
		public var vSpacing:Number;  // the spacing between messages
		public var maskMinY:Number = -Number.MAX_VALUE;  // the negative y height value to conceal text above the chatbox..
		public var enableMarquee:Boolean = true;  // whether to make paragraphs turn to single-lines, if not enough space to show no. of displayedItems
		public var history:StringLog;   // whether to push messages into history log, this must be used to handle scrolling of data
		public var dotMarqueeOffset:Number = 10;  // the ... marquee offset to the left
		public var dotMarqueeOffsetRight:Number = 3;  // the ... marquee offset to the right
		
		public var width:Number = 200;
		public var centered:Boolean = false;
		
		
		
		public function TextBoxChannel(styles:Vector.<FontSettings>, maxDisplayedItems:uint=5, timeout:Number=-1, vSpacing:Number=3) 
		{
		
		//	timeout = -1;
		//	maskMinY = (12 + vSpacing) * -maxDisplayedItems;
		
			if (styles.length < 1) throw new Error("Please provide at least 1 style fontsetting!");
			setStyles(styles);
			if (maxDisplayedItems < 1) throw new Error("Max displayed Items should be higher than zero!");
			this.maxDisplayedItems = maxDisplayedItems;
			this.timeout = timeout;
			this.countdown = -1;
			this.vSpacing = 10;
			
			
		}
		
		private function setStyles(styles:Vector.<FontSettings>):void 
		{
			this.styles = styles;
		}
		
		public var dirty:Boolean = false;
		public var dirtyFlags:int = 0;  // 1 - height-rows changed,  2- width changed
		
		public function resizeNotify():void {
			dirty = true;
			dirtyFlags |= 1 | 2;
		}
		
		public function rowsChangedNotify():void {
			dirty = true;
			dirtyFlags |=  1;
		}
		
		
		public function appendMessage(val:String):void {
			var me:Message;
			
			displayedItems++;
			if (displayedItems > maxDisplayedItems) {  // loop back
				displayedItems = maxDisplayedItems;
				tail.next = me = head;
				me.prev = tail;
				head = me.next;
				
				me.next = null;
				me.boundCache = null;
				me.scrolling = 0;
				me.startX  = 0;
				//me.numLinesCache = 0;
			}
			else {		// append new message
				if (head == null) {
					head = me = new Message();
					countdown = timeout;
				}
				else tail.next = me = new Message();
			}
			me.prev = tail;
			
			tail = me;
			
			me.str = val;
			
			if (history != null) {
				
				history.add(val); 
			}

			dirty = true;
	
			
		}
		
		
	
		
		public function clearAll():void {
			head = null;
			tail = null;
			_numScrollingMsgs = 0;
			displayedItems = 0;
			countdown = -1;
		}
		
		public function appendSpanTagMessage(val:String):void {
			throw new Error("Not supported yet!");
			dirty = true;
		}
		
		private function refresh():void {
			var i:int;
			var m:Message;
			
			dirty = false;
			
			// for now, just 1 style
			var style:FontSettings = styles[0];
			var data:Vector.<Number> = style.spriteSet.spriteData;
		
			if (dirtyFlags & 2) {
					for (m = head; m != null; m = m.next) {
						m.boundCache = null;
					}
			}
			
			var li:int = 0;
			var mi:int = 0;
			var heighter:Number = 0;
			
			_numScrollingMsgs = 0;
			var spareLines:int = enableMarquee ?  maxDisplayedItems - displayedItems : 2147483647;
			for (m = tail; m != null; m = m.prev) {
				//m.str;
				m.charIndexCache = li;
				
			//	 m.lastScrolling = 0;
				 
				if ( m.boundCache != null) {
					style.boundsCache = m.boundCache;
					style.referTextCache = m.referTextCache;
					
					if (m.numLines > 1) {
						spareLines -= m.numLines - 1;
						if (!m.scrolling)	{
							
							if (spareLines < 0) {  // convert paragraph to scrolling line
							//	/*
								_scrollMessages[_numScrollingMsgs++]  = m;
								m.scrolling = 1;
								style.fontSheet.fontV.getBound(m.str, 0, 0, centered, style.fontSheet.tight, style.boundParagraph);
								m.boundHeight = style.boundParagraph.maxY - style.boundParagraph.minY;
								heighter -= m.boundHeight + vSpacing;
								m.yValueCache = heighter;
								style.writeData(m.str, 0, heighter, 0, centered, li, width, maskMinY); 
							 
								
								m.boundWidth = style.boundParagraph.maxX - style.boundParagraph.minX;
								//m.boundHeight = style.boundParagraph.maxY - style.boundParagraph.minY;
								m.boundCache = style.boundsCache;
								m.referTextCache = style.referTextCache;
								
							//	*/
							//	style.writeDataFromCache(0, heighter, centered, li, width); 
							}
							else  {
									heighter -= m.boundHeight + vSpacing;
									m.yValueCache = heighter;
								style.writeDataFromCache(0, heighter, centered, li, width, maskMinY); 
							}
						}
						else {
							
							if (spareLines >= 0)  { // convert scrolling line to paragraph
								style.fontSheet.fontV.getBound(style.fontSheet.fontV.getParagraph(m.str, 0, 0, width, style.boundParagraph), 0, heighter, centered, style.fontSheet.tight, style.boundParagraph);
							m.boundHeight = style.boundParagraph.maxY - style.boundParagraph.minY;
									heighter -= m.boundHeight + vSpacing;
								m.yValueCache = heighter;
								style.writeData(m.str, 0,heighter, width, centered, li, 1.79e+308, maskMinY); 
								m.scrolling = 0;
								//m.boundHeight = style.boundParagraph.maxY - style.boundParagraph.minY;
								m.boundWidth = style.boundParagraph.maxX - style.boundParagraph.minX;
								
								m.boundCache = style.boundsCache;
							}
							else {
									heighter -= m.boundHeight + vSpacing;
									m.yValueCache = heighter;
									m.scrolling = 1;
								style.writeDataFromCache(0, heighter, centered, li, width, maskMinY); 
								_scrollMessages[_numScrollingMsgs++]  = m;  // continue scrolling
							}
						}
							
					}
					else {  // continue displaying single line
							heighter -= m.boundHeight + vSpacing;
						m.yValueCache = heighter;
						style.writeDataFromCache(0, heighter, centered, li, width, maskMinY);
					}
				}
				else {
					//style.writeData(m.str, 0, heighter, 0, centered, li);  // line case
					//style.writeData(m.str, 0, heighter, width, centered, li); 
					
					var checkPara:String = style.fontSheet.fontV.getParagraph(m.str, 0, 0, width, style.boundParagraph);
					
				
					m.numLines = checkPara.split("\n").length;
					
					if (m.numLines > 1) {
						spareLines -= m.numLines - 1;
						if (spareLines < 0) {
							_scrollMessages[_numScrollingMsgs++]  = m;
							m.scrolling = 1;	
							//if (m.startX != 0) throw new Error("SHOULD NOT BE!:"+m.startX);
								m.startX  = width * .25;
								style.fontSheet.fontV.getBound(m.str, 0, 0, centered, style.fontSheet.tight, style.boundParagraph);
							m.boundHeight = style.boundParagraph.maxY - style.boundParagraph.minY;
							heighter -= m.boundHeight + vSpacing;
							m.yValueCache = heighter;
							 style.writeData(m.str, 0, heighter, 0, centered, li, width, maskMinY); 
							
						}
						else {
							style.fontSheet.fontV.getBound(checkPara, 0, 0, centered, style.fontSheet.tight, style.boundParagraph);
							m.boundHeight = style.boundParagraph.maxY - style.boundParagraph.minY;
							heighter -= m.boundHeight + vSpacing;
							m.yValueCache = heighter;
							 style.writeData(checkPara, 0, heighter, width, centered, li, 1.79e+308, maskMinY); 
						}
					}
					else {   // display single line
						style.fontSheet.fontV.getBound(m.str, 0, 0, centered, style.fontSheet.tight, style.boundParagraph);
						m.boundHeight = style.boundParagraph.maxY - style.boundParagraph.minY;
						heighter -= m.boundHeight + vSpacing;
						m.yValueCache = heighter;
						style.writeData(m.str, 0, heighter, width, centered, li, width, maskMinY); 
					
					}
					
					m.boundWidth = style.boundParagraph.maxX - style.boundParagraph.minX;
					m.boundHeight = style.boundParagraph.maxY - style.boundParagraph.minY;
					m.boundCache = style.boundsCache;
					m.referTextCache = style.referTextCache;
					
				//	m.numLinesCache = style.numLinesCache
				}
				
				li += style.boundsCache.length;
			
			
				//if (m.boundCache != null ) throw new Error("A");
				//heighter += m.boundHeight + (m.eom ? vSpacing : lineSpacing);  // line case
			
				
				mi++;
				if (mi >= maxDisplayedItems) break;
			}

				//	throw new Error(arr);
				style.spriteSet._numSprites = li;// ,
				_heightOffset = -heighter;
				//style.spriteSet.y = _heightOffset;
	
				
			
				dirtyFlags = 0;
				
				
				onContentHeightChange.dispatch(_heightOffset);
		
		}
		
		public function resetAllScrollingMessages():void {
			for (var i:int = 0; i < _numScrollingMsgs; i++) {
				var m:Message=_scrollMessages[i];
				m.startX = width * .25;
				m.scrolling = 1;  
			}
		}
		
		public function update(time:Number):void {
			
			var gotScrollingMessages:Boolean = false;
			///*
			if (countdown > 0) {
				
				for (var i:int = 0; i < _numScrollingMsgs; i++) {
					if (_scrollMessages[i].scrolling == 1) {
						gotScrollingMessages = true;
						break;
					}
				}
			}
			//*/
			
			//if (displayedItems == 0) return;
			
			
			
			if (countdown > 0 && !gotScrollingMessages) {  // && !gotScrollingMessages
			
				countdown -= time;
				
				if (countdown <= 0) {
				//	/*
					//throw new Error("A");
					displayedItems--;
					if (displayedItems==0) tail = null;
					if (head.next) {
						head.next.prev = null;
					}
					head = head.next;
					
					countdown = displayedItems > 0 ? timeout : -1;
					dirty = true;
					
				//	*/
				}
				
			}
			
			
			var wasDirty:Boolean = dirty;
			if (dirty) {  // update buffer
				refresh();
			}
			
			dirtyFlags = 0;
	
			if (_numScrollingMsgs > 0) updateScrollingMsgs(time, wasDirty);  // temp disabled for now
			
		}
		
		private function updateScrollingMsgs(time:Number, wasDirty:Boolean):void 
		{
			var style:FontSettings = styles[0];
			for (var i:int = 0; i < _numScrollingMsgs; i++) {
				var m:Message = _scrollMessages[i];
				if ((m.scrolling & 2)) continue;
				m.startX -= .3;
				style.boundsCache = m.boundCache;
				style.referTextCache = m.referTextCache;
	
				var x:Number = m.startX;
				var limit:Number = m.boundWidth - width;
				if ( -x > limit) {
					x = -limit;
					m.scrolling = 2;
				}
				if (x > 0) x = 0;
				style.writeMarqueeDataFromCache(x, m.yValueCache, centered, m.charIndexCache, width, m.boundWidth + 32);
				
				style.minXOffset = dotMarqueeOffset;
				if (wasDirty) {
			
					m.dotCacheIndex = style.spriteSet._numSprites;
					style.writeData("...",  -dotMarqueeOffset, m.yValueCache, 2000, false, style.spriteSet._numSprites);
					style.writeData("...", width+dotMarqueeOffsetRight, m.yValueCache, 2000, false, style.spriteSet._numSprites+3);
					style.spriteSet._numSprites += 6;
			
					
				}
		
				style.setLetterZ( m.dotCacheIndex, 3, x < 0 ? 0 : -1);
				style.setLetterZ( m.dotCacheIndex + 3, 3,  !(m.scrolling & 2) ? 0 : -1);
				style.minXOffset = 0;
				
				
				
			}
		}
		
		public function get heightOffset():Number 
		{
			return _heightOffset;
		}
		
	}

}

class Message {
	public var str:String;
	public var span:Boolean = false;
	public var next:Message;
	public var prev:Message;
	
	public var boundCache:Array;
	public var referTextCache:String;
	public var boundHeight:Number;
	public var boundWidth:Number;
	
	public var numLines:int;
	
	// for horizontal scolling items 
	public var scrolling:int = 0;  // 0- not scrolling, 1- scrolling, 2- stopped scrolling, 4 - left , 8 - right
	public var charIndexCache:int;
	public var yValueCache:Number;
	public var startX:Number = 0;
//	public var lastScrolling:int = 0;
	public var dotCacheIndex:uint;
	
	//public var numLinesCache:int;
	//public var eom:Boolean = false; // line case end of message flag
	
	public function Message() {
		
	}
}