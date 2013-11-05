package tests.islands 
{
	import flash.display.Sprite;
	import flash.events.Event;
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class GridExplore extends Sprite
	{
		public const GRID_SIZE:Number = 32;
		public const RADIUS:Number = .25;
		
		public function GridExplore() 
		{
			addEventListener(Event.ENTER_FRAME, onENterFrame);
		}
		
		private function onENterFrame(e:Event):void 
		{
			graphics.clear();
			var mouseX:Number = this.mouseX;
			var mouseY:Number = this.mouseY;
			var minX:Number = mouseX - RADIUS*GRID_SIZE;
			var minY:Number =  mouseY - RADIUS*GRID_SIZE;
			var maxX:Number =  mouseX + RADIUS*GRID_SIZE;
			var maxY:Number =  mouseY + RADIUS*GRID_SIZE;
			var diameter:Number = RADIUS * 2 * GRID_SIZE;
			graphics.lineStyle(0, 0xFF0000);
			graphics.drawRect(minX, minY, diameter, diameter);
			
			graphics.lineStyle(0, 0x000000);
			var dx:int = Math.floor( minX / GRID_SIZE);
			var dy:int = Math.floor(minY / GRID_SIZE);
			
			var mx:int = Math.ceil( maxX / GRID_SIZE);
			var my:int = Math.ceil(maxY / GRID_SIZE);
			
		
			
			graphics.drawRect( dx * GRID_SIZE, dy * GRID_SIZE, (mx - dx) * GRID_SIZE, (my - dy) * GRID_SIZE );
			
			dx = Math.floor(mouseX / GRID_SIZE);
			dy = Math.floor(mouseY / GRID_SIZE);
			
			graphics.drawRect( dx * GRID_SIZE, dy * GRID_SIZE, GRID_SIZE, GRID_SIZE );
			
		}
		
	}

}