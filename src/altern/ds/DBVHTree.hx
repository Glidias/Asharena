package altern.ds;
import altern.collisions.dbvt.AbstractAABB;
import util.TypeDefs;
import util.geom.AABBUtils;



/**
 * Generic version of Dynamic Bounding Volume Hierachy tree to support extra data per node
 * @author Glidias
 */
@:generic
class DBVHTree<P>
{
	 /**
	 * The root of the tree.
	 */
    public var root:DBVHNode<P>;
    
    private var freeNodes:Array<DBVHNode<P>>;
    private var numFreeNodes:Int;
    private var aabb:AbstractAABB;
	
	public var nodeDataFactoryMethod:Void->P;
	
	// For ITCollidable and IRaycastImpl
	var _stack:Array<DBVHNode<P>> = [];
	public function purge() {
		TypeDefs.setVectorLen(_stack, 0);
	}
	
    
    public function new() {
        freeNodes = [];
        numFreeNodes = 0;
		this.aabb = new AbstractAABB();
    }
    


    public function moveLeaf(leaf:DBVHNode<P>) {
        deleteLeaf(leaf);
        insertLeaf(leaf);
    }
   
    public function insertLeaf(leaf:DBVHNode<P>) {
        if (root == null) {
            root = leaf;
            return;
        }
        var lb:AbstractAABB = leaf.aabb;
        var sibling:DBVHNode<P> = root;
        var oldArea:Float;
        var newArea:Float;
        while (!sibling.isLeaf()) {  // descend the node to search the best pair  
            var c1:DBVHNode<P> = sibling.child1;
            var c2:DBVHNode<P> = sibling.child2;
            var b:AbstractAABB = sibling.aabb;
            var c1b:AbstractAABB = c1.aabb;
            var c2b:AbstractAABB = c2.aabb;
            
            oldArea = b.surfaceArea();
            aabb.combine(lb, b);
            newArea = aabb.surfaceArea();
            var creatingCost:Float = newArea * 2;  // cost of creating a new pair with the node  
            var incrementalCost:Float = (newArea - oldArea) * 2;
            
            var discendingCost1:Float = incrementalCost;
            aabb.combine(lb, c1b);
            if (c1.isLeaf()) {
                // leaf cost = area(combined aabb)
                discendingCost1 += aabb.surfaceArea();
            }
            else {
                // node cost = area(combined aabb) - area(old aabb)
                discendingCost1 += aabb.surfaceArea() - c1b.surfaceArea();
            }
            
            var discendingCost2:Float = incrementalCost;
            aabb.combine(lb, c2b);
            if (c2.isLeaf()) {
                // leaf cost = area(combined aabb)
                discendingCost2 += aabb.surfaceArea();
            }
            else {
                // node cost = area(combined aabb) - area(old aabb)
                discendingCost2 += aabb.surfaceArea() - c2b.surfaceArea();
            }
            
            if (discendingCost1 < discendingCost2) {
                if (creatingCost < discendingCost1) {
                    break;
                }
                else {
                    sibling = c1;
                }
            }
            else {
                if (creatingCost < discendingCost2) {
                    break;
                }
                else {
                    sibling = c2;
                }
            }
        }
        var oldParent:DBVHNode<P> = sibling.parent;
        var newParent:DBVHNode<P>;
        if (numFreeNodes > 0) {
            newParent = freeNodes[--numFreeNodes];
        }
        else {
            newParent = new DBVHNode<P>();
			if (nodeDataFactoryMethod != null) newParent.data = nodeDataFactoryMethod();
        }
        newParent.parent = oldParent;
        newParent.child1 = leaf;
        newParent.child2 = sibling;
        newParent.aabb.combine(leaf.aabb, sibling.aabb);
        newParent.height = sibling.height + 1;
        sibling.parent = newParent;
        leaf.parent = newParent;
        if (sibling == root) {
            // replace root
            root = newParent;
        }
        else {
            // replace child
            if (oldParent.child1 == sibling) {
                oldParent.child1 = newParent;
            }
            else {
                oldParent.child2 = newParent;
            }
        }  // update whole tree  
        
        do{
            newParent = balance(newParent);
            fix(newParent);
            newParent = newParent.parent;
        }        while ((newParent != null));
    }
    
