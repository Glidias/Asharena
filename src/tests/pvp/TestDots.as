package tests.pvp 
{
	import alternativa.types.Float;
	import arena.components.char.EllipsoidPointSamples;
	import flash.display.Sprite;
	import flash.ui.Keyboard;
	import util.geom.Vec3;
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class TestDots extends Sprite
	{
		
		public function TestDots() 
		{
			var pts:EllipsoidPointSamples =  new EllipsoidPointSamples();
			var radius:Vec3 = new Vec3(32, 72, 1);
			pts.init2D( radius, 3 * 10 * 2 * 10 * 1);
			
			var outputRadius:Vec3 =  new Vec3(65, 99, 1);
			
			graphics.beginFill(0xFF0000, 1);
			for (var i:int = 0; i < pts.numPoints; i++) {
				var baseI:int = i * 3;
				graphics.drawCircle(127+pts.points[baseI]*outputRadius.x*pts.maxD, 127+pts.points[baseI+1]*outputRadius.y*pts.maxD, 1);

			}
			
			
			var spr:Sprite = new Sprite();
			spr.x = 127;
			spr.y = 127;
			spr.graphics.lineStyle(0, 0, 1);
			spr.graphics.drawCircle(0, 0, 1);
			spr.scaleX = outputRadius.x;
			spr.scaleY =outputRadius.y
			addChild(spr);
			
		}
		
	}

}