package alternativa.a3d.systems.text 
{
	import alternativa.engine3d.alternativa3d;
	import ash.core.NodeList;
	import ash.signals.Signal1;
	import ash.signals.Signal2;
	use namespace alternativa3d;
	/**
	 * A message alert/text container to hold either transcient/permanent messages.
	 * Also supports scrolling marquee messages and paginated scrolling.
	 * 
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
		public const onContentHeightChange:Signal2 = new Signal2();
		
		// Key settings
		alternativa3d var maxDisplayedItems:uint;

		private var lastRenderedHead:StringNode;
		private var lastRenderedTail:StringNode;
		private var _lastScrollNode:StringNode;
		
		alternativa3d var displayedItems:uint = 0;
		alternativa3d var countdown:Number;
		// More Settings
		public var timeout:Number;   // the timeout before topmost message vanishes, set to negative value to have no timeout
		public var vSpacing:Number;  // the spacing between messages
		public var maskMinY:Number = -Number.MAX_VALUE;  // the negative y height value to conceal text above the chatbox..
		public var enableMarquee:Boolean = false;  // whether to make paragraphs turn to single-lines, if not enough space to show no. of displayedItems
		public var history:StringLog;   // whether to push messages into history log, this must be used to handle scrolling of data
		public var dotMarqueeOffset:Number = 10;  // the ... marquee offset to the left
		public var dotMarqueeOffsetRight:Number = 3;  // the ... marquee offset to the right
		
		public var width:Number = 200;
		public var centered:Boolean = false;
		
		alternativa3d var showItems:uint  = 0;
		public var lineSpacing:Number = 14;
		
		public function setShowItems( amtItems:uint):void {
			
			if (amtItems > maxDisplayedItems) throw new Error("This method only allows setting of items below or equal the amount of maxItems. If you need to go beyond this, use setMaxDisplayedItemsAgainstHistory and provide a history log");
			showItems = amtItems;
			
			maskMinY = (lineSpacing + vSpacing) * -amtItems;
			
			dirty = true;
			dirtyFlags |= 1;
		}
		public function getShowItems():uint {
			return showItems;
		}
		
		// will truncate currently displayedItems data permanentnly to fit maxItems if needed
		public function setMaxDisplayedItemsTruncate(maxItems:uint):void {
			if (maxItems == 0) throw new Error("Invalid amount specified:" + maxItems);
			if (maxItems < displayedItems) {
				var i:int = displayedItems - maxItems;
				while (--i > -1) {
					displayedItems--;
					if (displayedItems==0) tail = null;
					if (head.next) {
						head.next.prev = null;
					}
					head = head.next;
				}
			}
			this.maxDisplayedItems = maxItems;
			dirty = true;
			dirtyFlags |= 1;
		}
		public function getMaxDisplayedItems():uint {
			return maxDisplayedItems;
		}
		
		public function scrollUpHistory():void {
			if (lastRenderedHead === null) return;
			if (_lastScrollNode != null) {
				lastRenderedHead = _lastScrollNode.previous as StringNode;
				if (lastRenderedHead === null) return;
				_lastScrollNode = null;
				
			}
			setMaxDisplayedItemsFromEndNode(maxDisplayedItems, lastRenderedHead); 
			
			
		}
		public function scrollDownHistory():void {
			if (lastRenderedTail === null) return;
			if (_lastScrollNode != null) {
				lastRenderedTail = _lastScrollNode.next as StringNode;
				if (lastRenderedTail === null) {
					_lastScrollNode = null;
					setMaxDisplayedItemsFromEndNode(maxDisplayedItems, history.nodeList.tail as StringNode, true); 
					return;
				}
				_lastScrollNode = null;
				
			}
			else if ( history.nodeList.tail === tail.node) return;
			setMaxDisplayedItemsFromStartNode(maxDisplayedItems, lastRenderedTail); 
			
		}
		
		public function setMaxDisplayedItemsFromStartNode(amtItems:uint, node:StringNode):void {
			_lastScrollNode = null;
			// basically, scrolling down from startNode is more involved, since we need to track all of the last fully rendered items, 
			// and than setMaxDisplayedItemsFromEndNode from there...
			// if last rendered item isn't a fully rendered one, than we also need to append an additional semi-rendered item message after it
			// based on the last rendered item but with truncated lines (without logging it to history!)
			
			if (node === history.nodeList.tail) {
				setMaxDisplayedItemsFromEndNode(amtItems, node);
				return;
			}
			
		maxDisplayedItems = amtItems;
				

				
			
			
			
			var style:FontSettings = styles[0];
			var linesLeft:int = amtItems;
			var lastValidNode:StringNode;
			var validCount:int = 0;

			for (var n:StringNode = node; n != null; n = n.next as StringNode) {
				var para:String = style.fontSheet.fontV.getParagraph(n.str, 0, 0, width, style.boundParagraph);
				var paraSplit:Array= para.split("\n");
				linesLeft -=  paraSplit.length;
				if (linesLeft <= 0) {
					//if (linesLeft == 0) {
						lastValidNode = n; 
						validCount++;
					//}
					break;
				}
				lastValidNode = n;
				validCount++;
			}
			
			
			//, (history ? lastValidNode === history.nodeList.tail : false)
			setMaxDisplayedItemsFromEndNode(maxDisplayedItems, lastValidNode );
			/*
			if (linesLeft < 0) {
				while (linesLeft < 0) {
					paraSplit.pop();
					linesLeft++;
				}
				
				var lastHistory:StringLog = history;
				history = null;
				appendMessage( paraSplit.join("\n") );
				
				history = lastHistory;
			}
			*/
			
			
		
		}
		
		public function setMaxDisplayedItemsFromEndNode(amtItems:uint, node:StringNode,  roundNext:Boolean=false):void { 
			_lastScrollNode = null;
			
			maxDisplayedItems = amtItems;
			maskMinY = (lineSpacing + vSpacing) * -amtItems;
			dirty = true;
			dirtyFlags |= 1;
			
			var me:Message;
			
			if (!roundNext) {  // consider round previous case
				
				var style:FontSettings = styles[0];
				var para:String = style.fontSheet.fontV.getParagraph(node.str, 0, 0, width, style.boundParagraph);
				var paraSplit:Array = para.split("\n");
				if (paraSplit.length > amtItems) {
					
					paraSplit = paraSplit.slice(0, amtItems);
					
					// unlink entire linked list first? 
					
					
					// create makeshift paraSplit node and display that only
					me = new Message();
					me.node = new StringNode(paraSplit.join("\n"));
					head = tail =  me;
					_lastScrollNode = node;
					return;
				}
				
			}
			
			me = tail;
			if (me == null) {
				me = new Message();
				tail = me;
			}
			var lastMe:Message = me;
			me.node = node;
			me.boundCache = null;
			me.scrolling = 0;
			me.startX  = 0;
				
			me = me.next;
	
			
			var linesLeft:int = maxDisplayedItems
			var count:int = 1;
			for (var n:StringNode = node.previous as StringNode; n != null; n = n.previous as StringNode) {
				
				if (count >= amtItems) break;
				
				if (me == null) me = new Message();
			
				me.node = n;
				me.boundCache = null;
				me.scrolling = 0;
				me.startX  = 0;
				lastMe.prev = me;
				me.next = lastMe;
				
				lastMe = me;
				me = me.prev;
				count++;
			}
			
			
			
			head = lastMe;
			if (lastMe.prev != null) {
				lastMe.prev.next = null;
				// unlink entire chain before lastMe??
			}
			lastMe.prev = null;
			
		
			 n = node.next as StringNode;
			 if (n != null) {
				// var appendCount:int = 0;
				while ( count < amtItems) {
					
					
					//if (n != null) {
					//appendMessage("A:" + count);
					tail.next = new Message();
					tail.next.prev = tail;
					tail.next.node = n;
					tail = tail.next;
					//}
					n =  n.next as StringNode;
					count++;
					//appendCount++;
				}
				//throw new Error(appendCount + ", "+count);
			 }
			
			
			// some temporary debug checks atm
			if (amtItems != 5) throw new Error("SJOUT NOT BE!"+amtItems);
			count = 0;
			for (var t:Message = tail; t != null; t = t.prev) {
				count++;
				if (count > amtItems) throw new Error("SHOULD NTO BE!");
			}
		}
		
		public function TextBoxChannel(styles:Vector.<FontSettings>, maxDisplayedItems:uint=5, timeout:Number=-1, vSpacing:Number=3) 
		{
		
			//	timeout = -1;
			//lineSpacing = 14;
			//maskMinY = (14 + vSpacing) * -maxDisplayedItems;
			//throw new Error(maskMinY);
			//maxDisplayedItems = 200;
		
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
			if (history != null && tail!=null  && history.nodeList.tail != tail.node) {
				setMaxDisplayedItemsFromEndNode(maxDisplayedItems, history.nodeList.tail as StringNode, true);
			}
			
			displayedItems++;
			if (displayedItems > maxDisplayedItems) {  // loop back
				displayedItems = maxDisplayedItems;
				tail.next = me = head;
				me.prev = tail;
				head = me.next;
				if (me.next != null) me.next.prev = null;
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
			
			me.node  = new StringNode(val);
			
			if (history != null) {
				
				history.addNode(me.node); 
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
			var spareLines:int = enableMarquee ?  (showItems != 0 ? showItems : maxDisplayedItems ) - displayedItems : 2147483647;
			
			lastRenderedTail = tail ? tail.node : null;
			lastRenderedHead = null;
			for (m = tail; m != null; m = m.prev) {
				//m.node.str;
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
								style.fontSheet.fontV.getBound(m.node.str, 0, 0, centered, style.fontSheet.tight, style.boundParagraph);
								m.boundHeight = style.boundParagraph.maxY - style.boundParagraph.minY;
								heighter -= m.boundHeight + vSpacing;
								m.yValueCache = heighter;
								style.writeData(m.node.str, 0, heighter, 0, centered, li, width, maskMinY); 
							 
								
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
								style.fontSheet.fontV.getBound(style.fontSheet.fontV.getParagraph(m.node.str, 0, 0, width, style.boundParagraph), 0, heighter, centered, style.fontSheet.tight, style.boundParagraph);
							m.boundHeight = style.boundParagraph.maxY - style.boundParagraph.minY;
									heighter -= m.boundHeight + vSpacing;
								m.yValueCache = heighter;
								style.writeData(m.node.str, 0,heighter, width, centered, li, 1.79e+308, maskMinY); 
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
					//style.writeData(m.node.str, 0, heighter, 0, centered, li);  // line case
					//style.writeData(m.node.str, 0, heighter, width, centered, li); 
					
					var checkPara:String = style.fontSheet.fontV.getParagraph(m.node.str, 0, 0, width, style.boundParagraph);
					
				
					m.numLines = checkPara.split("\n").length;
					
					if (m.numLines > 1) {
						spareLines -= m.numLines - 1;
						if (spareLines < 0) {
							_scrollMessages[_numScrollingMsgs++]  = m;
							m.scrolling = 1;	
							//if (m.startX != 0) throw new Error("SHOULD NOT BE!:"+m.startX);
								m.startX  = width * .25;
								style.fontSheet.fontV.getBound(m.node.str, 0, 0, centered, style.fontSheet.tight, style.boundParagraph);
							m.boundHeight = style.boundParagraph.maxY - style.boundParagraph.minY;
							heighter -= m.boundHeight + vSpacing;
							m.yValueCache = heighter;
							 style.writeData(m.node.str, 0, heighter, 0, centered, li, width, maskMinY); 
							
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
						style.fontSheet.fontV.getBound(m.node.str, 0, 0, centered, style.fontSheet.tight, style.boundParagraph);
						m.boundHeight = style.boundParagraph.maxY - style.boundParagraph.minY;
						heighter -= m.boundHeight + vSpacing;
						m.yValueCache = heighter;
						style.writeData(m.node.str, 0, heighter, width, centered, li, width, maskMinY); 
					
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
				lastRenderedHead = m.node;
				if (style._outsideBound) break;  // mi >= maxDisplayedItems || 
				//if ( mi >= maxDisplayedItems) break;
			}
			
			

				//	throw new Error(arr);
				style.spriteSet._numSprites = li;// ,
				_heightOffset = -heighter;
				//style.spriteSet.y = _heightOffset;
	
				
			
				dirtyFlags = 0;
				
				onContentHeightChange.dispatch(style._outsideBound ? -maskMinY - vSpacing : _heightOffset, style._outsideBound);
		
		}
		
		public function resetAllScrollingMessages():void {
			for (var i:int = 0; i < _numScrollingMsgs; i++) {
				var m:Message=_scrollMessages[i];
				m.startX = width * .25 * .5;
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

import alternativa.a3d.systems.text.StringNode;

class Message {
	//public var str:String;
	public var node:StringNode;
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