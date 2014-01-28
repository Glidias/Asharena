package examples.scenes
{
	import de.popforge.revive.application.SceneContainer;
	import de.popforge.revive.display.IDrawAble;
	import de.popforge.revive.forces.FixedSpring;
	import de.popforge.revive.forces.IForce;
	import de.popforge.revive.member.MovableCircle;
	
	public class NewtonsCradle extends SceneContainer
	{
		public function NewtonsCradle()
		{
			createScene();
			drawImmovables();
		}
		
		public function createScene(): void
		{
			var movableCircle: MovableCircle;
			
			var cx: Number = 272;
			var count: int = 5;
			var radius: Number = 16;
			var x: Number;

			var spring: IForce;
			
			for( var i: int = 0 ; i < count ; i++ )
			{
				x = cx + i * radius * 2 - count * radius;
				
				movableCircle = new MovableCircle( x, 320, radius );
				simulation.movables.push( movableCircle );
				
				spring = new FixedSpring( x, 128, movableCircle );
				simulation.forces.push( spring );
			}
		}
	}
}