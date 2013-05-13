package util.geom;

/**
 * Generic frustum  data structure/utility
 * @author Glenn Ko
 */

class Frustum 
{
	public var planes:Array<XYZ>;


	public function new() 
	{
		planes = new Array<XYZ>();
	}
	
	public function toString():String {
		return "[[Frustum]" + planes + "]]";
	}
	
	public function fillNewPlanes():Void {
		var len = planes.length;
		for (i in 0...len) {
			planes[i] = new XYZ(0,0,0,0);
		}
	}
	
	public static function create6():Frustum {
		var me:Frustum = new Frustum();
		var planes:Array<XYZ> = me.planes;
		planes[0] = new XYZ(0, 0, 0, 0);
		planes[1] = new XYZ(0, 0, 0, 0);
		planes[2] = new XYZ(0, 0, 0, 0);
		planes[3] = new XYZ(0, 0, 0, 0);
		planes[4] = new XYZ(0, 0, 0, 0);
		planes[5] = new XYZ(0,0,0,0);
		return me;
	}
	
	public static inline function create4():Frustum {
		var me:Frustum = new Frustum();
		var planes:Array<XYZ> = me.planes;
		planes[0] = new XYZ(0, 0, 0, 0);
		planes[1] = new XYZ(0, 0, 0, 0);
		planes[2] = new XYZ(0, 0, 0, 0);
		planes[3] = new XYZ(0, 0, 0, 0);
		return me;
	}
	
	
	public var debugPts:Array<XYZ>;

	/**
	 * Sets up 4 planes based on portal.
	 * @param	camX
	 * @param	camY
	 * @param	camZ
	 * @param	pts
	 * @param	o	Offset plane index to start assignign values from. Defaulted to 0.
	 */
	public inline function setup4FromPortal(camX:Float, camY:Float, camZ:Float, pts:Array<XYZ>, o:Int=0):Frustum {
		var a:XYZ;
		var b:XYZ;
		
		debugPts = pts;
		
		var ax:Float, ay:Float, az:Float;
		var bx:Float, by:Float, bz:Float;
		var vx:Float, vy:Float, vz:Float;
		var p:XYZ;
		
		var planes:Array<XYZ> = this.planes;
		
		//camX = 999999999;
		//camY = -999999999;
		//camZ = 999999999;
		//pts =[new XYZ(99999999999,99999999999,99999999999), new XYZ(99999999999,99999999999,99999999999), new XYZ(99999999999,99999999999,99999999999), new XYZ(99999999999,99999999999,99999999999)];
		
		p = planes[o];
		a = pts[0];
		b = pts[1];
		ax =a.x - camX;
		ay = a.y - camY;
		az = a.z - camZ;
		bx=b.x - camX;
		by=b.y - camY;
		bz = b.z - camZ;
		vx = ay * bz - az* by;
		vy = az * bx - ax * bz;
		vz = ax * by - ay * bx;
		p.x = vx;
		p.y = vy;
		p.z = vz;
		p.w = vx * camX + vy * camY + vz * camZ;
		p.flip();	 // BUG: need to flip  plane for CSS 
		o++;
		
		p = planes[o];
		a = pts[1];
		b = pts[2];
		ax =a.x - camX;
		ay = a.y - camY;
		az = a.z - camZ;
		bx=b.x - camX;
		by=b.y - camY;
		bz = b.z - camZ;
		vx = ay * bz - az* by;
		vy = az * bx - ax * bz;
		vz = ax * by - ay * bx;
		p.x = vx;
		p.y = vy;
		p.z = vz;
		p.w = vx * camX + vy * camY + vz * camZ;
		p.flip();	 // BUG: need to flip  plane for CSS 
		o++;
		
		p = planes[o];
		a = pts[2];
		b = pts[3];
		ax =a.x - camX;
		ay = a.y - camY;
		az = a.z - camZ;
		bx=b.x - camX;
		by=b.y - camY;
		bz = b.z - camZ;
		vx = ay * bz - az* by;
		vy = az * bx - ax * bz;
		vz = ax * by - ay * bx;
		p.x = vx;
		p.y = vy;
		p.z = vz;
		p.w = vx * camX + vy * camY + vz * camZ;
		p.flip();	 // BUG: need to flip  plane for CSS 
		o++;
		
		p = planes[o];
		a = pts[3];
		b = pts[0];
		ax =a.x - camX;
		ay = a.y - camY;
		az = a.z - camZ;
		bx=b.x - camX;
		by=b.y - camY;
		bz = b.z - camZ;
		vx = ay * bz - az* by;
		vy = az * bx - ax * bz;
		vz = ax * by - ay * bx;
		p.x = vx;
		p.y = vy;
		p.z = vz;
		p.w = vx * camX + vy * camY + vz * camZ;
		p.flip();	 // BUG: need to flip  plane for CSS 
		
		return this;
		
	}
	
