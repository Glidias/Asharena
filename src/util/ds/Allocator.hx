package util.ds;


/**
 * Fixed counter buffer allocator. For javascript and Flash targets only.
 * @author Glidias
 */

class Allocator<T> implements haxe.rtti.Generic
{
	private var _classe:Class<T>;
	private var _i:Int;
	private var _len:Int;
	private var _vec:Array<T>;
	public var fixed:Bool;

	/**
	 * 
	 * @param	classe		(Class) A class to instantiate 
	 * @param	fillAmount	(int)	 (Default 0) A value higher than 0 would pre-allocate the allocator with instances
	 * @param   initialCapacity	(int) (Default 0) Initial capacity of Vector buffer.
	 * @param	fillFixed	(Boolean) (Default false) Determines if the Vector buffer will be of fixed length.
	 */
	public function new(classe:Class<T>, fillAmount:Int=0, initialCapacity:Int=0, fixed:Bool=false) 
	{
		_classe = classe;
		_len = 0;
		this.fixed = fixed;
		_i = 0;
		_vec = new Array<T>(); //initialCapacity
		if (fillAmount > 0) fill(fillAmount, fixed);
	}
	
	inline public function get():T untyped { 
		return _i < _len  ? _vec[_i++] : (_vec[_len++] = __new__(_classe) );
	}
	
	inline public function _pop():Void {
		_i--;
	}
	
	inline public function reset():Void {
		_i = 0;
	}
	inline public function getSize():Int {
		return _len;
	}
	
	public function purge():Void {
		_purge();
	}
	public function purgeAndTruncate(fixed:Bool=false):Void {
		_purge(true, fixed);
	}
	
	inline public function _purge(truncateLength:Bool=false, fixed:Bool=false):Void {
		for (i in _i..._len) {
			_vec[i] = null;
		}
		if (truncateLength) {
			//_vec.fixed = false;
			untyped _vec.length = _i;
			_len = _i;
			//_vec.fixed = fixed;
		}
	}
	
	
	
	public function fill(amount:Int, fixed:Bool):Void {
		//_vec.fixed = false;
		untyped _vec.length = amount;
		_len = amount;
		
		while (--amount > -1) {
			if (_vec[amount] == null) _vec[amount] = untyped __new__(_classe);
		}
		//_vec.fixed = fixed;
	}
	
	public function setFixed(val:Bool):Void {
		//_vec.fixed = val;
		this.fixed = val;
	}
	public function getFixed():Bool {
		//return _vec.fixed;
		return this.fixed;
	}
		
	public function kill():Void {  
		fill(0, false);
		_i = 0;
	}
	
}