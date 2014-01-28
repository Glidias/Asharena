package de.popforge.revive.member
{
	import de.popforge.revive.resolve.DynamicIntersection;
	import de.popforge.revive.resolve.IDynamicIntersectionTestAble;
	import de.popforge.revive.display.IDrawAble;
	import flash.display.Graphics;
	
	public class ImmovableGroup extends Immovable
		implements IDynamicIntersectionTestAble, IDrawAble
	{
		private var immovables: Array;
		
		public function ImmovableGroup()
		{
			immovables = new Array();
		}
		
		public function addImmovable( immovable: Immovable ): void
		{
			immovables.push( immovable );
		}
		
		public function close(): void
		{
		
		}
		
		public function dIntersectMovableParticle( particle: MovableParticle, remainingFrameTime: Number ): DynamicIntersection
		{
			var testable: IDynamicIntersectionTestAble;

			var currentIntersection: DynamicIntersection;
			var nearestIntersection: DynamicIntersection;
			
			for each( testable in immovables )
			{
				currentIntersection = testable.dIntersectMovableParticle( particle, remainingFrameTime );

				if( currentIntersection )
				{
					if( currentIntersection.dt < remainingFrameTime )
					{
						remainingFrameTime = currentIntersection.dt;
						
						nearestIntersection = currentIntersection;
					}
				}
			}
			
			return nearestIntersection;
		}
		
		public function dIntersectMovableCircle( circle: MovableCircle, remainingFrameTime: Number ): DynamicIntersection
		{
			var testable: IDynamicIntersectionTestAble;

			var currentIntersection: DynamicIntersection;
			var nearestIntersection: DynamicIntersection;
			
			for each( testable in immovables )
			{
				currentIntersection = testable.dIntersectMovableCircle( circle, remainingFrameTime );

				if( currentIntersection )
				{
					if( currentIntersection.dt < remainingFrameTime )
					{
						remainingFrameTime = currentIntersection.dt;
						
						nearestIntersection = currentIntersection;
					}
				}
			}
			
			return nearestIntersection;
		}
		
		public function dIntersectMovableSegment( segment: MovableSegment, remainingFrameTime: Number ): DynamicIntersection
		{
			return null;
		}
		
		public function draw( g: Graphics ): void
		{
			for each( var immovable: IDrawAble in immovables )
			{
				immovable.draw( g );
			}
		}
	}
}