package arena.systems.islands.jobs 
{
	import ash.signals.Signal1;
	import hashds.ds.Indexable;
	import hashds.ds.IPrioritizable;
	//import de.polygonal.ds.Prioritizable;

	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class IsleJob implements IPrioritizable, Indexable
	{
		//public var async:Boolean;
		public static const ON_COMPLETE:Signal1 = new Signal1();
		
		public var priority:Number;
		//public var position:int;
		public var index:int;
		
		public var next:IsleJob;
		public var prev:IsleJob;
		
		public function IsleJob() 
		{
			
		}
		
		public function execute():void {
			
		}
		
		public function dispose():void {
			
		}
		
		public function cancel():void {
			
		}
		

		
	}

}