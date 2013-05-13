package components;

/**
 * ...
 * @author Glenn Ko
 */



class BitVector 
{
	
	private var vect:Array<Int>;
		
		public function new(size:Int, filled:Bool) 
		{
			size = Math.ceil(size / 31);
			vect = new Array<Int>();
			var val:Int  = filled ? 1 : 0;
			for (i in 0...size) {
				vect[i] = val;
			}
		}
		
	
		
		public function setFlagAt(frame:Int, val:Bool):Void {
			if (val) {
				vect[(frame >> 5)] |= (0x80000000 | (1 << (frame&31) ));
			}
			else {
				vect[(frame >> 5)] &=  ~(1 << (frame&31));
			}
		}
		
		public function getFlagAt(frame:Int):Bool {
			return ( vect[(frame >> 5)] & (1 << (frame&31)) ) != 0;
		}
		
		
		public function previewStream():String {
			var len:Int = vect.length * 31;
			var str:String = "";
			for (i in 0...len) {
				str += getFlagAt(i) ? "1" : "0";
			}
			return str;
		}
		
		private function get_length():Int 
		{
			return vect.length;
		}
		
		
	
}