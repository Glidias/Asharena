package hashds.ds;

/**
*
* DMixList without signals
*
* @see hashds.ds.IDLMixNode
* @author Glidias
*/

class DLMixList<T:IDLMixNode<T>> implements haxe.rtti.Generic
{
        public var head:T;
        public var tail:T;
        

        public function new()
        {

        }
        

        public function append( node : T ) : Void
        {
                // we assume node is fresh and not part of any list
                if( head!=null )
                {
                        _append(node);
                }
                else
                {
                        head = node;
                        tail = node;
                }
                
        }
		
		 public function prepend( node : T ) : Void
        {
                // we assume node is fresh and not part of any list
                if( head!=null )
                {
                      _prepend(node);
                }
                else
                {
                     head = node;
                     tail = node;
                }
                
        }
        
        
        inline private function _append(node:T):Void {
                tail.next = node;
                node.prev = tail;
                tail = node;
        }
		
		 inline private function _prepend(node:T):Void {
				node.next = head;
				node.prev = null;
                head = node;
        }
        



        /**
         * Removes a node from this list, assuming it actually belongs to this list.
         * @param        node
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
        
                public function swap( node1 : T, node2 : T ) : Void
                {
                        if( node1.prev == node2 )
                        {
                                node1.prev = node2.prev;
                                node2.prev = node1;
                                node2.next = node1.next;
                                node1.next = node2;
                        }
                        else if( node2.prev == node1 )
                        {
                                node2.prev = node1.prev;
                                node1.prev = node2;
                                node1.next = node2.next;
                                node2.next = node1;
                        }
                        else
                        {
                                var temp : T = node1.prev;
                                node1.prev = node2.prev;
                                node2.prev = temp;
                                temp = node1.next;
                                node1.next = node2.next;
                                node2.next = temp;
                        }
                        if( head == node1 )
                        {
                                head = node2;
                        }
                        else if( head == node2 )
                        {
                                head = node1;
                        }
                        if( tail == node1 )
                        {
                                tail = node2;
                        }
                        else if( tail == node2 )
                        {
                                tail = node1;
                        }
                        if( node1.prev!=null )
                        {                                                        
                                node1.prev.next = node1;
                        }
                        if( node2.prev!=null )
                        {
                                node2.prev.next = node2;
                        }
                        if( node1.next!=null )
                        {
                                node1.next.prev = node1;
                        }
                        if( node2.next!=null )
                        {
                                node2.next.prev = node2;
                        }
                }
        
        
}