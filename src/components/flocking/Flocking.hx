package components.flocking;
import util.geom.Vec3;

/**
 * Call new Flocking().setup()  to set this up!
 * @author Glenn Ko
 */
class Flocking
{
	// core data for flocking system
	public var separation:Vec3;
    public var alignment:Vec3;
    public var cohesion:Vec3;
	
	
	public var _a:Vec3;  // Acceleration relavant to system
	public var _aold:Vec3;  // if acceleration smoothing required
	public var angle:Float;  // calculated angle value under system
	public var minTime:Float;
	public var rangle:Float;

	 // private var  no:Int;  // id for debugging
	 
	 // necessary pre-calculated parameters for system
	public var settings:FlockSettings;
	 
				
	public function new() 
	{
		
	}
	
	public function setup(flockSettings:FlockSettings):Flocking {
		
		this.settings = flockSettings;
		 rangle = Math.random() * 2 * Math.PI;
		minTime  = (10.0 / 3);
		
		separation = new Vec3();
		alignment = new Vec3();
		cohesion = new Vec3();
		_a = new Vec3();
		_aold = new Vec3();
		
		
		
		return this;
	}
	

	
	public static function createFlockSettings( minDist:Float, senseDistance:Float, minx:Float = 0, miny:Float=0, maxx2:Float = 400, maxy2:Float = 400, minspeed:Float=8, maxspeed:Float=32, turnAccelRatio:Float=0, seperationScale:Float=.5, alignmentScale:Float=2, cohesionScale:Float=8):FlockSettings {
		var me:FlockSettings = new FlockSettings();
		me.minspeed = minspeed;
		me.maxspeed = maxspeed;
		me.turnAccelRatio = turnAccelRatio;
		me.mydist = senseDistance;
		me.mydistSquared = senseDistance * senseDistance;
		me.mindistSquared = minDist * minDist;
		
		me.maxx = maxx2-senseDistance;
		me.maxy = maxy2-senseDistance;
        me.minx = senseDistance;
        me.miny = senseDistance;
		
		me.seperationScale = seperationScale;
		me.alignmentScale = alignmentScale;
		me.cohesionScale = cohesionScale;
		
		return me;
	}
}


class FlockSettings {
	 public var maxx:Float;  	 // movement limit bounds based off radius of entity (assumed radius doesn't change..)
     public var maxy:Float;
     public var minx:Float;
     public var miny:Float;
	 
	 public var mindistSquared:Float;    //  distances of the boid's radius
     public var mydistSquared:Float;  
	 public var mydist:Float;
	 public var maxspeed:Float;
	 public var minspeed:Float;
	 public var turnAccelRatio:Float;
	 
	  public var seperationScale:Float;
      public var cohesionScale:Float;
      public var alignmentScale:Float;
	 
	 public function new() {
		 
	 }
}