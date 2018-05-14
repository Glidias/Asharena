package altern.ray;
import util.TypeDefs.Vector3D;

/**
 * Utility helper class instance to handle "meaningful"/straightforward raycasting for end-user.
 * syntax eg. 
 * var myRaycaster = new Raycaster();
 * var hitTest = myRaycaster.positionAndDirection(x, y, z, dx, dy, dz).gotHit();
 * if (hitTest != null) {
 * 	// do hit resolution
 * }
 * @author Glidias
 */
class Raycaster
{
	/**
	 * @param	source   Assign a starting target source for the given Raycaster implementing IRaycastImpl.
	 */
	public function new(source:IRaycastImpl) 
	{
		this.source = source;
	}
	
	public var source:IRaycastImpl;
	var _origin:Vector3D = new Vector3D();
	var _direction:Vector3D = new Vector3D();
	var _output:Vector3D = new Vector3D();
	
	
	public inline function setTarget(source:IRaycastImpl):Raycaster {
		this.source = source;
		return this;
	}
	public inline function position(x:Float, y:Float, z:Float):Raycaster {
		_origin.x = x;
		_origin.y = y;
		_origin.z = z;
		return this;
	}
	public inline function direction(x:Float, y:Float, z:Float):Raycaster {
		_direction.x = x;
		_direction.y = y;
		_direction.z = z;
		return this;
	}
	public inline function positionAndDirection(x:Float, y:Float, z:Float, dx:Float, dy:Float, dz:Float):Raycaster {
		_origin.x = x;
		_origin.y = y;
		_origin.z = z;
		_direction.x = dx;
		_direction.y = dy;
		_direction.z = dz;
		return this;
	}
	
	/**
	 * 
	 * @param	dist	Set to zero to not have any distance clamp consideration. Otherwise, any distance greater or equal to this parameter will not be raycasted/recorded as a hit!
	 */
	public inline function setIgnoreDistance(dist:Float):Void {
		_direction.w = dist;
	}
	
	/* INTERFACE altern.ray.IRaycastImpl */
	
	public inline function gotHit():Vector3D 
	{
		_output.w = 0;
		var result:Vector3D =  source.intersectRay(_origin, _direction, _output);
		
		if (result != null) {
			result.x = _origin.x + result.w * _direction.x;
			result.y = _origin.y + result.w * _direction.y;
			result.z = _origin.z + result.w * _direction.z;
		}
		return result;
	}
	
}