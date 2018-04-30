/*
Copyright (c) 2008-2018 Michael Baczynski, http://www.polygonal.de

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
associated documentation files (the "Software"), to deal in the Software without restriction,
including without limitation the rights to use, copy, modify, merge, publish, distribute,
sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or
substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT
NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT
OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
package de.polygonal.ds.tools;

//import de.polygonal.ds.NativeFloat32Array;
import de.polygonal.ds.NativeInt32Array;
import de.polygonal.ds.tools.ArrayTools;
import de.polygonal.ds.tools.Assert.assert;

/**
	Utility class for modifying `NativeInt32Array` objects
**/
class NativeInt32ArrayTools
{
	/**
		Allocates an array with length `len`.
	**/
	public static inline function alloc(len:Int):NativeInt32Array
	{
		#if flash10
			//#if (generic && !no_inline)
			return new flash.Vector<Int>(len, true);
			//#else
			//var a = new Array<Int>();
			//untyped a.length = len;
			//return a;
			//#end
		#elseif neko
		return untyped __dollar__amake(len);
			
		#elseif cs
		return new cs.NativeArray<Int>(len); // cs.Lib.arrayAlloc(len);
		#elseif java
		return new java.NativeArray<Int>(len);
		#elseif cpp
		var a = new Array<Int>();
		cpp.NativeArray.setSize(a, len);
		return a;
		#elseif python
		return python.Syntax.pythonCode("[{0}]*{1}", null, len);
		#else
			return new NativeInt32Array(len);
		#end
	}
	
	
	/*
	public static inline function allocFloat(len:Int):NativeFloat32Array
	{
		#if flash10
			//#if (generic && !no_inline)
			return new flash.Vector<Float>(len, true);
			//#else
			//var a = new Array<Int>();
			//untyped a.length = len;
			//return a;
			//#end
		#elseif neko
		return untyped __dollar__amake(len);
			
		#elseif cs
		return new cs.NativeArray<Int>(len); // cs.Lib.arrayAlloc(len);
		#elseif java
		return new java.NativeArray<Int>(len);
		#elseif cpp
		var a = new Array<Int>();
		cpp.NativeArray.setSize(a, len);
		return a;
		#elseif python
		return python.Syntax.pythonCode("[{0}]*{1}", null, len);
		#else
			return new NativeFloat32Array(len);
		#end
	}
	*/
	
	
	/**
		Returns the value in `src` at `index`.
	**/
	#if !(assert == "extra")
	inline
	#end
	public static function get<T>(src:NativeInt32Array, index:Int):Int
	{
		#if (assert == "extra")
		assert(index >= 0 && index < size(src), 'index $index out of range ${size(src)}');
		#end
		
		return
		#if (cpp && generic)
		cpp.NativeInt32Array.unsafeGet(src, index);
		#elseif python
		python.internal.ArrayImpl.unsafeGet(src, index);
		#else
		src[index];
		#end
	}
	
	/**
		Sets the value in `src` at `index` to `val`.
	**/
	#if !(assert == "extra")
	inline
	#end
	public static function setD<T>(dst:NativeInt32Array, index:Int, val:Int)
	{
		#if (assert == "extra")
		assert(index >= 0 && index < size(dst), 'index $index out of range ${size(dst)}');
		#end
		
		#if (cpp && generic)
		cpp.NativeInt32Array.unsafesetD(dst, index, val);
		#elseif python
		python.internal.ArrayImpl.unsafesetD(dst, index, val);
		#else
		dst[index] = val;
		#end
	}
	
	/**
		Returns the number of values in `a`.
	**/
	public static inline function size<T>(a:NativeInt32Array):Int
	{
		return
		#if neko
		untyped __dollar__asize(a);
		#elseif cs
		a.length;
		#elseif java
		a.length;
		#elseif python
		a.length;
		#elseif cpp
		a.length;
		#else
		a.length;
		#end
	}
	
	/**
		Copies `n` elements from `src` beginning at `first` to `dst` and returns `dst`.
	**/
	public static function toArray<T>(src:NativeInt32Array, first:Int, len:Int, dst:Array<Int>):Array<Int>
	{
		assert(first >= 0 && first < size(src), "first index out of range");
		assert(len >= 0 && first + len <= size(src), "len out of range");
		
		#if (cpp || python)
		if (first == 0 && len == size(src)) return src.copy();
		#end
		
		if (len == 0) return [];
		var out = ArrayTools.alloc(len);
		if (first == 0)
		{
			for (i in 0...len) out[i] = get(src, i);
		}
		else
		{
			for (i in first...first + len) out[i - first] = get(src, i);
		}
		return out;
	}
	
	/**
		Returns a `NativeInt32Array` object from the values stored in `src`.
	**/
	public static inline function ofArray<T>(src:Array<Int>):NativeInt32Array
	{
		#if (python || cs)
		return cast src.copy();
		#elseif flash10
			return
			#if (generic && !no_inline)
			flash.Vector.ofArray(src);
			#else
			src.copy();
			#end
		/*
		#elseif js
		return src.slice(0, src.length);
		*/
		#else
		var out = alloc(src.length);
		for (i in 0...src.length) setD(out, i, src[i]);
		return out;
		#end
	}
	
