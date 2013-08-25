package tests 
{
	import alternativa.a3d.controller.SimpleFlyController;
	import alternativa.engine3d.RenderingSystem;
	import ash.tick.FrameTickProvider;
	import flash.display.MovieClip;
	import systems.collisions.EllipsoidCollider;
	import systems.SystemPriorities;
	import views.engine3d.MainView3D;
	/**
	 * ...
	 * @author Glidias
	 */
	public class TestBuild3D extends MovieClip 
	{
		private var _template3D:MainView3D;
		private var game:TheGame;
		private var ticker:FrameTickProvider;
		
		public function TestBuild3D() 
		{
			haxe.initSwc(this);
		
			
			game = new TheGame(stage);
	
			addChild( _template3D = new MainView3D() );
			_template3D.onViewCreate.add(onReady3D);
			
				
		
		}
		
		private function onReady3D():void 
		{
			game.engine.addSystem( new RenderingSystem(_template3D.scene), SystemPriorities.render );

			
			var spectatorPerson:SimpleFlyController =new SimpleFlyController( 
						new EllipsoidCollider(GameSettings.SPECTATOR_RADIUS.x, GameSettings.SPECTATOR_RADIUS.y, GameSettings.SPECTATOR_RADIUS.z), 
						null ,
						stage, 
						_template3D.camera, 
						GameSettings.SPECTATOR_SPEED,
						GameSettings.SPECTATOR_SPEED_SHIFT_MULT);
			
						game.gameStates.spectator.addInstance(spectatorPerson).withPriority(SystemPriorities.postRender);
		
	
			
			game.engine.addSystem( spectatorPerson, SystemPriorities.postRender ) ;
		
		
			ticker = new FrameTickProvider(stage);
			ticker.add(tick);
			ticker.start();
			
		}
		
		private function tick(time:Number):void 
		{
				game.engine.update(time);
			_template3D.render();
		}
		
	}

}