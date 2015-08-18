package arena.pathfinding;

import de.polygonal.ds.BitVector;


class GKMarchingSquares{
  public var src:BitVector;
  public var across:Int;

  public var x(default, null):Int;
  public var y(default, null):Int;
  public var dir(default, null):Int;

  public var con8(default, set_con8):Bool;

  public var startX(default, null):Int;
  public var startY(default, null):Int;
  public var startDir(default, null):Int;

 
  var intCon8:Int;

  public function new(src=null, across:Int=32){
    this.src = src;
	
	this.across = across;
	
    con8 = true;
    }

  var nw:Bool;
  var ne:Bool;
  var sw:Bool;
  var se:Bool;
  
  

  public function startTracking(startx:Int, starty:Int):Bool {
   
    var cnd =  searchCandidate(src, startx, starty, across);  //new Point(startx, starty);//
    x = cnd.x;
    y = cnd.y;
    dir = 0;
    nw = (getPixel(x  ,y  ) );
    ne = (getPixel(x+1,y  ));
    sw = (getPixel(x  ,y+1));
    se = (getPixel(x+1,y+1));
    var result:Bool = nextPoint();
    startX = x;
    startY = y;
    startDir = dir;
	return result;
    }

  public function nextPoint(){ return nextPointInline(); }

  public inline function nextPointInline(){
      if(!nw && ne)
        if(sw && !se) // trouble: up or down
          if(((dir >> 1) ^ intCon8) == 1)
            goDown();
          else
            goUp();
        else
          goUp();
      else if(nw && !sw)
        if(!ne && se) // trouble: left or right
          if(((dir >> 1) ^ intCon8) == 1)
            goRight();
          else
            goLeft();
        else
          goLeft();
      else if(!se)
        goDown();
      else
        goRight();

    return (x != startX) || (y != startY) || (dir != startDir);
    }
	
	
	
	inline function getPixel(x:Int, y:Int):Bool {
		return y < across && x < across ? src.has(y * across + x) : false;
	}

  inline function set_con8(val){
    intCon8 = val ? 0 : 1;
    return con8 = val;
    }

  inline function goRight(){ x++;
    nw = ne; sw = se;
    ne = (getPixel(x+1,y  ));
    se = (getPixel(x+1,y+1));
    dir = 0;
    }

  inline function goUp(){ y--;
    sw = nw; se = ne;
    nw = (getPixel(x  ,y  ));
    ne = (getPixel(x+1,y  ));
    dir = 1;
    }

  inline function goLeft(){ x--;
    ne = nw; se = sw;
    nw = (getPixel(x  ,y  ));
    sw = (getPixel(x  ,y+1));
    dir = 2;
    }

  inline function goDown(){ y++;
    nw = sw; ne = se;
    sw = (getPixel(x  ,y+1));
    se = (getPixel(x+1,y+1));
    dir = 3;
    }


  public static inline function searchCandidate(src:BitVector, startx:Int, starty:Int, across:Int) {
	// var iterations:Int = 0;
    while ( startx < across &&  !src.has( starty * across + startx) ) {
		startx++;
	}
    do { startx++; if (startx >= across) throw "Width search forward exceeded!"; } while ( src.has( starty*across+startx) );
    return {x: startx-1, y:starty};
    }
  }
