package examples.scenes
{
	import de.popforge.revive.application.SceneContainer;
	import de.popforge.revive.display.IDrawAble;
	import de.popforge.revive.forces.IForce;
	import de.popforge.revive.member.Immovable;
	import de.popforge.revive.member.ImmovableCircleInnerSegment;
	import de.popforge.revive.member.ImmovableGate;
	import de.popforge.revive.member.ImmovablePoint;
	import de.popforge.revive.member.MovableCircle;
	import de.popforge.revive.member.ImmovableGroup;
	
	public class Billard extends SceneContainer
	{
		public function Billard()
		{
			createScene();
			drawImmovables();
		}
		
		public function createScene(): void
		{
			simulation.globalForce.x = 
			simulation.globalForce.y = 0;
			
			var movableCircle: MovableCircle;
			var immovable: Immovable;
			
			var group: ImmovableGroup;
			
			//-- scale table and balls
			var scale: Number = .175;
			
			var ballRadius: Number = 57.2 * scale / 2;
			
			//-- table
			var innerWidth: Number = 2540 * scale;
			var innerHeight: Number = innerWidth / 2;
			
			//-- local coordinate
			var x0: Number = ( 512 - innerWidth ) / 2;
			var y0: Number = ( 512 - innerHeight ) / 2;

			//////////////// TABLE ////////////////
			
			//-- Mitteltaschen
			var me: Number = 145 * scale;
			var mt: Number = 120 * scale;
			
			//-- Ecktaschen
			var ee: Number = 135 * scale;
			var et: Number = 115 * scale;
			
			//-- ecktaschen offset
			var q0: Number = Math.sqrt( ee * ee / 2 );
			
			var plankWidth: Number = ( innerWidth - 2 * q0 - me ) / 2;
			var plankHeight: Number = innerHeight - 2 * q0;
			
			var x1: Number = x0 + q0;
			var x2: Number = x1 + plankWidth;
			var x3: Number = x2 + me;
			var x4: Number = x3 + plankWidth;
			var x5: Number = x4 + q0;
			
			var y1: Number = y0 + q0;
			var y2: Number = y1 + plankHeight;
			var y3: Number = y2 + q0;

			//-- planks
			var plankElastic: Number = .75;
			
			immovable = new ImmovableGate( x4, y0, x3, y0 );
			immovable.setElastic( plankElastic );
			simulation.immovables.push( immovable );
			immovable = new ImmovableGate( x2, y0, x1, y0 );
			immovable.setElastic( plankElastic );
			simulation.immovables.push( immovable );
			immovable = new ImmovableGate( x3, y3, x4, y3 );
			immovable.setElastic( plankElastic );
			simulation.immovables.push( immovable );
			immovable = new ImmovableGate( x1, y3, x2, y3 );
			immovable.setElastic( plankElastic );
			simulation.immovables.push( immovable );
			immovable = new ImmovableGate( x0, y1, x0, y2 );
			immovable.setElastic( plankElastic );
			simulation.immovables.push( immovable );
			immovable = new ImmovableGate( x5, y2, x5, y1 );
			immovable.setElastic( plankElastic );
			simulation.immovables.push( immovable );
			
			//-- edge points
			var edgePointElastic: Number = .25;
			
			//-- upper plank
			immovable = new ImmovablePoint( x1, y0 );
			immovable.setElastic( edgePointElastic );
			simulation.immovables.push( immovable );
			immovable = new ImmovablePoint( x2, y0 );
			immovable.setElastic( edgePointElastic );
			simulation.immovables.push( immovable );
			immovable = new ImmovablePoint( x3, y0 );
			immovable.setElastic( edgePointElastic );
			simulation.immovables.push( immovable );
			immovable = new ImmovablePoint( x4, y0 );
			immovable.setElastic( edgePointElastic );
			simulation.immovables.push( immovable );
			
			//-- lower plank
			immovable = new ImmovablePoint( x1, y3 );
			immovable.setElastic( edgePointElastic );
			simulation.immovables.push( immovable );
			immovable = new ImmovablePoint( x2, y3 );
			immovable.setElastic( edgePointElastic );
			simulation.immovables.push( immovable );
			immovable = new ImmovablePoint( x3, y3 );
			immovable.setElastic( edgePointElastic );
			simulation.immovables.push( immovable );
			immovable = new ImmovablePoint( x4, y3 );
			immovable.setElastic( edgePointElastic );
			simulation.immovables.push( immovable );
			
			//-- left plank
			immovable = new ImmovablePoint( x0, y1 );
			immovable.setElastic( edgePointElastic );
			simulation.immovables.push( immovable );
			immovable = new ImmovablePoint( x0, y2 );
			immovable.setElastic( edgePointElastic );
			simulation.immovables.push( immovable );
			
			//-- right plank
			immovable = new ImmovablePoint( x5, y1 );
			immovable.setElastic( edgePointElastic );
			simulation.immovables.push( immovable );
			immovable = new ImmovablePoint( x5, y2 );
			immovable.setElastic( edgePointElastic );
			simulation.immovables.push( immovable );
			
			//-- TASCHEN
			var elastic: Number = .1;
			var drag: Number = .5;
			
			//-- Einlaufschraege
			//
			
			var a: Number = ( me - mt ) / 2;
			
			//-- bande (compute by mitteltasche)
			var innerFrame: Number = a / Math.tan( 20 / 180 * Math.PI );
			
			//-- Mitteltaschen Oben
			group = new ImmovableGroup();
			immovable = new ImmovableGate( x2 + a, y0 - innerFrame, x2, y0 );
			immovable.setElastic( elastic );
			group.addImmovable( immovable );
			immovable = new ImmovableGate( x3, y0, x3 - a, y0 - innerFrame );
			immovable.setElastic( elastic );
			group.addImmovable( immovable );
			immovable = new ImmovableCircleInnerSegment( x2 + a + mt / 2, y0 - innerFrame, mt / 2, Math.PI, 0 );
			immovable.setElastic( elastic );
			immovable.setDrag( drag );
			group.addImmovable( immovable );
			immovable = new ImmovablePoint( x2 + a, y0 - innerFrame );
			immovable.setElastic( elastic );
			group.addImmovable( immovable );
			immovable = new ImmovablePoint( x3 - a, y0 - innerFrame );
			immovable.setElastic( elastic );
			group.addImmovable( immovable );
			group.close();
			simulation.immovables.push( group );

			//-- Mitteltaschen Unten
			group = new ImmovableGroup();
			immovable = new ImmovableGate( x2, y3, x2 + a, y3 + innerFrame );
			immovable.setElastic( elastic );
			group.addImmovable( immovable );
			immovable = new ImmovableGate( x3 - a, y3 + innerFrame, x3, y3 );
			immovable.setElastic( elastic );
			group.addImmovable( immovable );
			immovable = new ImmovableCircleInnerSegment( x2 + a + mt / 2, y3 + innerFrame, mt / 2, 0, Math.PI );
			immovable.setElastic( elastic );
			immovable.setDrag( drag );
			group.addImmovable( immovable );
			immovable = new ImmovablePoint( x2 + a, y3 + innerFrame );
			immovable.setElastic( elastic );
			group.addImmovable( immovable );
			immovable = new ImmovablePoint( x3 - a, y3 + innerFrame );
			immovable.setElastic( elastic );
			group.addImmovable( immovable );
			group.close();
			simulation.immovables.push( group );
			
			//-- Ecktaschen
			//
			var e: Number = innerFrame / Math.tan( ( 35 ) / 180 * Math.PI );
			var dx: Number = ( x0 - innerFrame ) - ( x1 - e );
			var dy: Number = ( y2 + e ) - ( y3 + innerFrame );
			var dd: Number = Math.sqrt( dx * dx + dy * dy );
			var d: Number = 30 * scale;
			var radius: Number = Math.sqrt( d * d + dd * dd / 4 );
			var angle: Number = Math.atan( dd / 2 / d );
			
			//-- BL
			group = new ImmovableGroup();
			immovable = new ImmovableGate( x0, y2, x0 - innerFrame, y2 + e );
			immovable.setElastic( elastic );
			group.addImmovable( immovable );
			immovable = new ImmovableGate( x1 - e, y3 + innerFrame, x1, y3 );
			immovable.setElastic( elastic );
			group.addImmovable( immovable );
			immovable = new ImmovablePoint( x0 - innerFrame, y2 + e );
			immovable.setElastic( elastic );
			group.addImmovable( immovable );
			immovable = new ImmovablePoint( x1 - e, y3 + innerFrame );
			immovable.setElastic( elastic );
			group.addImmovable( immovable );
			immovable = new ImmovableCircleInnerSegment( ( ( x0 - innerFrame ) + ( x1 - e ) ) / 2 - Math.cos( Math.PI/4) * d, ( ( y2 + e ) + ( y3 + innerFrame ) ) / 2 + Math.sin( Math.PI/4) * d, radius, -Math.PI/4 + angle, -Math.PI/4 - angle );
			immovable.setElastic( elastic );
			immovable.setDrag( drag );
			group.addImmovable( immovable );
			group.close();
			simulation.immovables.push( group );
			
			//-- TL
			group = new ImmovableGroup();
			immovable = new ImmovableGate( x1, y0, x1 - e, y0 - innerFrame );
			immovable.setElastic( elastic );
			group.addImmovable( immovable );
			immovable = new ImmovableGate( x0 - innerFrame, y1 - e, x0, y1 );
			immovable.setElastic( elastic );
			group.addImmovable( immovable );
			immovable = new ImmovablePoint( x1 - e, y0 - innerFrame );
			immovable.setElastic( elastic );
			group.addImmovable( immovable );
			immovable = new ImmovablePoint( x0 - innerFrame, y1 - e );
			immovable.setElastic( elastic );
			group.addImmovable( immovable );
			immovable = new ImmovableCircleInnerSegment( ( ( x1 - e ) + ( x0 - innerFrame ) ) / 2 - Math.cos( Math.PI/4) * d, ( ( y0 - innerFrame ) + ( y1 - e ) ) / 2 - Math.sin( Math.PI/4) * d, radius, Math.PI*1/4 + angle, Math.PI*1/4 - angle );
			immovable.setElastic( elastic );
			immovable.setDrag( drag );
			group.addImmovable( immovable );
			group.close();
			simulation.immovables.push( group );

			//-- TR
			group = new ImmovableGroup();
			immovable = new ImmovableGate( x4 + e, y0 - innerFrame, x4, y0 );
			immovable.setElastic( elastic );
			group.addImmovable( immovable );
			immovable = new ImmovableGate( x5, y1, x5 + innerFrame, y1 - e );
			immovable.setElastic( elastic );
			group.addImmovable( immovable );
			immovable = new ImmovablePoint( x4 + e, y0 - innerFrame );
			immovable.setElastic( elastic );
			group.addImmovable( immovable );
			immovable = new ImmovablePoint( x5 + innerFrame, y1 - e );
			immovable.setElastic( elastic );
			group.addImmovable( immovable );
			immovable = new ImmovableCircleInnerSegment( ( ( x4 + e ) + ( x5 + innerFrame ) ) / 2 + Math.cos( Math.PI/4) * d, ( ( y0 - innerFrame ) + ( y1 - e ) ) / 2 - Math.sin( Math.PI/4) * d, radius, Math.PI*3/4 + angle, Math.PI*3/4 - angle );
			immovable.setElastic( elastic );
			immovable.setDrag( drag );
			group.addImmovable( immovable );
			group.close();
			simulation.immovables.push( group );
			
			//-- BL
			group = new ImmovableGroup();
			immovable = new ImmovableGate( x5 + innerFrame, y2 + e, x5, y2 );
			immovable.setElastic( elastic );
			group.addImmovable( immovable );
			immovable = new ImmovableGate( x4, y3, x4 + e, y3 + innerFrame );
			immovable.setElastic( elastic );
			group.addImmovable( immovable );
			immovable = new ImmovablePoint( x5 + innerFrame, y2 + e );
			immovable.setElastic( elastic );
			group.addImmovable( immovable );
			immovable = new ImmovablePoint( x4 + e, y3 + innerFrame );
			immovable.setElastic( elastic );
			group.addImmovable( immovable );			
			immovable = new ImmovableCircleInnerSegment( ( ( x5 + innerFrame ) + ( x4 + e ) ) / 2 + Math.cos( Math.PI/4) * d, ( ( y2 + e ) + ( y3 + innerFrame ) ) / 2 + Math.sin( Math.PI/4) * d, radius, -Math.PI*3/4 + angle, -Math.PI*3/4 - angle );
			immovable.setElastic( elastic );
			immovable.setDrag( drag );
			group.addImmovable( immovable );
			group.close();
			simulation.immovables.push( group );

			//-- APPLY BALLS
			var movable: MovableCircle;
			
			var tx: Number = 384;
			var ty: Number = 256;
			
			var x: Number;
			var y: Number;
			
			var dim: int = 5;
			var radiusDouble: Number = ballRadius * 2;
			
			for( var j: int = dim ; j > -1 ; j-- )
			{
				for( var i: int = 0 ; i < j ; i++ )
				{
					x = tx + ( j - 1 ) * Math.sqrt( radiusDouble*radiusDouble - ballRadius*ballRadius );
					y = ty + i * radiusDouble - ( j - 1 ) * ballRadius;

					movable = new MovableCircle( x, y, ballRadius );
					simulation.movables.push( movable );
				}
			}
			
			movable = new MovableCircle( 128, 256, ballRadius );
			simulation.movables.push( movable );

			/*
			
			var m: Matrix = new Matrix();
			
			//-- create "real" balls
			var ball: Ball;
			
			for each( var movable: MovableCircle in simulation.movables )
			{
				m.createGradientBox( movable.radius * 2, movable.radius * 2, 0, -movable.radius, -movable.radius );
				ball = new Ball( movable.radius );
				ball.graphics.beginGradientFill( 'radial', [ 0xffffff, 0xb0b0a0 ], [ 100, 100 ], [ 0, 0xff ], m );
				ball.graphics.drawCircle( 0, 0, movable.radius );
				ball.graphics.endFill();
				ballSprite.addChild( ball );
				movable.addEventListener( MovableCircle.EVENT_UPDATE, ball.update );
			}
			*/
		}
	}
}