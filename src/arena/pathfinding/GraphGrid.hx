package arena.pathfinding;
import arena.pathfinding.GKGraph;

import components.CollisionResult;
import de.polygonal.ds.BitVector;
import flash.Vector;
import hxGeomAlgo.IsoContours;
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
	//var marchingSquares:GKMarchingSquares;
	var _x:Int;
	var _y:Int;
	public var cells:Array<Vector<Float>>; // heightmap
	public var graph:GKGraph;
	public var visitCells:BitVector;
	public var djTraversal:GKDijkstra;
	public var normalZThreshold:Float;
	private var isoContours:IsoContours;
	
	
	public function new(across:Int) 
	{
		this._across = across;
		normalZThreshold = CollisionResult.MAX_GROUND_NORMAL_THRESHOLD;  // //  0.57357643635104609610803191282616;  // 55 degrees  (Math.cos(deg))
		graph = new GKGraph();
		cells = [];
		visitCells = new BitVector(across*across);
		cliffVector = new BitVector(across*across);
	
		isoContours = new IsoContours(visitCells, _across);
		isoContours.pixels2 = cliffVector;
		
		for ( y in 0...across) {
			cells[y] =  TypeDefs.createFloatVector(across, true);
		}
		new GKGrapher(cells, graph);
		
		djTraversal = new GKDijkstra(graph, 0, -1);
		
		//marchingSquares = new GKMarchingSquares(visitCells, across);
		
		
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
	
	private var outlineBitVector:BitVector;
	private var outlineBitVectorResult:BitVector;
	public inline function renderBordersAlgo(tupleMap:Vector<Int>):Int {
		var oIndex:Int;
		var index:Int;
		var across2:Int = (_across + 2);
		if (outlineBitVector == null) {
			outlineBitVector = new BitVector(across2 * across2);
			outlineBitVectorResult = new BitVector(_across * _across);
		}
		
		// http://www.mathworks.com/matlabcentral/fileexchange/41239-finds-edges-in-a-binary-image
		/*
		function [OUT] = edge2(IN)

		[r,c]  = size(IN);
		A = false([r,c]+2);

		for i = 0:2,
			for j = 0:2,
				A((1:r)+i,(1:c)+j) = A((1:r)+i,(1:c)+j) | IN;
			end;
		end;

		OUT = xor(A(2:r+1,2:c+1), IN);
		*/
		
		outlineBitVector.clrAll();
		
		var yi:Int;
		var xi:Int;
		
	
		for (i in 0...3) {
			xi = 0;
			for (j in 0...3) {  // todo: inline this for loop
			//	outlineBitVector.set
				yi = 0; 
				for (y in 1..._across) {
					xi = 0;
					for (x in 1..._across) {
						oIndex = (y+i) * across2 + x + j;
						index = index = yi * _across + xi;
						outlineBitVector.setFlagAt(oIndex, outlineBitVector.getFlagAt(oIndex) | visitCells.getFlagAt(index) );
						xi++;
					}
					yi++; 
				}
				
			}
		}
		
		yi = 0;
		for (y in 2..._across + 2) {
			
			xi = 0;
			for (x in 2..._across+2) {
				oIndex = y * across2 + x;
				index = yi * _across + xi;
				outlineBitVectorResult.setFlagAt(index, outlineBitVector.getFlagAt(oIndex) ^ visitCells.getFlagAt(index) );
				xi++;
			}
			yi++;
		}
		
		var count:Int = 0;
		for (y in 0..._across) {
			
			
			for (x in 0..._across) {
				index = y * _across + x;
				if ( outlineBitVectorResult.has(index) && !visitCells.has(index) ) {
					tupleMap[count++] = x;
					tupleMap[count++] = y;
				}; 
				
			}
			
		}
		
		return count;

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
	
	public function performIsoOutlineRender(tupleMap:Vector<Int>):Int {
		var count:Int = 0;
		var paths = isoContours.find(false);
		for (path in paths) {
			var len = path.length;
			
			for (i in 0...len) {
				var pt = path[i];
				tupleMap[count++] = Std.int(pt.x);
				tupleMap[count++] = Std.int(pt.y);
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
		
		
		///*
		if (endNodeIndex >= 0) {
			
			endNode = curNode = graph.getNode(endNodeIndex);
			djTraversal.cost2Node[curNode.index] = -1;
			while (curNode != null) {
				curNode = _processNodeBorder(curNode, startNode);
			}
		}
		//*/
		

		
		for (y in 0..._across) {
			for (x in 0..._across) {
				var i:Int = y * _across + x;
				
				// ==-1
				if ( djTraversal.cost2Node[i] ==-1 ) {     //> djTraversal.maxCost
					
					//img.rotationZ = Math.PI * .5 * .5;
					//img.scaleZ = upScale;
					tupleMap[count++] = x;
					tupleMap[count++] = y;
				}
				
				
			}
		}
		
		
		return count;
	}
	
	private inline function getNumFreeEdges(nodeIndex:Int):Int {
		var edges:Array<GKEdge> = graph.getEdges(nodeIndex);
		var len:Int = edges.length;
		var count:Int = 0;
		for (i in 0...len) {
			var e:GKEdge = edges[i];
			count += visitCells.has(e.to) ? 1 : 0;
		}
		return count;
	}
	
	//inline
	private  function _processNodeBorder(node:GKNode, startNode:GKNode):GKNode {
		var edges:Array<GKEdge> = graph.getEdges(node.index);
		var len:Int = edges.length;
		var curDist:Int = 0;// PMath.FLOAT_MAX;
		var firstClosestNode:GKNode = null;
		var d:Int;
		
		for (i in 0...len) {
			var e:GKEdge = edges[i];
			if ( visitCells.has(e.to) || djTraversal.cost2Node[e.to] <= djTraversal.maxCost ) {
				continue;
			}
			else {
				//continue;
				
				var destNode:GKNode =  graph.getNode(e.to);
				d = getNumFreeEdges(e.to);
				
				
				if (d > curDist) {
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