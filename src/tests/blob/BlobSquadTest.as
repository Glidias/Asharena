package tests.blob
{
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.geom.Point;
    import flash.geom.Vector3D;
    import flash.ui.Keyboard;

    /**
     * ...
     * @author Glidias
     */
    public class BlobSquadTest extends Sprite
    {
        private var characters:Array = [];
        private var blob:Sprite = new Sprite();
        private var blobOffsetX:Number = 0;
        private var blobOffsetY:Number = 0;
   
        private var forward:Boolean = false;
        private var backward:Boolean = false;
		 private var left:Boolean = false;
        private var right:Boolean = false;
		private var accelerate:Boolean = false;
		
        private var blobAngle:Number = 0;
        private var blobFormationAngle:Number = 0;
        private var blobForwardVector:Vector3D = new Vector3D(1, 0);
		
        
        private var blobFormationPreview:Sprite = new Sprite();
        private var _mouseDown:Boolean;
        private var _mouseDownPos:Point = new Point();
        private var _mouseDownRot:Number;
		
		
        

        public static const ROT_FAST:Number = .05;
        public static const ROT_SLOW:Number = .025;
        public static var ROT_SPEED:Number = ROT_FAST;
		
		public static const STRAFE_SPEED:Number = .65;
        private var blobSpeeds:Vector3D = new Vector3D(1.2, .4, STRAFE_SPEED,1.2);
        
        public function setBlobAngle(val:Number):void {
            blobAngle = val;
            blob.rotation = val * 180 / Math.PI;
            blobForwardVector.x = Math.cos(val);
            blobForwardVector.y = Math.sin(val);
        
        }
        
        
        public function BlobSquadTest() 
        {
            addEventListener(Event.ENTER_FRAME, onENterFrame);
            
            stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
            stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
            stage.addEventListener(MouseEvent.MOUSE_DOWN, onStageMouseDown);
            stage.addEventListener(MouseEvent.MOUSE_UP, onStageMouseUp);
           
			// Wedge
			/*
			addChar( 0, 0);
            addChar( -20, -20);
            addChar( -20, 20);
			  addChar( -40, 40);
			  addChar( -40, -40);
			  */
            
            // Block
			// /*
           addChar( -20, -20);
            addChar(20, -20);
          addChar(-20, 20);
           addChar( 20, 20);
		   addChar( 40, 20);
		   addChar( 60, 20);
		   addChar( 80, 20);
		   addChar( 100, 20);
			//*/
            
            
            setupBlob();
            
            if (ROT_SPEED == ROT_SLOW) blobSpeeds.x =  blobSpeeds.w * .25;
            
            //scaleX = 2;
            //scaleY = 2;
        }
        
        private function onStageMouseUp(e:MouseEvent):void 
        {
            _mouseDown = false;
            stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
        }
        
        private function onMouseMove(e:MouseEvent):void 
        {
            var xOffset:Number = stage.mouseX - _mouseDownPos.x;
            var rotOffset:Number = xOffset * .01 ;
        
            //var clampMag:Number = (ROT_SPEED != ROT_SLOW ? Math.PI : Math.PI * .5);
            //if ( Math.abs(rotOffset) > clampMag ) rotOffset *= clampMag/rotOffset;
            setBlobAngle( _mouseDownRot  +rotOffset );
        }
        
        private function onStageMouseDown(e:MouseEvent):void 
        {
            _mouseDown = true;
            _mouseDownPos.x = stage.mouseX;
            _mouseDownPos.y = stage.mouseY;
            _mouseDownRot =blobAngle;
            stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
        }
        
        private function onKeyUp(e:KeyboardEvent):void 
        {
            var kc:uint = e.keyCode;
            if (kc === Keyboard.W) {
                forward = false;
            }
            else if (kc === Keyboard.S) {
                backward = false;
            }
			else if (kc === Keyboard.A) {
                left = false;
            }
            else if (kc === Keyboard.D) {
               right = false;
            }
			else if (kc === Keyboard.SHIFT) {
               accelerate = false;
            }
        }
        
        private function onKeyDown(e:KeyboardEvent):void 
        {
            var kc:uint = e.keyCode;
            if (kc === Keyboard.W) {
                forward = true;
            }
            else if (kc === Keyboard.S) {
                backward = true;
            }
			 else if (kc === Keyboard.A) {
                left = true;
            }
			 else if (kc === Keyboard.D) {
                right = true;
            }
			else if (kc === Keyboard.SHIFT) {
				 accelerate = true;
			}
            else if (kc === Keyboard.CONTROL) {
                ROT_SPEED = ROT_SPEED != ROT_SLOW ? ROT_SLOW : ROT_FAST;
                if (ROT_SPEED == ROT_SLOW) blobSpeeds.x =  blobSpeeds.w * .25;
                else blobSpeeds.x = blobSpeeds.w;
            }
            else if (kc === Keyboard.TAB) {
                blob.visible = !blob.visible;
               blobFormationPreview.visible = blob.visible;
            }
        }
        
        private function setupBlob():void 
        {
            var rad:Number = 0;
            var len:int = characters.length;
            var minX:Number = Number.MAX_VALUE;
            var minY:Number = Number.MAX_VALUE;
            var maxX:Number = -Number.MAX_VALUE;
            var maxY:Number = -Number.MAX_VALUE;
            
            for (var i:int = 0; i < len; i++) {
                var c:Character = characters[i];
                var val:Number;
                val = c.offsetX- c.radius;
                if (val < minX) minX = val;
                val = c.offsetY- c.radius;
                if (val < minY) minY = val;
                val = c.offsetX + c.radius;
                if (val > maxX) maxX = val;
                val = c.offsetY + c.radius;
                if (val > maxY) maxY = val;
            }
            var xD:Number = maxX - minX;
            var yD:Number = maxY - minY;
            blobOffsetX  = minX+xD * .5;
            blobOffsetY = minY+yD * .5;
            blob.graphics.lineStyle(0, 0xFF0000);
            var radius:Number=   Math.sqrt(xD * xD + yD * yD) * .5;
            blob.graphics.drawCircle(0, 0,radius) ;
            blob.graphics.moveTo(radius, 0);
            blob.graphics.lineTo(radius+8, 0);
            //blob.graphics.drawRect(minX-blobOffsetX, minY-blobOffsetY, xD, yD);
            addChild(blob);
            addChild(blobFormationPreview);
            blobFormationPreview.graphics.lineStyle(0, 0x00FF00);
            blobFormationPreview.graphics.moveTo(radius, 0);
            blobFormationPreview.graphics.lineTo(radius + 13, 0);
        
            blob.visible = false;
               blobFormationPreview.visible = false;
            
        setupBlobPosition(40, 40);
        }
        
        private function addChar(x:Number, y:Number):void 
        {
            var char:Character;
            addChild(char = new Character());
            char.offsetX = x;
            char.offsetY = y;
                char.lastOffsetX = x;
            char.lastOffsetY = y;
            characters.push(char);
            
            
            
        }
        
        
        
        public function setupBlobPosition(x:Number, y:Number ):void {
            blob.x = x;
            blob.y = y;
            var len:int = characters.length;
            for (var i:int = 0; i < len; i++) {
                var c:Character = characters[i];
                var val:Number;
                c.x = c.offsetX + x - blobOffsetX;
                c.y = c.offsetY + y - blobOffsetY;
                c.offsetX = c.offsetX - blobOffsetX;
                c.offsetY = c.offsetY - blobOffsetY;
                c.lastOffsetX = c.offsetX;
                c.lastOffsetY = c.offsetY;
            }
            
            blobFormationPreview.x = blob.x;
            blobFormationPreview.y = blob.y;
        }
        
        private function onENterFrame(e:Event):void 
        {
            var c:Character;
            var i:int
            var len:int = characters.length;
            
            var blobVx:Number = 0;
            var blobVy:Number = 0;
			
            //blob.rotation += .5;
            if (forward || backward) {
                blobVx += forward ?  blobForwardVector.x * blobSpeeds.x : 0;
                blobVy += forward ?  blobForwardVector.y * blobSpeeds.x: 0;
                
                blobVx -= backward ?  blobForwardVector.x * blobSpeeds.y: 0;
                blobVy -= backward ?  blobForwardVector.y * blobSpeeds.y: 0;
            
            }
			var nostrafe:Boolean = true;
			if (left || right) {
				
				if ( !(left && right) ) {
					nostrafe = false;
					blobVx -= Math.sin(blobAngle) * (accelerate ? blobSpeeds.x : blobSpeeds.z) * (left ? -1 : 1); 
					blobVy -= -Math.cos(blobAngle) * (accelerate ? blobSpeeds.x : blobSpeeds.z) * (left ? -1 : 1);
				}
			}
			
            if (blobVx != 0 || blobVy != 0) {
                moveBlob(blobVx, blobVy);
            }
            

            
            
            var minBlobAngleOffset:Number = .005;
            var blobAngleOffset:Number = (blobAngle - blobFormationAngle);
            if (Math.abs(blobAngleOffset) < minBlobAngleOffset) {
                blobFormationAngle = blobAngle;
                blobAngleOffset = 0;
            }
            
            blobAngleOffset *= ROT_SPEED;
            //blobAngleOffset = blobAngleOffset < 0 ? blobAngleOffset > 0 ? -.1 : .1 : 0;
            
            var clampMag:Number = (ROT_SPEED != ROT_SLOW && !backward ? Math.PI*.35 : Math.PI * .05);
            if ( Math.abs(blobAngleOffset) > clampMag ) blobAngleOffset = clampMag/blobAngleOffset;
            blobFormationAngle += blobAngleOffset;

            
            
            blobFormationPreview.rotation = blobFormationAngle * 180 / Math.PI;
            
            
            for (i = 0; i < len; i++) {
                c = characters[i];
                
                c.velocity.x = blobVx;
                c.velocity.y = blobVy;
                
                //c.rotation +=  ( (blobAngle * 180 / Math.PI) - c.rotation) * .15;
                //c.rotation = (blobAngle * 180 / Math.PI);
            }
            
            if (blobAngleOffset != 0) {
                blobVx = Math.cos(blobFormationAngle);
                blobVy = Math.sin(blobFormationAngle);
                var blobVx2:Number = blobVy;
                var blobVy2:Number = -blobVx;
                for (i = 0; i < len; i++) {
                    c = characters[i];
                    c.offsetX * blobVx;
                    c.offsetY * blobVy;
                    
                    
                    var lastX:Number=   (c.offsetX)*blobVx + (c.offsetY)*blobVy ;
                    var lastY:Number =   (c.offsetX) * blobVx2 + (c.offsetY) * blobVy2  ;
                    
                    ///*
                    c.velocity.x += lastX - c.lastOffsetX;
                    c.velocity.y += lastY - c.lastOffsetY;
                    c.lastOffsetX = lastX;
                    c.lastOffsetY = lastY;
                    //*/
                    
                    c.x = lastX + blob.x
                    c.y = lastY + blob.y;
                    
                    //blobForwardVector.x = Math.cos(val);
                    //blobForwardVector.y = Math.sin(val);
                    
                    
                    //c.velocity.x += blobVx;
                    //c.velocity.y += blobVy;
                }
                //moveBlob(blobVx*4, blobVy*4);
            }
            

            var threshold:Number = .03;
			
            var strafeAngle:Number = blobFormationAngle * 180 / Math.PI;
			/*
			var antiStrafeRatio:Number =  Math.abs(blobAngleOffset) / threshold;
			antiStrafeRatio = antiStrafeRatio > 1 ? 1 : antiStrafeRatio;
			*/
			var noStrafe:Boolean = Math.abs(blobAngleOffset) > threshold;
			var blobFormAngle:Number = (blobFormationAngle  % (Math.PI * 2));
		
			var rotMaxSpeed:Number = Math.PI;
            // movement
			
			var rotEasing:Function = nostrafe ?  rotEasingEquation :  rotEasingEquation2;
            for (i = 0; i < len; i++) {
                c = characters[i];
                c.x+=c.velocity.x;
                c.y += c.velocity.y;
				var velAngle:Number = Math.atan2(c.velocity.y, c.velocity.x);
				velAngle%=  Math.PI;
				var angle:Number;
				//angle = c.velocity.lengthSquared > 1 * 1 ?  velAngle : blobFormationAngle;
				var ratioVelAngle:Number = (c.velocity.length-.65) / .25;
				
				
				// try this instead ? But no idnividual rotation schemes..
				//blobAngleOffset %= Math.PI;
				//ratioVelAngle =  (Math.abs( blobAngleOffset  ) - .1) / .05;
				
				
				
				if (ratioVelAngle > 1) {
					ratioVelAngle =1;
				}
				if (ratioVelAngle < 0) {
					ratioVelAngle = 0;
				}
				
				// snap regardless
				//if (ratioVelAngle < 1) {
				//	ratioVelAngle = 0;
				//}
				

				
				var angleDiff:Number;
				// find the rotation of the vector created by the sin and cos of the difference
				angleDiff = (velAngle - blobFormAngle);
				angleDiff = Math.atan2(Math.sin(angleDiff), Math.cos(angleDiff));
				

				
				ratioVelAngle =rotEasing(ratioVelAngle);
				
				angle = blobFormAngle + angleDiff * ratioVelAngle;
			
				
				
                c.rotation =    (angle * 180 / Math.PI);// blobFormationAngle * 180 / Math.PI;
				
            }
            
            
            
            
        }
		
		// refer to gaia.lib.tween.easing  (Gaia-tween) library
		private function rotEasingEquation(p:Number):Number {
			
			return -p * (p - 2);
		}
		
				private function rotEasingEquation2(p:Number):Number {
			return p * p;
			
		}
        
        private function moveBlob(x:Number, y:Number):void 
        {
            blob.x += x;
            blob.y += y;
            blobFormationPreview.x = blob.x;
            blobFormationPreview.y = blob.y;
        }
        
    }

}
import flash.display.Sprite;
import flash.geom.Vector3D;

class Character extends Sprite {
    
    public var offsetX:Number;
    public var offsetY:Number;
    public var radius:Number = 8;
    public var velocity:Vector3D = new Vector3D();
	//public var lastFacingAngle:Number = 0;
    public var lastOffsetX:Number;
    public var lastOffsetY:Number;
    
    public function get rotationRadians():Number {
        
        return rotation * (Math.PI / 180);
    }
        public function set rotationRadians(val:Number):void {
        rotation= val * (180/Math.PI);
    }
    
    public function Character() {
        super();
        graphics.lineStyle(0, 0);
        graphics.drawCircle(0, 0, radius );
        graphics.moveTo(radius, 0);
        graphics.lineTo(radius + 3, 0);
        rotation
        
    }
    
}

