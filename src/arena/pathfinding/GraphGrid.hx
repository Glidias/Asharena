package arena.pathfinding;
import arena.pathfinding.GKGraph;
import arena.pathfinding.GKMarchingSquares;
import components.CollisionResult;
import de.polygonal.ds.BitVector;
import util.geom.PMath;
import util.TypeDefs;

//import flash.display.BitmapData;

/**
 * ...
 * @author Glenn Ko
 */
class GraphGrid
{
	private var _across:Int;
	var cliffVector:BitVector;
	var marchingSquares:GKMarchingSquares;
	var _x:Int;
	var _y:Int;
	public var cells:Array<Vector<Float>>; // heightmap
	public var graph:GKGraph;
	public var visitCells:BitVector;
	public var djTraversal:GKDijkstra;
	public var normalZThreshold:Float;
	
	
	public function new(across:Int) 
	{
		this._across = across;
		normalZThreshold = CollisionResult.MAX_GROUND_NORMAL_THRESHOLD;  // //  0.57357643635104609610803191282616;  // 55 degrees  (Math.cos(deg))
		graph = new GKGraph();
		cells = [];
		visitCells = new BitVector(across*across);
		cliffVector = new BitVector(across*across);
	

		for ( y in 0...across) {
			cells[y] =  TypeDefs.createFloatVector(across, true);
		}
		new GKGrapher(cells, graph);
		
		djTraversal = new GKDijkstra(graph, 0, -1);
		
		marchingSquares = new GKMarchingSquares(visitCells, across);
		
		
		//djTraversal.search();
	}
	
	public function search(x:Int = 0, y:Int = 0, maxCost:Float=PMath.FLOAT_MAX):Void {
	
		visitCells.clrAll();	
		_x = x;
		_y = y;
		
		djTraversal.source = y * _across + x;
		djTraversal.visit = doVisit;
		djTraversal.maxCost = maxCost;
		djTraversal.search();
		
	
	}
	
	private function doVisit(node:GKNode):Void
	{
		visitCells.set( node.y * _across + node.x );
	}
	
	/*
	public function renderVisitedToBitmap(data:BitmapData):Void {
		for (y in 0..._across) {
			for (x in 0..._across) {
				data.setPixel(x, y, visitCells.has(y * _across + x)  ? 0xFF0000, 0);
			}
		}
	}
	*/
	
	
	public function renderVisitedToScaledImages(images:Array<Dynamic>, upScale:Float=2):Void {
		for (y in 0..._across) {
			for (x in 0..._across) {
				var i:Int = y * _across + x;
				var img:Dynamic = images[i];
				var val:Float = visitCells.has(i)  ? ( upScale >=0 ? upScale : 1-djTraversal.cost2Node[i]/djTraversal.maxCost) : 1;
				img.scaleX = val;
				img.scaleY = val;
				img.scaleZ = visitCells.has(i)  ? 1 : 4;
			}
		}
	}
	
	public function renderOutlineBorderToScaledImages(images:Array<Dynamic>, upScale:Float=2):Void {
		for (y in 0..._across) {
			for (x in 0..._across) {
				var i:Int = y * _across + x;
				var img:Dynamic = images[i];
				if ( djTraversal.cost2Node[i] > djTraversal.maxCost) {
					
					img.rotationZ = Math.PI * .5 * .5;
					//img.scaleZ = upScale;
				}
				else {
					img.rotationZ = 0;
				}
				
			}
		}
	}
	
	public function performOutlineRender(tupleMap:Vector<Int>):Int {
		var result:Bool = marchingSquares.startTracking(0, _y);
		var count:Int = 0;
		//var x:Int = _x;
		//var y:Int = _y;
		if (result ) {
			tupleMap[count++] = marchingSquares.x;
			tupleMap[count++] = marchingSquares.y;
			
			while ( marchingSquares.nextPoint() ) {
				
				tupleMap[count++] = marchingSquares.x;
				tupleMap[count++] = marchingSquares.y;
				
				//x = marchingSquares.x;
				//y = marchingSquares.y;
				
			}
		}
		
		return count;
	}
	
	public function performOutlineBorderRender(tupleMap:Vector<Int>):Int {
		var i:Int;
		var count:Int = 0;
		
		var startNode:GKNode = graph.getNode( djTraversal.source);
		var endNode:GKNode;
		var curNode:GKNode;
		var endNodeIndex:Int = -1;
		var x:Int = startNode.x;
		var colI:Int = startNode.y * _across;
		while ( --x > -1  ) {
			i = colI + x;
			var cost:Float = djTraversal.cost2Node[i];
			if (cost > djTraversal.maxCost) {
				if (endNodeIndex == -1) endNodeIndex = i;  // get first hit end border
			}
			else if (cost > 0) {
				endNodeIndex = -1;
			}
			x--;
		}
		
		
		/*
		if (endNodeIndex >= 0) {
			endNode = curNode= graph.getNode(endNodeIndex);
			while (curNode != null) {
				curNode = _processNodeBorder(curNode, startNode);
			}
		}
		*/
		

		
		for (y in 0..._across) {
			for (x in 0..._across) {
				var i:Int = y * _across + x;
				
				if ( djTraversal.cost2Node[i] > djTraversal.maxCost) {
					
					//img.rotationZ = Math.PI * .5 * .5;
					//img.scaleZ = upScale;
					tupleMap[count++] = x;
					tupleMap[count++] = y;
				}
				
				
			}
		}
		
		
		return count;
	}
	
	//inline
	private  function _processNodeBorder(node:GKNode, startNode:GKNode):GKNode {
		var edges:Array<GKEdge> = graph.getEdges(node.index);
		var len:Int = edges.length;
		var curDist:Float = PMath.FLOAT_MAX;
		var firstClosestNode:GKNode = null;
		
		for (i in 0...len) {
			var e:GKEdge = edges[i];
			if ( djTraversal.cost2Node[e.to] <= djTraversal.maxCost ) {
				continue;
			}
			else {
				continue;
				
				var destNode:GKNode =  graph.getNode(e.to);
				
				var dx:Float = destNode.x - startNode.x;
				var dy:Float = destNode.y - startNode.y;
				var d:Float = dx * dx + dy * dy;
				
				
				if (d < curDist) {
					curDist = d;
					firstClosestNode = destNode;
				}
			}
		}
		
		if (firstClosestNode != null) djTraversal.cost2Node[firstClosestNode.index] = -1;  // unmark it on purpose...
		
		return firstClosestNode;
	}
	
	
	
	
	///*
	public function sampleHeightmap(heightMap:Vector<Int>, tileSize:Float, xc:Int = 0, yc:Int=0, acrs:Int = 0):Void {
		if (acrs == 0 ) acrs = _across;
		var tileSizeMult:Float = tileSize!=0 ? 1 / tileSize : 1;
		for (y in 0..._across) {
			var yH:Int = yc + y;
			for (x in 0..._across) {
				var xH:Int = xc + x;
				//var i:Int = y * _across + x;
				var u:Int = yH * acrs + xH;
				cells[y][x] = yH < 0 || xH < 0 || xH >= acrs || yH >= acrs ?   PMath.FLOAT_MAX : heightMap[u]*tileSizeMult;
			}
		}
		
		// TODO: getCliffMap();, and for all edges that lead to/from cliff nodes, disable them as CLIFF EDGE flag!
	
		GKGraph.getCliffMap(heightMap, acrs, tileSize, normalZThreshold, 0, cliffVector );
		graph.setupNodes(cells, tileSize, cliffVector);  // TODO: add cliff map reference
		
		
	}
	//*/
	
}