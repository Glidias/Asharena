package altern.culling;
import altern.collisions.CollisionBoundNode;
import altern.geom.ClipMacros;
import altern.geom.Face;
import altern.geom.Vertex;
import altern.geom.Wrapper;
import components.Transform3D;
import util.LibUtil;
import util.TypeDefs;
import util.TypeDefs.Vector;
import util.TypeDefs.Vector3D;
import util.geom.Vec3;

#if js
// import js.html.Float32Array;
import altern.js.Delaunator;
#end

/**
 * General utility class to calculate target board percentage cover
 * @author Glidias
 */
class TargetBoardTester 
{
	private var position:Vector3D;
	
	
	private var proot:Vec3 = new Vec3();
	
	private var targOrigin:Vec3 = new Vec3();
	
	private var targPos:Vec3 = new Vec3();
	private var targRight:Vec3 = new Vec3();
	private var targUp:Vec3 = new Vec3();
	private var targLook:Vec3 = new Vec3();
	private var UP:Vector3D = new Vector3D(0, 1, 0);
	private var RIGHT:Vector3D = new Vector3D(1, 0, 0);
	
	private var testIndices:Vector<UInt> = new Vector<UInt>();
	private var testVertices:Vector<Float> = new Vector<Float>();
	private var testFrustumPoints:Vector<Vector3D> = new Vector<Vector3D>();
	private var testFrustumPoints2:Vector<Vector3D> = new Vector<Vector3D>();
	private var testFrustum:CullingPlane;
	
	private var dummyVec:Vec3 = new Vec3();
	private static var IDENTITY:Transform3D = new Transform3D();
	private var disposableFace:Face;
	
	public var yLockedNearClip:Bool = false;
	public var planeOrientedFarclip:Bool = false;
	
	public static inline var PRIORITY_CONCEALMENT:Int = 0;
	public static inline var PRIORITY_COVER:Int = 1;
	private var priorityCover:Int = 0;
	
	private var dfsStack:Array<CollisionBoundNode> = [];
	private var dfsStackCulling:Vector<Int> = new Vector<Int>();
	
	
	public function new() 
	{
		position = new Vector3D();
		
		testFrustumPoints[0] = new Vector3D();
		testFrustumPoints[1] = new Vector3D();
		testFrustumPoints[2] = new Vector3D();
		testFrustumPoints[3] = new Vector3D();
		testFrustumPoints[4] = new Vector3D();
		
		testFrustumPoints2[0] = new Vector3D();
		testFrustumPoints2[1] = new Vector3D();
		testFrustumPoints2[2] = new Vector3D();
		testFrustumPoints2[3] = new Vector3D();
		testFrustumPoints2[4] = new Vector3D();
		
		testFrustum = setupNewFrustum();
}
	

	public function setObserverPosition(x:Float, y:Float, z:Float):Void {
		position.x = x;
		position.y = y;
		position.z = z;
	}
	
	public function setObserverPriority(priority:Int):Void {
		priorityCover = priority;
	}
	
