package systems.collisions;
import ash.core.Engine;
import ash.core.Node;
import ash.core.NodeList;
import ash.core.System;
import components.Ellipsoid;
import components.MoveResult;
import components.Pos;
import components.Transform3D;
import components.Vel;
import jeash.geom.Vector3D;

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
	public var collidable:IECollidable;
	
	private var nodeList:NodeList<EllipsoidNode>;
	
	private var pos:Vector3D;
	private var disp:Vector3D;

	public function new(collidable:IECollidable, threshold:Float=0.001) 
	{
		super();
		_collider =  new EllipsoidCollider(0, 0, 0, threshold);
		this.collidable = collidable;
		
		
		pos = new Vector3D();
		disp = new Vector3D();
	}

	public inline function setThreshold(val:Float):Void {
		_collider.threshold = val;
	}
	
	override public function addToEngine(engine:Engine):Void
    {
		nodeList = engine.getNodeList(EllipsoidNode);
    }
	
	override public function update(time:Float):Void
    {
		var n:EllipsoidNode = nodeList.head;
		var result:MoveResult;
		while (n != null) {
			result = n.result;
			
			
			_collider.radiusX = n.ellipsoid.x;
			_collider.radiusY = n.ellipsoid.y;
			_collider.radiusZ = n.ellipsoid.z;
			
			pos.x = n.pos.x;
			pos.y = n.pos.y;
			pos.z = n.pos.z;
			
			disp.x = n.vel.x * time;
			disp.y = n.vel.y * time;
			disp.z = n.vel.z * time;
			
			var vec:Vector3D =  _collider.calculateDestination(pos, disp, collidable);
			result.x = vec.x;
			result.y = vec.y;
			result.z = vec.z;
			n.pos.x  = result.x;
				n.pos.y = result.y;
				n.pos.z =  result.z;
			//	/*
			result.collisions = _collider.collisions;
			
			if (result.collisions != null) {
				result.x  =result.collisions.pos.x;
				result.y  =result.collisions.pos.y;
				result.z  = result.collisions.pos.z;
				n.pos.x = result.x;
				n.pos.y = result.y;
				n.pos.z = result.z;
				//trace( );
				trace("A:"+result.collisions.normal.x + ", "+result.collisions.normal.y + ", "+result.collisions.normal.z + "::: "+result.collisions.getNumEvents());
			}
			//*/
			
			_collider.collisions = null;
			
			n = n.next;
		}
    }
	
}

class EllipsoidNode extends Node<EllipsoidNode> {  // For positioned nodes without transform
	public var ellipsoid:Ellipsoid;
	public var vel:Vel;
	public var pos:Pos;
	public var result:MoveResult;
}