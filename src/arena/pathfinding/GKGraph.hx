package arena.pathfinding;

import util.geom.Vec3;
import de.polygonal.ds.BitVector;
import util.geom.PMath;
import util.geom.Vec3Utils;
import util.TypeDefs;

class GKGraph {
	
	static var nextIndex:Int = 0;
	var nodes:Array<GKNode>;
	var edges:Array<Array<GKEdge>>;
	
	
	public function new () {
		nodes = new Array<GKNode>();
		edges = new Array<Array<GKEdge>>();
	}
    //In order to get the node, we just ask for the index of it, and access the nodes vector with that key
	public inline function getNode (idx:Int) :GKNode {
		return nodes[idx];
	}

    //To get an edge, we ask for the two nodes that it connects,
    //then we retrieve all the edges of the from node and search if one of them
    //goes to the same node as the edge we are looking for, if it does, thats our edge.
	public function getEdge (from:Int, to:Int) :GKEdge {
		
		var fromEdges = edges[from];
		for (a in 0...fromEdges.length) {
			if (fromEdges[a].to == to) {
				return fromEdges[a];
			}
		}
		return null;
	}

    //To add a node to the graph, we first look if it already exist on it,
    //if it doesnt, then we add it to the nodes vector, and add an array to the
    //edges vector where we will store the edges of that node, finally we increase
    //the next valid index Int in order to give the next avilable index in the graph
	public function addNode (node:GKNode) :Int {
		
		if (validIndex ( node.index)) {
			nodes.push ( node );
			edges.push ( new Array<GKEdge>());
			nextIndex++;
		}
		return 0;
	}
    //To add an edge we must first look if both nodes it connects actually exist,
    //then we must see if this edge already exist on the graph, finally we add it
    //to the array of edges of the node from where it comes
	public function addEdge (edge:GKEdge) :Void {
		if (validIndex(edge.to) && validIndex(edge.from)) {
			if (getEdge(edge.from, edge.to) == null) {
				edges[edge.from].push ( edge );
			}
		}
	}
	
    //To get the edges of a node, just return the array gived by the edges vector
    //at node's index position
	public inline function getEdges (node:Int):Array<GKEdge> {
		return edges[node];
	}
	
	//inline
	
	public static inline var DEG_36_GRAD:Float = 0.72654252800536088589546675748062;
	public static inline var DEG_55_GRAD:Float = 1.4281480067421145021606184849985;

	//inline
	public  function setupNodes(cells:Array<Vector<Float>>, tileSize:Float, cliffMap:BitVector):Void {
		var len:Int = nodes.length;
		for (i in 0...len) {  // setup impassable
			setupValidEdges(i, cells, tileSize, cliffMap);
		}
		
	}
	
	// Terrain geometry edge offsets starting from 12'oclock position, going clockwise. Supports up to 8 edges per terrain vertex
	public static inline var MASK_EDGE_ALL:Int = ( (1 << 0) | (1 << 1) | (1 << 2) | (1 << 3) | (1 << 4) | (1 << 5) | (1 << 6) | (1 << 7)  );
	public static inline var MASK_EDGE_CARDINAL:Int = ( (1 << 0)  | (1 << 2) | (1 << 4) | (1 << 6)   );	 // even bits in cardinal direction
	public static inline var MASK_EDGE_DIAGONAL:Int = (  (1 << 1)  | (1 << 3) |  (1 << 5) |  (1 << 7)  );  // odd bits in diagonal direction
	
