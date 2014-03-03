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
import input.KeyPoll;
import util.TypeDefs;

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
		_collider =  new EllipsoidCollider(0, 0, 0, threshold, true);
		this.collidable = collidable;
		
		
		pos = new Vector3D();
		disp = new Vector3D();
	}

	
	
	override public function addToEngine(engine:Engine):Void
    {
		nodeList = engine.getNodeList(EllipsoidNode);
    }
	
	private var lastPos:Vector3D;
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
			if (lastPos != null) {
				
				n = n.next;
				continue;
			}
			var vec:Vector3D =  _collider.calculateDestination(pos, disp, collidable);
			
			
			
			result.x = vec.x;
			result.y = vec.y;
			result.z = vec.z;
			
			
			result.collisions = _collider.collisions;

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