	/**
	 * 
	 * @param	pos	Target position center
	 * @param	up	Target up vector
	 * @param	right	Target right vector
	 * @param	sx	Radius h-width of target
	 * @param	sz	Radius h-height of target
	 * @param 	testBoundNode	Local coordinate space to begin with from "root" of target board location
	 * @param 	customDisposableFace  An optional custom disposable face along the up/right plane of the face
	 */
	public function setupTargetBoard(pos:Vec3, up:Vec3, right:Vec3, sx:Float, sz:Float, testBoundNode:CollisionBoundNode, customDisposableFace:Face=null):Float {
		
		var dx:Float;
		var dy:Float;
	
		targPos.x = pos.x;
		targPos.y = pos.y;
		targPos.z = pos.z;
		
		targUp.x = up.x;
		targUp.y = up.y;
		targUp.z = up.z;
		
		targRight.x = right.x;
		targRight.y = right.y;
		targRight.z = right.z;
		
		// horizontal extent
		dummyVec.x = targRight.x;
		dummyVec.y = 0;
		dummyVec.z = targRight.z;
		dummyVec.normalize();
		dummyVec.scale(sx);
		
		// project right vector over horizontal/vertical extents to see which width to use
		dx = targRight.dotProduct(dummyVec);  
		dy = targRight.y * sz; 
		dx = dx < 0 ? -dx : dx;
		dy = dy < 0 ? -dy : dy;
		var w:Float = dx < dy ? dy : dx;
		
		// project up vector over horizontal/vertical extents to see which height to use
		dx = targUp.dotProduct(dummyVec); 
		dy = targUp.y * sz; 
		dx = dx < 0 ? -dx : dx;
		dy = dy < 0 ? -dy : dy;
		var h:Float = dx < dy ? dy : dx;
		
		h = h >= w ? h : w;  // always enforce square or tall rectangle always for target board
		
		var f:Int = 0;
		
		// cone tip
		testFrustumPoints[f].x = position.x;
		testFrustumPoints[f].y = position.y;
		testFrustumPoints[f].z = position.z;
		
		f++;		// top left corner
		proot.x = targPos.x; proot.y = targPos.y; proot.z = targPos.z;
		proot.x += targUp.x * h;
		proot.y += targUp.y * h;
		proot.z += targUp.z * h;
		proot.x -= targRight.x * w;
		proot.y -= targRight.y * w;
		proot.z -= targRight.z * w;
		testFrustumPoints[f].x = proot.x;
		testFrustumPoints[f].y = proot.y;
		testFrustumPoints[f].z = proot.z;
		
		f++;	// bottom left corner
		proot.x = targPos.x; proot.y = targPos.y; proot.z = targPos.z;
		proot.x -= targUp.x * h;
		proot.y -= targUp.y * h;
		proot.z -= targUp.z * h;
		proot.x -= targRight.x * w;
		proot.y -= targRight.y * w;
		proot.z -= targRight.z * w;
		testFrustumPoints[f].x = proot.x;
		testFrustumPoints[f].y = proot.y;
		testFrustumPoints[f].z = proot.z;
		targOrigin.copyFrom(proot);
		
		f++;	// bottom right corner;
		proot.x = targPos.x; proot.y = targPos.y; proot.z = targPos.z;
		proot.x -= targUp.x * h;
		proot.y -= targUp.y * h;
		proot.z -= targUp.z * h;
		proot.x += targRight.x * w;
		proot.y += targRight.y * w;
		proot.z += targRight.z * w;
		testFrustumPoints[f].x = proot.x;
		testFrustumPoints[f].y = proot.y;
		testFrustumPoints[f].z = proot.z;
		
		f++;	// top right corner
		proot.x = targPos.x; proot.y = targPos.y; proot.z = targPos.z;
		proot.x += targUp.x * h;
		proot.y += targUp.y * h;
		proot.z += targUp.z * h;
		proot.x += targRight.x * w;
		proot.y += targRight.y * w;
		proot.z += targRight.z * w;
		testFrustumPoints[f].x = proot.x;
		testFrustumPoints[f].y = proot.y;
		testFrustumPoints[f].z = proot.z;
		
		// disposableFace != null ? Face.setupQuad(disposableFace, targPos, targUp, targRight, w, h, IDENTITY) : 
		var useFace = customDisposableFace != null ? customDisposableFace : disposableFace != null ? Face.setupQuad(disposableFace, targPos, targUp, targRight, w, h, IDENTITY) : Face.getQuad(targPos, targUp, targRight, w, h, IDENTITY);
		if (customDisposableFace == null) disposableFace = useFace;
		
		TypeDefs.setVectorLen(testIndices, 0);
		TypeDefs.setVectorLen(testVertices, 0);
		
		var startI:Int = 0;
		var di:Int = 0;
		dfsStack[di] = testBoundNode;
		dfsStackCulling[di] = 63;
		di++;
		
		while(--di >= 0) {
			// Go through entire scene graph, for all objects , attempt collidables collection into testIndices, testVertices aray
			var obj:CollisionBoundNode = dfsStack[di];
			var culling:Int = dfsStackCulling[di];
			
			if (obj.worldToLocalTransform == null) {
				obj.calculateLocalWorldTransforms();
			}
			// convert frustum points to local coordinate space and build test frstum
		
			var t:Transform3D = obj.worldToLocalTransform;
			
			for (i in 0...testFrustumPoints.length) {
				var v = testFrustumPoints2[i];
				var r = testFrustumPoints[i];
				// testFrustumPoints2[i] = terrainLOD.globalToLocal();
				v.x = t.a*r.x + t.b*r.y + t.c*r.z + t.d;
				v.y = t.e*r.x + t.f*r.y + t.g*r.z + t.h;
				v.z = t.i * r.x + t.j * r.y + t.k * r.z + t.l;
			}
			
			dummyVec.x = t.a * targPos.x + t.b * targPos.y + t.c * targPos.z + t.d;
			dummyVec.y = t.e * targPos.x + t.f * targPos.y + t.g * targPos.z + t.h;
			dummyVec.z = t.i * targPos.x + t.j * targPos.y + t.k * targPos.z + t.l;
			createFrustumFromPoints(testFrustumPoints2, dummyVec);
			
			// testFrustum against local bounding box of obj (if availble)
			if (obj.boundBox != null) {
				culling = DefaultCulling.cullingInFrustumOf(testFrustum, culling, obj.boundBox.minX, obj.boundBox.minY, obj.boundBox.minZ, obj.boundBox.maxX, obj.boundBox.maxY, obj.boundBox.maxZ);
			}
			
			if (culling >= 0) {
				var c = obj.childrenList;
				while (c != null) {
				
					dfsStack[di] = c;
					dfsStackCulling[di] = culling;
					di++;
					
					c = c.next;
				}
				
				var collectable:IFrustumCollectTri;
				//terrainLOD.collectTrisForFrustum(testFrustum, testFrustumPoints, testVertices, testIndices);
				if (priorityCover != PRIORITY_CONCEALMENT) { // PRIORITY_COVER
					if (obj.collidable != null && (collectable = LibUtil.as(obj.collidable, IFrustumCollectTri))!=null) {
						collectable.collectTrisForFrustum(testFrustum, culling, testFrustumPoints2, testVertices, testIndices);
					}
					else if (obj.raycastable != null && (collectable = LibUtil.as(obj.raycastable, IFrustumCollectTri))!=null) {
						collectable.collectTrisForFrustum(testFrustum, culling, testFrustumPoints2, testVertices, testIndices);
					}
				}
				else {	// PRIORITY_CONCEALMENT
					if (obj.raycastable != null && (collectable = LibUtil.as(obj.raycastable, IFrustumCollectTri))!=null) {
						collectable.collectTrisForFrustum(testFrustum, culling, testFrustumPoints2, testVertices, testIndices);
					}
					else if (obj.collidable != null && (collectable = LibUtil.as(obj.collidable, IFrustumCollectTri))!=null) {
						collectable.collectTrisForFrustum(testFrustum, culling, testFrustumPoints2, testVertices, testIndices);
					}
				}
				
				t = obj.localToWorldTransform; 
				transformVertices(t, startI);
				startI = testVertices.length;
			}

			
			
		}
		
		// end loop
		
		// calculate area subtracted from soup
		var area:Float = useFace.getArea(); // w * h * 4;
		var areaSubtracted:Float = collectClipPolygonsFromSoup(testVertices, testIndices, position.x, position.y, position.z, area, useFace);

		//Log.trace("Of area:" + area);
		/*
		var ratioCover:Float = 0;
		if (areaSubtracted > 0) {
			ratioCover = areaSubtracted / area;
			//Log.trace( Std.int(ratioCover*100)+"% cover" );
		} 
		else {
			Log.trace("Fully exposed");
		}
		*/
		var ratioCover:Float = areaSubtracted / area;
		return ratioCover;
	}
	
