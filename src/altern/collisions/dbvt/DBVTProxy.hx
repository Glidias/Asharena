package altern.collisions.dbvt;
import altern.ray.IRaycastImpl;
import components.Transform3D;
import systems.collisions.ITCollidable;
import util.LibUtil;
import util.geom.AABBUtils;

/**
 * @author Glidias
 */
#if alternExpose @:expose #end
class DBVTProxy 
{
	public var raycastable:IRaycastImpl;
	public var collidable:ITCollidable;
	public var transform:Transform3D;
	public var inverseTransform:Transform3D;
	public var localToGlobalTransform:Transform3D;
	public var globalToLocalTransform:Transform3D;
	//public var leaf:DBVTNode;
	
	public function new() 
	{
		//leaf = new DBVTNode();
		///leaf.proxy = this;
	}
	
	/*
	public static function createFrom(obj:Dynamic, aabb:AbstractAABB, transform:Transform3D=null):DBVTProxy {
        var me = new DBVTProxy();
		AABBUtils.match(cast me.leaf.aabb, cast aabb);
		me.collidable = LibUtil.as(obj, ITCollidable);
		me.raycastable = LibUtil.as(obj, IRaycastImpl);
		if (transform != null) {
			me.transform = transform;
			me.inverseTransform = new Transform3D();
			me.inverseTransform.calculateInversion(transform);
			me.localToGlobalTransform = new Transform3D();
			me.globalToLocalTransform = new Transform3D();
		}
		return me;
    }
	*/
	
}