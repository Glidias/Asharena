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
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.Loader;
    import flash.display.Sprite;
    import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.net.URLRequest;
    import flash.system.LoaderContext;
    import flash.text.TextField;
	import flash.ui.Keyboard;

    /**
     * Island explorer utility and previewer
     * @author Glidias
     */
    [SWF(width = "465", height = "465", frameRate = "30", backgroundColor = "#ffffff")]
    
    public class WonderFLIsles extends Sprite 
    {
    
        //標準偏差の閾値。小さくすると細かくなるけど、小さすぎるとただのモザイクみたくなる。
        private const THRESHOLD:Number = .33;

        private var fillRectangleArray:Array;
        private var image:Bitmap;
        private var imageData:BitmapData;
        private var _canvas:Sprite;
		public var seed:uint;

        public function WonderFLIsles():void 
        {
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
		}
		
		private function onKeyDown(e:KeyboardEvent):void 
		{
			var kc:uint = e.keyCode;
			
			if (kc === Keyboard.UP ) {
				init(tx, ty-1);
			}
			else if (kc === Keyboard.DOWN) {
				init(tx, ty+1);
			}
			else if (kc === Keyboard.LEFT) {
				init(tx-1, ty);
			}
			else if (kc === Keyboard.RIGHT) {
				init(tx+1, ty);
			}
			
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
            //フラクタルデータ保持用配列に初期値挿入
            fillRectangleArray = new Array(p);
			
		  tx = setX; 
		   ty = setY;
		  seed = (ty * uint.MAX_VALUE + tx) + int.MAX_VALUE;
	
		  updateLores();
		  _canvas.graphics.clear();
			while (onEnterFrame()) { };
			//addEventListener(Event.ENTER_FRAME, onEnterFrame);
        }
		
		private static const BM_SIZE_SMALL:Number = 64;

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
				  var cont:Sprite = new Sprite();
				addChild(cont);
				cont.scaleX = 4;
				cont.scaleY = 4;
		 addChild(_noiseBmp);
            cont.addChild(_canvas);
			_canvas.x += BM_SIZE_SMALL / 4;
      //   addEventListener(Event.ENTER_FRAME, onEnterFrame);
		 
		
		 
		//addEventListener(Event.ENTER_FRAME, updateNoiseEnterFrame);
        }
		
		private function updateNoiseEnterFrame(e:Event):void 
		{
				tx += (1)/64;
				ty+= (1 )/64;
				updateLores();
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
				
				

                var halfWidth:Number = (rect.x1 - rect.x0) / 2;
                var halfHeight:Number = (rect.y1 - rect.y0) / 2;

                // 指定した矩形内の輝度の標準偏差値が閾値以上なら2分木して処理続行
                if (rect.c > THRESHOLD && (halfWidth > 1 || halfHeight > 1)) {
                    //矩形を書くよ
                    _canvas.graphics.lineStyle(0, 0xAAAAAA);
                    _canvas.graphics.beginFill( (cArray[1] & 0xFF) > 128 ? 0x00CCFF : 0x0000CC  );
                    _canvas.graphics.drawRect(rect.x0, rect.y0, (rect.x1 - rect.x0), (rect.y1 - rect.y0));
                    
                    //矩形を2分割してフラクタルデータ保持用配列に突っ込む
                    var rect0:RectanglePiece = new RectanglePiece();
                    var rect1:RectanglePiece = new RectanglePiece();
                    if (halfWidth > halfHeight) {
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
                }
				return true;
            }
			
			
			return false;
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
        public function RectanglePiece() 
        {
             this.x0 = 0;
             this.y0 = 0;
             this.x1 = 0;
             this.x1 = 0;
             this.c = 0;            
        }
        
    }
