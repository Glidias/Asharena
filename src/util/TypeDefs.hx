package util;


#if (flash9 || flash9doc  )
typedef Vector<T> = flash.Vector<T>
typedef Vector3D = flash.geom.Vector3D
#else
typedef Vector<T> = Array<T>
typedef UInt = Int
typedef Vector3D = jeash.geom.Vector3D
#end



class TypeDefs {
	public static inline function createFloatVector(size:Int, fixed:Bool):Vector<Float> {
		#if (flash9 || flash9doc)
			return new Vector<Float>(size, fixed);
		#else
			var arr:Vector<Float> = new Vector<Float>();
			setVectorLen(arr, size, fixed ? 1 : 0);
			return arr;
		#end
	}
	
	public static inline function createIntVector(size:Int, fixed:Bool):Vector<Int> {
		#if (flash9 || flash9doc)
			return new Vector<Int>(size, fixed);
		#else
			var arr:Vector<Int> = new Vector<Int>();
			setVectorLen(arr, size, fixed ? 1 : 0);
			return arr;
		
		#end
	}
	public static inline function createUIntVector(size:UInt, fixed:Bool):Vector<UInt> {
		#if (flash9 || flash9doc)
			return new Vector<UInt>(size, fixed);
		#else
			var arr:Vector<UInt> = new Vector<UInt>();
			setVectorLen(arr, size, fixed ? 1 : 0);
			return arr;
		
		#end
	}
	
	public static inline function createVector<T>(size:UInt, fixed:Bool):Vector<T> {
		#if (flash9 || flash9doc)
			return new Vector<T>(size, fixed);
		#else
			var arr:Vector<T> = new Vector<T>();
			setVectorLen(arr, size, fixed ? 1 : 0);
			return arr;
		
		#end
	}
	
	public static inline function setVectorLen(vec:Dynamic,len:Int, setFixed:Int=-1):Void {
		#if (cpp||php)
			for (i in 0...6)) {
				vec[i] = 0;
			}
		#else
			untyped vec.length = len;
		#end
		
		#if (flash9 || flash9doc)
			if (setFixed >= 0) {
				vec.fixed = setFixed >= 1 ? true : false;
			}
		#end
	}
}