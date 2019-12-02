package wonderfl {
    import flash.text.TextFormatAlign;
    import flash.text.TextFormat;
    import flash.text.TextField;
    import flash.events.MouseEvent;
    import flash.events.Event;
    import flash.display.Sprite;
    [SWF(frameRate = "60", width="465", height="465")]
    public class SwingingBoard extends Sprite {
        private var vs:Vector.<Vtx>;
        private var ss:Vector.<Spr>;
        private var press:Boolean;
        private var fixed1:Vtx;
        private var fixed2:Vtx;
        private var box1:Vtx;
        private var box2:Vtx;
        private var wx:Number;
        private var wy:Number;
        private var tf:TextField;
        private var boardW:Number = 160;
        private var boardH:Number = 80;
         
        public function SwingingBoard() {
            init();
        }
         
        private function init():void {
            var numChain:int = 16;
            var chainLen:Number = 8;
            var center:Number = 465 * 0.5;
            vs = new Vector.<Vtx>(numChain * 2 + 4, true);
            ss = new Vector.<Spr>();
            var x1:Number = center - boardW * 0.5;
            var x2:Number = center + boardW * 0.5;
            var y:Number = 100;
            fixed1 = vs[0] = new Vtx(center - boardW * 0.5, y, 0);
            fixed2 = vs[numChain] = new Vtx(center + boardW * 0.5, y, 0);
			var massChain:Number = 3;
            for (var i:int = 1; i < numChain; i++) {
                y += chainLen;
                vs[i] = new Vtx(x1, y, massChain);
                vs[i + numChain] = new Vtx(x2, y, massChain);
                ss.push(new Spr(vs[i], vs[i - 1], chainLen, false, true));
                ss.push(new Spr(vs[i + numChain], vs[i + numChain - 1], chainLen, false, true));
            }
            var i1:int = numChain * 2;
            var i2:int = numChain * 2 + 1;
            var i3:int = numChain * 2 + 2;
            var i4:int = numChain * 2 + 3;
            y += chainLen;
            box1 = vs[i1] = new Vtx(x1, y, 0.2);
            box2 = vs[i2] = new Vtx(x2, y, 0.2);
            y += boardH;
            vs[i3] = new Vtx(x1, y, 0.2);
            vs[i4] = new Vtx(x2, y, 0.2);
            ss.push(new Spr(vs[numChain - 1], vs[i1], chainLen, false, true));
            ss.push(new Spr(vs[numChain * 2 - 1], vs[i2], chainLen, false, true));
            ss.push(new Spr(vs[i1], vs[i2], boardW, true, true));
            ss.push(new Spr(vs[i3], vs[i4], boardW, true, true));
            ss.push(new Spr(vs[i1], vs[i3], boardH, true, true));
            ss.push(new Spr(vs[i2], vs[i4], boardH, true, true));
            var diag:Number = Math.sqrt(boardW * boardW + boardH * boardH);
            ss.push(new Spr(vs[i1], vs[i4], diag, true, false));
            ss.push(new Spr(vs[i2], vs[i3], diag, true, false));
            ss.fixed = true;
             
            wx = 465 * 0.5;
            wy = 100;
             
            tf = new TextField();
            var dtf:TextFormat = new TextFormat("Courier New", 30);
            dtf.leading = -14;
            dtf.align = TextFormatAlign.CENTER;
            tf.defaultTextFormat = dtf;
            tf.text = "\nA Board";
            tf.width = boardW;
            tf.selectable = false;
            addChild(tf);
             
            stage.addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent = null):void {
                press = true;
            });
            stage.addEventListener(MouseEvent.MOUSE_UP, function(e:MouseEvent = null):void {
                press = false;
            });
 
            addEventListener(Event.ENTER_FRAME, loop);
        }
         
        private function rnd():Number {
            return Math.random() * 10 - 5;
        }
         
        private function loop(e:Event = null):void {
            graphics.clear();
            graphics.lineStyle(1, 0);
            if ((mouseX != 0 || mouseY != 0) && press) {
                //wx += (mouseX - wx) * 0.4;
                wy += (mouseY - 16 - wy) * 0.4;
            }
            graphics.moveTo(0, wy);
            graphics.lineTo(465, wy);


            fixed1.vx = wx - boardW * 0.25 - fixed1.x;
            fixed1.vy = wy - fixed1.y;
            fixed2.vx = wx + boardW * 0.25 - fixed2.x;
            fixed2.vy = wy - fixed2.y;
            var numV:int = vs.length;
            for (var i:int = 0; i < numV; i++) {
                var v:Vtx = vs[i];
                v.move();
            }
             
            var nx:Number = box2.x - box1.x;
            var ny:Number = box2.y - box1.y;
            tf.x = box1.x;
            tf.y = box1.y;
            tf.rotationZ = Math.atan2(ny, nx) / Math.PI * 180;
             
            var numS:int = ss.length;
            for (var t:int = 0; t < 32; t++) {
                ss[0].move();
                for (i = 1; i < numS; i++) {
                    ss[i].move();
                    var swap:int = int(Math.random() * i);
                    var tmp:Spr = ss[i];
                    ss[i] = ss[swap];
                    ss[swap] = tmp;
                }
                for (i = 1; i < numV; i++) {
                    vs[i].wall(wy);
                }
            }

            for (i = 0; i < numV; i++) {
                vs[i].draw(graphics);
            }
            for (i = 0; i < numS; i++) {
                ss[i].draw(graphics);
            }
        }
    }
}
import flash.display.Graphics;
 
