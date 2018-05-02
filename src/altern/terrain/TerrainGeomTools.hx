package altern.terrain;
import de.polygonal.ds.NativeInt32Array;
import de.polygonal.ds.tools.NativeInt32ArrayTools;
import haxe.ds.Vector;
import util.geom.Geometry;
import util.TypeDefs;

/**
 * ...
 * @author Glidias
 */
class TerrainGeomTools 
{

	public static inline var NORTH_EAST:Int = 0;
	public static inline var  NORTH_WEST:Int = 1;
	public static inline var  SOUTH_WEST:Int = 2;
	public static inline var  SOUTH_EAST:Int = 3;
	
	public static inline var  MASK_EAST:Int = 1;
	public static inline var  MASK_NORTH:Int = 2;
	public static inline var  MASK_WEST:Int = 4;
	public static inline var  MASK_SOUTH:Int = 8;
	
	///*
	public static function createLODTerrainChunkForMesh(patchesAcross:Int=32, patchSize:Int=256):GeometryResult 
		{
			var vAcross:Int = patchesAcross + 1;
			var i:Int;
			
			// code similar to Mesh class in Alternativa3D
			var geom:Geometry = new Geometry();
			TypeDefs.setVectorLen( geom.vertices, vAcross * vAcross, 1);
			/*
			var attributes:Array = [
			  VertexAttributes.POSITION,
			  VertexAttributes.POSITION,
			  VertexAttributes.POSITION,
			  VertexAttributes.TEXCOORDS[0],
			  VertexAttributes.TEXCOORDS[0],
			   VertexAttributes.NORMAL,
			  VertexAttributes.NORMAL,
			  VertexAttributes.NORMAL,
			  VertexAttributes.TANGENT4,
			  VertexAttributes.TANGENT4,
			  VertexAttributes.TANGENT4,
			  VertexAttributes.TANGENT4
			];
			geom.addVertexStream(attributes);
			*/
			var vertices:Vector<Float> = new Vector<Float>();
			var indices:Vector<UInt> = new Vector<UInt>();
			//var vertices:ByteArray = new ByteArray();
			//vertices.endian = Endian.LITTLE_ENDIAN;
			var x:Int;
			var y:Int;
			var segUVSize:Float = 1 / patchesAcross;
			
			var offsetAdditionalData:Int = 0;// 28;
			
			// vIndexLookup could be precomputed actually
			var vIndexLookup:NativeInt32Array =  NativeInt32ArrayTools.alloc(vAcross * vAcross); // new Vector<Int>(vAcross * vAcross, true);
			//i = vIndexLookup.length;
			//while (--i > -1) { vIndexLookup[i] = -1; }
			
			var count:Int = 0;
			
			// Start set of vertices whose vertex normals won't change when LOD stitching between chunks occurs.
			
			// inner vertices (arranged in reading direction: left to right, top to bottom)
			y = 2; 
			while (y < (vAcross - 2)) {
				x = 2;
				while ( x < (vAcross-2)) {
					writeVertices(vertices, x, y, patchSize, segUVSize, offsetAdditionalData);
					vIndexLookup[y * vAcross + x] = count++;
					x++;
				}
				y++;
			}
		
			
			
			// diamond vertex normals don't change when LOD edges stitch, cross vertex normals do.
			// edge flow order: east, north, west, south (always edge update from previous vertex if available)
			
			// Each cardinal side has their own unique set of diamond vertices (ie. no sharing of vertices between sides, since they share no common corners), 
			// unlike cross vertices which share common corner vertices.
			
			//   even-indexed outerEdge vertices (inside) aka. Inner diamond vertices 
			x = vAcross -2;  // east inner diamond
			y = vAcross-3;
			while ( y >= 2) {
				writeVertices(vertices, x, y, patchSize, segUVSize, offsetAdditionalData); // if (vIndexLookup[y * vAcross + x] != -1) throw new Error("Vertex already found 0!");
				vIndexLookup[y * vAcross + x] = count++;
				y -= 2;
			}
			y =  1;  // north  inner diamond
			
			x = vAcross -3;
			while ( x >=2) {  
				writeVertices(vertices, x, y, patchSize, segUVSize,offsetAdditionalData);  //if (vIndexLookup[y * vAcross + x] != -1) throw new Error("Vertex already found 1!");
				vIndexLookup[y * vAcross + x] = count++;
				 x -= 2;
			}
			x = 1;   // west  inner diamond
			y = 2;
			while ( y <= vAcross-3) {
				writeVertices(vertices, x, y, patchSize, segUVSize,offsetAdditionalData);  // if (vIndexLookup[y * vAcross + x] != -1) throw new Error("Vertex already found 2!");
				vIndexLookup[y * vAcross + x] = count++;
				y += 2;
			}
			
			y = vAcross - 2;  // south  inner diamond
			x = 2;
			while ( x <= vAcross-3) {
				writeVertices(vertices, x, y, patchSize, segUVSize, offsetAdditionalData); // if (vIndexLookup[y * vAcross + x] != -1) throw new Error("Vertex already found 3!");
				vIndexLookup[y * vAcross + x] = count++;
				x += 2;
			}
			
			//   odd-indexed outerEdge vertices (outside) aka. Outer diamond vertices.
			y = vAcross - 2;
			x = vAcross -1; 
			while ( y >= 1) {  // east outer diamond
				writeVertices(vertices, x, y, patchSize, segUVSize,offsetAdditionalData); // if (vIndexLookup[y * vAcross + x] != -1) throw new Error("Vertex already found 4!");
				vIndexLookup[y * vAcross + x] = count++;
				y -= 2;
			}
			y = 0;
			x = vAcross-2;
			while ( x >=1) {    // north outer diamond
				writeVertices(vertices, x, y, patchSize, segUVSize,offsetAdditionalData); // if (vIndexLookup[y * vAcross + x] != -1) throw new Error("Vertex already found 5!");
				vIndexLookup[y * vAcross + x] = count++;
				 x -= 2;
			}
			x = 0;   // west  outer diamond
			y = 1; 
			while (y <= vAcross-2) {
				writeVertices(vertices, x, y, patchSize, segUVSize,offsetAdditionalData); // if (vIndexLookup[y * vAcross + x] != -1) throw new Error("Vertex already found 6!");
				vIndexLookup[y * vAcross + x] = count++;
				y += 2;
			}
			x = 1; 
			y = vAcross - 1;  // south outer diamond
			while (x <= vAcross - 2) {
				writeVertices(vertices, x, y, patchSize, segUVSize, offsetAdditionalData); // if (vIndexLookup[y * vAcross + x] != -1) throw new Error("Vertex already found 7!");
				vIndexLookup[y * vAcross + x] = count++;
				x += 2;
			}
			
			
			var noChangeVertexCount:Int = count;
			
			// The vertex indices from here onwards indicates the close-to-edge vertices whose vertex normals can potentially change... (ie. they are cross vertices) as a result
			// of LOD stiching to neighbouring LOD chunks. We process each side's vertex order from the inside out in typical edge-flow order. 
			
			// Remember to skip starting vertex for subsequent sides due to shared corner vertex when flowing to a new side.
			
			// EAST
			x = vAcross -2; 
			y = vAcross-2;
			while ( y >= 1) {   // inner cross  (odd-indexed vertices)
				writeVertices(vertices, x, y, patchSize, segUVSize, offsetAdditionalData); // if (vIndexLookup[y * vAcross + x] != -1) throw new Error("Vertex already found 8!");
				vIndexLookup[y * vAcross + x] = count++;
				 y -= 2;
			}
			x = vAcross - 1;  
			y = vAcross - 1;
			while ( y >= 0 ) { // outer cross  (even-indexed vertices)
				writeVertices(vertices, x, y, patchSize, segUVSize, offsetAdditionalData); // if (vIndexLookup[y * vAcross + x] != -1) throw new Error("Vertex already found 9!");
				vIndexLookup[y * vAcross + x] = count++;
				y -= 2;
			} 
			
			// NORTH
			y = 1; 
			x = vAcross-4;
			while ( x >= 1) {   // inner cross  (odd-indexed vertices)
				writeVertices(vertices, x, y, patchSize, segUVSize, offsetAdditionalData); // if (vIndexLookup[y * vAcross + x] != -1) throw new Error("Vertex already found 10!");
				vIndexLookup[y * vAcross + x] = count++;
				 x -= 2;
			}
			y = 0;  
			x = vAcross - 3;
			while ( x >= 0 ) { // outer cross  (even-indexed vertices)
				writeVertices(vertices, x, y, patchSize, segUVSize, offsetAdditionalData);  //if (vIndexLookup[y * vAcross + x] != -1) throw new Error("Vertex already found 11!");
				vIndexLookup[y * vAcross + x] = count++;
				x -= 2;
			} 
			
			// WEST
			x = 1; 
			y = 3;
			while ( y <= vAcross-2) {   // inner cross  (odd-indexed vertices)
				writeVertices(vertices, x, y, patchSize, segUVSize, offsetAdditionalData);  //if (vIndexLookup[y * vAcross + x] != -1) throw new Error("Vertex already found 12!");
				vIndexLookup[y * vAcross + x] = count++;
				 y += 2;
			}
			x = 0;  
			y = 2;
			while ( y <= vAcross-1) { // outer cross  (even-indexed vertices)
				writeVertices(vertices, x, y, patchSize, segUVSize, offsetAdditionalData);  //if (vIndexLookup[y * vAcross + x] != -1) throw new Error("Vertex already found 13!");
				vIndexLookup[y * vAcross + x] = count++;
				y += 2 ;
			} 
			 
			// SOUTH     (remember to skip last vertex to avoid looping back to first vertex at east side)
			y = vAcross -2;
			x = 3;
			while ( x <= vAcross - 4) {   // inner cross  (odd-indexed vertices)
				writeVertices(vertices, x, y, patchSize, segUVSize, offsetAdditionalData); // if (vIndexLookup[y * vAcross + x] != -1) throw new Error("Vertex already found 14!");
				vIndexLookup[y * vAcross + x] = count++;
				 x += 2;
			}
			y = vAcross -1;
			x = 2;
			while ( x <= vAcross - 3) {   // outer cross  (even-indexed vertices) 
				writeVertices(vertices, x, y, patchSize, segUVSize, offsetAdditionalData); // if (vIndexLookup[y * vAcross + x] != -1) throw new Error("Vertex already found 15!");
				vIndexLookup[y * vAcross + x] = count++;
				 x += 2;
			}
			
				
				// Form up cross hatch index-buffer. 
				// Iterate through quads and form cross patches (4 patches).
				y = 0;
				while (y < patchesAcross) {
					x = 0;
					while ( x < patchesAcross) {
						// ne
						createFace(indices, vertices, vIndexLookup[y*vAcross + x+2], vIndexLookup[y*vAcross + x+1], vIndexLookup[(y + 1)*vAcross + x + 1], vIndexLookup[(y+1)*vAcross + x + 2], 0, 0, 1, 1, 0, 0, -1, false);
						//nw
						createFace(indices, vertices, vIndexLookup[y * vAcross + x], vIndexLookup[(y + 1) * vAcross + x], vIndexLookup[(y + 1) * vAcross + x + 1], vIndexLookup[y * vAcross + x + 1], 0, 0, 1, 1, 0, 0, -1, false);
						// sw
						createFace(indices, vertices, vIndexLookup[(y+1) * vAcross + x+1], vIndexLookup[(y + 1) * vAcross + x], vIndexLookup[(y + 2) * vAcross + x], vIndexLookup[(y+2) * vAcross + x + 1], 0, 0, 1, 1, 0, 0, -1, false);
						// se
						createFace(indices, vertices, vIndexLookup[(y + 1) * vAcross + x + 1], vIndexLookup[(y + 2) * vAcross + x + 1], vIndexLookup[(y + 2) * vAcross + x + 2], vIndexLookup[(y + 1) * vAcross + x + 2], 0, 0, 1, 1, 0, 0, -1, false);		 
						
						x += 2;
					}
					y += 2;
				}
				
				//geom._vertexStreams[0].data = vertices;
				geom.setIndices( indices);
				geom.setVertices( vertices);
		
				var result:GeometryResult = new GeometryResult();
				result.geometry = geom;
				result.edgeChangeVertexIndex = noChangeVertexCount;
				result.uvSeg = segUVSize;
				result.indexLookup  = vIndexLookup;
				result.verticesAcross = vAcross;
				result.patchSize = patchSize;
			return result;
		}
		//*/
		
		
	static function writeVertices(vertices:Vector<Float>, x:Int, y:Int, patchSize:Int, segUVSize:Float, offsetAdditionalData:Int):Void {
			vertices.push(x*patchSize);
			vertices.push(0);
			vertices.push(y*patchSize);
			
			// TODO: how to write uvs and the rest..
			//vertices.push(x*segUVSize);
			//vertices.push(y * segUVSize);
			
			while ( --offsetAdditionalData > -1) {
				vertices.push(0);
			}
			//vertices.length = vertices.position += offsetAdditionalData;
	}
		
