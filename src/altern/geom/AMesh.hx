package altern.geom;
import altern.culling.CullingPlane;
import altern.geom.Edge;
import altern.geom.Face;
import altern.geom.Vertex;
import altern.geom.Wrapper;
import haxe.ds.ObjectMap;
import util.geom.Geometry;
import util.geom.Vec3;

/**
 * This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
 * If it is not possible or desirable to put the notice in a particular file, then You may include the notice in a location (such as a LICENSE file in a relevant directory) where a recipient would be likely to look for such a notice.
 * You may add additional accurate notices of copyright ownership.
 *
 * It is desirable to notify that Covered Software was "Powered by AlternativaPlatform" with link to http://www.alternativaplatform.com/ 
 * */

/**
 * Occluder Port to Haxe into a general-usage N-gon mesh geometry instance that can be used to facilitate geometry welding/occlusion culling/clipping/convexity/percentage cover checks.
 * Use `createForm(geometry: altern.Geometry)` reference to start your AMesh version of altern.geometry!
 * @author Glidias
 */
class AMesh 
{
	// Core Mesh geometry
	private var faceList:Face;
	private var vertexList:Vertex;
	
	// ----
	// Used for Occlusion
	private var edgeList:Edge;
	// May optionally be used for Occlusion
	private var planeList:CullingPlane;
	
	// initialization createForm option bit flags
	public static inline var OPTION_CONVEX:Int = (1 << 0);
	public static inline var OPTION_CALCULATE_EDGES:Int = (1 << 1);
	public static inline var OPTION_WELD_VERTICES:Int = (1 << 2);
	public static inline var OPTION_WELD_FACES:Int = (1 << 3);
	
	// minimal workable occluder option (assumed vertices already welded. no welding of faces and vertices)
	public static inline var USE_OPTION_OCCLUDER_LEAST_0:Int = OPTION_CONVEX | OPTION_CALCULATE_EDGES;
	// middle occluder option (variant 1) (assumed vertices already welded. init-welding of faces only)
	public static inline var USE_OPTION_OCCLUDER_LEAST_1:Int = OPTION_CONVEX | OPTION_CALCULATE_EDGES | OPTION_WELD_FACES;
	
	// reccomended typical occluder option (for safe usage across all geometry types)
	public static inline var USE_OPTION_OCCLUDER:Int = USE_OPTION_OCCLUDER_LEAST_0 | OPTION_WELD_VERTICES | OPTION_WELD_FACES;
	
	static var DIGIT_THRESHOLD:Float = 0.001;
	
	public function new() 
	{
		
	}
	
	/**
	 * Creates form of overlap on base of re-created geometry.
	 * @param geometry passed <code>Geometry</code>
	 * @param options  Bitflag options in OPTION / USE_OPTION.
	 * @param distanceThreshold Accuracy, within which the coordinates of the vertices are the same.
	 * @param angleThreshold Permissible angle in radians between normals, that allows to unite faces in one plane.
	 * @param convexThreshold Value, that decrease allowable angle between related edges of united faces.
	 * @see #destroyForm()
	 */
	public function createForm(geometry:Geometry, options:Int, distanceThreshold:Float = 0, angleThreshold:Float = 0, convexThreshold:Float = 0):Void {
		var i:Int;
		
		destroyForm();
		// Checking for the errors
		var geometryIndicesLength:Int = geometry.indices.length;
		if (geometry.numVertices == 0 || geometryIndicesLength == 0) throw "The supplied geometry is empty.";
	
		var vertices:Array<Vertex> = [];
		// Create vertices
		geometryIndicesLength = geometry.numVertices * 3;
		i = 0;
		while (i < geometryIndicesLength) {
			var vertex:Vertex = new Vertex();
			vertex.x = geometry.vertices[i++];
			vertex.y = geometry.vertices[i++];
			vertex.z = geometry.vertices[i++];
			vertices.push(vertex);
		}

		// Create faces
		geometryIndicesLength = geometry.indices.length;
		i = 0;
		while(i < geometryIndicesLength) {
			var a:Int = geometry.indices[i++];
			var b:Int = geometry.indices[i++];
			var c:Int = geometry.indices[i++];
			var face:Face = new Face();
			face.wrapper = new Wrapper();
			face.wrapper.vertex = vertices[a];
			face.wrapper.next = new Wrapper();
			face.wrapper.next.vertex = vertices[b];
			face.wrapper.next.next = new Wrapper();
			face.wrapper.next.next.vertex = vertices[c];
			face.calculateBestSequenceAndNormal();
			face.next = faceList;
			faceList = face;
		}
		
		
		
		// Unite vertices if needed
		vertexList = ((options & OPTION_WELD_VERTICES)!=0) ? weldVertices(vertices, distanceThreshold) : getVerticesFromArray(vertices);
		// Unite faces
		if ((options & OPTION_WELD_FACES)!=0) weldFaces(angleThreshold, convexThreshold);
		// Calculation of edges and checking for the validity
		if ( (options & (OPTION_CONVEX | OPTION_CALCULATE_EDGES)) != 0 ) {
			var error:String = calculateEdges();
			if ((options & OPTION_CONVEX)!=0 && error != null) {
				destroyForm();
				throw error;
			}
			
			if ((options & OPTION_CALCULATE_EDGES) == 0) {
				edgeList = null;
			}
		}
	}
	
