/**
 * A standard 3x3 matrix.
 * @author Glenn Ko
 */

package util.geom;

class Mat3 implements IMat3
{
	public static var IDENTITY:Mat3 = new Mat3();
	public static var ZERO:Mat3 = new Mat3(0, 0, 0, 0, 0, 0, 0, 0, 0);
	
	public var a:Float;
	public var b:Float;
	public var c:Float;
	
	public var e:Float;
	public var f:Float;
	public var g:Float;
	
	public var i:Float;
	public var j:Float;
	public var k:Float;
	
	public function new(a:Float = 1, b:Float = 0, c:Float = 0, e:Float = 0, f:Float = 1, g:Float = 0, i:Float = 0, j:Float = 0, k:Float = 1) 
	{
		this.a = a;
		this.b = b;
		this.c = c;

		this.e = e;
		this.f = f;
		this.g = g;

		this.i = i;
		this.j = j;
		this.k = k;	
	}
	
	
	// -- Inlined 
	
	inline public function determinant():Float {
		return 1/(-c*f*i + b*g*i +c*e*j - a*g*j - b*e*k + a*f*k);
	}
	
	inline public function identity():Void {
		a = f =	k = 1;
		b = c = e = g = i =	j = 0;
	}
	
	inline public function clone():Mat3 {
		return new Mat3(a, b, c, e, f, g, i, j, k);
	}
 
	inline public function transformVector(vin:Vec3, vout:Vec3):Void {
		vout.x = a*vin.x + b*vin.y + c*vin.z;
		vout.y = e*vin.x + f*vin.y + g*vin.z;
		vout.z = i*vin.x + j*vin.y + k*vin.z;
	}

	inline public function transformVectorTransposed(vin:Vec3, vout:Vec3):Void {
		vout.x = a*vin.x + e*vin.y + i*vin.z;
		vout.y = b*vin.x + f*vin.y + j*vin.z;
		vout.z = c*vin.x + g*vin.y + k*vin.z;
	}

	inline public function transformVec3To3D(vin:Vec3, vout:Vec3):Void {
		vout.x = a*vin.x + b*vin.y + c*vin.z;
		vout.y = e*vin.x + f*vin.y + g*vin.z;
		vout.z = i*vin.x + j*vin.y + k*vin.z;
	}

	// Optional inlines

	#if (iA_x||iInvert_x) inline #end
	public function invert():Void {
		invert_with_determinant( determinant() );
	}	
	inline public function invert_with_determinant(det:Float):Void {
		a = (f*k - g*j)*det;
		b = (c*g - b*k)*det;
		c = (b*g - c*f)*det;
		e = (g*i - e*k)*det;
		f = (a*k - c*i)*det;
		g = (c*e - a*g)*det;
		i = (e*j - f*i)*det;
		j = (b*i - a*j)*det;
		k = (a*f - b*e)*det;
	}

	#if (iA_x||iAppend_x) inline #end
	public function append(m:Mat3):Void {
		a = m.a*a + m.b*e + m.c*i;
		b = m.a*b + m.b*f + m.c*j;
		c = m.a*c + m.b*g + m.c*k;
		e = m.e*a + m.f*e + m.g*i;
		f = m.e*b + m.f*f + m.g*j;
		g = m.e*c + m.f*g + m.g*k;
		i = m.i*a + m.j*e + m.k*i;
		j = m.i*b + m.j*f + m.k*j;
		k = m.i*c + m.j*g + m.k*k;
	}

	#if (iA_x||iPrepend_x) inline #end
	public function prepend(m:Mat3):Void {
		a = a*m.a + b*m.e + c*m.i;
		b = a*m.b + b*m.f + c*m.j;
		c = a*m.c + b*m.g + c*m.k;
		e = e*m.a + f*m.e + g*m.i;
		f = e*m.b + f*m.f + g*m.j;
		g = e*m.c + f*m.g + g*m.k;
		i = i*m.a + j*m.e + k*m.i;
		j = i*m.b + j*m.f + k*m.j;
		k = i*m.c + j*m.g + k*m.k;
	}

	#if (iA_x||iPrepend_x) inline #end
	public function prependTransposed(m:Mat3):Void {
		a = a*m.a + b*m.b + c*m.c;
		b = a*m.e + b*m.f + c*m.g;
		c = a*m.i + b*m.j + c*m.k;
		e = e*m.a + f*m.b + g*m.c;
		f = e*m.e + f*m.f + g*m.g;
		g = e*m.i + f*m.j + g*m.k;
		i = i*m.a + j*m.b + k*m.c;
		j = i*m.e + j*m.f + k*m.g;
		k = i*m.i + j*m.j + k*m.k;
	}
	
	#if (iA_x||iAdd_x) inline #end
	public function add(m:Mat3):Void {
		a += m.a;
		b += m.b;
		c += m.c;
		e += m.e;
		f += m.f;
		g += m.g;
		i += m.i;
		j += m.j;
		k += m.k;
	}

	#if (iA_x||iSubtract_x) inline #end
	public function subtract(m:Mat3):Void {
		a -= m.a;
		b -= m.b;
		c -= m.c;
		e -= m.e;
		f -= m.f;
		g -= m.g;
		i -= m.i;
		j -= m.j;
		k -= m.k;
	}
	
	#if (iA_x||iTranspose_x) inline #end
	public function transpose():Void {
		var tmp:Float = b;
		b = e;
		e = tmp;
		tmp = c;
		c = i;
		i = tmp;
		tmp = g;
		g = j;
		j = tmp;
	}

	#if (iA_x||iSkew_x) inline #end
	public function toSkewSymmetric(v:Vec3):Void {
		a = f = k = 0;
		b = -v.z;
		c = v.y;
		e = v.z;
		g = -v.x;
		i = -v.y;
		j = v.x;
	}
	
	#if (iA_x||iCopy_x) inline #end
	public function copyFrom(m:Mat3):Void {
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
	
	#if (iA_x||iEuler_x) inline #end
	public function writeToEulerAngles(angles:Vec3):Void {
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
	
	#if (iA_x||iRotation_x) inline #end
	public function setRotation(rx:Float, ry:Float, rz:Float):Void {
		var cosX:Float = Math.cos(rx);
		var sinX:Float = Math.sin(rx);
		var cosY:Float = Math.cos(ry);
		var sinY:Float = Math.sin(ry);
		var cosZ:Float = Math.cos(rz);
		var sinZ:Float = Math.sin(rz);

		var cosZsinY:Float = cosZ*sinY;
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

	#if (iA_x||iAxisAngle_x) inline #end
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
		k = t * z * z + c1;
		
	}
	

	public function toString():String {
		return "[Mat3 (" + a + ", " + b + ", " + c + "), (" + e + ", " + f + ", " + g + "), (" + i + ", " + j + ", " + k + ")]";
	}


	
}