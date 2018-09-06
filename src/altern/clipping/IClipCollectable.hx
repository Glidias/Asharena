package altern.clipping;
import altern.culling.CullingPlane;
import util.TypeDefs;

/**
 * @author Glidias
 */
interface IClipCollectable 
{
  	function collectClipPlanes(collector:Vector.<CullingPlane>, collectorCount:Int, frustumPlanes:CullingPlane, frustumPoints:Vector<Float>):Int;
}