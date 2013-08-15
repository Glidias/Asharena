package saboteur.spawners 
{
	import flash.display.Sprite;
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class JettyAssets extends Sprite
	{	
		[Embed(source = "../../../bin/assets/models/jetty/layout-jetty.a3d", mimeType = "application/octet-stream")]
		public static var $_MODEL:Class;
		
		[Embed(source="../../../bin/assets/models/jetty/001.jpg")]
		public  static var $_TEXTURE:Class;
		
		public function JettyAssets() 
		{
			
		
		}
		
	}

}