package systems.player;
import alternativa.engine3d.core.Object3D;
import ash.core.Engine;
import ash.core.Node;
import ash.core.NodeList;
import ash.core.System;
import ash.signals.Signal0;
import ash.signals.Signal1;
import systems.collisions.Intersect3D;
import systems.player.PlayerTargetNode;
import util.geom.Vec3;

/**
 * This is for basic crosshair/mouse-rollover kind of targetting via raycasting, to get information of other entities.
 * @author Glenn Ko
 */
class PlayerTargetingSystem extends System
{

	private var nodeList:NodeList<PlayerTargetNode>;

	private var ray_travel:Vec3;
	private var ray_origin:Vec3;
	
	public static inline var MAX_VALUE:Float =  1.79e+308;
	
	private var lastHitObj:Object3D;
	
	public var targetChanged:Signal1<PlayerTargetNode>;
	
	private var targetRayOrigin:Vec3;
	
	public function new() 
	{
		super();
	
		ray_travel = new Vec3();
		ray_origin = new Vec3();
		
		targetRayOrigin = new Vec3();
		
		lastHitObj = null;
		
		targetChanged = new Signal1<PlayerTargetNode>();
	}
	
	
	override public function addToEngine(engine:Engine):Void {
		nodeList = engine.getNodeList(PlayerTargetNode);
		lastHitObj = null;
	}
	
	public function calculateRay():Void {  // hook method for exended classes
		
	}
	
	public function getEnv3DIntersectionTime():Float {
		return MAX_VALUE;
	}
	
	public function isValidTarget(n:PlayerTargetNode):Bool {
		return true;
	}
	
	override public function update(time:Float):Void {
		calculateRay();
		
		
		// we assume all entities are in the same coordinate space
		
		var n:PlayerTargetNode = nodeList.head;
		var nd:Float =  getEnv3DIntersectionTime();
		var hitNode:PlayerTargetNode = null;
		while (n != null) {
			if (!isValidTarget(n)) {
				n = n.next;
				continue;
			}
			
			targetRayOrigin.x = ray_origin.x - n.pos.x;
			targetRayOrigin.y = ray_origin.y - n.pos.y;
			targetRayOrigin.z = ray_origin.z - n.pos.z;
			
			var d:Float = Intersect3D.rayIntersectsEllipsoid(targetRayOrigin, ray_travel, n.ellipsoid);
			if (d >= 0 && d  < nd) {
				hitNode = n;
				nd = d;
			}
			n = n.next;
		}
		
		if (hitNode == null && lastHitObj != null) {
			targetChanged.dispatch(null);
			lastHitObj =null;
		}
		else if (hitNode != null && lastHitObj != hitNode.obj) {
			targetChanged.dispatch(hitNode);
			lastHitObj = hitNode.obj;
		}
		

		
	}
	
}

