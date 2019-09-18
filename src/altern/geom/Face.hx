package altern.geom;
import components.Transform3D;
import util.geom.Vec3;

/**
 * This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
 * If it is not possible or desirable to put the notice in a particular file, then You may include the notice in a location (such as a LICENSE file in a relevant directory) where a recipient would be likely to look for such a notice.
 * You may add additional accurate notices of copyright ownership.
 *
 * It is desirable to notify that Covered Software was "Powered by AlternativaPlatform" with link to http://www.alternativaplatform.com/ 
 * */
/**
 * Port over to Haxe with some additional utility methods of my own
 * @author Glidias
 */
class Face
{

	public var next:Face;
	public var processNext:Face;
	
	public var normalX:Float;
	public var normalY:Float;
	public var normalZ:Float;
	public var offset:Float;
	
	public var wrapper:Wrapper;
	
	public var visible:Bool;

	public static var collector:Face;
	
	public inline function collect():Void {
		next = collector;
		collector = this;
	}
	
	public function destroy():Void {
		var w:Wrapper = wrapper;
		while ( w != null) {
			var nextW:Wrapper = w.next;
			w.next = Wrapper.collector;
			Wrapper.collector = w;
			if (w.vertex.temp) {
				w.vertex.temp = false;
				w.vertex.next = Vertex.collector;
				Vertex.collector = w.vertex;
			}
			w.vertex = null;
			w = nextW;
		}
		wrapper = null;
		processNext = null;
		visible = false;
	}
	

	static public function create():Face {
		if (collector != null) {
			var res:Face = collector;
			collector = res.next;
			res.next = null;
			/*if (res.processNext != null) trace("!!!processNext!!!");
			if (res.geometry != null) trace("!!!geometry!!!");
			if (res.negative != null) trace("!!!negative!!!");
			if (res.positive != null) trace("!!!positive!!!");*/
			return res;
		} else {
			//trace("new Face");
			return new Face();
		}
	}
	
	
	public function new() 
	{
		
	}
	
	public function calculateNormal():Void {
		var offset:Float;
		var nz:Float;
		var ny:Float;
		var nx:Float;
		var w:Wrapper;
		var acz:Float;
		var acy:Float;
		var acx:Float;
		var abz:Float;
		var aby:Float;
		var abx:Float;
		var nl:Float;
		var c:Vertex;
		var b:Vertex;
		var a:Vertex;
		
		w = wrapper;
		a = w.vertex;
		w = w.next;
		b = w.vertex;
		w = w.next;
		c = w.vertex;
		abx = b.x - a.x;
		aby = b.y - a.y;
		abz = b.z - a.z;
		acx = c.x - a.x;
		acy = c.y - a.y;
		acz = c.z - a.z;
		nx = acz*aby - acy*abz;
		ny = acx*abz - acz*abx;
		nz = acy*abx - acx*aby;
		nl = nx*nx + ny*ny + nz*nz;
		if (nl > 0) {
			nl = 1/Math.sqrt(nl);
			nx *= nl;
			ny *= nl;
			nz *= nl;
			normalX = nx;
			normalY = ny;
			normalZ = nz;
		}
		offset = a.x*nx + a.y*ny + a.z*nz;
	
	}
	
