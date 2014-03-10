package systems.sensors;
import ash.core.Engine;
import ash.core.Entity;
import ash.core.Node;
import ash.core.NodeList;
import ash.core.System;
import ash.core.System;
import ash.signals.Signal0;
import ash.signals.Signal3;
import components.Health;

/**
 * ...
 * @author Glenn Ko
 */
class HealthTrackingSystem extends System
{

	private var nodeList:NodeList<HealthNode>;
	public static var SIGNAL_MURDER:Signal3<Entity,Int,Int> = new Signal3<Entity,Int,Int>();
	public static var SIGNAL_DAMAGE:Signal3<Entity,Int,Int> = new Signal3<Entity,Int,Int>();
	
	public function new() 
	{
		super();
	}
	
	
	override public function addToEngine(engine:Engine):Void {
		nodeList = engine.getNodeList(HealthNode);
		nodeList.nodeAdded.add(onNodeAdded);
		//nodeList.nodeRemoved.add(onNodeRemoved);   NON-NAIVE NODE ADDED
	}
	
	/*
	function onNodeRemoved(node:Node<HealthNode>) 
	{
		//node.health;
		//node.entity.
		var tracker:HealthTracker =  node.entity.get(HealthTracker);
	tracker.dispose();
		
		node.entity.remove(HealthTracker );
		
	}
	
	function onNodeAdded(node:Node<HealthNode>) 
	{
		var tracker:HealthTracker =  new HealthTracker();
		tracker.init(node.entity);
		node.entity.add(tracker, HealthTracker );
	}
	*/
	

	// NAIVE NODE ADDED
	///*
	function onNodeAdded(node:Node<HealthNode>) 
	{
		var tracker:HealthTracker =  new HealthTracker();
		tracker.init(node.entity);
		
	}
	//*/
	
	
	
	// not being used..
	override public function update(time:Float):Void {
		
	}
	
}

class HealthNode extends Node<HealthNode> {
	public var health:Health;
}


class HealthTracker {
	public var health:Health;
	public var entity:Entity;
	
	
	public function new() {
		
		
	}
	
	public inline function init(e:Entity):Void {
		entity = e;
		health = e.get(Health);
		health.onDamaged.add(onDamaged);
		health.onMurdered.add(onMurdered);
	//	throw "WRW";
	}
	
	public inline function dispose() 
	{
		health.onMurdered.remove(onMurdered);
		health.onDamaged.remove(onDamaged);
	//	health = null;
	//	entity = null;
	}
	
	private function onMurdered(val:Int, val2:Int):Void 
	{
		HealthTrackingSystem.SIGNAL_MURDER.dispatch(entity, val, val2);
	}
	
	private function onDamaged(val:Int, val2:Int):Void 
	{
		HealthTrackingSystem.SIGNAL_DAMAGE.dispatch(entity, val, val2);
	}
	
}