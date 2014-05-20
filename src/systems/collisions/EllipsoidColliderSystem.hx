package systems.collisions;
import ash.core.Engine;
import ash.core.Entity;
import ash.core.Node;
import ash.core.NodeList;
import ash.core.System;
import components.CollisionResult;
import components.Ellipsoid;
import components.ImmovableCollidable;
import components.MovableCollidable;
import components.MoveResult;
import components.Pos;
import components.Transform3D;
import components.Vel;
import flash.errors.Error;
import flash.geom.Vector3D;
import haxe.Log;
import input.KeyPoll;
import systems.collisions.CollisionEvent;
import systems.collisions.EllipsoidColliderSystem.EllipsoidImmovableNode;
import systems.collisions.EllipsoidColliderSystem.EllipsoidMovableNode;
import util.geom.PMath;
import util.geom.Vec3;
import util.geom.Vec3Utils;
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
	private var nodeListImmovables:NodeList<EllipsoidImmovableNode>;
	private var nodeListMovables:NodeList<EllipsoidMovableNode>;
	
	private var pos:Vector3D;
	private var disp:Vector3D;
	
		private var ellipsoid_radius:Vector3D;
		private var ray_travel:Vector3D;
		private var ray_origin:Vector3D ;
		
		private var zeroVel:Vec3;

	public function new(collidable:IECollidable, threshold:Float=0.001) 
	{
		super();
		_collider =  new EllipsoidCollider(0, 0, 0, threshold, true);
		this.collidable = collidable;
		
		
		pos = new Vector3D();
		disp = new Vector3D();
		
		ellipsoid_radius = new Vector3D();
		ray_travel = new Vector3D();
		ray_origin = new Vector3D();
		
		zeroVel = new Vec3();
		collNorm = new Vec3();
		collPos = new Vec3();
	}

	
	
	override public function addToEngine(engine:Engine):Void
    {
		nodeList = engine.getNodeList(EllipsoidNode);
		nodeListImmovables = engine.getNodeList(EllipsoidImmovableNode);
		nodeListMovables = engine.getNodeList(EllipsoidMovableNode);
    }
	
	//inline
	private  function doCalculateDestination(ellip:Ellipsoid, npos:Vec3, vel:Vec3, time:Float, fromTime:Float, result:MoveResult):Bool {
		//if (npos.z < 36) {
			//npos.z  = 37;
			//mytrace("Pre than z Dest:" + pos.z);
	//	}
		
		pos.x = npos.x;
		pos.y = npos.y;
		pos.z = npos.z;
		
		disp.x = vel.x * time;
		disp.y = vel.y * time;
		disp.z = vel.z * time;
		
		
		
		var vec:Vector3D =  _collider.calculateDestination(pos, disp, collidable, time, fromTime);
		
	//	if (vec.z < ellip.z) throw "OUTTA BOUNDS:"+vec.z;
		if (_collider.collisions != null) {
			var tailCollision:CollisionEvent = null;
			var c:CollisionEvent = _collider.collisions;
			while ( c != null) {
				tailCollision = c;
				//if (tailCollision.dest.z < 36) mytrace("Post Lower than z Dest:" + tailCollision.dest.z);
				c = c.next;
			}
			
			tailCollision.next = result.collisions;
			result.collisions = _collider.collisions;
			//mytrace("Collisions added! "+ npos + ", " + vel);
			_collider.collisions = null;
			//	result.setIntegrationNewVelAtCollideTime(npos, vel, ellip,fromTime);
			return true;
		}
		else {
		//	mytrace( "No collisions found:" + npos + ", " + vel);
			return false;
		}
	}
	
	private inline function mytrace(val:String):Void {
		Log.trace(val);
	}
	
	override public function update(time:Float):Void
    {
		
		var n:EllipsoidNode = nodeList.head;
		var result:MoveResult;
		
		// Test movable objects against static 3d environment, getting a list of collision events and assumed final destination
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
	
			var vec:Vector3D =  _collider.calculateDestination(pos, disp, collidable, 1, 0);
			
			
			result.x = vec.x;
			result.y = vec.y;
			result.z = vec.z;
			
			
			result.collisions = _collider.collisions;

			_collider.collisions = null;
			
			n = n.next;
		}
		
		
		
		//return;
		// --------------------------------
		
		
			setupIntegration();
		
			// Now, test for dynamic collisions along the way that might interuppt/change the above collision events
			var elapseFrameTime: Float;
			var remainingFrameTime: Float = 1;
			var totalElapsedFrameTime:Float = 0;
		
			
			//var millis: uint = getTimer();
			
			///*
		
			while( getNearestCollision(totalElapsedFrameTime, remainingFrameTime)  )
			{
				
			//	if( getTimer() - millis > MAX_FRAME_TIME )
			//	{
				//	trace( "Throw an error. Frame is unsolvable" );
			//		return;
				//}
				
				
				
				elapseFrameTime = nearestCollisionEvent != null ? nearestCollisionEvent.t - totalElapsedFrameTime : collTimeResult;// nearestIntersection.dt;
				
				
				

				remainingFrameTime -= elapseFrameTime;
				totalElapsedFrameTime += elapseFrameTime;
				
				/*
				if ( nearestCollisionEvent != null) {
					if (nearestCollisionEvent.t != totalElapsedFrameTime) throw "MISMatch assertion!";
				}
				*/
				
				//if (totalElapsedFrameTime > 1) throw "SHOULD NOT exceed frame time of 1!!";
				// either is static collision OR dynamic collision OR both
				
				//if (elapseFrameTime != 1) throw new Error(":" + nearestCollisionEvent.t);
				//-- step forward to intersection				
				//for each( movable in movables )
				integrate(elapseFrameTime, totalElapsedFrameTime);
				//}
				
				
				//-- resolve dynamic intersection as collision if available
				// remove any subsequent collision events  and add a new  "THING" collision event at given totalElapsedFrameTime
				// [...]
				if ( circleA != null) {
					if (circleB != null) {
						resolveMovableCircleWithAnother(circleA.movable.pos, circleA.movable.vel, circleB.movable.pos, circleB.movable.vel);
						
						circleA.result.truncateCollisionEvents(totalElapsedFrameTime);
						circleB.result.truncateCollisionEvents(totalElapsedFrameTime);
						
						var gotCollideA:Bool = doCalculateDestination(circleA.ellipsoid, circleA.movable.pos, circleA.movable.vel, remainingFrameTime, totalElapsedFrameTime, circleA.result);
						var gotCollideB:Bool = doCalculateDestination(circleB.ellipsoid, circleB.movable.pos, circleB.movable.vel, remainingFrameTime, totalElapsedFrameTime, circleB.result);
						//totalElapsedFrameTime
						//if ( (!gotCollideA && !gotCollideB)) {
							//mytrace( "NO collisions found for both!");
						//}

						var aFirst:Bool = (circleA.movable.priority >= circleB.movable.priority);
						addThingCollisionEvent(totalElapsedFrameTime, aFirst ? circleB.entity : circleA.entity, aFirst ? circleA : circleB);
					}
					else {
						resolveMovableCircleWithImmobile(circleC.pos, circleA.movable.pos, circleA.movable.vel);
					
						circleA.result.truncateCollisionEvents(totalElapsedFrameTime);
						doCalculateDestination(circleA.ellipsoid, circleA.movable.pos, circleA.movable.vel, remainingFrameTime, totalElapsedFrameTime, circleA.result);
						
						addThingCollisionEvent(totalElapsedFrameTime, circleC.entity, circleA);
					}
					
				}
				
			}
		//	*/
			
			nearestCollisionEvent = null;
			circleA = null;
			circleB = null;
			circleC = null;
				
			//-- simulation is complete resolved
			integrateFinal(remainingFrameTime);
		
    }
	
	inline private function addThingCollisionEvent(t:Float, thing:Entity, activeCircle:EllipsoidMovableNode):Void {
		
		var radius:Float = activeCircle.ellipsoid.x;
		if (activeCircle.ellipsoid.y > radius) radius = activeCircle.ellipsoid.y;
		if (activeCircle.ellipsoid.z > radius) radius = activeCircle.ellipsoid.z;
		
		collPos.x = activeCircle.movable.pos.x - collNorm.x * radius * radius / activeCircle.ellipsoid.x;
		collPos.y= activeCircle.movable.pos.y - collNorm.y * radius * radius / activeCircle.ellipsoid.y;
		collPos.z = activeCircle.movable.pos.z - collNorm.z * radius * radius / activeCircle.ellipsoid.z;
		collOffset = collPos.dotProduct(collNorm);
		var e:CollisionEvent= CollisionEvent.Get(collPos, collNorm, collOffset, t, activeCircle.movable.pos, CollisionEvent.GEOMTYPE_THING);
		e.thing = thing;
		activeCircle.result.addCollisionEvent(e);
	}
	

	
	///*
	inline private  function setupIntegration():Void {
		var m:EllipsoidMovableNode = nodeListMovables.head;
		while (m != null) {
			//m.result.tweenResultPosVel(m.pos, m.movable.pos, m.movable.vel, fromTime);
			m.result.initIntegration(m.pos, m.movable.pos, m.movable.vel, m.ellipsoid);
			m = m.next;
		}
	}
	//*/
	
	inline private  function integrate(time:Float, totalElapsedTime:Float):Void {
		var m:EllipsoidMovableNode = nodeListMovables.head;
		
		//if (time > EPLISON_DT) {
			while (m != null) {
				m.movable.integrate(time);
				//if (m.movable.pos.z < 36) {
				//	mytrace("integrate lower than 36:"+m.movable.pos.z);
				//	m.movable.pos.z = 36;
					
				//}
				m = m.next;
			}
		//}
		// if integreating to static collision, go through all movable entities whose static collision events match given t, and re-update their velocities to match new path
		if (nearestCollisionEvent != null) {
			m = nodeListMovables.head;
			
			while ( m != null) {
				
				m.result.setIntegrationNewVelAtCollideTime(m.movable.pos, m.movable.vel, m.ellipsoid, nearestCollisionEvent.t);
				m = m.next;
			}
		}
		// else, it is assumed only a dynamic collision event did occur before static collision event, or no collisions occured at all..do nothing
	}
	
	inline
	private  function integrateFinal(time:Float):Void {
		var m:EllipsoidMovableNode = nodeListMovables.head;
		while (m != null) {
			m.movable.integrate(time);	
			m.result.x = m.movable.pos.x;
			m.result.y = m.movable.pos.y;
			m.result.z = m.movable.pos.z;
			m = m.next;
		}
	}
	
	private var circleA:EllipsoidMovableNode;
	private var circleB:EllipsoidMovableNode;
	private var circleC:EllipsoidImmovableNode;
	private var collTimeResult:Float;  // dynamic collisions
	private var collPos:Vec3;
	private var collNorm:Vec3;
	private var collOffset:Float;

	
	private var nearestCollisionEvent:CollisionEvent; 
	// Always integrate everyone to nearest collision time, whether static or not...Always get velocity at particular time, than itnegreate
	
	
	inline
	private  function getNearestCollision(fromTime:Float, timeRemaining:Float):Bool {
		circleA = null;
		circleB = null;
		circleC = null;
		nearestCollisionEvent = null;
		
		var collTime:Float = PMath.FLOAT_MAX;
		if ( getNearestCollisionEvent(fromTime) ) {	// any static collision with 3d environment to integrate to first...
			
		}
		
		//nearestCollisionEvent!=null ? nearestCollisionEvent.t-fromTime : timeRemaining
		if (getNearestEllCollision(timeRemaining)) {  // dynamic collision to resolve (if t <= timeFrame)
			if (nearestCollisionEvent != null && nearestCollisionEvent.t <= fromTime+collTimeResult) {
				circleA = null;
				circleB = null;
				circleC = null;
			}
			else nearestCollisionEvent = null;
		}
		
		
		return nearestCollisionEvent!=null || circleA!=null;
	}
	
	inline
	private  function getNearestCollisionEvent(fromTime:Float):Bool {
		var m:EllipsoidMovableNode = nodeListMovables.head;
		var collisionEvent:CollisionEvent = null;
		var curCollisionEvent:CollisionEvent = null;
		var t:Float  = PMath.FLOAT_MAX;
		while ( m != null) {

			if ( (collisionEvent =  m.result.findNearestCollisionEvent(fromTime))!=null ) {
				if (collisionEvent.t < t) {
					t = collisionEvent.t;
					curCollisionEvent = collisionEvent;
				}
				
			}
			m = m.next;
		}
		
		nearestCollisionEvent = curCollisionEvent;
		
		return curCollisionEvent!= null;
	}
	
	
	inline
	public  function getNearestEllCollision(time:Float):Bool { 
		
		
		 // Test for any immobile ellipsoid collisions that might occur earlier than static environment collisions
		var i:EllipsoidImmovableNode = nodeListImmovables.head; 
		var m:EllipsoidMovableNode;
		var minTime:Float = time;// PMath.FLOAT_MAX;
		var t:Float;
		while ( i != null) {
			m = nodeListMovables.head;
			while (m != null) {
				if ( (t= getCollision(m.movable.pos,m.ellipsoid, m.movable.vel, i.pos, i.ellipsoid, zeroVel, time )) <= minTime) {
					//if (t<minTime) {
						circleA = m;
						circleC = i;
						minTime = t;
					//}
				}
				
				m = m.next;
			}
			i = i.next;
		}

		
		 // Test for any mobile ellipsoid collisions that might occur earlier than static environment collisions
		///*
		m = nodeListMovables.head;
		var m2:EllipsoidMovableNode;
		while ( m != null) {
			m2 = nodeListMovables.head;
			while (m2 != null) {  // laze approach first instead of back/forward
				if (m2 != m  && (t= getCollision(m.movable.pos,m.ellipsoid, m.movable.vel, m2.movable.pos, m2.ellipsoid, m2.movable.vel, time )) <= minTime ) {
					circleA = m;
					circleB = m2;
					minTime = t;
					circleC = null;
				}
				m2 = m2.next;
			}
			m = m.next;
		}
		//*/
		
		
		// if got collision pair, add/change CollisionEvents of involved movables, 
		
		collTimeResult = minTime;
		
		return circleA != null;
	}
	
	
	/*
		avoid float errors
		(very small penetration will be catched)
	*/
	private static inline var EPLISON_DT: Float = -0.00001;

	/*
		avoid very slow moving objects while contact
		(too much computations)
		and tangential zero reflection for curves
		(which cause no change of velocity while collision resolve)
	*/
	private static inline var MIN_REFLECTION: Float = .005;

	///*
	public inline function resolveMovableCircleWithImmobile( immobileCircle:Vec3, circle: Vec3, circleVel:Vec3 ): Void  // immovable (use this naive approach for 3d as immovable against a movable circle! )
	{
		var nx:Float = circle.x - immobileCircle.x;
		var ny:Float = circle.y - immobileCircle.y;
		
		
		var rr: Float = Math.sqrt(nx * nx + ny * ny);
		rr = 1 / rr;
			
		nx *= rr;
		ny *= rr;
		
		
		collNorm.x = nx;
		collNorm.y = ny;
		
		//collOffset = nx *
		
		var e: Float;

		// elastic .5 would be fine... so 1.5 total computed
		//( 1 + .5 ) *
		e = 1.5* ( nx * circleVel.x + ny * circleVel.y );
		
		if( e > -MIN_REFLECTION ) e = -MIN_REFLECTION;
		
		circleVel.x -= nx * e;
		circleVel.y -= ny * e;
		circleVel.z = 0;
		
		
	}
	
		public inline function resolveMovableCircleWithAnother(myCircle:Vec3, vc1:Vec3,  circle: Vec3, vc0:Vec3 ):Void {
		var dx:Float = myCircle.x - circle.x;
		var dy:Float = myCircle.y - circle.y;

		var dd: Float =  Math.sqrt(dx * dx + dy * dy );
		dd = 1 / dd;
		dx*= dd;
		dy*= dd;
	
		
		collNorm.x = dx;
		collNorm.y = dy;
		
		
		// normal dotProduct of Velocity  -  normal dotProduct of Velocity  (inline expanded...lol) 
		var energie: Float = 1.5* ( vc0.x * dx + vc0.y * dy - vc1.x * dx - vc1.y * dy ); // * 1;
		if( energie < .0001 ) energie = .0001;
		
		dx *= energie;
		dy *= energie;
		
		
	
		
		vc0.x -= dx; vc0.y -= dy; 
		vc1.x += dx; vc1.y += dy; 
		vc0.z = 0;
		vc1.z = 0;
	}
	//*/
	
	/*
		public inline function resolveMovableCircleWithImmobile( immobileCircle:Vec3, circle: Vec3, circleVel:Vec3 ): Void  // immovable (use this naive approach for 3d as immovable against a movable circle! )
	{
		var nx:Float = circle.x - immobileCircle.x;
		var ny:Float = circle.y - immobileCircle.y;
			var nz:Float = circle.z - immobileCircle.z;
		
		var rr: Float = Math.sqrt(nx * nx + ny * ny + nz*nz);
		rr = 1 / rr;
			
		nx *= rr;
		ny *= rr;
		nz *= rr;
		
		collNorm.x = nx;
		collNorm.y = ny;
		collNorm.z = nz;
		//collOffset = nx *
		
		var e: Float;

		// elastic .5 would be fine... so 1.5 total computed
		//( 1 + .5 ) *
		e = 1.5* ( nx * circleVel.x + ny * circleVel.y + nz*circleVel.z );
		
		if( e > -MIN_REFLECTION ) e = -MIN_REFLECTION;
		
		circleVel.x -= nx * e;
		circleVel.y -= ny * e;
		circleVel.z -=  nz * e;
		
		
	}
	
		public inline function resolveMovableCircleWithAnother(myCircle:Vec3, vc1:Vec3,  circle: Vec3, vc0:Vec3 ):Void {
		var dx:Float = myCircle.x - circle.x;
		var dy:Float = myCircle.y - circle.y;
		var dz:Float = myCircle.z - circle.z;
		var dd: Float =  Math.sqrt(dx * dx + dy * dy + dz * dz);
		dd = 1 / dd;
		dx*= dd;
		dy*= dd;
		dz *= dd;
		
		collNorm.x = dx;
		collNorm.y = dy;
		collNorm.z = dz;
		
		// normal dotProduct of Velocity  -  normal dotProduct of Velocity  (inline expanded...lol) 
		var energie: Float = 1.5*( vc0.x * dx + vc0.y * dy + vc0.z * dz - vc1.x * dx - vc1.y * dy - vc1.z * dz ); // * 1;
		if( energie < .0001 ) energie = .0001;
		
		dx *= energie;
		dy *= energie;
		dz *= energie;
		
	
		
		vc0.x -= dx; vc0.y -= dy; vc0.z -= dz;
		vc1.x += dx; vc1.y += dy; vc1.z += dz;
	}
	*/
	
	


	
	
	

		/*
	public inline function getCollision(c1Obj:Vec3, c1Ellip:Ellipsoid, c1Vel:Vec3, c2Obj:Vec3,  c2Ellip:Ellipsoid, c2Vel:Vec3, dt:Float):Float {
			
			var t:Float;
			
			// This is a C1 ray hit test against....
			ray_origin.x = c1Obj.x - c2Obj.x;
			ray_origin.y = c1Obj.y - c2Obj.y;
			ray_origin.z = c1Obj.z - c2Obj.z;
			
			// ...inflated ellipsoid (sum of radii)
			ellipsoid_radius.x = c1Ellip.x + c2Ellip.x;
			ellipsoid_radius.y = c1Ellip.y + c2Ellip.y;
			ellipsoid_radius.z = c1Ellip.z + c2Ellip.z;
			
			// ...based on relative velocities of c1/c2.
			ray_travel.x = c1Vel.x - c2Vel.x;
			ray_travel.y = c1Vel.y - c2Vel.y;
			ray_travel.z = c1Vel.z - c2Vel.z;
		
			// Find "d" in normalized unit time. 
			// Quadratic formula (to consider: simplified to 1 solution: b^2-ac. instead)
			var a:Float = ((ray_travel.x*ray_travel.x)/(ellipsoid_radius.x*ellipsoid_radius.x))
					+ ((ray_travel.y*ray_travel.y)/(ellipsoid_radius.y*ellipsoid_radius.y))
					+ ((ray_travel.z*ray_travel.z)/(ellipsoid_radius.z*ellipsoid_radius.z));
				var b:Float = ((2*ray_origin.x*ray_travel.x)/(ellipsoid_radius.x*ellipsoid_radius.x))
						+ ((2*ray_origin.y*ray_travel.y)/(ellipsoid_radius.y*ellipsoid_radius.y))
						+ ((2*ray_origin.z*ray_travel.z)/(ellipsoid_radius.z*ellipsoid_radius.z));
				var c:Float = ((ray_origin.x*ray_origin.x)/(ellipsoid_radius.x*ellipsoid_radius.x))
						+ ((ray_origin.y*ray_origin.y)/(ellipsoid_radius.y*ellipsoid_radius.y))
						+ ((ray_origin.z*ray_origin.z)/(ellipsoid_radius.z*ellipsoid_radius.z))
						- 1;

				var d:Float = b * b - 4 * a * c;
				
				if ( d < 0 ) {  // no real roots
					t = PMath.FLOAT_MAX;
				}
				else {
					d = Math.sqrt(d);
					
					var multiplier:Float = 1/(2*a);
					var hit:Float = (-b + d)*multiplier;
					var hitsecond:Float = (-b - d)*multiplier;
					d = hit < hitsecond ? hit : hitsecond;  // 2 solutions, bah...
					if (d < 0) {
						t = PMath.FLOAT_MAX;
					}
					else {
						t = d * dt; 
					}
				}
				
				return t;   // collision happened within timeframe  t<=dt
		}
		//*/
		

		public inline function getCollision(c1Obj:Vec3, c1Ellip:Ellipsoid, c1Vel:Vec3, c2Obj:Vec3,  c2Ellip:Ellipsoid, c2Vel:Vec3, dt:Float):Float {
			
		var rr: Float = c1Ellip.x + c2Ellip.x;
			var r2: Float = rr * rr;
			var vx: Float = c1Vel.x;
			var vy: Float = c1Vel.y;
			var vs: Float = vx * vx + vy * vy;
			var ex: Float = c2Obj.x - c1Obj.x;
			var ey: Float = c2Obj.y - c1Obj.y;
			var ev: Float = ex * vy - ey * vx;
			var sq: Float = vs * r2 - ev * ev;
			
			var t:Float;
			if ( sq < 0 ) t = PMath.FLOAT_MAX;
			else {
				t = -( Math.sqrt( sq ) - ey * vy - ex * vx ) / vs;
				//if( t > EPLISON_DT && t < 0 ) t = 0;
				if ( t < 0 ) t= PMath.FLOAT_MAX;
				else t *= dt;
			}
			return t;
		}
	
}

