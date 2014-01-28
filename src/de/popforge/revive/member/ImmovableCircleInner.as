package de.popforge.revive.member
{
	import de.popforge.revive.display.IDrawAble;
	import de.popforge.revive.resolve.DynamicIntersection;
	import de.popforge.revive.resolve.IDynamicIntersectionTestAble;
	import de.popforge.revive.resolve.IResolvable;
	
	import flash.display.Graphics;
	
	public class ImmovableCircleInner extends Immovable
		implements IDynamicIntersectionTestAble, IResolvable, IDrawAble
	{
		private var x: Number;
		private var y: Number;
		private var r: Number;
		
		public function ImmovableCircleInner( x: Number, y: Number, r: Number )
		{
			this.x = x;
			this.y = y;
			this.r = r;
		}
		
		public function dIntersectMovableParticle( particle: MovableParticle, remainingFrameTime: Number ): DynamicIntersection
		{
			var r2: Number = r * r;
			var vx: Number = particle.velocity.x;
			var vy: Number = particle.velocity.y;
			var vs: Number = vx * vx + vy * vy;
			var ex: Number = x - particle.x;
			var ey: Number = y - particle.y;
			var ev: Number = ex * vy - ey * vx;
			var sq: Number = vs * r2 - ev * ev;
			
			if( sq < 0 ) return null;
			
			var dt: Number = ( Math.sqrt( sq ) + ey * vy + ex * vx ) / vs;
			if( dt > EPLISON_DT && dt < 0 ) dt = 0;
			if( dt < 0 || dt > remainingFrameTime ) return null;

			return new DynamicIntersection( this, particle, dt );
		}
		
		public function dIntersectMovableCircle( circle: MovableCircle, remainingFrameTime: Number ): DynamicIntersection
		{
			var rr: Number = r - circle.r;
			var r2: Number = rr * rr;
			var vx: Number = circle.velocity.x;
			var vy: Number = circle.velocity.y;
			var vs: Number = vx * vx + vy * vy;
			var ex: Number = x - circle.x;
			var ey: Number = y - circle.y;
			var ev: Number = ex * vy - ey * vx;
			var sq: Number = vs * r2 - ev * ev;
			
			if( sq < 0 ) return null;
			
			var dt: Number = ( Math.sqrt( sq ) + ey * vy + ex * vx ) / vs;
			if( dt > EPLISON_DT && dt < 0 ) dt = 0;
			if( dt < 0 || dt > remainingFrameTime ) return null;

			return new DynamicIntersection( this, circle, dt );
		}
		
		public function dIntersectMovableSegment( segment: MovableSegment, remainingFrameTime: Number ): DynamicIntersection
		{
			return null;
		}
		
		public function resolveMovableParticle( particle: MovableParticle ): void
		{
			var nx: Number = ( x - particle.x ) / r;
			var ny: Number = ( y - particle.y ) / r;

			var e: Number;
			
			e = ( 1 + elastic ) * ( nx * particle.velocity.x + ny * particle.velocity.y );
			
			if( e > -MIN_REFLECTION ) e = -MIN_REFLECTION;
			
			particle.velocity.x -= nx * e;
			particle.velocity.y -= ny * e;
		}
		
		public function resolveMovableCircle( circle: MovableCircle ): void
		{
			var rr: Number = r - circle.r;
			
			var nx: Number = ( x - circle.x ) / rr;
			var ny: Number = ( y - circle.y ) / rr;

			var e: Number;
			
			e = ( 1 + elastic ) * ( nx * circle.velocity.x + ny * circle.velocity.y );
			
			if( e > -MIN_REFLECTION ) e = -MIN_REFLECTION;
			
			circle.velocity.x -= nx * e;
			circle.velocity.y -= ny * e;
		}
		
		public function resolveMovableSegment( segment: MovableSegment ): void
		{
		}
		
		public function draw( g: Graphics ): void
		{
			g.drawCircle( x, y, r );
		}
	}
}