package spawners.arena.terrain 
{
	import alternativa.a3d.collisions.CollisionBoundNode;
	import alternativa.a3d.rayorcollide.TerrainITCollide;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.materials.Material;
	import alternterrain.core.HeightMapInfo;
	import alternterrain.core.QuadTreePage;
	import alternterrain.objects.TerrainLOD;
	import alternterrain.resources.LoadAliases;
	import flash.display.BitmapData;
	import flash.utils.ByteArray;
	import util.geom.Vec3;
	import util.SpawnerBundle;
	import alternativa.engine3d.alternativa3d;
	use namespace alternativa3d;
	
	
	
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class TerrainBase extends SpawnerBundle
	{
		private var assetClasse:Class;
		private var terrainHeightScale:Number;
		private var mapScale:Number;
		private var tileScale:Number;
		
		
		public var terrain:TerrainLOD;
		public var terrainCollision:CollisionBoundNode;
		public var loadedPage:QuadTreePage;
		public var normalMap:BitmapData;
		
		public var TERRAIN_HEIGHT_SCALE:Number;
		public var MAX_POSSIBLE_HEIGHT:Number;
		public var FAR_CLIPPING:Number;
		 
		
		public function TerrainBase(assetClasse:Class, heightScale:Number=1, tileScale:Number=1 ) 
		{
			this.tileScale = tileScale;
			TERRAIN_HEIGHT_SCALE = heightScale * tileScale;
			new LoadAliases();
			this.assetClasse = assetClasse;
			ASSETS = [assetClasse, MistEdge];
			var useScale:Number = TERRAIN_HEIGHT_SCALE >= 1 ? TERRAIN_HEIGHT_SCALE : 1;
			MAX_POSSIBLE_HEIGHT = Math.sqrt( 64 * 255 + 256) * useScale;
			FAR_CLIPPING = Math.sqrt(MAX_POSSIBLE_HEIGHT * MAX_POSSIBLE_HEIGHT + 2 * 333901639.34426229508196721311475 * MAX_POSSIBLE_HEIGHT) * 1  * 3
			super();
		}
		
		override protected function init():void {
			
			
			var untyped:* = assetClasse;
			var data:ByteArray = new untyped.TERRAIN();
			
			data.uncompress();
			//throw new Error(	data.readObject() );
			loadedPage = new QuadTreePage();
			loadedPage.readExternal(data);
			
			normalMap = (new untyped.NORMAL()).bitmapData;
			
			

			super.init();
		}
		
		
		public function samplePos(pos:Vec3):Number {
			return loadedPage.heightMap.Sample(  (pos.x - terrain._x) / terrain._scaleX, -(pos.y - terrain._y) / terrain._scaleY ) * terrain._scaleZ + terrain._z;
		}
		public function sample(x:Number, y:Number):Number {
		//	throw new Error(  loadedPage.heightMap.Sample(  (x - terrain.x) / terrain.scaleX, -(y - terrain.y) / terrain.scaleY ) );
			return loadedPage.heightMap.Sample(  (x - terrain._x) / terrain._scaleX, -(y - terrain._y) / terrain._scaleY ) * terrain._scaleZ + terrain._z;
		}
		
		public function sampleObjectPos(pos:Object3D):Number {
			return loadedPage.heightMap.Sample(  (pos.x - terrain._x) / terrain.scaleX, -(pos.y - terrain._y) / terrain._scaleY ) * terrain._scaleZ + terrain._z;
		}
		
		public function getNewTerrain(material:Material, uvTileSize:int = 0, requirements:int = -1, terrainHeightScale:Number = 1, mapScale:Number = 1, tileSize:Number = 256):TerrainLOD {
			terrain = new TerrainLOD();
			terrain.scaleZ = TERRAIN_HEIGHT_SCALE;
			
			terrain.scaleX = tileScale;
			terrain.scaleY = tileScale;

			terrain.loadSinglePage(context3D, loadedPage, material, uvTileSize, requirements, tileSize);
			loadedPage.heightMap.XOrigin = loadedPage.xorg;
			loadedPage.heightMap.ZOrigin = loadedPage.zorg;
			//new Standard
			
			
			 SpawnerBundle.uploadResources( terrain.getResources());
			 return terrain;
			
		}
		
		public function getTerrainCollisionNode():CollisionBoundNode {
			 terrainCollision = TerrainITCollide.createNode(terrain);
			 return terrainCollision;
		}
		
		
		
	}

}