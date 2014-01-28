package de.popforge.revive.member
{
	/*
	 * ImmovableBezierQuadric
	 * will be assembled by circle- and linesegments
	 * and be handled as a group
	 */
	
	import de.popforge.revive.display.IDrawAble;
	import de.popforge.revive.geom.BezierQuadric;
	import de.popforge.revive.geom.Vec2D;
	import de.popforge.revive.resolve.DynamicIntersection;
	import de.popforge.revive.resolve.IDynamicIntersectionTestAble;
	import de.popforge.revive.resolve.IResolvable;
	
	import flash.display.Graphics;

	public class ImmovableBezierQuadric extends Immovable
		implements IDynamicIntersectionTestAble, IDrawAble
	{
		private var bezier: BezierQuadric;
		
		private var immovables: Array;
		
		public function ImmovableBezierQuadric( x0: Number, y0: Number, x1: Number, y1: Number, x2: Number, y2: Number, outer: Boolean = true )
		{
			bezier = new BezierQuadric( x0, y0, x1, y1, x2, y2 );

			assemble( outer );
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
			if( 1 )
			{
				g.moveTo( bezier.x0, bezier.y0 );
				g.curveTo( bezier.x1, bezier.y1, bezier.x2, bezier.y2 );
			}
			else
			{
				for each( var drawable: IDrawAble in immovables )
				{
					drawable.draw( g );
				}
			}
		}
		
		private function assemble( outer: Boolean, resolution: int = 10, lineTol: Number = .025 ): void
		{
			immovables = new Array();
			
			var c: Boolean = ( bezier.y2 - bezier.y0 ) * ( bezier.x1 - bezier.x0 ) - ( bezier.x2 - bezier.x0 ) * ( bezier.y1 - bezier.y0 ) < 0;
			
			var segments: Array = new Array();
			
			var p0: Vec2D;
			var p1: Vec2D;
			var p2: Vec2D;
			
			var ma: Number;
			var mb: Number;
			var cx: Number;
			var cy: Number;
			var cr: Number;
			var a0: Number;
			var a1: Number;
			var dx: Number;
			var dy: Number;
			
			var px0: Number;
			var py0: Number;
			var px1: Number;
			var py1: Number;
			var px2: Number;
			var py2: Number;
			
			var s: Number = ( 1 / resolution ) / 2;
			var t: Number = 0;
			
			for( var i: int = 0 ; i < resolution ; i++ )
			{
				t = i / resolution;

				p0 = bezier.getPoint( t );
				t += s;
				p1 = bezier.getPoint( t );
				t += s;
				p2 = bezier.getPoint( t );
				
				px0 = p0.x; py0 = p0.y;
				px1 = p1.x; py1 = p1.y;
				px2 = p2.x; py2 = p2.y;

				ma = ( py1 - py0 ) / ( px1 - px0 );
				mb = ( py2 - py1 ) / ( px2 - px1 );
				
				if( Math.abs( ma - mb ) > lineTol )
				{
					cx = ( ma * mb * ( py0 - py2 ) + mb * ( px0 + px1 ) - ma * ( px1 + px2 ) ) / ( 2 * ( mb - ma ) );
					cy = ( -1 / ma ) * ( cx - ( px0 + px1 ) / 2 ) + ( py0 + py1 ) / 2;
					dx = px0 - cx; dy = py0 - cy;
					cr = Math.sqrt( dx * dx + dy * dy );
					a0 = Math.atan2( py0 - cy, px0 - cx );
					a1 = Math.atan2( py2 - cy, px2 - cx );
					
					if( c )
					{
						if( outer )
							immovables.push( new ImmovableCircleOuterSegment( cx, cy, cr, a1, a0 ) );
						else
							immovables.push( new ImmovableCircleInnerSegment( cx, cy, cr, a1, a0 ) );
					}
					else
					{
						if( outer )
							immovables.push( new ImmovableCircleInnerSegment( cx, cy, cr, a0, a1 ) );
						else
							immovables.push( new ImmovableCircleOuterSegment( cx, cy, cr, a0, a1 ) );
					}					
				}
				else
				{
					if( c )
					{
						immovables.push( new ImmovableGate( px2, py2, px0, py0 ) );
					}
					else
					{
						immovables.push( new ImmovableGate( px0, py0, px2, py2 ) );
					}
				}
				
				if( i < resolution - 1 ) immovables.push( new ImmovablePoint( p2.x, p2.y ) );
				
			}
		}
	}
}