	function getVerticesFromArray(vertices:Array<Vertex>):Vertex
	{
		var vList:Vertex;
		if (vertices.length == 0) {
			return null;
		}
		vList = vertices[0];
		var v:Vertex = vList;
		for (i in 1...vertices.length) {
			v = v.next = vertices[i];
		}
		return vList;
	}
	
	inline public function destroyForm():Void {
		faceList = null;
		edgeList = null;
		vertexList = null;
	}
	
	// WELDING METHODS
	
	private function weldVertices(vertices:Array<Vertex>, distanceThreshold:Float):Vertex {
		var vertex:Vertex;
		var verticesLength:Int = vertices.length;
		// Group
		group(vertices, 0, verticesLength, 0, distanceThreshold, new Array<Int>());
		// Change vertices
		var face:Face = faceList;
		while (face != null) {
			var wrapper:Wrapper = face.wrapper;
			while (wrapper != null) {
				if (wrapper.vertex.value != null) {
					wrapper.vertex = wrapper.vertex.value;
				}
				wrapper = wrapper.next;
			}
			face = face.next;
		}
		// Create new list of vertices
		var res:Vertex = null;
		for (i in 0...verticesLength) {
			vertex = vertices[i];
			if (vertex.value == null) {
				vertex.next = res;
				res = vertex;
			}
		}
		return res;
	}
	
	private function group(verts:Array<Vertex>, begin:Int, end:Int, depth:Int, threshold:Float, stack:Array<Int>):Void {
		var i:Int;
		var j:Int;
		var vertex:Vertex;
		switch (depth) {
			case 0: // x
				for (i in begin...end) {
					vertex = verts[i];
					vertex.offset = vertex.x;
				}
			case 1: // y
				for (i in begin...end) {
					vertex = verts[i];
					vertex.offset = vertex.y;
				}
			case 2: // z
				for (i in begin...end) {
					vertex = verts[i];
					vertex.offset = vertex.z;
				}
		}
		// Sorting
		stack[0] = begin;
		stack[1] = end - 1;
		var index:Int = 2;
		while (index > 0) {
			index--;
			var r:Int = stack[index];
			j = r;
			index--;
			var l:Int = stack[index];
			i = l;
			vertex = verts[(r + l) >> 1];
			var median:Float = vertex.offset;
			while (i <= j) {
				var left:Vertex = verts[i];
				while (left.offset > median) {
					i++;
					left = verts[i];
				}
				var right:Vertex = verts[j];
				while (right.offset < median) {
					j--;
					right = verts[j];
				}
				if (i <= j) {
					verts[i] = right;
					verts[j] = left;
					i++;
					j--;
				}
			}
			if (l < j) {
				stack[index] = l;
				index++;
				stack[index] = j;
				index++;
			}
			if (i < r) {
				stack[index] = i;
				index++;
				stack[index] = r;
				index++;
			}
		}
		// Divide on groups further
		i = begin;
		vertex = verts[i];
		var compared:Vertex = null;
		for (j in (i + 1)...(end+1)) {
			if (j < end) compared = verts[j];
			if (j == end || vertex.offset - compared.offset > threshold) {
				if (depth < 2 && j - i > 1) {
					group(verts, i, j, depth + 1, threshold, stack);
				}
				if (j < end) {
					i = j;
					vertex = verts[i];
				}
			} else if (depth == 2) {
				compared.value = vertex;
			}
		}
	}
	