	/**
		Copies `n` elements from `src`, beginning at `srcPos` to `dst`, beginning at `dstPos`.
		
		Copying takes place as if an intermediate buffer was used, allowing the destination and source to overlap.
	**/
	#if (cs || java || neko || cpp)
	inline
	#end
	public static function blit<T>(src:NativeInt32Array, srcPos:Int, dst:NativeInt32Array, dstPos:Int, n:Int)
	{
		if (n > 0)
		{
			assert(srcPos < size(src), "srcPos out of range");
			assert(dstPos < size(dst), "dstPos out of range");
			assert(srcPos + n <= size(src) && dstPos + n <= size(dst), "n out of range");
			
			#if neko
			untyped __dollar__ablit(dst, dstPos, src, srcPos, n);
			#elseif cpp
			cpp.NativeInt32Array.blit(dst, dstPos, src, srcPos, n);
			#else
			if (src == dst)
			{
				if (srcPos < dstPos)
				{
					var i = srcPos + n;
					var j = dstPos + n;
					for (k in 0...n)
					{
						i--;
						j--;
						setD(src, j, get(src, i));
					}
				}
				else
				if (srcPos > dstPos)
				{
					var i = srcPos;
					var j = dstPos;
					for (k in 0...n)
					{
						setD(src, j, get(src, i));
						i++;
						j++;
					}
				}
			}
			else
			{
				if (srcPos == 0 && dstPos == 0)
				{
					for (i in 0...n) dst[i] = src[i];
				}
				else
				if (srcPos == 0)
				{
					for (i in 0...n) dst[dstPos + i] = src[i];
				}
				else
				if (dstPos == 0)
				{
					for (i in 0...n) dst[i] = src[srcPos + i];
				}
				else
				{
					for (i in 0...n) dst[dstPos + i] = src[srcPos + i];
				}
			}
			#end
		}
	}
	
	/**
		Returns a shallow copy of `src`.
	**/
	inline public static function copy<T>(src:NativeInt32Array):NativeInt32Array
	{
		#if (neko || cpp)
		var len = size(src);
		var out = alloc(len);
		blit(src, 0, out, 0, len);
		return out;
		#elseif flash
		return src.slice(0);
		/*
		#elseif js
		return src.slice(0);
		*/
		#elseif python
		return src.copy();
		#else
		var len = size(src);
		var dst = alloc(len);
		for (i in 0...len) setD(dst, i, get(src, i));
		return dst;
		#end
	}
	
	/**
		Sets `n` elements in `dst` to 0 starting at index `first` and returns `dst`.
		If `n` is 0, `n` is set to the length of `dst`.
	**/
	#if (flash || java)
	inline
	#end
	public static function zero<T>(dst:NativeInt32Array, first:Int = 0, n:Int = 0):NativeInt32Array
	{
		var min = first;
		var max = n <= 0 ? size(dst) : min + n;
		
		assert(min >= 0 && min < size(dst));
		assert(max <= size(dst));
		
		#if cpp
		cpp.NativeInt32Array.zero(dst, min, max - min);
		#else
		var val:Int = 0;
		while (min < max) setD(dst, min++, cast val);
		#end
		
		return dst;
	};
	
	/**
		Sets `n` elements in `a` to `val` starting at index `first` and returns `a`.
		If `n` is 0, `n` is set to the length of `a`.
	**/
	public static function init<T>(a:NativeInt32Array, val:Int, first:Int = 0, n:Int = 0):NativeInt32Array
	{
		var min = first;
		var max = n <= 0 ? size(a) : min + n;
		
		assert(min >= 0 && min < size(a));
		assert(max <= size(a));
		
		while (min < max) setD(a, min++, val);
		return a;
	}
	
	/**
		Nullifies `n` elements in `a` starting at index `first` and returns `a`.
		If `n` is 0, `n` is set to the length of `a`.
	**/
	public static function nullify<T>(a:NativeInt32Array, first:Int = 0, n:Int = 0):NativeInt32Array
	{
		var min = first;
		var max = n <= 0 ? size(a) : min + n;
		
		assert(min >= 0 && min < size(a));
		assert(max <= size(a));
		
		#if cpp
		cpp.NativeInt32Array.zero(a, min, max - min);
		#else
		while (min < max) setD(a, min++, cast null);
		#end
		
		return a;
	}
	
	/**
		Searches the sorted array `a` for `val` in the range [`min`, `max`] using the binary search algorithm.
		
		@return the array index storing `val` or the bitwise complement (~) of the index where `val` would be inserted (guaranteed to be a negative number).
		<br/>The insertion point is only valid for `min` = 0 and `max` = `a.length` - 1.
	**/
	public static function binarySearchCmp<T>(a:NativeInt32Array, val:Int, min:Int, max:Int, cmp:Int->Int->Int):Int
	{
		assert(a != null);
		assert(cmp != null);
		assert(min >= 0 && min < size(a));
		assert(max < size(a));
		
		var l = min, m, h = max + 1;
		while (l < h)
		{
			m = l + ((h - l) >> 1);
			if (cmp(get(a, m), val) < 0)
				l = m + 1;
			else
				h = m;
		}
		
		if ((l <= max) && cmp(get(a, l), val) == 0)
			return l;
		else
			return ~l;
	}
	

	
	/**
		Searches the sorted array `a` for `val` in the range [`min`, `max`] using the binary search algorithm.
		@return the array index storing `val` or the bitwise complement (~) of the index where `val` would be inserted (guaranteed to be a negative number).
		<br/>The insertion point is only valid for `min` = 0 and `max` = `a.length` - 1.
	**/
	public static function binarySearchi(a:NativeInt32Array, val:Int, min:Int, max:Int):Int
	{
		assert(a != null);
		assert(min >= 0 && min < size(a));
		assert(max < size(a));
		
		var l = min, m, h = max + 1;
		while (l < h)
		{
			m = l + ((h - l) >> 1);
			if (get(a, m) < val)
				l = m + 1;
			else
				h = m;
		}
		
		if ((l <= max) && (get(a, l) == val))
			return l;
		else
			return ~l;
	}
}