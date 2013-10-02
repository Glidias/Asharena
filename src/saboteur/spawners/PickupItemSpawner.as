package saboteur.spawners 
{
	import ash.core.Engine;
	import util.SpawnerBundle;
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class PickupItemSpawner extends SpawnerBundle
	{
		private var engine:Engine;
		
		
		public function PickupItemSpawner(engine:Engine) 
		{
			ASSETS = [PickupAssets];
			this.engine = engine;
			super();
		}
		
		public function spawn():void {
			
		}
		
	}

}