	private function weldFaces(angleThreshold:Float = 0, convexThreshold:Float = 0):Void {
		var i:Int;
		var j:Int;
		var sibling:Face;
		var face:Face;
		var next:Face;
		var wp:Wrapper;
		var sp:Wrapper;
		var w:Wrapper;
		var s:Wrapper;
		var wn:Wrapper;
		var sn:Wrapper;
		var wm:Wrapper;
		var sm:Wrapper;
		var vertex:Vertex;
		var a:Vertex;
		var b:Vertex;
		var c:Vertex;
		var abx:Float;
		var aby:Float;
		var abz:Float;
		var acx:Float;
		var acy:Float;
		var acz:Float;
		var nx:Float;
		var ny:Float;
		var nz:Float;
		var nl:Float;
		var dictionary:ObjectMap<Face, Bool>;
		// Accuracy
		var digitThreshold:Float = DIGIT_THRESHOLD;
		angleThreshold = Math.cos(angleThreshold) - digitThreshold;
		convexThreshold = Math.cos(Math.PI - convexThreshold) - digitThreshold;
		// Faces
		var faceSet:ObjectMap<Face,Bool> = new ObjectMap<Face, Bool>();
		// Map of matching vertex:faces(dictionary)
		var map:ObjectMap<Vertex, ObjectMap<Face,Bool>> = new ObjectMap<Vertex, ObjectMap<Face,Bool>>();
		face = faceList; 
		while (face != null) {
			next = face.next;
			face.next = null;
			faceSet.set(face, true);
			wn = face.wrapper;
			while (wn != null) {
				vertex = wn.vertex;
				dictionary = map.get(vertex);
				if (dictionary == null) {
					dictionary = new ObjectMap<Face, Bool>();
					map.set(vertex, dictionary);
				}
				dictionary.set(face, true);
				
				wn = wn.next;
			}
			face = next;
		}
		faceList = null;
		// Island
		var island:Array<Face> = new Array<Face>();
		// Neighbors of current edge
		var siblings:ObjectMap<Face,Bool> = new ObjectMap<Face,Bool>();
		// Edges, that are not included to current island
		var unfit:ObjectMap<Face,Bool>= new ObjectMap<Face,Bool>();
		while (true) {
			// Get of first face
			face = null;
			for (key in faceSet.keys()) {
				face = key;
				faceSet.remove(key);
				break;
			}
			if (face == null) break;
			// Create island
			var num:Int = 0;
			island[num] = face;
			num++;
			nx = face.normalX;
			ny = face.normalY;
			nz = face.normalZ;
			for (key in unfit.keys()) {
				unfit.remove(key);
			}
			for (i in 0...num) {
				face = island[i];
				for (key in siblings.keys()) {
					siblings.remove(key);
				}
				// Collect potential neighbors of face
				w = face.wrapper;
				while ( w != null ) {
					for (key in map.get(w.vertex).keys()) {
						if (faceSet.get(key) && !unfit.get(key)) {
							siblings.set(key, true);
						}
					}
					
					w = w.next;
				}
				for (key in siblings.keys()) {
					sibling = key;
					// If they match along the normals
					if (nx*sibling.normalX + ny*sibling.normalY + nz*sibling.normalZ >= angleThreshold) {
						// Checking on the neighborhood
						w = face.wrapper;
						while (w != null) {
							wn = (w.next != null) ? w.next : face.wrapper;
							s = sibling.wrapper;
							while (s != null) {
								sn = (s.next != null) ? s.next : sibling.wrapper;
								if (w.vertex == sn.vertex && wn.vertex == s.vertex) break;
							}
							if (s != null) break;
							
							w = w.next;
							
							s = s.next;
						}
						// Add to island
						if (w != null) {
							island[num] = sibling;
							num++;
							faceSet.remove(sibling);
						}
					} else {
						unfit.set(sibling, true);
					}
				}
			}
			// If island has one face
			if (num == 1) {
				face = island[0];
				face.next = faceList;
				faceList = face;
				// Unite of island
			} else {
				while (true) {
					var weld:Bool = false;
					// Loop of island faces
					for (i in 0...num - 1) {
						face = island[i];
						if (face != null) {
							// Try to unite current faces with others
							for (j in 1...num) {
								sibling = island[j];
								if (sibling != null) {
									// Search for the common face
									w = face.wrapper;
									while ( w != null) {
										wn = (w.next != null) ? w.next : face.wrapper;
										s = sibling.wrapper;
										while ( s != null) {
											sn = (s.next != null) ? s.next : sibling.wrapper;
											if (w.vertex == sn.vertex && wn.vertex == s.vertex) break;
											
											s = s.next;
										}
										if (s != null) break;
										
										w = w.next;
									}
									// If faces is not found
									if (w != null) {
										// Expansion of union faces
										while (true) {
											wm = (wn.next != null) ? wn.next : face.wrapper;
											//for (sp = sibling.wrapper; sp.next != s && sp.next != null; sp = sp.next);
											sp = sibling.wrapper;
											while (sp.next != s && sp.next != null) sp = sp.next;
											if (wm.vertex == sp.vertex) {
												wn = wm;
												s = sp;
											} else break;
										}
										while (true) {
											//for (wp = face.wrapper; wp.next != w && wp.next != null; wp = wp.next);
											wp = face.wrapper;
											while (wp.next != w && wp.next != null) wp = wp.next;
											sm = (sn.next != null) ? sn.next : sibling.wrapper;
											if (wp.vertex == sm.vertex) {
												w = wp;
												sn = sm;
											} else break;
										}
										// First bend
										a = w.vertex;
										b = sm.vertex;
										c = wp.vertex;
										abx = b.x - a.x;
										aby = b.y - a.y;
										abz = b.z - a.z;
										acx = c.x - a.x;
										acy = c.y - a.y;
										acz = c.z - a.z;
										nx = acz*aby - acy*abz;
										ny = acx*abz - acz*abx;
										nz = acy*abx - acx*aby;
										if (nx < digitThreshold && nx > -digitThreshold && ny < digitThreshold && ny > -digitThreshold && nz < digitThreshold && nz > -digitThreshold) {
											if (abx * acx + aby * acy + abz * acz > 0) {
												continue;
											}
										} else {
											if (face.normalX * nx + face.normalY * ny + face.normalZ * nz < 0) {
												continue;
											}
										}
										nl = 1/Math.sqrt(abx*abx + aby*aby + abz*abz);
										abx *= nl;
										aby *= nl;
										abz *= nl;
										nl = 1/Math.sqrt(acx*acx + acy*acy + acz*acz);
										acx *= nl;
										acy *= nl;
										acz *= nl;
										if (abx * acx + aby * acy + abz * acz < convexThreshold) {
											continue;
										}
										// Second bend
										a = s.vertex;
										b = wm.vertex;
										c = sp.vertex;
										abx = b.x - a.x;
										aby = b.y - a.y;
										abz = b.z - a.z;
										acx = c.x - a.x;
										acy = c.y - a.y;
										acz = c.z - a.z;
										nx = acz*aby - acy*abz;
										ny = acx*abz - acz*abx;
										nz = acy*abx - acx*aby;
										if (nx < digitThreshold && nx > -digitThreshold && ny < digitThreshold && ny > -digitThreshold && nz < digitThreshold && nz > -digitThreshold) {
											if (abx * acx + aby * acy + abz * acz > 0) {
												continue;
											}
										} else {
											if (face.normalX * nx + face.normalY * ny + face.normalZ * nz < 0) {
												
												continue;
											}
										}
										nl = 1/Math.sqrt(abx*abx + aby*aby + abz*abz);
										abx *= nl;
										aby *= nl;
										abz *= nl;
										nl = 1/Math.sqrt(acx*acx + acy*acy + acz*acz);
										acx *= nl;
										acy *= nl;
										acz *= nl;
										if (abx * acx + aby * acy + abz * acz < convexThreshold) {
											continue;
										}
										// Unite
										weld = true;
										var newFace:Face = new Face();
										newFace.normalX = face.normalX;
										newFace.normalY = face.normalY;
										newFace.normalZ = face.normalZ;
										newFace.offset = face.offset;
										wm = null;
										while (wn != w) {
											sm = new Wrapper();
											sm.vertex = wn.vertex;
											if (wm != null) {
												wm.next = sm;
											} else {
												newFace.wrapper = sm;
											}
											wm = sm;
											
											wn = (wn.next != null) ? wn.next : face.wrapper;
										}
										while (sn != s) {
											sm = new Wrapper();
											sm.vertex = sn.vertex;
											if (wm != null) {
												wm.next = sm;
											} else {
												newFace.wrapper = sm;
											}
											wm = sm;
											
											sn = (sn.next != null) ? sn.next : sibling.wrapper;
										}
										island[i] = newFace;
										island[j] = null;
										face = newFace;
										// TODO: comment to ENG
										// Если, то собираться будет парами, иначе к одной прицепляется максимально (это чуть быстрее)
										//if (pairWeld) break;
									}
								}
							}
						}
					}
					if (!weld) break;
				}
				// Collect of united faces
				for (i in 0...num) {
					face = island[i];
					if (face != null) {
						// Calculate the best sequence of vertices
						face.calculateBestSequenceAndNormal();
						// Add
						face.next = faceList;
						faceList = face;
					}
				}
			}
		}
	}
	
