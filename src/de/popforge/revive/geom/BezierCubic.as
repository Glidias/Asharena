package de.popforge.revive.geom
{
	public class BezierCubic
		implements ICurve
	{
		public var x0: Number;
		public var y0: Number;
		public var x1: Number;
		public var y1: Number;
		public var x2: Number;
		public var y2: Number;
		public var x3: Number;
		public var y3: Number;
		
		public function BezierCubic( x0: Number, y0: Number, x1: Number, y1: Number, x2: Number, y2: Number, x3: Number, y3: Number )
		{
			this.x0 = x0;
			this.y0 = y0;
			this.x1 = x1;
			this.y1 = y1;
			this.x2 = x2;
			this.y2 = y2;
			this.x3 = x3;
			this.y3 = y3;
		}
		
		public function getPoint( t: Number ): Vec2D
		{
			var t1m: Number = 1 - t;
			var t2m: Number = t1m * t1m;
			var t3m: Number = t2m * t1m
			var t2p: Number = t * t;
			var t3p: Number = t2p * t;
			var tt2m: Number = t * t2m;
			var t2pt1m: Number = t2p * t1m;
			
			return new Vec2D( t3m*x0+3*tt2m*x1+3*t2pt1m*x2+t3p*x3, t3m*y0+3*tt2m*y1+3*t2pt1m*y2+t3p*y3 );
		}
		
		public function getDerivative( t: Number ): Vec2D
		{
			var t2p: Number = t * t;
			var x: Number = -3*t2p*(x0-3*x1+3*x2-x3)+6*t*(x0-2*x1+x2)-3*(x0-x1);
			var y: Number = -3*t2p*(y0-3*y1+3*y2-y3)+6*t*(y0-2*y1+y2)-3*(y0-y1);
			
			return new Vec2D( x, y );
		}
	}
}