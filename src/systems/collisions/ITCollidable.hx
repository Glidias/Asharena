package systems.collisions;
import components.Transform3D;

/**
 * ...
 * @author Glenn Ko
 */
interface ITCollidable
{
	function collectGeometryAndTransforms(collider:EllipsoidCollider, baseTransform:Transform3D):Void;
}