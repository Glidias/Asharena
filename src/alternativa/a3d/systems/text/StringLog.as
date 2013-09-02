package alternativa.a3d.systems.text 
{
	import ash.core.NodeList;
	
	/**
	 * Data stricture to keep track of messages and other utility methods to extract out message strings
	 * @author Glidias
	 */
	public class StringLog 
	{
		public var nodeList:NodeList = new NodeList();
		public var maxItems:int = int.MAX_VALUE;
		public var count:int = 0;
		public function StringLog() 
		{
			
		}
		
		/**
		 * Appends string to list, removing off head if maxItems exceeded
		 * @param	str
		 */
		public function add(str:String):StringNode 
		{
			var me:StringNode;
			nodeList.add( me = new StringNode(str) );
			count++;
			if (count > maxItems) {
				count = maxItems;
				nodeList.remove(nodeList.head);
			}
			return me;
		}
		
		/**
		 * Appends node to list, removing off head if maxItems exceeded
		 * @param	node
		 */
		public function addNode(node:StringNode):void 
		{
			nodeList.add( node );
			count++;
			if (count > maxItems) {
				count = maxItems;
				nodeList.remove(nodeList.head);
			}
		}
		
		
	}

}