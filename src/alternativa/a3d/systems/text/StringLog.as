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
		
		public function StringLog() 
		{
			
		}
		
		/**
		 * Prepends string to list
		 * @param	str
		 */
		public function add(str:String):void 
		{
			nodeList.add( new StringNode(str) );
		}
		
		
	}

}