package de.popforge.revive.forces
{
	import de.popforge.revive.display.IDrawAble;
	import de.popforge.revive.member.MovableParticle;
	
	import flash.display.Graphics;
	
	public class Spring
		implements IForce, IDrawAble
	{
		public var m0: MovableParticle;
		public var m1: MovableParticle;

		public var tension: Number;
		public var restLength: Number;
		
		public var targetLength:Number = -1;
		
		public function Spring( m0: MovableParticle, m1: MovableParticle, tension: Number = .5, restLength: Number = -1 )
		{
			this.m0 = m0;
			this.m1 = m1;
			
			this.tension = tension;
			
			if( restLength == -1 )
			{
				var dx: Number = m0.x - m1.x;
				var dy: Number = m0.y - m1.y;
				
				restLength = Math.sqrt( dx * dx + dy *dy );
			}
			
			this.restLength = restLength;
		}
		
		public function autoSetRestLength():void {
				var dx: Number = m0.x - m1.x;
				var dy: Number = m0.y - m1.y;
				
				restLength = Math.sqrt( dx * dx + dy * dy );
			
		}
		
		public function solve():void
		{
			var dx: Number = ( m1.x + m1.velocity.x ) - ( m0.x + m0.velocity.x );
			var dy: Number = ( m1.y + m1.velocity.y ) - ( m0.y + m0.velocity.y );

			var d1: Number = Math.sqrt( dx * dx + dy * dy );
			var d2: Number = tension * ( d1 - restLength ) / d1;
			
			dx *= d2;
			dy *= d2;
			
			m0.velocity.x += dx;
			m0.velocity.y += dy;
			m1.velocity.x -= dx;
			m1.velocity.y -= dy;			
		}
		
		public function draw( g: Graphics ): void
		{
			g.moveTo( m0.x, m0.y );
			g.lineTo( m1.x, m1.y );
		}
	}
}