	public function calculateBestSequenceAndNormal():Void {
		var nl:Float;
		var nz:Float;
		var ny:Float;
		var nx:Float;
		var w:Wrapper;
		var acz:Float;
		var acy:Float;
		var acx:Float;
		var abz:Float;
		var aby:Float;
		var abx:Float;
		var c:Vertex;
		var b:Vertex;
		var a:Vertex;
		if (wrapper.next.next.next != null) {
			var max:Float = -1e+22;
			var s:Wrapper = null;
			var sm:Wrapper;
			var sp:Wrapper;
			w = wrapper;
			while (w != null) {
				var wn:Wrapper = (w.next != null) ? w.next : wrapper;
				var wm:Wrapper = (wn.next != null) ? wn.next : wrapper;
				a = w.vertex;
				b = wn.vertex;
				c = wm.vertex;
				abx = b.x - a.x;
				aby = b.y - a.y;
				abz = b.z - a.z;
				acx = c.x - a.x;
				acy = c.y - a.y;
				acz = c.z - a.z;
				nx = acz*aby - acy*abz;
				ny = acx*abz - acz*abx;
				nz = acy*abx - acx*aby;
				nl = nx*nx + ny*ny + nz*nz;
				if (nl > max) {
					max = nl;
					s = w;
				}
			}
			if (s != wrapper) {
				//for (sm = wrapper.next.next.next; sm.next != null; sm = sm.next);
				sm = wrapper.next.next.next;
				while (sm.next != null) sm = sm.next;
				//for (sp = wrapper; sp.next != s && sp.next != null; sp = sp.next);
				sp = wrapper;
				while (sp.next != s && sp.next != null) sp = sp.next;
				sm.next = wrapper;
				sp.next = null;
				wrapper = s;
			}
		}
		w = wrapper;
		a = w.vertex;
		w = w.next;
		b = w.vertex;
		w = w.next;
		c = w.vertex;
		abx = b.x - a.x;
		aby = b.y - a.y;
		abz = b.z - a.z;
		acx = c.x - a.x;
		acy = c.y - a.y;
		acz = c.z - a.z;
		nx = acz*aby - acy*abz;
		ny = acx*abz - acz*abx;
		nz = acy*abx - acx*aby;
		nl = nx*nx + ny*ny + nz*nz;
		if (nl > 0) {
			nl = 1/Math.sqrt(nl);
			nx *= nl;
			ny *= nl;
			nz *= nl;
			normalX = nx;
			normalY = ny;
			normalZ = nz;
		}
		offset = a.x*nx + a.y*ny + a.z*nz;
	}
	
	public function getArea():Float {
		var w:Wrapper;
		var a:Vertex = wrapper.vertex;
		
		var areaAccum:Float = 0;
		w = wrapper.next;
		var wn:Wrapper = w.next;
		while (wn != null) {
			var b:Vertex = w.vertex;
			var c:Vertex = wn.vertex;
			var xAB:Float = b.x - a.x;
			var yAB:Float = b.y - a.y;
			var zAB:Float = b.z - a.z;
			
			var xAC:Float = c.x - a.x;
			var yAC:Float = c.y - a.y;
			var zAC:Float = c.z - a.z;
			
			var cx:Float = yAB*zAC - zAB*yAC;
			var cy:Float = zAB*xAC - xAB*zAC;
			var cz:Float = xAB*yAC - yAB*xAC;
			areaAccum += Math.sqrt( cx * cx + cy * cy + cz * cz) * 0.5;
			
			w = w.next;
			wn = wn.next;
		}
		
		return areaAccum;
	}
	
	public function overlapsOther2D(face:Face):Bool {
		// http://0x80.pl/articles/convex-polygon-intersection/demo/
		// naive
		
		var v2:Vertex = null;
		var w2:Wrapper;
		var v:Vertex = null;
		var w:Wrapper;
		// naive algorithm
		var a:Float;
		var b:Float;
		var c:Float;
	
		var lastVertex:Vertex;
		var lastVertex2:Vertex;
		
		w = wrapper;
		while (w != null) {
			v = w.vertex;
			
			w = w.next;
		}
		lastVertex = v;
		
		w = face.wrapper;
		while (w != null) {
			v = w.vertex;
			
			w = w.next;
		}
		lastVertex2 = v;
		
		v = lastVertex;
		w = wrapper;
		while (w != null) {
			var v0:Vertex = v;
			v = w.vertex;
			var v1:Vertex = w.next != null ? w.next.vertex : wrapper.vertex;
			
			v2 = lastVertex2;
			w2 = face.wrapper;
			while (w2 != null) {
				var v2_0:Vertex = v2;
				v2 = w2.vertex;
				var v2_1:Vertex =  w2.next != null ? w2.next.vertex : face.wrapper.vertex;
				
				a = -(v2.cameraY - v.cameraY);
				b = (v2.cameraX - v.cameraX);	// the other guy's one have this as negative
				c = a * v.cameraX + b * v.cameraY;	
				var sideA:Int = get_side(a, b, c, v0, v1);
				if (sideA < -1) {
					
					w2 = w2.next;
					continue;
				}
				var sideB:Int = get_side(a, b, c, v2_0, v2_1);
				if (sideB < -1) {
					
					w2 = w2.next;
					continue;
				}				
				if (sideA * sideB < 0) {
					return false;
				}
				
				w2 = w2.next;
			}
			
			w = w.next;
		}
	
		return true;
	}
	
