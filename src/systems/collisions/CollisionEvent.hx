/**
 * Generic event template for creating collisions against static geometry and things
 * while moving.
 * @author Glenn Ko
 */

package systems.collisions;
import ash.core.Entity;
import util.geom.Vec3;
import util.geom.Vec3Utils;
import util.geom.Vec3;
import util.TypeDefs;

class CollisionEvent 
{
	public var pos:Vec3;
	
    public var offset:Float;
	public var normal:Vec3;
    
	public var t:Float;  // actual distance to collision (NOT normalized time!)
    public var geomtype:Int;
		
	public static inline var GEOMTYPE_POINT:Int = 1;
    public static inline var GEOMTYPE_EDGE:Int = 2;
	public static inline var GEOMTYPE_POLYGON:Int = 3;
	public static inline var GEOMTYPE_THING:Int = 4;
   
    public static inline var TOLERANCE_POLYGON_OVERLAP:Float = 1e-005;
    public static inline var TOLERANCE_BACKWARDS_T:Float = 1e-006;
    public static inline var TOLERANCE_TRANSVERSE_DISPLACEMENT:Float = 1e-006;
    public static inline var TOLERANCE_QUADRATIC_DISCRIMINANT:Float = 1e-006;
	
	static var COLLECTOR:CollisionEvent = new CollisionEvent();
	public var next:CollisionEvent;
	
	public var thing:Entity;
	
	public function new() 
	{
		pos = new Vec3();
		normal = new Vec3();
	}
	
	public function getNumEvents():Int {
		var ct:Int = 1;
		var m:CollisionEvent = this;
		while ((m= m.next)!=null) {
			ct++;
		}
		return ct;
	}
	
		
	// Pooling, linked list and disposal

	public static inline  function Get(collision:Vec3, normal:Vec3, offset:Float, t:Float, geomtype:Int):CollisionEvent {
		var c:CollisionEvent = COLLECTOR!= null ? COLLECTOR : (COLLECTOR = new CollisionEvent());
		COLLECTOR = COLLECTOR.next;
		c.write(collision, normal, offset, t, geomtype);
		c.next = null;
		return c;
	}
	
	public static inline  function GetAs3(pos:Vector3D, normal:Vector3D, offset:Float, t:Float, geomtype:Int):CollisionEvent {
		var c:CollisionEvent = COLLECTOR!= null ? COLLECTOR : (COLLECTOR = new CollisionEvent());
		COLLECTOR = COLLECTOR.next;
	
		Vec3Utils.matchValuesVector3D(c.pos, pos);
		Vec3Utils.matchValuesVector3D(c.normal, normal);
        c.offset = offset;
        c.t = t;
        c.geomtype = geomtype;
		
		c.next = null;
		return c;
	}
	

	public static inline function get(pos:Vec3, normal:Vec3, offset:Float, t:Float, geomtype:Int):CollisionEvent {
		return Get(pos, normal, offset, t, geomtype);
	}
	
	inline public function write(pos:Vec3, normal:Vec3, offset:Float, t:Float, geomtype:Int):Void {
		Vec3Utils.matchValues(this.pos, pos);
		Vec3Utils.matchValues(this.normal, normal);
        this.offset = offset;
        this.t = t;
        this.geomtype = geomtype;
	}
	
	
	
	inline public function dispose():Void {	
		next = COLLECTOR;
		COLLECTOR = this;
	}
		
		
		// Static methods
		
		public static function getGeomTypeString(type:Int) : String
        {
            switch(type)
            {
                case GEOMTYPE_POINT:
                {
                    return "POINT";
					
                }
                case GEOMTYPE_EDGE:
                {
                    return "EDGE";
                }
                case GEOMTYPE_POLYGON:
                {
                    return "POLYGON";
                }
				case GEOMTYPE_THING:
                {
                    return "THING";
                }
                default:
                {
                    return "UNDEF";
                   
                }
			}
            
        }
	
}