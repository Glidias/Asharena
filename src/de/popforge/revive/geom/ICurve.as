package de.popforge.revive.geom
{
	public interface ICurve
	{
		function getPoint( t: Number ): Vec2D;
		function getDerivative( t: Number ): Vec2D;
	}
}