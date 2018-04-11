package alternativa.a3d.clippers 
{
	import alternativa.engine3d.core.CullingPlane;
	/**
	 * ...
	 * @author Glidias
	 */
	public interface IClipCollectable 
	{
		/**
		 * 
		 * @param	collector	The array used for collecting planes
		 * @param 	collectorCount	Current culling planes collected so far
		 * @param	frustumPlanes	Viewing target frustum planes
		 * @param	frustumPoints	Viewing target frustum's points. Source, + 4 corners if frustumPlanes length is 5 (cone). 
		 * 							Or if Trapezoid (Source + 4 corners  + 4 corners) if frustum plane length is 9.
		 * @return  (int)  collectorCount value to update
		 */
		function collectClipPlanes(collector:Vector.<CullingPlane>, collectorCount:int, frustumPlanes:CullingPlane, frustumPoints:Vector.<Number>):int;
	}

}