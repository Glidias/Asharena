package de.popforge.revive.member
{
	import de.popforge.revive.display.IDrawAble;
	import de.popforge.revive.geom.BoundingBox;
	import de.popforge.revive.resolve.DynamicIntersection;
	import de.popforge.revive.resolve.IDynamicIntersectionTestAble;
	import de.popforge.revive.resolve.IResolvable;
	
	import flash.display.Graphics;
	
	public class ImmovableGate extends Immovable
		implements IDynamicIntersectionTestAble, IResolvable, IDrawAble
	{
		public var x0: Number;
		public var y0: Number;
		public var x1: Number;
		public var y1: Number;
		
		private var length: Number;
		
		//-- line Vec2D
		private var dx: Number;
		private var dy: Number;
		
		//-- normal Vec2D
		private var nx: Number;
		private var ny: Number;
		
		public function ImmovableGate( x0: Number, y0: Number, x1: Number, y1: Number )
		{
			this.x0 = x0;
			this.y0 = y0;
			this.x1 = x1;
			this.y1 = y1;
			
			precompute();
		}
		
		public function dIntersectMovableParticle( particle: MovableParticle, remainingFrameTime: Number ): DynamicIntersection
		{
			var vx: Number = particle.velocity.x;
			var vy: Number = particle.velocity.y;
			
			var ud: Number = ( vy * dx - vx * dy );
			if( ud <= 0 ) return null; // only one collision direction
			
			var px: Number = particle.x - x0;
			var py: Number = particle.y - y0;

			var ua: Number = ( vy * px - vx * py ) / ud;
			if( ua < 0 || ua > 1 ) return null;

			var dt: Number = ( dy * px - dx * py ) / ud;
			if( dt > EPLISON_DT && dt < 0 ) dt = 0;
			if( dt < 0 || dt > remainingFrameTime ) return null;

			return new DynamicIntersection( this, particle, dt );
		}
		
		public function dIntersectMovableCircle( circle: MovableCircle, remainingFrameTime: Number ): DynamicIntersection
		{
			//return dIntersectMovableParticle(circle, remainingFrameTime);
			var vx: Number = circle.velocity.x;
			var vy: Number = circle.velocity.y;
			
			var ud: Number = ( vy * dx - vx * dy );
			if( ud <= 0 ) return null; // only one collision direction
			
			var r: Number = circle.r;
			var px: Number = circle.x - x0 - nx * r;
			var py: Number = circle.y - y0 - ny * r;

			var ua: Number = ( vy * px - vx * py ) / ud;
			if( ua < 0 || ua > 1 ) return null;

			var dt: Number = ( dy * px - dx * py ) / ud;
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
			var e: Number = ( 1 + elastic ) * ( nx * particle.velocity.x + ny * particle.velocity.y );
			
			particle.velocity.x -= nx * e;
			particle.velocity.y -= ny * e;
			
			particle.velocity.x -= particle.velocity.x * drag;
			particle.velocity.y -= particle.velocity.y * drag;
		}
		
		public function resolveMovableCircle( circle: MovableCircle ): void
		{
			var e: Number = ( 1 + elastic ) * ( nx * circle.velocity.x + ny * circle.velocity.y );

			circle.velocity.x -= nx * e;
			circle.velocity.y -= ny * e;
		}
		
		public function resolveMovableSegment( segment: MovableSegment ): void
		{
		}
		
		public function draw( g: Graphics ): void
		{
			g.moveTo( x0, y0 );
			g.lineTo( x1, y1 );
			
			var cx: Number = ( x0 + x1 ) / 2;
			var cy: Number = ( y0 + y1 ) / 2;
			
			g.moveTo( cx - ny * 3, cy + nx * 3 );
			g.lineTo( cx + nx * 3, cy + ny * 3 );
			g.lineTo( cx + ny * 3, cy - nx * 3 );
		}
		
		private function precompute(): void
		{
			dx = x1 - x0;
			dy = y1 - y0;
			
			length = Math.sqrt( dx * dx + dy * dy );
			
			nx =  dy / length;
			ny = -dx / length;
		}
	}
}