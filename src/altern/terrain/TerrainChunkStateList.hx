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
	
	
	public function getAvailable():TerrainChunkState { // dequeue from head (FIFO queue)
				var entity:TerrainChunkState = head;

				if (entity == null) {
					
					return null;
				}

				
				head = head.next;
				if (head!=null) {
					head.prev = null;
			
				}
				
				if ( tail	== entity) tail = null;
				
			
				
				//if (entity.next) entity.next.prev =  null;
				entity.next = null;
				entity.parent = null;
			//	validate("");
				
				return entity;
			}

			public function remove( entity : TerrainChunkState ) : Void
			{
				

				
				if ( head == entity)
				{
				head = head.next;
				}
				if ( tail == entity)
				{
				tail = tail.prev;
				}

				if (entity.prev!=null)
				{
				entity.prev.next = entity.next;
				}

				if (entity.next!=null)
				{
				entity.next.prev = entity.prev;
				}
				entity.parent = null;
				entity.next = null;
				entity.prev = null;
				
		
				//validate("")
				// N.B. Don't set node.next and node.prev to null because that will break the list iteration if node is the current node in the iteration.
			}

			public function removeAll() : Void
			{
				while( head!=null )
				{
					var entity : TerrainChunkState = head;
					head = head.next;
					entity.prev = null;
					entity.next = null;
					entity.parent = null;
				}
				tail = null;
			}
	
}