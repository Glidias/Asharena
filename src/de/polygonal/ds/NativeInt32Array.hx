package de.polygonal.ds;

#if js
typedef NativeInt32Array = js.html.Int32Array;
#else
typedef NativeInt32Array = NativeArray<Int>;
#end