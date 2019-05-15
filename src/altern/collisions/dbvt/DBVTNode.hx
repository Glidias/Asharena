/* Copyright (c) 2012-2013 EL-EMENT saharan
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy of this
 * software and associated documentation  * files (the "Software"), to deal in the Software
 * without restriction, including without limitation the rights to use, copy,  * modify, merge,
 * publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to
 * whom the Software is furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in all copies or
 * substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
 * INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
 * PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR
 * ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
 * ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 */
package altern.collisions.dbvt;
import altern.ray.IRaycastImpl;
import components.Transform3D;
import systems.collisions.ITCollidable;
import util.LibUtil;
import util.geom.AABBUtils;

/**
 * A node of the dynamic bounding volume tree.
 * @author saharan
 */
class DBVTNode {
	
    /**
	 * The first child node of this node.
	 */
    public var child1:DBVTNode;
    
    /**
	 * The second child node of this node.
	 */
    public var child2:DBVTNode;
    
    /**
	 * The parent node of this tree.
	 */
    public var parent:DBVTNode;
    
    /**
	 * The proxy of this node. This has no value if this node is not leaf.
	 */
    public var proxy:DBVTProxy;
    
    /**
	 * The maximum distance from leaf nodes.
	 */
    public var height:Int;
    
    /**
	 * The AbstractAABB of this node.
	 */
    public var aabb:AbstractAABB;
	
    
    public function new() {
        aabb = new AbstractAABB();
    }
	
	public static function createFrom(obj:Dynamic, aabb:AbstractAABB, transform:Transform3D = null):DBVTNode {
		var node = new DBVTNode();
        var me = new DBVTProxy();
		node.aabb = new AbstractAABB();
		AABBUtils.match(cast node.aabb, cast aabb);
		me.collidable = LibUtil.as(obj, ITCollidable);
		me.raycastable = LibUtil.as(obj, IRaycastImpl);
		if (transform != null) {
			me.transform = transform;
			me.inverseTransform = new Transform3D();
			me.inverseTransform.calculateInversion(transform);
			me.localToGlobalTransform = new Transform3D();
			me.globalToLocalTransform = new Transform3D();
		}
		node.proxy = me;
		return node;
    }
	
}
