package util.geom;
import altern.collisions.CollisionBoundNode;
import components.BoundBox;
import components.Transform3D;

/**
 * To handle collision scene graph, geometries and transforms
 * @author Glidias
 */
#if alternExpose @:expose #end
class GeomCollisionSceneUtil 
{

	static var toRootTransform:Transform3D = new Transform3D();
	static var fromRootTransform:Transform3D = new Transform3D();
	/**
	 * @private
	 * Performs calculation of bound box of objects hierarchy branch.
	 */
	public static function calculateHierarchyBoundBox(object:CollisionBoundNode, boundBoxSpace:CollisionBoundNode = null, result:BoundBox = null):BoundBox {
		if (result == null) result = new BoundBox();

		if (boundBoxSpace != null && object != boundBoxSpace) {
			// Calculate transfer matrix from object to provided space.
			var objectRoot:CollisionBoundNode;
			var toSpaceTransform:Transform3D = null;

			toRootTransform.copy(object.transform);
			var root:CollisionBoundNode = object;
			while (root._parent != null) {
				root = root._parent;
				toRootTransform.append(root.transform);
				if (root == boundBoxSpace) {
					// Matrix has been composed.
					toSpaceTransform = toRootTransform;
				}
			}
			objectRoot = root;
			if (toSpaceTransform == null) {
				// Transfer matrix from root to needed space.
				fromRootTransform.copy(boundBoxSpace.inverseTransform);
				root = boundBoxSpace;
				while (root._parent != null) {
					root = root._parent;
					fromRootTransform.prepend(root.inverseTransform);
				}
				if (objectRoot == root) {
					toRootTransform.append(fromRootTransform);
					toSpaceTransform = toRootTransform;
				} else {
					throw "Object and boundBoxSpace must be located in the same hierarchy.";
				}
			}
			updateBoundBoxHierarchically(object, result, toSpaceTransform);
		} else {
			updateBoundBoxHierarchically(object, result);
		}
		return result;
	}
	
	public static function transformBounds(bounds:BoundBox, t:Transform3D):Void {
		var x:Float;
		var y:Float;
		var z:Float;
		
		x = bounds.minX;
		y = bounds.minY;
		z = bounds.minZ;
		bounds.minX = t.a * x + t.b * y + t.c * z + t.d;
		bounds.minY = t.e * x + t.f * y + t.g * z + t.h;
		bounds.minZ = t.i * x + t.j * y + t.k * z + t.l;
		
		x = bounds.maxX;
		y = bounds.maxY;
		z = bounds.maxZ;
		bounds.maxX = t.a * x + t.b * y + t.c * z + t.d;
		bounds.maxY  = t.e * x + t.f * y + t.g * z + t.h;
		bounds.maxZ = t.i * x + t.j * y + t.k * z + t.l;		
	}
	
	public static inline function updateBounds(boundBox:BoundBox, tBounds:BoundBox):Void {
		if (tBounds.minX < boundBox.minX) boundBox.minX = tBounds.minX;
		if (tBounds.maxX > boundBox.maxX) boundBox.maxX = tBounds.maxX;
		if (tBounds.minY < boundBox.minY) boundBox.minY = tBounds.minY;
		if (tBounds.maxY > boundBox.maxY) boundBox.maxY = tBounds.maxY;
		if (tBounds.minZ < boundBox.minZ) boundBox.minZ = tBounds.minZ;
		if (tBounds.maxZ > boundBox.maxZ) boundBox.maxZ = tBounds.maxZ;	
	}

	/**
	 * @private
	 * Calculates hierarchical bound.
	 */
	static function updateBoundBoxHierarchically(object:CollisionBoundNode, boundBox:BoundBox, transform:Transform3D = null):Void {
		if (object.boundBox != null) { // assumed boundBox of CollisionBoundNode already pre-transformed with it's transform
			updateBounds(boundBox, object.boundBox);
		}

		var child:CollisionBoundNode = object.childrenList;
		while (child != null) {
			child.localToGlobalTransform.copy(child.transform);
			if (transform != null) child.localToGlobalTransform.append(transform);
			updateBoundBoxHierarchically(child, boundBox, child.localToGlobalTransform);
			child = child.next;
		}
	}
}