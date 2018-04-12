package alternativa.a3d.collisions 
{
	import altern.ray.IRaycastImpl;
	import alternativa.engine3d.core.BoundBox;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.objects.Mesh;
	import components.Transform3D;
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;
	import haxe.Log;
//	import haxe.Log;
	import systems.collisions.EllipsoidCollider;
	import systems.collisions.IECollidable;
	import alternativa.engine3d.alternativa3d;
	import systems.collisions.ITCollidable;
	use namespace alternativa3d;

	/**
	 * A 3d collision graph node, to support hierachical bounding volumes of arbituary ITCollidable instances!
	 * @author Glenn Ko
	 */
	public class CollisionBoundNode implements IECollidable, IRaycastImpl
	{

		alternativa3d var childrenList:CollisionBoundNode;
		alternativa3d var next:CollisionBoundNode;
		alternativa3d var _parent:CollisionBoundNode;
		
		alternativa3d var transform:Transform3D;
		alternativa3d var inverseTransform:Transform3D;
		alternativa3d var localToGlobalTransform:Transform3D;
		alternativa3d var globalToLocalTransform:Transform3D;
		alternativa3d var collidable:ITCollidable;
		alternativa3d var raycastable:IRaycastImpl;
		
		alternativa3d var boundBox:BoundBox;  
		//alternativa3d var object:Object3D; //Alternativa3d debugging
		public static var PADD:Number = 2;
		
		public function CollisionBoundNode() 
		{
			transform = new Transform3D();
			inverseTransform = new Transform3D();
			localToGlobalTransform = new Transform3D();
			globalToLocalTransform = new Transform3D();
		}
		
		public function updateTransform(x:Number = 0, y:Number = 0, z:Number = 0, rotationX:Number=0, rotationY:Number=0, rotationZ:Number=0, scaleX:Number = 1, scaleY:Number = 1, scaleZ:Number = 1):void {
			transform.compose(x, y, z, rotationX, rotationY, rotationZ, scaleX, scaleY, scaleZ);
			inverseTransform.calculateInversion(transform);
		}
		
		
		// -- Alternativa3D-specific Object3D setups
		
		/*
		public function validate(root:Object3D):void {
			if ( root != object) throw new Error("SHould not be!!!:" + [object, root]);
			var r:Object3D = root.childrenList;
			for (var c:CollisionBoundNode = childrenList; c != null; c = c.next) {
				if (c.object != r) throw new Error("WRONG!:"+[c.object,r]);
				
				if (c.object.childrenList != r.childrenList) throw new Error("WROG22N"+[c.object.childrenList,r.childrenList] );
				if (c.childrenList) c.childrenList.validate(r.childrenList);
				r = r.next;
			}
		}
		*/
		

		
		alternativa3d function setup(object:Object3D, collidable:ITCollidable, raycastable:IRaycastImpl=null):CollisionBoundNode {
			//this.object = object; // Alternativa3d debugging

			boundBox =  object.boundBox;
		//	/*
			if (boundBox != null && PADD!=0) {
				boundBox = boundBox.clone();
				var padd:Number = PADD;  // conservative padd just in case...
				boundBox.minX -= padd;
				boundBox.minY -= padd;
				boundBox.minZ -= padd;
				
				boundBox.maxX += padd;
				boundBox.maxY += padd;
				boundBox.maxZ += padd;
			}
			//*/
			if (object.transformChanged) {
				object.composeTransforms();
			}
			transform.a = object.transform.a; 
			transform.b = object.transform.b;
			transform.c = object.transform.c;
			transform.d = object.transform.d;
			transform.e = object.transform.e;
			transform.f = object.transform.f;
			transform.g = object.transform.g;
			transform.h = object.transform.h;
			transform.i = object.transform.i;
			transform.j = object.transform.j;
			transform.k = object.transform.k;
			transform.l = object.transform.l;
			
			inverseTransform.a = object.inverseTransform.a; 
			inverseTransform.b = object.inverseTransform.b;
			inverseTransform.c = object.inverseTransform.c;
			inverseTransform.d = object.inverseTransform.d;
			inverseTransform.e = object.inverseTransform.e;
			inverseTransform.f = object.inverseTransform.f;
			inverseTransform.g = object.inverseTransform.g;
			inverseTransform.h = object.inverseTransform.h;
			inverseTransform.i = object.inverseTransform.i;
			inverseTransform.j = object.inverseTransform.j;
			inverseTransform.k = object.inverseTransform.k;
			inverseTransform.l = object.inverseTransform.l;
			//transform.compose(object._x, object._y, object._z, object._rotationX, object._rotationY, object._rotationZ, object._scaleX, object._scaleY, object._scaleZ);
			//inverseTransform.calculateInversion(transform);
			this.collidable = collidable;
			this.raycastable = collidable as IRaycastImpl;
			return this;
			
		}
		
				
		/* INTERFACE altern.ray.IRaycastImpl */
		
		public function intersectRay(origin:Vector3D, direction:Vector3D, output:Vector3D):Vector3D 
		{
			
			var minData:Vector3D = raycastable != null ? raycastable.intersectRay(origin, direction, output) : null;
			var minTime:Number = minData != null ? minData.w  : output.w != 0 ? output.w : direction.w != 0 ? direction.w : 1e22; 
			
			var childOrigin:Vector3D;
			var childDirection:Vector3D;
			for (var child:CollisionBoundNode = childrenList; child != null; child = child.next) {
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
				childDirection.w = minTime;
				var data:Vector3D = child.intersectRay(childOrigin, childDirection, output);
				if (data != null && data.w < minTime) {
					minTime = data.w;
					minData = data;
				}
			}
			return minData;
		}
		
		
		
		alternativa3d function setupChildren(obj:Object3D, factoryMethodHash:Dictionary):void {
			
			var startChild:Object3D = obj.childrenList;
			while (startChild!=null && !startChild.visible) {
				startChild = startChild.next;
			}
			if (startChild == null) return;
			
			childrenList = new CollisionBoundNode();
			childrenList._parent = this;
			var classe:Class = Object(startChild).constructor;

			childrenList.setup( startChild, factoryMethodHash[classe] ? factoryMethodHash[classe](startChild) : startChild is Mesh ? factoryMethodHash[Mesh](startChild) :  null);
			
				
			if (startChild.childrenList) childrenList.setupChildren(startChild, factoryMethodHash);
		
			
			var tail:CollisionBoundNode = childrenList;
			
			startChild = startChild.next;
			
			
			for (var c:Object3D = startChild; c != null; c = c.next) {
				if (!c.visible) {
					continue;
				}
				var me:CollisionBoundNode = new CollisionBoundNode();
				classe = Object(c).constructor;
				me.setup(c, factoryMethodHash[classe] ? factoryMethodHash[classe](c) : c is Mesh ? factoryMethodHash[Mesh](c) : null);	
				me._parent = this;
				if (c.childrenList) me.setupChildren(c, factoryMethodHash);
				tail.next = me;
				tail = me;
			}
		}
		
		
		/* INTERFACE systems.collisions.IECollidable */	
		public function collectGeometry(collider:EllipsoidCollider):void 
		{
			//if (!object.visible) return;
			
			var intersects:Boolean = true;
			globalToLocalTransform.combine(inverseTransform, collider.matrix);
			if (boundBox != null) {
				
				collider.calculateSphere(globalToLocalTransform);
				intersects = boundBox.checkSphere(collider.sphere);  
			}
			if (!intersects) return;
			

			// parent's localToGlobalTransofrm, child.transform
			localToGlobalTransform.combine(collider.inverseMatrix, transform); 
				
			if (collidable) collidable.collectGeometryAndTransforms(collider, localToGlobalTransform);
			if (childrenList != null) visitChildren(collider);
		}
		
		
		///*  // inlinable visitor/visitor-succeeded method
		
		//	public var debug:Boolean = false;
		//public var debugCount:int = 0;
		alternativa3d function visitChildren(collider:EllipsoidCollider):void {
			for (var child:CollisionBoundNode = childrenList; child != null; child = child.next) {		
				//if (!child.object.visible) continue;
				// Calculating matrix for converting from collider coordinates to local coordinates
				child.globalToLocalTransform.combine(child.inverseTransform, globalToLocalTransform);
				// Check boundbox intersecting
				var intersects:Boolean = true;
				if (child.boundBox != null) {
					collider.calculateSphere(child.globalToLocalTransform);
					intersects = child.boundBox.checkSphere(collider.sphere);
				}
				
				// Adding the geometry of self content
				if (intersects) {
					// Calculating matrix for converting from local coordinates to callider coordinates
					child.localToGlobalTransform.combine(localToGlobalTransform, child.transform);
					if (child.collidable) child.collidable.collectGeometryAndTransforms(collider, child.localToGlobalTransform);
					if (child.childrenList != null) child.visitChildren(collider);		
					
				}
				//if (debug) Log.trace("intersects?" + intersects + ", "+(debugCount++));
				// Check for children
				
			}
		}

		//*/
		
		
		
		// -- borrowed from alternativa3d below
		

			public function addChild(child:CollisionBoundNode):CollisionBoundNode {
			// Error checking
			if (child == null) throw new TypeError("Parameter child must be non-null.");
			if (child == this) throw new ArgumentError("An object cannot be added as a child of itself.");
			for (var container:CollisionBoundNode = _parent; container != null; container = container._parent) {
			if (container == child) throw new ArgumentError("An object cannot be added as a child to one of it's children (or children's children, etc.).");
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
				if (child == null) throw new ArgumentError("Cannot add child.");
				// Adding
				addToList(child);
				}
			return child;
			}
			
				public function removeChild(child:CollisionBoundNode):CollisionBoundNode {
			// Error checking
			if (child == null) throw new TypeError("Parameter child must be non-null.");
			if (child._parent != this) throw new ArgumentError("The supplied CollisionBoundNode must be a child of the caller.");
			child = removeFromList(child);
			if (child == null) throw new ArgumentError("Cannot remove child.");
			// Dispatching the event
			child._parent = null;
			return child;
			}
			


			
				private function addToList(child:CollisionBoundNode, item:CollisionBoundNode = null):void {
			child.next = item;
			if (item == childrenList) {
			childrenList = child;
			} else {
			for (var current:CollisionBoundNode = childrenList; current != null; current = current.next) {
			if (current.next == item) {
			current.next = child;
			break;
			}
			}
			}
			}

			/**
			* @private
			*/
			alternativa3d function removeFromList(child:CollisionBoundNode):CollisionBoundNode {
			var prev:CollisionBoundNode;
			for (var current:CollisionBoundNode = childrenList; current != null; current = current.next) {
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
			}
			return null;
			}



			alternativa3d function _prepend(child:CollisionBoundNode):void {
				child.next = childrenList;
				childrenList = child;
				child._parent = this;
			}
			
			alternativa3d function _removeHead():void {
				var removed:CollisionBoundNode = childrenList;
				if (removed != null) childrenList =  removed.next;
				removed._parent = null;
			}
		
		
		
	}

}