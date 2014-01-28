package de.popforge.revive.member
{
	import de.popforge.revive.display.IDrawAble;
	import de.popforge.revive.geom.Vec2D;
	import de.popforge.revive.resolve.DynamicIntersection;
	import de.popforge.revive.resolve.IDynamicIntersectionTestAble;
	
	import flash.display.Graphics;
	import de.popforge.revive.resolve.IResolvable;
	
	public class MovableCircle extends MovableParticle
		implements IDynamicIntersectionTestAble, IResolvable, IDrawAble
	{
		public var r: Number;
		
		public function MovableCircle( x: Number, y: Number, r: Number )
		{
			super( x, y );

			this.r = r;
		}
		
		public override function dIntersectMovableParticle( particle: MovableParticle, remainingFrameTime: Number ): DynamicIntersection
		{
			// TEST
			return null;
		}
		
		public override function dIntersectMovableCircle( circle: MovableCircle, remainingFrameTime: Number ): DynamicIntersection
		{
			var ex: Number = x - circle.x;
			var ey: Number = y - circle.y;
			var rr: Number = r + circle.r;
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
		
		public override function resolveMovableParticle( particle: MovableParticle ): void // #TODO
		{
			var dx: Number = ( x - particle.x ) / r;
			var dy: Number = ( y - particle.y ) / r;
			
			var vc0: Vec2D = particle.velocity;
			var vc1: Vec2D = velocity;

			var energie: Number = ( vc0.x * dx + vc0.y * dy - vc1.x * dx - vc1.y * dy ) * 1;
			
			if( energie < .0001 ) energie = .0001;
			
			dx *= energie;
			dy *= energie;
			
			vc0.x -= dx; vc0.y -= dy;
			vc1.x += dx; vc1.y += dy;
		}
		
		public override function resolveMovableCircle( circle: MovableCircle ): void // #TODO
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
		
		public override function draw( g: Graphics ): void
		{
			g.drawCircle( x, y, Math.max( r, 3 ) );
		}
	}
}