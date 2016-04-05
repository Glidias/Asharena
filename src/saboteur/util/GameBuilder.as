package saboteur.util 
{
	import ash.signals.Signal2;
	import de.polygonal.ds.GraphNode;
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
		
		protected var buildDict:Dictionary;
		protected var buildDictOutside:Dictionary;
		
		public static const FLAG_ATTEMPTED:uint = 1;
		public var signalFlags:uint = 0;
		public const onBuildMade:SignalAny = new SignalAny();
		public const onRemoved:Signal2 = new Signal2();
		
		
		
		public function GameBuilder() 
		{
			buildDict = new Dictionary();
			pathUtil = SaboteurPathUtil.getInstance();
			pathGraph = new SaboteurGraph();
			
			buildDictOutside = new Dictionary();
	
		}
		
		public function getValidResult(east:int, south:int, value:uint):int {
			return pathUtil.getValidResult(buildDict, east, south, value, pathGraph);
		}
		
		public function buildStartNodeAt(gridEast:int, gridSouth:int, value:uint):void {
			buildAt(  gridEast, gridSouth, value  );		
			pathGraph.setAsStartNodeAt(gridEast, gridSouth);
		}
		
		public function buildAt(gridEast:int, gridSouth:int, value:uint, addGraphNode:Boolean=true, buildWithinGame:Boolean=true):void 
		{
			pathUtil.buildAt( buildWithinGame ? buildDict : buildDictOutside, gridEast, gridSouth, value  );		
			if (addGraphNode) {
				pathGraph.addNode(gridEast, gridSouth, value);
				pathGraph.recalculateEndpoints();
			}
					
			
			onBuildMade.dispatch(value, this, gridEast, gridSouth);
			signalFlags = 0;
		}
		
		public function attemptBuild(gridEast:int, gridSouth:int, value:uint):Boolean 
		{
			if ( (attemptBuildResult = getBuildableResult(gridEast, gridSouth, value))  === SaboteurPathUtil.RESULT_VALID) {
				signalFlags = 1;
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
				signalFlags = 1;
				removeAt(gridEast, gridSouth);
				return true;
			}
			
			return false;
		}
		
			private var _playableCount:int = 0;
		private var _playableCollector:Array;
		private var _playCheckValue:uint;
		private static const ALLOW_FLIP:uint = (1 << 0);  // 1
		private static const EARLY_OUT:uint = (1 << 1);

		
		public function getPlayablePathCardLocationsByGraph(locations:Array, value:uint, flags:uint = 1, rangelimit:int=2147483647):int 
		{
		
			_playableCount = 0;
			_playableCollector = locations;
			_playCheckValue = value;
			
			pathGraph.graph.clearMarks();
			
			var len:int = pathGraph.startNodes.length;
			for (var i:int = 0; i < len; i++) {
				var startNode:GraphNode = pathGraph.startNodes[i];
				pathGraph.graph.DLBFS(rangelimit, false, startNode, checkForPlayableEdges, flags);
			}
			return _playableCount;
		}
		
		
		
		private function checkForPlayableEdges(node:GraphNode, preflight:Boolean, data:Object = null):Boolean {
			var valueArr:Array = node.val as Array;
			var east:int = valueArr[0];
			var south:int = valueArr[1];
			var foundOne:Boolean = false;
			var endPoints:Dictionary = pathGraph.endPoints;
			var value:uint = _playCheckValue;
		
		//	var toNorth:uint = pathUtil.getGridKey(east, south - 1);
		//	var toSouth:uint = pathUtil.getGridKey(east, south + 1);
		//	var toWest:uint = pathUtil.getGridKey(east-1, south);
			//var toEast:uint = pathUtil.getGridKey(east + 1, south);
			
			var key:uint =  pathUtil.getGridKey(east, south);
			var endPointAccum:uint = endPoints[key] != null ? endPoints[key] : 0;
			var flags:uint = data != null ? uint(data) : 0;
				var earlyOut:Boolean = (flags & EARLY_OUT) !=0;
				
			if ( (endPointAccum & SaboteurPathUtil.NORTH)!=0 ) {
				if ( pathUtil.getValidResult(buildDict, east, south - 1, value, pathGraph)  === SaboteurPathUtil.RESULT_VALID ) {
					foundOne = true;
				}
			}
			if ( (endPointAccum & SaboteurPathUtil.SOUTH)!=0 ) {
				if ( pathUtil.getValidResult(buildDict, east, south + 1, value, pathGraph)  === SaboteurPathUtil.RESULT_VALID ) {
					foundOne = true;
				}
			}
			if ( (endPointAccum & SaboteurPathUtil.EAST)!=0 ) {
				if ( pathUtil.getValidResult(buildDict, east+1, south, value, pathGraph)  === SaboteurPathUtil.RESULT_VALID ) {
					foundOne = true;
				}
			}
			if ( (endPointAccum & SaboteurPathUtil.WEST)!=0 ) {
				if ( pathUtil.getValidResult(buildDict, east - 1, south , value, pathGraph)  === SaboteurPathUtil.RESULT_VALID ) {
					foundOne = true;
				}
			}
			
			
			return earlyOut && foundOne ? false : true;
		}
		
		
		public function removeAt(gridEast:int, gridSouth:int):Boolean { 
			var key:uint = pathUtil.getGridKey(gridEast, gridSouth);

			
			delete buildDict[key];
			pathGraph.removeNode(gridEast, gridSouth);
			pathGraph.recalculateEndpoints();
			
			
			onRemoved.dispatch(gridEast, gridSouth);
			signalFlags = 0;
			return true;	
		}
		
		
		public function isOccupiedAt(ge:int, gs:int):Boolean {
			return buildDict[pathUtil.getGridKey(ge, gs)] != null;
		}
		
		
	}

}