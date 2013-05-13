/**
 * A standard 4x3 matrix.
 * @author Glenn Ko
 */

package util.geom;
import flash.Vector;
import flash.Vector;

class Mat4 implements IMat4
{
	public static var IDENTITY:Mat4 = new Mat4();
	
	public var a:Float;
	public var b:Float;
	public var c:Float;
	public var d:Float;
		
	public var e:Float;
	public var f:Float;
	public var g:Float;
	public var h:Float;
		
	public var i:Float;
	public var j:Float;
	public var k:Float;
	public var l:Float;
	
	public function new(a:Float = 1, b:Float = 0, c:Float = 0, d:Float = 0, e:Float = 0, f:Float = 1, g:Float = 0, h:Float = 0, i:Float = 0, j:Float = 0, k:Float = 1, l:Float = 0) 
	{
		this.a = a;
		this.b = b;
		this.c = c;
		this.d = d;

		this.e = e;
		this.f = f;
		this.g = g;
		this.h = h;

		this.i = i;
		this.j = j;
		this.k = k;
		this.l = l;
	}
	
	// Inlined by default
		
	inline public function identity():Void {
		a = f =	k = 1;
		b = c = e = g = i =	j = d = h = l = 0;
	}
	
	inline public function determinant():Float {
		return -c*f*i + b*g*i + c*e*j - a*g*j - b*e*k + a*f*k;
	}

	// Optional inlines
	
	public function invert():Void {
		invert_with_determinant( determinant() );
	}	
	inline public function invert_with_determinant(det:Float):Void {
		a = (-g*j + f*k)/det;
		b = (c*j - b*k)/det;
		c = (-c*f + b*g)/det;
		d = (d*g*j - c*h*j - d*f*k + b*h*k + c*f*l - b*g*l)/det;
		e = (g*i - e*k)/det;
		f = (-c*i + a*k)/det;
		g = (c*e - a*g)/det;
		h = (c*h*i - d*g*i + d*e*k - a*h*k - c*e*l + a*g*l)/det;
		i = (-f*i + e*j)/det;
		j = (b*i - a*j)/det;
		k = (-b*e + a*f)/det;
		l = (d*f*i - b*h*i - d*e*j + a*h*j + b*e*l - a*f*l)/det;
	}


	public function append(m:Mat4):Void {
		a = m.a*a + m.b*e + m.c*i;
		b = m.a*b + m.b*f + m.c*j;
		c = m.a*c + m.b*g + m.c*k;
		d = m.a*d + m.b*h + m.c*l + m.d;
		e = m.e*a + m.f*e + m.g*i;
		f = m.e*b + m.f*f + m.g*j;
		g = m.e*c + m.f*g + m.g*k;
		h = m.e*d + m.f*h + m.g*l + m.h;
		i = m.i*a + m.j*e + m.k*i;
		j = m.i*b + m.j*f + m.k*j;
		k = m.i*c + m.j*g + m.k*k;
		l = m.i*d + m.j*h + m.k*l + m.l;
	}


	public function prepend(m:Mat4):Void {
		a = a*m.a + b*m.e + c*m.i;
		b = a*m.b + b*m.f + c*m.j;
		c = a*m.c + b*m.g + c*m.k;
		d = a*m.d + b*m.h + c*m.l + d;
		e = e*m.a + f*m.e + g*m.i;
		f = e*m.b + f*m.f + g*m.j;
		g = e*m.c + f*m.g + g*m.k;
		h = e*m.d + f*m.h + g*m.l + h;
		i = i*m.a + j*m.e + k*m.i;
		j = i*m.b + j*m.f + k*m.j;
		k = i*m.c + j*m.g + k*m.k;
		l = i*m.d + j*m.h + k*m.l + l;
	}
		

	public function add(m:Mat4):Void {
		a += m.a;
		b += m.b;
		c += m.c;
		d += m.d;
		e += m.e;
		f += m.f;
		g += m.g;
		h += m.h;
		i += m.i;
		j += m.j;
		k += m.k;
		l += m.l;
	}