	static function createFace(indices:Vector<UInt>, vertices:Vector<Float>, a:Int, b:Int, c:Int, d:Int, nx:Float, ny:Float, nz:Float, tx:Float, ty:Float, tz:Float, tw:Float, reverse:Bool):Void {
		var temp:Int;
		if (reverse) {
			nx = -nx;
			ny = -ny;
			nz = -nz;
			tw = -tw;
			temp = a;
			a = d;
			d = temp;
			temp = b;
			b = c;
			c = temp;
		}
		indices.push(a);
		indices.push(b);
		indices.push(c);
		indices.push(a);
		indices.push(c);
		indices.push(d);
		
		// TODO: how to write normals and tangents
		/*
		vertices.position = a*48 + 20;
		vertices.writeFloat(nx);
		vertices.writeFloat(ny);
		vertices.writeFloat(nz);
		vertices.writeFloat(tx);
		vertices.writeFloat(ty);
		vertices.writeFloat(tz);
		vertices.writeFloat(tw);
		vertices.position = b*48 + 20;
		vertices.writeFloat(nx);
		vertices.writeFloat(ny);
		vertices.writeFloat(nz);
		vertices.writeFloat(tx);
		vertices.writeFloat(ty);
		vertices.writeFloat(tz);
		vertices.writeFloat(tw);
		vertices.position = c*48 + 20;
		vertices.writeFloat(nx);
		vertices.writeFloat(ny);
		vertices.writeFloat(nz);
		vertices.writeFloat(tx);
		vertices.writeFloat(ty);
		vertices.writeFloat(tz);
		vertices.writeFloat(tw);
		vertices.position = d*48 + 20;
		vertices.writeFloat(nx);
		vertices.writeFloat(ny);
		vertices.writeFloat(nz);
		vertices.writeFloat(tx);
		vertices.writeFloat(ty);
		vertices.writeFloat(tz);
		vertices.writeFloat(tw);
		*/
	}
	
	
	public static function writeInnerIndicesToByteArray(patchesAcross:Int, vIndexLookup:NativeInt32Array, indices:Vector<UInt>, addInnerPadding:Int=0):Void {
		var x:Int;
		var y:Int;
		var count:Int = 0;
		var vAcross:Int = patchesAcross + 1;
		y = 2+addInnerPadding;
		while ( y < patchesAcross - 2 - addInnerPadding) {
			x = 2+addInnerPadding;
			while ( x < patchesAcross-2-addInnerPadding) {
				writeRegularQuad(x, y, vAcross, indices, vIndexLookup);
				count++;
				x += 2;
			}
			y += 2;
		}
	}
	
