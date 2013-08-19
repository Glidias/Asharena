package systems.collisions;
import ash.core.Engine;
import ash.core.Node;
import ash.core.NodeList;
import ash.core.System;
import components.CollisionResult;
import components.Ellipsoid;
import components.Pos;
import components.Vel;

/**
 * ...
 * @author Glenn Ko
 */
class GroundPlaneCollisionSystem extends System
{

	private var nodeList:NodeList<CollidableNode>;
	private var groundLevel:Float;
	private var passive:Bool;
	
	public function new(groundLevel:Float=0, passive:Bool=false) 
	{
		super();
		this.passive = passive;
		this.groundLevel = groundLevel;
	}
	
	
	override public function addToEngine(engine:Engine):Void {
		nodeList = engine.getNodeList(CollidableNode);
	}
	
	override public function update(time:Float):Void {
		var n:CollidableNode = nodeList.head;
		while (n != null) {
			var bottom:Float = n.pos.z - n.ellipsoid.z;
			if (bottom <= groundLevel - .001) {
				n.pos.z = groundLevel + n.ellipsoid.z;
				n.result.gotGroundNormal = true;
				n.result.maximum_ground_normal.set(0, 0, 1);
				//trace( "on ground");
				
				n.vel.z = 0;
				
			}
			else {
				if (!passive) n.result.gotGroundNormal = false;
				//trace( "in air");
				
			}
			n = n.next;
		}
	}
	
}

class CollidableNode extends Node<CollidableNode> {
	public var result:CollisionResult;
	public var ellipsoid:Ellipsoid;
	public var pos:Pos;
	public var vel:Vel;
}