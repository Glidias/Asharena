package altern.terrain;
import util.TypeDefs;


/**
 * ...
 * @author Glidias
 */
class QuadSquareChunk 
{
/**
	 * @author Thatcher Ulrich (tu@tulrich.com)
	 * @author Glenn Ko
	 * Thatcher's lod terrain implementation of QuadSquare, but simplified to support some form of fixed-resolution chunked LOD grids. Basically,
	 * each quad square will comprise of a fixed resolution grid batch of triangles (usually 32x32 patches), instead of a mere handful of 4-8 triangles in a 2x2 quad patch
	 * in the earlier software rendered approach. Vertex tests are removed and simplified with a single highest possible error value for the current chunk.
	 */
	

		public var Child:Vector<QuadSquareChunk>;
		
		public static var BlockUpdateCount:Int = 0;	//xxxxx
		private static var DetailThreshold:Float = 100;

		public var error:Int;
		
		// Bounds for frustum culling and error testing.
		public var MinY:Int;
		public var MaxY:Int;	
		
		// important, please set this up to ensure you can get neighboring entries
		public static var QUADTREE_GRID:GridQuadChunkCornerData;
		
		public var 	EnabledFlags:Int;	// bit-30, culled,   bits 8-13: culling mask of frustum planes,   bits 0-7: e, n, w, s, ne, nw, sw, se
		public var	SubEnabledCount:Vector<Int>;	// e, s enabled reference counts. [2]
		
		//public var normals:NormMapInfo;   // e,n,w,s - inner and outer edge normals as a result of stitch blending
		
		public var state:TerrainChunkState;
		
		public static var LOD_LVL_MIN:Int = 12;

		
		
		public function QuadSquareChunk() 
		{
			MinY =  2147483647; //1.79e+308;
			MaxY =  -2147483647; //-1.79e+308;

			var	i:Int;
			Child = TypeDefs.createVector(4, true); // new Vector<QuadSquareChunk>(4, true);

			EnabledFlags = 0;

			SubEnabledCount = TypeDefs.createVector(2, true);// new Vector<Int>(2, true);
			SubEnabledCount[0] = 0;
			SubEnabledCount[1] = 0;
		}
		
		
		
		public function destroy():Void {
			/*
			for (var i:Int = 0; i < 4; i++) {
				if (Child[i] !=null) {
					Child[i].destroy();
					Child[i] = null;
				}
			}
			*/
			if (Child[0] !=null) {
				Child[0].destroy();
				Child[0] = null;
			}
			if (Child[1] !=null) {
				Child[1].destroy();
				Child[1] = null;
			}
			if (Child[2] !=null) {
				Child[2].destroy();
				Child[2] = null;
			}
			if (Child[3] !=null) {
				Child[3].destroy();
				Child[3] = null;
			}
		}
		
		//private static const CLONE_BYTES:ByteArray = new ByteArray();
		/* //  //yagni?
		public function clone():QuadSquareChunk {
			var cloned:QuadSquareChunk = new QuadSquareChunk();
			CLONE_BYTES.position = 0;
			writeExternal(CLONE_BYTES);
			CLONE_BYTES.position = 0;
			cloned.readExternal(CLONE_BYTES);
			return cloned;
		}
		*/
	
	
		// ne, nw, sw, se [4]
		public function	SetupCornerData(q:QuadChunkCornerData, cd:QuadChunkCornerData, ChildIndex:Int):Void
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
			
				
			case 1:
				q.xorg = cd.xorg;
				q.zorg = cd.zorg;
				

			case 2:
				q.xorg = cd.xorg;
				q.zorg = cd.zorg + half;
				

			case 3:
				q.xorg = cd.xorg + half;
				q.zorg = cd.zorg + half;
				
			}	
		}

		public function CountNodes():Int
		// Debugging function.  Counts the number of nodes in this subtree.
		{
			var count:Int = 1;	// Count ourself.

			// Count descendants.
			var i:Int = 0;
			while ( i < 4) {
				if (Child[i]!=null) count += Child[i].CountNodes();
				else {
					var u:Int = 0;
					while( u < 4) {
						if (Child[u] != null) throw ("NOT dense!");
						u++;
					}
				}
				i++;
			}
			

			return count;
		}
		
	


