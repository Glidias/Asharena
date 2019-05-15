package altern.ds;

/**
 * ...
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
	
	function combine(aabb1:IAbsAABB, aabb2:IAbsAABB):Float;
	function surfaceArea():Float;
	

	
}