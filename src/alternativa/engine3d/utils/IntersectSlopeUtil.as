package alternativa.engine3d.utils 
{
	import flash.geom.Vector3D;
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class IntersectSlopeUtil 
	{
		 
        public var startPt:Vector3D = new Vector3D(30,60);
        public var endPt:Vector3D = new Vector3D();
        
        public var pt1:Vector3D = new Vector3D(100, 60, 60);
        public var pt2:Vector3D = new Vector3D(90, 60, 80);
        public var pt3:Vector3D = new Vector3D(70,180, 100);
        private var r:Number;
        private var s:Number;
        
        public var intersectTimes:Vector.<Number> = new Vector.<Number>(2, true);
        public var intersectZ:Vector.<Number> = new Vector.<Number>(2, true);
		private var gradient:Number;
		
		public static const RESULT_NONE:int = 0;
		public static const RESULT_SLOPE:int = 1;
		public static const RESULT_WALL:int = -1;
		public static const RESULT_COLLINEAR:int = -2;
		
        public function sqDistBetween2DVector(a:Vector3D, b:Vector3D):Number {
            var dx:Number = b.x - a.x;
            var dy:Number = b.y - a.y;
            return dx * dx + dy * dy;
        }
        
        public function rBetween2DVec(a:Vector3D, b:Vector3D, c:Vector3D):Number {
            var dx:Number = b.x - a.x;
            var dy:Number = b.y - a.y;
            var dx2:Number = c.x - a.x;
            var dy2:Number = c.y - a.y;
            return dx * dx2 + dy * dy2;
        }
		
		public function setupRay(origin:Vector3D, direction:Vector3D):void {
			startPt.x = origin.x;
			startPt.y = origin.y;
			startPt.z = origin.z;
			
			endPt.x = startPt.x + direction.x;
			endPt.y = startPt.y + direction.y;
			endPt.z = startPt.z + direction.z;
		}
		
		public function setupTri(ax:Number, ay:Number, az:Number, bx:Number, by:Number, bz:Number, cx:Number, cy:Number, cz:Number):void {
			pt1.x = ax;
			pt1.y = ay;
			pt1.z = az;
			
			pt2.x = bx;
			pt2.y = by;
			pt2.z = bz;
			
			pt3.x = cx;
			pt3.y = cy;
			pt3.z = cz;
		}
		
		
		
		public function getTriIntersections():int {
			var gotIntersect:Boolean;
         
        
            var count:int = 0;
			
            gotIntersect = IsIntersecting(startPt, endPt, pt1, pt2);
            if (gotIntersect) {
              
                intersectTimes[count] = r;
                intersectZ[count] = pt2.z * s - pt1.z * s  + pt1.z;
                count++;
                
            }
            gotIntersect = IsIntersecting(startPt, endPt, pt2, pt3);
            if (gotIntersect) {
              
                intersectTimes[count] = r;
                intersectZ[count] = pt3.z * s - pt2.z * s  + pt2.z;
                count++;
            }
            
            gotIntersect = IsIntersecting(startPt, endPt, pt3, pt1);
            if (gotIntersect) {
                if (count <2) {
                   
                    intersectTimes[count] = r;
                    intersectZ[count] = pt1.z * s - pt3.z * s  + pt3.z;
                    count++;
                }
            }
            
           
            
            var dx:Number = endPt.x - startPt.x;
            var dy:Number  = endPt.y - startPt.y;
            
            var temp:Number = intersectTimes[0];
            var temp2:Number = intersectZ[0];
            
            if (intersectTimes[1] < temp ) {
                intersectTimes[0] = intersectTimes[1];
                intersectZ[0] = intersectZ[1];
                
                intersectTimes[1] = temp;
                intersectZ[1]=temp2;
            }
            
            
            if (count!=0) {
               
                
                var rd:Number = (intersectTimes[1] - intersectTimes[0]);
                dx *= rd;
                dy *= rd;
                rd  = Math.sqrt( dx * dx + dy * dy ); 
                if (count > 1) {
                    if (rd> 0) {
                      gradient = (intersectZ[1] - intersectZ[0]) / rd;
                    //  debugField.text = "penetrate dist:" + rd + ", gradient:"+gradient + ", "+intersectTimes;
						return RESULT_SLOPE;
                    }
                    else {
                       //  debugField.text = "Hit a fully vertical wall!:"+intersectTimes[0];
					   return RESULT_WALL;
                    }
                }
                else {
					// TODO: collinear gradient
					
                    //debugField.text = "Collinear case";
					return RESULT_COLLINEAR;
                }

            
            }
            else {
              // debugField.text = "No penetrate";
			  return RESULT_NONE;
            }
		}


        
        public function IsIntersecting(a:Vector3D, b:Vector3D, c:Vector3D, d:Vector3D):Boolean
        {
            var denominator:Number = ((b.x - a.x) * (d.y - c.y)) - ((b.y - a.y) * (d.x - c.x));
            var numerator1:Number = ((a.y - c.y) * (d.x - c.x)) - ((a.x - c.x) * (d.y - c.y));
            var numerator2:Number = ((a.y - c.y) * (b.x - a.x)) - ((a.x - c.x) * (b.y - a.y));

            // Detect coincident lines (has a problem, read below)
            if (denominator == 0) {
                // find between c and d, which is closer to a, clamp to s to 1 and 0, set r to c/d
               s = sqDistBetween2DVector(a, c) < sqDistBetween2DVector(a, d) ? 0 : 1;
               r = s != 0 ? rBetween2DVec(a, b, d)  : rBetween2DVec(a, b, c);
              // throw new Error("DETECT");
                return true;// (r >= 0) && (s >= 0 && s <= 1);
               //  return numerator1 == 0 && numerator2 == 0;
            }


            r = numerator1 / denominator;
            s = numerator2 / denominator;
            // && r <= 1
            return (r >= 0) && (s >= 0 && s <= 1);
        }
		
	}

}