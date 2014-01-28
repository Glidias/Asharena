package de.popforge.revive.member
{
	import de.popforge.revive.geom.Vec2D;
	
	public class Movable
	{
		static internal const EPLISON_DT: Number = -.0000001;
		
		public function applyGlobalEnvirons( globalForce: Vec2D, globalDrag: Number ): void
		{
		}
		
		public function integrate( dt: Number ): void
		{
		}
	}
}