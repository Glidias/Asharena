package de.polygonal.ds;

#if js
typedef NativeFloat32Array = js.html.Float32Array;
#else
typedef NativeFloat32Array = NativeArray<Float>;
#end