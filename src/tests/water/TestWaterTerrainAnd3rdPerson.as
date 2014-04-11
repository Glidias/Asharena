package tests.water 
{
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import systems.animation.IAnimatable;
	import systems.player.a3d.GladiatorStance;
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class TestWaterTerrainAnd3rdPerson extends MovieClip
	{
		private var game:TheGameAS3;
		
		public function TestWaterTerrainAnd3rdPerson() 
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		}
		
		private function onKeyDown(e:KeyboardEvent):void 
		{
			var keyCode:uint = e.keyCode;
			if (keyCode === Keyboard.B && !game.keyPoll.isDown(Keyboard.B)) {
				testAnim(1);
			}
			else if (keyCode === Keyboard.N && !game.keyPoll.isDown(Keyboard.N)) {
				testAnim2(1);
			}
			else if (keyCode === Keyboard.G && !game.keyPoll.isDown(Keyboard.G)) {
				testAnim(.5);
			}
			else if (keyCode === Keyboard.Y && !game.keyPoll.isDown(Keyboard.Y)) {
				testAnim2(0);
			}
			else if (keyCode === Keyboard.H && !game.keyPoll.isDown(Keyboard.H)) {
				testAnim2(.5);
			}
			else if (keyCode === Keyboard.T && !game.keyPoll.isDown(Keyboard.T)) {
				testAnim(0);
			}
		}
		
			private function testAnim(blend:Number=.5):void 
		{
			var arenaSpawner:ArenaSpawner = game.spawner as ArenaSpawner;
			var stance:GladiatorStance = (arenaSpawner.currentPlayerEntity ).get(IAnimatable) as GladiatorStance;
			
			stance.swing(blend);
			
		}
		private function testAnim2(blend:Number=.5):void 
		{
			var arenaSpawner:ArenaSpawner = game.spawner as ArenaSpawner;
			var stance:GladiatorStance = (arenaSpawner.currentPlayerEntity ).get(IAnimatable) as GladiatorStance;
		
			stance.thrust(blend);
			
		}
		
		private function init(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			haxe.initSwc(this);
			game = new TheGameAS3(stage);
		}
		
		
	}

}