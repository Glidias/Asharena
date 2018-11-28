package alternativa.a3d.systems.hud 
{

	import alternativa.engine3d.core.CullingPlane;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.Occluder;
	import alternativa.engine3d.core.Transform3D;
	import alternativa.engine3d.core.VertexAttributes;
	import alternativa.engine3d.materials.FillMaterial;
	import alternativa.engine3d.objects.Mesh;
	import alternativa.engine3d.objects.MeshSetClone;
	import alternativa.engine3d.objects.MeshSetClonesContainer;
	import alternativa.engine3d.objects.WireFrame;
	import alternativa.engine3d.primitives.Box;
	import alternativa.engine3d.primitives.Plane;
	import alternativa.engine3d.resources.Geometry;
	import alternativa.engine3d.utils.GeometryUtil;
	import alternativa.engine3d.utils.Object3DTransformUtil;
	import alternativa.engine3d.utils.Object3DUtils;
	import alternterrain.objects.TerrainLOD;
	import ash.core.Engine;
	import ash.core.NodeList;
	import ash.core.System;
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.ui.Keyboard;
	import haxe.Log;
	import input.KeyPoll;
	import util.SpawnerBundle;
	import util.geom.Vec3;
	import alternativa.engine3d.alternativa3d;
	use namespace alternativa3d;
	
	/**
	 * Test out plane orientation and 4 corners of each oriented target board.
	 * 
	 * @author Glidias
	 */
	public class TargetBoardTester extends System
	{
		private var position:Vec3;
		private var nodeList:NodeList;
		private var planes:MeshSetClonesContainer;
		private var corners:MeshSetClonesContainer;
		
		private var billboardMat:FillMaterial = new FillMaterial(0xFF0000, 0.5);
		private var cornerMat:FillMaterial = new FillMaterial(0x0000FF, 1);
		
		private var cameraObj:Object3D;
		
		public var testOccluder:Occluder;
		public var soupOccluder:Occluder = new Occluder();
		
		public function TargetBoardTester(scene:Object3D, position:Vec3, cameraObj:Object3D=null, keyPoll:KeyPoll=null, terrainLOD:TerrainLOD=null) 
		{
			this.terrainLOD = terrainLOD;
			this.keyPoll = keyPoll;
			this.cameraObj = cameraObj;
			this.position = position;
			var p:Plane = new Plane(1, 1, 1, 1, false, false);
			p.rotationX = -Math.PI * .5;  

	
			
			GeometryUtil.globalizeMesh(p);
			
			planes = new MeshSetClonesContainer(p, billboardMat );
			
			corners = new MeshSetClonesContainer(new Box(4,4,4,1,1,1, false), cornerMat );
			if (position == null) this.position = new Vec3();
			scene.addChild(planes);
			scene.addChild(corners);
			
			SpawnerBundle.uploadResourcesOf(planes);
			SpawnerBundle.uploadResourcesOf(corners);
			
			testFrustumPoints[0] = new Vector3D();
			testFrustumPoints[1] = new Vector3D();
			testFrustumPoints[2] = new Vector3D();
			testFrustumPoints[3] = new Vector3D();
			testFrustumPoints[4] = new Vector3D();
		}
		
		override public function addToEngine (engine:Engine) : void {
			nodeList = engine.getNodeList(TargetBoardNode);
			
		}
		
		private var billboardMatrix:Matrix3D = new Matrix3D();
		private var rawData:Vector.<Number> = new Vector.<Number>(16, true);
		
		private function CreateBillboardMatrix(right:Vec3, up:Vec3, look:Vec3, pos:Vec3, width:Number, height:Number):Matrix3D {
			/*
			 * 
			 
				right.x, look.x, up.x, 0,
				right.y, look.y, up.y, 0,
				right.z, look.z, up.z, 0,
				targPos.x, targPos.y, targPos.z, 1
			 
			 */
			///*
			var matrix:Matrix3D = billboardMatrix;
			var rawData:Vector.<Number> = this.rawData;  
			rawData[0] = -right.x * width; rawData[1] =  -right.y * width; rawData[2] = -right.z * width; rawData[3] =  0;
			rawData[4] = look.x; rawData[5] = look.y; rawData[6] =  look.z; rawData[7] =  0;
			rawData[8] = up.x * height; rawData[9] = up.y * height; rawData[10] =  up.z * height;  rawData[11] =  0;
			rawData[12] = pos.x; rawData[13] =  pos.y; rawData[14] =  pos.z; rawData[15] = 1;
			
			matrix.copyRawDataFrom(rawData);
			/*
			-1,-8.742277657347586e-8,0,0,
			8.628069991800658e-8, -0.9869361519813538,0.16111187636852264,0,
			-1.4084847954620727e-8,0.16111187636852264,0.9869361519813538,0
			
1.0728003978729248,-519.7822875976563,-35224.23046875,1,

0.9869361519813538,-2.9326055472900237e-10,4.7247757789525835e-11,0,
-2.9326055472900237e-10,-0.9869361519813538,0.15900714695453644,0,
0,0.16111187636852264,0.9740429520606995,0,

-1.0728003978729248,-519.7822875976563,-35224.23046875,1
			*/
		
			
			//*/
			//fixMatrix.append(matrix);
			//fixMatrix.appendTranslation(pos.x, pos.y, pos.z);
			//throw new Error(fixMatrix.rawData);
			
			return matrix;
		}
		
		private var targPos:Vec3 = new Vec3();
		private var targRight:Vec3 = new Vec3();
		private var targUp:Vec3 = new Vec3();
		private var targLook:Vec3 = new Vec3();
		private var dv:Vec3 =  new Vec3();
		private var UP:Vec3 = new Vec3(0, 0, 1)
	
		private var RIGHT:Vec3 = new Vec3(1, 0, 0);
		
		private function logNumbers(arr:Array):void {
			var str:String = "";
			
			for (var i:int = 0; i < arr.length; i++) {
				var vec:Vector.<Number> = arr[i];
				var arr2:Array = [];
				for (var n:int = 0; n < vec.length; n++) {
					arr2.push( Number(Math.round(vec[n]/0.01) * 0.01).toFixed(2) );
				}
	
				str += arr2.join("|")+"___";
			}
			//Log.trace(str);
		}
		
		
		override public function update(time:Number):void
		{
			if (cameraObj != null) {
				position.x = cameraObj.x;
				position.y = cameraObj.y;
				position.z = cameraObj.z;
			}
	
			//var totalSprites:int = 0;
			
			planes.numClones = 0;
			corners.numClones = 0;
			
			for (var n:TargetBoardNode = nodeList.head as TargetBoardNode; n != null; n = n.next as TargetBoardNode) {
				
				targPos.x = n.pos.x;
				targPos.y = n.pos.y;
				targPos.z = n.pos.z;
				var dx:Number = position.x - targPos.x;
				var dy:Number = position.y - targPos.y;
				var dz:Number = position.z - targPos.z;
				var sd:Number = dx * dx + dy * dy + dz * dz;
				var d:Number = Math.sqrt(sd);
				var di:Number = 1 / d;
				targLook.x = dx * di;
				targLook.y = dy * di;
				targLook.z = dz * di;
				//Vec3.writeCross(UP, targLook, targRight);
				//targRight.normalize();  // any way to avoid normalizing?
				targRight.x = UP.y * targLook.z -  UP.z * targLook.y;
				targRight.y = UP.z * targLook.x - UP.x * targLook.z;
				targRight.z = UP.x * targLook.y - UP.y * targLook.x;
				targRight.normalize();
				

				
				var sc:Number = 1 / targLook.z;		
				
				//targLook.z;
				
				Vec3.writeCross(targLook, targRight, targUp);
				//targUp.normalize();
				
				var sx:Number = n.size.x - 4;
				var sz:Number = n.size.z;
				/*  // center of mass size modifications
				var wh:Number = 42;
				sz = wh*.5;
				targPos.z += sz*.5;
				*/
		
				var p:MeshSetClone = planes.addNewOrAvailableClone();
				
				
				var m:Matrix3D;
				

				
				/*
				objectTransform = dummyObj.matrix.decompose();
				objectTransform[0].x = targPos.x;
				objectTransform[0].y = targPos.y;
				objectTransform[0].z = targPos.z;
				var v:Vector3D = objectTransform[1];
				v.x = Math.atan2(dz, Math.sqrt(dx*dx + dy*dy));
				v.y = 0;
				v.z = -Math.atan2(dx, dy);
				m = new Matrix3D();
				m.recompose(objectTransform);
				p.root.matrix = m;
				*/
				
				//var arr:Array = [];
				/*
				targRight.x = 1;
				targRight.y = 0;
				targRight.z = 0;
				targUp.x = 0;
				targUp.y = 0;
				targUp.z = 1;
				targLook.x = 0;
				targLook.y = 1;
				targLook.z = 0;
				*/
				//*/
				
				// z-locked right vector multiplied over ellipsoid.x (assumed same as ellipsoid.y), is used for horizontal extent
				// UP vector is used for vertical extent....
				
				// horizontal extent
				dummyVec.copyFrom(targRight);
				dummyVec.z = 0;
				dummyVec.normalize();
				dummyVec.scale(sx);
				
				
				
			
				
				// project right vector over horizontal/vertical extents to see which width to use
				dx = targRight.dotProduct(dummyVec);  
				dy = targRight.z * sz; 
				dx = dx < 0 ? -dx : dx;
				dy = dy < 0 ? -dy : dy;
				var w:Number = dx < dy ? dy : dx;
				
				// project up vector over horizontal/vertical extents to see which height to use
				
				
				dx = targUp.dotProduct(dummyVec); 
				dy = targUp.z * sz; 
				dx = dx < 0 ? -dx : dx;
				dy = dy < 0 ? -dy : dy;
				var h:Number = dx < dy ? dy : dx;
				
				h = h >= w ? h : w;  // always enforce square or tall rectangle always for target board
				
				//targPos.z += 27*.5;
				//h -= 27/n.size.z*2;
				
				p.root.matrix = m = CreateBillboardMatrix(targRight, targUp, targLook, targPos, w*2, h*2 );
		
				/*
				var data:Vector.<Number> = m.rawData;
				targRight.x = -data[0];
				targRight.y = -data[1];
				targRight.z = -data[2];
				targUp.x = data[8];
				targUp.y = data[9];
				targUp.z = data[10];
				*/
			
				//p.root.rotationY = 0;
				///*
				
				var t:Transform3D;
				var vx:Number;
				var vy:Number;
				var vz:Number;
				
				t = planes.localToCameraTransform;
				
				var f:int = 0;
				
				testFrustumPoints[f].x = cameraObj.x;
				testFrustumPoints[f].y = cameraObj.y;
				testFrustumPoints[f].z = cameraObj.z;
				
				
				f++;		// top left corner
				p = corners.addNewOrAvailableClone();
				p.root.x = targPos.x; p.root.y = targPos.y; p.root.z = targPos.z;
				p.root.x += targUp.x * h;
				p.root.y += targUp.y * h;
				p.root.z += targUp.z * h;
				p.root.x -= targRight.x * w;
				p.root.y -= targRight.y * w;
				p.root.z -= targRight.z * w;
				
				/*
				vx = p.root.x; vy = p.root.y; vz = p.root.z;
				p.root.x = t.a*vx + t.b*vy + t.c*vz + t.d;
				p.root.y = t.e*vx + t.f*vy + t.g*vz + t.h;
				p.root.z = t.i * vx + t.j * vy + t.k * vz + t.l;
				vx = p.root.x; vy = p.root.y; vz = p.root.z;
				
				t = planes.cameraToLocalTransform;
				vx = p.root.x; vy = p.root.y; vz = p.root.z;
				p.root.x = t.a*vx + t.b*vy + t.c*vz + t.d;
				p.root.y = t.e*vx + t.f*vy + t.g*vz + t.h;
				p.root.z = t.i * vx + t.j * vy + t.k * vz + t.l;
				*/
				testFrustumPoints[f].x = p.root.x;
				testFrustumPoints[f].y = p.root.y;
				testFrustumPoints[f].z = p.root.z;
				
				
				f++;	// bottom left corner
				p = corners.addNewOrAvailableClone();
				p.root.x = targPos.x; p.root.y = targPos.y; p.root.z = targPos.z;
				p.root.x -= targUp.x * h;
				p.root.y -= targUp.y * h;
				p.root.z -= targUp.z * h;
				p.root.x -= targRight.x * w;
				p.root.y -= targRight.y * w;
				p.root.z -= targRight.z * w;
				testFrustumPoints[f].x = p.root.x;
				testFrustumPoints[f].y = p.root.y;
				testFrustumPoints[f].z = p.root.z;
				
				f++;	// bottom right corner
				p = corners.addNewOrAvailableClone();
				p.root.x = targPos.x; p.root.y = targPos.y; p.root.z = targPos.z;
				p.root.x -= targUp.x * h;
				p.root.y -= targUp.y * h;
				p.root.z -= targUp.z * h;
				p.root.x += targRight.x * w;
				p.root.y += targRight.y * w;
				p.root.z += targRight.z * w;
				testFrustumPoints[f].x = p.root.x;
				testFrustumPoints[f].y = p.root.y;
				testFrustumPoints[f].z = p.root.z;
				
				f++;	// top right corner
				p = corners.addNewOrAvailableClone();
				p.root.x = targPos.x; p.root.y = targPos.y; p.root.z = targPos.z;
				p.root.x += targUp.x * h;
				p.root.y += targUp.y * h;
				p.root.z += targUp.z * h;
				p.root.x += targRight.x * w;
				p.root.y += targRight.y * w;
				p.root.z += targRight.z * w;
				testFrustumPoints[f].x = p.root.x;
				testFrustumPoints[f].y = p.root.y;
				testFrustumPoints[f].z = p.root.z;
				
				
				
				
				if (testOccluder != null) {
					var areaSubtracted:Number =  testOccluder.clip( testOccluder.getDisposableTransformedFace(targPos, targUp, targRight, w, h, planes.localToCameraTransform)  );
					var area:Number = w * h * 4;
					if (areaSubtracted > 0) {
						//Log.trace( int(areaSubtracted/area*100)+"% cover" );
					}
					else {
						//Log.trace("Fully exposed");
					}
					
				}
				
			
				

				if (keyPoll != null && keyPoll.isDown(Keyboard.SLASH) && terrainLOD != null ) {
					
		
					for (var i:int = 0; i < testFrustumPoints.length; i++) {
						testFrustumPoints[i] = terrainLOD.globalToLocal(testFrustumPoints[i]);
					}
				
					testIndices.length = 0;
					testVertices.length = 0;
					testFrustum = createFrustumFromPoints(testFrustumPoints, terrainLOD.globalToLocal(new Vector3D(targPos.x, targPos.y, targPos.z) ));
					//var pp:Vector3D = terrainLOD.globalToLocal(new Vector3D(targPos.x, targPos.y, targPos.z));
					//throw new Error(terrainLOD.scaleX + ", "+terrainLOD.scaleZ + ", "+new Vector3D(terrainLOD.x, terrainLOD.y, terrainLOD.z) );
					//terrainLOD.setupCollisionGeometry( new Vector3D( pp.x, pp.y, pp.z, 1000), testVertices, testIndices);
					//throw new Error(targPos + ", " + (testVertices.length / 3));
					
					var usePoints:Vector.<Vector3D> = testFrustumPoints;// testFrustumPoints.slice(1, testFrustumPoints.length);
					terrainLOD.collectTrisForFrustum(testFrustum, usePoints, testVertices, testIndices);
					createWireframeCollisionPreview( );
					/*
					Object3DTransformUtil.calculateGlobalToLocal(terrainLOD);
					soupOccluder.getDisposableTransformedFace(targPos, targUp, targRight, w, h, terrainLOD.globalToLocalTransform);
					
					var pos:Vector3D = terrainLOD.globalToLocal(new Vector3D(cameraObj.x, cameraObj.y, cameraObj.z) );
					areaSubtracted = collectClipPolygonsFromSoup(testVertices, testIndices, pos.x, pos.y, pos.z);
					*/
					Object3DTransformUtil.calculateLocalToGlobal(terrainLOD);
					soupOccluder.getDisposableTransformedFace(targPos, targUp, targRight, w, h, new Transform3D());
					transformVertices(terrainLOD.localToGlobalTransform);
					
					//createFrustumFromPoints(oldFrustumPoints, new Vector3D(targPos.x, targPos.y, targPos.z));
					
					areaSubtracted = collectClipPolygonsFromSoup(testVertices, testIndices, cameraObj.x, cameraObj.y, cameraObj.z);
					
					
					
					area = soupOccluder._disposableFaceCache.getArea(); // w * h * 4;
					if (areaSubtracted > 0) {
						Log.trace( int(areaSubtracted/area*100)+"% cover" );
					} else {
						Log.trace("Fully exposed");
					}
					//throw new Error(testVertices.length / 3);
				}
			
				break;
	
			}
			
			
		}
		
		private function transformVertices(t:Transform3D):void {
			var vx:Number; var vy:Number; var vz:Number;
			var len:int = testVertices.length;
			for (var i:int = 0; i < len; i += 3) {
				vx = testVertices[i]; vy = testVertices[i+1]; vz = testVertices[i+2];
				testVertices[i] = t.a*vx + t.b*vy + t.c*vz + t.d;
				testVertices[i+1] = t.e*vx + t.f*vy + t.g*vz + t.h;
				testVertices[i+2] = t.i * vx + t.j * vy + t.k * vz + t.l;
				
			}
		}
		
		private function collectClipPolygonsFromSoup(vertices:Vector.<Number>, indices:Vector.<uint>, observerX:Number, observerY:Number, observerZ:Number):Number {
			var ax:Number;
			var ay:Number;
			var az:Number;
			var len:int;
			var i:int;
			
			var p: CullingPlane;
			if (soupOccluder.planeList == null) {	// lazy instantiate 3 planes for triangle soup testing
				soupOccluder.planeList = p = CullingPlane.create();
				p = p.next = CullingPlane.create();
				p = p.next = CullingPlane.create();
			}
			
			soupOccluder.faceList = null;
			
			var mask:int;
			var areaSubtracted:Number = 0;
			
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
			for (i = 0; i < len; i += 3) {
				mask = 0;
				var ai:int = indices[i] * 3;
				var bi:int = indices[i+1] * 3;
				var ci:int = indices[i+2] * 3;
				
				ax = vertices[ai];
				ay = vertices[ai+1];
				az = vertices[ai+2];
				
				var bx:Number = vertices[bi];
				var by:Number = vertices[bi+1];
				var bz:Number = vertices[bi + 2];
				
				var cx:Number = vertices[ci];
				var cy:Number = vertices[ci+1];
				var cz:Number = vertices[ci + 2];
				
				
				// Not sure why broadphase didn't detect this case, force-doing this for narrow phase
				/*
				if ( billboardFarClip.x * ax + billboardFarClip.y * ay + billboardFarClip.z * az < billboardFarClip.offset || billboardFarClip.x * bx + billboardFarClip.y * by + billboardFarClip.z * bz < billboardFarClip.offset || billboardFarClip.x * cx + billboardFarClip.y * cy + billboardFarClip.z * cz < billboardFarClip.offset ) {
					//Log.trace("Exit");
					continue;
				}
				*/
				
				var abx:Number;
				var aby:Number;
				var abz:Number;
				
				var acx:Number;
				var acy:Number;
				var acz:Number;
				
				
				p = soupOccluder.planeList;
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
				
				//if (mask != 0) Log.trace("MASK:"+mask);
				//soupOccluder.clipMask = mask;
			
				var retAreaSubtracted:Number = soupOccluder.clip(soupOccluder._disposableFaceCache);
				if (retAreaSubtracted > 0) {
					areaSubtracted += retAreaSubtracted;
					soupOccluder._negativeFaceCache.next = soupOccluder.faceList;
					soupOccluder.faceList = soupOccluder._negativeFaceCache;
				}
				
				
			}
				

			if (soupOccluder.faceList != null) {
				if (soupOccluder.faceList.next == null) {	// early out
					soupOccluder.faceList.collect();
					soupOccluder.faceList = null;
					return areaSubtracted;
				}
				else {
					//Log.trace("Got multiple polies");
					soupOccluder.calculateFaceCoordinates(soupOccluder.faceList,  soupOccluder._disposableFaceCache);
					var reduc:Number = soupOccluder.disposeTotalAreaIntersections(soupOccluder.faceList);
					soupOccluder.faceList = null;
					if (reduc > 0) Log.trace(int(reduc / soupOccluder._disposableFaceCache.getArea() * 100)+" percent reduction overlap");
					areaSubtracted -= reduc;
					
					if (areaSubtracted < -1e-6) Log.trace("Area substracted should not exceed total:" + areaSubtracted);
					return areaSubtracted;
				}
			}
			
			return areaSubtracted;
			
		}
		
		
		
		private function extractUnsignedVector(vec:Vector.<uint>, sliceAmt:int):Vector.<uint> {
			var vect:Vector.<uint> = new Vector.<uint>(sliceAmt, true);
			for (var i:int = 0; i < sliceAmt; i++) {
				vect[i] = vec[i];
			}
			return vect;
		}
		
		public function createWireframeCollisionPreview(pos:Vector3D=null):WireFrame {
			var wireframe:WireFrame;
			var dummyMesh:Mesh = new Mesh();
			if (pos == null) pos = new Vector3D();
			
			if (testWireframe!=null) {
				testWireframe.parent.removeChild(testWireframe);
				testWireframe.geometry.dispose();
			}
			
			dummyMesh.geometry = new alternativa.engine3d.resources.Geometry(testVertices.length/3);
			dummyMesh.geometry.addVertexStream( [VertexAttributes.POSITION, VertexAttributes.POSITION, VertexAttributes.POSITION]);
			//throw new Error(testChunkEllipsoid.numFaces + ", " + (testChunkEllipsoid.indices.length/3));
//throw new Error( ( testChunkEllipsoid.vertices.length / 3 ) + ", "+ testChunkEllipsoid.vertices.length + ", "+(3*dummyMesh.geometry.numVertices) );
			dummyMesh.geometry.setAttributeValues(VertexAttributes.POSITION, testVertices);
			
			
			dummyMesh.geometry.indices = testIndices;// extractUnsignedVector(testIndices,  testVertices.length / 3);
			//dummyMesh.geometry.indices = extractSteepPolygons(0.57357643635104609610803191282616);

			//dummyMesh = new Box(300, 300, 300);
		
			
			wireframe =  WireFrame.createEdges(dummyMesh, 0xFFFFFF, 1, 1);
			testWireframe = wireframe;
			//wireframe = WireFrame.createLinesList(extractSteepEdges(0.57357643635104609610803191282616), 0xFFFFFF, 1, 2);
				
			
			
			
			var mat:Matrix3D = terrainLOD.matrix;// mat.invert();
			wireframe.matrix = mat;
			
			
			// wireframe.geometry.upload( _view.stage3D.context3D);
			SpawnerBundle.uploadResourcesOf(wireframe);
			terrainLOD.parent.addChild(wireframe);
		
			SpawnerBundle.uploadResourcesOf(coneWireframe);
			terrainLOD.addChild(coneWireframe);
			
			coneWireframe.boundBox = null;
			wireframe.boundBox = null;
			return wireframe;	
		}
		
		public  function createFrustumFromPoints(pts:Vector.<Vector3D>, targPos:Vector3D):CullingPlane {
			var cullingPlane:CullingPlane = new CullingPlane();
			var c:CullingPlane = cullingPlane;
			var v:Vector3D;
			
			if (coneWireframe != null) {
				coneWireframe.parent.removeChild(coneWireframe);
				coneWireframe.geometry.dispose();
			}
			
			var mesh:Mesh = new Mesh();
			
			var lineList:Vector.<Vector3D> = new Vector.<Vector3D>();
			

			v = pts[2].subtract(pts[0]).crossProduct(pts[1].subtract(pts[0]));
			//v.normalize();
			c.x = v.x;
			c.y = v.y;
			c.z = v.z;
			c.offset = v.dotProduct(pts[0]);
			lineList.push(pts[0], pts[2], pts[0], pts[1], pts[1], pts[2]);
		
			
			///*
			c = c.next = new CullingPlane();
			v = pts[3].subtract(pts[0]).crossProduct(pts[2].subtract(pts[0]));
			//v.normalize();
			c.x = v.x;
			c.y = v.y;
			c.z = v.z;
			c.offset = v.dotProduct(pts[0]);
			lineList.push(pts[0], pts[3], pts[2], pts[0], pts[2], pts[3]);
				
			
			c = c.next = new CullingPlane();
			v = pts[4].subtract(pts[0]).crossProduct(pts[3].subtract(pts[0]));
			//v.normalize();
			c.x = v.x;
			c.y = v.y;
			c.z = v.z;
			c.offset = v.dotProduct(pts[0]);
			lineList.push(pts[0], pts[4], pts[0], pts[3], pts[3], pts[4]);
			
			
			c = c.next = new CullingPlane();
			v = pts[1].subtract(pts[0]).crossProduct(pts[4].subtract(pts[0]));
			//v.normalize();
			c.x = v.x;
			c.y = v.y;
			c.z = v.z;
			c.offset = v.dotProduct(pts[0]);
			lineList.push(pts[0], pts[1], pts[4], pts[0], pts[4], pts[1]);
			
			//*/
			///*
			
			c = c.next = new CullingPlane();
			v = targPos.subtract(pts[0]);
			//v.normalize();
			c.x = v.x;
			c.y = v.y;
			c.z = v.z;
			c.offset = v.dotProduct(pts[0]);
		
			///*
			c = c.next = new CullingPlane();
			v = pts[0].subtract(targPos);
			//v.normalize();
			c.x = v.x;
			c.y = v.y;
			c.z = v.z;
			c.offset = v.dotProduct(targPos);
			billboardFarClip = c;
			//*/
			
			//*/
			
			v = targPos.subtract(pts[0]);
			v.normalize();
			v.scaleBy( targPos.subtract(pts[0]).length*.5 );
			var testPt:Vector3D = pts[0].add(v);
			for (c = cullingPlane; c != null; c = c.next) {
				var dp:Number = testPt.x * c.x + testPt.y * c.y + testPt.z * c.z;
				if (dp < c.offset) {
					throw new Error( "Invalid frustum, not enclosed!" + Math.abs(c.offset - dp) );
				}
			}
			
			coneWireframe =  WireFrame.createLinesList(lineList, 0x0000FF, 1, 2);
			
			return cullingPlane;
		}
		
		private var testGeometry:Geometry;
		private var testIndices:Vector.<uint> = new Vector.<uint>();
		private var testVertices:Vector.<Number> = new Vector.<Number>();
		private var testFrustum:CullingPlane;
		private var testWireframe:WireFrame;
		private var coneWireframe:WireFrame;
		private var testFrustumPoints:Vector.<Vector3D> = new Vector.<Vector3D>(5, true);
		
		private var dummyVec:Vec3 = new Vec3();
		private var dummyObj:Object3D = new Object3D();
		public var keyPoll:KeyPoll;
		public var terrainLOD:TerrainLOD;
		private var objectTransform:Vector.<Vector3D>;
		private var billboardFarClip:CullingPlane;
		
	}

}
import ash.ClassMap;
import ash.core.Node;
import components.Ellipsoid;
import components.Pos;

class TargetBoardNode extends Node {
	public var pos:Pos;
	public var size:Ellipsoid;
	
	public function TargetBoardNode() {
		
	}
	
	private static var _components:ClassMap;
	
	public static function _getComponents():ClassMap {
		if(_components == null) {
				_components = new ClassMap();
				_components.set(Pos, "pos");
				_components.set(Ellipsoid, "size");
			
		}
			return _components;
	}
}
