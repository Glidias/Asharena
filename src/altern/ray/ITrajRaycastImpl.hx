package altern.ray;
import util.TypeDefs;

/**
 * @author Glidias
 */
interface ITrajRaycastImpl 
{
    function intersectRayTraj(origin:Vector3D, direction:Vector3D, strength:Float, gravity:Float, output:Vector3D):Vector3D;
}