	private inline function transformVertices(t:Transform3D, startI:Int):Void {
		var vx:Float; var vy:Float; var vz:Float;
		var len:Int = testVertices.length;
		var i:Int = startI;
		while (i < len) {
			vx = testVertices[i]; vy = testVertices[i+1]; vz = testVertices[i+2];
			testVertices[i] = t.a*vx + t.b*vy + t.c*vz + t.d;
			testVertices[i+1] = t.e*vx + t.f*vy + t.g*vz + t.h;
			testVertices[i + 2] = t.i * vx + t.j * vy + t.k * vz + t.l;
			i += 3;
		}
	}
	
	public  function setupNewFrustum():CullingPlane {
		var cullingPlane:CullingPlane = new CullingPlane();
		var c:CullingPlane = cullingPlane;
		c = c.next = new CullingPlane();
		c = c.next = new CullingPlane();
		c = c.next = new CullingPlane();
		c = c.next = new CullingPlane();
		c = c.next = new CullingPlane();
		return cullingPlane;
	}
	

	// TODO: minmise garbade instantation, use Vec3 instead
	public  function createFrustumFromPoints(pts:Array<Vector3D>, targPos:Vec3):Void {
	
			var cullingPlane:CullingPlane = testFrustum;
			var c:CullingPlane = cullingPlane;
			var v:Vector3D;

			//var lineList:Vector<Vector3D> = new Vector<Vector3D>();
			
			v = pts[2].subtract(pts[0]).crossProduct(pts[1].subtract(pts[0]));
			//v.normalize();
			c.x = v.x;
			c.y = v.y;
			c.z = v.z;
			c.offset = v.x * pts[0].x + v.y * pts[0].y + v.z * pts[0].z; // v.dotProduct(pts[0]);
			//lineList.push(pts[0], pts[2], pts[0], pts[1], pts[1], pts[2]);
		
			
			///*
			c = c.next;
			v = pts[3].subtract(pts[0]).crossProduct(pts[2].subtract(pts[0]));
			//v.normalize();
			c.x = v.x;
			c.y = v.y;
			c.z = v.z;
			c.offset = v.x * pts[0].x + v.y * pts[0].y + v.z * pts[0].z; // v.dotProduct(pts[0]);
			//lineList.push(pts[0], pts[3], pts[2], pts[0], pts[2], pts[3]);
				
			
			c = c.next;
			v = pts[4].subtract(pts[0]).crossProduct(pts[3].subtract(pts[0]));
			//v.normalize();
			c.x = v.x;
			c.y = v.y;
			c.z = v.z;
			c.offset =  v.x * pts[0].x + v.y * pts[0].y + v.z * pts[0].z; // v.dotProduct(pts[0]);
			//lineList.push(pts[0], pts[4], pts[0], pts[3], pts[3], pts[4]);
			
			
			c = c.next;
			v = pts[1].subtract(pts[0]).crossProduct(pts[4].subtract(pts[0]));
			//v.normalize();
			c.x = v.x;
			c.y = v.y;
			c.z = v.z;
			c.offset = v.x * pts[0].x + v.y * pts[0].y + v.z * pts[0].z; // v.dotProduct(pts[0]);
			//lineList.push(pts[0], pts[1], pts[4], pts[0], pts[4], pts[1]);
			
			//*/
			///*
			
			c = c.next;
			//v = targPos.subtract(pts[0]);
			v.x = targPos.x - pts[0].x;
			v.y = yLockedNearClip ? 0 : targPos.y - pts[0].y;
			v.z = targPos.z - pts[0].z;
			
			//v.normalize();
			c.x = v.x;
			c.y = v.y;
			c.z = v.z;
			c.offset = v.x * pts[0].x + v.y * pts[0].y + v.z * pts[0].z; //v.dotProduct(pts[0]);
		
			///*
			c = c.next;
			//v = pts[0].subtract(targPos);
			if (!planeOrientedFarclip) { // view aligned
				v.x = pts[0].x - targPos.x;
				v.y = pts[0].y - targPos.y;
				v.z = pts[0].z - targPos.z;
			} else { // plane aligned
				v = pts[3].subtract(pts[2]).crossProduct(pts[1].subtract(pts[2]));
			}
			//v.normalize();
			c.x = v.x;
			c.y = v.y;
			c.z = v.z;
			c.offset = v.x * targPos.x + v.y * targPos.y + v.z * targPos.z; // v.dotProduct(targPos);
			//*/
			
			//*/
			
			
			// For testing only
			//v = targPos.subtract(pts[0]);
			/*
			v.x = targPos.x - pts[0].x;
			v.y = targPos.y - pts[0].y;
			v.z = targPos.z - pts[0].z;
			var d:Float = v.length * .5;
			v.normalize();
			v.scaleBy(d);
			var testPt:Vector3D = pts[0].add(v);
			
			c = cullingPlane;
			while ( c != null) {
				var dp:Float = testPt.x * c.x + testPt.y * c.y + testPt.z * c.z;
				if (dp < c.offset) {
					throw ("Invalid frustum, not enclosed!" + Math.abs(c.offset - dp) );
				}
				c = c.next;
			}
			*/
		}
		
		
		private var soupPlaneList:CullingPlane;
		private var soupFaceList:Face;
		private var soupNegativeFace:Face;
		