	public static function writeEdgeVerticesToByteArray(patchesAcross:Int, vIndexLookup:NativeInt32Array, indices:Vector<UInt>, edgeMask:Int):Void {
			
			var x:Int;
			var y:Int;
			var vAcross:Int = patchesAcross + 1;
			var count:Int;
		//	/*
			// east
			x = vAcross - 3;
			
			count = 0;
			y = vAcross-5;
			while ( y >= 2) {
				writeConditionalQuad(x, y, vAcross, indices, vIndexLookup, edgeMask & MASK_EAST); count++;
				y -= 2;
			}
			
			
			// north-east corner
			y = 0;
			writeConditionalQuad(x,y,vAcross,indices,vIndexLookup, edgeMask & (MASK_NORTH | MASK_EAST) );
		//	*/
			// north
			count = 0;
			x = vAcross-5;
			while ( x >= 2) {
				writeConditionalQuad(x, y, vAcross, indices, vIndexLookup, edgeMask & MASK_NORTH);  count++; 
				x -= 2;
			}
	//		/*
			// north-west corner
			x = 0;
			writeConditionalQuad(x,y,vAcross,indices,vIndexLookup, edgeMask & (MASK_NORTH | MASK_WEST ) );
			
			// west
			count = 0;
			y = 2;
			while ( y <= vAcross-5) {
				writeConditionalQuad(x, y, vAcross, indices, vIndexLookup, edgeMask & MASK_WEST);  count++;
				 y += 2;
			}
			
			
			// south-west corner
			y = vAcross - 3;
			writeConditionalQuad(x,y,vAcross,indices,vIndexLookup, edgeMask & (MASK_SOUTH | MASK_WEST) );

			
			//south
			count = 0;
			y = vAcross - 3;
			x = 2;
			while ( x <= vAcross-5) {
				writeConditionalQuad(x, y, vAcross, indices, vIndexLookup, edgeMask & MASK_SOUTH );  count++;
				x += 2;
			}

			// south-east corner
			x = vAcross - 3;
			writeConditionalQuad(x,y,vAcross,indices,vIndexLookup, edgeMask & (MASK_SOUTH | MASK_EAST) );
//*/
		}
	
