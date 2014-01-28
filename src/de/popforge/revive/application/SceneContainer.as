package de.popforge.revive.application
{
	import de.popforge.revive.display.IDrawAble;
	import de.popforge.revive.forces.FixedSpring;
	import de.popforge.revive.geom.Vec2D;
	import de.popforge.revive.member.ImmovableGate;
	import de.popforge.revive.member.MovableCircle;
	import de.popforge.revive.member.MovableParticle;
	import de.popforge.revive.member.Movable;
	
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;

	public class SceneContainer extends Sprite
	{
		static public function debugStop(): void
		{
			instance.simulation.debugStop();
			instance.onRemoved( null );
		}
		
		static private var instance: SceneContainer;
		
		static protected const COLOR_FORCE: uint = 0xcc6633;
		static protected const COLOR_MOVABLE: uint = 0xababab;
		static protected const COLOR_IMMOVABLE: uint = 0x878787;
		
		static protected const WIDTH: uint = 512;
		static protected const HEIGHT: uint = 512;

		static private const MOUSE_CATCH_DISTANCE2: Number = 16 * 16;
		static private const MOUSE_CATCH_STRENGTH: Number = .025;
		
		public var simulation: Simulation;
		
		protected var iShape: Shape;
		protected var mShape: Shape;
		
		private var mouseSpring: FixedSpring;
		
		public function SceneContainer()
		{
			instance = this;
			
			//-- DISPLAY --//
			iShape = new Shape();
			mShape = new Shape();
			
			addChild( iShape );
			addChild( mShape );
			
			simulation = new Simulation();
	
			addEventListener( Event.ADDED, onAdded );
			addEventListener( Event.REMOVED, onRemoved );
		}
		
		protected function createStageBounds(): void
		{
			
			var immovable: ImmovableGate;
			
			immovable = new ImmovableGate( WIDTH, 0, 0, 0 );
			simulation.addImmovable( immovable );
			immovable = new ImmovableGate( 0, HEIGHT, WIDTH, HEIGHT );
			simulation.addImmovable( immovable );
			immovable = new ImmovableGate( 0, 0, 0, HEIGHT );
			simulation.addImmovable( immovable );
			immovable = new ImmovableGate( WIDTH, HEIGHT, WIDTH, 0 );
			simulation.addImmovable( immovable );
		}
		
		protected function drawImmovables(): void
		{
			iShape.graphics.lineStyle( 0, COLOR_IMMOVABLE );
			
			var drawAble: IDrawAble;
			
			for each( drawAble in simulation.immovables )
			{
				drawAble.draw( iShape.graphics );
			}
		}
		
		private function onAdded( event: Event ): void
		{
			stage.addEventListener( Event.ENTER_FRAME, onEnterFrame );
			stage.addEventListener( MouseEvent.MOUSE_DOWN, onMouseDown );
			stage.addEventListener( MouseEvent.MOUSE_UP, onMouseUp );
		}
		
		private function onRemoved( event: Event ): void
		{
			stage.removeEventListener( Event.ENTER_FRAME, onEnterFrame );
			stage.removeEventListener( MouseEvent.MOUSE_DOWN, onMouseDown );
			stage.removeEventListener( MouseEvent.MOUSE_UP, onMouseUp );
		}
		
		protected function onEnterFrame( event: Event ): void
		{
			if (event == null) {
				simulation.nextFrame();
				return;
			}
			
			if( mouseSpring )
			{
				mouseSpring.x = mouseX;
				mouseSpring.y = mouseY;
			}
			
			simulation.nextFrame();
			simulation.nextFrame();
			
			
			
			//-- UPDATE DISPLAY --//
			var drawAble: IDrawAble;
			
			
			mShape.graphics.clear();
			mShape.graphics.lineStyle( 0, COLOR_MOVABLE );
			for each( drawAble in simulation.movables )
			{
				drawAble.draw( mShape.graphics );
			}
			
			mShape.graphics.lineStyle( 0, COLOR_FORCE );
			for each( drawAble in simulation.forces )
			{
				drawAble.draw( mShape.graphics );
			}
		}
		
		private function onMouseDown( event: MouseEvent ): void
		{
			var movable: Movable;

			var dx: Number;
			var dy: Number;
			
			for each( movable in simulation.movables )
			{
				if( movable is MovableParticle || movable is MovableCircle )
				{
					dx = MovableParticle( movable ).x - mouseX;
					dy = MovableParticle( movable ).y - mouseY;
					
					if( dx * dx + dy * dy < MOUSE_CATCH_DISTANCE2 )
					{
						mouseSpring = new FixedSpring( mouseX, mouseY, MovableParticle( movable ), MOUSE_CATCH_STRENGTH, 0 );
						simulation.addForce( mouseSpring );
						break;
					}
				}
			}
		}
		
		private function onMouseUp( event: MouseEvent ): void
		{
			if( mouseSpring )
			{
				simulation.removeForce( mouseSpring );
			
				mouseSpring = null;
			}
		}
	}
}