		private function collectClipPolygonsFromSoup(vertices:Vector<Float>, indices:Vector<UInt>, observerX:Float, observerY:Float, observerZ:Float, ofArea:Float, disposableFace:Face):Float {
			var ax:Float;
			var ay:Float;
			var az:Float;
			var len:Int;
			var i:Int;
			var earlyOutFull:Bool = false;
			var retFace:Face;
			
			var p: CullingPlane;
			if (soupPlaneList == null) {	// lazy instantiate 3 planes for triangle soup testing
				soupPlaneList = p = CullingPlane.create();
				p = p.next = CullingPlane.create();
				p = p.next = CullingPlane.create();
			}
			
			soupFaceList = null;
			
			var mask:Int;
			var areaSubtracted:Float = 0;
			
			len = indices.length;
			i = 0;
			while ( i < len) {
				mask = 0;
				var ai:Int = indices[i] * 3;
				var bi:Int = indices[i+1] * 3;
				var ci:Int = indices[i+2] * 3;
				
				ax = vertices[ai];
				ay = vertices[ai+1];
				az = vertices[ai+2];
				
				var bx:Float = vertices[bi];
				var by:Float = vertices[bi+1];
				var bz:Float = vertices[bi + 2];
				
				var cx:Float = vertices[ci];
				var cy:Float = vertices[ci+1];
				var cz:Float = vertices[ci + 2];
				
				var abx:Float;
				var aby:Float;
				var abz:Float;
				
				var acx:Float;
				var acy:Float;
				var acz:Float;
				
				
				p = soupPlaneList;
				abx = ax - observerX;
				aby = ay - observerY;
				abz = az - observerZ;
				acx = bx - observerX;
				acy = by - observerY;
				acz = bz - observerZ;
				p.x = acz*aby - acy*abz;
				p.y = acx*abz - acz*abx;
				p.z = acy * abx - acx * aby;
				p.offset = ax * p.x + ay * p.y + az * p.z;


			
				p = p.next;
				
				abx = bx - observerX;
				aby = by - observerY;
				abz = bz - observerZ;
				acx = cx - observerX;
				acy = cy - observerY;
				acz = cz - observerZ;
				p.x = acz*aby - acy*abz;
				p.y = acx*abz - acz*abx;
				p.z = acy * abx - acx * aby;
				p.offset = bx * p.x + by * p.y + bz * p.z;

				
				p = p.next;
				
				abx = cx - observerX;
				aby = cy - observerY;
				abz = cz - observerZ;
				acx = ax - observerX;
				acy = ay - observerY;
				acz = az - observerZ;
				p.x = acz*aby - acy*abz;
				p.y = acx*abz - acz*abx;
				p.z = acy * abx - acx * aby;
				p.offset = cx * p.x + cy * p.y + cz * p.z;

				//soupOccluder.clipMask = mask;
				
				retFace = ClipMacros.clipWithPlaneList(soupPlaneList, disposableFace );
				soupNegativeFace = retFace;
				
				//var retAreaSubtracted:Float = retFace != null ? retFace.getArea() : 0;
				//var retAreaSubtracted:Float = soupOccluder.clip(soupOccluder._disposableFaceCache);
				if (retFace != null) {
					

					//areaSubtracted += retAreaSubtracted;
					soupNegativeFace.next = soupFaceList;
					soupFaceList = soupNegativeFace;
					if (retFace.getArea() >= ofArea) {
						earlyOutFull = true;
						break;
					}
				}
				
				i += 3;
			}
			
			if (earlyOutFull) 
			{
				//Log.trace("early out full!");
				var lastRetFace:Face = null;
				retFace = soupFaceList;
				while ( retFace != null) {
					retFace.destroy();
					lastRetFace = retFace;
					retFace = retFace.next;
				}
				lastRetFace.next = Face.collector;
				Face.collector = soupFaceList;
				return ofArea;
			}
			

			if (soupFaceList != null) {
				if (soupFaceList.next == null) {	// early out
					areaSubtracted = soupFaceList.getArea();
					soupFaceList.collect();
					soupFaceList = null;
					return areaSubtracted;
				}
				else {
					//Log.trace("Got multiple polies");
					
					//ClipMacros.calculateFaceCoordinates2(soupFaceList, disposableFace);
					/*
					ClipMacros.calculateFaceCoordinates(soupFaceList, targUp, targRight, targPos );
					
					*/
					
					
					/*
					var faceArea:Float = disposableFace.getArea();
					
					var reduc:Float = ClipMacros.disposeTotalAreaIntersections(soupFaceList, faceArea);
					soupFaceList = null;
					if (reduc > 0) Log.trace(Std.int(reduc / faceArea * 100)+" percent reduction overlap");
					areaSubtracted -= reduc;
					
					if (areaSubtracted < -1e-6) Log.trace("Area substracted should not exceed total:" + areaSubtracted);
					*/
					//ClipMacros.calculateFaceCoordinates2(soupFaceList, disposableFace);
					ClipMacros.calculateFaceCoordinates(soupFaceList, targUp, targRight, targPos );
					areaSubtracted = disposeGetTotalArea(soupFaceList);
					
					
					
					return areaSubtracted;
				}
			}
			
			return areaSubtracted;
			
		}
		
	
	public function disposeGetTotalArea(faceList:Face):Float 
	{
		//  Get total area covering target from polygon soup, and dispose recycle polygon soup back to pool
		var accum:Float = 0;
		var lastFace:Face = null;
		var f:Face = faceList;
		var p:Face;
		var processList:Face = null;
		
		var firstFace:Face = null;
		var count:Int = 0;

		f = faceList;
		while (f != null) {
			var fNext:Face = f.next;
			f.next = null;
			p = fNext;
			while (p != null) {
				if ( (!f.visible || !p.visible) && f.overlapsOther2D(p)) {
					if (!f.visible) {
						f.visible = true;
						f.processNext = processList;
						processList = f;
						count++;
					}
				    if (!p.visible) {
						p.visible = true;
						p.processNext = processList;
						processList = p;
					}
				}	
				p = p.next;
			}

			if (!f.visible) {
				// add area
				accum += f.getArea();
				
				f.destroy();
				if (firstFace == null) {
					firstFace = f;
				}
				lastFace = f;
			}		

			f = fNext;
		}
		
		
		if (lastFace != null) {
			lastFace.next = Face.collector;
			Face.collector = firstFace;
		}
		
		
		var retFace:Face; 	
		
		// only 2 intersecting faces
		if (processList != null && processList.processNext.processNext == null) {
			accum += processList.getArea() + processList.processNext.getArea();
			retFace = ClipMacros.getOverlapClipFace(processList, processList.processNext);
			accum -= retFace != null ? retFace.getArea() : 0;
			
			
			processList.processNext.collect();
			processList.collect();
			
			processList.processNext.destroy();
			processList.destroy();
			return accum;
		}
		

		var retFaceList:Face;
		var newList:Face = null;
		
		var d:Int = 0;
		var w:Wrapper;
		var v:Vertex;
		var lastP:Face;
		
		var delauneyId:Int = ++ClipMacros.transformId;
		
		f = processList;
		while ( f != null) {
			retFaceList = null;
			var processNext:Face = f.processNext;
			lastP = null;
			
			
			f.next = newList;
			newList = f;
			
			p = processNext;
			
				
			while (p != null) {
				if (f.overlapsOther2D(p)) {		// no cache, redo check.. bleh..
					retFace = ClipMacros.getOverlapClipFace(f, p);
					if (retFace != null) {
						lastP = p;
						retFace.next = retFaceList;
						retFaceList = retFace;
					}
					
				}
				p = p.processNext;
			}
			
			if (retFaceList != null) {	// there are intersecting faces under f
				/*	// This method doesn't seem to work, hmmm..
				if (retFaceList.next == null) {	// confirmed only 1 overlapping face between f and p, add total Faces area now without adding f to delauney set. 
					accum += f.getArea() + lastP.getArea() - retFaceList.getArea();
					// f can be discarded now as it'll no longer be processed
					Log.trace("early accum:" + accum);
					f.destroy();
					f.collect();
				}
				else {*/  // >=2 overlapping faces, might require delauney if all overlap clip faces have intersections among each other. simply assume delauney
					// add all delauney points from retFaceList faces
					p = retFaceList;
					while (p != null) {
						w = p.wrapper;
						while (w != null) {
							v = w.vertex;
							if (v.transformId != delauneyId) {
								delaunatorPts[d++] = [v.cameraX, v.cameraY];
								v.transformId = delauneyId;
							}
							w = w.next;
						}
						p = p.next;
					}
					
					// got more than 1 intersecting face under f, add to delauney set
					/*
					f.next = newList;
					newList = f;		
					*/
				//}
			}
			/*
			else {	// no intersecting faces under f, but might still need to be considered in delanuey set
				f.next = newList;
				newList = f;
			}
			*/
			f = processNext;
		}

		
		p = newList;
		while ( p != null) {
			w = p.wrapper;
			while (w != null) {
				v = w.vertex;
				if (v.transformId != delauneyId) {
					delaunatorPts[d++] = [v.cameraX, v.cameraY];
					v.transformId = delauneyId;
				}
				w = w.next;
			}
			p = p.next;
		}

		// Only wish to execute 1 final delauney per target
		//Log.trace("Using delaunator method");
		
		#if js
		// requires JS atm until port Delaunator to haxe
		TypeDefs.setVectorLen(delaunatorPts, d);
		
		if (newList !=null) {
			// later consider using typed vector buffer for performance
			var delaunator:Delaunator = Delaunator.from(delaunatorPts);
			
			// create delauney triangulation from points
			var triangles = delaunator.triangles;
			var i = 0;
			while (i < triangles.length) {
				var ax:Float, ay:Float, bx:Float, by:Float, cx:Float, cy:Float;
	
				ax = delaunatorPts[triangles[i]][0];
				ay = delaunatorPts[triangles[i]][1];
				
				
				bx = delaunatorPts[triangles[i+1]][0];
				by = delaunatorPts[triangles[i+1]][1];
				
				cx = delaunatorPts[triangles[i+2]][0];
				cy = delaunatorPts[triangles[i+2]][1];
			
				
				var centerX:Float = (ax + bx + cx) / 3;
				var centerY:Float = (ay + by + cy) / 3;
				// for each triangle centroid, check if inside newList polygon soup. If it is, add area of triangle to accum..
				f = newList;
				var inside = false;
				while ( f != null) {
					if (f.isPointInside2D(centerX, centerY)) {
						inside = true;
						break;
					}
					f = f.next;
				}
				
				if (inside) {
					accum +=  Math.abs(0.5*(ax*(by-cy)+bx*(cy-ay)+cx*(ay-by)));
				}
				i += 3;
			}
			
			
			
			p = newList;
			while ( p != null) {
				p.destroy();
				lastFace = p;
				p = p.next;
			}
			lastFace.next = Face.collector;
			Face.collector = newList;
		}
		#end

		
		
		
		return accum;
	}
	

	
	private var delaunatorPts:Vector<Array<Float>> = [];
	
	
	
}