	public function isPointInside2D(centerX:Float, centerY:Float):Bool {
		var w:Wrapper  = wrapper;
		var v:Vertex;
		var nx:Float;
		var ny:Float;
		var offset:Float;
		while (w != null) {
			v = w.vertex;
			var v2:Vertex = w.next != null ? w.next.vertex : wrapper.vertex;
			nx = -(v2.cameraY - v.cameraY);
			ny = (v2.cameraX - v.cameraX);	
			offset = nx * v.cameraX + ny * v.cameraY;
			if (nx * centerX + ny * centerY < offset) {
				return false;
			}
			w = w.next;
		}
		return true;
	}
	
	
	
	
	/**
	 * 
	 * @param	pos Center position of quad
	 * @param	up	The normalised up vector
	 * @param	right	The normalised right vector
	 * @param	halfWidth	The (half-offset)width from center position
	 * @param	halfHeight	The (half-offset)height from center position
	 * @param	t	The transform to use
	 * @return	A single quad face
	 */
	public static function getQuad(pos:Vec3, up:Vec3, right:Vec3, halfWidth:Float, halfHeight:Float, t:Transform3D):Face {
		var f:Face = new Face();
	
		var v:Vertex;
		var vx:Float;
		var vy:Float;
		var vz:Float;
		var w:Wrapper;
	
		f.wrapper = w = new Wrapper();	// top left vertex
		w.vertex  = v =  new Vertex();
		vx = pos.x; vy = pos.y; vz = pos.z;
		vx += up.x*halfHeight;
		vy += up.y*halfHeight;
		vz += up.z*halfHeight;
		vx -= right.x*halfWidth;
		vy -= right.y*halfWidth;
		vz -= right.z * halfWidth;
		v.x = t.a*vx + t.b*vy + t.c*vz + t.d;
		v.y = t.e*vx + t.f*vy + t.g*vz + t.h;
		v.z = t.i * vx + t.j * vy + t.k * vz + t.l;
		
		w = w.next = new Wrapper();	 // bottom left
		w.vertex = v.next = v = new Vertex();
		vx = pos.x; vy = pos.y; vz = pos.z;
		vx -= up.x*halfHeight;
		vy -= up.y*halfHeight;
		vz -= up.z*halfHeight;
		vx -= right.x*halfWidth;
		vy -= right.y*halfWidth;
		vz -= right.z * halfWidth;
		v.x = t.a*vx + t.b*vy + t.c*vz + t.d;
		v.y = t.e*vx + t.f*vy + t.g*vz + t.h;
		v.z = t.i * vx + t.j * vy + t.k * vz + t.l;
		
		w = w.next = new Wrapper();	 // bottom right vertex
		w.vertex =  v.next = v = new Vertex();
		vx = pos.x; vy = pos.y; vz = pos.z;
		vx -= up.x*halfHeight;
		vy -= up.y*halfHeight;
		vz -= up.z*halfHeight;
		vx += right.x*halfWidth;
		vy += right.y*halfWidth;
		vz += right.z * halfWidth;
		v.x = t.a*vx + t.b*vy + t.c*vz + t.d;
		v.y = t.e*vx + t.f*vy + t.g*vz + t.h;
		v.z = t.i * vx + t.j * vy + t.k * vz + t.l;
		
		
		w = w.next = new Wrapper();		// top right
		w.vertex =  v.next = v = new Vertex();
		vx = pos.x; vy = pos.y; vz = pos.z;
		vx += up.x*halfHeight;
		vy += up.y*halfHeight;
		vz += up.z*halfHeight;
		vx += right.x*halfWidth;
		vy += right.y*halfWidth;
		vz += right.z*halfWidth;
		v.x = t.a*vx + t.b*vy + t.c*vz + t.d;
		v.y = t.e*vx + t.f*vy + t.g*vz + t.h;
		v.z = t.i * vx + t.j * vy + t.k * vz + t.l;
		
		f.calculateNormal();
	
		return f;
	}
	
	
	public static function setupQuad(f:Face, pos:Vec3, up:Vec3, right:Vec3, halfWidth:Float, halfHeight:Float, t:Transform3D):Face {
		var v:Vertex;
		var vx:Float;
		var vy:Float;
		var vz:Float;
		var w:Wrapper;
	
		w = f.wrapper;	// top left vertex
		v = w.vertex;
		vx = pos.x; vy = pos.y; vz = pos.z;
		vx += up.x*halfHeight;
		vy += up.y*halfHeight;
		vz += up.z*halfHeight;
		vx -= right.x*halfWidth;
		vy -= right.y*halfWidth;
		vz -= right.z * halfWidth;
		v.x = t.a*vx + t.b*vy + t.c*vz + t.d;
		v.y = t.e*vx + t.f*vy + t.g*vz + t.h;
		v.z = t.i * vx + t.j * vy + t.k * vz + t.l;
		
		w = w.next;	 // bottom left
		v = w.vertex;
		vx = pos.x; vy = pos.y; vz = pos.z;
		vx -= up.x*halfHeight;
		vy -= up.y*halfHeight;
		vz -= up.z*halfHeight;
		vx -= right.x*halfWidth;
		vy -= right.y*halfWidth;
		vz -= right.z * halfWidth;
		v.x = t.a*vx + t.b*vy + t.c*vz + t.d;
		v.y = t.e*vx + t.f*vy + t.g*vz + t.h;
		v.z = t.i * vx + t.j * vy + t.k * vz + t.l;
		
		w = w.next;	 // bottom right vertex
		v = w.vertex;
		vx = pos.x; vy = pos.y; vz = pos.z;
		vx -= up.x*halfHeight;
		vy -= up.y*halfHeight;
		vz -= up.z*halfHeight;
		vx += right.x*halfWidth;
		vy += right.y*halfWidth;
		vz += right.z * halfWidth;
		v.x = t.a*vx + t.b*vy + t.c*vz + t.d;
		v.y = t.e*vx + t.f*vy + t.g*vz + t.h;
		v.z = t.i * vx + t.j * vy + t.k * vz + t.l;
		
		
		w = w.next;		// top right
		v = w.vertex;
		vx = pos.x; vy = pos.y; vz = pos.z;
		vx += up.x*halfHeight;
		vy += up.y*halfHeight;
		vz += up.z*halfHeight;
		vx += right.x*halfWidth;
		vy += right.y*halfWidth;
		vz += right.z*halfWidth;
		v.x = t.a*vx + t.b*vy + t.c*vz + t.d;
		v.y = t.e*vx + t.f*vy + t.g*vz + t.h;
		v.z = t.i * vx + t.j * vy + t.k * vz + t.l;
		
		f.calculateNormal();
		return f;
	}
	