    public function getBalance(node:DBVHNode<P>):Int {
        if (node.isLeaf()) {
			return 0;
		}
        return node.child1.height - node.child2.height;
    }
    
  
    public function deleteLeaf(leaf:DBVHNode<P>) {
        if (leaf == root) {
            root = null;
            return;
        }
        var parent:DBVHNode<P> = leaf.parent;
        var sibling:DBVHNode<P>;
        if (parent.child1 == leaf) {
            sibling = parent.child2;
        }
        else {
            sibling = parent.child1;
        }
        if (parent == root) {
            root = sibling;
            sibling.parent = null;
            return;
        }
        var grandParent:DBVHNode<P> = parent.parent;
        sibling.parent = grandParent;
        if (grandParent.child1 == parent) {
            grandParent.child1 = sibling;
        }
        else {
            grandParent.child2 = sibling;
        }
        if (numFreeNodes < 16384) {
            freeNodes[numFreeNodes++] = parent;
        }
        do {
            grandParent = balance(grandParent);
            fix(grandParent);
            grandParent = grandParent.parent;
        } while (grandParent != null);
    }
	
    
    private function balance(node:DBVHNode<P>):DBVHNode<P> {
        var nh:Int = node.height;
        if (nh < 2) {
            return node;
        }
		
        var p:DBVHNode<P> = node.parent;
        var l:DBVHNode<P> = node.child1;
        var r:DBVHNode<P> = node.child2;
        var lh:Int = l.height;
        var rh:Int = r.height;
        var balance:Int = lh - rh;
        var t:Int;  // for bit operation  
        
        //          [ N ]
        //         /     \
        //    [ L ]       [ R ]
        //     / \         / \
        // [L-L] [L-R] [R-L] [R-R]
        
        // Is the tree balanced?
        if (balance > 1) {
            var ll:DBVHNode<P> = l.child1;
            var lr:DBVHNode<P> = l.child2;
            var llh:Int = ll.height;
            var lrh:Int = lr.height;
            
            // Is L-L higher than L-R?
            if (llh > lrh) {
                // set N to L-R
                l.child2 = node;
                node.parent = l;
                
                //          [ L ]
                //         /     \
                //    [L-L]       [ N ]
                //     / \         / \
                // [...] [...] [ L ] [ R ]
                
                // set L-R
                node.child1 = lr;
                lr.parent = node;
                
                //          [ L ]
                //         /     \
                //    [L-L]       [ N ]
                //     / \         / \
                // [...] [...] [L-R] [ R ]
                
                // fix bounds and heights
                node.aabb.combine(lr.aabb, r.aabb);
                t = lrh - rh;
                node.height = lrh - (t & t >> 31) + 1;
                
                l.aabb.combine(ll.aabb, node.aabb);
                t = llh - nh;
                l.height = llh - (t & t >> 31) + 1;
            }
            else {
                // set N to L-L
                l.child1 = node;
                node.parent = l;
                
                //          [ L ]
                //         /     \
                //    [ N ]       [L-R]
                //     / \         / \
                // [ L ] [ R ] [...] [...]
                
                // set L-L
                node.child1 = ll;
                ll.parent = node;
                
                //          [ L ]
                //         /     \
                //    [ N ]       [L-R]
                //     / \         / \
                // [L-L] [ R ] [...] [...]
                
                // fix bounds and heights
                node.aabb.combine(ll.aabb, r.aabb);
                t = llh - rh;
                node.height = llh - (t & t >> 31) + 1;
                
                l.aabb.combine(node.aabb, lr.aabb);
                t = nh - lrh;
                l.height = nh - (t & t >> 31) + 1;
            }  // set new parent of L  
            
            if (p != null) {
                if (p.child1 == node) {
                    p.child1 = l;
                }
                else {
                    p.child2 = l;
                }
            }
            else {
                root = l;
            }
            l.parent = p;
            return l;
        }
        else if (balance < -1) {
            var rl:DBVHNode<P> = r.child1;
            var rr:DBVHNode<P> = r.child2;
            var rlh:Int = rl.height;
            var rrh:Int = rr.height;
            
            // Is R-L higher than R-R?
            if (rlh > rrh) {
                // set N to R-R
                r.child2 = node;
                node.parent = r;
                
                //          [ R ]
                //         /     \
                //    [R-L]       [ N ]
                //     / \         / \
                // [...] [...] [ L ] [ R ]
                
                // set R-R
                node.child2 = rr;
                rr.parent = node;
                
                //          [ R ]
                //         /     \
                //    [R-L]       [ N ]
                //     / \         / \
                // [...] [...] [ L ] [R-R]
                
                // fix bounds and heights
                node.aabb.combine(l.aabb, rr.aabb);
                t = lh - rrh;
                node.height = lh - (t & t >> 31) + 1;
                r.aabb.combine(rl.aabb, node.aabb);
                t = rlh - nh;
                r.height = rlh - (t & t >> 31) + 1;
            }
            else {
                // set N to R-L
                r.child1 = node;
                node.parent = r;
                
                //          [ R ]
                //         /     \
                //    [ N ]       [R-R]
                //     / \         / \
                // [ L ] [ R ] [...] [...]
                
                // set R-L
                node.child2 = rl;
                rl.parent = node;
                
                //          [ R ]
                //         /     \
                //    [ N ]       [R-R]
                //     / \         / \
                // [ L ] [R-L] [...] [...]
                
                // fix bounds and heights
                node.aabb.combine(l.aabb, rl.aabb);
                t = lh - rlh;
                node.height = lh - (t & t >> 31) + 1;
                r.aabb.combine(node.aabb, rr.aabb);
                t = nh - rrh;
                r.height = nh - (t & t >> 31) + 1;
            }  // set new parent of R  
            
            if (p != null) {
                if (p.child1 == node) {
                    p.child1 = r;
                }
                else {
                    p.child2 = r;
                }
            }
            else {
                root = r;
            }
            r.parent = p;
            return r;
        }
		
        return node;
    }
    
    inline private function fix(node:DBVHNode<P>) {
        var c1:DBVHNode<P> = node.child1;
        var c2:DBVHNode<P> = node.child2;
        node.aabb.combine(c1.aabb, c2.aabb);
        var h1:Int = c1.height;
        var h2:Int = c2.height;
        if (h1 < h2) {
            node.height = h2 + 1;
        }
        else {
            node.height = h1 + 1;
        }
    }
	
	

	
}

/**
 * Generic AABB tree node to store extended data
 * @author Glidias
 */
@:generic
class DBVHNode<P> {
	
    /**
	 * The first child node of this node.
	 */
    public var child1:DBVHNode<P>;
    
    /**
	 * The second child node of this node.
	 */
    public var child2:DBVHNode<P>;
    
    /**
	 * The parent node of this tree.
	 */
    public var parent:DBVHNode<P>;
    
    /**
	 * Any extra data of this node. 
	 */
    public var data:P;
    
    /**
	 * The maximum distance from leaf nodes.
	 */
    public var height:Int;
    
    /**
	 * The AbstractAABB of this node.
	 */
    public var aabb:AbstractAABB;
	
	public inline function isLeaf():Bool {
		return child1 == null;
	}
	
     public function new() {
        this.aabb = new AbstractAABB();
    }
  
}