	static private function writeRegularQuad(x:Int, y:Int, vAcross:Int, indices:Vector<UInt>, vIndexLookup:NativeInt32Array):Void 
	{
		var a:Int;
		var b:Int;
		var c:Int;
		var d:Int;
		// ne
		a = vIndexLookup[y * vAcross + x + 2];  b = vIndexLookup[y * vAcross + x + 1]; c =  vIndexLookup[(y + 1) * vAcross + x + 1]; d=  vIndexLookup[(y + 1) * vAcross + x + 2];
		indices.push(a); indices.push(b); indices.push(c);
		indices.push(a); indices.push(c); indices.push(d);
		//nw
		a = vIndexLookup[y * vAcross + x]; b = vIndexLookup[(y + 1) * vAcross + x]; c = vIndexLookup[(y + 1) * vAcross + x + 1]; d= vIndexLookup[y * vAcross + x + 1];
		indices.push(a); indices.push(b); indices.push(c);
		indices.push(a); indices.push(c); indices.push(d);
		// sw
		a = vIndexLookup[(y + 1) * vAcross + x + 1]; b = vIndexLookup[(y + 1) * vAcross + x]; c =  vIndexLookup[(y + 2) * vAcross + x]; d = vIndexLookup[(y + 2) * vAcross + x + 1];
		indices.push(a); indices.push(b); indices.push(c);
		indices.push(a); indices.push(c); indices.push(d);
		// se
		a = vIndexLookup[(y + 1) * vAcross + x + 1]; b = vIndexLookup[(y + 2) * vAcross + x + 1]; c = vIndexLookup[(y + 2) * vAcross + x + 2]; d= vIndexLookup[(y + 1) * vAcross + x + 2];
		indices.push(a); indices.push(b); indices.push(c);
		indices.push(a); indices.push(c); indices.push(d);
	}
	
	
	
