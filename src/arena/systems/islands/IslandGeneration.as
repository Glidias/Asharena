
package arena.systems.islands {
	//import alternterrainxtras.msa.MathUtils;
	//import alternterrainxtras.msa.Perlin;
	//import alternterrainxtras.msa.Smoothing;
	import alternterrainxtras.msa.MathUtils;
	import alternterrainxtras.msa.Perlin;
	import alternterrainxtras.msa.Smoothing;
	import com.bit101.components.NumericStepper;
	import com.bit101.components.VBox;
	import de.polygonal.math.PM_PRNG;
	import terraingen.island.mapgen2;
	//import de.polygonal.math.PM_PRNG;
    import flash.display.Bitmap;
    import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.GraphicsPath;
	import flash.display.GraphicsPathWinding;
	import flash.display.IGraphicsData;
    import flash.display.Loader;
    import flash.display.Sprite;
    import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
	import flash.geom.Rectangle;
    import flash.net.URLRequest;
    import flash.system.LoaderContext;
    import flash.text.TextField;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;
	//import terraingen.island.mapgen2;

    
    [SWF(width = "465", height = "465", frameRate = "30", backgroundColor = "#ffffff")]
    
    public class IslandGeneration extends Sprite 
    {
		public static var LATE_LEAF:Boolean = false;
        
        public var THRESHOLD:Number = LATE_LEAF ? .35 : .15;
		public var COLOR_THRESHOLD:uint = 168;

        private var fillRectangleArray:Array;

        private var imageData:BitmapData;
       
		public var seed:uint;


		private var rootNode:KDNode;
		private var prng:PM_PRNG;
		
		private var seededNodeDict:Dictionary = new Dictionary();
		
		private const OFFSETS:Vector.<int> = createOffsetTable();
		private static function createOffsetTable():Vector.<int> {
			var vec:Vector.<int> = new Vector.<int>(8, true);
			var len:int = vec.length;
			var count:int = 0;
			
			for (var i:int = 1; i < len; i++) {
				var totalPerLevel:int = (1 << (i-1));
				totalPerLevel *= totalPerLevel;
				vec[i] = count += totalPerLevel;
			}

			return vec;
		}
		
        public function IslandGeneration():void 
        {
			prng = new PM_PRNG();
			
           loadComplete();
		  
        }
		

		
		private var foundLevel:int;
		public function findNode(x:Number, y:Number):KDNode {
			si  = 1;
		
			var curLevel:int;
			searchStack[0] = rootNode;
			searchStackLevels[0] = 0;
			
			var node:KDNode  = null;
			
			while (si > 0) {
				node = searchStack[--si];
				curLevel = searchStackLevels[si];
				
				if  ( (node.flags & 1) && !(x < node.boundMinX || x > node.boundMaxX || y < node.boundMinY || y > node.boundMaxY)  ) {
					foundLevel = curLevel;
					return node;
				}
				
			
			if (node.positive && (node.flags & KDNode.FLAG_SLAVE) == 0) {
				searchStack[si] = node.positive;
				searchStackLevels[si] = curLevel + (node.splitDownLevel() ?  1 : 0);
				si++;
			}
				if (node.negative) {
					searchStack[si] = node.negative;
					searchStackLevels[si] = curLevel + (node.splitDownLevel() ?  1 : 0);
					si++;
				}
			
		
			}
			return null;
		}
		
		public function generateNode(node:KDNode):void 
		{
			

				if (node.isSeeded()) {
					if (_mapGen && _mapGen.parent) {
						removeChild(_mapGen);
					}
					
			
					hitAreas.mouseChildren = false;
					hitAreas.mouseEnabled = false;
					mapgen2.PREVIEW_SIZE = getShortSide(foundLevel);  
					mapgen2.SIZE = 1024;
					mapgen2.islandSeedInitial = node.seed+"-1";
					_mapGen = new mapgen2();
					_mapGen.visible = false;
					_mapGen.mouseChildren = false;
					_mapGen.mouseEnabled = false;
					_mapGen.addEventListener(mapgen2.COMPLETED, onMapGenCompleted);

				
					addChild(_mapGen);
					_mapGen.scaleX = .25;
					_mapGen.scaleY = .25;
					
				}
		
		}
		
		private function onMapGenCompleted(e:Event):void 
		{
			
			_mapGen.removeEventListener(e.type, onMapGenCompleted);

			/*
			var scaler:Number = 4;
			var child:Bitmap = hitAreas.addChild( _mapGen.getPreviewBmp(mapgen2.PREVIEW_SIZE * scaler) ) as Bitmap;
			previewBmps.push( child.bitmapData);
			child.x = _mapGen.x;
			child.y = _mapGen.y;
			child.scaleX = 1/scaler;
			child.scaleY = 1/scaler;
			
			vBox.alpha = 1;
								vBox.mouseChildren = true;
								hitAreas.mouseChildren = true;
					hitAreas.mouseEnabled = true; 
		
			*/
		
				removeChild(_mapGen);
					dispatchEvent(new Event(Event.COMPLETE));
					
				_mapGen = null;
			
		}
		
		private var _mapGen:mapgen2;
		
		

        
        public function init(setX:Number = 0, setY:Number=0 ):void 
        {
       
		 
		
		
		seededNodeDict = new Dictionary();
		
		   var p:RectanglePiece = new RectanglePiece();
            p.x0 = 0;
            p.y0 = 0;
            p.x1 = imageData.width;
            p.y1 = imageData.height;
            p.c = 0;
			rootNode = setupNode(p);
            
            fillRectangleArray = new Array(p);
			
		  tx = setX; 
		   ty = setY;
		   
		     var max:int = PM_PRNG.MAX;
			var sqDim:int = Math.sqrt(max);
			var radius:int = sqDim * .5;
			seed = ( (ty +radius)*sqDim + tx+radius);
			
			if (seed == 0) seed = 1;
			prng.setSeed( seed);

		  updateLores();

		  
			while (onEnterFrame()) { };
			
			cleanupTree();
		
			
			
        }
		
		
		private function cleanupTree():void 
		{
			var nodeIndex:int;
			var mult:Number;
			var curLevel:int;
			var node:KDNode;
			
			si  = 1;
			searchStack[0] = rootNode;
			searchStackLevels[0] = 0;
			
			
			while (si > 0) {
				node = searchStack[--si];
				curLevel = searchStackLevels[si];
				var shortSide:Number =  getShortSide(curLevel);
				
				if (node.flags & 1) {
					node.positive = null;
					node.negative = null;
					
					mult = (1 /shortSide );
					nodeIndex = OFFSETS[curLevel] + (node.boundMinY * mult) * (1 << curLevel) + (node.boundMinX * mult);
					seededNodeDict[  nodeIndex ] = node;
				
					seededNodeDict[node] = curLevel +"|"+nodeIndex+"|"+node.boundMinY+"|"+node.boundMinX + "| "+getShortSide(curLevel); 
					
					continue;
				}
			
				if (node.positive ) {
					searchStack[si] = node.positive;
				
					searchStackLevels[si] = curLevel + (node.splitDownLevel() ? 1 : 0);
					si++;
				}
				if (node.negative) {
					searchStack[si] = node.negative;
					
					searchStackLevels[si] = curLevel  + (node.splitDownLevel() ? 1 : 0);
					si++;
				}
			}
			
				
			
			
			si  = 1;
			searchStack[0] = rootNode;
			searchStackLevels[0] = 0;
			
			var masterOff:int;
			var slaveCount:int;
			
			while (si > 0) {
				node = searchStack[--si];
				curLevel = searchStackLevels[si];
				
				shortSide = getShortSide(curLevel);
				if (node.flags & 1) {
					
					
					mult = (1 /  shortSide);
					
					nodeIndex =  OFFSETS[curLevel] + (node.boundMinY * mult) * (1 << curLevel) + (node.boundMinX * mult);
				
					
					
					
					var off:int;
					var master:KDNode;
						var masterNodeIndex:int;
						var reachEnd:Boolean;
					var slave:KDNode;
				
					off = 0;
					slaveCount = 0;
					master = null;
					reachEnd = false;
					while (true) {  
						++off;
						reachEnd =  node.boundMinX * mult - off < 0;
						nodeIndex = !reachEnd ? OFFSETS[curLevel] + (node.boundMinY * mult) * (1 << curLevel) + (node.boundMinX * mult) - off : -1;
						if (nodeIndex != -1 && seededNodeDict[nodeIndex]) {
							master = seededNodeDict[nodeIndex];
							masterNodeIndex = nodeIndex;
							masterOff = off;
							
						}
						else break;
					}
			
					
					
					if (master == null) off = 0;
					else off = masterOff;
					if (reachEnd) off--;
					
					while (--off > -1) {  
						nodeIndex =  OFFSETS[curLevel] + (node.boundMinY * mult) * (1 << curLevel) + (node.boundMinX * mult) - off;
						slave = seededNodeDict[nodeIndex];
								if (master === slave) {  
									
									continue;
								
								}
								
						
						slave.flags |= KDNode.FLAG_SLAVE;
						slave.flags &= ~1;
						slave.positive = master;
						master.boundMaxX += shortSide;
						slaveCount++;
						delete seededNodeDict[nodeIndex];
						
			
					}
					
					if (slaveCount > 0) {
						master.offset = prng.nextDoubleRange(0, slaveCount * shortSide);
					}
		
					
					if (master!=null) continue;
					
					
					
					off = 0;
					master = null;
					slaveCount = 0;
					reachEnd = false;
					while (true) {  
						++off;
						reachEnd =  node.boundMinY * mult - off < 0;
						nodeIndex = !reachEnd ? OFFSETS[curLevel] + (node.boundMinY * mult - off) * (1 << curLevel) + (node.boundMinX * mult) : -1;
						if (nodeIndex != -1 && seededNodeDict[nodeIndex]) {
							master = seededNodeDict[nodeIndex];
							masterNodeIndex = nodeIndex;
							masterOff = off;	
						}
						else break;
					}
			
					if (master == null) off = 0;
					else off = masterOff;
					if (reachEnd) off--;
					
					while (--off > -1) {  
						nodeIndex =  OFFSETS[curLevel] + (node.boundMinY*mult- off) * (1 << curLevel) + (node.boundMinX * mult);
						slave = seededNodeDict[nodeIndex];
						if (master === slave) { 
								
									continue;
						}
						
						
						slave.flags |= KDNode.FLAG_SLAVE;
						slave.flags &= ~1;
						slave.positive = master;
					
						master.boundMaxY += shortSide;
						slaveCount++;
						delete seededNodeDict[nodeIndex];

					}
					
					if (slaveCount > 0) {
						master.offset = prng.nextDoubleRange(0, slaveCount * shortSide);
					}
				
					
					
					
					continue;
				}
				
				if (node.positive && ((node.flags & KDNode.FLAG_SLAVE)==0) ) {
					searchStack[si] = node.positive;
					searchStackLevels[si] = curLevel + (node.splitDownLevel() ? 1 : 0);
					si++;
				}
				if (node.negative) {
					searchStack[si] = node.negative;
						searchStackLevels[si] = curLevel + (node.splitDownLevel() ? 1 : 0);
					si++;
				}
				
				
					
			}
		}
		
		private static const BM_SIZE_SMALL:Number = 64;
		static public const INIT_ZONE:String = "initZone";
		

		private var bitmapData:BitmapData = new BitmapData(BM_SIZE_SMALL, BM_SIZE_SMALL, false, 0);
		public var tx:Number = 0;
		public var ty:Number = 0;
		private var postFunction:Function = Smoothing.linear;
		private var noiseFunction:Function = Perlin.fractalNoise;
		private var phase:Number = 0;
		private var brightness:Number = 0;
		private var contrast:Number = 3.29;
		private var scaler:Number = 128;

		
		public function updateLores():void {
			var x:Number;
			var y:Number;
			//bitmapData.lock();
			for (y = 0; y < BM_SIZE_SMALL; y++)
				for (x = 0; x < BM_SIZE_SMALL; x++) drawNoise(x, y, 4);
			//bitmapData.unlock();
			

			
			
		}
		
		public function drawNoise(x:Number, y:Number, r:Number):void {
			var i:Number = (x * r - BM_SIZE_SMALL * 0.5) / scaler + tx*r;
			var j:Number = (y * r - BM_SIZE_SMALL * 0.5) / scaler + ty*r;

			var n:Number = int( 255 * MathUtils.clamp(postFunction (MathUtils.contrast (MathUtils.brightness( noiseFunction(i, j, phase), brightness), contrast) ) ));
			
			bitmapData.setPixel(x, y, n + (n << 8) + (n << 16));
		}

        
        
        public function loadComplete():void 
        {

			
			
			Perlin.setParams( {octaves:4, H:0.64, lacunarity:2 } );


	
          
            imageData = bitmapData;


      
		 
		
        }
		
		private var searchStack:Vector.<KDNode> = new Vector.<KDNode>();
		private var searchStackLevels:Vector.<int> = new Vector.<int>();
		private var si:int = 0;
		
		private var hitAreas:Sprite;
		private var cont:Sprite;
		private var vBox:VBox;

		private var previewBmps:Vector.<BitmapData> = new Vector.<BitmapData>();
		private function disposePreviewBmps():void {
			var i:int = previewBmps.length;
			while (--i > -1) {
				previewBmps[i].dispose();
			}
			previewBmps.length = 0;
		}
		
		
		
		
		
		
        private function getShortSide(level:int):int {
			return BM_SIZE_SMALL / (1 << level);
		}
		
        
        private function onEnterFrame(e:Event=null):Boolean 
        {
			
	
            	
            
            if (fillRectangleArray.length < 1) {
                removeEventListener(Event.ENTER_FRAME, onEnterFrame);
					
				return false;
              
            }else {
                
                var rect:RectanglePiece = fillRectangleArray.shift();
                var cArray:Array = deviationLogic(rect.x0, rect.y0, rect.x1, rect.y1);
                rect.c = cArray[0];

                var halfWidth:Number = (rect.x1 - rect.x0) *.5;
                var halfHeight:Number = (rect.y1 - rect.y0) *.5;

                
                if (rect.c > THRESHOLD && (halfWidth > 1 || halfHeight > 1)) {
                    
                    
				
					var seeded:Boolean = (cArray[1] & 0xFF) > COLOR_THRESHOLD;
					
					if (seeded) {
						var mult:Number = (1 /  getShortSide(rect.level));
					
						var nodeIndex:int = OFFSETS[rect.level] + rect.y0*mult*(1<<rect.level) + rect.x0 *mult;
						
						 var isRect:int = rect.node.isRectangle();
						if (isRect == 1) seededNodeDict[nodeIndex + 1] = rect.node;

						var seededParent:RectanglePiece = LATE_LEAF ?  rect.findSeededParent() : null;
						if (seededParent)  seededParent.node.transferSeedTo( rect.node );
						else  rect.node.setSeed( prng.nextInt() );
						
					
					  rect.node.offset = isRect === 0 ? 0 : isRect === 1 ? prng.nextDoubleRange(0, (rect.node.boundMaxX - rect.node.boundMinX)*.5 ): prng.nextDoubleRange(0,(rect.node.boundMaxY - rect.node.boundMinY)*.5);
					
					}
					else {
						rect.node.flags &= ~1;
					}
					
				
						rect.node.flags |= 4;
					
                  
					
                    
                    var rect0:RectanglePiece = new RectanglePiece();
                    var rect1:RectanglePiece = new RectanglePiece();
					
					
                    if (halfWidth > halfHeight) {  
						rect.node.vertical = false;
                        rect0.x0 = rect.x0;
                        rect0.y0 = rect.y0;
                        rect0.x1 = rect.x0+halfWidth;
                        rect0.y1 = rect.y1;
                        fillRectangleArray.push(rect0);
						

                        rect1.x0 = rect.x0+halfWidth;
                        rect1.y0 = rect.y0;
                        rect1.x1 = rect.x1;
                        rect1.y1 = rect.y1;
                        fillRectangleArray.push(rect1);
						

                    }else {    
						rect.node.vertical = true;

                        rect0.x0 = rect.x0;
                        rect0.y0 = rect.y0;
                        rect0.x1 = rect.x1;
                        rect0.y1 = rect.y0+halfHeight;
                        fillRectangleArray.push(rect0);

                        rect1.x0 = rect.x0;
                        rect1.y0 = rect.y0+halfHeight;
                        rect1.x1 = rect.x1;
                        rect1.y1 = rect.y1;
                        fillRectangleArray.push(rect1);
                    }
	
		
				
					
					var node0:KDNode = setupNode(rect0);
					var node1:KDNode = setupNode(rect1);
					
				
					
					rect0.level = rect.node.splitDownLevel() ? rect.level + 1 : rect.level;
					rect1.level = rect0.level;
					
					if (LATE_LEAF || !rect.node.isSeeded() ) {
							rect0.parent = rect;
						rect1.parent = rect;
						rect.node.positive = node0;
						rect.node.negative = node1;
						
					}
					
				
                }
				return true;
            }
			
			
			return false;
        }
		
		 private function setupNode(p:RectanglePiece):KDNode {
            var node:KDNode;
          
		   node =  new KDNode();
		   
		 
		   
		    p.node = node;
		   
            node.boundMinX = p.x0;
            node.boundMinY = p.y0;
           
            node.boundMaxX = p.x1;
            node.boundMaxY = p.y1;
			
			
          
            
		  

            return node;
        }
		
		
        
        private function deviationLogic(x0:Number,y0:Number,x1:Number,y1:Number):Array {
            var rgb:uint = 0;
            var r:uint = 0;
            var g:uint = 0;
            var b:uint = 0;
            var hsb:Array = new Array();
            var bArray:Array = new Array();
            var br:Number = 0;
            var av:Number = 0;

            
            for (var i:int = x0; i < x1;i++ ) {
                for (var j:int = y0; j < y1; j++ ) {
                    rgb = imageData.getPixel(i, j);
                    r += (rgb >> 16) & 255;
                    g += (rgb >> 8) & 255;
                    b += rgb & 255;
                    hsb = uintRGBtoHSB(rgb);
                    br += hsb[2];
                    bArray.push(hsb[2]);
                }
            }
            av = br / bArray.length;
            r = r / bArray.length;
            g = g / bArray.length;
            b = b / bArray.length;
            rgb = (r << 16) | (g << 8) | (b << 0);
            
            br = 0;
            for (i = 0; i < bArray.length; i++ ) {
                br += (bArray[i] - av) *(bArray[i] - av);
            }
            return [Math.sqrt(br / bArray.length),rgb];
            
        }
        
        private function uintRGBtoHSB(rgb:uint):Array {
            var r:uint = (rgb >> 16) & 255;
            var g:uint = (rgb >> 8) & 255;
            var b:uint = rgb & 255;
            return RGBtoHSB(r, g, b);
        }
        
        private function RGBtoHSB(r:int, g:int, b:int):Array {
            var cmax:Number = Math.max(r, g, b);
            var cmin:Number = Math.min(r, g, b);
            var brightness:Number = cmax / 255.0;
            var hue:Number = 0;
            var saturation:Number = (cmax != 0) ? (cmax - cmin) / cmax : 0;
            if (saturation != 0) {
                var redc:Number = (cmax - r) / (cmax - cmin);
                var greenc:Number = (cmax - g) / (cmax - cmin);
                var bluec:Number = (cmax - b) / (cmax - cmin);
                if (r == cmax) {
                    hue = bluec - greenc;
                } else if (g == cmax) {
                    hue = 2.0 + redc - bluec;
                } else {
                    hue = 4.0 + greenc - redc;
                }
                hue = hue / 6.0;
                if (hue < 0) {
                    hue = hue + 1.0;
                }
            }
            return [hue, saturation, brightness];
        }
    }    
}
import flash.display.Sprite;

    
    class RectanglePiece 
    {
        public var x0:Number;
        public var y0:Number;
        public var x1:Number;
        public var y1:Number;
        public var c:Number;
		public var node:KDNode;
		public var parent:RectanglePiece;
		public var level:int;
		
        public function RectanglePiece() 
        {
             this.x0 = 0;
             this.y0 = 0;
             this.x1 = 0;
             this.x1 = 0;
             this.c = 0;            
			 this.level = 0;
        }
		
		public function findSeededParent():RectanglePiece {
			var p:RectanglePiece = parent;

			while (p != null) {
				if (p.node.flags & 1) return p;
				p = p.parent;
			}
			return null;
		}
    }

	class KDNode
	{
		public var positive:KDNode;
		public var negative:KDNode;
		public var boundMinX:Number;
		public var boundMaxX:Number;
		
		public var boundMinY:Number;
		public var boundMaxY:Number;
		
		
		
		
		
		public var seed:uint;
		public var flags:int;
		public static const FLAG_SEEDED:int = 1;
		public static const FLAG_VERTICAL:int = 2;
		public static const FLAG_CONSIDERSEED:int = 4;
		public static const FLAG_SLAVE:int = 8;   
		
		public var offset:int;
		
		public function setSeed(val:uint):void {
			flags |= FLAG_SEEDED;
			seed = val;
		}
		public function isSeeded():Boolean {
			return flags & FLAG_SEEDED;
		}
		public function get vertical():Boolean {
			return flags & FLAG_VERTICAL;
		}
		public function set vertical(val:Boolean):void {
			if (val) flags |= FLAG_VERTICAL
			else flags &= ~FLAG_VERTICAL;
		}
		
			
		
		
		
		public function getMeasuredShortSide():Number {
			return isRectangle() === 1 ? boundMaxY - boundMinY :  boundMaxX - boundMinX; 
		}
		
		public function splitDownLevel():Boolean {
			return flags & FLAG_VERTICAL;
		}
		
		
		
		public function isRectangle():int {  
			return boundMaxY - boundMinY == boundMaxX - boundMinX ? 0 : boundMaxY - boundMinY < boundMaxX - boundMinX ? 1 : 2;
		}
		
		public function KDNode() {
			flags  = 0;
			offset = 0;
		}
		
		public function transferSeedTo(node:KDNode):uint 
		{
			
			node.setSeed(seed);
			flags &= ~FLAG_SEEDED;
			flags &= ~FLAG_CONSIDERSEED;
			
			return seed;
		}
		
		
	}
	
	class HitArea extends Sprite {
		public var node:KDNode;
	
		public function HitArea(node:KDNode, x:Number, y:Number, width:Number, height:Number, buttonMode:Boolean=true) {
			this.node = node;
			graphics.beginFill(0, 0);
			graphics.drawRect(x, y, width, height);
			this.buttonMode = buttonMode;
		}
		
	}
	