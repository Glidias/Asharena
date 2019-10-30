package altern.collisions;
import altern.ray.IRaycastImpl;
import components.BoundBox;
import components.Transform3D;
import systems.collisions.EllipsoidCollider;
import systems.collisions.IECollidable;
import systems.collisions.ITCollidable;
import util.geom.AABBUtils;
import util.TypeDefs;

/**
 * A CollisionBoundNode can be formed as part of a hierachial transformed (optional)OOBB tree of nodes, and can contain
 * optional collidable/raycasting implementations within each node. Useful to set up any collision/raycastable scene graph accordingly.
 * @author Glidias
 */
class CollisionBoundNode implements IECollidable
{
	public var childrenList:CollisionBoundNode;
	public var next:CollisionBoundNode;
	public var _parent:CollisionBoundNode;
	
	public var transform:Transform3D;
	public var inverseTransform:Transform3D;
	public var localToGlobalTransform:Transform3D;
	public var globalToLocalTransform:Transform3D;	
	public function calculateLocalGlobalTransforms():Void { // temporary
		calculateLocalToGlobal2(this, localToGlobalTransform);
		globalToLocalTransform.calculateInversion(localToGlobalTransform);
	}
	
	// optional assignables
	public var collidable:ITCollidable;
	public var raycastable:IRaycastImpl;
	public var boundBox:BoundBox;  // sized to match all union of all descendents as well
	
	// optional transform precompute assignables (needed for some utilities). 
	// Call calculateLocalWorldTransforms() once placed in final scene graph.
	public var localToWorldTransform:Transform3D;
	public var worldToLocalTransform:Transform3D;
	
	public function calculateLocalWorldTransforms():Void {	// permanent
		if (worldToLocalTransform == null) worldToLocalTransform = new Transform3D();
		if (localToWorldTransform == null) localToWorldTransform = new Transform3D();
		
		calculateLocalToGlobal2(this, localToWorldTransform);
		//calculateGlobalToLocal2(this, worldToLocalTransform);
		worldToLocalTransform.calculateInversion(localToWorldTransform);
	}
	
	
	public static inline function calculateLocalToGlobal2(obj:CollisionBoundNode, trm:Transform3D=null):Transform3D {
		trm = trm != null ? trm : new Transform3D();
		trm.copy(obj.transform);
		var root:CollisionBoundNode = obj;
		while (root._parent != null) {
			root = root._parent;
			trm.append(root.transform);
		}
		return trm;
	}
	
		
	public static inline function calculateGlobalToLocal2(obj:CollisionBoundNode, trm:Transform3D=null):Transform3D {
		trm = trm != null ? trm : new Transform3D();
		trm.copy(obj.inverseTransform);
		var root:CollisionBoundNode = obj;
		while (root._parent != null) {
			root = root._parent;
			trm.prepend(root.inverseTransform);
		}
		return trm;
	}
	
		
	function new() 
	{
		
	}
	
	/**
	 * Creates a mirror clone of the current collision bound node and all it's descendents 
	 * (ie. cloning the entire hierachy). Bounding boxes/local transforms/addons are shared between mirror clones except for the
	 * hierachy itself and localToGlobalTransform/globalToLocalTransform caches.
	 * @return
	 */
	public function mirrorClone():CollisionBoundNode {
		var c:CollisionBoundNode = CollisionBoundNode.create(transform, inverseTransform);
		c.collidable = collidable;
		c.boundBox = boundBox;
		c.raycastable = raycastable;
		
		var child:CollisionBoundNode = childrenList;
		var lastChild:CollisionBoundNode = null;
		while ( child != null) {
			var newChild:CollisionBoundNode = child.mirrorClone();
			if (c.childrenList != null) {
				lastChild.next = newChild;
			} else {
				c.childrenList = newChild;
			}
			lastChild = newChild;
			newChild._parent = c;
			child = child.next;
		}
		return c;
	}
	
