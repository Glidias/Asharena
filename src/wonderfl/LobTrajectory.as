/**
 * Copyright Glidias ( http://wonderfl.net/user/Glidias )
 * MIT License ( http://www.opensource.org/licenses/mit-license.php )
 * Downloaded from: http://wonderfl.net/c/siV5
 */

package wonderfl
{
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Point;
    import flash.geom.Vector3D;
    
    /**
     * Typical lob trajectory parabola paths in 2D. This should be converted to a 3D AGAL Vertex shader to batch draw tons of arrows or trajectory paths!
     * See drawPath() for guidelines.
     * @author Glenn Ko
     */
    [SWF(frameRate="60", backgroundColor="#FFFFFF")]
    public class LobTrajectory extends Sprite 
    {
        static public const MAX_TIME:Number = 10;

 
        private var SPEED:Number = 144;
        private var DRAW_SEGMENTS:int  = 16;
        private var startPosition:Point = new Point();
        private var endPosition:Point = new Point();
        private var GRAVITY:Number = 266;
        private var totalTime:Number;
        
        private var velocity:Point = new Point();
        private var _displace:Point = new Point();
        
        private var curPosition:Point = new Point();
        private var curSprite:Sprite = new Sprite();
        
        public function LobTrajectory() 
        {
            startPosition.x = 40;
            startPosition.y = stage.stageHeight -40;
            
            curPosition = startPosition.clone();
            
            endPosition.x  = 300;
            endPosition.y = 333;
            
            
            drawPath();
            
            stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
            addEventListener(Event.ENTER_FRAME, onEnterFrame);
            
            curSprite.graphics.beginFill(0xFF0000);
            curSprite.graphics.drawCircle(0, 0, 4);
            addChild(curSprite);
        
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
        
        
        
        private function onMouseMove(e:MouseEvent):void 
        {
        
            curPosition.x = startPosition.x;
            curPosition.y = startPosition.y;
            
            endPosition.x  = mouseX;
            endPosition.y = mouseY;
            
            //drawPath();
            calcVelocity();
            
            drawPath();
        }
        
        
        private function drawPath():void 
        {    // TODO: Convert to AGAL 3d vertex shader to batch draw tons of arrows/trajectory paths, etc.
            
            // Constants: (besides obj->camera transform..)
            // 1) Gravity.w,  z = maximum arrow travel time for ~120 per draw call case.
            
            // 2 CONSTANT REGISTERS per arrow! 
            // Constants per arrow/trajectory path: (~60 per draw call)  ->  Arrow travel path time > MAX_TIME
            // 1) velocity x,y,z ,  w  = totalTimeOfPath or currentTimeOfArrowPath
            // 2) start Position x,y,z of arrow
            
            // -or - 
            // Sequeeze everything into 1 CONSTANT REGISTER pre arrow. With this single constant, the arrow position and
            // orientation can be determined:
            // Constants per arrow/trajectory path:   (~120 per draw call) ->  Arrow travel path time <= MAX_TIME
            // arrow velocity x,y,z and w(whole portion) offset and w(fractional portion) time
            // 1) velocity x,y,z ,  w  = totalTimeOfPath or currentTimeOfArrowPath (approximate fractional portion over maximum arrow travel time MAX_TIME)
            //  &   offset (rounded approx to whole number) (whole number portion, dotProduct  of arrow velocity over it's start position. By scaling dotProduct over velocity, you get the start position)
            
            graphics.clear();
            graphics.beginFill(0x000000, 1);
            graphics.lineStyle(0, 0, 1);
        
            var totalTimeToUse:Number =  (totalTime > MAX_TIME) ? totalTime : totalTime / MAX_TIME * MAX_TIME;
                   
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
        }
        
        // Launch arrow
        private function calcVelocity():void 
        {
          
            var displace:Point = endPosition.subtract(startPosition);
            _displace.x = displace.x;
            _displace.y = displace.y;
			var optimalAngle:Number = -Math.atan2(2 *-displace.y, displace.x);
			
			//optimalAngle -= Math.PI * 0.5 * 16/90;
			if (optimalAngle <= -Math.PI * 0.5) {
				optimalAngle = -Math.PI * 0.5; // + 0.0001;
			}
			
			var dis:Number = 2 * -displace.y + 0.5 * (displace.x * displace.x) / -displace.y;
			
			// float speed = (distance * Mathf.Sqrt(gravity) * Mathf.Sqrt(1 / Mathf.Cos(angle))) / Mathf.Sqrt(2 * distance * Mathf.Sin(angle) + 2 * yOffset * Mathf.Cos(angle));
		  var speed:Number = (displace.x * Math.sqrt(GRAVITY) * Math.sqrt(1 / Math.cos(optimalAngle))) / Math.sqrt(2 * displace.x * Math.sin(optimalAngle) + 2 * -displace.y * Math.cos(optimalAngle));
		  //speed = Math.sqrt(GRAVITY) * Math.sqrt(dis);
		  
		  var cAngle:Number = Math.cos(optimalAngle);
		  cAngle *= cAngle;
		  var tAngle:Number = Math.tan(optimalAngle);
          speed = Math.sqrt((displace.x * displace.x * GRAVITY) / (2 * displace.y * cAngle  - 2*displace.x*cAngle*tAngle));
		trace(speed);
            var floatIntervals:Number = displace.length / SPEED;
            totalTime = floatIntervals;

            
            velocity.x = speed * Math.cos(optimalAngle);
            velocity.y = speed * Math.sin(optimalAngle);
        }
        
    }

}