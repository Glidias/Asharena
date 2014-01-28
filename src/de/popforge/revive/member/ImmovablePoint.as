package de.popforge.revive.member
{
	import de.popforge.revive.display.IDrawAble;
	import de.popforge.revive.resolve.DynamicIntersection;
	import de.popforge.revive.resolve.IDynamicIntersectionTestAble;
	import de.popforge.revive.resolve.IResolvable;
	
	import flash.display.Graphics;
	
	public class ImmovablePoint extends Immovable
		implements IDynamicIntersectionTestAble, IResolvable, IDrawAble
	{
		private var x: Number;
		private var y: Number;
		
		public function ImmovablePoint( x: Number, y: Number )
		{
			this.x = x;
			this.y = y;
		}

		public function dIntersectMovableParticle( particle: MovableParticle, remainingFrameTime: Number ): DynamicIntersection
		{
			// particles never intersect each other
			return null;
		}
		
		public function dIntersectMovableCircle( circle: MovableCircle, remainingFrameTime: Number ): DynamicIntersection
		{
			var ex: Number = x - circle.x;
			var ey: Number = y - circle.y;
			
			var vx: Number = circle.velocity.x;
			var vy: Number = circle.velocity.y;
			var vs: Number = vx * vx + vy * vy;
			var ev: Number = ex * vy - ey * vx;
			var sq: Number = vs * ( circle.r * circle.r ) - ev * ev;

			if( sq < 0 ) return null;

			var dt: Number = -( Math.sqrt( sq ) - ey * vy - ex * vx ) / vs;
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
			trace( "Never expected, that particle intersect each other." );
		}
		
		public function resolveMovableCircle( circle: MovableCircle ): void
		{
			var rr: Number = circle.r;
			
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
			g.moveTo( x - 3, y );
			g.lineTo( x + 3, y );
			g.moveTo( x , y - 3 );
			g.lineTo( x , y + 3 );
		}
	}
}