private function GetNeighbor(dir:Int,  cd:QuadChunkCornerData):QuadSquareChunk
// Traverses the tree in search of the quadsquare neighboring this square to the
// specified direction.  0-3 -. { E, N, W, S }.
// Returns NULL if the neighbor is outside the bounds of the tree.
{
	// If we don't have a parent, then we don't have a neighbor.
	// (Actually, we could have inter-tree connectivity at this level
	// for connecting separate trees together.)
	if (cd.Parent == null) {  
		return QUADTREE_GRID != null ? getNeighborCornerData(cd, dir).Square  :  cd.Square; 
	}
	
	// Find the parent and the child-index of the square we want to locate or create.
	var p:QuadSquareChunk = null;
	
	var	index:Int =  cd.ChildIndex ^ 1 ^ ((dir & 1) << 1);
	var	SameParent:Bool = ((dir - cd.ChildIndex) & 2)!=0;
	
	if (SameParent) {
		p = cd.Parent.Square;
	} else {
		p = cd.Parent.Square.GetNeighbor(dir, cd.Parent);
		if (p == null) return null;
	}
	
	return p.Child[index];
}


		
		
		
private static var STACK:Vector<Int> = TypeDefs.createVector(32, true); // new Vector<Int>(32, true);
private function EnableEdgeVertex( index:Int,  IncrementCount:Bool, cd:QuadChunkCornerData):Void
// Enable the specified edge vertex.  Indices go { e, n, w, s }.
// Increments the appropriate reference-count if IncrementCount is true.
{
	if ((EnabledFlags & (1 << index))!=0 && !IncrementCount) return;
	
	// Turn on flag and deal with reference count.
	EnabledFlags |= 1 << index;
	if (IncrementCount  && (index == 0 || index == 3)) {
		SubEnabledCount[index & 1]++;
	}

	// Now we need to enable the opposite edge vertex of the adjacent square (i.e. the alias vertex).

	// This is a little tricky, since the desired neighbor node may not exist, in which
	// case we have to create it, in order to prevent cracks.  Creating it may in turn cause
	// further edge vertices to be enabled, propagating updates through the tree.

	// The sticking point is the QuadChunkCornerData list, which
	// conceptually is just a linked list of activation structures.
	// In this function, however, we will introduce branching into
	// the "list", making it in actuality a tree.  This is all kind
	// of obscure and hard to explain in words, but basically what
	// it means is that our implementation has to be properly
	// recursive.

	// Travel upwards through the tree, looking for the parent in common with our desired neighbor.
	// Remember the path through the tree, so we can travel down the complementary path to get to the neighbor.
	var p:QuadSquareChunk = this;
	var pcd:QuadChunkCornerData = cd;
	var	ct:Int = 0;
	var stack:Vector<Int>= STACK;  // TODO: Buffer this and check that it's okay!
	while(true) {
		var	ci:Int = pcd.ChildIndex;

		if (pcd.Parent == null || pcd.Parent.Square == null) {

			
		
			
			pcd = QUADTREE_GRID!=null ? getNeighborCornerData(pcd, index) : pcd;
			//if (pcd == null)  return;
			
			p = pcd.Square;
	//	if (p == null) throw new Error("WRR!");
			if (ct > 0) break;
			//else {  // duplicate of below
				index ^= 2;
				p.EnabledFlags |= (1 << index);
				if (IncrementCount  && (index == 0 || index == 3)) {
					p.SubEnabledCount[index & 1]++;
				}
				return;
			//}
		}
		p = pcd.Parent.Square;
		pcd = pcd.Parent;

		var	SameParent:Int = ((index - ci) & 2);
		
		ci = ci ^ 1 ^ ((index & 1) << 1);	// Child index of neighbor node.
		stack[ct++] = ci;
		
		
		if (SameParent!=0) break;
	}

	// Get a pointer to our neighbor (create if necessary), by walking down
	// the quadtree from our shared ancestor.
	p = p.EnableDescendant(ct, stack, pcd);
	


	// Finally: enable the vertex on the opposite edge of our neighbor, the alias of the original vertex.
	index ^= 2;
	p.EnabledFlags |= (1 << index);
	if (IncrementCount  && (index == 0 || index == 3)) {
		p.SubEnabledCount[index & 1]++;
	}
}

private function getNeighborCornerData(pcd:QuadChunkCornerData, dir:Int):QuadChunkCornerData 
{
	var x:Int = pcd.xorg;
	var z:Int = pcd.zorg;
	var half:Int = (1 << pcd.Level);
	var full :Int = (half << 1);
	var ci:Int = pcd.ChildIndex;
//	try { 
	if (dir == 0) {  // todo: check sizign and positining
		x += full;
		if (x > QUADTREE_GRID.originX + QUADTREE_GRID.cols * full - full) x = 0;
	}
	else if (dir==1) {
		z -= full;
		if (z < QUADTREE_GRID.originY) {
			z = QUADTREE_GRID.cols * full - full;
		}
	}
	else if (dir == 2) {
		x -= full;
		if (x < QUADTREE_GRID.originX) x = QUADTREE_GRID.cols*full - full;
	}
	else {	
		z += full;
		if (z > QUADTREE_GRID.originY + (QUADTREE_GRID.cols) * full - full) z = 0;
	}
	
	
	//var result:QuadChunkCornerData = ;
	//}
	//catch (e:Error) {
	//	throw new Error("dir:" + dir + ", " + e + ", "+pcd.zorg + ", "+((z-QUADTREE_GRID.originY) >> (pcd.Level+1)) );
	//}
	return QUADTREE_GRID.getCornerData(x, z, pcd.Level);  // todo: check sizing and positinoing
}



