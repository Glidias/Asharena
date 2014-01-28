package examples.scenes
{
	import de.popforge.revive.application.SceneContainer;
	import de.popforge.revive.display.IDrawAble;
	import de.popforge.revive.forces.IForce;
	import de.popforge.revive.forces.Spring;
	import de.popforge.revive.member.ImmovableCircleInner;
	import de.popforge.revive.member.MovableCircle;
	import de.popforge.revive.member.MovableParticle;
	import de.popforge.revive.member.MovableSegment;
	
	public class TrySegments extends SceneContainer
	{
		public function TrySegments()
		{
			createScene();
			createStageBounds();
			drawImmovables();
		}
		
		private function createSpringPoly( x: Number, y: Number, verticesNum: uint, radius: Number, cw: Boolean = true ): void
		{
			if( verticesNum < 3 || verticesNum > 4 )
			{
				trace( "not supported yet." );
				return;
			}
			
			///-- CREATE VERTICES
			var vertex: MovableParticle;
			var vertices: Array = new Array();
			
			var angle: Number = 0;
			var angleStep: Number = ( Math.PI * 2 ) / verticesNum;
			
			for( var i: int = 0 ; i < verticesNum ; i++ )
			{
				vertex = new MovableParticle( x + Math.cos( angle ) * radius, y + Math.sin( angle ) * radius );
				vertex.velocity.x = Math.random() * 2 - 1;
				vertex.velocity.y = Math.random() * 2 - 1;
				
				simulation.addMovable( vertex );
				
				angle += angleStep;
				
				vertices.push( vertex );
			}
			
			//-- CREATE SPRINGS AND SOLID HULL
			var vertexA: MovableParticle;
			var vertexB: MovableParticle;
			
			var spring: Spring;
			var segment: MovableSegment;
			
			var a: int = verticesNum;
			var j: int;
			
			for( j = a - 1, i = 0 ; i < a ; j = i, i++ )
			{
				vertexA = vertices[i];
				vertexB = vertices[j];
				
				spring = new Spring( vertexA, vertexB );
				simulation.addForce( spring );
				
				if( cw ) segment = new MovableSegment( vertexA, vertexB );
				else segment = new MovableSegment( vertexB, vertexA );
				simulation.addMovable( segment );
			}
			
			//-- for a cube
			if( verticesNum == 4 )
			{
				spring = new Spring( vertices[0], vertices[2] );
				simulation.addForce( spring );
				spring = new Spring( vertices[1], vertices[3] );
				simulation.addForce( spring );
			}
		}
		
		public function createScene(): void
		{
			var px: Number = 256;
			var py: Number = 256;

			var width: Number = 48;
			var height: Number = 48;
			
			/*
			var vertexA: MovableParticle = new MovableParticle( px - width/2, py - height/2 );
			vertexA.velocity.x = 0;//-Math.random();
			vertexA.velocity.y = .1;//Math.random() * 2 - 1;
			simulation.addMovable( vertexA );
			var vertexB: MovableParticle = new MovableParticle( px + width/2, py - height/2 );
			vertexB.velocity.x = 0;//Math.random();
			vertexB.velocity.y = .11;//Math.random() * 2 - 1;
			simulation.addMovable( vertexB );
			
			var segment: MovableSegment = new MovableSegment( vertexA, vertexB );
			simulation.addMovable( segment );
			
			var spring: Spring = new Spring( vertexA, vertexB );
			simulation.addForce( spring );
			*/
			
			//createSpringPoly( 256, 256, 3, 96, false );
			//createSpringPoly( 256, 256, 4, 32, true );
			createSpringPoly( 128, 256, 4, 32 );
			createSpringPoly( 384, 256, 4, 48 );
			createSpringPoly( 64, 256, 4, 48 );
			
			//var particle: MovableParticle = new MovableParticle( px, py + 128 );
			
			//particle.velocity.x = Math.random() * 2 - 1;
			//particle.velocity.y = -5;
			//simulation.addMovable( particle );
			
			
			//var immovable: ImmovableCircleInner = new ImmovableCircleInner( 256, 256, 255 );
			//simulation.addImmovable( immovable );
			

			/*
			var vertexA: MovableParticle = new MovableParticle( px - width/2, py - height/2 );
			simulation.addMovable( vertexA );
			var vertexB: MovableParticle = new MovableParticle( px + width/2, py - height/2 );
			simulation.addMovable( vertexB );
			var vertexC: MovableParticle = new MovableParticle( px + width/2, py + height/2 );
			simulation.addMovable( vertexC );
			var vertexD: MovableParticle = new MovableParticle( px - width/2, py + height/2 );
			simulation.addMovable( vertexD );
			
			var spring: Spring;
			
			//-- edges
			spring = new Spring( vertexA, vertexB );
			simulation.addForce( spring );
			spring = new Spring( vertexB, vertexC );
			simulation.addForce( spring );
			spring = new Spring( vertexC, vertexD );
			simulation.addForce( spring );
			spring = new Spring( vertexD, vertexA );
			simulation.addForce( spring );
			
			//-- cross beam
			spring = new Spring( vertexA, vertexC );
			simulation.addForce( spring );
			spring = new Spring( vertexB, vertexD );
			simulation.addForce( spring );*/
		}
	}
}