class Vtx {
    public var x:Number;
    public var y:Number;
    public var vx:Number;
    public var vy:Number;
    public var mass:Number;
     
    public function Vtx(x:Number, y:Number, mass:Number) {
        this.x = x;
        this.y = y;
        vx = 0;
        vy = 0;
        this.mass = mass;
    }
     
    public function move():void {
        x += vx;
        y += vy;
        if (mass != 0) {
            vy += 0.5;
        }
    }
     
    public function wall(wy:Number):void {
        if (mass != 0 && y + vy < wy) {
            vy += wy - (y + vy);
        }
    }
     
    public function draw(g:Graphics):void {
        if (mass == 0){
            g.drawCircle(x, y, 5);
        }
    }
 
}
 
class Spr {
    public var v1:Vtx;
    public var v2:Vtx;
    public var rest:Number;
    public var visible:Boolean;
    public var rigid:Boolean;
     
    public function Spr(v1:Vtx, v2:Vtx, rest:Number, rigid:Boolean, visible:Boolean) {
        this.v1 = v1;
        this.v2 = v2;
        this.rest = rest;
        this.rigid = rigid;
        this.visible = visible;
    }
     
    public function move():void {
        var dx:Number = (v2.x + v2.vx) - (v1.x + v1.vx);
        var dy:Number = (v2.y + v2.vy) - (v1.y + v1.vy);
        var dist:Number = Math.sqrt(dx * dx + dy * dy);
        if (dist == 0) return;
        var m:Number = 1 / (v1.mass + v2.mass);
        var invDist:Number = 1 / dist;
        var dvx:Number = v2.vx - v1.vx;
        var dvy:Number = v2.vy - v1.vy;
        var nx:Number = dx * invDist;
        var ny:Number = dy * invDist;
        var rvn:Number = nx * dvx + ny * dvy;
        var f:Number = m * (dist - rest + rvn * 0.5);
        if (!rigid && f < 0) f = 0;
        var fx:Number = nx * f;
        var fy:Number = ny * f;
        v1.vx += fx * v1.mass;
        v1.vy += fy * v1.mass;
        v2.vx -= fx * v2.mass;
        v2.vy -= fy * v2.mass;
    }
     
    public function draw(g:Graphics):void {
        if (!visible) return;
        g.moveTo(v1.x, v1.y);
        g.lineTo(v2.x, v2.y);
    }
 
}