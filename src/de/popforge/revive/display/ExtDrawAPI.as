package de.popforge.revive.display
{
	import flash.display.Graphics;
	
	public class ExtDrawAPI
	{
		static public function drawCircleSegment( g: Graphics, x: Number, y: Number, radius: Number, startAngle: Number, endAngle: Number ): void
		{
			var angle: Number = startAngle;
			var angleMid: Number;
			var arc: Number = endAngle - angle;
			while( arc < 0 ) arc += Math.PI * 2;
			var segs: Number = Math.ceil( arc / ( Math.PI / 4 ) );
			var segAngle: Number = -arc / segs;
			var theta: Number = -segAngle / 2;
			var cosTheta: Number = Math.cos( theta );
			var ax: Number = Math.cos( angle ) * radius;
			var ay: Number = Math.sin( angle ) * radius;
			var bx: Number;
			var by: Number;
			var cx: Number;
			var cy: Number;
			g.moveTo( ax + x, ay + y );
			for( var i: int = 0 ; i < segs ; i++ )
			{
				angle += theta*2;
				angleMid = angle - theta;
				bx = x + Math.cos( angle ) * radius;
				by = y + Math.sin( angle ) * radius;
				cx = x + Math.cos( angleMid ) * ( radius / cosTheta );
				cy = y + Math.sin( angleMid ) * ( radius / cosTheta );
				g.curveTo( cx, cy, bx, by );
			}
		}
	}
}