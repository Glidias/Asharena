package altern.terrain;

/**
 * ...
 * @author Glidias
 */
class TerrainChunkStateList 
{
	
	public var head : TerrainChunkState;
		public var tail : TerrainChunkState;
			
	public function append( entity : TerrainChunkState ) : Void  // enqueue
	{
			
		//try {
			entity.parent = this;
			if( head!=null )
			{
		
				tail.next = entity;
				entity.prev = tail;
				entity.next = null;
				tail = entity;
			}
			else
			{	
				head = tail = entity;
				entity.next = entity.prev = null;
			}
		//}
		//catch (e:Error) {
		//	throw new Error("WRW:"+e.message);
		//}
			validate("");
	}
	
	public function appendList( entity : TerrainChunkState, lastEntity:TerrainChunkState ) : Void  // enqueue
	{
			var e:TerrainChunkState = entity;
			while ( e != null ) {
				e.parent = this;
				e = e.next;
			}
			var e:TerrainChunkState = entity;
			while ( e != null) {
				
				e = e.next;
			}
		//try {
			//entity.parent = this;
			
			if( head!=null )
			{
		
				tail.next = entity;
				entity.prev = tail;
				
				tail = lastEntity;
			}
			else
			{	
				head  = entity;
				tail = lastEntity;
			}
			//validate("");
		//}
		//catch (e:Error) {
		//	throw new Error("WRW:"+e.message);
		//}
		
	}
	
	
	
	public function validate(msg:String):Void {
		if (head!=null && head.next == null && head != tail) throw ("WRONG: Head doesn't match tail when head.next is null" + msg + " : " + head + ", " + tail );
		if (head!=null && tail == null) throw ("WRONG2_headTail:" + msg + " : " + head + ", " + tail );
		if (head!=null && head == tail && head.next!=null) throw ("Both head tail is same but why got head.next??" );
	}

	public function new() 
	{
		
	}
	
}