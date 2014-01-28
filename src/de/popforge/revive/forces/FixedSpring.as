package de.popforge.revive.forces
{
	import de.popforge.revive.display.IDrawAble;
	import de.popforge.revive.member.MovableParticle;
	
	import flash.display.Graphics;
	
	public class FixedSpring
		implements IForce, IDrawAble
	{
		public var x: Number;
		public var y: Number;
		
		public var movableParticle: MovableParticle;
		
		public var tension: Number;
		public var restLength: Number;
		
		public var targetLength:Number = -1;
		
		
		public function FixedSpring( x: Number, y: Number, movableParticle: MovableParticle, tension: Number = .5, restLength: Number = -1 )
		{
			this.x = x;
			this.y = y;
			
			this.movableParticle = movableParticle;
			
			this.tension = tension;
			
			if( restLength == -1 )
			{
				var dx: Number = movableParticle.x - x;
				var dy: Number = movableParticle.y - y;
				
				restLength =  Math.sqrt( dx * dx + dy * dy );
			}
			
			this.restLength = restLength;
		}
		
		public function autoSetRestLength():void {
				var dx: Number = movableParticle.x - x;
				var dy: Number = movableParticle.y - y;
			
				this.restLength =  Math.sqrt( dx * dx + dy * dy );
				
	
		}
		
		public function solve():void
		{
			var dx: Number = ( movableParticle.x + movableParticle.velocity.x ) - x;
			var dy: Number = ( movableParticle.y + movableParticle.velocity.y ) - y;

			var d1: Number = Math.sqrt( dx * dx + dy * dy );
			var d2: Number = tension * ( d1 - restLength ) / d1;
			
			movableParticle.velocity.x -= dx * d2;
			movableParticle.velocity.y -= dy * d2;
			/*
			if (targetLength == 0.1) {
				throw new Error(movableParticle.velocity.x + ", " + movableParticle.velocity.y + ", "+(dx * d2) + ", "+(dy*d2) + ", "+d1 + ", "+d2 + ", "+tension + ", "+restLength);
			}
			*/
		}
		
		public function draw( g: Graphics ): void
		{
			g.moveTo( x, y );
			g.lineTo( movableParticle.x, movableParticle.y );
		}
	}
}