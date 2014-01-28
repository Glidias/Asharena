package de.popforge.revive.member
{
	import de.popforge.revive.display.IDrawAble;
	import de.popforge.revive.geom.Vec2D;
	import de.popforge.revive.resolve.DynamicIntersection;
	import de.popforge.revive.resolve.IDynamicIntersectionTestAble;
	import de.popforge.revive.resolve.IResolvable;
	import flash.display.Graphics;
	
	public class MovableParticle extends Movable
		implements IDynamicIntersectionTestAble, IResolvable, IDrawAble
	{
		public var x: Number;
		public var y: Number;
		
		public var velocity: Vec2D;
		
		public function MovableParticle( x: Number, y: Number )
		{
			this.x = x;
			this.y = y;
			
			velocity = new Vec2D( 0, 0 );
		}
		
		public override function applyGlobalEnvirons( globalForce: Vec2D, globalDrag: Number ): void
		{
			velocity.x += globalForce.x;
			velocity.y += globalForce.y;
			
			velocity.x -= velocity.x * globalDrag;
			velocity.y -= velocity.y * globalDrag;
		}
		
		public override function integrate( dt: Number ): void
		{
			x += velocity.x * dt;
			y += velocity.y * dt;
		}
		
		public function dIntersectMovableParticle( particle: MovableParticle, remainingFrameTime: Number ): DynamicIntersection
		{
			return null;
		}
		
		public function dIntersectMovableCircle( circle: MovableCircle, remainingFrameTime: Number ): DynamicIntersection
		{
			var ex: Number = x - circle.x;
			var ey: Number = y - circle.y;
			var rr: Number = circle.r;
			var r2: Number = rr * rr;

			var vx: Number = circle.velocity.x - velocity.x;
			var vy: Number = circle.velocity.y - velocity.y;
			var vs: Number = vx * vx + vy * vy;

			if( vs == 0 ) return null;

			var ev: Number = ex * vy - ey * vx;
			var sq: Number = vs * r2 - ev * ev;

			if( sq < 0 ) return null;

			var dt: Number = -( Math.sqrt( sq ) - ey * vy - ex * vx ) / vs;
			if( dt > EPLISON_DT && dt < 0 ) dt = 0;
			if( dt < 0 || dt > remainingFrameTime ) return null;

			return new DynamicIntersection( this, circle, dt );
		}
		
		public function dIntersectMovableSegment( segment: MovableSegment, remainingFrameTime: Number ): DynamicIntersection
		{
			return segment.dIntersectMovableParticle( this, remainingFrameTime );
		}

		public function resolveMovableParticle( particle: MovableParticle ): void
		{
		}
		
		public function resolveMovableCircle( circle: MovableCircle ): void
		{
			var dd: Number = circle.r;
			var dx: Number = ( x - circle.x ) / dd;
			var dy: Number = ( y - circle.y ) / dd;
			
			var vc0: Vec2D = circle.velocity;
			var vc1: Vec2D = velocity;

			var e: Number = ( vc0.x * dx + vc0.y * dy - vc1.x * dx - vc1.y * dy ) * 1;
			
			if( e < .0001 ) e = .0001;
			
			dx *= e;
			dy *= e;
			
			vc0.x -= dx; vc0.y -= dy;
			vc1.x += dx; vc1.y += dy;
		}
		
		public function resolveMovableSegment( segment: MovableSegment ): void
		{
			segment.resolveMovableParticle( this );
		}
		
		public function draw( g: Graphics ): void
		{
			g.drawCircle( x, y, 1 );
		}
	}
}














