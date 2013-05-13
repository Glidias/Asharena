package components;
import util.geom.ITransform3D;

/**
 * ...
 * @author Glenn Ko
 */

class Transform3D implements ITransform3D
{

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
	
	public function new() 
	{
		identity();
	}
	
		public inline function identity():Void {
			a = 1;
			b = 0;
			c = 0;
			d = 0;
			e = 0;
			f = 1;
			g = 0;
			h = 0;
			i = 0;
			j = 0;
			k = 1;
			l = 0;
		}

public inline function compose(x:Float, y:Float, z:Float, rotationX:Float, rotationY:Float, rotationZ:Float, scaleX:Float, scaleY:Float, scaleZ:Float):Void {
var cosX:Float = Math.cos(rotationX);
var sinX:Float = Math.sin(rotationX);
var cosY:Float = Math.cos(rotationY);
var sinY:Float = Math.sin(rotationY);
var cosZ:Float = Math.cos(rotationZ);
var sinZ:Float = Math.sin(rotationZ);
var cosZsinY:Float = cosZ*sinY;
var sinZsinY:Float = sinZ*sinY;
var cosYscaleX:Float = cosY*scaleX;
var sinXscaleY:Float = sinX*scaleY;
var cosXscaleY:Float = cosX*scaleY;
var cosXscaleZ:Float = cosX*scaleZ;
var sinXscaleZ:Float = sinX*scaleZ;
a = cosZ*cosYscaleX;
b = cosZsinY*sinXscaleY - sinZ*cosXscaleY;
c = cosZsinY*cosXscaleZ + sinZ*sinXscaleZ;
d = x;
e = sinZ*cosYscaleX;
f = sinZsinY*sinXscaleY + cosZ*cosXscaleY;
g = sinZsinY*cosXscaleZ - cosZ*sinXscaleZ;
h = y;
i = -sinY*scaleX;
j = cosY*sinXscaleY;
k = cosY*cosXscaleZ;
l = z;
}

public inline function composeInverse(x:Float, y:Float, z:Float, rotationX:Float, rotationY:Float, rotationZ:Float, scaleX:Float, scaleY:Float, scaleZ:Float):Void {
var cosX:Float = Math.cos(rotationX);
var sinX:Float = Math.sin(-rotationX);
var cosY:Float = Math.cos(rotationY);
var sinY:Float = Math.sin(-rotationY);
var cosZ:Float = Math.cos(rotationZ);
var sinZ:Float = Math.sin(-rotationZ);
var sinXsinY:Float = sinX*sinY;
var cosYscaleX:Float = cosY/scaleX;
var cosXscaleY:Float = cosX/scaleY;
var sinXscaleZ:Float = sinX/scaleZ;
var cosXscaleZ:Float = cosX/scaleZ;
a = cosZ*cosYscaleX;
b = -sinZ*cosYscaleX;
c = sinY/scaleX;
d = -a*x - b*y - c*z;
e = sinZ*cosXscaleY + sinXsinY*cosZ/scaleY;
f = cosZ*cosXscaleY - sinXsinY*sinZ/scaleY;
g = -sinX*cosY/scaleY;
h = -e*x - f*y - g*z;
i = sinZ*sinXscaleZ - cosZ*sinY*cosXscaleZ;
j = cosZ*sinXscaleZ + sinY*sinZ*cosXscaleZ;
k = cosY*cosXscaleZ;
l = -i*x - j*y - k*z;
}

public inline function invert():Void {
var ta:Float = a;
var tb:Float = b;
var tc:Float = c;
var td:Float = d;
var te:Float = e;
var tf:Float = f;
var tg:Float = g;
var th:Float = h;
var ti:Float = i;
var tj:Float = j;
var tk:Float = k;
var tl:Float = l;
var det:Float = 1/(-tc*tf*ti + tb*tg*ti + tc*te*tj - ta*tg*tj - tb*te*tk + ta*tf*tk);
a = (-tg*tj + tf*tk)*det;
b = (tc*tj - tb*tk)*det;
c = (-tc*tf + tb*tg)*det;
d = (td*tg*tj - tc*th*tj - td*tf*tk + tb*th*tk + tc*tf*tl - tb*tg*tl)*det;
e = (tg*ti - te*tk)*det;
f = (-tc*ti + ta*tk)*det;
g = (tc*te - ta*tg)*det;
h = (tc*th*ti - td*tg*ti + td*te*tk - ta*th*tk - tc*te*tl + ta*tg*tl)*det;
i = (-tf*ti + te*tj)*det;
j = (tb*ti - ta*tj)*det;
k = (-tb*te + ta*tf)*det;
l = (td*tf*ti - tb*th*ti - td*te*tj + ta*th*tj + tb*te*tl - ta*tf*tl)*det;
}

public inline function initFromVector( vector:Array<Float>):Void {
a = vector[0];
b = vector[1];
c = vector[2];
d = vector[3];
e = vector[4];
f = vector[5];
g = vector[6];
h = vector[7];
i = vector[8];
j = vector[9];
k = vector[10];
l = vector[11];
}

public inline function append(transform:ITransform3D):Void {
var ta:Float = a;
var tb:Float = b;
var tc:Float = c;
var td:Float = d;
var te:Float = e;
var tf:Float = f;
var tg:Float = g;
var th:Float = h;
var ti:Float = i;
var tj:Float = j;
var tk:Float = k;
var tl:Float = l;
a = transform.a*ta + transform.b*te + transform.c*ti;
b = transform.a*tb + transform.b*tf + transform.c*tj;
c = transform.a*tc + transform.b*tg + transform.c*tk;
d = transform.a*td + transform.b*th + transform.c*tl + transform.d;
e = transform.e*ta + transform.f*te + transform.g*ti;
f = transform.e*tb + transform.f*tf + transform.g*tj;
g = transform.e*tc + transform.f*tg + transform.g*tk;
h = transform.e*td + transform.f*th + transform.g*tl + transform.h;
i = transform.i*ta + transform.j*te + transform.k*ti;
j = transform.i*tb + transform.j*tf + transform.k*tj;
k = transform.i*tc + transform.j*tg + transform.k*tk;
l = transform.i*td + transform.j*th + transform.k*tl + transform.l;
}

public inline function prepend(transform:ITransform3D):Void {
var ta:Float = a;
var tb:Float = b;
var tc:Float = c;
var td:Float = d;
var te:Float = e;
var tf:Float = f;
var tg:Float = g;
var th:Float = h;
var ti:Float = i;
var tj:Float = j;
var tk:Float = k;
var tl:Float = l;
a = ta*transform.a + tb*transform.e + tc*transform.i;
b = ta*transform.b + tb*transform.f + tc*transform.j;
c = ta*transform.c + tb*transform.g + tc*transform.k;
d = ta*transform.d + tb*transform.h + tc*transform.l + td;
e = te*transform.a + tf*transform.e + tg*transform.i;
f = te*transform.b + tf*transform.f + tg*transform.j;
g = te*transform.c + tf*transform.g + tg*transform.k;
h = te*transform.d + tf*transform.h + tg*transform.l + th;
i = ti*transform.a + tj*transform.e + tk*transform.i;
j = ti*transform.b + tj*transform.f + tk*transform.j;
k = ti*transform.c + tj*transform.g + tk*transform.k;
l = ti*transform.d + tj*transform.h + tk*transform.l + tl;

}

public inline function combine( transformA:ITransform3D, transformB:ITransform3D):Void {
a = transformA.a*transformB.a + transformA.b*transformB.e + transformA.c*transformB.i;
b = transformA.a*transformB.b + transformA.b*transformB.f + transformA.c*transformB.j;
c = transformA.a*transformB.c + transformA.b*transformB.g + transformA.c*transformB.k;
d = transformA.a*transformB.d + transformA.b*transformB.h + transformA.c*transformB.l + transformA.d;
e = transformA.e*transformB.a + transformA.f*transformB.e + transformA.g*transformB.i;
f = transformA.e*transformB.b + transformA.f*transformB.f + transformA.g*transformB.j;
g = transformA.e*transformB.c + transformA.f*transformB.g + transformA.g*transformB.k;
h = transformA.e*transformB.d + transformA.f*transformB.h + transformA.g*transformB.l + transformA.h;
i = transformA.i*transformB.a + transformA.j*transformB.e + transformA.k*transformB.i;
j = transformA.i*transformB.b + transformA.j*transformB.f + transformA.k*transformB.j;
k = transformA.i*transformB.c + transformA.j*transformB.g + transformA.k*transformB.k;
l = transformA.i*transformB.d + transformA.j*transformB.h + transformA.k*transformB.l + transformA.l;
}

public inline function calculateInversion( source:ITransform3D):Void {
var ta = source.a;
var tb = source.b;
var tc = source.c;
var td = source.d;
var te = source.e;
var tf = source.f;
var tg = source.g;
var th = source.h;
var ti = source.i;
var tj = source.j;
var tk = source.k;
var tl = source.l;
var det = 1/(-tc*tf*ti + tb*tg*ti + tc*te*tj - ta*tg*tj - tb*te*tk + ta*tf*tk);
a = (-tg*tj + tf*tk)*det;
b = (tc*tj - tb*tk)*det;
c = (-tc*tf + tb*tg)*det;
d = (td*tg*tj - tc*th*tj - td*tf*tk + tb*th*tk + tc*tf*tl - tb*tg*tl)*det;
e = (tg*ti - te*tk)*det;
f = (-tc*ti + ta*tk)*det;
g = (tc*te - ta*tg)*det;
h = (tc*th*ti - td*tg*ti + td*te*tk - ta*th*tk - tc*te*tl + ta*tg*tl)*det;
i = (-tf*ti + te*tj)*det;
j = (tb*ti - ta*tj)*det;
k = (-tb*te + ta*tf)*det;
l = (td*tf*ti - tb*th*ti - td*te*tj + ta*th*tj + tb*te*tl - ta*tf*tl)*det;
}

public inline function copy( source:ITransform3D):Void {
a = source.a;
b = source.b;
c = source.c;
d = source.d;
e = source.e;
f = source.f;
g = source.g;
h = source.h;
i = source.i;
j = source.j;
k = source.k;
l = source.l;
}
	
}