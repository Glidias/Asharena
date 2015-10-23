package assets.fonts 
{
	import de.polygonal.gl.text.fonts.rondaseven.PFRondaSeven;
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class ConsoleFont extends Fontsheet
	{
		[Embed(source="../../../resources/fonts/console.png")]
		public static var FONT:Class;
		
		[Embed(source="../../../resources/fonts/console-bounds.bin", mimeType="application/octet-stream")]
		public static var BOUNDS:Class;
		
		
		
		public function ConsoleFont() 
		{
			
			fontV = new PFRondaSeven();
			
			var bytes:ByteArray = new BOUNDS();
			bytes.uncompress();
			init( new FONT().bitmapData, bytes, [0xFFFFEEAA, 0xFFFF4455, 0xFF00FF00, 0xFFFFFFFF]);  //
			
		}
		
	}

}