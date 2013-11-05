package hashds.ds;

import flash.Vector;
import hashds.ds.Indexable;

/**
 * Wrapper for Vector to hold indexable instances, which allow for fast 0(1) performance pops/pop-backs,etc.
 * Also contains internal len value to keep track of the number of active instances, without having to resize the vector.
 * 
 * If you're iterating through a list that involves no removal or alteration of structure during iteration, 
 *  using this can be an alternative compared to DLMixList. Removal of nodes is O(1) constant.
 * 
 * @author Glidias
 */

class VectorIndex<T:Indexable> implements haxe.rtti.Generic 
{
	public var vec:Vector<T>;
	public var len:Int;

	public function new(len:Int=0, fixed:Bool=false) //, fillAmt:Int=0
	{
		vec = new Vector<T>(len, fixed);
		this.len = len;
	}
	
	inline public function push(item:T):Void {
		vec[len++] = item;
	}
	
	public function purge():Void {
		_purge();
	}
	public function purgeAndTruncate(fixed:Bool=false):Void {
		_purge(true, fixed);
	}
	
	inline public function _purge(truncateLength:Bool=false, fixed:Bool=false):Void {
		for (i in len...vec.length) {
			vec[i] = null;
		}
		if (truncateLength) {
			vec.fixed = false;
			vec.length = len;
			vec.fixed = fixed;
		}
	}
	
	public function remove(item:T):Void {
		if (item.index != --len) {   // pop-back case
			vec[item.index] = vec[len]; 
			vec[len].index = item.index;
			vec[len] = null;
			return;
		}
		// pop case
		vec[len] = null;
	}
	
	inline public function _remove(item:T):Void {
		if (item.index != --len) {   // pop-back case
			vec[item.index] = vec[len]; 
			vec[len].index = item.index;
			vec[len] = null;
		}
		else {  // pop case
			vec[len] = null;
		}
	}
	
	
	
}