package util.ds;

/**
 * ...
 * @author Glenn Ko
 */

class ArrayBuffer<T> implements haxe.rtti.Generic
{
	public var arr:Array<T>;
	public var i:Int;

	public function new() 
	{
		i = 0;
		arr = new Array<T>();
	}
	
	//public inline function pop():Void {
	//	i--;
	//}
	public inline function push(val:T):Void {
		arr[i++] = val;
	}
	public inline function reset():Void {
		i = 0;
	}
	
	
	
}