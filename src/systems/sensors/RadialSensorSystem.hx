package systems.sensors;
import ash.core.Engine;
import ash.core.Node;
import ash.core.NodeList;
import ash.core.System;
import ash.signals.Signal1;
import components.Ellipsoid;
import components.EllipsoidDyn;
import components.EllipsoidSignal;
import components.Pos;
import flash.globalization.NumberFormatter;
import util.geom.Vec3;

/**
 * ...
 * @author Glenn Ko
 */
class RadialSensorSystem extends System
{

	private var nodeList:NodeList<RadialSensorNode>;
	
	public var playerPos:Pos;
	private var playerEllipsoid:Ellipsoid;
	//public var playerMask:UInt;  // to specifically ignore certain stuff
	
	public function new() 
	{
		super();
	//	playerMask = 0;
		setPlayerEllipsoid(  new Ellipsoid() );
		playerPos = new Pos();

	}
	
	public function setPlayerEllipsoid(ellipsoid:Ellipsoid):Void {
		playerEllipsoid = ellipsoid;
		
	}
	
	
	override public function addToEngine(engine:Engine):Void {
		nodeList = engine.getNodeList(RadialSensorNode);
	}
	
	override public function update(time:Float):Void {
		var n:RadialSensorNode = nodeList.head;
		while (n != null) {
			var other:EllipsoidSignal = n.ellipsoid;
			var otherPos:Pos = n.pos;
			
			
		
			var rx:Float = playerEllipsoid.x + other.x;
            var ry:Float = playerEllipsoid.y + other.y;
			var rz:Float = playerEllipsoid.z + other.z;
            var pRadius:Float = rx > ry ? rx :ry;
            var prScaleX:Float =  pRadius / rx;
            var prScaleY:Float =  pRadius / ry;
			var prScaleZ:Float =  pRadius / rz;
            
            // check if overlap
            var dx:Float = otherPos.x - playerPos.x;
            var dy:Float = otherPos.y -  playerPos.y; 
			var dz:Float = otherPos.z -  playerPos.z;
            dx *= prScaleX;
            dy *= prScaleY;
			dz *= prScaleZ;
      
            if (dx * dx + dy * dy + dz*dz <= pRadius*pRadius) {
				other.signal.dispatch(n.entity);
            }
            //else {
				
			//}
			
		//
			
			n = n.next;
		}
	}
	
}

class RadialSensorNode extends Node<RadialSensorNode> {
	public var ellipsoid:EllipsoidSignal;
	public var pos:Pos;
}