	// EDGE CALCULATION/OCCLUSION METHODS
	
	private function calculateEdges():String {
		var face:Face;
		var wrapper:Wrapper;
		var edge:Edge;
		// Create edges
		face = faceList;
		while (face != null) {
			// Loop of edge segments
			var a:Vertex;
			var b:Vertex;
			wrapper = face.wrapper;
			while (wrapper != null) {
				a = wrapper.vertex;
				b = (wrapper.next != null) ? wrapper.next.vertex : face.wrapper.vertex;
				// Loop of created edges
				edge = edgeList;
				while (edge != null) {
					// If geometry is incorrect
					if (edge.a == a && edge.b == b) {
						return "The supplied geometry is not valid.";
					}
					// If found created edges with these vertices
					if (edge.a == b && edge.b == a) break;
					
					edge = edge.next;
				}
				if (edge != null) {
					edge.right = face;
				} else {
					edge = new Edge();
					edge.a = a;
					edge.b = b;
					edge.left = face;
					edge.next = edgeList;
					edgeList = edge;
				}
				
				wrapper = wrapper.next;  a = b;
			}
			
			face = face.next;
		}
		// Checking for the validity
		var edge = edgeList;
		while (edge != null) {
			// If edge consists of one face
			if (edge.left == null || edge.right == null) {
				return "The supplied geometry is non whole.";
			}
			var abx:Float = edge.b.x - edge.a.x;
			var aby:Float = edge.b.y - edge.a.y;
			var abz:Float = edge.b.z - edge.a.z;
			var crx:Float = edge.right.normalZ*edge.left.normalY - edge.right.normalY*edge.left.normalZ;
			var cry:Float = edge.right.normalX*edge.left.normalZ - edge.right.normalZ*edge.left.normalX;
			var crz:Float = edge.right.normalY*edge.left.normalX - edge.right.normalX*edge.left.normalY;
			// If bend inside
			if (abx*crx + aby*cry + abz*crz < 0) {
				return "The supplied geometry is non convex.";
				//trace("Warning: " + this + ": geometry is non convex.");
			}
			
			edge = edge.next;
		}
		return null;
	}
	
