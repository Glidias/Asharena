package arena.pathfinding;
import util.TypeDefs;

class GKGrapher {
	
	var cells :Array<Vector<Float>>;
	var valuesToIgnore :Array<Int>;
	
	
	public function new (cells:Array<Vector<Float>>, n_graph:GKGraph) {
			
		this.cells = cells;
		var cellsX :Int = cells.length;
		var cellsY :Int = cells.length;
			
		for (x in 0...cellsX) {
			for (y in 0...cellsY) {
				var node = new GKNode (GKGraph.getNextIndex(), x, y);
				n_graph.addNode ( node );
			}
		}
		///*
		for (node_x in 0...cellsX) {
			for (node_y in 0...cellsY) {
				
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
		
		addNeighbor(cc, -1, -1, n_graph, row, col, cellsX, cellsY);
		addNeighbor(cc, 0, -1, n_graph, row, col, cellsX, cellsY);
		addNeighbor(cc, 1, -1, n_graph, row, col, cellsX, cellsY);
		
		addNeighbor(cc, -1, 0, n_graph, row, col, cellsX, cellsY);
		addNeighbor(cc, 1, 0, n_graph, row, col, cellsX, cellsY);
		
		addNeighbor(cc, -1, 1, n_graph, row, col, cellsX, cellsY);
		addNeighbor(cc, 0, 1, n_graph, row, col, cellsX, cellsY);
		addNeighbor(cc, 1, 1, n_graph, row, col, cellsX, cellsY);

	}
	
	public inline function addNeighbor(cc:Float,i:Int, j:Int, n_graph:GKGraph, row:Int, col:Int, cellsX:Int, cellsY:Int ):Void {
		var nodeY = row + j;
		var nodeX = col + i;
		
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

			var cost = (i == 0 || j == 0) ? 1 : 1.4142135623730950488016887242097;
			
			
			var nodeIdx:Int = Math.round (col * cellsY + row);
			var nIdx:Int = Math.round (nodeX * cellsY + nodeY);
			var edge = new GKEdge (nodeIdx, nIdx, cost);
			
			n_graph.addEdge ( edge );
		}
		
	}
}