package de.popforge.revive.application
{
	import de.popforge.revive.forces.IForce;
	import de.popforge.revive.geom.Vec2D;
	import de.popforge.revive.member.MovableSegment;

	import de.popforge.revive.member.Immovable;
	import de.popforge.revive.member.Movable;
	import de.popforge.revive.member.MovableCircle;
	import de.popforge.revive.member.MovableParticle;
	import de.popforge.revive.resolve.DynamicIntersection;
	import de.popforge.revive.resolve.IDynamicIntersectionTestAble;
	import de.popforge.revive.resolve.IResolvable;
	
	import flash.utils.getTimer;
	
	public class Simulation
	{
		static public const MAX_FRAME_TIME: uint = 50;

		public var globalForce: Vec2D = new Vec2D( 0, .1 );
		public var globalDrag: Number = .0005;

		public var forces: Array;
		public var movables: Array;
		public var immovables: Array;
		
		private var pause: Boolean = false;
		
		public function Simulation()
		{
			forces = new Array();
			movables = new Array();
			immovables = new Array();
		}
		
		public function nextFrame(): void
		{
			applyEnvirons();
			resolve();
		}
		
		public function debugStop(): void
		{
			pause = true;
		}
		
		private function applyEnvirons(): void
		{
			var movable: Movable;
			var force: IForce;
			
			for each( movable in movables )
			{
				movable.applyGlobalEnvirons( globalForce, globalDrag );
				//movable.updateBounds();
			}

			for each( force in forces )
			{
				force.solve();
			}
		}
		
		private function resolve(): void
		{
			if( pause ) return;
			
			var elapseFrameTime: Number;
			var remainingFrameTime: Number = 1;
			
			var movable: Movable;
			var nearestIntersection: DynamicIntersection;
			
			var millis: uint = getTimer();
			
			while( nearestIntersection = getNearestDynamicIntersection( remainingFrameTime ) )
			{
				if( getTimer() - millis > MAX_FRAME_TIME )
				{
					trace( "Throw an error. Frame is unsolvable" );
					return;
				}
				
				elapseFrameTime = nearestIntersection.dt;
				remainingFrameTime = remainingFrameTime - elapseFrameTime;

				//-- step forward to intersection				
				for each( movable in movables )
				{
					movable.integrate( elapseFrameTime );
				}
				
				if( pause )
				{
					nearestIntersection.resolvable.resolveMovableParticle( MovableParticle( movable ) );
					return;
				}
				
				//-- resolve intersection as collision
				movable = nearestIntersection.movable;

				if( movable is MovableCircle )
				{
					nearestIntersection.resolvable.resolveMovableCircle( movable as MovableCircle );
					continue;
				}
				
				if( movable is MovableParticle )
				{
					nearestIntersection.resolvable.resolveMovableParticle( movable as MovableParticle );
					continue;
				}
				
				if( movable is MovableSegment )
				{
					nearestIntersection.resolvable.resolveMovableSegment( movable as MovableSegment );
					continue;
				}

				// [...]
			}
			
			//-- simulation is complete resolved
			for each( movable in movables )
			{
				movable.integrate( remainingFrameTime );
				//movable.update();
			}
		}
		
		private function getNearestDynamicIntersection( remainingFrameTime: Number ): DynamicIntersection
		{
			var movable: Movable;
			var testable: IDynamicIntersectionTestAble;
			
			var currentIntersection: DynamicIntersection;
			var nearestIntersection: DynamicIntersection;
			
			var i: int = movables.length;
			var k: int;

			while( --i > -1 )
			{
				movable = movables[i]
				
				//-- MOVABLE CIRCLE --//
				if( movable is MovableCircle )
				{
					k = immovables.length;
					
					while( --k > -1 )
					{
						testable = immovables[k];
						
						currentIntersection = testable.dIntersectMovableCircle( movable as MovableCircle, remainingFrameTime );
						
						if( currentIntersection )
						{
							if( currentIntersection.dt < remainingFrameTime )
							{
								remainingFrameTime = currentIntersection.dt;
								nearestIntersection = currentIntersection;
							}
						}
					}
					
					k = i;
					
					while( --k > -1 )
					{
						testable = movables[k];

						currentIntersection = testable.dIntersectMovableCircle( movable as MovableCircle, remainingFrameTime );
						
						if( currentIntersection )
						{
							if( currentIntersection.dt < remainingFrameTime )
							{
								remainingFrameTime = currentIntersection.dt;
								nearestIntersection = currentIntersection;
							}
						}
					}
					continue;
				}
				
				//-- MOVABLE PARTICLE --//
				if( movable is MovableParticle )
				{
					k = immovables.length;
					
					while( --k > -1 )
					{
						testable = immovables[k];
						
						currentIntersection = testable.dIntersectMovableParticle( movable as MovableParticle, remainingFrameTime );
						
						if( currentIntersection )
						{
							if( currentIntersection.dt < remainingFrameTime )
							{
								remainingFrameTime = currentIntersection.dt;
								nearestIntersection = currentIntersection;
							}
						}
					}
					
					k = i;
					
					while( --k > -1 )
					{
						testable = movables[k];
						
						currentIntersection = testable.dIntersectMovableParticle( movable as MovableParticle, remainingFrameTime );
						
						if( currentIntersection )
						{
							if( currentIntersection.dt < remainingFrameTime )
							{
								remainingFrameTime = currentIntersection.dt;
								nearestIntersection = currentIntersection;
							}
						}
					}
				}
				
				//-- MOVABLE PARTICLE --//
				if( movable is MovableSegment )
				{
					k = immovables.length;
					
					while( --k > -1 )
					{
						testable = immovables[k];
						
						currentIntersection = testable.dIntersectMovableSegment( movable as MovableSegment, remainingFrameTime );
						
						if( currentIntersection )
						{
							if( currentIntersection.dt < remainingFrameTime )
							{
								remainingFrameTime = currentIntersection.dt;
								nearestIntersection = currentIntersection;
							}
						}
					}
					
					k = i;
					
					while( --k > -1 )
					{
						testable = movables[k];
						
						currentIntersection = testable.dIntersectMovableSegment( movable as MovableSegment, remainingFrameTime );
						
						if( currentIntersection )
						{
							if( currentIntersection.dt < remainingFrameTime )
							{
								remainingFrameTime = currentIntersection.dt;
								nearestIntersection = currentIntersection;
							}
						}
					}
				}
				
				// [...]
			}
			
			return nearestIntersection;
		}
		
		public function addForce( force: IForce ): void
		{
			removeForce( force );
			forces.push( force );
		}
		
		public function removeForce( force: IForce ): void
		{
			var i: int = forces.length;
			while( --i > -1 )
			{
				if( forces[i] == force )
				{
					forces.splice( i, 1 );
					break;
				}
			}
		}
		
		public function addMovable( movable: Movable ): void
		{
			removeMovable( movable );
			movables.push( movable );
		}
		
		public function removeMovable( movable: Movable ): void
		{
			var i: int = movables.length;
			while( --i > -1 )
			{
				if( movables[i] == movable )
				{
					movables.splice( i, 1 );
					break;
				}
			}
		}
		
		public function addImmovable( immovable: Immovable ): void
		{
			removeImmovable( immovable );
			immovables.push( immovable );
		}
		
		public function removeImmovable( immovable: Immovable ): void
		{
			var i: int = immovables.length;
			while( --i > -1 )
			{
				if( immovables[i] == immovable )
				{
					immovables.splice( i, 1 );
					break;
				}
			}
		}
	}
}
