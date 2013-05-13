package systems.collisions;
import ash.core.Node;
import ash.core.System;
import components.Ellipsoid;
import components.MoveResult;
import components.Pos;
import components.Transform3D;
import components.Vel;

/**
 * Calculates move results of all relavant collidable entities against static environment.
 * 
 * Would probably also include dynamic  EllipsoidDyn componetns as well for resolving collisions between dynamic entities as well.
 * 
 * @author Glenn Ko
 */
class EllipsoidColliderSystem extends System
{
	private var _collider:EllipsoidCollider;
	private var _collidable:IECollidable;

	public function new(collidable:IECollidable, threshold:Float=0.001) 
	{
		_collider =  new EllipsoidCollider(0, 0, 0, threshold);
		_collidable = collidable;
	}
	
}

class EllipsoidNode extends Node<EllipsoidNode> {  // For positioned nodes without transform
	public var ellipsoid:Ellipsoid;
	public var vel:Vel;
	public var pos:Pos;
	public var result:MoveResult;
}