	public function checkVisibility(a:IAABB):Bool {
		var side:Int = 1;
		var planes = this.planes;
		var len = planes.length;
		var minX:Float = a.minX;
		var minY:Float = a.minY;
		var minZ:Float = a.minZ;
		var maxX:Float = a.maxX;
		var maxY:Float = a.maxY;
		var maxZ:Float = a.maxZ;

		
		for (i in 0...len) {
			var plane:XYZ = planes[i];
			
				if (plane.x >= 0)   
				if (plane.y >= 0)
				if (plane.z >= 0) {
				if (maxX*plane.x + maxY*plane.y + maxZ*plane.z <= plane.w) return false;
				//if (minX*plane.x + minY*plane.y + minZ*plane.z > plane.w) return true;
				} else {
				if (maxX*plane.x + maxY*plane.y + minZ*plane.z <= plane.w) return false;
				//if (minX*plane.x + minY*plane.y + maxZ*plane.z > plane.w) return true;
				}
				else
				if (plane.z >= 0) {
				if (maxX*plane.x + minY*plane.y + maxZ*plane.z <= plane.w) return false;
				//if (minX*plane.x + maxY*plane.y + minZ*plane.z > plane.w) return true;
				} else {
				if (maxX*plane.x + minY*plane.y + minZ*plane.z <= plane.w) return false;
				//if (minX*plane.x + maxY*plane.y + maxZ*plane.z > plane.w) return true;
				}
				else if (plane.y >= 0)
				if (plane.z >= 0) {
				if (minX*plane.x + maxY*plane.y + maxZ*plane.z <= plane.w) return false;
				//if (maxX*plane.x + minY*plane.y + minZ*plane.z > plane.w) return true;
				} else {
				if (minX*plane.x + maxY*plane.y + minZ*plane.z <= plane.w) return false;
				//if (maxX*plane.x + minY*plane.y + maxZ*plane.z > plane.w) return true;
				}
				else if (plane.z >= 0) {
				if (minX*plane.x + minY*plane.y + maxZ*plane.z <= plane.w) return false;
				//if (maxX*plane.x + maxY*plane.y + minZ*plane.z > plane.w) return true;
				} else {
				if (minX*plane.x + minY*plane.y + minZ*plane.z <= plane.w) return false;
				//if (maxX*plane.x + maxY*plane.y + maxZ*plane.z > plane.w) return true;
				}
				
			
			side <<= 1;
		}
		return true;
	}
	
