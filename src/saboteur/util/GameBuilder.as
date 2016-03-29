package saboteur.util 
{
	import flash.utils.Dictionary;
	import ash.signals.SignalAny;
	/**
	 * Refactoring. Simplified GameBuilder without the 3D/view stuffz for general model use in other applications.
	 * @author Glenn Ko
	 */
	public class GameBuilder 
	{
		
		private var pathUtil:SaboteurPathUtil;
		public var pathGraph:SaboteurGraph;
		
		public const onBuildMade:SignalAny = new SignalAny();
		
		public var buildDict:Dictionary;

		
		public function GameBuilder() 
		{
			buildDict = new Dictionary();
			pathUtil = SaboteurPathUtil.getInstance();
			pathGraph = new SaboteurGraph();
	
		}
		
		public function buildAt(gridEast:int, gridSouth:int, value:uint, addGraphNode:Boolean=true):void 
		{
			pathUtil.buildAt(buildDict, gridEast, gridSouth, value  );		
			if (addGraphNode) {
				pathGraph.addNode(gridEast, gridSouth, value);
				pathGraph.recalculateEndpoints();
			}
						
			onBuildMade.dispatch(value, this, gridEast, gridSouth);
		}
		
		public function attemptBuild(gridEast:int, gridSouth:int, value:uint):Boolean 
		{
			if ( getBuildableResult(gridEast, gridSouth, value)  === SaboteurPathUtil.RESULT_VALID) {
				buildAt(gridEast, gridSouth, value);
				return true;
			}
			return false;
		}
		
		
		
		private function getBuildableResult(gridEast:int, gridSouth:int, value:uint):int 
		{
			return pathUtil.getValidResult(buildDict, gridEast, gridSouth, value, null );
		}
		
		
		public function attemptRemove(gridEast:int, gridSouth:int):Boolean 
		{
			// any value would be fine in this case...
			if ( isOccupiedAt(gridEast, gridSouth) ) {
				removeAt(gridEast, gridSouth);
				return true;
			}
			
			return false;
		}
		
		public function removeAt(gridEast:int, gridSouth:int):Boolean { 
			var key:uint = pathUtil.getGridKey(gridEast, gridSouth);

			
			delete buildDict[key];
			pathGraph.removeNode(gridEast, gridSouth);
			pathGraph.recalculateEndpoints();
			return true;	
		}
		
		
		public function isOccupiedAt(ge:int, gs:int):Boolean {
			return buildDict[pathUtil.getGridKey(ge, gs)] != null;
		}
	
	}

}