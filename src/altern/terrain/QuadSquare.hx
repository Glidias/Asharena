package altern.terrain;

import util.TypeDefs;
import util.geom.PMath;

/**
 * ...
 * @author Glidias
 */
	
	class QuadSquare
	{
		public var Child:Array<QuadSquare>  = new Array<QuadSquare>();
		
		// center, e, n, w, s [5]  , vertex heights   
		public	var Vertex:Vector<Int> = TypeDefs.createIntVector(5, true); // new Vector<Int>(5, true);	
		// e, s, children: ne, nw, sw, se  [6]
		public	var errorList:Vector<Int> = TypeDefs.createIntVector(6, true); // new Vector<Int>(6, true); 
		
		// Bounds for frustum culling and error testing.
		public var MinY:Int;
		public var MaxY:Int;

		
		public function new(pcd:QuadCornerData) 
		{
			pcd.Square = this;
			MinY =  PMath.INT16_MAX;// 1.79e+308;
			MaxY = PMath.INT16_MIN;// -1.79e+308;
			
			// Set static to true if/when this node contains real data, and
			// not just interpolated values.  When static == false, a node
			// can be deleted by the Update() function if none of its
			// vertices or children are enabled.
	
			var	i:Int;
			
			// Set default vertex positions by interpolating from given corners.
			// Just bilinear interpolation.
			Vertex[0] = Std.int(0.25 * (pcd.Verts[0] + pcd.Verts[1] + pcd.Verts[2] + pcd.Verts[3]));
			Vertex[1] = Std.int(0.5 * (pcd.Verts[3] + pcd.Verts[0]));
			Vertex[2] = Std.int(0.5 * (pcd.Verts[0] + pcd.Verts[1]));
			Vertex[3] = Std.int(0.5 * (pcd.Verts[1] + pcd.Verts[2]));
			Vertex[4] = Std.int(0.5 * (pcd.Verts[2] + pcd.Verts[3]));
			
			var i:Int;
			
			i = 0;
			while (i < 2) {
				errorList[i] = 0;
				i++;
			}
			
			i = 0;
			while (i < 4) {
				errorList[i+2] = Std.int( Math.abs((Vertex[0] + pcd.Verts[i]) - (Vertex[i+1] + Vertex[((i+1)&3) + 1])) * 0.25 );
				i++;
			}

			// Compute MinY/MaxY based on corner verts.
			MinY = MaxY = pcd.Verts[0];
			i = 0;
			while (i < 4) {
				var	y:Int = pcd.Verts[i];
				if (y < MinY) MinY = y;
				if (y > MaxY) MaxY = y;
				i++;
			}
			
		}
		
		/*
		public function calculateYBounds(pcd:QuadCornerData):Void {
			MinY = 1.79e+308;
			MaxY = -1.79e+308;
			var	y:Float;
			var i:Int;
			
			i = 0;
			while (i < 4) {
				y = pcd.Verts[i];
				if (y < MinY) MinY = y;
				if (y > MaxY) MaxY = y;
				i++;
			}
			
			i = 0;
			while (i < 5; i++) {
				y = Vertex[i];
				if (y < MinY) MinY = y;
				if (y > MaxY) MaxY = y;
				i++;
			}
		}
		*/
		
		public function destroy():Void {
			var i:Int = 0;
			while (i < 4) {
				if (Child[i] !=null) {
					Child[i].destroy();
					Child[i] = null;
				}
				i++;
			}

			Child = null;
			Vertex = null;
			errorList = null;
		}
	
		//se,sw,nw,ne
		// ne, nw, sw, se [4]
		public function	SetupCornerData(q:QuadCornerData, cd:QuadCornerData, ChildIndex:Int):Void
		// Fills the given structure with the appropriate corner values for the
		// specified child block, given our own vertex data and our corner
		// vertex data from cd.
		//
		// ChildIndex mapping:
		// +-+-+
		// |1|0|
		// +-+-+
		// |2|3|
		// +-+-+
		//
		// Verts mapping:
		// 1-0
		// | |
		// 2-3
		//
		// Vertex mapping:
		// +-2-+
		// | | |
		// 3-0-1
		// | | |
		// +-4-+
		{
			var	half:Int = 1 << cd.Level;

			q.Parent = cd;
			q.Square = Child[ChildIndex];
			q.Level = cd.Level - 1;
			q.ChildIndex = ChildIndex;
			
			switch (ChildIndex) {
			case 0:
				q.xorg = cd.xorg + half;
				q.zorg = cd.zorg;
				q.Verts[0] = cd.Verts[0];
				q.Verts[1] = Vertex[2];
				q.Verts[2] = Vertex[0];
				q.Verts[3] = Vertex[1];
				//break;

			case 1:
				q.xorg = cd.xorg;
				q.zorg = cd.zorg;
				q.Verts[0] = Vertex[2];
				q.Verts[1] = cd.Verts[1];
				q.Verts[2] = Vertex[3];
				q.Verts[3] = Vertex[0];
				//break;

			case 2:
				q.xorg = cd.xorg;
				q.zorg = cd.zorg + half;
				q.Verts[0] = Vertex[0];
				q.Verts[1] = Vertex[3];
				q.Verts[2] = cd.Verts[2];
				q.Verts[3] = Vertex[4];
				//break;

			case 3:
				q.xorg = cd.xorg + half;
				q.zorg = cd.zorg + half;
				q.Verts[0] = Vertex[1];
				q.Verts[1] = Vertex[0];
				q.Verts[2] = Vertex[4];
				q.Verts[3] = cd.Verts[3];
				//break;
			}	
		}
		
		


		/*
		public function CountNodes():Int
		// Debugging function.  Counts the number of nodes in this subtree.
		{
			var count:Int = 1;	// Count ourself.

			// Count descendants.
			for (var i:Int = 0; i < 4; i++) {
				if (Child[i]) count += Child[i].CountNodes()
				else {
					for (var u:int = 0; u < 4; u++) {
						if (Child[u] != null) throw new Error("NOT dense!");
					}
				}
			}

			return count;
		}
		*/


	

/*
private function GetNeighbor(dir:int,  cd:QuadCornerData):QuadSquare
// Traverses the tree in search of the QuadSquare neighboring this square to the
// specified direction.  0-3 -. { E, N, W, S }.
// Returns NULL if the neighbor is outside the bounds of the tree.
{
	// If we don't have a parent, then we don't have a neighbor.
	// (Actually, we could have inter-tree connectivity at this level
	// for connecting separate trees together.)
	if (cd.Parent == null) {  
		return cd is QuadCornerDataNeighbor ?  (cd as QuadCornerDataNeighbor).neighbors[dir] != null ? (cd as QuadCornerDataNeighbor).neighbors[dir].Square : null : cd.Square;  // TODO: check, also neighbors[dir] might be optionally null
	}
	
	// Find the parent and the child-index of the square we want to locate or create.
	var p:QuadSquare = null;
	
	var	index:int =  cd.ChildIndex ^ 1 ^ ((dir & 1) << 1);
	var	SameParent:Boolean = ((dir - cd.ChildIndex) & 2) ? true : false;
	
	if (SameParent) {
		p = cd.Parent.Square;
	} else {
		p = cd.Parent.Square.GetNeighbor(dir, cd.Parent);
		if (p == null) return null;
	}
	
	return p.Child[index];
}
*/


public function SampleFromHeightMap(cd:QuadCornerData, hm:HeightMapInfo):Void {
	var BlockSize:Int = 2 << cd.Level;
	if (cd.xorg > hm.XOrigin + ((hm.XSize + 2) << hm.Scale) ||
	    cd.xorg + BlockSize < hm.XOrigin - (1 << hm.Scale) ||
	    cd.zorg > hm.ZOrigin + ((hm.ZSize + 2) << hm.Scale) ||
	    cd.zorg + BlockSize < hm.ZOrigin - (1 << hm.Scale))
	{
		// This square does not touch the given height array area; no need to modify this square or descendants.
		return;
	}
	
	// Is this enabling on the fly really necessary?
	/*
	if (cd.Parent && cd.Parent.Square) {
		cd.Parent.Square.EnableChild(cd.ChildIndex, cd.Parent);	// causes parent edge verts to be enabled, possibly causing neighbor blocks to be created.
	}
	*/
	
	// todo: optimize by checking real indices rather than unnecessary sampling!
	cd.Verts[0] = hm.Sample( cd.xorg + BlockSize, cd.zorg);
	cd.Verts[1] = hm.Sample( cd.xorg, cd.zorg);
	cd.Verts[2] = hm.Sample( cd.xorg, cd.zorg+BlockSize);
	cd.Verts[3] = hm.Sample( cd.xorg + BlockSize, cd.zorg+BlockSize);
	
	var	i:Int;
	
	var half:Int = 1 << cd.Level;
	var size:Int = half << 1;
	
	// Deviate vertex heights based on data sampled from heightmap.
	var	s:Vector<Int> = TypeDefs.createIntVector(5, true);
	s[0] = hm.Sample(cd.xorg + half, cd.zorg + half);
	s[1] = hm.Sample(cd.xorg + (half<<1), cd.zorg + half);
	s[2] = hm.Sample(cd.xorg + half, cd.zorg);
	s[3] = hm.Sample(cd.xorg, cd.zorg + half);
	s[4] = hm.Sample(cd.xorg + half, cd.zorg + (half<<1));

	// Modify the vertex heights if necessary, and set the dirty
	// flag if any modifications occur, so that we know we need to
	// recompute error data later.
	i = 0;
	while (i < 5) {
		//if (s[i] != 0) {
			
			Vertex[i] = s[i];  //+   dont deviate
			 i++;
		//}
	}
}

//public static var DEBUG_ADDCOUNT:int = 0;


public function	AddHeightMap(cd:QuadCornerData,  hm:HeightMapInfo ):Void
// Sets the height of all samples within the specified rectangular
// region using the given array of floats.  Extends the tree to the
// level of detail defined by (1 << hm.Scale) as necessary.
{
	
	// If block is outside rectangle, then don't bother.
	var BlockSize:Int = 2 << cd.Level;
	if (cd.xorg > hm.XOrigin + ((hm.XSize + 2) << hm.Scale) ||
	    cd.xorg + BlockSize < hm.XOrigin - (1 << hm.Scale) ||
	    cd.zorg > hm.ZOrigin + ((hm.ZSize + 2) << hm.Scale) ||
	    cd.zorg + BlockSize < hm.ZOrigin - (1 << hm.Scale))
	{
		// This square does not touch the given height array area; no need to modify this square or descendants.
		return;
	}
	
	// Is this enabling on the fly really necessary?
	/*
	if (cd.Parent && cd.Parent.Square) {
		cd.Parent.Square.EnableChild(cd.ChildIndex, cd.Parent);	// causes parent edge verts to be enabled, possibly causing neighbor blocks to be created.
	}
	*/
	
	
	cd.Verts[0] = hm.Sample( cd.xorg + BlockSize, cd.zorg);
	cd.Verts[1] = hm.Sample( cd.xorg, cd.zorg);
	cd.Verts[2] = hm.Sample( cd.xorg, cd.zorg+BlockSize);
	cd.Verts[3] = hm.Sample( cd.xorg + BlockSize, cd.zorg+BlockSize);
	
	var	i:Int;
	
	var half:Int = 1 << cd.Level;
	var size:Int = half << 1;
	
	// Create and update child nodes.
	if (cd.Level >= hm.Scale) {
		i = 0;
		while ( i < 4) {
			var	q:QuadCornerData =  new QuadCornerData(); 
		//	DEBUG_ADDCOUNT++;
			SetupCornerData(q, cd, i);

			
			
			if (Child[i] == null) {  // && 
				// Create child node w/ current (unmodified) values for corner verts.
				Child[i]  = new QuadSquare(q);
			}
			
			// Recurse.
			//if (Child[i]) {
				Child[i].AddHeightMap(q, hm);
			//}
			 i++;
		}
	}
	
	// Deviate vertex heights based on data sampled from heightmap.
	
	Vertex[0] = hm.Sample(cd.xorg + half, cd.zorg + half);
	Vertex[1] = hm.Sample(cd.xorg + (half<<1), cd.zorg + half);
	Vertex[2] = hm.Sample(cd.xorg + half, cd.zorg);
	Vertex[3] = hm.Sample(cd.xorg, cd.zorg + half);
	Vertex[4] = hm.Sample(cd.xorg + half, cd.zorg + (half<<1));
	
}


// Use RecomputerErrorAndLighting()  to get error value to pass into 2nd parameter for this QuadSquare, recurse down to till (not including)
// targetChunkLevel 2^13 = 8192 ...(32*256=8192)  and for each recursion visit, form up a simpler tree of QuadSquareChunks.

public function GetQuadSquareChunk(cd:QuadCornerData, error:Int, targetChunkLevel:Int=12):QuadSquareChunk {
	if (cd.Level < targetChunkLevel) throw ("LOD of current quad square is too fine for target chunk LOD level!");
	
	var chunk:QuadSquareChunk = new QuadSquareChunk();
	chunk.MinY = MinY;
	chunk.MaxY = MaxY;
	chunk.error = error;
	if (cd.Level == targetChunkLevel)  return chunk;
	
	// with starting cd, recurse though entire quad squares till targetChunkLevel to get error value
	//GetSquareChunkAux(cd, 
	var q:QuadCornerData;
	SetupCornerData( q = new QuadCornerData(), cd, 0);
	chunk.Child[0] = GetQuadSquareChunk(q, errorList[0], targetChunkLevel);  
	SetupCornerData( q =  new QuadCornerData(), cd, 1);
	chunk.Child[1] = GetQuadSquareChunk(q, errorList[1],targetChunkLevel);
	SetupCornerData( q =  new QuadCornerData(), cd, 2);
	chunk.Child[2] = GetQuadSquareChunk(q, errorList[2],targetChunkLevel);
	SetupCornerData( q = new QuadCornerData(), cd, 3);
	chunk.Child[3] = GetQuadSquareChunk(q, errorList[3],targetChunkLevel);
	
	return chunk;
}


///*
 public function RecomputeErrorAndLighting(cd:QuadCornerData):Float 
// Recomputes the error values for this tree.  Returns the
// max error.
// Also updates MinY & MaxY.
// Also computes quick & dirty vertex lighting for the demo.
{
	var	i:Int;
	var	y:Int;  // float
	// Measure error of center and edge vertices.
	var	maxerror:Float = 0;

	// Compute error of center vert.
	var	e:Int;
	if ((cd.ChildIndex & 1)!=0) {
		e = Math.round( Math.abs(Vertex[0] - (cd.Verts[1] + cd.Verts[3]) * 0.5));
	} else {
		e = Math.round(Math.abs(Vertex[0] - (cd.Verts[0] + cd.Verts[2]) * 0.5));
	}
	if (e > maxerror) maxerror = e;

	// Initial min/max.
	MaxY = Vertex[0];
	MinY = Vertex[0];

	// Check min/max of corners.
	i = 0;
	while (i < 4) {
		y = cd.Verts[i];
		if (y < MinY) MinY = y;
		if (y > MaxY) MaxY = y;
	
		i++;
	}
	
	// Edge verts.
	e = Math.round(Math.abs(Vertex[1] - (cd.Verts[0] + cd.Verts[3]) * 0.5));
	if (e > maxerror) maxerror = e;
	errorList[0] = e;
	
	e = Math.round(Math.abs(Vertex[4] - (cd.Verts[2] + cd.Verts[3]) * 0.5));
	if (e > maxerror) maxerror = e;
	errorList[1] = e;

	// Min/max of edge verts.
	i = 0;
	while ( i < 4) {
		y = Vertex[1 + i];
		if (y < MinY) MinY = y;
		if (y > MaxY) MaxY = y;
		i++;
	}
	
	// Check child squares.
	i = 0;
	while (i < 4) {
		
		if (Child[i]!=null) {
			var	q:QuadCornerData = new QuadCornerData();
			SetupCornerData(q, cd, i);
			errorList[i+2] = Std.int(Child[i].RecomputeErrorAndLighting(q));

			if (Child[i].MinY < MinY) MinY = Child[i].MinY;
			if (Child[i].MaxY > MaxY) MaxY = Child[i].MaxY;
			
	
		} else {
			// Compute difference between bilinear average at child center, and diagonal edge approximation.
			errorList[i+2] = Std.int( Math.abs((Vertex[0] + cd.Verts[i]) - (Vertex[i+1] + Vertex[((i+1)&3) + 1])) * 0.25);
		}
		if (errorList[i + 2] > maxerror) maxerror = errorList[i + 2];
		i++;
	}


	//
	// Compute quickie demo lighting.
	//
	//removed off...not required for this case.

	// The error, MinY/MaxY, and lighting values for this node and descendants are correct now.

	
	return maxerror;
}
//*/



}

