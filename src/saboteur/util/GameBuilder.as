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
		public var attemptBuildResult:int;
		
		protected var pathUtil:SaboteurPathUtil;
		public var pathGraph:SaboteurGraph;
		
		public const onBuildMade:SignalAny = new SignalAny();
		
		protected var buildDict:Dictionary;
		protected var buildDictOutside:Dictionary;

		
		public function GameBuilder() 
		{
			buildDict = new Dictionary();
			pathUtil = SaboteurPathUtil.getInstance();
			pathGraph = new SaboteurGraph();
			
			buildDictOutside = new Dictionary();
	
		}
		
		public function buildStartNodeAt(gridEast:int, gridSouth:int, value:uint):void {
			buildAt(  gridEast, gridSouth, value  );		
			pathGraph.addStartNode(gridEast, gridSouth);
		}
		
		public function buildAt(gridEast:int, gridSouth:int, value:uint, addGraphNode:Boolean=true, buildWithinGame:Boolean=true):void 
		{
			pathUtil.buildAt( buildWithinGame ? buildDict : buildDictOutside, gridEast, gridSouth, value  );		
			if (addGraphNode) {
				pathGraph.addNode(gridEast, gridSouth, value);
				pathGraph.recalculateEndpoints();
			}
						
			onBuildMade.dispatch(value, this, gridEast, gridSouth);
		}
		
		public function attemptBuild(gridEast:int, gridSouth:int, value:uint):Boolean 
		{
			if ( (attemptBuildResult=getBuildableResult(gridEast, gridSouth, value))  === SaboteurPathUtil.RESULT_VALID) {
				buildAt(gridEast, gridSouth, value);
				return true;
			}
			return false;
		}
		
		public function canBuildAt(gridEast:int, gridSouth:int, value:uint):Boolean {
			return getBuildableResult(gridEast, gridSouth, value) === SaboteurPathUtil.RESULT_VALID;
		}
		
		public function getBuildableResult(gridEast:int, gridSouth:int, value:uint):int 
		{
			return pathUtil.getValidResult(buildDict, gridEast, gridSouth, value, pathGraph );
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