	/*
	public static function getFromWrapper(pos:Vec3, up:Vec3, right:Vec3, halfWidth:Float, halfHeight:Float, t:Transform3D):Face {
		var f:Face = new Face();
		
		return f;
	}
	
	public static function getValueWrapperFromPoints(pts:Array<Vec3>):Wrapper {
		var wrapper:Wrapper = new Wrapper();
		var w:Wrapper;
		
		w = wrapper;
		w.vertex = new Vertex();
		w.vertex.value = new Vertex();
		w.vertex.x = pts[0].x;
		w.vertex.y = pts[0].y;
		w.vertex.z = pts[0].z;
		
		for (i in 1...pts.length) {
			w = w.next = new Wrapper();
			w.vertex = new Vertex();
			w.vertex.value = new Vertex();
		}
		
		
		
		return wrapper;
	}
	*/
	
	
	
	private inline function get_side(a:Float , b:Float, c:Float, point1:Vertex, point2:Vertex):Int {
		var s1:Float = a * point1.cameraX + b * point1.cameraY - c;
		var s1i:Int = s1 > 0 ? 1 : s1 < 0 ? -1 : 0;
		
		var s2:Float = a * point2.cameraX + b * point2.cameraY - c;
		var s2i:Int = s2 > 0 ? 1 : s2 < 0 ? -1 : 0;
		
		var side:Int = s1i * s2i;
		return side < 0 ? -2 : side > 0 ? s1i : s1i == 0 ? s2i : s2i == 0 ? s1i : -2;
	}
	

	
	
	
}