	public static var EDGE_OFFSETS:Vector<Int> = {   // (x,y) offset tuple
		var edgeOffsets:Vector<Int>  = TypeDefs.createIntVector(8*2, true);
		
		edgeOffsets[0] = 0;   // North
		edgeOffsets[1] = -1;
		
		edgeOffsets[2] = 1;  // North-east
		edgeOffsets[3] = -1;
		
		edgeOffsets[4] = 1;	// East
		edgeOffsets[5] = 0;
		
		edgeOffsets[6] = 1;  // South-East
		edgeOffsets[7] = 1;
		
		edgeOffsets[8] = 0;   // South
		edgeOffsets[9] = 1;
		
		edgeOffsets[10] = -1; // South-West
		edgeOffsets[11] = 1;
		
		edgeOffsets[12] = -1;  // West
		edgeOffsets[13] = 0;
		
		edgeOffsets[14] = -1;  // North-west
		edgeOffsets[15] = -1;
		
		
		edgeOffsets;
	}
	public static var EDGE_MASK_MATCH_EVEN_ODD:Int = MASK_EDGE_ALL;
	public static var EDGE_MASK_MISMATCH_EVEN_ODD:Int = MASK_EDGE_CARDINAL;
	
	
	private static var EDGE_1:Vec3 = new Vec3();
	private static var EDGE_2:Vec3 = new Vec3();
	private static var NORM:Vec3 = new Vec3();
	private static var NORM_ACCUM:Vec3 = new Vec3();

	
	/**
	 * Calculates 'impassable' cliff regions given a terrain height map
	 * @param	heightMap	The square heightmap of vertices altitude values
	 * @param	verticesAcross	The number of vertices across the heightmap
	 * @param	tileSize		The tile length dimension between vertices
	 * @param	normalZThreshold	The maximum normal.z of a steep (maybe cliff) slope per tile. Can be derived as: Math.cos(angleOfSlope).
	 * @param	consecutiveSteepsForCliff  How many consecutive tile steep edges are required to be deemed an impassable cliff
	 * @return	A bit vector of vertices based off the heightmap where cliffed vertices are marked as true.
	 */
	public static function getCliffMap(heightMap:Vector<Int>, verticesAcross:Int, tileSize:Float, normalZThreshold:Float, consecutiveSteepsForCliff:Int, cliffVector:BitVector=null):BitVector {
		
		var totalNodes:Int = verticesAcross * verticesAcross;
		cliffVector = cliffVector != null ? cliffVector : new BitVector(totalNodes);
		cliffVector.clearAll();
			
		// temporary edge vector to keep track of steep slopes per node
		var edgeVector:BitVector  = new BitVector(totalNodes * 8); 
		
		// temporary edge vector to keep track of visited edges per node
		var visitedEdgeVector:BitVector  = new BitVector(totalNodes * 8); 
	
		// push into list of steep nodes as a tuple of (x,y)
		var steepNodes:Vector<Int> = TypeDefs.createIntVector(0,false);
		
		// approx steep edge gradient 
		var gradient:Float = Math.tan( Math.acos(normalZThreshold) );
		
		var tileSizeRec:Float = 1 / tileSize;
		
		var xi:Int;
		var yi:Int;
		
		var h:Float;
		
		// per node, calculate adjoining relavant edges, mark steep edges that meet gradient magnitude,
		// also calculate normals for each successive edge to get vertex normal as average of all those normals
		var count:Int;
		var edge1:Vec3 = EDGE_1;
		var edge2:Vec3 = EDGE_2;
		var norm:Vec3 = NORM;
		
			var i:Int;
			
			var normZ:Float;
			var normAccum:Vec3 = NORM_ACCUM;
		var avgCount:Int;
		for (y in 0...verticesAcross) {
			for (x in 0...verticesAcross) {
				count = 0;
			     i= y * verticesAcross + x;
				var h:Float = heightMap[i];
				normZ = 0;
				avgCount = 0;
				normAccum.set(0, 0, 0);
				var masker:Int = (y & 1)  != (x&1) ? EDGE_MASK_MISMATCH_EVEN_ODD : EDGE_MASK_MATCH_EVEN_ODD;
				count += _markSteepEdges( edgeVector, masker, 0, heightMap, x, y, h, verticesAcross, gradient, tileSize, edge1);
					
				count += _markSteepEdges( edgeVector, masker, 1, heightMap, x, y, h, verticesAcross, gradient, tileSize, (count != 1 ? edge1 :edge2));
					if (count == 2) {   Vec3Utils.writeCross(edge1, edge2, norm);  norm.normalize();  normZ += norm.z; normAccum.add(norm); avgCount++; count = 1;  edge1.copyFrom(edge2); }
				count += _markSteepEdges( edgeVector, masker, 2, heightMap, x, y, h, verticesAcross, gradient, tileSize, (count!= 1 ? edge1 :edge2));
					if (count == 2) { Vec3Utils.writeCross(edge1, edge2, norm); norm.normalize(); normZ+= norm.z; normAccum.add(norm); avgCount++; count = 1; edge1.copyFrom(edge2); }
				count += _markSteepEdges( edgeVector, masker, 3, heightMap, x, y, h, verticesAcross, gradient, tileSize, (count!= 1? edge1 :edge2));
					if (count == 2) { Vec3Utils.writeCross(edge1, edge2, norm); norm.normalize(); normZ+= norm.z; normAccum.add(norm); avgCount++; count = 1; edge1.copyFrom(edge2); }
				count += _markSteepEdges( edgeVector, masker, 4, heightMap, x, y, h, verticesAcross, gradient, tileSize, (count!= 1 ?edge1 :edge2));
					if (count == 2) { Vec3Utils.writeCross(edge1, edge2, norm); norm.normalize(); normZ+= norm.z; normAccum.add(norm); avgCount++; count = 1; edge1.copyFrom(edge2); }
				count += _markSteepEdges( edgeVector, masker, 5, heightMap, x, y, h, verticesAcross, gradient, tileSize, (count!= 1 ? edge1 :edge2));
					if (count == 2) { Vec3Utils.writeCross(edge1, edge2, norm); norm.normalize();normZ+= norm.z;normAccum.add(norm);  avgCount++; count = 1; edge1.copyFrom(edge2); }
				count += _markSteepEdges( edgeVector, masker, 6, heightMap, x, y, h, verticesAcross, gradient, tileSize, (count!= 1 ? edge1 :edge2));
					if (count == 2) { Vec3Utils.writeCross(edge1, edge2, norm); norm.normalize(); normZ+= norm.z;normAccum.add(norm);  avgCount++; count = 1; edge1.copyFrom(edge2); }
				count += _markSteepEdges( edgeVector, masker, 7, heightMap, x, y, h, verticesAcross, gradient, tileSize, (count!= 1? edge1 :edge2));
					if (count == 2) { Vec3Utils.writeCross(edge1, edge2, norm); norm.normalize(); normZ += norm.z; normAccum.add(norm); avgCount++; count = 1; edge1.copyFrom(edge2); }
					
					count += _markSteepEdges( edgeVector, masker, 0, heightMap, x, y, h, verticesAcross, gradient, tileSize, edge1);	
					if (count == 2) { Vec3Utils.writeCross(edge1, edge2, norm); norm.normalize(); normZ += norm.z; normAccum.add(norm); avgCount++; count = 1; edge1.copyFrom(edge2); }
					
					if (avgCount > 0) {
						
						normZ /= avgCount;
						
						
						normAccum.normalize();
						normZ = normAccum.z;
						
						if (normZ < normalZThreshold) {
							//if (avgCount == 8) throw normZ*avgCount;
							cliffVector.set(i);
						}
					}
			}
		}
		
		
		 // go through every steepNode to perform a DFS traversal through steep edges only
		 // Once stack no longer pushes, detemine if depth >= consecutiveSteepsForCliff,
		 // if so, flag those steep nodes in stack into cliffVector before popping the stack.
			/*
		var nIndex:Int;
		var steepNodeStack:Vector<Float> = TypeDefs.createFloatVector(totalNodes, false);
		var depth:Int;
		var len:Int = steepNodes.length;
		i = 0;
		while(i < len) {
			xi = steepNodes[i];
			yi = steepNodes[i + 1];
			nIndex = yi * verticesAcross + xi;
			
			depth = 0;
			visitedEdgeVector.clrAll();
			
				
			i += 2;  // continue iteration
		}
			*/
		return cliffVector;
	}
	
