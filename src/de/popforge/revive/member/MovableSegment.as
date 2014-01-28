package de.popforge.revive.member
{
	/*
	 * MovableSegment
	 * will be assembled 2 Movable Particle
	 * to act like a IDynamicIntersectionTestAble segment
	 */
	 
	import de.popforge.revive.display.IDrawAble;
	import de.popforge.revive.resolve.IDynamicIntersectionTestAble;
	import de.popforge.revive.resolve.IResolvable;
	
	import flash.display.Graphics;
	import de.popforge.revive.resolve.DynamicIntersection;

	public class MovableSegment extends Movable
		implements IDynamicIntersectionTestAble, IResolvable, IDrawAble
	{
		internal var m0: MovableParticle;
		internal var m1: MovableParticle;
		
		public function MovableSegment( m0: MovableParticle, m1: MovableParticle )
		{
			this.m0 = m0;
			this.m1 = m1;
		}
		
		public function dIntersectMovableParticle( particle: MovableParticle, remainingFrameTime: Number ): DynamicIntersection
		{
			var x0: Number = particle.x;
			var y0: Number = particle.y;
			
			if( particle == m0 || particle == m1 )
			{
				return null;
			}
			
			var x1: Number = m0.x;
			var y1: Number = m0.y;
			var x2: Number = m1.x;
			var y2: Number = m1.y;
			
			var vx0: Number = particle.velocity.x;
			var vy0: Number = particle.velocity.y;
			
			var vx1: Number = m0.velocity.x;
			var vy1: Number = m0.velocity.y;
			var vx2: Number = m1.velocity.x;
			var vy2: Number = m1.velocity.y;
		
			var div: Number = ( ( 2 * vx1 - 2 * vx0 ) * vy2 + ( 2 * vx0 - 2 * vx2 ) * vy1 + ( 2 * vx2 - 2 * vx1 ) * vy0 );
			
			if( div == 0 ) return null;
			
			var vx0pow2: Number = vx0 * vx0;
			var vx1pow2: Number = vx1 * vx1;
			var vx2pow2: Number = vx2 * vx2;
			var vy0pow2: Number = vy0 * vy0;
			var vy1pow2: Number = vy1 * vy1;
			var vy2pow2: Number = vy2 * vy2;
			
			var vx0mul1: Number = vx0 * vx1;
			var vy0mul1: Number = vy0 * vy1;
			var vx0mul2: Number = vx0 * vx2;
			
			var vx0min1: Number = vx0 - vx1;
			var vy0min1: Number = vy0 - vy1;
			var vx0min2: Number = vx0 - vx2;
			var vy0min2: Number = vy0 - vy2;
			var vx1min2: Number = vx1 - vx2;
			var vy1min2: Number = vy1 - vy2;
			
			var vx0plu1: Number = vx0 + vx1;
			var vx0plu2: Number = vx0 + vx2;
			var vx1plu2: Number = vx1 + vx2;

			var sq: Number = 
						(
							  ( vx1pow2 - 2 * vx0mul1 + vx0pow2 ) * y2 * y2
							+ (
								  2 * ( vx0min1 * vx2 + ( vx0mul1 - vx0pow2 ) ) * y1
								- 2 * ( vx0min1 * vx2 + vx1pow2 - vx0mul1 ) * y0
								+ 2 * ( vx0min1 * vy1 - vx0min1 * vy0 ) * x2
 								+ 2 * ( vx0min1 * vy2 - 2 * vx0min2 * vy1 + ( vx0plu1 - 2 * vx2 ) * vy0 ) * x1
								+ (
									 -2 * ( vx0min1 * vy2 + ( 2 * vx2 - vx0plu1 ) * vy1 )
									- 4 * vx1min2 * vy0
								  ) * x0
							  ) * y2
							+ ( vx2pow2 - 2 * vx0mul2 + vx0pow2 ) * y1 * y1
							+ (
								  2 * ( vx0plu1 * vx2 - vx0mul1 - vx2pow2 ) * y0
								+ 2 * ( vx0min2 * vy1 + ( vx0plu2 - 2 * vx1 ) * vy0 - 2 * vx0min1 * vy2 ) * x2
								+ 2 * ( vx0min2 * vy2 - vx0min2 * vy0 ) * x1
								+ 2 * ( ( vx2 - 2 * vx1 + vx0 ) * vy2 - vx0min2 * vy1 + 2 * vx1min2 * vy0 )	* x0
							  ) * y1
							+ ( vx2pow2 - 2 * vx1 * vx2 + vx1pow2 ) * y0 * y0
							+ (
								  2 * ( 2 * vx0min1 * vy2 + ( vx1plu2 - 2 * vx0 ) * vy1 + vx1min2 * vy0 ) * x2
								+ 2 * ( ( vx2 + vx1 - 2 * vx0 ) * vy2 + 2 * vx0min2 * vy1 - vx1min2 * vy0 ) * x1
								+ 2 * ( vx1min2 * vy2 - vx1min2 * vy1 ) * x0
							  ) * y0
							+ ( vy1pow2 - 2 * vy0 * vy1 + vy0pow2 ) * x2 *x2
							+ (
								  2 * ( vy0min1 * vy2 + ( vy0 * vy1 - vy0pow2 ) ) * x1
								+ 2 * (-vy0min1 * vy2 - ( vy1pow2 - vy0mul1 ) ) * x0
							  ) * x2
							+ ( vy2pow2 - 2 * vy0 * vy2 + vy0pow2 ) * x1 * x1
							- 2 * ( vy2pow2 - ( vy1 + vy0 ) * vy2 + vy0mul1 ) * x0 * x1
							+ ( vy2pow2 - 2 * vy1 * vy2 + vy1pow2 ) * x0 * x0
						);
						
			if( sq < 0 ) return null;
			
			var dt: Number = -(
							Math.sqrt( sq )	+ vx0min2 * y1 - vx0min1 * y2
											+ vy0min1 * x2 - vx1min2 * y0
											+ vy1min2 * x0 - vy0min2 * x1 ) / div;
			
			if( dt < 0 || dt > remainingFrameTime ) return null;
			
			var dx: Number = m1.x - m0.x;
			var dy: Number = m1.y - m0.y;

			//-- IntersectionPoint
			var px: Number = particle.x + particle.velocity.x * dt - m0.x;
			var py: Number = particle.y + particle.velocity.y * dt - m0.y;
			
			//-- IntersectionPoint on segment
			var u: Number = ( px * dx + py * dy ) / ( dx * dx + dy * dy );

			if( u < 0 || u > 1 ) return null;
			
			return new DynamicIntersection( this, particle, dt );
		}
		
		public function dIntersectMovableCircle( circle: MovableCircle, remainingFrameTime: Number ): DynamicIntersection
		{
			return null;
		}
		
		public function dIntersectMovableSegment( segment: MovableSegment, remainingFrameTime: Number ): DynamicIntersection
		{
			return null;
		}
		
		public function resolveMovableParticle( particle: MovableParticle ): void
		{
			var dx: Number = m1.x - m0.x;
			var dy: Number = m1.y - m0.y;
			
			//-- compute normal
			var nx: Number = dy;
			var ny: Number = -dx;
			
			var nl: Number = nx * nx + ny * ny;
			
			//-- get ratio
			var u0: Number = ( ( particle.x - m0.x ) * dx + ( particle.y - m0.y ) * dy ) / nl;
			var u1: Number = 1 - u0;

			nl = Math.sqrt( nl );
			nx /= nl;
			ny /= nl;
			
			var vx: Number = m0.velocity.x * u1 + m1.velocity.x * u0;
			var vy: Number = m0.velocity.y * u1 + m1.velocity.y * u0;
			
			var e: Number = ( nx * particle.velocity.x + ny * particle.velocity.y - nx * vx - ny * vy ) * 1;
			
			if( e < .01 ) e = .01;
			
			particle.velocity.x -= nx * e;
			particle.velocity.y -= ny * e;
			
			m0.velocity.x += nx * e * u1;
			m0.velocity.y += ny * e * u1;
			m1.velocity.x += nx * e * u0;
			m1.velocity.y += ny * e * u0;
			
			var drag: Number = .1;
			
			m0.velocity.x -= m0.velocity.x * drag;
			m0.velocity.y -= m0.velocity.y * drag;
			m1.velocity.x -= m1.velocity.x * drag;
			m1.velocity.y -= m1.velocity.y * drag;
			particle.velocity.x -= particle.velocity.x * drag;
			particle.velocity.y -= particle.velocity.y * drag;
		}
		
		public function resolveMovableCircle( circle: MovableCircle ): void
		{
		}
		
		public function resolveMovableSegment( segment: MovableSegment ): void
		{
		}
		
		public function draw( g: Graphics ): void
		{
			g.moveTo( m0.x, m0.y );
			g.lineTo( m1.x, m1.y );
		}
	}
}


