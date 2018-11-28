package altern.culling;
import altern.geom.ClipMacros;
import altern.geom.Face;
import components.Transform3D;
import haxe.Log;
import util.TypeDefs;
import util.TypeDefs.Vector;
import util.TypeDefs.Vector3D;
import util.geom.Vec3;

/**
 * ...
 * @author ...
 */
class TargetBoardTester 
{
	private var position:Vector3D;
	
	
	private var proot:Vec3 = new Vec3();
	
	private var targPos:Vec3 = new Vec3();
	private var targRight:Vec3 = new Vec3();
	private var targUp:Vec3 = new Vec3();
	private var targLook:Vec3 = new Vec3();
	private var UP:Vector3D = new Vector3D(0, 1, 0);
	private var RIGHT:Vector3D = new Vector3D(1, 0, 0);
	
	private var testIndices:Vector<UInt> = new Vector<UInt>();
	private var testVertices:Vector<Float> = new Vector<Float>();
	private var testFrustum:CullingPlane;
	private var testFrustumPoints:Array<Vector3D> = [];
	
	private var dummyVec:Vec3 = new Vec3();
	private var billboardFarClip:CullingPlane;

	private static var IDENTITY:Transform3D = new Transform3D();
	private var disposableFace:Face;
	
	public function new() 
	{
		position = new Vector3D();
		
		testFrustumPoints[0] = new Vector3D();
		testFrustumPoints[1] = new Vector3D();
		testFrustumPoints[2] = new Vector3D();
		testFrustumPoints[3] = new Vector3D();
		testFrustumPoints[4] = new Vector3D();
}
	
	public function setPosition(x:Float, y:Float, z:Float):Void {
		position.x = x;
		position.y = y;
		position.z = z;
	}
	