	/**
	 * Creates a brand new minimal CollisionBoundNode instance with an already (assumed usually precalculated) transform instance and an optional (assumed already precalculated)  inverseTransform instance.
	 * @param	transform	The  (usually precalculated) transform to assign
	 * @param	inverseTransform	(optoinal) The precalculated inverseTransform to assign
	 * @return
	 */
	public static function create(transform:Transform3D, inverseTransform:Transform3D=null):CollisionBoundNode {
		var n:CollisionBoundNode = new CollisionBoundNode();
		n.transform = transform;
		if (inverseTransform == null) {
			n.inverseTransform =  new Transform3D();
			n.inverseTransform.calculateInversion(n.transform);
		}
		else {
			n.inverseTransform = inverseTransform;
		}
		
		// boilerplate instantaite
		n.localToGlobalTransform = new Transform3D();
		n.globalToLocalTransform = new Transform3D();
		return n;
	}
	
	public static function createNew(transform:Transform3D = null, inverseTransform:Transform3D = null, collidable:ITCollidable = null, raycastable:IRaycastImpl = null):CollisionBoundNode {
		var n = CollisionBoundNode.create(transform != null ? transform : new Transform3D(), inverseTransform);
		n.collidable = collidable;
		n.raycastable = raycastable != null ? raycastable : Std.is(collidable, IRaycastImpl) ? cast collidable : null;
		return n;
	}
	
	/**
	 * Updates current transform with a reference transform
	 * @param	refTransform	The reference transform to match
	 */
	public function updateTransform(refTransform:Transform3D):Void {
		transform.copy(refTransform);
		inverseTransform.calculateInversion(transform);
	}
	
		
	/* INTERFACE systems.collisions.IECollidable */	
	
	public function collectGeometry(collider:EllipsoidCollider):Void 
	{
		//if (!object.visible) return;
		
		//var intersects:Bool = true;
		globalToLocalTransform.combine(inverseTransform, collider.matrix);
		collider.calculateSphere(globalToLocalTransform);
		//if (boundBox != null) {
			
		
		//	intersects = AABBUtils.checkSphere(boundBox, collider.sphere);// boundBox.checkSphere(collider.sphere);  
		//}
		//if (!intersects) return;
		

		// parent's localToGlobalTransofrm, child.transform
		localToGlobalTransform.combine(collider.inverseMatrix, transform); 
			
		if (collidable != null) collidable.collectGeometryAndTransforms(collider, localToGlobalTransform);
		if (childrenList != null) visitChildren(collider);
	}
	
	
	/* INTERFACE altern.ray.IRaycastImpl */
	public function intersectRay(origin:Vector3D, direction:Vector3D, output:Vector3D):Vector3D 
	{
		
		var minData:Vector3D = raycastable!= null ? raycastable.intersectRay(origin, direction, output) : null;
		var minTime:Float = minData != null ? minData.w  : output.w != 0 ? output.w : direction.w != 0 ? direction.w : 1e22; 
		
		var childOrigin:Vector3D = null;
		var childDirection:Vector3D = null;
		var child:CollisionBoundNode = childrenList;
		while (child != null) {
			if (childOrigin == null) {
				childOrigin = new Vector3D();
				childDirection = new Vector3D();
			}
			childOrigin.x = child.inverseTransform.a*origin.x + child.inverseTransform.b*origin.y + child.inverseTransform.c*origin.z + child.inverseTransform.d;
			childOrigin.y = child.inverseTransform.e*origin.x + child.inverseTransform.f*origin.y + child.inverseTransform.g*origin.z + child.inverseTransform.h;
			childOrigin.z = child.inverseTransform.i*origin.x + child.inverseTransform.j*origin.y + child.inverseTransform.k*origin.z + child.inverseTransform.l;
			childDirection.x = child.inverseTransform.a*direction.x + child.inverseTransform.b*direction.y + child.inverseTransform.c*direction.z;
			childDirection.y = child.inverseTransform.e*direction.x + child.inverseTransform.f*direction.y + child.inverseTransform.g*direction.z;
			childDirection.z = child.inverseTransform.i * direction.x + child.inverseTransform.j * direction.y + child.inverseTransform.k * direction.z;
			childDirection.w = direction.w != 0 ? (childDirection.length / direction.length) * direction.w : 1e22;
			if (child.boundBox != null && !AABBUtils.intersectRay(child.boundBox, childOrigin, childDirection) ) {
				child = child.next;
				continue;
			}
			var data:Vector3D =  child.intersectRay(childOrigin, childDirection, output);
			if (data != null && data.w < minTime) {
				minTime = data.w;
				minData = data;
			}
			
			child = child.next;
		}
		return minData;
	}
		
	
	///*  // inlinable visitor/visitor-succeeded method
	
