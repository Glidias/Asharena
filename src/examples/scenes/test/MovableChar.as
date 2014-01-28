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
		public static const COLORS:Vector.<uint> = new <uint>[0xFF0000, 0x00FF00, 0x0000FF, 0xFFFF00];
		
		public function MovableChar( x: Number, y: Number, r: Number, index:int=0 ) 
		{
			super(x, y, r);
			color = COLORS[index];
		}
		
		override public function draw(g:Graphics):void {
			g.lineStyle(0, color, .6);
			g.drawCircle( x, y, Math.max( r, 3 )*1 );
		}
		
	}

}