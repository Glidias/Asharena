package de.popforge.revive.geom
{
	public class BezierQuadric
		implements ICurve
	{
		public var x0: Number;
		public var y0: Number;
		public var x1: Number;
		public var y1: Number;
		public var x2: Number;
		public var y2: Number;
		
		public function BezierQuadric( x0: Number, y0: Number, x1: Number, y1: Number, x2: Number, y2: Number )
		{
			this.x0 = x0;
			this.y0 = y0;
			this.x1 = x1;
			this.y1 = y1;
			this.x2 = x2;
			this.y2 = y2;
		}
		
		public function getPoint( t: Number ): Vec2D
		{
			return new Vec2D
			(
				( 1 - t ) * ( 1 - t ) * x0 + 2 * t * ( 1 - t ) * x1 + t * t * x2,
				( 1 - t ) * ( 1 - t ) * y0 + 2 * t * ( 1 - t ) * y1 + t * t * y2
			);
		}
		
		public function getDerivative( t: Number ): Vec2D
		{
			var x: Number = t * ( x0 - 2 * x1 + x2 ) - x0 + x1;
			var y: Number = t * ( y0 - 2 * y1 + y2 ) - y0 + y1;
			
			return new Vec2D( x, y );
		}
	}
}