private function EnableDescendant( count:Int,  path:Vector<Int>, cd:QuadChunkCornerData):QuadSquareChunk
// This function enables the descendant node 'count' generations below
// us, located by following the list of child indices in path[].
// Creates the node if necessary, and returns a pointer to it.
{
	count--;
	var	ChildIndex:Int = path[count];

	if ((EnabledFlags & (16 << ChildIndex)) == 0) {
		EnableChild(ChildIndex, cd);
	}
	
	if (count > 0) { // more than 1 index in path, need to recurse until end
		var	q:QuadChunkCornerData = QuadChunkCornerData.create();
		SetupCornerData(q, cd, ChildIndex);
		return Child[ChildIndex].EnableDescendant(count, path, q);
	} else {
		return Child[ChildIndex];
	}
}




private function  EnableChild(index:Int, cd:QuadChunkCornerData):Void
// Enable the indexed child node.  { ne, nw, sw, se }
// Causes dependent edge vertices to be enabled.
{
	if (cd.Level <= LOD_LVL_MIN) throw ("SHOULD not allow!");
	
	if ((EnabledFlags & (16 << index)) == 0) {
		EnabledFlags |= (16 << index);
		EnableEdgeVertex(index, true, cd);
		EnableEdgeVertex((index + 1) & 3, true, cd);
		
	}
}



private function NotifyChildDisable( cd:QuadChunkCornerData, index:Int):Void
// Marks the indexed child quadrant as disabled.  Deletes the child node
// if it isn't static.
{
				
	//if (cd.Level < 8) throw new Error("FAILED!");
	// Clear enabled flag for the child.

	EnabledFlags &= ~(16 << index);
	
	// Update child enabled counts for the affected edge verts.
	var s:QuadSquareChunk;
	
	if ((index & 2)!=0) s = this;
	else s = GetNeighbor(1, cd);
	if (s!=null) {
		s.SubEnabledCount[1]--;
	}
	
	if (index == 1 || index == 2) s = GetNeighbor(2, cd);
	else s = this;
	if (s!=null) {
		s.SubEnabledCount[0]--;
	}

	

}

public function	ResetTree():Void
// Clear all enabled flags, and delete all non-static child nodes.
{
	if (Child[0]!=null) {
		Child[0].ResetTree();
	}
	if (Child[1]!=null) {
		Child[1].ResetTree();
	}
	if (Child[2]!=null) {
		Child[2].ResetTree();
	}
	if (Child[3]!=null) {
		Child[3].ResetTree();
	}
	EnabledFlags = 0;
	SubEnabledCount[0] = 0;
	SubEnabledCount[1] = 0;
	
}






		



// todo: re-adjust this to get MINIMUM distance to box
public function	BoxTest(x:Float, z:Float, size:Float, miny:Float, maxy:Float, error:Float, camera:Vector3D):Bool
// Returns true if any vertex within the specified box (origin at x,z,
// edges of length size) with the given error value could be enabled
// based on the given viewer location.
{
	// Find the minimum distance to the box. 
	// Got to check orientation for this...
	var	half:Float = size * 0.5;
	var	dx:Float = Math.abs(x + half - camera.x) - half;
	var	dy:Float =  Math.abs((miny + maxy) * 0.5 - camera.z) - (maxy - miny) * 0.5;  
	var	dz:Float =  Math.abs(z + half - camera.y) - half;
	var	d:Float = dx;
	if (dy > d) d = dy;
	if (dz > d) d = dz;
	
	return (error * DetailThreshold) > d;
}


public function	Update(cd:QuadChunkCornerData,  camera:Vector3D, Detail:Float, culler:ICuller, culling:Int):Void
// Refresh the vertex enabled states in the tree, according to the
// location of the viewer.  May force creation or deletion of qsquares
// in areas which need to be interpolated.
{
	QuadChunkCornerData.BI = 0;
	DetailThreshold = Detail;
	UpdateAux(cd, camera, 0, culler, culling);
}