	//	public var debug:Boolean = false;
	//public var debugCount:int = 0;
	function visitChildren(collider:EllipsoidCollider):Void {
		var child:CollisionBoundNode = childrenList;
		while ( child != null) {		
			//if (!child.object.visible) continue;
			// Calculating matrix for converting from collider coordinates to local coordinates
			child.globalToLocalTransform.combine(child.inverseTransform, globalToLocalTransform);
			// Check boundbox intersecting
			var intersects:Bool = true;
			collider.calculateSphere(child.globalToLocalTransform);
			if (child.boundBox != null) {
				
				intersects = AABBUtils.checkSphere(child.boundBox, collider.sphere); // child.boundBox.checkSphere(collider.sphere);
			}
			
			// Adding the geometry of self content
			if (intersects) {
				// Calculating matrix for converting from local coordinates to callider coordinates
				child.localToGlobalTransform.combine(localToGlobalTransform, child.transform);
				if (child.collidable != null) child.collidable.collectGeometryAndTransforms(collider, child.localToGlobalTransform);
				if (child.childrenList != null) child.visitChildren(collider);		
				
			}
			//if (debug) Log.trace("intersects?" + intersects + ", "+(debugCount++));
			// Check for children
			child = child.next;
		}
	}
	
		
			// -- borrowed from alternativa3d below
	

		public function addChild(child:CollisionBoundNode):CollisionBoundNode {
		// Error checking
		if (child == null) throw "Parameter child must be non-null.";
		if (child == this) throw "An object cannot be added as a child of itself.";
		var container:CollisionBoundNode = _parent; 
		while (container != null) {
			if (container == child) throw "An object cannot be added as a child to one of it's children (or children's children, etc.).";
			container = container._parent;
		}
		// Adding
		if (child._parent != this) {
		// Removing from old place
		if (child._parent != null) child._parent.removeChild(child);
		// Adding
		addToList(child);
		child._parent = this;
		// Dispatching the event
		} else {
			child = removeFromList(child);
			if (child == null) throw "Cannot add child.";
			// Adding
			addToList(child);
			}
		return child;
		}
		
		public function removeChild(child:CollisionBoundNode):CollisionBoundNode {
		// Error checking
		if (child == null) throw "Parameter child must be non-null.";
		if (child._parent != this) throw "The supplied CollisionBoundNode must be a child of the caller.";
		child = removeFromList(child);
		if (child == null) throw "Cannot remove child.";
		// Dispatching the event
		child._parent = null;
		return child;
		}
		

		
		private function addToList(child:CollisionBoundNode, item:CollisionBoundNode = null):Void {
		child.next = item;
		if (item == childrenList) {
		childrenList = child;
		} else {
		var current:CollisionBoundNode = childrenList;
		while ( current != null) {
		if (current.next == item) {
		current.next = child;
		break;
		}
		current = current.next;
		}
		}
		}

		/**
		* @private
		*/
		function removeFromList(child:CollisionBoundNode):CollisionBoundNode {
		var prev:CollisionBoundNode = null;
		var current:CollisionBoundNode = childrenList;
		while ( current != null) {
		if (current == child) {
		if (prev != null) {
		prev.next = current.next;
		} else {
		childrenList = current.next;
		}
		current.next = null;
		return child;
		}
		prev = current;
		current = current.next;
		}
		return null;
		}



		function _prepend(child:CollisionBoundNode):Void {
			child.next = childrenList;
			childrenList = child;
			child._parent = this;
		}
		
		function _removeHead():Void {
			var removed:CollisionBoundNode = childrenList;
			if (removed != null) childrenList =  removed.next;
			removed._parent = null;
		}

	
	
}