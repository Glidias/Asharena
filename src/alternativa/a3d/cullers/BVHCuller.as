package alternativa.a3d.cullers 
{
	import alternativa.engine3d.core.BoundBox;
	import alternativa.engine3d.core.Camera3D;
	import alternativa.engine3d.core.CullingPlane;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.Transform3D;
	import alternativa.engine3d.objects.IMeshSetCloneCuller;
	import alternativa.engine3d.objects.IMeshSetClonesContainer;
	import alternativa.engine3d.objects.MeshSetClone;
	import flash.utils.Dictionary;
	import alternativa.engine3d.alternativa3d;
	use namespace alternativa3d;
	
	/**
	 * Bounding volume hierachy ( in the form of hierachical bounding boxes)
	 *
	 * @author Glenn Ko
	 */
	public class BVHCuller implements IMeshSetCloneCuller, IMeshSetClonesContainer
	{
		private var proxy:IMeshSetClonesContainer;
		public var tree:DynamicBVTree;
		private var _frustum:CullingPlane;
		
		public var parentTrees:Dictionary = new Dictionary();  // assosiate Object3D key parents with new DynamicBVTrees
		
		public function BVHCuller(proxy:IMeshSetClonesContainer) 
		{
			this.proxy = proxy;
			tree = new DynamicBVTree();
			
		}
		
		
		private var nodeStack:Vector.<DynamicBVTreeNode> = new Vector.<DynamicBVTreeNode>();
	
		
		/* INTERFACE alternativa.engine3d.objects.IMeshSetCloneCuller */
		
		public function cull(numClones:int, clones:Vector.<MeshSetClone>, collector:Vector.<MeshSetClone>, camera:Camera3D, object:Object3D):int 
		{
			camera.calculateFrustum( object.cameraToLocalTransform);
			_frustum = camera.frustum;
			
			var ni:int = 0;
			
			var count:int = 0;
			var node:DynamicBVTreeNode;
			var cNode:DynamicBVTreeNode;
			var nodeAABB:AABB;
			
			node = tree.root;
			
			if (node != null) {
				nodeAABB = node.aabb;
				node.culling = cullingInFrustum(63, nodeAABB.minX, nodeAABB.minY, nodeAABB.minZ, nodeAABB.maxX, nodeAABB.maxY, nodeAABB.maxZ);
				if (node.culling>=0) nodeStack[ni++] = node;
			}
			
			while ( --ni > -1) {
				node = nodeStack[ni];
				if (node.proxy) {
					if (node.proxy.index < 0) throw new Error("SHould no longer be in tree!");
					collector[count++] = node.proxy;
				}
				
				if ( (cNode=node.child1) != null ) {
					nodeAABB = cNode.aabb;
					cNode.culling = cullingInFrustum(node.culling, nodeAABB.minX, nodeAABB.minY, nodeAABB.minZ, nodeAABB.maxX, nodeAABB.maxY, nodeAABB.maxZ);
					if (cNode.culling >= 0) nodeStack[ni++] = cNode;
					//else throw new Error("culled!");
				}
				if ( (cNode=node.child2) != null) {
					nodeAABB = cNode.aabb;
					cNode.culling = cullingInFrustum(node.culling, nodeAABB.minX, nodeAABB.minY, nodeAABB.minZ, nodeAABB.maxX, nodeAABB.maxY, nodeAABB.maxZ);
					if (cNode.culling >= 0) nodeStack[ni++] = cNode;
					//else throw new Error("culled!");
				}
				
			}
			
			
			return count;
		}
		
		private function cullingInFrustum(culling:int, minX:Number, minY:Number, minZ:Number, maxX:Number, maxY:Number, maxZ:Number):int 
		{
			
				
				var frustum:CullingPlane = _frustum;
			//	var temp:Number = minY;
			//	minY = -maxY;
			//	maxY = -temp;
				
				var side:int = 1;
				for (var plane:CullingPlane = frustum; plane != null; plane = plane.next) {
				if (culling & side) {
				if (plane.x >= 0)
				if (plane.y >= 0)
				if (plane.z >= 0) {
				if (maxX*plane.x + maxY*plane.y + maxZ*plane.z <= plane.offset) return -1;
				if (minX*plane.x + minY*plane.y + minZ*plane.z > plane.offset) culling &= (63 & ~side);
				} else {
				if (maxX*plane.x + maxY*plane.y + minZ*plane.z <= plane.offset) return -1;
				if (minX*plane.x + minY*plane.y + maxZ*plane.z > plane.offset) culling &= (63 & ~side);
				}
				else
				if (plane.z >= 0) {
				if (maxX*plane.x + minY*plane.y + maxZ*plane.z <= plane.offset) return -1;
				if (minX*plane.x + maxY*plane.y + minZ*plane.z > plane.offset) culling &= (63 & ~side);
				} else {
				if (maxX*plane.x + minY*plane.y + minZ*plane.z <= plane.offset) return -1;
				if (minX*plane.x + maxY*plane.y + maxZ*plane.z > plane.offset) culling &= (63 & ~side);
				}
				else if (plane.y >= 0)
				if (plane.z >= 0) {
				if (minX*plane.x + maxY*plane.y + maxZ*plane.z <= plane.offset) return -1;
				if (maxX*plane.x + minY*plane.y + minZ*plane.z > plane.offset) culling &= (63 & ~side);
				} else {
				if (minX*plane.x + maxY*plane.y + minZ*plane.z <= plane.offset) return -1;
				if (maxX*plane.x + minY*plane.y + maxZ*plane.z > plane.offset) culling &= (63 & ~side);
				}
				else if (plane.z >= 0) {
				if (minX*plane.x + minY*plane.y + maxZ*plane.z <= plane.offset) return -1;
				if (maxX*plane.x + maxY*plane.y + minZ*plane.z > plane.offset) culling &= (63 & ~side);
				} else {
				if (minX*plane.x + minY*plane.y + minZ*plane.z <= plane.offset) return -1;
				if (maxX*plane.x + maxY*plane.y + maxZ*plane.z > plane.offset) culling &= (63 & ~side);
				}
				}
				side <<= 1;
				}
				return culling;
		}
		
		/* INTERFACE alternativa.engine3d.objects.IMeshSetClonesContainer */
		
		private var cloneNodeDict:Dictionary = new Dictionary();
		private var result:BoundBox = new BoundBox();
		
		private function calculateNewBounds(bound:BoundBox, obj:Object3D, parentTransform:Transform3D, result:BoundBox):void {	
			var x:Number;
			var y:Number;
			var z:Number;
			
			var maxValue:Number =  Number.MAX_VALUE;
			var rx:Number;
			var ry:Number;
			var rz:Number;
			
			result.maxX = -maxValue;
			result.maxY = -maxValue;
			result.maxZ = -maxValue;
			result.minX = maxValue;
			result.minY = maxValue;
			result.minZ = maxValue;
			
			// all min
			x = bound.minX + obj._x;
			y = bound.minY + obj._y;
			z = bound.minZ + obj._z;
			rx= parentTransform.a * x + parentTransform.b * y  +  parentTransform.c*z+ parentTransform.d;
			ry = parentTransform.e * x + parentTransform.f * y +  parentTransform.g * z + parentTransform.h;
			rz= parentTransform.i * x + parentTransform.j * y +  parentTransform.k*z + parentTransform.l;
			if (rx > result.maxX) result.maxX = rx;
			if (rx < result.minX) result.minX = rx;
			if (ry > result.maxY) result.maxY = ry;
			if (ry < result.minY) result.minY = ry;
			if (rz > result.maxZ) result.maxZ = rz;
			if (rz < result.minZ) result.minZ = rz;
			
			// max1 x3
			x = bound.maxX + obj._x;
			y = bound.minY + obj._y;
			z = bound.minZ + obj._z;
				rx= parentTransform.a * x + parentTransform.b * y  +  parentTransform.c*z+ parentTransform.d;
			ry = parentTransform.e * x + parentTransform.f * y +  parentTransform.g * z + parentTransform.h;
			rz= parentTransform.i * x + parentTransform.j * y +  parentTransform.k*z + parentTransform.l;
			if (rx > result.maxX) result.maxX = rx;
			if (rx < result.minX) result.minX = rx;
			if (ry > result.maxY) result.maxY = ry;
			if (ry < result.minY) result.minY = ry;
			if (rz > result.maxZ) result.maxZ = rz;
			if (rz < result.minZ) result.minZ = rz;
			
			
			x = bound.minX + obj._x;
			y = bound.maxY + obj._y;
			z = bound.minZ + obj._z;
				rx= parentTransform.a * x + parentTransform.b * y  +  parentTransform.c*z+ parentTransform.d;
			ry = parentTransform.e * x + parentTransform.f * y +  parentTransform.g * z + parentTransform.h;
			rz= parentTransform.i * x + parentTransform.j * y +  parentTransform.k*z + parentTransform.l;
			if (rx > result.maxX) result.maxX = rx;
			if (rx < result.minX) result.minX = rx;
			if (ry > result.maxY) result.maxY = ry;
			if (ry < result.minY) result.minY = ry;
			if (rz > result.maxZ) result.maxZ = rz;
			if (rz < result.minZ) result.minZ = rz;
			
			
			x = bound.minX + obj._x;
			y = bound.minY + obj._y;
			z = bound.maxZ + obj._z;
				rx= parentTransform.a * x + parentTransform.b * y  +  parentTransform.c*z+ parentTransform.d;
			ry = parentTransform.e * x + parentTransform.f * y +  parentTransform.g * z + parentTransform.h;
			rz= parentTransform.i * x + parentTransform.j * y +  parentTransform.k*z + parentTransform.l;
			if (rx > result.maxX) result.maxX = rx;
			if (rx < result.minX) result.minX = rx;
			if (ry > result.maxY) result.maxY = ry;
			if (ry < result.minY) result.minY = ry;
			if (rz > result.maxZ) result.maxZ = rz;
			if (rz < result.minZ) result.minZ = rz;
			
			
			// max2 x3
			x = bound.maxX + obj._x;
			y = bound.maxY + obj._y;
			z = bound.minZ + obj._z;
				rx= parentTransform.a * x + parentTransform.b * y  +  parentTransform.c*z+ parentTransform.d;
			ry = parentTransform.e * x + parentTransform.f * y +  parentTransform.g * z + parentTransform.h;
			rz= parentTransform.i * x + parentTransform.j * y +  parentTransform.k*z + parentTransform.l;
			if (rx > result.maxX) result.maxX = rx;
			if (rx < result.minX) result.minX = rx;
			if (ry > result.maxY) result.maxY = ry;
			if (ry < result.minY) result.minY = ry;
			if (rz > result.maxZ) result.maxZ = rz;
			if (rz < result.minZ) result.minZ = rz;
			
			x = bound.minX + obj._x;
			y = bound.maxY + obj._y;
			z = bound.maxZ + obj._z;
				rx= parentTransform.a * x + parentTransform.b * y  +  parentTransform.c*z+ parentTransform.d;
			ry = parentTransform.e * x + parentTransform.f * y +  parentTransform.g * z + parentTransform.h;
			rz= parentTransform.i * x + parentTransform.j * y +  parentTransform.k*z + parentTransform.l;
			if (rx > result.maxX) result.maxX = rx;
			if (rx < result.minX) result.minX = rx;
			if (ry > result.maxY) result.maxY = ry;
			if (ry < result.minY) result.minY = ry;
			if (rz > result.maxZ) result.maxZ = rz;
			if (rz < result.minZ) result.minZ = rz;
			
			x = bound.maxX + obj._x;
			y = bound.minY + obj._y;
			z = bound.maxZ + obj._z;
				rx= parentTransform.a * x + parentTransform.b * y  +  parentTransform.c*z+ parentTransform.d;
			ry = parentTransform.e * x + parentTransform.f * y +  parentTransform.g * z + parentTransform.h;
			rz= parentTransform.i * x + parentTransform.j * y +  parentTransform.k*z + parentTransform.l;
			if (rx > result.maxX) result.maxX = rx;
			if (rx < result.minX) result.minX = rx;
			if (ry > result.maxY) result.maxY = ry;
			if (ry < result.minY) result.minY = ry;
			if (rz > result.maxZ) result.maxZ = rz;
			if (rz < result.minZ) result.minZ = rz;
			
			// all max
			x = bound.maxX + obj._x;
			y = bound.maxY + obj._y;
			z = bound.maxZ + obj._z;
			rx= parentTransform.a * x + parentTransform.b * y  +  parentTransform.c*z+ parentTransform.d;
			ry = parentTransform.e * x + parentTransform.f * y +  parentTransform.g * z + parentTransform.h;
			rz= parentTransform.i * x + parentTransform.j * y +  parentTransform.k*z + parentTransform.l;
		
			if (rx > result.maxX) result.maxX = rx;
			if (rx < result.minX) result.minX = rx;
			if (ry > result.maxY) result.maxY = ry;
			if (ry < result.minY) result.minY = ry;
			if (rz > result.maxZ) result.maxZ = rz;
			if (rz < result.minZ) result.minZ = rz;
		}
		
		public function addClone(cloneItem:MeshSetClone):MeshSetClone 
		{
			var maxZ:Number;
			var maxY:Number;
			var maxX:Number;
			var minZ:Number;
			var minY:Number;
			var minX:Number;
			proxy.addClone(cloneItem);
			var node:DynamicBVTreeNode = new DynamicBVTreeNode();
			node.proxy = cloneItem;
		
					
					
			var parentTransform:Transform3D = null;
			var parent:Object3D = cloneItem.root._parent;
			if (parent != null) parentTransform = cloneItem.root._parent.transform;
			
			
			if (parentTransform != null) {  // TODO: need to check if there is rotation for parent object3D, and if so, expand AABB accordingly.
				//if (parent.transformChanged) parent.composeTransforms();
				if (parent._rotationX != 0  || parent._rotationY != 0 || parent._rotationZ != 0) {

					calculateNewBounds(cloneItem.root.boundBox, cloneItem.root, parentTransform, result);
				
					node.aabb.minX = result.minX;
					node.aabb.minY = result.minY;
					node.aabb.minZ =result.minZ;
					
					node.aabb.maxX = result.maxX;
					node.aabb.maxY = result.maxY;
					node.aabb.maxZ = result.maxZ;
					
				}
				else {
				
			
				// assumes cloneItme.root is identity rotation and scale!  So only need to offset translation!
					minX = cloneItem.root.boundBox.minX + cloneItem.root._x;
					minY =  cloneItem.root.boundBox.minY+ cloneItem.root._y;
					minZ =  cloneItem.root.boundBox.minZ + cloneItem.root._z;
				
					maxX =  cloneItem.root.boundBox.maxX + cloneItem.root._x;
					maxY =  cloneItem.root.boundBox.maxY + cloneItem.root._y;
					maxZ =  cloneItem.root.boundBox.maxZ + cloneItem.root._z;
					
					node.aabb.minX =parentTransform.a * minX + parentTransform.b * minY  +  parentTransform.c*minZ+ parentTransform.d;
					node.aabb.minY = parentTransform.e * minX + parentTransform.f * minY +  parentTransform.g * minZ + parentTransform.h;
					node.aabb.minZ = parentTransform.i * minX + parentTransform.j * minY +  parentTransform.k*minZ + parentTransform.l;
					
					node.aabb.maxX =parentTransform.a * maxX + parentTransform.b * maxY  +  parentTransform.c*maxZ+ parentTransform.d;
					node.aabb.maxY = parentTransform.e * maxX + parentTransform.f * maxY + parentTransform.c*maxZ+ parentTransform.h;
					node.aabb.maxZ = parentTransform.i * maxX + parentTransform.j * maxY + parentTransform.k * maxZ +  parentTransform.l;
				}
			}
			else {
				node.aabb.minX = minX;
				node.aabb.minY = minY;
				node.aabb.maxX = maxX;
				node.aabb.maxY = maxY;
				node.aabb.minZ = minZ;
				node.aabb.maxZ = maxZ;
			}
			
			tree.insertLeaf( node );
			cloneNodeDict[cloneItem] = node;
			return cloneItem;
		}
		
		public function removeClone(cloneItem:MeshSetClone):void 
		{
			proxy.removeClone(cloneItem);
			if (cloneItem.index >= 0) throw new Error("SHOULD NOT BE!");
			tree.deleteLeaf(cloneNodeDict[cloneItem]);
			delete cloneNodeDict[cloneItem];
		}
		
	}

}
import alternativa.engine3d.objects.MeshSetClone;

