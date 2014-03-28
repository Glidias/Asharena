package systems.collisions;
import ash.core.Engine;
import ash.core.Node;
import ash.core.NodeList;
import ash.core.System;
import systems.collisions.EllipsoidNode;

/**
 * ...
 * @author Glenn Ko
 */
class EllCollisionResolveSystem extends System
{

	private var nodeList:NodeList<EllipsoidNode>;
	
	public function new() 
	{
		super();
	}
	
	
	override public function addToEngine(engine:Engine):Void {
		nodeList = engine.getNodeList(EllipsoidNode);
	}
	
	override public function update(time:Float):Void {
		var n:EllipsoidNode = nodeList.head;
		
		while (n != null) {
			
			
			n = n.next;
		}
	}
	
	
	
		private var ellipsoid_radius:Vector3D = new Vector3D();
		private var ray_travel:Vector3D = new Vector3D();
		private var ray_origin:Vector3D = new Vector3D();
	//	/*
		override public function willCollide(dt:Number):Boolean {
			
			// This is a C1 ray hit test against....
			ray_origin.x = c1.object.x - c2.object.x;
			ray_origin.y = c1.object.y - c2.object.y;
			ray_origin.z = c1.object.z - c2.object.z;
			
			// ...inflated ellipsoid (sum of radii)
			ellipsoid_radius.x = c1.collider.radiusX + c2.collider.radiusX;
			ellipsoid_radius.y = c1.collider.radiusY + c2.collider.radiusY;
			ellipsoid_radius.z = c1.collider.radiusZ + c2.collider.radiusZ;
			
			// ...based on relative velocities of c1/c2.
			ray_travel.x = c1.vx - c2.vx;
			ray_travel.y = c1.vy - c2.vy;
			ray_travel.z = c1.vz - c2.vz;
		
			// Find "d" in normalized unit time. 
			// Quadratic formula (to consider: simplified to 1 solution: b^2-ac. instead)
			var a:Number = ((ray_travel.x*ray_travel.x)/(ellipsoid_radius.x*ellipsoid_radius.x))
					+ ((ray_travel.y*ray_travel.y)/(ellipsoid_radius.y*ellipsoid_radius.y))
					+ ((ray_travel.z*ray_travel.z)/(ellipsoid_radius.z*ellipsoid_radius.z));
				var b:Number = ((2*ray_origin.x*ray_travel.x)/(ellipsoid_radius.x*ellipsoid_radius.x))
						+ ((2*ray_origin.y*ray_travel.y)/(ellipsoid_radius.y*ellipsoid_radius.y))
						+ ((2*ray_origin.z*ray_travel.z)/(ellipsoid_radius.z*ellipsoid_radius.z));
				var c:Number = ((ray_origin.x*ray_origin.x)/(ellipsoid_radius.x*ellipsoid_radius.x))
						+ ((ray_origin.y*ray_origin.y)/(ellipsoid_radius.y*ellipsoid_radius.y))
						+ ((ray_origin.z*ray_origin.z)/(ellipsoid_radius.z*ellipsoid_radius.z))
						- 1;

				var d:Number = b*b-4*a*c;
				if ( d < 0 ) {  // no real roots
					return false;
				}
				
				d = Math.sqrt(d);
				
				const multiplier:Number = 1/(2*a);
				var hit:Number = (-b + d)*multiplier;
				var hitsecond:Number = (-b - d)*multiplier;
				d = hit < hitsecond ? hit : hitsecond;  // 2 solutions, bah...
				if (d < 0) {
					return false;
				}
				
				t = d * dt; 
				
				return t <= dt;   // collision happened within timeframe
		}

		

		// BETWEEN MOVABLE
		public inline function dIntersectMovableCircle( circle: MovableCircle, remainingFrameTime: Float ): Void
		{
			var ex: Float = x - circle.x;
			var ey: Float = y - circle.y;
			var rr: Float = r + circle.r;
			var r2: Float = rr * rr;

			var vx: Float = circle.velocity.x - velocity.x;
			var vy: Float = circle.velocity.y - velocity.y;
			var vs: Float = vx * vx + vy * vy;

			if( vs == 0 ) return null;

			var ev: Float = ex * vy - ey * vx;
			var sq: Float = vs * r2 - ev * ev;

			if( sq < 0 ) return null;

			var dt: Float = -( Math.sqrt( sq ) - ey * vy - ex * vx ) / vs;
			if( dt > EPLISON_DT && dt < 0 ) dt = 0;
			if( dt < 0 || dt > remainingFrameTime ) return null;

			//return new DynamicIntersection( this, circle, dt );
		}
			public function dIntersectMovableCircle( circle: MovableCircle, remainingFrameTime: Number ): DynamicIntersection  // immovable
		{
			var rr: Number = r + circle.r;
			var r2: Number = rr * rr;
			var vx: Number = circle.velocity.x;
			var vy: Number = circle.velocity.y;
			var vs: Number = vx * vx + vy * vy;
			var ex: Number = x - circle.x;
			var ey: Number = y - circle.y;
			var ev: Number = ex * vy - ey * vx;
			var sq: Number = vs * r2 - ev * ev;
			
			if( sq < 0 ) return null;
			
			var dt: Number = -( Math.sqrt( sq ) - ey * vy - ex * vx ) / vs;
			if( dt > EPLISON_DT && dt < 0 ) dt = 0;
			if( dt < 0 || dt > remainingFrameTime ) return null;
		
			return new DynamicIntersection( this, circle, dt );
		}
		
		public inline function resolveMovableCircle( circle: MovableCircle ): void // #TODO
		{
			var dd: Number = r + circle.r;
			var dx: Number = ( x - circle.x ) / dd;
			var dy: Number = ( y - circle.y ) / dd;
			
			var vc0: Vec2D = circle.velocity;
			var vc1: Vec2D = velocity;

			var energie: Number = ( vc0.x * dx + vc0.y * dy - vc1.x * dx - vc1.y * dy ) * 1;
			
			if( energie < .0001 ) energie = .0001;
			
			dx *= energie;
			dy *= energie;
			
			vc0.x -= dx; vc0.y -= dy;
			vc1.x += dx; vc1.y += dy;
		}
		public function resolveMovableCircle( circle: MovableCircle ): void  // immovable
		{
			var rr: Number = r + circle.r;
			
			var nx: Number = ( circle.x - x ) / rr;
			var ny: Number = ( circle.y - y ) / rr;

			var e: Number;
			
			
			// elastic .5 would be fine... so 1.5
			e = ( 1 + elastic ) * ( nx * circle.velocity.x + ny * circle.velocity.y );
			
			if( e > -MIN_REFLECTION ) e = -MIN_REFLECTION;
			
			circle.velocity.x -= nx * e;
			circle.velocity.y -= ny * e;
		}
		
		override public function resolve():void {
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
		
			var impulse:Number = cn.dotProduct( dv  ) / cn.dotProduct( cn2);
			var multiplier:Number = -impulse / p1Mass;
			c1.vx += cn.x * multiplier;
			c1.vy += cn.y  * multiplier;
			c1.vz += cn.z * multiplier;
			multiplier = impulse / p2Mass;
			c2.vx += cn.x * multiplier;
			c2.vy += cn.y  * multiplier;
			c2.vz += cn.z * multiplier;
			
		}
	
}

