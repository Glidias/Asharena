package  recast
{
	import flash.display.Sprite;
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class RecastPreviewer extends Sprite
	{
		
		private static const WORLD_SCALE:Number =5 
		private static var SCALE:Number = 10 / WORLD_SCALE;
		
		public function RecastPreviewer() 
		{
			this.scaleX = this.scaleY = SCALE;
			this.x = 300;
			this.y = 300;
		}
		
		public function drawNavMesh(tiles:Array):void
		{
			graphics.clear();
			//draw each nav mesh tile
			for ( var t:int = 0; t < tiles.length; t++)
			{
				var polys:Array = tiles[t].polys;
				//draw each poly
				for ( var p:int = 0; p < polys.length; p++)
				{
					var poly:Object = polys[p];
					//draw each tri in the poly
					var triVerts:Array = poly.verts;
					this.graphics.beginFill(0x6796a5, 0.5 );
					for ( var i:int = 0; i < poly.triCount; i++)
					{
						//each triangle has 3 vertices
						//each vert has 3 points, xyz
						var p1:Object = {x: triVerts[(i * 9) + 0], y: triVerts[(i * 9) + 1], z: triVerts[(i * 9) + 2]  };
						var p2:Object = {x: triVerts[(i * 9) + 3], y: triVerts[(i * 9) + 4], z: triVerts[(i * 9) + 5]  };
						var p3:Object = {x: triVerts[(i * 9) + 6], y: triVerts[(i * 9) + 7], z: triVerts[(i * 9) + 8]  };
					
						this.graphics.lineStyle(0.1, 0x123d4b);
						
						this.graphics.moveTo(p1.x, p1.z);
						this.graphics.lineTo(p2.x, p2.z);
						this.graphics.lineTo(p3.x, p3.z);
						this.graphics.lineTo(p1.x, p1.z);
						
					}
					this.graphics.endFill();
				}
			}
			
			//draw origin
			this.graphics.lineStyle(0.1, 0x00ff00);
			this.graphics.moveTo(0, 0);
			this.graphics.lineTo(0, 10 );
			this.graphics.lineStyle(0.1, 0x0000ff);
			this.graphics.moveTo(0, 0);
			this.graphics.lineTo(10, 0);
		}
		
		public function drawMesh(tris:Array, verts:Array):void
		{
			
			//this.graphics.clear();
			
			for ( var i:int = 0; i < tris.length; i += 3)
			{
				var v1:Object = verts[tris[i]];
				var v2:Object = verts[tris[i + 1]];
				var v3:Object = verts[tris[i + 2]];
				
				this.graphics.lineStyle(0.1, 0x514a3c);
				this.graphics.beginFill(0x92856d, 1 );
				this.graphics.moveTo(v1.x, v1.z);
				this.graphics.lineTo(v2.x, v2.z);
				this.graphics.lineTo(v3.x, v3.z);
				this.graphics.lineTo(v1.x, v1.z);
				this.graphics.endFill();
			}
			
		}
		
		
	}

}