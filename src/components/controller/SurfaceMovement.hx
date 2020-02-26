package components.controller;
import util.geom.Vec3;
import util.geom.Vec3Utils;
import util.geom.Vec3;

/**
 * Component that supports your basic move forward/back and strafe left/right actions.
 * Provides a prescriptive inline method that systems can use. (This could be factored out later...)
 * 
 * @author Glenn Ko
 */
#if alternExpose @:expose #end
class SurfaceMovement 
{
	// State settings
	public var WALK_SPEED:Float;
	public var WALKBACK_SPEED:Float;
	public var STRAFE_SPEED:Float;
	
	
	

	// State for thing
	// delta walk/strafe state (-1 for backwards/left, 0 for neither direction, 1 for forwards/right)
    public var walk_state:Int; 
	public var strafe_state:Int;
	
	public static inline var WALK_FORWARD:Int = 1;
	public static inline var WALK_STOP:Int = 0;
	public static inline var WALK_BACK:Int = -1;

	public static inline var STRAFE_LEFT:Int = -1;
	public static inline var STRAFE_STOP:Int = 0;
	public static inline var STRAFE_RIGHT:Int = 1;
	
	// The below is factored out to a seperate DirectionVectors component
	// Normalized forward direction along surface  
	//	public var forwardVec:Vec3;
	//	public var rightVec:Vec3;

	public var friction:Float;
	static public inline var STOP_VELOCITY_SQ_LENGTH:Float = 1;
	
	

	public function new() 
	{
		walk_state = 0;
		strafe_state = 0;
		//forwardVec = new Vec3();
		//rightVec = new Vec3();
		friction = 0;// .05;  // set this to a value lower than STOP_VELOCITY_SQ_LENGTH to ensure no sliding off surfaces occurs
		
		setWalkSpeeds(115, 32);
		//setWalkSpeeds(150, 32);
		setStrafeSpeed(37);
	}
	
	inline public function resetAllStates():Void {
		walk_state = 0;
		strafe_state = 0;
	}
	

	
	inline public function setWalkSpeeds(forwardSpeed:Float, backspeed:Float = -1):Void {

		WALK_SPEED = forwardSpeed;
		WALKBACK_SPEED = (backspeed != -1) ? backspeed : forwardSpeed; 
	}
	inline public function setStrafeSpeed(val:Float):Void {
		STRAFE_SPEED = val;
	}
	inline public function setAllSpeeds(val:Float):Void {
		WALK_SPEED = val;
		WALKBACK_SPEED  = val;
		STRAFE_SPEED = val;
	}
		
	inline public function respond_move_forward():Void {
		walk_state = 1;
	}
	inline public function respond_move_back():Void {
		walk_state = -1;
	}
	inline public function respond_move_stop():Void {
		walk_state = 0;
	}
	
	inline public function respond_strafe_left():Void {
		strafe_state = -1;
	}
	inline public function respond_strafe_right():Void {
		strafe_state = 1;
	}
	inline public function respond_strafe_stop():Void {
		strafe_state = 0;
	}

	
	// -- macro methods
	/*
	inline public function update(time:Float,rotation:Vec3, velocity:Vec3, ground_normal:Vec3 = null):Void {
		updateWith(time, rotation,velocity, walk_state, strafe_state, forwardVec, rightVec, WALK_SPEED, WALKBACK_SPEED, STRAFE_SPEED, friction, ground_normal);
	}
	*/
	
	public static inline function updateWith(time:Float, rotation:Vec3, velocity:Vec3, walkState:Int, strafeState:Int, forwardVec:Vec3, rightVec:Vec3, WALK_SPEED:Float, WALKBACK_SPEED:Float, STRAFE_SPEED:Float, friction:Float=.25, ground_normal:Vec3 = null):Void {
		var multiplier:Float;
		
		if (ground_normal != null) { // can walk on ground
  
			Vec3Utils.scale(velocity, friction);
			if (velocity.lengthSqr() < STOP_VELOCITY_SQ_LENGTH) {
				velocity.x = 0;
				velocity.y = 0;
				velocity.z = 0;
			}
			/*
			 * Math.cos(this.thingBase.azimuth) * Math.cos(this.thingBase.elevation), Math.sin(this.thingBase.azimuth) * Math.cos(this.thingBase.elevation)
			 */
			if (rotation !=null) {
				forwardVec.x = -Math.sin(rotation.z); //Math.cos(rotation.z) * Math.cos(rotation.y);  // frm rotation.z azimith
				forwardVec.y = Math.cos(rotation.z);//Math.sin(rotation.z) * Math.cos(rotation.y); // frm rotation.x pitch.  //* Math.cos(rotation.x)
				forwardVec.z = 0;
			}
			if ( Vec3Utils.dot( forwardVec, ground_normal) > 0) {
				//forwardVec.removeComponent(ground_normal);
				multiplier = forwardVec.x * ground_normal.x + forwardVec.y * ground_normal.y + forwardVec.z * ground_normal.z;
				forwardVec.x -= forwardVec.x * multiplier;
				forwardVec.y -= forwardVec.y * multiplier;
				forwardVec.z -= forwardVec.z * multiplier;
			}
			Vec3Utils.normalize(forwardVec);
			if (walkState != 0 ) {
				multiplier = (walkState != WALK_BACK) ? WALK_SPEED : -WALKBACK_SPEED;
				velocity.x += forwardVec.x * multiplier;
				velocity.y += forwardVec.y * multiplier;
				velocity.z += forwardVec.z * multiplier;
	
			}
			
			Vec3Utils.writeCross(forwardVec, ground_normal, rightVec);
			Vec3Utils.normalize(rightVec);
			if (strafeState != 0) {
				multiplier = strafeState != STRAFE_LEFT ? STRAFE_SPEED : -STRAFE_SPEED;
				velocity.x += rightVec.x * multiplier;
				velocity.y += rightVec.y * multiplier;
				velocity.z += rightVec.z * multiplier;
			}
			
		}
	}

}