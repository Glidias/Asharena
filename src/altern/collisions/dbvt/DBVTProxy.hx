package altern.collisions.dbvt;
import altern.ray.IRaycastImpl;
import systems.collisions.ITCollidable;
import util.LibUtil;

/**
 * @author Glidias
 */
class DBVTProxy 
{
	public var raycastable:IRaycastImpl;
	public var collidable:ITCollidable;
	public var leaf:DBVTNode;
	
	public function new() 
	{
		leaf = new DBVTNode();
		leaf.proxy = this;
	}
	
	public static function createFrom(obj:Dynamic):DBVTProxy {
        var me = new DBVTProxy();
		me.collidable = LibUtil.as(obj, ITCollidable);
		me.raycastable = LibUtil.as(obj, IRaycastImpl);
		return me;
    }
	
}