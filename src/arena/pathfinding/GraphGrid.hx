package arena.pathfinding;
import arena.pathfinding.GKGraph;
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
	public var cells:Array<Vector<Float>>; // heightmap
	public var graph:GKGraph;
	public var visitCells:BitVector;
	public var djTraversal:GKDijkstra;
	
	
	public function new(across:Int) 
	{
		this._across = across;
		graph = new GKGraph();
		cells = [];
		visitCells = new BitVector(across*across);
		
	

		for ( y in 0...across) {
			cells[y] =  TypeDefs.createFloatVector(across, true);
		}
		new GKGrapher(cells, graph);
		
		djTraversal = new GKDijkstra(graph, 0, -1);
		
		//djTraversal.search();
	}
	
	public function search(x:Int = 0, y:Int = 0, maxCost:Float=PMath.FLOAT_MAX):Void {
	
		visitCells.clrAll();	
		
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
	
	
	
	
	///*
	public function sampleHeightmap(heightMap:Vector<Int>, tileSize:Float, xc:Int = 0, yc:Int=0, acrs:Int = 0):Void {
		if (acrs == 0 ) acrs = _across;
		tileSize = tileSize!=0 ? 1 / tileSize : 1;
		for (y in 0..._across) {
			var yH:Int = yc + y;
			for (x in 0..._across) {
				var xH:Int = xc + x;
				//var i:Int = y * _across + x;
				var u:Int = yH * acrs + xH;
				cells[y][x] = yH < 0 || xH < 0 || xH >= acrs || yH >= acrs ?   PMath.FLOAT_MAX : heightMap[u]*tileSize;
			}
		}
		
		// TODO: getCliffMap();, and for all edges that lead to/from cliff nodes, disable them as CLIFF EDGE flag!
		
		graph.setupNodes(cells, tileSize);  // TODO: add cliff map reference
		
		
	}
	//*/
	
}