public	function UpdateAux(cd:QuadChunkCornerData, camera:Vector3D, CenterError:Float, culler:ICuller, culling:Int):Void
// Does the actual work of updating enabled states and tree growing/shrinking.
{

	if (culling < 0) return;
	

	// set culling value
	BlockUpdateCount++;	//xxxxx

	var	half:Int = 1 << cd.Level;
	var	whole:Int = half << 1;
	var	s:QuadSquareChunk;

	var succeeded:Bool = false;
	if (culling >= 0 && cd.Level > LOD_LVL_MIN) {
		
		
		// min LOD level 2^8=256 for tri,  min LOD level for chunk 2^13=8192	 
		

		if ((EnabledFlags & 16) == 0) {
			if ( BoxTest(cd.xorg + half, cd.zorg, half, MinY, MaxY, Child[0].error, camera) ) {
				EnableChild(0, cd);	// ne child.
				succeeded = true;
			}
		}
		
		if ((EnabledFlags & 32) == 0) {
			if ( BoxTest(cd.xorg, cd.zorg, half, MinY, MaxY, Child[1].error, camera)  ) {
				EnableChild(1, cd);	// nw child.er
				succeeded = true;
			}
		}
		if ((EnabledFlags & 64) == 0) {
			if ( BoxTest(cd.xorg, cd.zorg + half, half, MinY, MaxY, Child[2].error, camera)  ) {
				EnableChild(2, cd);	// sw child.
				succeeded = true;
			}
		}
		if ((EnabledFlags & 128) == 0) {
			if ( BoxTest(cd.xorg + half, cd.zorg + half, half, MinY, MaxY, Child[3].error, camera)  ) {
				EnableChild(3, cd);	// se child.
				succeeded = true;
			}
		}
		
		
		
		// Recurse into child quadrants as necessary.
		var	q:QuadChunkCornerData; 

		if ((EnabledFlags & 32)!=0) {
			SetupCornerData(q = QuadChunkCornerData.create(), cd, 1);
			s = Child[1]; 
			s.UpdateAux(q, camera, s.error, culler, culling != 0 ? culler.cullingInFrustum(culling, q.xorg, q.zorg, q.Square.MinY, q.xorg + half, q.zorg + half, q.Square.MaxY) : 0);
		}
		if ((EnabledFlags & 16)!=0) {
			SetupCornerData(q = QuadChunkCornerData.create(), cd, 0);
			s = Child[0]; 
			s.UpdateAux(q, camera, s.error, culler, culling != 0 ?culler.cullingInFrustum(culling, q.xorg, q.zorg, q.Square.MinY, q.xorg + half, q.zorg + half, q.Square.MaxY) : 0 );		
		}
		if ((EnabledFlags & 64)!=0) {
			SetupCornerData(q = QuadChunkCornerData.create(), cd, 2);
			s = Child[2]; 
			s.UpdateAux(q, camera, s.error, culler, culling != 0 ?culler.cullingInFrustum(culling, q.xorg, q.zorg, q.Square.MinY, q.xorg + half, q.zorg + half, q.Square.MaxY) : 0 );		
		}
		if ((EnabledFlags & 128)!=0) {
			SetupCornerData(q = QuadChunkCornerData.create(), cd, 3);
			
			s = Child[3]; 
			s.UpdateAux(q, camera, s.error, culler, culling != 0 ?culler.cullingInFrustum(culling, q.xorg, q.zorg, q.Square.MinY, q.xorg + half, q.zorg + half, q.Square.MaxY) : 0);
		}
		
		
	}

	
	
	var recursable:Bool = succeeded || BoxTest(cd.xorg, cd.zorg, whole, MinY, MaxY, CenterError, camera);
	// Test for disabling.  East, South, and center.
	///*
	if (!recursable) {
		if ((EnabledFlags & 1)!=0 && SubEnabledCount[0] == 0  ) {
			EnabledFlags &= ~1;
			s = GetNeighbor(0, cd);
			if (s!=null) s.EnabledFlags &= ~4;
		}
		if ((EnabledFlags & 8)!=0 && SubEnabledCount[1] == 0  ) {
			EnabledFlags &= ~8;
			s = GetNeighbor(3, cd);
			if (s!=null) s.EnabledFlags &= ~2;
		}
		if ( (EnabledFlags & 0xFF) ==0 &&
			cd.Parent != null 
		   )
		{
			// Disable ourself.
			EnabledFlags = 0;
			cd.Parent.Square.NotifyChildDisable(cd.Parent, cd.ChildIndex);	// nb: possibly deletes 'this'.
		}
	}
	/*
	
	//*/
}

}