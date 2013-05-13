package util.geom;

/**
 * ...
 * @author Glenn Ko
 */

class TransformUtil 
{

		public static inline function identity(targ:ITransform3D):Void {
targ.a = 1;
targ.b = 0;
targ.c = 0;
targ.d = 0;
targ.e = 0;
targ.f = 1;
targ.g = 0;
targ.h = 0;
targ.i = 0;
targ.j = 0;
targ.k = 1;
targ.l = 0;
}

public static inline function compose(targ:ITransform3D, x:Float, y:Float, z:Float, rotationX:Float, rotationY:Float, rotationZ:Float, scaleX:Float, scaleY:Float, scaleZ:Float):Void {
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
targ.a = cosZ*cosYscaleX;
targ.b = cosZsinY*sinXscaleY - sinZ*cosXscaleY;
targ.c = cosZsinY*cosXscaleZ + sinZ*sinXscaleZ;
targ.d = x;
targ.e = sinZ*cosYscaleX;
targ.f = sinZsinY*sinXscaleY + cosZ*cosXscaleY;
targ.g = sinZsinY*cosXscaleZ - cosZ*sinXscaleZ;
targ.h = y;
targ.i = -sinY*scaleX;
targ.j = cosY*sinXscaleY;
targ.k = cosY*cosXscaleZ;
targ.l = z;
}

public static inline function composeInverse(targ:ITransform3D, x:Float, y:Float, z:Float, rotationX:Float, rotationY:Float, rotationZ:Float, scaleX:Float, scaleY:Float, scaleZ:Float):Void {
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
targ.a = cosZ*cosYscaleX;
targ.b = -sinZ*cosYscaleX;
targ.c = sinY/scaleX;
targ.d = -targ.a*x - targ.b*y - targ.c*z;
targ.e = sinZ*cosXscaleY + sinXsinY*cosZ/scaleY;
targ.f = cosZ*cosXscaleY - sinXsinY*sinZ/scaleY;
targ.g = -sinX*cosY/scaleY;
targ.h = -targ.e*x - targ.f*y - targ.g*z;
targ.i = sinZ*sinXscaleZ - cosZ*sinY*cosXscaleZ;
targ.j = cosZ*sinXscaleZ + sinY*sinZ*cosXscaleZ;
targ.k = cosY*cosXscaleZ;
targ.l = -targ.i*x - targ.j*y - targ.k*z;
}

public static inline function invert(targ:ITransform3D):Void {
var ta:Float = targ.a;
var tb:Float = targ.b;
var tc:Float = targ.c;
var td:Float = targ.d;
var te:Float = targ.e;
var tf:Float = targ.f;
var tg:Float = targ.g;
var th:Float = targ.h;
var ti:Float = targ.i;
var tj:Float = targ.j;
var tk:Float = targ.k;
var tl:Float = targ.l;
var det:Float = 1/(-tc*tf*ti + tb*tg*ti + tc*te*tj - ta*tg*tj - tb*te*tk + ta*tf*tk);
targ.a = (-tg*tj + tf*tk)*det;
targ.b = (tc*tj - tb*tk)*det;
targ.c = (-tc*tf + tb*tg)*det;
targ.d = (td*tg*tj - tc*th*tj - td*tf*tk + tb*th*tk + tc*tf*tl - tb*tg*tl)*det;
targ.e = (tg*ti - te*tk)*det;
targ.f = (-tc*ti + ta*tk)*det;
targ.g = (tc*te - ta*tg)*det;
targ.h = (tc*th*ti - td*tg*ti + td*te*tk - ta*th*tk - tc*te*tl + ta*tg*tl)*det;
targ.i = (-tf*ti + te*tj)*det;
targ.j = (tb*ti - ta*tj)*det;
targ.k = (-tb*te + ta*tf)*det;
targ.l = (td*tf*ti - tb*th*ti - td*te*tj + ta*th*tj + tb*te*tl - ta*tf*tl)*det;
}

public static inline function initFromVector(targ:ITransform3D, vector:Array<Float>):Void {
targ.a = vector[0];
targ.b = vector[1];
targ.c = vector[2];
targ.d = vector[3];
targ.e = vector[4];
targ.f = vector[5];
targ.g = vector[6];
targ.h = vector[7];
targ.i = vector[8];
targ.j = vector[9];
targ.k = vector[10];
targ.l = vector[11];
}

public static inline function append(targ:ITransform3D, transform:ITransform3D):Void {
var ta:Float = targ.a;
var tb:Float = targ.b;
var tc:Float = targ.c;
var td:Float = targ.d;
var te:Float = targ.e;
var tf:Float = targ.f;
var tg:Float = targ.g;
var th:Float = targ.h;
var ti:Float = targ.i;
var tj:Float = targ.j;
var tk:Float = targ.k;
var tl:Float = targ.l;
targ.a = transform.a*ta + transform.b*te + transform.c*ti;
targ.b = transform.a*tb + transform.b*tf + transform.c*tj;
targ.c = transform.a*tc + transform.b*tg + transform.c*tk;
targ.d = transform.a*td + transform.b*th + transform.c*tl + transform.d;
targ.e = transform.e*ta + transform.f*te + transform.g*ti;
targ.f = transform.e*tb + transform.f*tf + transform.g*tj;
targ.g = transform.e*tc + transform.f*tg + transform.g*tk;
targ.h = transform.e*td + transform.f*th + transform.g*tl + transform.h;
targ.i = transform.i*ta + transform.j*te + transform.k*ti;
targ.j = transform.i*tb + transform.j*tf + transform.k*tj;
targ.k = transform.i*tc + transform.j*tg + transform.k*tk;
targ.l = transform.i*td + transform.j*th + transform.k*tl + transform.l;
}

public static inline function prepend(targ:ITransform3D, transform:ITransform3D):Void {
var ta:Float = targ.a;
var tb:Float = targ.b;
var tc:Float = targ.c;
var td:Float = targ.d;
var te:Float = targ.e;
var tf:Float = targ.f;
var tg:Float = targ.g;
var th:Float = targ.h;
var ti:Float = targ.i;
var tj:Float = targ.j;
var tk:Float = targ.k;
var tl:Float = targ.l;
targ.a = ta*transform.a + tb*transform.e + tc*transform.i;
targ.b = ta*transform.b + tb*transform.f + tc*transform.j;
targ.c = ta*transform.c + tb*transform.g + tc*transform.k;
targ.d = ta*transform.d + tb*transform.h + tc*transform.l + td;
targ.e = te*transform.a + tf*transform.e + tg*transform.i;
targ.f = te*transform.b + tf*transform.f + tg*transform.j;
targ.g = te*transform.c + tf*transform.g + tg*transform.k;
targ.h = te*transform.d + tf*transform.h + tg*transform.l + th;
targ.i = ti*transform.a + tj*transform.e + tk*transform.i;
targ.j = ti*transform.b + tj*transform.f + tk*transform.j;
targ.k = ti*transform.c + tj*transform.g + tk*transform.k;
targ.l = ti*transform.d + tj*transform.h + tk*transform.l + tl;

}

public static inline function combine(targ:ITransform3D, transformA:ITransform3D, transformB:ITransform3D):Void {
targ.a = transformA.a*transformB.a + transformA.b*transformB.e + transformA.c*transformB.i;
targ.b = transformA.a*transformB.b + transformA.b*transformB.f + transformA.c*transformB.j;
targ.c = transformA.a*transformB.c + transformA.b*transformB.g + transformA.c*transformB.k;
targ.d = transformA.a*transformB.d + transformA.b*transformB.h + transformA.c*transformB.l + transformA.d;
targ.e = transformA.e*transformB.a + transformA.f*transformB.e + transformA.g*transformB.i;
targ.f = transformA.e*transformB.b + transformA.f*transformB.f + transformA.g*transformB.j;
targ.g = transformA.e*transformB.c + transformA.f*transformB.g + transformA.g*transformB.k;
targ.h = transformA.e*transformB.d + transformA.f*transformB.h + transformA.g*transformB.l + transformA.h;
targ.i = transformA.i*transformB.a + transformA.j*transformB.e + transformA.k*transformB.i;
targ.j = transformA.i*transformB.b + transformA.j*transformB.f + transformA.k*transformB.j;
targ.k = transformA.i*transformB.c + transformA.j*transformB.g + transformA.k*transformB.k;
targ.l = transformA.i*transformB.d + transformA.j*transformB.h + transformA.k*transformB.l + transformA.l;
}

public static inline function calculateInversion(targ:ITransform3D, source:ITransform3D):Void {
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
targ.a = (-tg*tj + tf*tk)*det;
targ.b = (tc*tj - tb*tk)*det;
targ.c = (-tc*tf + tb*tg)*det;
targ.d = (td*tg*tj - tc*th*tj - td*tf*tk + tb*th*tk + tc*tf*tl - tb*tg*tl)*det;
targ.e = (tg*ti - te*tk)*det;
targ.f = (-tc*ti + ta*tk)*det;
targ.g = (tc*te - ta*tg)*det;
targ.h = (tc*th*ti - td*tg*ti + td*te*tk - ta*th*tk - tc*te*tl + ta*tg*tl)*det;
targ.i = (-tf*ti + te*tj)*det;
targ.j = (tb*ti - ta*tj)*det;
targ.k = (-tb*te + ta*tf)*det;
targ.l = (td*tf*ti - tb*th*ti - td*te*tj + ta*th*tj + tb*te*tl - ta*tf*tl)*det;
}

public static inline function copy(targ:ITransform3D, source:ITransform3D):Void {
targ.a = source.a;
targ.b = source.b;
targ.c = source.c;
targ.d = source.d;
targ.e = source.e;
targ.f = source.f;
targ.g = source.g;
targ.h = source.h;
targ.i = source.i;
targ.j = source.j;
targ.k = source.k;
targ.l = source.l;
}

	
}