	inline
	public static  function _markSteepEdges(edgeVector:BitVector, masker:Int, edgeIndex:Int, heightMap:Vector<Int>, x:Int, y:Int, h:Float, verticesAcross:Int, gradient:Float, tileSize:Float, edge:Vec3):Int {
		var counter:Int = (masker & (1 << edgeIndex)) != 0  ? 1 : 0;
		if ( counter != 0  )  {  // hopefully this repeat will inline
			var xo:Int = EDGE_OFFSETS[(edgeIndex << 1)] + x;
			var yo:Int = EDGE_OFFSETS[(edgeIndex << 1) + 1] + y;
			counter = xo >= 0 && xo < verticesAcross  && yo >= 0 && yo < verticesAcross ? 1 : 0;
			
			
			if (counter != 0) {  // must be within range to consider valid edge
				edge.x = -EDGE_OFFSETS[(edgeIndex << 1)] * tileSize;
				edge.y = -EDGE_OFFSETS[(edgeIndex << 1) + 1] * tileSize;
				edge.z =  heightMap[( yo) * verticesAcross + ( xo)] - h;
				if ( PMath.abs(edge.z) / (xo == 0 || yo == 0 ? tileSize : GKEdge.DIAGONAL_LENGTH) > gradient ) {
					edgeVector.set( ((y*verticesAcross+x) << 3) + edgeIndex );	
				}
				else {
					edgeVector.clear(  ((y*verticesAcross+x) << 3) + edgeIndex  );
				}
				
			}
		}
		
		return counter;
	}
	