		static private function writeConditionalQuad(x:Int, y:Int, vAcross:Int, indices:Vector<UInt>, vIndexLookup:NativeInt32Array, disabledEdgeVertices:Int):Void 
		{
		var a:Int;
		var b:Int;
		var c:Int;
		var d:Int;
				// ne
				a = vIndexLookup[y * vAcross + x + 2];  // tr
				b = vIndexLookup[y * vAcross + x + 1];  // tl
				c =  vIndexLookup[(y + 1) * vAcross + x + 1];  // bl
				d=  vIndexLookup[(y + 1) * vAcross + x + 2];  // br
				if ( (disabledEdgeVertices & (MASK_NORTH | MASK_EAST)  )!=0 ) {
					if ( (disabledEdgeVertices & MASK_NORTH)==0 ) {
						indices.push(c); indices.push(a); indices.push(b);
					}
					if ( (disabledEdgeVertices & MASK_EAST)==0 ) {
						indices.push(c); indices.push(d); indices.push(a);
					}
				}
				else {
					indices.push(a); indices.push(b); indices.push(c);
					indices.push(a); indices.push(c); indices.push(d);
				}
				
				//nw
				///*
				a = vIndexLookup[y * vAcross + x];    // tl
				b = vIndexLookup[(y + 1) * vAcross + x];   //bl
				c = vIndexLookup[(y + 1) * vAcross + x + 1];   //br
				d = vIndexLookup[y * vAcross + x + 1];  // tr
				if ( (disabledEdgeVertices & (MASK_NORTH | MASK_WEST)  )!=0 ) {
					if ( (disabledEdgeVertices & MASK_NORTH)==0 ) {
						indices.push(c); indices.push(d); indices.push(a);
					}
					if ( (disabledEdgeVertices & MASK_WEST)==0 ) {
						indices.push(c); indices.push(a); indices.push(b);
					}
				}
				else {
					indices.push(a); indices.push(b); indices.push(c);
					indices.push(a); indices.push(c); indices.push(d);
				}
				//*/
				
				// sw
				a = vIndexLookup[(y + 1) * vAcross + x + 1];  // tr
				b = vIndexLookup[(y + 1) * vAcross + x];   // tl
				c =  vIndexLookup[(y + 2) * vAcross + x];   // bl
				d = vIndexLookup[(y + 2) * vAcross + x + 1];  // br
				if ( (disabledEdgeVertices & (MASK_SOUTH | MASK_WEST)  )!=0 ) {
					if ( (disabledEdgeVertices & MASK_SOUTH)==0 ) {
						indices.push(a); indices.push(c); indices.push(d);
					}
					if ( (disabledEdgeVertices & MASK_WEST)==0 ) {
						indices.push(a); indices.push(b); indices.push(c);
					}
				}
				else {
					indices.push(a); indices.push(b); indices.push(c);
					indices.push(a); indices.push(c); indices.push(d);
				}
				
				// se
				
				a = vIndexLookup[(y + 1) * vAcross + x + 1];   //tl
				b = vIndexLookup[(y + 2) * vAcross + x + 1];  // bl
				c = vIndexLookup[(y + 2) * vAcross + x + 2];   // br
				d = vIndexLookup[(y + 1) * vAcross + x + 2];  // tr
				if ( (disabledEdgeVertices & (MASK_SOUTH | MASK_EAST)  )!=0 ) {
					if ( (disabledEdgeVertices & MASK_SOUTH)==0 ) {
						indices.push(a); indices.push(b); indices.push(c);
					}
					if ( (disabledEdgeVertices & MASK_EAST)==0 ) {
						indices.push(a); indices.push(c); indices.push(d);
					}
				}
				else {
					indices.push(a); indices.push(b); indices.push(c);
					indices.push(a); indices.push(c); indices.push(d);
				}
			
				
				a = vIndexLookup[(y + 1) * vAcross + x + 1];
				if ( (disabledEdgeVertices & MASK_EAST)!=0 )  {
					b = vIndexLookup[(y + 2) * vAcross + x + 2];
					c = vIndexLookup[y * vAcross + x + 2];
					indices.push(a); indices.push(b); indices.push(c);
				}
				if ( (disabledEdgeVertices & MASK_NORTH)!=0 ) {
					b = vIndexLookup[y * vAcross + x + 2]; 
					c = vIndexLookup[y * vAcross + x];
					indices.push(a); indices.push(b); indices.push(c);
				}
				if ((disabledEdgeVertices & MASK_WEST)!=0) {
					b = vIndexLookup[y * vAcross + x];
					c = vIndexLookup[(y + 2) * vAcross + x];
					indices.push(a); indices.push(b); indices.push(c);
				}
				if ((disabledEdgeVertices & MASK_SOUTH)!=0) {
					b = vIndexLookup[(y + 2) * vAcross + x];
					c = vIndexLookup[(y + 2) * vAcross + x + 2];
					indices.push(a); indices.push(b); indices.push(c);
				}
	}
	
	
}