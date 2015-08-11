package arena.pathfinding;
import util.TypeDefs;

class IndexedPriorityQ {
	
	var keys :Vector<Float>;
	var data :Vector<Int>;
	
	
	public function new (n_keys:Vector<Float>) {
		
		keys = n_keys;
		data = new Vector<Int>();
	}
	
	public inline function insert (idx:Int) :Void {
		
		data[data.length] = idx;
		reorderUp();
	}
	
	public inline function pop () :Int {
		
		var rtn = data[0];
		data[0] = data[data.length-1];
		data.pop();
		reorderDown();
		return rtn;
	}
	
	//inline
	public function reorderUp () :Void {
		
		var a = data.length - 1;
		while (a > 0) {
			if (keys[data[a]] < keys[data[a-1]]) {
				var tmp:Int=data[a];
				data[a]=data[a-1];
				data[a-1]=tmp;
				a--;
			}
			else return;
		}
	}
		
	//inline
	public function reorderDown():Void {
		
		for (a in 0...data.length-1) {
			if (keys[data[a]] > keys[data[a+1]]) {
				var tmp = data[a];
				data[a] = data[a+1];
				data[a+1] = tmp;
			}
			else return;
		}
	}
	public inline function isEmpty () :Bool {
		return (data.length == 0);
	}
	
	public inline function clear():Void {
		TypeDefs.setVectorLen(data, 0);
	}
}