	public  function setupValidEdgesBinaryCells(node:Int, cells:Array<Vector<Float>>, blockHeight:Float):Void {
		var edgeArr:Array<GKEdge> = edges[node];
		var from:GKNode = nodes[node];
		var fromZ:Float = cells[from.y][from.x];
		var across:Int = cells.length;
	
		//if (fromZ != PMath.FLOAT_MAX)  {
		
			var len:Int = edgeArr.length;
		
			var cost:Float;
			
			for (i in 0...len) {
				var edge:GKEdge = edgeArr[i];
			
				edge.flags = 0;
				
				
				var to:GKNode = nodes[edge.to];
				var toZ:Float = cells[to.y][to.x];
				//
				
				if (toZ >= blockHeight || fromZ >= blockHeight ) {
					edge.flags |= GKEdge.FLAG_INVALID;
					//continue;
				}
				
				///*
				
				//var cost:Float =  (to.x == from.x || to.y == from.y ? 1 : GKEdge.DIAGONAL_LENGTH);
				
				//if (cost != 1 && cost != GKEdge.DIAGONAL_LENGTH) throw "Nons tandard cost:"+nodes[edge.to] + " ::: "+cost;
				//edge.cost = cost;
				
			}
		
		
	}
	
	//inline
	public  function setupValidEdges(node:Int, cells:Array<Vector<Float>>, tileSize:Float, cliffMap:BitVector):Void {
		var edgeArr:Array<GKEdge> = edges[node];
		var from:GKNode = nodes[node];
		var fromZ:Float = cells[from.y][from.x];
		var across:Int = cells.length;
		var fromCliff:Bool =  cliffMap.has(from.y * across + from.x);
		//if (fromZ != PMath.FLOAT_MAX)  {
		
			var len:Int = edgeArr.length;
		
			var cost:Float;
			
			for (i in 0...len) {
				var edge:GKEdge = edgeArr[i];
			
				edge.flags = 0;
				
				
				var to:GKNode = nodes[edge.to];
				var toZ:Float = cells[to.y][to.x];
				//
				if (fromCliff || cliffMap.has(to.y * across + to.x)) {
					edge.flags |= GKEdge.FLAG_CLIFF;
				}
				
				if (toZ == PMath.FLOAT_MAX || fromZ == PMath.FLOAT_MAX) {
					edge.flags |= GKEdge.FLAG_INVALID;
					//continue;
				}
				
				///*
				
				var cost:Float =  (to.x == from.x || to.y == from.y ? 1 : GKEdge.DIAGONAL_LENGTH);
				var heightDiff:Float = (toZ - fromZ);
				var grad:Float = heightDiff / cost;
			
			
				
			
				edge.flags |= PMath.abs(grad) > DEG_55_GRAD ? GKEdge.FLAG_GRADIENT_UNSTABLE : 0;
				edge.flags |= grad < 0 ? GKEdge.FLAG_GRADIENT_DOWNWARD : 0;
				edge.flags |= grad > DEG_36_GRAD ? GKEdge.FLAG_GRADIENT_DIFFICULT : 0;
				
				
			
			
				//if (grad>0) throw "A";
				grad = grad <= DEG_36_GRAD ? 0 : grad;
				
				
				if ((edge.flags & (GKEdge.FLAG_GRADIENT_UNSTABLE | GKEdge.FLAG_CLIFF)) != 0  ) {  // will have to resort to climbing, so speed is reduced significantly	
					cost *= 4;
					
					/*
					 * stepHeight cost: 0 ~ 18 units (+0.125)
					Step to Crotch height cost: 18 ~ 36  units (raise leg over cost) (+1.25) 
					Crotch to Abs height cost: 36 - 54  units  (direct vault-over cost) (+2.375) 
					Over abs height cost: 54-86 units ( raise hands to vault over cost) (+2) 
					High above over head cost: Required to jump, grab and vault over cost: >86 units to highest possible jump+grab height (+2)
					*/
					
					heightDiff *= tileSize; 
					cost += 0.125;  // stepHeight penalty
				//	/*
					cost += heightDiff > 18 ? 1.25 : 0;
					cost += heightDiff > 36 ? 2.375 : 0;
					cost += heightDiff > 54 ? 2 : 0;
					cost += heightDiff > 86 ? 2 : 0;
					//*/
					
				}
				
				cost += grad;
				
				
				
				
				
				//if (cost != 1 && cost != GKEdge.DIAGONAL_LENGTH) throw "Nons tandard cost:"+nodes[edge.to] + " ::: "+cost;
				edge.cost = cost;
				
				//*/
			}
		
		//}
	}
	
    //This function checks if the node index is between the range of already added nodes
    //which is form 0 to the next valid index of the graph
	public inline function validIndex (idx:Int) :Bool {
		return (idx >= 0 && idx <= nextIndex);
	}
	
    //Just returns the amount of nodes already added to the graph
	public inline function numNodes () :Int {
		return nodes.length;
	}
	
    //This function return the next valid node index to be added
	public static function getNextIndex () :Int {
		return nextIndex;
	}
}