	/**
	 * Ported from Alternativa3D 8.
	 * @param   a	An axis-aligned bounding box
	 * @param	culling	A culling bitmask for which planes to necessarily check.
	 * @return	The culling bitmask
	 */
	public  function checkFrustumCulling(a:IAABB, culling:Int):Int {
		
	//	if (planes.length == 4) return -1;
		
		var side:Int = 1;
		var planes = this.planes;
		var len = planes.length;
		var minX:Float = a.minX;
		var minY:Float = a.minY;
		var minZ:Float = a.minZ;
		var maxX:Float = a.maxX;
		var maxY:Float = a.maxY;
		var maxZ:Float = a.maxZ;
		var rootCull = culling;
		
		for (i in 0...len) {
			var plane:XYZ = planes[i];
			if ((culling & side) != 0) {     // GASP!! Arrow anti-pattern! Anyway, determine nearest determinatate corner to compare against plane.

				if (plane.x >= 0)   
				if (plane.y >= 0)
				if (plane.z >= 0) {
				if (maxX*plane.x + maxY*plane.y + maxZ*plane.z <= plane.w) return -1;
				if (minX*plane.x + minY*plane.y + minZ*plane.z > plane.w) culling &= (rootCull & ~side);
				} else {
				if (maxX*plane.x + maxY*plane.y + minZ*plane.z <= plane.w) return -1;
				if (minX*plane.x + minY*plane.y + maxZ*plane.z > plane.w) culling &= (rootCull & ~side);
				}
				else
				if (plane.z >= 0) {
				if (maxX*plane.x + minY*plane.y + maxZ*plane.z <= plane.w) return -1;
				if (minX*plane.x + maxY*plane.y + minZ*plane.z > plane.w) culling &= (rootCull & ~side);
				} else {
				if (maxX*plane.x + minY*plane.y + minZ*plane.z <= plane.w) return -1;
				if (minX*plane.x + maxY*plane.y + maxZ*plane.z > plane.w) culling &= (rootCull & ~side);
				}
				else if (plane.y >= 0)
				if (plane.z >= 0) {
				if (minX*plane.x + maxY*plane.y + maxZ*plane.z <= plane.w) return -1;
				if (maxX*plane.x + minY*plane.y + minZ*plane.z > plane.w) culling &= (rootCull & ~side);
				} else {
				if (minX*plane.x + maxY*plane.y + minZ*plane.z <= plane.w) return -1;
				if (maxX*plane.x + minY*plane.y + maxZ*plane.z > plane.w) culling &= (rootCull & ~side);
				}
				else if (plane.z >= 0) {
				if (minX*plane.x + minY*plane.y + maxZ*plane.z <= plane.w) return -1;
				if (maxX*plane.x + maxY*plane.y + minZ*plane.z > plane.w) culling &= (rootCull & ~side);
				} else {
				if (minX*plane.x + minY*plane.y + minZ*plane.z <= plane.w) return -1;
				if (maxX*plane.x + maxY*plane.y + maxZ*plane.z > plane.w) culling &= (rootCull & ~side);
				}
				
			}
			side <<= 1;
		}
		return culling;
	}
	
	/**
	 * Calculate frustum from world matrix position geometrically, given screen parameters. 
	 * Identity screen parameters is: -z for away from screen,  +x for eastwards from screen, +y for southwards from screen.
	 * @param	te
	 * @param	screenWhalf
	 * @param	screenHhalf
	 * @param	near
	 * @param	far
	 */
	public inline function setup6FromWorldMatrix(te:Array<Float>, screenWhalf:Float, screenHhalf:Float, focalLength:Float, near:Float=0, far:Float=9999999999):Void {
		var planes:Array<XYZ> = this.planes;
		var p:XYZ;
		
		
	
		var vx:Float;
		var vy:Float;
		var vz:Float;
		
		var ax:Float;
		var ay:Float;
		var az:Float;
		var bx:Float;
		var by:Float;
		var bz:Float;
		
		var cx:Float = te[12];
		var cy:Float = te[13];
		var cz:Float = te[14];
		
		

		
		// fan out clockwise 
		
		// top
		p = planes[0];
		vz = -focalLength;
		vx = -screenWhalf;
		vy = -screenHhalf;
		ax = ( te[0] * vx + te[4] * vy + te[8] * vz  );
		ay = ( te[1] * vx + te[5] * vy + te[9] * vz  );
		az = ( te[2] * vx + te[6] * vy + te[10] * vz  );
		var tx:Float = ax;
		var ty:Float = ay;
		var tz:Float = az;

		
		vz = -focalLength;
		vx = screenWhalf;
		vy = -screenHhalf;
		bx = ( te[0] * vx + te[4] * vy + te[8] * vz  );
		by = ( te[1] * vx + te[5] * vy + te[9] * vz  );
		bz = ( te[2] * vx + te[6] * vy + te[10] * vz  );
		
		 vx = ay * bz - az* by;
		 vy = az * bx - ax * bz;
		 vz = ax * by - ay * bx;
		
		 p.x = vx;
		 p.y = vy;
		 p.z = vz;
		 p.w = vx * cx + vy * cy + vz * cz;
		// p.normalizeAndCalcOffset(cx,cy,cz);
		p.flip();	 // BUG: need to flip vertical plane for CSS 
		
		ax = bx;
		ay = by;
		az = bz;
		
		// right
		p = planes[1];
		vz = -focalLength;
		vx = screenWhalf;
		vy = screenHhalf;
		bx = ( te[0] * vx + te[4] * vy + te[8] * vz  );
		by = ( te[1] * vx + te[5] * vy + te[9] * vz  );
		bz = ( te[2] * vx + te[6] * vy + te[10] * vz  );
		

		 vx = ay * bz - az* by;
		 vy = az * bx - ax * bz;
		 vz = ax * by - ay * bx;
		
		 p.x = vx;
		 p.y = vy;
		 p.z = vz;
		 p.w = vx * cx + vy * cy + vz * cz;
		 // p.normalizeAndCalcOffset(cx,cy,cz);
		 p.flip();	
		 
		
		ax = bx;
		ay = by;
		az = bz;
		
		// bottom
		p = planes[2];
		vz = -focalLength;
		vx = -screenWhalf;
		vy = screenHhalf;
		bx = ( te[0] * vx + te[4] * vy + te[8] * vz  );
		by = ( te[1] * vx + te[5] * vy + te[9] * vz  );
		bz = ( te[2] * vx + te[6] * vy + te[10] * vz  );

		 vx = ay * bz - az* by;
		 vy = az * bx - ax * bz;
		 vz = ax * by - ay * bx;
		
		 p.x = vx;
		 p.y = vy;
		 p.z = vz;
		 p.w = vx * cx + vy * cy + vz * cz;
		//  p.normalizeAndCalcOffset(cx,cy,cz);
		p.flip();  // BUG: need to flip vertical plane for CSS 
		
		ax = bx;
		ay = by;
		az = bz;
		
		// left
		p = planes[3];
		bx = tx;
		by = ty;
		bz = tz;
		 vx = ay * bz - az* by;
		 vy = az * bx - ax * bz;
		 vz = ax * by - ay * bx;
		
		 p.x = vx;
		 p.y = vy;
		 p.z = vz;
		 p.w = vx * cx + vy * cy + vz * cz;
	//	  p.normalizeAndCalcOffset(cx,cy,cz);
		 p.flip(); // BUG: need to flip for left plane!!
		
		
		// transform forward vector
		vx = 0;
		vy = 0;
		vz = -1;
		tx = ( te[0] * vx + te[4] * vy + te[8] * vz  );
		ty = ( te[1] * vx + te[5] * vy + te[9] * vz  );
		tz = ( te[2] * vx + te[6] * vy + te[10] * vz  );
		
		// near
		p = planes[4];
		p.x = tx;
		p.y = ty;
		p.z = tz;
		p.w = tx * cx + ty * cy + tz * cz;
		
		// far
		p = planes[5];
		p.x = tx;
		p.y = ty;
		p.z = tz;
		p.w =  tx * cx + ty * cy + tz * cz;

	}
	
	

