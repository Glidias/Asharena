package de.popforge.revive.resolve
{
	import de.popforge.revive.member.Movable;
	
	public class DynamicIntersection
	{
		public var resolvable: IResolvable;
		public var movable: Movable;
		
		public var dt: Number;
		
		public function DynamicIntersection( resolvable: IResolvable, movable: Movable, dt: Number )
		{
			this.resolvable = resolvable;
			this.movable = movable;
			
			this.dt = dt;
		}
	}
}