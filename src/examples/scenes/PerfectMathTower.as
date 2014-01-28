package examples.scenes
{
	import de.popforge.revive.application.SceneContainer;
	import de.popforge.revive.display.IDrawAble;
	import de.popforge.revive.forces.IForce;
	import de.popforge.revive.forces.Spring;
	import de.popforge.revive.member.Immovable;
	import de.popforge.revive.member.MovableCircle;
	
	public class PerfectMathTower extends SceneContainer
	{
		public function PerfectMathTower()
		{
			createScene();
			createStageBounds();
			drawImmovables();
		}
		
		public function createScene(): void
		{
			var movableCircle: MovableCircle;
			var lastMovableCircle: MovableCircle;
			var force: IForce;
			
			var radius: Number = 16;
			var count: int = 10;
			
			for( var i: int = 0 ; i < count ; i++ )
			{
				movableCircle = new MovableCircle( 128, 512 - radius - i * 2 * radius, radius );
				simulation.addMovable( movableCircle );
				
				if( lastMovableCircle )
				{
					force = new Spring( movableCircle, lastMovableCircle );
					simulation.addForce( force );
				}
				
				lastMovableCircle = movableCircle;
			}
			
			var immovable: Immovable;
		}
	}
}