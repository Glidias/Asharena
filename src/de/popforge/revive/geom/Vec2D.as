package de.popforge.revive.geom
{
	public class Vec2D
	{
		public var x: Number;
		public var y: Number;
		
		public function Vec2D( x: Number, y: Number )
		{
			this.x = x;
			this.y = y;
		}
		
		public function unify(): void
		{
			var l: Number = length();
			
			x /= l;
			y /= l;
		}

		public function scale( t: Number ): void
		{
			x *= t;
			y *= t;
		}
		
		public function length(): Number
		{
			return Math.sqrt( x * x + y * y );
		}
		
		public function clone(): Vec2D
		{
			return new Vec2D( x, y );
		}
		
		public function toString(): String
		{
			return 'Vec2D x: ' + x + ' y: ' + y;
		}
		
		public function normalize():void 
		{
			var l:Number = length();
			l = l > 0 ? 1 / l : 1;
			x *= l;
			y *= l;
		}
	}
}