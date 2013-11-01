package arena.systems.islands.jobs 
{
	import de.polygonal.ds.PriorityQueue;
	import jp.progression.commands.Command;
	import jp.progression.commands.lists.SerialList;
	import terraingen.island.mapgen2;
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class CreateIslandResource extends IsleJob
	{
		private var mapgen:mapgen2;
		public var resource:IslandResource;
		
		public function CreateIslandResource() 
		{
			super();
			async = true;
		}
		
		public function init(resource:IslandResource, id:String):void {
			this.resource = resource;
		}
		
		override public function execute():void {
			
		}
		
		override public function dispose():void {
			
		}
	
		
		
		
	}

}