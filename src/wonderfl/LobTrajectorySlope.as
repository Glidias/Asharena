/**
 * Copyright Glidias ( http://wonderfl.net/user/Glidias )
 * MIT License ( http://www.opensource.org/licenses/mit-license.php )
 * Downloaded from: http://wonderfl.net/c/316X
 */

// forked from Glidias's forked from: forked from: Trajectory Path formula
// forked from Glidias's forked from: Trajectory Path formula
package  wonderfl
{
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.geom.Point;
    import flash.geom.Vector3D;
    import flash.ui.Keyboard;
    
    /**
    
     * @author Glenn Ko
     */
    [SWF(frameRate="60", backgroundColor="#FFFFFF")]
    public class LobTrajectorySlope extends Sprite 
    {
        private var SPEED:Number = 244;
        private var DRAW_SEGMENTS:int  = 16;
        private var startPosition:Point = new Point();
        private var GRAVITY:Number = 266;
        
        private var velocity:Point = new Point();
        private var _displace:Point = new Point();
        
        private var curPosition:Point = new Point();
        private var curSprite:Sprite = new Sprite();
        
        private var totalFlightTime:Number;
        
        private var _tRise:Number;
        private var _h:Number;
        
        private var slopeHeight:Number;
        private var mSlope:Number;
        
        public function LobTrajectorySlope() 
        {
           
            
            y= -130;
            startPosition.x = 100;
            startPosition.y = stage.stageHeight -100;
            
            slopeHeight = 300;
            
            
            mSlope = slopeHeight/1;
            
            
            curPosition = startPosition.clone();
            

            
            
            drawPath();
            
            stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
            addEventListener(Event.ENTER_FRAME, onEnterFrame);
            
            curSprite.graphics.beginFill(0xFF0000);
            curSprite.graphics.drawCircle(0, 0, 4);
            addChild(curSprite);
            
            stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDOwn);
        
        }
        
        private function onKeyDOwn(e:KeyboardEvent):void 
        {
            var keyCode:uint = e.keyCode;
            if (keyCode === Keyboard.NUMPAD_DIVIDE) {
                onMouseMove(null);
            }
            else if (keyCode === Keyboard.NUMPAD_ADD) {
                    
                onMouseMove(null);
            }
            else if (keyCode === Keyboard.LEFT) {
                    startPosition.x--;
                      onMouseMove(null);
            }
            else if (keyCode === Keyboard.RIGHT) {
                startPosition.x++;
                  onMouseMove(null);
            }
            else if (keyCode === Keyboard.UP) {
                startPosition.y--;
                  onMouseMove(null);
            }
            else if (keyCode === Keyboard.DOWN) {
                startPosition.y++;
                  onMouseMove(null);
            }
        }
        
        private function onEnterFrame(e:Event):void 
        {
            var timeElapsed:Number =  (1 / 60);
                velocity.y += GRAVITY * timeElapsed;
                
                
            curPosition.x += velocity.x * timeElapsed;
            curPosition.y += velocity.y * timeElapsed;
        
            curSprite.x = curPosition.x;
            curSprite.y = curPosition.y;
            
            
        }
        
            /**
     * Basic dragless trajectory time of impact 1-liner calculation across flat ground. 
     * Simply calculates time of rise to apex added with time of fall to ground level.
     * @param    yo    Start y position
     * @param    vyo    Start velocity y
     * @param    g    Constant gravity
     * @return    Time of impact/flight till object hits the ground
     */
    //inline
    private  function getTrajectoryTimeOfFlight(yo:Number, vyo:Number,  g:Number ):Number {
   

            var tRise:Number = -vyo / g;
            _tRise = tRise;
            
           // 0 = yo + .5 * g * t * t + vyo * t
            var h:Number = yo + vyo*vyo/(2*g);

            _h = h;
            
            var tSink:Number = Math.sqrt(2*h/g) * (yo >= 0 ? 1 : -1); //+- quadratic 
        return tRise + tSink;
        
        //return vyo/g + Math.sqrt((2*yo  + vyo*2*t - 1*g*t*t)/g);
        
        //return vyo/g + Math.sqrt((2*yo  + vyo*2*t - 1*g*t*t)/g);
    }
    
    private function getTrajectoryTimeOfFlight2(yo:Number , vyo:Number, g:Number, isFinal:Boolean=false):Number {
        
         
        //y(t) = yo + (vyo)*t - (g/2)t2
        //x(t) = vxo*t,
        
        var t1:Number = -vyo/g;
        var t2:Number = Math.sqrt( vyo * vyo + g * 2 * yo) / g;
        _tRise = t1;
        _h =  yo + vyo*vyo/(2*g);
    //    return t1 + t2;
        //y = yo +  (vyo * t - g / 2 * t * t);
        //x = vxo * t;    
        
        var slope:Number      =  mSlope;// 0.0; // For line.
        var yIntercept:Number  = -startPosition.x * mSlope;
        
        //y = Ax2 + Bx + C
        var A:Number  = g / 2; // For parabolla, quadratic function coefficients.
        var B:Number  = vyo;
        var C:Number  = -yo;

        var a:Number = 0.0; // For solving quadratic formula.
        var b:Number  = 0.0;
        var c:Number  = 0.0;

        var x1:Number  = 0.0; // Point(s) of intersection.
        var y1:Number  = 0.0;
        var x2:Number  = 0.0;
        var y2:Number  = 0.0;

        a = A;
        b = B + slope*velocity.x;
        c = C - yIntercept;
        
        

        var discriminant:Number = b * b - 4 * a * c;

        if(discriminant > 0.0)
        {
            x1 = (-b + Math.sqrt(discriminant)) / (2.0 * a);
            x2 = (-b - Math.sqrt(discriminant)) / (2.0 * a);

            y1 = slope * x1 + yIntercept;
            y2 = slope * x2 + yIntercept;
            
            
            if (!isFinal) {
                //return getTrajectoryTimeOfFlight2(yo, x1 + x2, -2,true);
            }


            return  x1 > x2 ? x1 : x2;
        
        }
        else if(discriminant == 0.0)
        {
            x1 = (-b) / (2.0 * a);

            y1 = slope * x1 + yIntercept;
            return x1;
        }
        
        
        return -1;
        
    }
    
    
   
        
        private function onMouseMove(e:MouseEvent):void 
        {
        
            //  startPosition.x  = mouseX;
          //  startPosition.y = mouseY;
          
            _displace.x = mouseX - startPosition.x;
            _displace.y = mouseY - startPosition.y;
            _displace.normalize(SPEED);
            
            
            velocity.x = _displace.x;
            velocity.y = _displace.y;
            
            curPosition.x = startPosition.x;
            curPosition.y = startPosition.y;
            

          totalFlightTime =   getTrajectoryTimeOfFlight2(stage.stageHeight - startPosition.y, velocity.y, GRAVITY);
            

            drawPath();
        }
        
        
        private function drawPath():void 
        {    
            graphics.clear();
            graphics.beginFill(0x000000, 1);
            graphics.lineStyle(0, 0, 1);
        
            var totalTimeToUse:Number = totalFlightTime;// (totalTime > MAX_TIME) ? totalTime : totalTime / MAX_TIME * MAX_TIME;
                   
            for (var i:int = 0; i <= DRAW_SEGMENTS; i++) {  // draw in between segments
            
                var t:Number = (i / DRAW_SEGMENTS) * totalTimeToUse;
               
                var px:Number;
                var py:Number;
                graphics.drawCircle(
                px= startPosition.x + velocity.x * t,
                py = startPosition.y + .5 * GRAVITY * t * t + velocity.y * t
                ,4);
                
                 // get forward vector
                var vx:Number = velocity.x;
                var vy:Number = velocity.y + GRAVITY*t;
                var d:Number = 1 / Math.sqrt(vx * vx + vy * vy); // normalize  
                vx *= d;
                vy *= d;
                graphics.moveTo(px, py);
                graphics.lineTo(px + vx * 11, py + vy * 11);
            }
            

            
           // if (_tRise <0) _tRise = 0;
            graphics.moveTo(startPosition.x + _tRise*velocity.x, startPosition.y);
            graphics.lineTo(startPosition.x + _tRise*velocity.x, startPosition.y - 320)
            
             graphics.moveTo(startPosition.x + totalFlightTime*velocity.x, startPosition.y);
            graphics.lineTo(startPosition.x + totalFlightTime*velocity.x, startPosition.y - 320);
            
            graphics.beginFill(0xFFFF00,1);
              graphics.drawCircle(
                px= startPosition.x + _tRise*velocity.x,
               py = startPosition.y+ .5 * GRAVITY * _tRise * _tRise + velocity.y * _tRise
                ,4);
                
                graphics.moveTo(0,stage.stageHeight-1);
                graphics.lineTo(1, stage.stageHeight - 1 - slopeHeight);
                
                   graphics.moveTo(0,stage.stageHeight-1);
                graphics.lineTo(1, stage.stageHeight-1 );
            
        }
        

        
    }

}