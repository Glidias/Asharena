package altern.culling;
import util.TypeDefs.Vector;
import util.TypeDefs.Vector3D;

/**
 * @author Glidias
 */
interface IFrustumCollectTri 
{
	function collectTrisForFrustum(frustum:CullingPlane, culling:Int, frustumCorners:Vector<Vector3D>, vertices:Vector<Float>, indices:Vector<UInt>):Void;
}