package spawners.arena 
{
	import flash.display.Sprite;
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class GladiatorialAnims extends Sprite
	{
		[Embed(source="../../../bin/assets/models/gladiators/animations.ani", mimeType="application/octet-stream")]
		public static var $_ANIMATIONS:Class;
		
		[Embed(source="../../../bin/assets/models/gladiators/anim-gladiator.xml", mimeType="application/octet-stream")]
		public static var ANIM_INFO:Class;
		
		public function GladiatorialAnims() 
		{
			
		}
		
	}

}