	/**
	 * 
	 * @param	pos
	 * @param	up
	 * @param	right
	 * @param	sx
	 * @param	sz
	 * @param	t	localToCamera transform
	 */
	public function setup(pos:Vec3, up:Vec3, right:Vec3, sx:Float, sz:Float):Void {
		
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
		
		var vx:Float;
		var vy:Float;
		var vz:Float;
		
		/// t = planes.localToCameraTransform;
		
		var f:Int = 0;
		
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
		
		
		// workon
		TypeDefs.setVectorLen(testIndices, 0);
		TypeDefs.setVectorLen(testVertices, 0);
		testFrustum = createFrustumFromPoints(testFrustumPoints, targPos);
		//var pp:Vector3D = terrainLOD.globalToLocal(new Vector3D(targPos.x, targPos.y, targPos.z));
		//throw new Error(terrainLOD.scaleX + ", "+terrainLOD.scaleZ + ", "+new Vector3D(terrainLOD.x, terrainLOD.y, terrainLOD.z) );
		//terrainLOD.setupCollisionGeometry( new Vector3D( pp.x, pp.y, pp.z, 1000), testVertices, testIndices);
		//throw new Error(targPos + ", " + (testVertices.length / 3));
		
		var usePoints:Array<Vector3D> = testFrustumPoints;// testFrustumPoints.slice(1, testFrustumPoints.length);
		//terrainLOD.collectTrisForFrustum(testFrustum, usePoints, testVertices, testIndices);
		
		
		//createWireframeCollisionPreview( );
		
		//Object3DTransformUtil.calculateGlobalToLocal(terrainLOD);
		
		disposableFace = disposableFace != null ? Face.setupQuad(disposableFace, targPos, targUp, targRight, w, h, IDENTITY) : Face.getQuad(targPos, targUp, targRight, w, h, IDENTITY);
		//soupOccluder.getDisposableTransformedFace(targPos, targUp, targRight, w, h, terrainLOD.globalToLocalTransform);
		//var pos:Vector3D = terrainLOD.globalToLocal(new Vector3D(cameraObj.x, cameraObj.y, cameraObj.z) );
		
		
		/*
		areaSubtracted = collectClipPolygonsFromSoup(testVertices, testIndices, position.x, position.y, position.z);
		area = soupOccluder._disposableFaceCache.getArea(); // w * h * 4;
		if (areaSubtracted > 0) {
			Log.trace( Std.int(areaSubtracted/area*100)+"% cover" );
		} else {
			Log.trace("Fully exposed");
		}
		*/
		
		
		
	}
	
	
	public  function createFrustumFromPoints(pts:Array<Vector3D>, targPos:Vec3):CullingPlane {
			var cullingPlane:CullingPlane = new CullingPlane();
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
			c = c.next = new CullingPlane();
			v = pts[3].subtract(pts[0]).crossProduct(pts[2].subtract(pts[0]));
			//v.normalize();
			c.x = v.x;
			c.y = v.y;
			c.z = v.z;
			c.offset = v.x * pts[0].x + v.y * pts[0].y + v.z * pts[0].z; // v.dotProduct(pts[0]);
			//lineList.push(pts[0], pts[3], pts[2], pts[0], pts[2], pts[3]);
				
			
			c = c.next = new CullingPlane();
			v = pts[4].subtract(pts[0]).crossProduct(pts[3].subtract(pts[0]));
			//v.normalize();
			c.x = v.x;
			c.y = v.y;
			c.z = v.z;
			c.offset =  v.x * pts[0].x + v.y * pts[0].y + v.z * pts[0].z; // v.dotProduct(pts[0]);
			//lineList.push(pts[0], pts[4], pts[0], pts[3], pts[3], pts[4]);
			
			
			c = c.next = new CullingPlane();
			v = pts[1].subtract(pts[0]).crossProduct(pts[4].subtract(pts[0]));
			//v.normalize();
			c.x = v.x;
			c.y = v.y;
			c.z = v.z;
			c.offset = v.x * pts[0].x + v.y * pts[0].y + v.z * pts[0].z; // v.dotProduct(pts[0]);
			//lineList.push(pts[0], pts[1], pts[4], pts[0], pts[4], pts[1]);
			
			//*/
			///*
			
			c = c.next = new CullingPlane();
			//v = targPos.subtract(pts[0]);
			v.x = targPos.x - pts[0].x;
			v.y = targPos.y - pts[0].y;
			v.z = targPos.z - pts[0].z;
			
			//v.normalize();
			c.x = v.x;
			c.y = v.y;
			c.z = v.z;
			c.offset = v.x * pts[0].x + v.y * pts[0].y + v.z * pts[0].z; //v.dotProduct(pts[0]);
		
			///*
			c = c.next = new CullingPlane();
			//v = pts[0].subtract(targPos);
			v.x = pts[0].x - targPos.x;
			v.y = pts[0].y - targPos.y;
			v.z = pts[0].z - targPos.z;
			//v.normalize();
			c.x = v.x;
			c.y = v.y;
			c.z = v.z;
			c.offset = v.x * targPos.x + v.y * targPos.y + v.z * targPos.z; // v.dotProduct(targPos);
			billboardFarClip = c;
			//*/
			
			//*/
			
			
			// For testing only
			//v = targPos.subtract(pts[0]);
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
			
		
			
			return cullingPlane;
		}
		
		
		private var soupPlaneList:CullingPlane;
		private var soupFaceList:Face;
		private var soupNegativeFace:Face;
		
