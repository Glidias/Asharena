package arena.systems.islands.jobs 
{
	import arena.systems.islands.IslandGeneration;
	import arena.systems.islands.KDNode;
	import arena.systems.islands.KDZone;
	import de.polygonal.ds.PriorityQueue;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.utils.ByteArray;
	import hashds.ds.alchemy.GrayscaleMap;
	import jp.progression.commands.Command;
	import jp.progression.commands.lists.SerialList;
	import terraingen.island.mapgen2;
	import util.LogTracer;
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class CreateIslandResource extends IsleJob
	{
		
		public static var GENERATOR:IslandGeneration;
		public static var ZONE_TILE_LENGTH:Number = 2048;
		public static var MAX_GENERATE_TILE_LENGTH:Number = 1024;
		
		public var resource:IslandResource;
		public var zone:KDZone;
		public var node:KDNode;
		private var id:String;
		
		public var pending:Boolean = false;
		
		public function toString():String {
			return "{[CreateIslandResource:" + zone.x + "," + zone.y + "]" + id + "}";
		
		}
		
		
		public function CreateIslandResource() 
		{
			super();
			//async = true;
		}
		
		public function getLocation(scaler:Number):Array {
			return [zone.x+node.boundMinX*scaler, zone.y+node.boundMinY*scaler, zone.x + node.boundMaxX*scaler, zone.y + node.boundMaxY*scaler];
		}
		
		public function init(resource:IslandResource, id:String):void {
			this.resource = resource;
			this.id = id;
		}
		
		
		
		override public function execute():void {
		
			GENERATOR.onComplete.addOnce(onGeneratorCompleted);
			GENERATOR.size = node.getMeasuredShortSide() * IslandGeneration.BM_SIZE_SMALL_I * ZONE_TILE_LENGTH;
			if (GENERATOR.size > MAX_GENERATE_TILE_LENGTH) GENERATOR.size = MAX_GENERATE_TILE_LENGTH;
			GENERATOR.generateIslandSeed(id, GENERATOR.size < 128 ? 128 : 0 );
		}
		
		private function onGeneratorCompleted():void 
		{
			//generate grayscale Heightmap into resource and other relavant entiteis
			//resource.heightMap = GENERATOR.mapGen.makeBitmapDataExport("elevation");
			resource.heightMap = GENERATOR.mapGen.makeHeightExport();
		//	 var bytes:ByteArray = GENERATOR.mapGen.makeHeightExport("heightmap", 0,false);
		
			
			ON_COMPLETE.dispatch(this);
		}
		
		override public function cancel():void {
			GENERATOR.onComplete.remove(onGeneratorCompleted);
			GENERATOR.cancel();
		}
		
		override public function dispose():void {
			resource.dispose();
		}
	
		
		
		
	}

}