	public function subtract(m:Mat4):Void {
		a -= m.a;
		b -= m.b;
		c -= m.c;
		d -= m.d;
		e -= m.e;
		f -= m.f;
		g -= m.g;
		h -= m.h;
		i -= m.i;
		j -= m.j;
		k -= m.k;
		l -= m.l;
	}
		

	inline public function transformPoint(vin:Vec3, vout:Vec3):Void {
		vout.x = a*vin.x + b*vin.y + c*vin.z + d;
		vout.y = e*vin.x + f*vin.y + g*vin.z + h;
		vout.z = i*vin.x + j*vin.y + k*vin.z + l;
	}


	public function transformPointTransposed(vin:Vec3, vout:Vec3):Void {
		var xx:Float = vin.x - d;
		var yy:Float = vin.y - h;
		var zz:Float = vin.z - l;
		vout.x = a*xx + e*yy + i*zz;
		vout.y = b*xx + f*yy + j*zz;
		vout.z = c*xx + g*yy + k*zz;
	}


	public function transformPoints(arrin:Vector<Vec3>, arrout:Vector<Vec3>):Void {
		var vin:Vec3;
		var vout:Vec3;
		for (i in 0...arrin.length) {
			vin = arrin[i];
			vout = arrout[i];
			vout.x = a*vin.x + b*vin.y + c*vin.z + d;
			vout.y = e*vin.x + f*vin.y + g*vin.z + h;
			vout.z = i*vin.x + j*vin.y + k*vin.z + l;
		}
	}


	public function transformPointsN(arrin:Vector<Vec3>, arrout:Vector<Vec3>, len:Int):Void {
		var vin:Vec3;
		var vout:Vec3;
		for (i in 0...len) {
			vin = arrin[i];
			vout = arrout[i];
			vout.x = a*vin.x + b*vin.y + c*vin.z + d;
			vout.y = e*vin.x + f*vin.y + g*vin.z + h;
			vout.z = i*vin.x + j*vin.y + k*vin.z + l;
		}
	}


	public function transformPointsTransposed(arrin:Vector<Vec3>, arrout:Vector<Vec3>):Void {
		var vin:Vec3;
		var vout:Vec3;
		for (i in 0...arrin.length) {
			vin = arrin[i];
			vout = arrout[i];
			var xx:Float = vin.x - d;
			var yy:Float = vin.y - h;
			var zz:Float = vin.z - l;
			vout.x = a*xx + e*yy + i*zz;
			vout.y = b*xx + f*yy + j*zz;
			vout.z = c*xx + g*yy + k*zz;
		}
	}


	public function transformPointsTransposedN(arrin:Vector<Vec3>, arrout:Vector<Vec3>, len:Int):Void {
		var vin:Vec3;
		var vout:Vec3;
		for (i in 0...len) {
			vin = arrin[i];
			vout = arrout[i];
			var xx:Float = vin.x - d;
			var yy:Float = vin.y - h;
			var zz:Float = vin.z - l;
			vout.x = a*xx + e*yy + i*zz;
			vout.y = b*xx + f*yy + j*zz;
			vout.z = c*xx + g*yy + k*zz;
		}
	}
		

	public function getAxis(idx:Int, axis:Vec3):Void {
		switch (idx) {
			case 0:
				axis.x = a;
				axis.y = e;
				axis.z = i;
				return;
			case 1:
				axis.x = b;
				axis.y = f;
				axis.z = j;
				return;
			case 2:
				axis.x = c;
				axis.y = g;
				axis.z = k;
				return;
			case 3:
				axis.x = d;
				axis.y = h;
				axis.z = l;
				return;
		}
	}
		

	public function setAxes(xAxis:Vec3, yAxis:Vec3, zAxis:Vec3, pos:Vec3):Void {
		a = xAxis.x;
		e = xAxis.y;
		i = xAxis.z;
			
		b = yAxis.x;
		f = yAxis.y;
		j = yAxis.z;
			
		c = zAxis.x;
		g = zAxis.y;
		k = zAxis.z;
			
		d = pos.x;
		h = pos.y;
		l = pos.z;
	}


