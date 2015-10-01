package arena.pathfinding;
import util.TypeDefs;

class GKGrapher {
	
	var cells :Array<Vector<Float>>;

	var _edgeDisableMask:Int;
	
	public function new (cells:Array<Vector<Float>>, n_graph:GKGraph, edgeDisableMask:Int=0) {
			
		this.cells = cells;
		this._edgeDisableMask = edgeDisableMask;
		var cellsX :Int = cells.length > 0 ? cells[0].length : 0;
		var cellsY :Int = cells.length;
			
		
		for (y in 0...cellsY) {
			for (x in 0...cellsX) {
				var node = new GKNode (GKGraph.getNextIndex(), x, y);
				n_graph.addNode ( node );
			}
		}
		///*
		
		for (node_y in 0...cellsY) {
			for (node_x in 0...cellsX) {
				var cell :Float = cells[node_y][node_x];
				
				addNeighbours (n_graph, node_y, node_x, cellsX, cellsY);
				
			}
		}
		//*/
	}
		
	public function addNeighbours (n_graph:GKGraph, row:Int, col:Int, cellsX:Int, cellsY:Int) :Void {
			
		var cc:Float = cells[row][col];// current cell
			
		/*
		for (i in -1...1) {
			for (j in -1...1) {
				addNeighbor(cc,i, j);
			}
		}
		*/
		
		

		
		var edgeOffsets:Vector<Int> = GKGraph.EDGE_OFFSETS;
		var i:Int = 0;
		var len:Int = edgeOffsets.length;
		
		while (i < len) {
			if ( (_edgeDisableMask & (1<< (i>>1) ))==0 ) addNeighbor(cc, edgeOffsets[i], edgeOffsets[i+1], n_graph, row, col, cellsX, cellsY);
			i += 2;
		}
		
		

	}
	
	public inline function addNeighbor(cc:Float,i:Int, j:Int, n_graph:GKGraph, row:Int, col:Int, cellsX:Int, cellsY:Int ):Void {
		
		var nodeX = col + i;
		var nodeY = row + j;
		
		//if (i==0 && j==0) continue;
		
		if (nodeX >= 0 && nodeX < cellsX && nodeY >= 0 && nodeY < cellsY) {
			
			var nc :Float = cells[nodeY][nodeX];// neighbour cell
			
			// Neighbours to ignore
			/*
			if (nc >= 0 && nc != 20) continue;
			if (cc == -6 && i == -1 && j == 1) continue;
			if (cc == -7 && i == 1 && j == 1) continue;
			if (cc == -8 && i == 1 && j == -1) continue;
			if (nc == -6 && i == 1 && j == -1) continue;
			if (nc == -7 && i == -1 && j == -1) continue;
			if (nc == -8 && i == -1 && j == 1) continue;
			*/

			var cost = (i == 0 || j == 0) ? 1 : GKEdge.DIAGONAL_LENGTH;
			
			
			var nodeIdx:Int = Math.round (row * cellsY + col);
			var nIdx:Int = Math.round (nodeY * cellsX + nodeX);
			var edge = new GKEdge (nodeIdx, nIdx, cost);
		//	edge.flags = j == 0 && i == 1 ? 0 : GKEdge.FLAG_INVALID;
			n_graph.addEdge ( edge );
		}
		
	}
}