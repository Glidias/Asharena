package tests.islands 
{
	import alternativa.engine3d.core.Camera3D;
	import arena.systems.islands.IslandExploreSystem;
	import ash.core.Engine;
	import ash.tick.FrameTickProvider;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import spawners.arena.IslandGenWorker;
	import systems.SystemPriorities;
	import util.SpawnerBundle;
	import util.SpawnerBundleA;
	import util.SpawnerBundleLoader;
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class TestMouseIslandGen extends MovieClip
	{
		private var exploreSystem:IslandExploreSystem;
		private var camera:Camera3D;
		public var engine:Engine;
		public var ticker:FrameTickProvider;
		
		
		static private const ZONE_TILES:Number = 2048;
		static private const TERRAIN_TILE_SIZE:Number = 256;
		static private const PREVIEW_ZONE_SIZE:Number = 64;
		static public const RADIUS:Number = .25;
		private var bundleLoader:SpawnerBundleLoader;
		
		public function TestMouseIslandGen() 
		{
			haxe.initSwc(this);
			TheGame;
			
			engine = new Engine();
			ticker = new FrameTickProvider(stage);
			
			
			bundleLoader = new SpawnerBundleLoader(stage, onSpawnerBundleLoaded, new <SpawnerBundle>[new SpawnerBundleA([IslandGenWorker])]);
		
		}
		
		
		private function onSpawnerBundleLoaded():void {
			exploreSystem = new IslandExploreSystem(camera = new Camera3D(1, 2000), null, ZONE_TILES, TERRAIN_TILE_SIZE);
			exploreSystem.zoneVisDistance = RADIUS;
			engine.addSystem(exploreSystem,SystemPriorities.postRender);
			
			ticker.add(tick);
			ticker.start();
		}
		
		public function tick(time:Number):void 
		{
			var mapScale:Number = (ZONE_TILES * TERRAIN_TILE_SIZE) / PREVIEW_ZONE_SIZE;
			
			camera.x = mouseX*mapScale;
			camera.y = mouseY*mapScale;
			
			
			graphics.clear();
			graphics.lineStyle(0, 0x000000);

			var minX:Number = mouseX - RADIUS*PREVIEW_ZONE_SIZE;
			var minY:Number =  mouseY - RADIUS*PREVIEW_ZONE_SIZE;
			var maxX:Number =  mouseX + RADIUS*PREVIEW_ZONE_SIZE;
			var maxY:Number =  mouseY + RADIUS*PREVIEW_ZONE_SIZE;
			var diameter:Number = RADIUS * 2 * PREVIEW_ZONE_SIZE;
			graphics.lineStyle(0, 0xFF0000);
			graphics.drawRect(minX, minY, diameter, diameter);
			
			graphics.lineStyle(0, 0x000000);
			var dx:int = Math.floor( minX / PREVIEW_ZONE_SIZE);
			var dy:int = Math.floor(minY / PREVIEW_ZONE_SIZE);
			
			var mx:int = Math.ceil( maxX / PREVIEW_ZONE_SIZE);
			var my:int = Math.ceil(maxY / PREVIEW_ZONE_SIZE);
			
		
			
			graphics.drawRect( dx * PREVIEW_ZONE_SIZE, dy * PREVIEW_ZONE_SIZE, (mx - dx) * PREVIEW_ZONE_SIZE, (my - dy) * PREVIEW_ZONE_SIZE );
			
			dx = Math.floor(mouseX / PREVIEW_ZONE_SIZE);
			dy = Math.floor(mouseY / PREVIEW_ZONE_SIZE);
			
			graphics.drawRect( dx * PREVIEW_ZONE_SIZE, dy * PREVIEW_ZONE_SIZE, PREVIEW_ZONE_SIZE, PREVIEW_ZONE_SIZE );
			
			engine.update(time);
		}
		
	}

}