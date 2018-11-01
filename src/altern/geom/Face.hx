package altern.geom;

/**
 * This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
 * If it is not possible or desirable to put the notice in a particular file, then You may include the notice in a location (such as a LICENSE file in a relevant directory) where a recipient would be likely to look for such a notice.
 * You may add additional accurate notices of copyright ownership.
 *
 * It is desirable to notify that Covered Software was "Powered by AlternativaPlatform" with link to http://www.alternativaplatform.com/ 
 * */
/**
 * Port over to Haxe
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
			w.vertex.next = Vertex.collector;
			Vertex.collector = w.vertex;
			w.vertex = null;
			
			w = nextW;
		}
		wrapper = null;
		processNext = null;
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
					continue;
				}
				var sideB:Int = get_side(a, b, c, v2_0, v2_1);
				if (sideB < -1) {
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
	
	
	private inline function get_side(a:Float , b:Float, c:Float, point1:Vertex, point2:Vertex):Int {
		var s1:Float = a * point1.cameraX + b * point1.cameraY - c;
		var s1i:Int = s1 > 0 ? 1 : s1 < 0 ? -1 : 0;
		
		var s2:Float = a * point2.cameraX + b * point2.cameraY - c;
		var s2i:Int = s2 > 0 ? 1 : s2 < 0 ? -1 : 0;
		
		var side:Int = s1i * s2i;
		return side < 0 ? -2 : side > 0 ? s1i : s1i == 0 ? s2i : s2i == 0 ? s1i : -2;
	}
	
	/*
	public function getOverlapClipFace(face:Face):Face {
		var v:Vertex;
		var w:Wrapper;
		var ax:Number;
		var ay:Number;
		var az:Number;
		var bx:Number;
		var by:Number;
		var bz:Number;
		var negativeFace:Face;
		ax = normalX;
		ay = normalY;
		az = normalZ;
		var inputNorm:Vector3D = ClipMacros.DUMMY_VECTOR;

		for (w = wrapper; w != null; w = w.next) {
			v = w.vertex;
			var v2:Vertex = w.next != null ? w.next.vertex : wrapper.vertex;
			bx = v2.x - v.x;
			by = v2.y - v.y;
			bz = v2.z - v.z;
			var d:Number = 1 / Math.sqrt(bx * bx + by * by + bz * bz);
			bx *= d;
			by *= d;
			bz *= d;
			inputNorm.x = bz*ay - by*az;
			inputNorm.y = bx*az - bz*ax;
			inputNorm.z = by * ax - bx * ay;
			
			inputNorm.w = v.x * inputNorm.x + v.y * inputNorm.y + v.z * inputNorm.z;
				
			ClipMacros.computeMeshVerticesLocalOffsets(face, inputNorm);
			
			if (negativeFace == null) negativeFace = ClipMacros.newPositiveClipFace(face, inputNorm, inputNorm.w);
			else ClipMacros.updateClipFace(face, inputNorm, inputNorm.w);
			if (negativeFace.wrapper == null) negativeFace = null;
			face = negativeFace;
			if (face == null) {
				// face happens to lie completely on the outside of a plane
				//gotExit = true;
				break;  
			}
				
		}
		
		if (negativeFace != null) {
			return negativeFace;
			//return "Negative: "+gotExit + ":"+ negativeFace.wrapper + "="+count + "/"+pCount;
		}
		
		return null;
	}
	*/
	
	
}