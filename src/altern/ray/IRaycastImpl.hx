package altern.ray;
import util.TypeDefs;

/**
 * @author Glidias
 */
interface IRaycastImpl 
{
	/**
	 * The implementation for this interface is highly app-specific and not meant to be user friendly. 
	 * Most end users would simply use an altern.ray.Raycaster utility class instance to manage all raycasts from a specific starting source, and also handles some further boilerplate to get raycast position in global space (and any extra data) for it if the user so requires.
	 * 
	 * @param	origin	The starting position of the ray in local coordinate space of receiving object.
	 * @param	direction	The direction vector of ray in local coordinate space of receiving object. The "w" component of the direction vector, if set to a non-zero value, imples a default ignore-beyond "clamp" length. This means the raycast distance must be LOWER (<) than the given clamp length in order to trigger a "hit". Any objects that lie above or equal (>=) to the given clamp distance, is missed completely.
	 * @param	output	The output vector to use. Under normal use, remember to reset the output.w value to zero for every new raycast source raycast  (or create a fresh new vector each time)! If set to a non-zero value, will treat the output.w as the current clamp length, instead of direction.w!
	 * @return	If "hit", returns the same output Vector3D whose "w" component is updated (including local hit position).
	 */
	function intersectRay(origin:Vector3D, direction:Vector3D, output:Vector3D):Vector3D;
 
}