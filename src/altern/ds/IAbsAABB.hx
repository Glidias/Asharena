package altern.ds;

/**
 * An interface to help in generic implementations of AABB representations of anything
 * @author Glidias
 */
interface IAbsAABB 
{
	var minX(get, set):Float;
	var minY(get, set):Float;
	var minZ(get, set):Float;

	var maxX(get, set):Float;
	var maxY(get, set):Float;
	var maxZ(get, set):Float;
	
	function combine(aabb1:IAbsAABB, aabb2:IAbsAABB):Void;
	function surfaceArea():Float;

}