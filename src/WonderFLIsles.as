/**
フラクタルで画像を描画

パクリ元ネタ:
fladdict » コンピューターに絵画を描かせる
http://fladdict.net/blog/2009/05/computer-painting.html

標準偏差：
http://www.cap.or.jp/~toukei/kandokoro/html/14/14_2migi.htm

画像の読み込み処理：
http://wonderfl.kayac.com/code/3fb2258386320fe6d2b0fe17d6861e7da700706a

RGB->HSB変換：
http://d.hatena.ne.jp/flashrod/20060930#1159622027

**/
package 
{
	import alternterrainxtras.msa.MathUtils;
	import alternterrainxtras.msa.Perlin;
	import alternterrainxtras.msa.Smoothing;
	import com.bit101.components.NumericStepper;
	import com.bit101.components.VBox;
	import de.polygonal.math.PM_PRNG;
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
	import terraingen.island.mapgen2;
	import terraingen.island.MapGen2Main;

    /**
     * Island explorer utility and previewer
     * @author Glidias
     */
    [SWF(width = "465", height = "465", frameRate = "30", backgroundColor = "#ffffff")]
    
    public class WonderFLIsles extends Sprite 
    {
    
        //標準偏差の閾値。小さくすると細かくなるけど、小さすぎるとただのモザイクみたくなる。
        private const THRESHOLD:Number = .35;

        private var fillRectangleArray:Array;
        private var image:Bitmap;
        private var imageData:BitmapData;
        private var _canvas:Sprite;
		public var seed:uint;
		private var locField:TextField;
		
		private var stepperX:NumericStepper;
		private var stepperY:NumericStepper;
		private var rootNode:KDNode;
		private var prng:PM_PRNG;
		
        public function WonderFLIsles():void 
        {
			prng = new PM_PRNG();
			
           loadComplete();
		   init();
		   if (stage) {
			   initStage();
		   }
		   else addEventListener(Event.ADDED_TO_STAGE, initStage);
		
        }
		
		private function initStage(e:Event=null):void 
		{
			if (e != null) (e.currentTarget as IEventDispatcher).removeEventListener(e.type, initStage);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false, 0, true);
			
			locField = new TextField();
			locField.autoSize = "left";
			locField.y = 64;
			locField.multiline = true;
			locField.height = 32;
			addChild(locField);
		
			
			var length:int = Math.sqrt(PM_PRNG.MAX);
		
			var vBox = new VBox(this, 0, 100);
			stepperX = new NumericStepper(vBox, 0, 0, onStepperChange);
			stepperY  = new NumericStepper(vBox, 0, 0, onStepperChange);
			stepperX.minimum =  -length * .5;
			stepperY.minimum = -length * .5;
			stepperX.maximum =  length * .5;
			stepperY.maximum = length * .5;
			
			updateLocField();
			hitAreas = new Sprite();
			hitAreas.addEventListener(MouseEvent.CLICK, onHitAreaClick);
			hitAreas.x = _canvas.x;
			hitAreas.y = _canvas.y;
			cont.addChild(hitAreas);
			
			 renderTree();
			
		}
		
		private function findNode(x:Number, y:Number):KDNode {
			si  = 1;
	
			searchStack[0] = rootNode;
			
			var node:KDNode  = null;
			
			while (si > 0) {
				node = searchStack[--si];
				//!node.negative && !node.positive && !(x < node.boundMinX || x > node.boundMaxX || y < node.boundMinY || y> node.boundMaxY )
				if  ( (node.flags &1) && !(x < node.boundMinX || x > node.boundMaxX || y < node.boundMinY || y> node.boundMaxY)  ) return node;
				
			
				if (node.positive) searchStack[si++] = node.positive;
				if (node.negative) searchStack[si++] = node.negative;
			
		
			}
			return null;
		}
		
		private function onHitAreaClick(e:MouseEvent):void 
		{
			// TODO: find proper target according to local x/y mouse position!
			
	
			var node:KDNode = findNode(e.localX, e.localY);  
			if (node == null) return;
		//	throw new Error(node);
		//	if (node.isSeeded()) {
				_canvas.graphics.beginFill(0x0000CC, 1);
			//	_canvas.graphics.drawRect(node.boundMinX + (node.isRectangle() === 1 ? node.offset : 0), node.boundMinY + (node.isRectangle() === 2 ? node.offset : 0), node.getShortSide(), node.getShortSide() );
				_canvas.graphics.drawRect(node.boundMinX, node.boundMinY, (node.boundMaxX - node.boundMinX), (node.boundMaxY - node.boundMinY));
		
				if (node.isSeeded()) {
					if (_mapGen && _mapGen.parent) {
						removeChild(_mapGen);
					}
					mapgen2.PREVIEW_SIZE = node.getShortSide();  // / cont.scaleX
					mapgen2.SIZE = 1024;
					mapgen2.islandSeedInitial = node.seed+"-1";
					_mapGen = new mapgen2();
					//_mapGen.visible = false;
					_mapGen.addEventListener(mapgen2.COMPLETED, onMapGenCompleted);

				
					addChild(_mapGen);
					_mapGen.x = node.boundMinX + (node.isRectangle() === 1 ? node.offset : 0);
					_mapGen.y = node.boundMinY + (node.isRectangle() === 2 ? node.offset : 0);
					_mapGen.scaleX = .25;
					_mapGen.scaleY = .25;
				}
		//	}
		}
		
		private function onMapGenCompleted(e:Event):void 
		{
			_mapGen.removeEventListener(e.type, onMapGenCompleted);
			var child:DisplayObject = hitAreas.addChild( _mapGen.getPreviewBmp() );
			child.x = _mapGen.x;
			child.y = _mapGen.y;
			removeChild(_mapGen);
			
			_mapGen = null;
		}
		
		private var _mapGen:mapgen2;
		
		private function onStepperChange(e:Event):void 
		{
			if (e.currentTarget === stepperX) {
				init(stepperX.value, ty);
			}
			else {
				init(tx, stepperY.value);
			}
			updateLocField();
		}
		
		private function onKeyDown(e:KeyboardEvent):void 
		{
			var kc:uint = e.keyCode;
			
			if (kc === Keyboard.UP ) {
				init(tx, ty - 1);
				 updateLocField();
			}
			else if (kc === Keyboard.DOWN) {
				init(tx, ty + 1);
				updateLocField();
			}
			else if (kc === Keyboard.LEFT) {
				init(tx - 1, ty);
				updateLocField();
			}
			else if (kc === Keyboard.RIGHT) {
				init(tx + 1, ty);
				updateLocField();
			}
			
		}
		
		private function updateLocField():void 
		{
			locField.text = "(" + tx + ", " + ty + ")\n"+seed;
			stepperX.value = tx;
			stepperY.value = ty;

		}
        
        public function init(setX:Number = 0, setY:Number=0 ):void 
        {
       //  setX *= 2;
		 
		// setY *= 2;
		   var p:RectanglePiece = new RectanglePiece();
            p.x0 = 0;
            p.y0 = 0;
            p.x1 = imageData.width;
            p.y1 = imageData.height;
            p.c = 0;
			rootNode = setupNode(p);
            //フラクタルデータ保持用配列に初期値挿入
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
		  _canvas.graphics.clear();
		  
			while (onEnterFrame()) { };
			
			cleanupTree();
			if (locField) renderTree();
			
			//addEventListener(Event.ENTER_FRAME, onEnterFrame);
        }
		
		// any nodes that are seeded, their children will be removed
		private function cleanupTree():void 
		{
			si  = 1;
	
			searchStack[0] = rootNode;
			
		
		
			
			while (si > 0) {
				var node:KDNode = searchStack[--si];
			
				if (node.flags & 1) {
					node.positive = null;
					node.negative = null;
					continue;
				}
				
				if (node.positive) searchStack[si++] = node.positive;
				if (node.negative) searchStack[si++] = node.negative;
				
				//if ((node.positive && !node.negative) || (node.negative && !node.positive)) throw new Error("MISMATCH!");
					
	
			}
		}
		
		private static const BM_SIZE_SMALL:Number = 64;
		//public function findNode

		private var bitmapData:BitmapData = new BitmapData(BM_SIZE_SMALL, BM_SIZE_SMALL, false, 0);
		public var tx:Number = 0;
		public var ty:Number = 0;
		private var postFunction:Function = Smoothing.linear;
		private var noiseFunction:Function = Perlin.fractalNoise;
		private var phase:Number = 0;
		private var brightness:Number = 0;
		private var contrast:Number = 3.29;
		private var scaler:Number = 128;
		private var _noiseBmp:Bitmap;
		
		// the updateAnimated function, draw the noise, updateAnimated colorswatch etc
		public function updateLores():void {
			var x:Number;
			var y:Number;
			bitmapData.lock();
			for (y = 0; y < BM_SIZE_SMALL; y++)
				for (x = 0; x < BM_SIZE_SMALL; x++) drawNoise(x, y, 4);
			bitmapData.unlock();
			//phase += sldSpeed.value;		

			
			//checkMouse();
		}
		
		public function drawNoise(x:Number, y:Number, r:Number):void {
			var i:Number = (x * r - BM_SIZE_SMALL * 0.5) / scaler + tx*r;
			var j:Number = (y * r - BM_SIZE_SMALL * 0.5) / scaler + ty*r;

			var n:Number = int( 255 * MathUtils.clamp(postFunction (MathUtils.contrast (MathUtils.brightness( noiseFunction(i, j, phase), brightness), contrast) ) ));
			//var n:Number = int(255 * noiseFunction(i, j, phase) );
			bitmapData.setPixel(x, y, n + (n << 8) + (n << 16));
		}

        
        //画像読み込み後の処理
        public function loadComplete():void 
        {
			
			// Fractal Brownian
            //octaves:4
			//falloff: 0.64
			// lacunarity: 2
			// offset: 0.8
			// scale:0.64*200
			// brightness:0
			// contrast: 3.29
			
			Perlin.setParams( {octaves:4, H:0.64, lacunarity:2 } );


	
          
            imageData = bitmapData;

            //キャンバス用スプライト
            _canvas = new Sprite;
            
           
            
				  _noiseBmp = new Bitmap(bitmapData);
				  cont = new Sprite();
				addChild(cont);
				cont.scaleX = 4;
				cont.scaleY = 4;
		 addChild(_noiseBmp);
            cont.addChild(_canvas);
			_canvas.x +=(BM_SIZE_SMALL+32) / 4;
      //   addEventListener(Event.ENTER_FRAME, onEnterFrame);
		 
		
        }
		
		private var searchStack:Vector.<KDNode> = new Vector.<KDNode>();
		private var si:int = 0;
		
		private var hitAreas:Sprite;
		private var cont:Sprite;

		
		private function renderTree():void {
			si  = 1;
	
			searchStack[0] = rootNode;
			
			var graphics:Graphics =_canvas.graphics;
			graphics.clear();
		//	 _canvas.graphics.lineStyle(0, 0xAAAAAA);
			hitAreas.removeChildren();
			
			//graphics.beginFill( rootNode.flags & 1 ? 0x00CCFF : 0x0000CC  );
			//graphics.drawRect(rootNode.boundMinX, rootNode.boundMinY, (rootNode.boundMaxX - rootNode.boundMinX), (rootNode.boundMaxY - rootNode.boundMinY));
			
			while (si > 0) {
				var node:KDNode = searchStack[--si];
			
				if (node.positive) searchStack[si++] = node.positive;
				if (node.negative) searchStack[si++] = node.negative;
			
				//if ((node.positive && !node.negative) || (node.negative && !node.positive)) throw new Error("MISMATCH!");
					
				//if (node.flags & 4) {
					//if (node.flags &1) {
				//	_canvas.graphics.lineStyle(0, node.flags & 1 ? 0xAAAAAA : 0x0000CC);
						graphics.beginFill( node.flags & 1 ? 0x00CCFF : 0x0000CC  );
						graphics.drawRect(node.boundMinX, node.boundMinY, (node.boundMaxX - node.boundMinX), (node.boundMaxY - node.boundMinY));
						hitAreas.addChild(  new HitArea(node, node.boundMinX, node.boundMinY, (node.boundMaxX - node.boundMinX), (node.boundMaxY - node.boundMinY), node.flags & 1) );
					//}
				//}
		
			}
		}
	
		
		
		
		
        
        //ループ
        private function onEnterFrame(e:Event=null):Boolean 
        {
	
            	
            //フラクタル処理終了
            if (fillRectangleArray.length < 1) {
                removeEventListener(Event.ENTER_FRAME, onEnterFrame);
					
				return false;
              
            }else {
                //フラクタルデータ保持用配列から1つ取り出す
                var rect:RectanglePiece = fillRectangleArray.shift();
                var cArray:Array = deviationLogic(rect.x0, rect.y0, rect.x1, rect.y1);
                rect.c = cArray[0];

                var halfWidth:Number = (rect.x1 - rect.x0) *.5;
                var halfHeight:Number = (rect.y1 - rect.y0) *.5;

                // 指定した矩形内の輝度の標準偏差値が閾値以上なら2分木して処理続行
                if (rect.c > THRESHOLD && (halfWidth > 1 || halfHeight > 1)) {
                    //矩形を書くよ
                    //_canvas.graphics.lineStyle(0, 0xAAAAAA);
				
					var seeded:Boolean = (cArray[1] & 0xFF) > 128;
					
					if (seeded) {
						
						var seededParent:RectanglePiece = rect.findSeededParent();// rect.parent && rect.parent.node.isSeeded ? rect.parent : null;
						if (seededParent)  seededParent.node.transferSeedTo( rect.node );
						else  rect.node.setSeed( prng.nextInt() );
						
					 var isRect:int = rect.node.isRectangle();
					  rect.node.offset = isRect === 0 ? 0 : isRect === 1 ? prng.nextDoubleRange(0, (rect.node.boundMaxX - rect.node.boundMinX)*.5 ): prng.nextDoubleRange(0,(rect.node.boundMaxY - rect.node.boundMinY)*.5);
					// if (isRect) throw new Error(rect.node.offset+","+prng.nextDoubleRange(0, rect.node.boundMaxX - rect.node.boundMinX));
					}
					else {
						rect.node.flags &= ~1;
					}
					
				
						rect.node.flags |= 4;
					//_canvas.graphics.beginFill( seeded ? 0x00CCFF : 0x0000CC  );
                  //  _canvas.graphics.drawRect(rect.x0, rect.y0, (rect.x1 - rect.x0), (rect.y1 - rect.y0));
                  
					
                    //矩形を2分割してフラクタルデータ保持用配列に突っ込む
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
	
			
					rect0.parent = rect;
					rect1.parent = rect;
					
					var node0:KDNode = setupNode(rect0);
					var node1:KDNode = setupNode(rect1);
				//	if (!rect.node.isSeeded() ) {
						rect.node.positive = node0;
						rect.node.negative = node1;
						
				//	}
					
				
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
           // node.boundMinZ = 0;
            node.boundMaxX = p.x1;
            node.boundMaxY = p.y1;
          //  node.boundMaxZ = MAX_Z_BOUNDS;
            
		  /*
            var bNode:KDNode;
            node.positive = bNode =  new KDNode();
            bNode.boundMinX = node.boundMinX;
            bNode.boundMinY = node.boundMinY;
            //bNode.boundMinZ = height;  // to be set later
            bNode.boundMaxX = node.boundMaxX;
            bNode.boundMaxY = node.boundMaxY;
           // bNode.boundMaxZ = MAX_Z_BOUNDS;
            
            node.negative = bNode =  new KDNode();
            bNode.boundMinX = node.boundMinX;
            bNode.boundMinY = node.boundMinY;
            //bNode.boundMinZ = 0;
            bNode.boundMaxX = node.boundMaxX;
            bNode.boundMaxY = node.boundMaxY;
            //bNode.boundMaxZ = height;  // to be set later
			*/

            return node;
        }
		
		
        /**
         * 指定した矩形間の輝度の標準偏差を求める
         * @param    x0    左上のx座標
         * @param    y0    左上のｙ座標
         * @param    x1    右下のx座標
         * @param    y1    右下のy座標
         * @return    標準偏差値とカラーの平均
         */
        private function deviationLogic(x0:Number,y0:Number,x1:Number,y1:Number):Array {
            var rgb:uint = 0;
            var r:uint = 0;
            var g:uint = 0;
            var b:uint = 0;
            var hsb:Array = new Array();
            var bArray:Array = new Array();
            var br:Number = 0;
            var av:Number = 0;

            //輝度の平均を計算
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
            //標準偏差を計算
            br = 0;
            for (i = 0; i < bArray.length; i++ ) {
                br += (bArray[i] - av) *(bArray[i] - av);
            }
            return [Math.sqrt(br / bArray.length),rgb];
            
        }
        /**
         * 
         * @param    rgb    RGB成分（uint)
         * @return HSB配列([0]=hue, [1]=saturation, [2]=brightness)
         */
        private function uintRGBtoHSB(rgb:uint):Array {
            var r:uint = (rgb >> 16) & 255;
            var g:uint = (rgb >> 8) & 255;
            var b:uint = rgb & 255;
            return RGBtoHSB(r, g, b);
        }
        /** RGBからHSBをつくる
         * @param r    色の赤色成分(0～255)
         * @param g 色の緑色成分(0～255)
         * @param b 色の青色成分(0～255)
         * @return HSB配列([0]=hue, [1]=saturation, [2]=brightness)
         */
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

    /**
     * ...
     * @author DefaultUser (Tools -> Custom Arguments...)
     */
    class RectanglePiece 
    {
        public var x0:Number;
        public var y0:Number;
        public var x1:Number;
        public var y1:Number;
        public var c:Number;
		public var node:KDNode;
		public var parent:RectanglePiece;
		
        public function RectanglePiece() 
        {
             this.x0 = 0;
             this.y0 = 0;
             this.x1 = 0;
             this.x1 = 0;
             this.c = 0;            
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
		public function getShortSide():Number {
			//throw new Error(isRectangle() === 1);
			return isRectangle() === 1 ? boundMaxY - boundMinY :  boundMaxX - boundMinX; 
		}
		
		/**
		 * 
		 * @return  0 - Is a square, 1 - horizontal rectangle, 2 - vertical rectangle 
		 */
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