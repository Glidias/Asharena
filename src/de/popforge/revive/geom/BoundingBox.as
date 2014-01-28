package de.popforge.revive.geom
{
	public class BoundingBox
	{
		public var xMin: Number;
		public var yMin: Number;
		public var xMax: Number;
		public var yMax: Number;
		
		public function BoundingBox( xMin: Number, yMin: Number, xMax: Number, yMax: Number )
		{
			this.xMin = xMin;
			this.yMin = yMin;
			this.xMax = xMax;
			this.yMax = yMax;
		}
		
		public function intersect( bounds: BoundingBox ): Boolean
		{
			if( xMin > bounds.xMax ) return false;
			if( yMin > bounds.yMax ) return false;
			if( xMax < bounds.xMin ) return false;
			if( yMax < bounds.yMin ) return false;
			
			return true;
		}
	}
}