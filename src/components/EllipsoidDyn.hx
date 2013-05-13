package components;

import util.TypeDefs;

/**
 * To indicate dynamically collidable entities against others
 * @author Glenn Ko
 */
class EllipsoidDyn extends Ellipsoid
{
	public var mask:UInt;
	
	public function new(x:Float=32,y:Float=32,z:Float=32, mash:UInt=0) 
	{
		super();
		mask = 0;
	}
	
}