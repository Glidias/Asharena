package saboteur.util 
{
	import de.polygonal.ds.Graph;
	import de.polygonal.ds.GraphNode;
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class SaboteurGraph
	{
		private var pathUtil:SaboteurPathUtil;
		public var graph:Graph;
		public var graphGrid:Dictionary;
		public var endPoints:Dictionary;
		
		public var startNodes:Vector.<GraphNode> = new Vector.<GraphNode>();
		private var startPoints:Dictionary = new Dictionary();
		
		private static const ARC_NORTH_MASK:uint = SaboteurPathUtil.ARC_NORTH_EAST | SaboteurPathUtil.ARC_NORTH_WEST | SaboteurPathUtil.ARC_VERTICAL;
		private static const ARC_WEST_MASK:uint = SaboteurPathUtil.ARC_NORTH_WEST | SaboteurPathUtil.ARC_SOUTH_WEST | SaboteurPathUtil.ARC_HORIZONTAL;
		private static const ARC_EAST_MASK:uint = SaboteurPathUtil.ARC_NORTH_EAST | SaboteurPathUtil.ARC_SOUTH_EAST | SaboteurPathUtil.ARC_HORIZONTAL;
		private static const ARC_SOUTH_MASK:uint = SaboteurPathUtil.ARC_SOUTH_EAST | SaboteurPathUtil.ARC_SOUTH_WEST | SaboteurPathUtil.ARC_VERTICAL;
		
		public function SaboteurGraph() 
		{
			graph = new Graph();
			pathUtil = SaboteurPathUtil.getInstance();
			endPoints = new Dictionary();
			graphGrid = new Dictionary();
		}
		
		public function addNode(east:int, south:int, value:uint):GraphNode {
			var key:uint = pathUtil.getGridKey(east, south);
			var node:GraphNode = graphGrid[key];
			if (node != null) {
				
				throw new Error("Node already found at: "+east+" ,"+south);
			}
			node = new GraphNode(graph, [east,south,value]);
			graph.addNode(node);
			
			var toNorth:uint = pathUtil.getGridKey(east, south - 1);
			var toSouth:uint = pathUtil.getGridKey(east, south + 1);
			var toWest:uint = pathUtil.getGridKey(east-1, south);
			var toEast:uint = pathUtil.getGridKey(east + 1, south);
			
			var gotArc:Boolean = false;
			// setup links to neighboring nodes
			var edges:uint = pathUtil.getEdgeValue(value);
			var arcs:uint = pathUtil.getArcValue(value);
			
			if (graphGrid[toNorth] && (edges & SaboteurPathUtil.NORTH) ) {
				//if (arcs & ARC_NORTH_MASK) {
					graph.addMutualArc(node, graphGrid[toNorth] );
					gotArc = true;
				//	throw new Error("N");
				//}
			
			}
			if (graphGrid[toSouth] && (edges & SaboteurPathUtil.SOUTH) )  {
				//if (arcs & ARC_SOUTH_MASK) {
					graph.addMutualArc(node, graphGrid[toSouth] );
					gotArc = true;
				//	throw new Error("s");
				//}
			}
			if (graphGrid[toWest] && (edges & SaboteurPathUtil.WEST) )  {
				//if (arcs & ARC_WEST_MASK) {
					graph.addMutualArc(node, graphGrid[toWest] );
					gotArc = true;
				//	throw new Error("W");
				//}
			}
			if (graphGrid[toEast] && (edges & SaboteurPathUtil.EAST) )  {
				//if (arcs & ARC_EAST_MASK) {
					graph.addMutualArc(node, graphGrid[toEast] );
					gotArc = true;
					//throw new Error("E");
				//}
			}
			
		
		
			graphGrid[key] = node;
				//if (assertGotArc) {
				//	if (!gotArc) throw new Error("Assertion arc created failed!");
				//}
			
			return node;
		}
		
		public function removeNode(east:int, south:int):void {
			var key:uint = pathUtil.getGridKey(east, south);
			var node:GraphNode = graphGrid[key];
			if (node != null) {
				throw new Error("Node already found at: "+east+" ,"+south);
			}
			graph.removeNode(node);
			delete graphGrid[key];
			
		}
		
		
		public function addStartNode(ge:int, gs:int):void {
			var key:uint = pathUtil.getGridKey(ge, gs);
			if (startPoints[key]) return;
		
			var foundNode:GraphNode =  graph.findNode(key);
			if (foundNode == null) throw new Error("Could not find graph node");
			startPoints[key] = foundNode;
			startNodes.push(foundNode);
			
		}
		
		public function addStartNodeDirectly(graphNode:GraphNode):void {
			var keyer:Array = graphNode.val as Array;
			var key:uint = pathUtil.getGridKey(keyer[0], keyer[1]);
			if (startPoints[key]) return;
		
	
			startPoints[key] = graphNode;
			startNodes.push(graphNode);
		}
		
		
		
		public function recalculateEndpoints():void {
			endPoints = new Dictionary();
			graph.clearMarks();
			var i:int = startNodes.length;
			while (--i > -1) {
				
				graph.DFS(false, startNodes[i], visitNodeForEndPoints);
			}
		}
		
		
		
		
		private function visitNodeForEndPoints(node:GraphNode, preflight:Boolean, data:uint):Boolean {
	
			var keyer:Array = node.val as Array;
			var key:uint =  pathUtil.getGridKey(keyer[0], keyer[1]);
			var value:uint = keyer[2];
			var edges:uint = pathUtil.getEdgeValue(key);
			var arcs:uint = pathUtil.getArcValue(key);
			var east:int = keyer[0];
			var south:int = keyer[1];
			var toNorth:uint = pathUtil.getGridKey(east, south - 1);
			var toSouth:uint = pathUtil.getGridKey(east, south + 1);
			var toWest:uint = pathUtil.getGridKey(east-1, south);
			var toEast:uint = pathUtil.getGridKey(east + 1, south);
			var endPointsAccum:uint = 0;
			if (!graphGrid[toNorth] && (edges & SaboteurPathUtil.NORTH) && (arcs & ARC_NORTH_MASK) ) {
				endPointsAccum |= SaboteurPathUtil.NORTH;
			}
			if (!graphGrid[toSouth] && (edges & SaboteurPathUtil.SOUTH) && (arcs & ARC_SOUTH_MASK) ) {
				endPointsAccum |= SaboteurPathUtil.SOUTH;
			}
			if (!graphGrid[toWest] && (edges & SaboteurPathUtil.WEST) && (arcs & ARC_WEST_MASK) ) {
				endPointsAccum |= SaboteurPathUtil.WEST;
			}
			if (!graphGrid[toEast] && (edges & SaboteurPathUtil.EAST) && (arcs & ARC_EAST_MASK) ) {
				endPointsAccum |= SaboteurPathUtil.EAST;
			}
			
			endPoints[key] = endPointsAccum;
			
			return true;

		}
		
	}

}