	private inline function clearPlanes():Void {
		var plane:CullingPlane;
		if (planeList != null) {
			plane = planeList;
			while (plane.next != null) plane = plane.next;
			plane.next = CullingPlane.collector;
			CullingPlane.collector = planeList;
			planeList = null;
		}
	}
	
	// OCCLUSION METHODS
	
	/**
	 * Calculates planes in relation to local-coordinate viewing position of AMesh
	 * @param	position	Assumed local coordinate position of AMesh
	 * @param 
	 */
	public function calculatePlanes(position:Vec3):Void {
			var a:Vertex;
			var b:Vertex;
			var c:Vertex;
			var face:Face;
			var plane:CullingPlane;
			// Clear of planes
			clearPlanes();
			if (faceList == null || edgeList == null) return;		
			
			// Visibility of faces
			var cameraInside:Bool = true;
			face = faceList;
			while (face != null) {
				if (face.normalX*position.x + face.normalY*position.y + face.normalZ*position.z > face.offset) {
					face.visible = true;
					cameraInside = false;
				} else {
					face.visible = false;
				}
				
				face = face.next;
			}
			if (cameraInside) return;
			
			
			// Create planes by contour
			var t:Float;
			var ax:Float;
			var ay:Float;
			var az:Float;
			var bx:Float;
			var by:Float;
			var bz:Float;
			var ox:Float;
			var oy:Float;
			//var lineList:CullingPlane = null;
			var occludeAll:Bool = true;
			var d:Float;
			var edge:Edge = edgeList;
			while (edge != null) {
				// If face is into the contour
				if (edge.left.visible != edge.right.visible) {
					// Define the direction (counterclockwise)
					if (edge.left.visible) {
						a = edge.a;
						b = edge.b;
					} else {
						a = edge.b;
						b = edge.a;
					}
					ax = a.x;
					ay = a.y;
					az = a.z;
					bx = b.x;
					by = b.y;
					bz = b.z;
				
					// Create plane by edge
					plane = CullingPlane.create();
					plane.next = planeList;
					planeList = plane;
					
					/*	// TODO cross product
					plane.x = (b.cameraZ*a.cameraY - b.cameraY*a.cameraZ)*camera.correctionY;
					plane.y = (b.cameraX*a.cameraZ - b.cameraZ*a.cameraX)*camera.correctionX;
					plane.z = (b.cameraY * a.cameraX - b.cameraX * a.cameraY) * camera.correctionX * camera.correctionY;
					plane.offset = 0;
					*/
					
					
					
				}
			}
		}
	
	
	
}