package tests.islands 
{
	import alternativa.a3d.controller.SimpleFlyController;
	import alternativa.engine3d.materials.FillMaterial;
	import alternativa.engine3d.RenderingSystem;
	import alternterrain.core.HeightMapInfo;
	import alternterrain.core.QuadChunkCornerData;
	import alternterrain.core.QuadSquare;
	import alternterrain.core.QuadSquareChunk;
	import alternterrain.core.QuadTreePage;
	import alternterrain.objects.TerrainLOD;
	import ash.tick.FrameTickProvider;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import systems.collisions.EllipsoidCollider;
	import systems.SystemPriorities;
	import util.SpawnerBundle;
	import views.engine3d.MainView3D;
	/**
	 * Testing 4 arbituarily positioned "islands" within 1 TerrainLOD instance!
	 * @author Glidias
	 */
	public class TestLowResIslands extends MovieClip 
	{
		private var _template3D:MainView3D;
		private var game:TheGame;
		private var ticker:FrameTickProvider;
		
		public function TestLowResIslands() 
		{
			haxe.initSwc(this);
		
			
			game = new TheGame(stage);
	
			addChild( _template3D = new MainView3D() );
			_template3D.onViewCreate.add(onReady3D);

		}
		
		private function stitchBmpData(data:BitmapData):void {
			var c:uint;
			var c2:uint;
			var r:uint;
			var height:int = data.height;
			var width:int = data.width;
			
			for (var x:int = 1; x < width-1; x++) {
				c = data.getPixel(x, 0) & 0xFF;
				c2 = data.getPixel(x, height-1)  & 0xFF;
				r = c + c2;
				r *= .5;
				data.setPixel(x, 0, (r << 16) | (r << 8) | r);
				data.setPixel(x, height-1, (r<<16) | (r<<8) | r);
			}
			for (var y:int = 1; y < height-1; y++) {
				c = data.getPixel(0, y) & 0xFF;
				c2 = data.getPixel(width-1, y)  & 0xFF;
				r = c + c2;
				r *= .5;
				data.setPixel(0, y, (r << 16) | (r << 8) | r);
				data.setPixel(width-1, y, (r<<16) | (r<<8) | r);
			}
			
			r =  data.getPixel(0, height - 1) & 0xFF;
			r +=  data.getPixel(0, 0) & 0xFF;
			r +=  data.getPixel(width-1, height - 1) & 0xFF;
			r +=  data.getPixel(width-1, 0) & 0xFF;
			r /= 4;
			r = (r << 16) | (r << 8) | r;
			data.setPixel(0, height - 1, r);
			data.setPixel(0, 0, r);
			data.setPixel(width-1, height - 1, r);
			data.setPixel(width-1, 0, r);
		}
		
		private var tCount:int = 0;
	
		private function getQuadTreePage(x:Number,y:Number):QuadTreePage {
			var hm:HeightMapInfo = new HeightMapInfo();
			var bmpSize:int = 129;
			var bmpData:BitmapData =  new BitmapData(bmpSize, bmpSize, false, 0);
			var stich:Boolean = true;
			bmpData.perlinNoise(bmpSize, bmpSize, 4, stich ? 0  : Math.random()*44444, stich, true, 7, true);
			if (stich) stitchBmpData(bmpData);
			//if ( (bmpData.getPixel(0, 0) & 0x0000FF) != (bmpData.getPixel(bmpSize-1, 0) & 0x0000FF) ) throw new Error("A:"+(bmpData.getPixel(0, 0) & 0x0000FF) + ", "+(bmpData.getPixel(bmpSize-1, 0)&0x0000FF));
			
			hm.setFromBmpData(bmpData, bmpSize * 1.3, -bmpSize * 1.3 * 255);
			//hm.setFlat(128);
			var chlid:DisplayObject = addChild( new Bitmap(bmpData));
			chlid.x = tCount++ * bmpSize;
					
			var p:QuadTreePage =  TerrainLOD.installQuadTreePageFromHeightMap(hm, 0, 0, 256, 0);
			
			
		//	p.Level+=SCALE_UP_OFFSET;   // this tells the size of the QuadSquareChunk in world units
		//	p.heightMap.Scale+=SCALE_UP_OFFSET;  // this can be used to adjust Maximum LOD cap to be displayed from base default 8 value.
			
			//x += Math.random() * 13644;
			//y += Math.random() * 13644;
			p.xorg = x;
			p.zorg = y;
			hm.XOrigin = p.xorg;
			hm.ZOrigin = p.zorg;
			
			p.material = new FillMaterial(0xFF0000);
			return p;
		}
		
		private static const SCALE_UP_OFFSET:int = 0;
		
		private function onReady3D():void 
		{
			SpawnerBundle.context3D = _template3D.stage3D.context3D;
			
			game.engine.addSystem( new RenderingSystem(_template3D.scene), SystemPriorities.render );

			
	
			var t:TerrainLOD = new TerrainLOD();
			var size:Number = (128 * 256);
			t.loadNull(SpawnerBundle.context3D, getQuadTreePage(0, 0));
			//t.loadGridOfPages(SpawnerBundle.context3D, new <QuadTreePage>[getQuadTreePage(0,0),getQuadTreePage(size,0),getQuadTreePage(0,size),getQuadTreePage(size,size)], new FillMaterial(0xFF0000) );
			t.gridPagesVector = new <QuadTreePage>[getQuadTreePage(0,0),getQuadTreePage(size,0),getQuadTreePage(0,size),getQuadTreePage(size,size)];
			t.boundBox = null;
			t.debug = true;
			_template3D.scene.addChild(t);
			
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
		
		private function assert(result:Boolean, label:String=""):void {
			if (!result) throw new Error("Assertion failed: " + label);
		}
		
		private function tick(time:Number):void 
		{
				game.engine.update(time);
			_template3D.render();
		}
		
	}

}