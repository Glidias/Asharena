package arena.pathfinding;
import util.geom.PMath;
import util.TypeDefs;

class GKDijkstra {
	
	private var graph :GKGraph;					//The graph where the search will be made
	private var SPT :Array<GKEdge>;			//This vector will store the Shortest Path Three
	private var cost2Node :Vector<Float>;	//This vector will store the costs of getting to each node
	private var SF :Array<GKEdge>;			//This will be our search frontier, it will contain
	public var source :Int;
	public var target :Int;
	public var maxCost:Float;
	private var _pq:IndexedPriorityQ;
	
	public function new (n_graph:GKGraph, src:Int, tar:Int) {
		graph=n_graph;
		source=src;
		target=tar;
		SPT = new Array<GKEdge>();
		//SPT.length = graph.numNodes();
		TypeDefs.setVectorLen(SPT, graph.numNodes());
		cost2Node = TypeDefs.createFloatVector(graph.numNodes(), false);// new Array<Float>(graph.numNodes());
		
		SF = new Array<GKEdge>();  //graph.numNodes()
		//SF.length = graph.numNodes();
		TypeDefs.setVectorLen(SF, graph.numNodes());
		
		_pq = new IndexedPriorityQ(cost2Node);
		this.maxCost = PMath.FLOAT_MAX;
		//search();
	}
	public function search () :Void {
		//This will be the indexed priority Queue that will sort the nodes
		var pq:IndexedPriorityQ = _pq;
		pq.clear();
		
		TypeDefs.setVectorLen(SF, 0);
		
		// todo: clear SF;
		// todo: clear SPT
		
		
		
		
		//To start the algorithm we first add the source to the pq
		pq.insert(source);
		//With this we make sure that we will continue the search until there is no more nodes on the pq
		while (!pq.isEmpty()) {
				
			/* 1.- Take the closest node not yet analysed */
				
			//We get the Next Closest Node (NCN) which is the first element of the pq
			var NCN:Int = pq.pop();
				
			/* 2.-Add its best edge to the Shortest Path Tree (Its best edge is stored on the SF) */
				
			SPT[NCN] = SF[NCN];
				
			//This will color the actual edge to red in order to see which edges algorithm had analyzed
			/*
			if (SPT[NCN]) {
				SPT[NCN].drawGKEdge (
					graph.getNode(SPT[NCN].from).getPos(),
					graph.getNode(SPT[NCN].to).getPos(),
					"visited"
				);
			}
			*/
			
			/* 3.- If if is the target node, finish the search */
			
			if (NCN == target) return;
			
			/* 4.- Retrieve all the edges of this node */
			
			var edges = graph.getEdges( NCN );
			
			//With this loop we will analyse each of the edges of the array
			for (edge in edges) {
				/* 5.- For each edge calculate the cost of moving from the source node to the arrival Node */
				
				if  ( (edge.flags & GKEdge.FLAG_INVALID)!=0 )  {
					continue;
				}
				//The total cost is calculated by: Cost of the node + Cost of the edge
				var nCost:Float = cost2Node[NCN] + edge.cost;
				if (nCost > maxCost) {
					continue;
				}
				
				//If the arrival node has no edge on the SF, then add its cost to the
				//Cost vector, the arrival node to the pq, and add the edge to the SF
				if (SF[edge.to] == null) {
					cost2Node[edge.to] = nCost;
					pq.insert(edge.to);
					SF[edge.to] = edge;
				}

				/* 6.- If the cost of this edge is less than the cost of the arrival node until now, then update the node cost with the new one */					
				
				else if (nCost < cost2Node[edge.to] && SPT[edge.to] == null) {
					cost2Node[edge.to] = nCost;
					//Since the cost of the node has changed, we need to reorder again the pq to reflect the changes
					pq.reorderUp();
					//Because this edge is better, we update the SF with this edge
					SF[edge.to] = edge;
				}
			}
		}
	}
	
	public function doBacktrackCliffDisable(nd:Int):Void {
		
		//This loop will work until we find the source, or theres no edge in the SPT for a certain node
		while (nd != source && SPT[nd] != null && (SPT[nd].flags & GKEdge.FLAG_GRADIENT_UNSTABLE)!=0 ) {
			SPT[nd].flags |= GKEdge.FLAG_INVALID;
			nd = SPT[nd].from;
			// todo: unvisit SPT[nd].to node
		}
	}
	
	public function getPath () :Vector<Int> {
		//Create the variable where we will store the path
		var path = new Vector<Int>();
		//If the target is a not valid index, or the SPT doesn't have a path to the node,
		//meaning that is wasn't found, just return an empty path
		if (target < 0 || SPT[target] == null) return path;
		//nd will store the current node, wich at the beggining is the target
		var nd:Int = target;
		//add the target to the path
		path.push(nd);
		//This loop will work until we find the source, or theres no edge in the SPT for a certain node
		while (nd != source && SPT[nd] != null) {
			//This will change the color of the path to black so we can actually se it
			/*
			SPT[nd].drawGKEdge(
				graph.getNode(SPT[nd].from).getPos(),
				graph.getNode(SPT[nd].to).getPos(),
				"path"
			);
			*/
			//Get the next node and add it to the path
			nd = SPT[nd].from;
			path.push(nd);
		}
		//Reverse the path so the first element will be the source
	//	path = path.reverse();
			
		return path;
	}
}