class EllipsoidNode extends Node<EllipsoidNode> {  
	public var ellipsoid:Ellipsoid;
	public var vel:Vel;
	public var pos:Pos;
	public var result:MoveResult;
	
	public var collResult:CollisionResult;
}

class EllipsoidMovableNode extends Node<EllipsoidMovableNode> {  
	public var ellipsoid:Ellipsoid;
	public var vel:Vel;
	public var pos:Pos;
	public var result:MoveResult;
	public var movable:MovableCollidable;
	
	
}


class EllipsoidImmovableNode extends Node<EllipsoidImmovableNode> {  // It is assumed such an entity in this state will also lack Velocity and MoveResult components..
	public var ellipsoid:Ellipsoid;
	public var pos:Pos;
	public var immovable:ImmovableCollidable;
}


/*
		override public function resolve():void { // more complicated resolution taking into account both particle masses, this will NOT be used.
			// halt total
			//c1.vx = 0; c1.vy = 0; c1.vz = 0
			//c2.vx = 0; c2.vy = 0; c2.vz = 0;
			//return;
			 
			var cn:Vector3D = c1.collisionNormal;
			cn.x = c2.object.x - c1.object.x;
			cn.y = c2.object.y - c1.object.y;
			cn.z = c2.object.z - c1.object.z;
			cn.normalize();
			//p2.x.minus( p1.x );

			//relative velocity
			var dv:Vector3D = new Vector3D(c2.vx - c1.vx, c2.vy - c1.vy, c2.vz - c1.vz); //  p2.v.minus( p1.v );
			
			const p2Mass:Number = 1;
			const p1Mass:Number = 1;
			//const mass:Number = 1;
			
			//perfectly elastic impulse
			dv.x *= -2; dv.y *= -2; dv.z *= -2;
			var cn2:Vector3D = cn.clone();
			cn2.scaleBy( 1 / p1Mass + 1 / p2Mass );
		
			// normal dotProduct of relative velocities / normal dotProduct of impulse normal
			
			var impulse:Number = cn.dotProduct( dv  ) / cn.dotProduct( cn2);
			var multiplier:Number = -impulse / p1Mass; // bah...I dun get this!
			
			c1.vx += cn.x * multiplier;
			c1.vy += cn.y  * multiplier;
			c1.vz += cn.z * multiplier;
			multiplier = impulse / p2Mass;
			c2.vx += cn.x * multiplier;
			c2.vy += cn.y  * multiplier;
			c2.vz += cn.z * multiplier;
			
		}
		
		// original 2d version from above
		public function resolve() : void
		{
			
			//points from 1 -> 2
			var cn:Vec2D = p2.x.minus( p1.x );
			
			cn.normalize();
			
			//relative velocity
			var dv:Vec2D = p2.v.minus( p1.v );
			
			//perfectly elastic impulse
			var impulse:Number = cn.dot( dv.times( -2 ) ) / cn.dot( cn.times( 1 / p1.mass + 1 / p2.mass ) );
			
			//scale normal by the impulse
			p1.v.plusEquals( cn.times( -impulse / p1.mass ) );
			p2.v.plusEquals( cn.times(  impulse / p2.mass ) );
			
		}
		
*/