	/**
	 * Ported from THREE.JS.  Doesn't seem to work though..Hmm...
	 * @param	me
	 */
	/*
	public inline function setup6FromProjMatrix(me:Array<Float>):Void {
		var plane:XYZ; 
		var planes:Array<XYZ> = this.planes;
		
		var me0 = me[0], me1 = me[1], me2 = me[2], me3 = me[3];
		var me4 = me[4], me5 = me[5], me6 = me[6], me7 = me[7];
		var me8 = me[8], me9 = me[9], me10 = me[10], me11 = me[11];
		var me12 = me[12], me13 = me[13], me14 = me[14], me15 = me[15];

		planes[ 0 ].set( me3 - me0, me7 - me4, me11 - me8, me15 - me12 ); 
		planes[ 1 ].set( me3 + me0, me7 + me4, me11 + me8, me15 + me12 );
		planes[ 2 ].set( me3 + me1, me7 + me5, me11 + me9, me15 + me13 );
		planes[ 3 ].set( me3 - me1, me7 - me5, me11 - me9, me15 - me13 );
		planes[ 4 ].set( me3 - me2, me7 - me6, me11 - me10, me15 - me14 );
		planes[ 5 ].set( me3 + me2, me7 + me6, me11 + me10, me15 + me14 );

		plane = planes[ 0 ];
		plane.divideScalar( Math.sqrt( plane.x * plane.x + plane.y * plane.y + plane.z * plane.z ) );
		
		plane = planes[ 1 ];
		plane.divideScalar( Math.sqrt( plane.x * plane.x + plane.y * plane.y + plane.z * plane.z ) );
		
		plane = planes[ 2 ];
		plane.divideScalar( Math.sqrt( plane.x * plane.x + plane.y * plane.y + plane.z * plane.z ) );
		
		plane = planes[ 3 ];
		plane.divideScalar( Math.sqrt( plane.x * plane.x + plane.y * plane.y + plane.z * plane.z ) );
		
		plane = planes[ 4 ];
		plane.divideScalar( Math.sqrt( plane.x * plane.x + plane.y * plane.y + plane.z * plane.z ) );
		
		plane = planes[ 5 ];
		plane.divideScalar( Math.sqrt( plane.x * plane.x + plane.y * plane.y + plane.z * plane.z ) );
	}
	*/
	
	
	/**  
	 * Ported from Alternativa3D 8. Create standard 6 planes for frustum perspective camera using world transform and cross-products.
	 * @param   me	Matrix array of floats for world transform
	 * @param 	correctionX = viewSizeX / focalLength;   // viewSizeX half width of 
		@param 	correctionY = viewSizeY / focalLength;	// viewSizeY
	 * @return
	 */
		/*
		public function calculateFrustum6(me:Array<Float>, screenWhalf:Float, screenHhalf:Float, focalLength:Float, near:Float=1, far:Float=9999999999 ):Void {
		

			var  correctionX:Float = screenWhalf / focalLength;
			var  correctionY:Float = screenHhalf / focalLength;
			
			
			var planes:Array<XYZ> = this.planes;
			var nearPlane:XYZ = planes[4];
			var farPlane:XYZ = planes[5];
			var leftPlane:XYZ = planes[3];
			var rightPlane:XYZ = planes[1];
			var topPlane:XYZ = planes[0];
			var bottomPlane:XYZ = planes[2];
			
			var a:Float = me[0]; var b:Float = me[1]; var c:Float = me[2]; var d:Float = me[3];
			var e:Float = me[4]; var f:Float = me[5]; var g:Float = me[6]; var h:Float = me[7];
			var i:Float = me[8]; var j:Float = me[9]; var k:Float = me[10]; var l:Float = me[11];
			
			
			var fa:Float = a * correctionX;
			var fe:Float = e * correctionX;
			var fi:Float = i * correctionX;
			var fb:Float = b * correctionY;
			var ff:Float = f * correctionY;
			var fj:Float = j * correctionY;
			nearPlane.x = fj * fe - ff * fi;
			nearPlane.y = fb * fi - fj * fa;
			nearPlane.z = ff * fa - fb * fe;
			nearPlane.w = (d + c * near) * nearPlane.x + (h + g * near) * nearPlane.y + (l + k * near) * nearPlane.z;

			farPlane.x = -nearPlane.x;
			farPlane.y = -nearPlane.y;
			farPlane.z = -nearPlane.z;
			farPlane.w = (d + c * far) * farPlane.x + (h + g * far) * farPlane.y + (l + k * far) * farPlane.z;

			var ax:Float = -fa - fb + c;
			var ay:Float = -fe - ff + g;
			var az:Float = -fi - fj + k;
			var bx:Float = fa - fb + c;
			var by:Float = fe - ff + g;
			var bz:Float = fi - fj + k;
			topPlane.x = bz * ay - by * az;
			topPlane.y = bx * az - bz * ax;
			topPlane.z = by * ax - bx * ay;
			topPlane.w = d * topPlane.x + h * topPlane.y + l * topPlane.z;
			// Right plane.
			ax = bx;
			ay = by;
			az = bz;
			bx = fa + fb + c;
			by = fe + ff + g;
			bz = fi + fj + k;
			rightPlane.x = bz * ay - by * az;
			rightPlane.y = bx * az - bz * ax;
			rightPlane.z = by * ax - bx * ay;
			rightPlane.w = d * rightPlane.x + h * rightPlane.y + l * rightPlane.z;
			// Bottom plane.
			ax = bx;
			ay = by;
			az = bz;
			bx = -fa + fb + c;
			by = -fe + ff + g;
			bz = -fi + fj + k;
			bottomPlane.x = bz*ay - by*az;
			bottomPlane.y = bx*az - bz*ax;
			bottomPlane.z = by*ax - bx*ay;
			bottomPlane.w = d*bottomPlane.x + h*bottomPlane.y + l*bottomPlane.z;
			// Left plane.
			ax = bx;
			ay = by;
			az = bz;
			bx = -fa - fb + c;
			by = -fe - ff + g;
			bz = -fi - fj + k;
			leftPlane.x = bz*ay - by*az;
			leftPlane.y = bx*az - bz*ax;
			leftPlane.z = by*ax - bx*ay;
			leftPlane.w = d*leftPlane.x + h*leftPlane.y + l*leftPlane.z;
			
		}
		*/
	
	
	
	
}