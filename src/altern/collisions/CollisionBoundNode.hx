package altern.collisions;
import components.BoundBox;
import components.Transform3D;
import systems.collisions.EllipsoidCollider;
import systems.collisions.IECollidable;
import systems.collisions.ITCollidable;
import util.geom.AABBUtils;

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
	
	// optional assignables
	public var collidable:ITCollidable;
	public var boundBox:BoundBox;  
		
	function new() 
	{
		
	}
	
	/**
	 * Creates a brand new minimal CollisionBoundNode instance with an already (assumed usually precalculated) transform instance and an optional (assumed already precalculated)  inverseTransform instance.
	 * @param	transform	The  (usually precalculated) transform to assign
	 * @param	inverseTransform	(optoinal) The precalculated inverseTransform to assign
	 * @return
	 */
	public static inline function create(transform:Transform3D, inverseTransform:Transform3D=null):CollisionBoundNode {
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
		
		var intersects:Bool = true;
		globalToLocalTransform.combine(inverseTransform, collider.matrix);
		if (boundBox != null) {
			
			collider.calculateSphere(globalToLocalTransform);
			intersects = AABBUtils.checkSphere(boundBox, collider.sphere);// boundBox.checkSphere(collider.sphere);  
		}
		if (!intersects) return;
		

		// parent's localToGlobalTransofrm, child.transform
		localToGlobalTransform.combine(collider.inverseMatrix, transform); 
			
		if (collidable != null) collidable.collectGeometryAndTransforms(collider, localToGlobalTransform);
		if (childrenList != null) visitChildren(collider);
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
			if (child.boundBox != null) {
				collider.calculateSphere(child.globalToLocalTransform);
				intersects = AABBUtils.checkSphere(boundBox, collider.sphere); // child.boundBox.checkSphere(collider.sphere);
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