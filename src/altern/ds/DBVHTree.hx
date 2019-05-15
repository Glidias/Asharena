package altern.ds;
import haxe.Constraints.Constructible;
import util.TypeDefs;



/**
 * Generic version of Dynamic Bounding Volume Hierachy tree
 * @author Glidias
 */
@:generic
class DBVHTree<P, A:(IAbsAABB,Constructible<IAbsAABB>)>
{
	 /**
	 * The root of the tree.
	 */
    public var root:DBVHNode<P,A>;
    
    private var freeNodes:Array<DBVHNode<P,A>>;
    private var numFreeNodes:Int;
    private var aabb:IAbsAABB;
	
	// For ITCollidable and IRaycastImpl
	var _stack:Array<DBVHNode<P,A>> = [];
	public function purge() {
		TypeDefs.setVectorLen(_stack, 0);
	}
	
    
    public function new(aabb:IAbsAABB) {
        freeNodes = [];
        numFreeNodes = 0;
		this.aabb = aabb;
    }
    


    public function moveLeaf(leaf:DBVHNode<P,A>) {
        deleteLeaf(leaf);
        insertLeaf(leaf);
    }
    
	
   
    public function insertLeaf(leaf:DBVHNode<P,A>) {
        if (root == null) {
            root = leaf;
            return;
        }
        var lb:IAbsAABB = leaf.aabb;
        var sibling:DBVHNode<P,A> = root;
        var oldArea:Float;
        var newArea:Float;
        while (sibling.proxy == null) {  // descend the node to search the best pair  
            var c1:DBVHNode<P,A> = sibling.child1;
            var c2:DBVHNode<P,A> = sibling.child2;
            var b:IAbsAABB = sibling.aabb;
            var c1b:IAbsAABB = c1.aabb;
            var c2b:IAbsAABB = c2.aabb;
            
            oldArea = b.surfaceArea();
            aabb.combine(lb, b);
            newArea = aabb.surfaceArea();
            var creatingCost:Float = newArea * 2;  // cost of creating a new pair with the node  
            var incrementalCost:Float = (newArea - oldArea) * 2;
            
            var discendingCost1:Float = incrementalCost;
            aabb.combine(lb, c1b);
            if (c1.proxy != null) {
                // leaf cost = area(combined aabb)
                discendingCost1 += aabb.surfaceArea();
            }
            else {
                // node cost = area(combined aabb) - area(old aabb)
                discendingCost1 += aabb.surfaceArea() - c1b.surfaceArea();
            }
            
            var discendingCost2:Float = incrementalCost;
            aabb.combine(lb, c2b);
            if (c2.proxy != null) {
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
        var oldParent:DBVHNode<P,A> = sibling.parent;
        var newParent:DBVHNode<P,A>;
        if (numFreeNodes > 0) {
            newParent = freeNodes[--numFreeNodes];
        }
        else {
            newParent = new DBVHNode<P,A>();
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
    
    public function getBalance(node:DBVHNode<P,A>):Int {
        if (node.proxy != null) {
			return 0;
		}
        return node.child1.height - node.child2.height;
    }
    
	/*
    public function print(node:DBVHNode<P,A>, indent:Int, text:String):String {
        var hasChild:Bool = node.proxy == null;
		
        if (hasChild) {
            text = print(node.child1, indent + 1, text);
		}
		
        var i:Int = indent * 2;
        while (i >= 0){
            text += " ";
            i--;
        }
		
        text += ((hasChild) ? getBalance(node) + "" : "[" + node.proxy.leaf.aabb.minX + "]") + "\n"; 
        if (hasChild) {
            text = print(node.child2, indent + 1, text);
		}
		
        return text;
    }
    */
  
    public function deleteLeaf(leaf:DBVHNode<P,A>) {
        if (leaf == root) {
            root = null;
            return;
        }
        var parent:DBVHNode<P,A> = leaf.parent;
        var sibling:DBVHNode<P,A>;
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
        var grandParent:DBVHNode<P,A> = parent.parent;
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
	
    
    private function balance(node:DBVHNode<P,A>):DBVHNode<P,A> {
        var nh:Int = node.height;
        if (nh < 2) {
            return node;
        }
		
        var p:DBVHNode<P,A> = node.parent;
        var l:DBVHNode<P,A> = node.child1;
        var r:DBVHNode<P,A> = node.child2;
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
            var ll:DBVHNode<P,A> = l.child1;
            var lr:DBVHNode<P,A> = l.child2;
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
            var rl:DBVHNode<P,A> = r.child1;
            var rr:DBVHNode<P,A> = r.child2;
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
    
    inline private function fix(node:DBVHNode<P,A>) {
        var c1:DBVHNode<P,A> = node.child1;
        var c2:DBVHNode<P,A> = node.child2;
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

@:generic
class DBVHNode<P, A:(IAbsAABB, Constructible<IAbsAABB>)> {
	
    /**
	 * The first child node of this node.
	 */
    public var child1:DBVHNode<P,A>;
    
    /**
	 * The second child node of this node.
	 */
    public var child2:DBVHNode<P,A>;
    
    /**
	 * The parent node of this tree.
	 */
    public var parent:DBVHNode<P,A>;
    
    /**
	 * The proxy of this node. This has no value if this node is not leaf.
	 */
    public var proxy:P;
    
    /**
	 * The maximum distance from leaf nodes.
	 */
    public var height:Int;
    
    /**
	 * The IAbsAABB of this node.
	 */
    public var aabb:A;
	
     public function new() {
        this.aabb = new A();
    }
  
}