/*
			var d: Number = ( ( 2 * vx1 - 2 * vx0 ) * vy2 + ( 2 * vx0 - 2 * vx2 ) * vy1 + ( 2 * vx2 - 2 * vx1 ) * vy0 );
			
			var vx0p2: Number = vx0 * vx0;
			var vx1p2: Number = vx1 * vx1;
			var vx2p2: Number = vx2 * vx2;
			var vy0p2: Number = vy0 * vy0;
			var vy1p2: Number = vy1 * vy1;
			var vy2p2: Number = vy2 * vy2;
			
			var vx0mul1: Number = vx0 * vx1;
			var vy0mul1: Number = vy0 * vy1;
			
			
			var vx0min1: Number = vx0 - vx1;
			
			var t: Number = -( Math.sqrt( ( vx1p2 - 2 * vx0mul1 + vx0p2 ) * y2 * y2
					+ ( ( ( vx0 * 2 - vx1 * 2 ) * vx2 + 2 * vx0mul1 - 2 * vx0p2 ) * y1
					+ ( ( vx0min1 * -2 ) * vx2 - 2 * vx1p2 + 2 * vx0mul1 ) * y0
					+ ( ( vx0min1 *  2 ) * vy1 + ( 2 * vx1 - vx0 * 2 ) * vy0 ) * x2
 					+ ( ( vx0min1 *  2 ) * vy2 + ( 4 * vx2 - 2 * vx0 * 2 ) * vy1 + ( -4 * vx2 + 2 * vx1 + vx0 * 2 ) * vy0 )
					* x1 + ( ( 2 * vx1 - vx0 * 2 ) * vy2 + ( -4 * vx2 + 2 * vx1 + vx0 * 2 ) * vy1
					+ (4 * vx2 - 4 * vx1 ) * vy0 ) * x0 ) * y2 + ( vx2 * vx2 - vx0 * 2 * vx2 + vx0p2 ) * y1 * y1
					+ ( ( -2 * vx2p2 + ( 2 * vx1 + vx0 * 2 ) * vx2 - vx0 * 2 * vx1 ) * y0
					+ ( ( 4 * vx1 - 2 * vx0 * 2 ) * vy2 + ( vx0 * 2 - 2 * vx2 ) * vy1 + ( 2 * vx2 - 4 * vx1 + vx0 * 2 ) * vy0 ) * x2
					+ ( ( vx0 * 2 - 2 * vx2 ) * vy2 + ( 2 * vx2 - vx0 * 2 ) * vy0 ) * x1
					+ ( ( 2 * vx2 - 4 * vx1 + vx0 * 2 ) * vy2 + ( 2 * vx2 - vx0 * 2 ) * vy1 + ( 4 * vx1 - 4 * vx2 ) * vy0 )
					* x0 ) * y1 + ( vx2 * vx2 - 2 * vx1 * vx2 + vx1p2 ) * y0 * y0
					+ ( ( ( 4 * vx0 - 4 * vx1 ) * vy2 + ( 2 * vx2 + 2 * vx1 - 2 * vx0 * 2 ) * vy1 + ( 2 * vx1 - 2 * vx2 ) * vy0 )
					* x2 + ( ( 2 * vx2 + 2 * vx1 - 2 * vx0 * 2 ) * vy2 + ( 2 * vx0 * 2 - 4 * vx2 ) * vy1 + ( 2 * vx2 - 2 * vx1 ) * vy0 )
					* x1 + ( ( 2 * vx1 - 2 * vx2 ) * vy2 + ( 2 * vx2 - 2 * vx1 ) * vy1 ) * x0 ) * y0
					+ ( vy1p2 - 2 * vy0 * vy1 + vy0p2 ) * x2 *x2 + ( ( ( 2 * vy0 - 2 * vy1 ) * vy2 + 2 * vy0 * vy1 - 2 * vy0p2 )
					* x1 + ( ( 2 * vy1 - 2 * vy0 ) * vy2 - 2 * vy1p2 + 2 * vy0mul1 ) * x0 ) * x2
					+ ( vy2p2 - 2 * vy0 * vy2 + vy0p2 ) * x1 * x1 + ( -2 * vy2p2 + ( 2 * vy1 + 2 * vy0 ) * vy2 - 2 * vy0mul1 )
					* x0 * x1 + ( vy2p2 - 2 * vy1 * vy2 + vy1p2 ) * x0 * x0 ) + ( vx1 - vx0 ) * y2 + ( vx0 - vx2 ) * y1
					+ ( vx2 - vx1 ) * y0 + ( vy0 - vy1 ) * x2 + ( vy2 - vy0 ) * x1 + ( vy1 - vy2 ) * x0 ) / d;
				*/