class DynamicBVTree {
    public var root:DynamicBVTreeNode;
    
    public function DynamicBVTree() {
    }
    
    public function insertLeaf(leaf:DynamicBVTreeNode):void {
        if (root == null) {
            root = leaf;
            return;
        }
        var sibling:DynamicBVTreeNode = root;
        var aabb:AABB = new AABB();
        var oldArea:Number;
        var newArea:Number;
        while (sibling.proxy == null) { // descend the node to search the best pair
            oldArea = sibling.aabb.surfaceArea();
            aabb.combine(leaf.aabb, sibling.aabb);
            newArea = aabb.surfaceArea();
            var creatingCost:Number = newArea; // cost of creating a new pair with the node
            var incrementalCost:Number = newArea - oldArea;
            
            var discendingCost1:Number = incrementalCost;
            aabb.combine(leaf.aabb, sibling.child1.aabb);
            if (sibling.child1.proxy != null) {
                // leaf cost = area(combined aabb)
                discendingCost1 += aabb.surfaceArea();
            } else {
                // node cost = area(combined aabb) - area(old aabb)
                discendingCost1 += aabb.surfaceArea() - sibling.child1.aabb.surfaceArea();
            }
            
            var discendingCost2:Number = incrementalCost;
            aabb.combine(leaf.aabb, sibling.child2.aabb);
            if (sibling.child2.proxy != null) {
                // leaf cost = area(combined aabb)
                discendingCost2 += aabb.surfaceArea();
            } else {
                // node cost = area(combined aabb) - area(old aabb)
                discendingCost2 += aabb.surfaceArea() - sibling.child2.aabb.surfaceArea();
            }
            
            if (discendingCost1 < discendingCost2) {
                if (creatingCost < discendingCost1) {
                    break; // stop descending
                } else {
                    sibling = sibling.child1; // descend into first child
                }
            } else {
                if (creatingCost < discendingCost2) {
                    break; // stop descending
                } else {
                    sibling = sibling.child2; // descend into second child
                }
            }
        }
        var oldParent:DynamicBVTreeNode = sibling.parent;
        var newParent:DynamicBVTreeNode = new DynamicBVTreeNode();
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
        } else {
            // replace child
            if (oldParent.child1 == sibling) {
                oldParent.child1 = newParent;
            } else {
                oldParent.child2 = newParent;
            }
        }
        // update whole tree
        do {
            newParent = balance(newParent);
            fix(newParent);
            newParent = newParent.parent;
        } while (newParent != null);
    }
    
	/*
    public function print(node:DynamicBVTreeNode, indent:int, text:String):String {
        var hasChild:Boolean = node.proxy == null;
        if (hasChild) text = print(node.child1, indent + 1, text);
        for (var i:int = indent * 2; i >= 0; i--) {
            text += " ";
        }
        text += (hasChild ? getBalance(node) : "[" + node.proxy.id + "]") + "\n";
        if (hasChild) text = print(node.child2, indent + 1, text);
        return text;
    }
	*/
    
    public function deleteLeaf(leaf:DynamicBVTreeNode):void {
        if (leaf == root) {
            root = null;
            return;
        }
        var parent:DynamicBVTreeNode = leaf.parent;
        var sibling:DynamicBVTreeNode;
        if (parent.child1 == leaf) {
            sibling = parent.child2;
        } else {
            sibling = parent.child1;
        }
        if (parent == root) {
            root = sibling;
            sibling.parent = null;
            return;
        }
        var grandParent:DynamicBVTreeNode = parent.parent;
        sibling.parent = grandParent;
        if (grandParent.child1 == parent) {
            grandParent.child1 = sibling;
        } else {
            grandParent.child2 = sibling;
        }
        do {
            grandParent = balance(grandParent);
            fix(grandParent);
            grandParent = grandParent.parent;
        } while (grandParent != null);
    }
    
    private function getBalance(node:DynamicBVTreeNode):int {
        if (node.proxy != null) return 0;
        return node.child1.height - node.child2.height;
    }
    
    private function balance(node:DynamicBVTreeNode):DynamicBVTreeNode {
        var balance:int = getBalance(node);
        if (balance > 1) {
            if (getBalance(node.child1) < 0) {
                node.child1 = rotateLeft(node.child1);
            }
            return rotateRight(node);
        } else if (balance < -1) {
            if (getBalance(node.child2) > 0) {
                node.child2 = rotateRight(node.child2);
            }
            return rotateLeft(node);
        }
        return node;
    }
    
    private function fix(node:DynamicBVTreeNode):void {
        var c1:DynamicBVTreeNode = node.child1;
        var c2:DynamicBVTreeNode = node.child2;
        node.aabb.combine(c1.aabb, c2.aabb);
        var h1:int = c1.height;
        var h2:int = c2.height;
        if (h1 < h2) {
            node.height = h2 + 1;
        } else {
            node.height = h1 + 1;
        }
    }
    
    private function rotateRight(node:DynamicBVTreeNode):DynamicBVTreeNode {
        var p:DynamicBVTreeNode = node.parent;
        var l:DynamicBVTreeNode = node.child1;
        var lr:DynamicBVTreeNode = l.child2;
        (node.child1 = lr).parent = node;
        fix(node);
        ((l.child2 = node).parent = l).parent = p;
        fix(l);
        if (p != null) {
            if (p.child2 == node) {
                p.child2 = l;
            } else {
                p.child1 = l;
            }
            fix(p);
        } else root = l;
        return l;
    }
    
    private function rotateLeft(node:DynamicBVTreeNode):DynamicBVTreeNode {
        var p:DynamicBVTreeNode = node.parent;
        var r:DynamicBVTreeNode = node.child2;
        var rl:DynamicBVTreeNode = r.child1;
        (node.child2 = rl).parent = node;
        fix(node);
        ((r.child1 = node).parent = r).parent = p;
        fix(r);
        if (p != null) {
            if (p.child1 == node) {
                p.child1 = r;
            } else {
                p.child2 = r;
            }
            fix(p);
        } else root = r;
        return r;
    }
    
}
class DynamicBVTreeNode {
    public var child1:DynamicBVTreeNode;
    public var child2:DynamicBVTreeNode;
    public var parent:DynamicBVTreeNode;
    
