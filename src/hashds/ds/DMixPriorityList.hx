package hashds.ds;
/**
 * RichardLord's implementation of a doubly-linked priortizable list. 
 * Priority sorting is using insertion sort approach ( i think..). 
 * 
 * @see hashds.ds.IDLMixNode
 * @author Glidias
 */

class DMixPriorityList<T:(IDLMixNode<T>,IPrioritizable)> implements haxe.rtti.Generic 
{
	public var head:T;
	public var tail:T;

	public function new() 
	{
		
	}
	

	public function add( data : T ) : Void
	{
			if( head == null )
			{
				head = tail = data;
			}
			else
			{
				var node:T = tail;
				while( node!=null  )
				{
					if( node.priority <= data.priority )
					{
						break;
					}
					node = node.prev;
				}
				if( node == tail )
				{
					tail.next = data;
					data.prev = tail;
					tail = data;
				}
				else if( node == null )
				{
					data.next = head;
					head.prev = data;
					head = data;
				}
				else
				{
					data.next = node.next;
					data.prev = node;
					node.next.prev = data;
					node.next = data;
				}
			}
	}
	
	
	



	/**
	 * Removes a node from this list, assuming it actually belongs to this list.
	 * @param	node
	 */
	public function remove( node : T ) : Void
	{
		if ( head == node) head = head.next;
		if ( tail == node) tail = tail.prev;
	
		if (node.prev != null) node.prev.next = node.next;
		if (node.next != null) node.next.prev = node.prev;
	}
		

	public function removeAll() : Void
	{
		while( head!=null )
		{
			var node : T = head;
			head = node.next;
			

			node.prev = null;
			node.next = null;
		}
		tail = null;
	}
	
	/**
	 * In most cases, using this method would be fine to quickly null references, hopefully without memory leak.
	 */
	inline public function quickClear():Void {
		head = null;
		tail = null;
	}
	
		
	
}