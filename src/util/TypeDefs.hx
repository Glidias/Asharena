package util;


#if (flash9 || flash9doc  )
typedef Vector<T> = flash.Vector<T>
#else
typedef Vector<T> = Array<T>
typedef UInt = Int
#end



class TypeDefs {
	public static inline function createFloatVector(size:Int, fixed:Bool):Vector<Float> {
		#if (flash9 || flash9doc)
			return new Vector<Float>(size, fixed);
		#else
			var arr:Vector = new Vector<Float>();
			setVectorLen(arr, size, fixed ? 1 : 0);
			return arr;
		
		#end
	}
	
	public static inline function createIntVector(size:Int, fixed:Bool):Vector<Int> {
		#if (flash9 || flash9doc)
			return new Vector<Int>(size, fixed);
		#else
			var arr:Vector = new Vector<Float>();
			setVectorLen(arr, size, fixed ? 1 : 0);
			return arr;
		
		#end
	}
	public static inline function createUIntVector(size:UInt, fixed:Bool):Vector<UInt> {
		#if (flash9 || flash9doc)
			return new Vector<UInt>(size, fixed);
		#else
			var arr:Vector = new Vector<Float>();
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