	public function transformVector(vin:Vec3, vout:Vec3):Void {
		vout.x = a*vin.x + b*vin.y + c*vin.z;
		vout.y = e*vin.x + f*vin.y + g*vin.z;
		vout.z = i*vin.x + j*vin.y + k*vin.z;
	}


	public function transformVectorTransposed(vin:Vec3, vout:Vec3):Void {
		vout.x = a*vin.x + e*vin.y + i*vin.z;
		vout.y = b*vin.x + f*vin.y + j*vin.z;
		vout.z = c*vin.x + g*vin.y + k*vin.z;
	}


	public function copy(m:Mat4):Void {
		a = m.a;
		b = m.b;
		c = m.c;
		d = m.d;
		e = m.e;
		f = m.f;
		g = m.g;
		h = m.h;
		i = m.i;
		j = m.j;
		k = m.k;
		l = m.l;
	}
	
	public function copy3(m:Mat3):Void {
		a = m.a;
		b = m.b;
		c = m.c;
		e = m.e;
		f = m.f;
		g = m.g;
		i = m.i;
		j = m.j;
		k = m.k;
	}

	public function getEulerAngles(angles:Vec3):Void {
		if (-1 < i && i < 1) {
			angles.x = Math.atan2(j, k);
			angles.y = -Math.asin(i);
			angles.z = Math.atan2(e, a);
		} else {
			angles.x = 0;
			angles.y = (i <= -1) ? Math.PI : -Math.PI;
			angles.y *= 0.5;
			angles.z = Math.atan2(-b, f);
		}
	}
		
		
	inline public function setPosition(pos:Vec3):Void {
		d = pos.x;
		h = pos.y;
		l = pos.z;
	}


	inline public function setPositionXYZ(x:Float, y:Float, z:Float):Void {
		d = x;
		h = y;
		l = z;
	}
		

	inline public function clone():Mat4 {
		return new Mat4(a, b, c, d, e, f, g, h, i, j, k, l);
	}
		

	public function toString():String {
		return "[Mat4 [" + a + " " + b + " " + c + " " + d + "] [" + e + " " + f + " " + g + " " + h + "] [" + i + " " + j + " " + k + " " + l + "]]";
	}


	public function setRotation(rx:Float, ry:Float, rz:Float):Void {
		var cosX:Float = Math.cos(rx);
		var sinX:Float = Math.sin(rx);
		var cosY:Float = Math.cos(ry);
		var sinY:Float = Math.sin(ry);
		var cosZ:Float = Math.cos(rz);
		var sinZ:Float = Math.sin(rz);
		
		var cosZsinY:Float = cosZ * sinY;		
		var sinZsinY:Float = sinZ*sinY;
			
		a = cosZ*cosY;
		b = cosZsinY*sinX - sinZ*cosX;
		c = cosZsinY*cosX + sinZ*sinX;

		e = sinZ*cosY;
		f = sinZsinY*sinX + cosZ*cosX;
		g = sinZsinY*cosX - cosZ*sinX;
			
		i = -sinY;
		j = cosY*sinX;
		k = cosY*cosX;
	}
	

	public function setFromAxisAngle(axis:Vec3, angle:Float):Void {
		var c1:Float = Math.cos(angle);
		var s:Float = Math.sin(angle);
		var t:Float = 1 - c1;
		var x:Float = axis.x;
		var y:Float = axis.y;
		var z:Float = axis.z;

		a = t*x*x + c1;
		b = t*x*y - z*s;
		c = t*x*z + y*s;

		e = t*x*y + z*s;
		f = t*y*y + c1;
		g = t*y*z - x*s;

		i = t*x*z - y*s;
		j = t*y*z + x*s;
		k = t*z*z + c1;
	}
}