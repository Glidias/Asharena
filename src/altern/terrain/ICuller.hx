package altern.terrain;

/**
 * @author Glidias
 */
interface ICuller 
{

	/**
	 * @param	culling A value higher than zero is reccomended for testing bounds against required frustum planes
	 * @return	Resultant culling bitmask value. ( 1=near, 2=far, 4=left, 8=right, 16=top, 32=bottom) where bound intersection occurs.
	 * 			A value of -1 bounds completely outside camera view. A value of zero indicates bounds completely within camera view.
	 */
	function cullingInFrustum(culling:Int, boundMinX:Float, boundMinY:Float, boundMinZ:Float, boundMaxX:Float, boundMaxY:Float, boundMaxZ:Float):Int;
	
	
}