		private function collectClipPolygonsFromSoup(vertices:Vector<Float>, indices:Vector<UInt>, observerX:Float, observerY:Float, observerZ:Float):Float {
			var ax:Float;
			var ay:Float;
			var az:Float;
			var len:Int;
			var i:Int;
			
			var p: CullingPlane;
			if (soupPlaneList == null) {	// lazy instantiate 3 planes for triangle soup testing
				soupPlaneList = p = CullingPlane.create();
				p = p.next = CullingPlane.create();
				p = p.next = CullingPlane.create();
			}
			
			soupFaceList = null;
			
			var mask:Int;
			var areaSubtracted:Float = 0;
			
			/*
			var precision:Number = 0.000001;
			len = vertices.length;
			for (i = 0; i < len; i += 3) {
				ax = vertices[i];
				ay = vertices[i+1];
				az = vertices[i + 2];
				vertices[i] = Math.round(ax / precision) * precision;
				vertices[i+1] = Math.round(ay / precision) * precision;
				vertices[i+2] = Math.round(az / precision) * precision;
			}
			*/
			
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
				
				
				// Not sure why broadphase didn't detect this case, force-doing this for narrow phase
				if ( billboardFarClip.x * ax + billboardFarClip.y * ay + billboardFarClip.z * az < billboardFarClip.offset || billboardFarClip.x * bx + billboardFarClip.y * by + billboardFarClip.z * bz < billboardFarClip.offset || billboardFarClip.x * cx + billboardFarClip.y * cy + billboardFarClip.z * cz < billboardFarClip.offset ) {
					//Log.trace("Exit");
					
					i += 3;
					continue;
				}
				
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
				//Log.trace(p.x + ", "+p.y + " , "+p.z + ", "+p.offset);
				mask |=  billboardFarClip.x * ax  + billboardFarClip.y * ay + billboardFarClip.z * az < billboardFarClip.offset && billboardFarClip.x * bx  + billboardFarClip.y * by + billboardFarClip.z * bz < billboardFarClip.offset  ? 1 : 0; 

			
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
				//Log.trace(p.x + ", "+p.y + " , "+p.z + ", "+p.offset);
				mask |=  billboardFarClip.x * bx  + billboardFarClip.y * by + billboardFarClip.z * bz < billboardFarClip.offset && billboardFarClip.x * cx  + billboardFarClip.y * cy + billboardFarClip.z * cz < billboardFarClip.offset  ? 2 : 0; 
				
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
				//Log.trace(p.x + ", "+p.y + " , "+p.z + ", "+p.offset);
				mask |=  billboardFarClip.x * ax  + billboardFarClip.y * ay + billboardFarClip.z * az < billboardFarClip.offset && billboardFarClip.x * cx  + billboardFarClip.y * cy + billboardFarClip.z * cz < billboardFarClip.offset  ? 4 : 0; 
				
				if (mask != 0) Log.trace("MASK:"+mask);
				//soupOccluder.clipMask = mask;
				
				var retFace:Face = ClipMacros.clipWithPlaneList(soupPlaneList, soupNegativeFace );
				var retAreaSubtracted:Float = retFace != null ? retFace.getArea() : 0;
				//var retAreaSubtracted:Float = soupOccluder.clip(soupOccluder._disposableFaceCache);
				if (retAreaSubtracted > 0) {
					areaSubtracted += retAreaSubtracted;
					soupNegativeFace.next = soupFaceList;
					soupFaceList = soupNegativeFace;
				}
				
				i += 3;
			}
				

			if (soupFaceList != null) {
				if (soupFaceList.next == null) {	// early out
					soupFaceList.collect();
					soupFaceList = null;
					return areaSubtracted;
				}
				else {
					//Log.trace("Got multiple polies");
					soupOccluder.calculateFaceCoordinates(soupFaceList,  soupNegativeFace);
					var reduc:Float = ClipMacros.disposeTotalAreaIntersections(soupFaceList);
					soupFaceList = null;
					if (reduc > 0) Log.trace(Std.int(reduc / soupNegativeFace.getArea() * 100)+" percent reduction overlap");
					areaSubtracted -= reduc;
					
					if (areaSubtracted < -1e-6) Log.trace("Area substracted should not exceed total:" + areaSubtracted);
					return areaSubtracted;
				}
			}
			
			return areaSubtracted;
			
		}
	
	
	
}