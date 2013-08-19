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
		
		///*
		public static const ARC_NORTH_MASK:uint = SaboteurPathUtil.ARC_NORTH_EAST | SaboteurPathUtil.ARC_NORTH_WEST | SaboteurPathUtil.ARC_VERTICAL;
		public static const ARC_WEST_MASK:uint = SaboteurPathUtil.ARC_NORTH_WEST | SaboteurPathUtil.ARC_SOUTH_WEST | SaboteurPathUtil.ARC_HORIZONTAL;
		public static const ARC_EAST_MASK:uint = SaboteurPathUtil.ARC_NORTH_EAST | SaboteurPathUtil.ARC_SOUTH_EAST | SaboteurPathUtil.ARC_HORIZONTAL;
		public static const ARC_SOUTH_MASK:uint = SaboteurPathUtil.ARC_SOUTH_EAST | SaboteurPathUtil.ARC_SOUTH_WEST | SaboteurPathUtil.ARC_VERTICAL;
		//*/
		
		public function SaboteurGraph() 
		{
			graph = new Graph();
			pathUtil = SaboteurPathUtil.getInstance();
			endPoints = new Dictionary();
			graphGrid = new Dictionary();
		}
		
		public function checkLocationLinked(east:int, south:int, value:uint):Boolean {
			var key:uint = pathUtil.getGridKey(east, south);
			var toNorth:uint = pathUtil.getGridKey(east, south - 1);
			var toSouth:uint = pathUtil.getGridKey(east, south + 1);
			var toWest:uint = pathUtil.getGridKey(east-1, south);
			var toEast:uint = pathUtil.getGridKey(east + 1, south);
			
			var gotArc:Boolean = false;
			// setup links to neighboring nodes
			var edges:uint = pathUtil.getEdgeValue(value);
			var arcs:uint = pathUtil.getArcValue(value);
			
			if (graphGrid[toNorth] && (edges & SaboteurPathUtil.NORTH) ) {
				if (preflightZones[toNorth]) return true;
				
			}
			if (graphGrid[toSouth] && (edges & SaboteurPathUtil.SOUTH) )  {
				if (preflightZones[toSouth]) return true;
				
			}
			if (graphGrid[toWest] && (edges & SaboteurPathUtil.WEST) )  {
				if (preflightZones[toWest]) return true;
			}
			if (graphGrid[toEast] && (edges & SaboteurPathUtil.EAST) )  {
				if (preflightZones[toEast]) return true;
			}
			
			return false;
			
		}
		
		private function addMutualArc(a:GraphNode, b:GraphNode):void {
			//if (graph
			//graph.addMutualArc(a, b);
			if (a.getArc(b) == null) a.addArc(b);
			if (b.getArc(a) == null) b.addArc(a);
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
				if (arcs & ARC_NORTH_MASK) {
					graph.addMutualArc(node, graphGrid[toNorth] );
					gotArc = true;
				}
			
			}
			if (graphGrid[toSouth] && (edges & SaboteurPathUtil.SOUTH) )  {
				if (arcs & ARC_SOUTH_MASK) {
					graph.addMutualArc(node, graphGrid[toSouth] );
					gotArc = true;
				
				}
			}
			if (graphGrid[toWest] && (edges & SaboteurPathUtil.WEST) )  {
				if (arcs & ARC_WEST_MASK) {
					graph.addMutualArc(node, graphGrid[toWest] );
					gotArc = true;
				//	throw new Error("W");
				}
			}
			if (graphGrid[toEast] && (edges & SaboteurPathUtil.EAST) )  {
				if (arcs & ARC_EAST_MASK) {
					graph.addMutualArc(node, graphGrid[toEast] );
					gotArc = true;
					//throw new Error("E");
				}
			}
			
		
		
			graphGrid[key] = node;
				//if (assertGotArc) {
				//	if (!firstTime && !gotArc) throw new Error("Assertion arc created failed!");
				//}
				firstTime = false;
			
			return node;
		}
		private var firstTime:Boolean = true;
		
		public function removeNode(east:int, south:int):void {
			var key:uint = pathUtil.getGridKey(east, south);
			var node:GraphNode = graphGrid[key];
			if (node == null) {
				throw new Error("Node not found at: "+east+" ,"+south);
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
			preflightZones = new Dictionary();
			graph.clearMarks();
			var i:int = startNodes.length;
			while (--i > -1) {
				
				graph.DFS(true, startNodes[i], visitNodeForEndPoints);
			}
		}
		
	
		
		public var preflightZones:Dictionary = new Dictionary();
		
		/*
		public function canBuildAt(east:int, south:int, key:uint, value:uint):void {
			var toNorth:uint = pathUtil.getGridKey(east, south - 1);
			var toSouth:uint = pathUtil.getGridKey(east, south + 1);
			var toWest:uint = pathUtil.getGridKey(east-1, south);
			var toEast:uint = pathUtil.getGridKey(east + 1, south);
			
			var edges:uint = pathUtil.getEdgeValue(value);
			var arcs:uint = pathUtil.getArcValue(value);
			
			if ( (arcs & SaboteurPathUtil.ARC_VERTICAL) ) {
				if ( !preflightZones[toNorth] || !preflightZones[toSouth] ) return false; 
			}
			if (preflightZones[toSouth] && (edges & SaboteurPathUtil.SOUTH)  ) {
				if ( ((arcs & SaboteurPathUtil.ARC_VERTICAL) && preflightZones[key]	)
					|| ((arcs & SaboteurPathUtil.ARC_SOUTH_WEST) && preflightZones[toWest]  )
					|| ((arcs & SaboteurPathUtil.ARC_SOUTH_EAST) && preflightZones[toEast]) )  endPointsAccum |= SaboteurPathUtil.SOUTH;
			}
			if (preflightZones[toWest] && (edges & SaboteurPathUtil.WEST) ) {
				if ( ((arcs & SaboteurPathUtil.ARC_HORIZONTAL) && preflightZones[key])	
					|| ((arcs & SaboteurPathUtil.ARC_NORTH_WEST) && preflightZones[toNorth])  
					|| ((arcs & SaboteurPathUtil.ARC_SOUTH_WEST) && preflightZones[toSouth]) )  endPointsAccum |= SaboteurPathUtil.WEST;
			}
			if (preflightZones[toEast] && (edges & SaboteurPathUtil.EAST)  ) {
					if ( ((arcs & SaboteurPathUtil.ARC_HORIZONTAL) && preflightZones[key])	
					|| ((arcs & SaboteurPathUtil.ARC_NORTH_EAST) && preflightZones[toNorth])  
					|| ((arcs & SaboteurPathUtil.ARC_SOUTH_EAST) && preflightZones[toSouth]) )  endPointsAccum |= SaboteurPathUtil.EAST;
			}
			
		}
		*/
		
		private function visitNodeForEndPoints(node:GraphNode, preflight:Boolean, data:uint):Boolean {
	
			var keyer:Array = node.val as Array;
			var key:uint =  pathUtil.getGridKey(keyer[0], keyer[1]);
			if (preflight) {
				
				preflightZones[key] = true;
				return true;
			}
			
			var value:uint = keyer[2];
			var edges:uint = pathUtil.getEdgeValue(value);
			var arcs:uint = pathUtil.getArcValue(value);
			var east:int = keyer[0];
			var south:int = keyer[1];
			var toNorth:uint = pathUtil.getGridKey(east, south - 1);
			var toSouth:uint = pathUtil.getGridKey(east, south + 1);
			var toWest:uint = pathUtil.getGridKey(east-1, south);
			var toEast:uint = pathUtil.getGridKey(east + 1, south);
			var endPointsAccum:uint = 0;
			if (!graphGrid[toNorth] && (edges & SaboteurPathUtil.NORTH)  ) {
				if (arcs & ARC_NORTH_MASK) endPointsAccum |= SaboteurPathUtil.NORTH;
				/*
				if ( ((arcs & SaboteurPathUtil.ARC_VERTICAL) && preflightZones[key])	
					|| ((arcs & SaboteurPathUtil.ARC_NORTH_WEST) && preflightZones[toWest])  
					|| ((arcs & SaboteurPathUtil.ARC_NORTH_EAST) && preflightZones[toEast]) )  endPointsAccum |= SaboteurPathUtil.NORTH;
					*/
			}
			if (!graphGrid[toSouth] && (edges & SaboteurPathUtil.SOUTH)  ) {
				if (arcs & ARC_SOUTH_MASK) endPointsAccum |= SaboteurPathUtil.SOUTH;
				/*
				if ( ((arcs & SaboteurPathUtil.ARC_VERTICAL) && preflightZones[key]	)
				
					|| ((arcs & SaboteurPathUtil.ARC_SOUTH_WEST) && preflightZones[toWest]  )
					|| ((arcs & SaboteurPathUtil.ARC_SOUTH_EAST) && preflightZones[toEast]) )  endPointsAccum |= SaboteurPathUtil.SOUTH;
					*/
			}
			if (!graphGrid[toWest] && (edges & SaboteurPathUtil.WEST) ) {
				if (arcs & ARC_WEST_MASK) endPointsAccum |= SaboteurPathUtil.WEST;
				/*
				if ( ((arcs & SaboteurPathUtil.ARC_HORIZONTAL) && preflightZones[key])	
					|| ((arcs & SaboteurPathUtil.ARC_NORTH_WEST) && preflightZones[toNorth])  
					|| ((arcs & SaboteurPathUtil.ARC_SOUTH_WEST) && preflightZones[toSouth]) )  endPointsAccum |= SaboteurPathUtil.WEST;
					*/
			}
			if (!graphGrid[toEast] && (edges & SaboteurPathUtil.EAST)  ) {
				if (arcs & ARC_EAST_MASK) endPointsAccum |= SaboteurPathUtil.EAST;
				/*
					if ( ((arcs & SaboteurPathUtil.ARC_HORIZONTAL) && preflightZones[key])	
					|| ((arcs & SaboteurPathUtil.ARC_NORTH_EAST) && preflightZones[toNorth])  
					|| ((arcs & SaboteurPathUtil.ARC_SOUTH_EAST) && preflightZones[toSouth]) )  endPointsAccum |= SaboteurPathUtil.EAST;
					*/
			}
			
			endPoints[key] = endPointsAccum;
			
			return true;

		}
		
	}

}