    public var proxy:MeshSetClone;
    
    public var height:int;
	public var culling:int;
    
    public var aabb:AABB;
    
    public function DynamicBVTreeNode() {
        aabb = new AABB();
    }
    
}
class AABB {
    public var minX:Number;
    public var maxX:Number;
    public var minY:Number;
    public var maxY:Number;
	
	public var minZ:Number;
    public var maxZ:Number;
    
    public function AABB() {
       
    }
    
    public function combine(aabb1:AABB, aabb2:AABB):void {
        if (aabb1.minX < aabb2.minX) {
            minX = aabb1.minX;
        } else {
            minX = aabb2.minX;
        }
        if (aabb1.maxX > aabb2.maxX) {
            maxX = aabb1.maxX;
        } else {
            maxX = aabb2.maxX;
        }
        if (aabb1.minY < aabb2.minY) {
            minY = aabb1.minY;
        } else {
            minY = aabb2.minY;
        }
        if (aabb1.maxY > aabb2.maxY) {
            maxY = aabb1.maxY;
        } else {
            maxY = aabb2.maxY;
        }
        var margin:Number = 3;
        minX -= margin;
        maxX += margin;
        minY -= margin;
        maxY += margin;
    }
    
    public function surfaceArea():Number {
        return 2 * (maxX - minX + maxY - minY);
    }
    
    public function intersectsWithPoint(x:Number, y:Number, z:Number):Boolean {
        return x >= minX && x <= maxX && y >= minY && y <= maxY;
    }
    
}

