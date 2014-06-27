package examples.scenes.test 
{
	import de.popforge.revive.member.MovableCircle;
	import flash.display.Graphics;
	
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class MovableChar extends MovableCircle 
	{
		private var color:uint;
		public static const COLORS:Vector.<uint> = new <uint>[0xFF0000, 0xFF0000, 0x00FF00, 0x0000FF];
		public var following:int = -1;
		public var offsetX:Number = 0;
		public var offsetY:Number = 0;
		public var slot:int = 0;
		public var flankScale:Number=.5;
		
		public function MovableChar( x: Number, y: Number, r: Number, index:int=0 ) 
		{
			super(x, y, r);
			color = COLORS[index];
		}
		
		override public function draw(g:Graphics):void {
			//return;
			g.lineStyle(0, color, .6);
			g.drawCircle( x, y, r );
			
			g.lineStyle(1, 0xA2F233, .6);
			g.moveTo(x, y);
			g.lineTo(x + offsetX, y + offsetY);
	
		}
		
		
		
	}

}