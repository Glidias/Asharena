package de.popforge.revive.member
{
	import de.popforge.revive.display.IDrawAble;
	import de.popforge.revive.resolve.DynamicIntersection;
	import de.popforge.revive.resolve.IDynamicIntersectionTestAble;
	import de.popforge.revive.resolve.IResolvable;
	
	import flash.display.Graphics;
	import de.popforge.revive.display.ExtDrawAPI;
	
	public class ImmovableCircleOuterSegment extends Immovable
		implements IDynamicIntersectionTestAble, IResolvable, IDrawAble
	{
		private var x: Number;
		private var y: Number;
		private var r: Number;
		
		private var a0: Number;
		private var a1: Number;
		
		private var ea: Number;
		
		public function ImmovableCircleOuterSegment( x: Number, y: Number, r: Number, a0: Number, a1: Number )
		{
			this.x = x;
			this.y = y;
			this.r = r;
			
			this.a0 = a0;
			this.a1 = a1;
			
			ea = a1 - a0;
			while( ea < 0 ) ea += Math.PI * 2;
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
			
			var dt: Number = -( Math.sqrt( sq ) - ey * vy - ex * vx ) / vs;
			if( dt > EPLISON_DT && dt < 0 ) dt = 0;
			if( dt < 0 || dt > remainingFrameTime ) return null;
			
			ex = ( particle.x + vx * dt ) - x;
			ey = ( particle.y + vy * dt ) - y;
			
			var da: Number = Math.atan2( ey, ex ) - a0;

			while( da < 0 ) da += Math.PI * 2;
			while( da > Math.PI * 2 ) da -= Math.PI * 2;

			if( da < 0 || da > ea ) return null;

			return new DynamicIntersection( this, particle, dt );
		}
		
		public function dIntersectMovableCircle( circle: MovableCircle, remainingFrameTime: Number ): DynamicIntersection
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
			
			ex = ( circle.x + vx * dt ) - x;
			ey = ( circle.y + vy * dt ) - y;
			
			var da: Number = Math.atan2( ey, ex ) - a0;

			while( da < 0 ) da += Math.PI * 2;
			while( da > Math.PI * 2 ) da -= Math.PI * 2;

			if( da < 0 || da > ea ) return null;

			return new DynamicIntersection( this, circle, dt );
		}
		
		public function dIntersectMovableSegment( segment: MovableSegment, remainingFrameTime: Number ): DynamicIntersection
		{
			return null;
		}
		
		public function resolveMovableParticle( particle: MovableParticle ): void
		{
			var nx: Number = ( particle.x - x ) / r;
			var ny: Number = ( particle.y - y ) / r;

			var e: Number;
			
			e = ( 1 + elastic ) * ( nx * particle.velocity.x + ny * particle.velocity.y );
			
			if( e > -MIN_REFLECTION ) e = -MIN_REFLECTION;
			
			particle.velocity.x -= nx * e;
			particle.velocity.y -= ny * e;
		}
		
		public function resolveMovableCircle( circle: MovableCircle ): void
		{
			var rr: Number = r + circle.r;
			
			var nx: Number = ( circle.x - x ) / rr;
			var ny: Number = ( circle.y - y ) / rr;

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
			ExtDrawAPI.drawCircleSegment( g, x, y, r, a0, a1 );
		}
	}
}