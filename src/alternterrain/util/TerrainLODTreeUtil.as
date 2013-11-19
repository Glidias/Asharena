package alternterrain.util 
{
	import alternterrain.objects.HierarchicalTerrainLOD;
	import de.polygonal.ds.mem.BitMemory;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import util.LogTracer;
	
	import alternativa.engine3d.alternativa3d;
	use namespace alternativa3d;
	/**
	 * Utility to manage a hiercahical quadtree of TerrainLODs
	 * @author Glenn Ko
	 */
	public class TerrainLODTreeUtil 
	{
		public const BASE_PATCH:int = 4;  
		
		// up to 4 levels
        public const QUERY_SIZE:int = 1024;
		public var smallestSquareSize:Number =128;
        
        public var boundingSpace:Rectangle = new Rectangle(0, 0, 8192,8192 );
        private var boundingTiles:Rectangle = new Rectangle(boundingSpace.x/smallestSquareSize, boundingSpace.y/smallestSquareSize, boundingSpace.width / smallestSquareSize, boundingSpace.height / smallestSquareSize);
        private var offset6:Vector.<int>= new Vector.<int>(6*4, true);
        
        private var _lmx:int = -int.MAX_VALUE;
        private var _lmy:int = -int.MAX_VALUE;
		
		 static private const ORIGIN:Point = new Point();
        
        public var levelPxOffsets:Vector.<int> = new Vector.<int>();
		   public var loaderOffsets:Vector.<int> = new Vector.<int>();
		   public var loaderAmount:int;
		   
		  private var gridLookup:BitmapData;
		  public var boundWidth:int;
		  public var boundHeight:int;
		   private var rectFiller:Rectangle = new Rectangle();
		   public var drawBits:BitMemory;
		   
		   public var previewShape:Shape = new Shape();
		   
		   public var levelNumSquares:Vector.<int>;
		   public var indices:Vector.<int>;
		   public var totalIndices:int;
		 
		
        
        //private var stateLookup:BitmapData;
      //  private var lastStatelookup:BitmapData;
	  
		
		public function TerrainLODTreeUtil() 
		{
			gridLookup = new BitmapData(boundingTiles.width, boundingTiles.height, false, 0);
			previewShape.scaleX = previewShape.scaleY = 32 / smallestSquareSize;
			
			

			 ///*
            offset6[0] = 0;  offset6[1] = 1;  // nw  (0)
            offset6[2] = 1;  offset6[3] = 1;
            offset6[4] = 1;  offset6[5] = 0;
            
            offset6[6] = -1;  offset6[7] = 0;  // ne  (0)
            offset6[8] = -1;  offset6[9] = 1;
            offset6[10] = 0;  offset6[11] = 1;
            
            offset6[12] =0;  offset6[13] = -1;  //   sw (|=2,)  10
            offset6[14] = 1;  offset6[15] = -1;
            offset6[16] = 1;  offset6[17] = 0;
            
            offset6[18] = -1;  offset6[19] = 0;   // se (|=2,|=1) 11
            offset6[20] = -1;  offset6[21] = -1;
            offset6[22] = 0;  offset6[23] = -1;
            //*/
			
			 var qSize:uint = smallestSquareSize;
            levelPxOffsets.push(0);
			 loaderOffsets.push(0);
            var count:int = 0;
            var count2:int = 0;
            var level:int  = 0;
          
            boundWidth = Math.floor(boundingSpace.width) / smallestSquareSize;
            boundHeight =  Math.floor(boundingSpace.height) / smallestSquareSize;
			
	
            while (qSize < QUERY_SIZE ) {
                
                qSize *= 2;
                count += (boundWidth >> level);
                
                 count2 += (boundWidth >> level) * (boundHeight >> level);
                levelPxOffsets.push(count );
				 loaderOffsets.push(count2);
               
                level++;
            }
			
			levelNumSquares = new Vector.<int>( levelPxOffsets.length, true);
			indices = new Vector.<int>();
			levelPxOffsets.fixed = true;
			loaderOffsets.fixed = true;

			 loaderAmount = count2 + boundWidth * boundHeight;
			 drawBits = new BitMemory(loaderAmount);
		}
		
		public function get graphics():Graphics {
			return previewShape.graphics;
		}
		
		
		public var offsetX:Number = 0;
		public var offsetY:Number = 0;
		
		
		public function update(mx:int, my:int, forceUpdate:Boolean=false):Boolean {
		    
          //  if (mx < 0) mx = 0;
            //if (my < 0) my = 0;
            var mix:int = Math.round(mx/smallestSquareSize);
            var miy:int = Math.round(my / smallestSquareSize);
         //   if (mix >= boundWidth) mix = boundWidth - 1;    // clamp round up cases
         //   if (miy >= boundHeight) miy = boundHeight - 1;
            
            if (!forceUpdate && _lmx === mix && _lmy === miy) {
                return false;
            }
			
            
            _lmx = mix;
            _lmy = miy;
            
            
            graphics.clear(); 
            gridLookup.fillRect(gridLookup.rect, 0xFF0000);
           // lastStatelookup.copyPixels(stateLookup, stateLookup.rect, ORIGIN);
          //  previewChangeState.fillRect(previewChangeState.rect, 0);
          //  stateLookup.fillRect(stateLookup.rect, 0);
		  drawBits.clrAll();
            
            var rect:Rectangle;
            
            
            rect = new Rectangle(mix * smallestSquareSize - smallestSquareSize * 4 * BASE_PATCH, miy * smallestSquareSize - smallestSquareSize * 4 * BASE_PATCH, smallestSquareSize * 8 * BASE_PATCH, smallestSquareSize * 8 * BASE_PATCH);

         
			// preview query box
			graphics.lineStyle(0, 0xFF0000, 1); 

           graphics.drawRect(rect.x, rect.y, rect.width, rect.height);
			//if (rect.x + rect.width > boundingSpace.width) throw new Error("EXCEEDED!");
		   
           graphics.lineStyle(0, 0, 1);
            
            var qSize:int;
            
            qSize = smallestSquareSize;
			
         

            rect.width = smallestSquareSize*4;
            rect.height = smallestSquareSize * 4;
            rect.x = mix * smallestSquareSize - smallestSquareSize * 2
            rect.y = miy * smallestSquareSize - smallestSquareSize * 2
			
			
            var level:int = 0;
			totalIndices = 0;
			levelNumSquares[0] = 0;
           drawOntoGrid(rect, qSize, level);
        
            while (qSize < QUERY_SIZE ) {
				
                rect.x -= rect.width * .5; rect.y -= rect.height * .5; rect.width *= 2, rect.height *= 2;
				level++;
				qSize *= 2;
				levelNumSquares[level] = 0;
		
                 drawOntoGrid(rect, qSize, level);
            }
			
			return true;
		}
		
		private function drawOntoGrid(sampleRegion:Rectangle, gridSize:int, level:int):void {
    
          
            var xLimit:int = Math.ceil( (sampleRegion.x+sampleRegion.width)  / gridSize );
            var yLimit:int = Math.ceil( (sampleRegion.y + sampleRegion.height)  / gridSize );
            var parentGridSize:int = gridSize * 2;
            if (xLimit > boundingTiles.x + boundingTiles.width) xLimit = boundingTiles.x + boundingTiles.width ;
            if (yLimit > boundingTiles.y + boundingTiles.height) yLimit = boundingTiles.y + boundingTiles.height ;
            var yStart:int = Math.floor(sampleRegion.y / gridSize);
            var xStart:int =  Math.floor(sampleRegion.x / gridSize);
            if (xStart < boundingTiles.x) xStart = boundingTiles.x;
            if (yStart < boundingTiles.y) yStart = boundingTiles.y;
            
            rectFiller.width = gridSize / smallestSquareSize;
            rectFiller.height = gridSize / smallestSquareSize;
            
                var levelPxOffset:int = levelPxOffsets[level];
                  var loaderOffsets:int = loaderOffsets[level];
				    var cols:int = (boundWidth >> level);
        
            var randColor:uint = 0xFF + (level + 1);// * (65535/8);
            var rx:int;
			var ry:int;
            var gotParent:Boolean = parentGridSize <= QUERY_SIZE;
          
            for (var yi:int =  yStart; yi < yLimit; yi++) {
                    for (var xi:int = xStart; xi < xLimit; xi ++) {
                        var xis:int;
                         var yis:int;
                        rectFiller.x = xis =( xi - boundingTiles.x) * rectFiller.width;
                        rectFiller.y = yis = (yi - boundingTiles.y) * rectFiller.height;
                    
    
                        if ( (gridLookup.getPixel(xis, yis) & 0xFFFF00) != 0xFF0000) {
                            // this is already filled up by something
                            //BitmapData().compare()
                            continue;
                        }
                
                        if (gridSize == smallestSquareSize ) graphics.lineStyle(2, 0xFF)
                        else graphics.lineStyle(0, 0, 1);
                        graphics.beginFill(0xFF0000, .2);
                        graphics.drawRect(xi * gridSize, yi * gridSize, gridSize, gridSize);
                         gridLookup.fillRect(rectFiller, randColor);
						 
						 levelNumSquares[level]++;
						 indices[totalIndices++] = rx = xi;
						indices[totalIndices++] = ry = yi;
                        //    stateLookup.setPixel(xi+levelPxOffset, yi, 0xFF0000);
						drawBits.set(loaderOffsets + ry * cols + rx);
                        
                        if (gotParent) {
                            if (gridSize == smallestSquareSize) graphics.lineStyle(1, 0xFF0000, 1)
                            else graphics.lineStyle(0, 0, 1)
                            
                            var result:int = 0;
                            // based on current region, which quadrant and I'm in?? draw rect on 3 other quadrants.
                            var xii:int = xi*gridSize;
                            var yii:int = yi*gridSize;
                        
                            
                            
                            result|= ((xi*gridSize) % parentGridSize)  != 0 ? 1 : 0;
                            result |= ((yi * gridSize) % parentGridSize) != 0 ? 2 : 0;
                    

                          
                                
                                result *= 6;
                                
                                rectFiller.x = (xis) + offset6[result]*rectFiller.width;
                                rectFiller.y = (yis) + offset6[result + 1] * rectFiller.height;
                                if (gridLookup.getPixel(rectFiller.x, rectFiller.y) === 0xFF0000) {
                                    gridLookup.fillRect(rectFiller, randColor);
                                    graphics.beginFill(0xFF0000, .2);
                                    graphics.drawRect(xii + offset6[result] * gridSize,   yii + (offset6[result + 1]) * gridSize, gridSize, gridSize);
									levelNumSquares[level]++;
									indices[totalIndices++] =rx= xi + offset6[result];
									indices[totalIndices++] = ry=yi + offset6[result + 1];
									drawBits.set(loaderOffsets + ry * cols + rx);
                        //            stateLookup.setPixel(xi+ levelPxOffset+offset6[result], yi+ offset6[result+1], 0xFF0000);
                                }
                
                                rectFiller.x = (xis) + offset6[result+2]*rectFiller.width;
                                rectFiller.y = (yis) + offset6[result+3]*rectFiller.height;
                                if (gridLookup.getPixel(rectFiller.x, rectFiller.y) === 0xFF0000) {
                                    gridLookup.fillRect(rectFiller, randColor);
                                    graphics.beginFill(0xFF0000, .2);
                                    graphics.drawRect(xii + offset6[result + 2] * gridSize, yii + (offset6[result + 3]) * gridSize, gridSize, gridSize);
									levelNumSquares[level]++;
									indices[totalIndices++] =rx= xi + offset6[result + 2];
									indices[totalIndices++] = ry = yi + offset6[result + 3];
									drawBits.set(loaderOffsets + ry * cols + rx);
									
                           //         stateLookup.setPixel(xi+ levelPxOffset+offset6[result+2], yi+ offset6[result+3], 0xFF0000);
                                }
                                
                                rectFiller.x = (xis) + offset6[result+4]*rectFiller.width;
                                rectFiller.y = (yis) + offset6[result + 5] * rectFiller.height;
                                if (gridLookup.getPixel(rectFiller.x, rectFiller.y) === 0xFF0000) {
                                    gridLookup.fillRect(rectFiller, randColor);
                                    graphics.beginFill(0xFF0000, .2);  graphics.drawRect(xii + offset6[result + 4] * gridSize,  yii + offset6[result + 5] * gridSize, gridSize, gridSize);
									levelNumSquares[level]++;
									indices[totalIndices++] =rx= xi + offset6[result+4];
									indices[totalIndices++] = ry = yi + offset6[result + 5];
									drawBits.set(loaderOffsets + ry * cols + rx);
                            //      stateLookup.setPixel(xi+ levelPxOffset+offset6[result+4], yi+ offset6[result+5], 0xFF0000);
                                    
                                }
                                
                           
                            
                        
                        
                        }
                }
            }
            
            
			
		}
		
	}

}