package util 
{
	import alternativa.engine3d.core.Resource;
	import alternativa.engine3d.resources.BitmapTextureResource;
	import ash.signals.Signal1;
	import flash.display.BitmapData;
	import flash.display3D.Context3D;
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class SpawnerBundle
	{
		public var ASSETS:Array;
		public static const onInitialized:Signal1 = new Signal1();
		private static var COUNT:int = 0;
		public static function isLoading():Boolean {
			return COUNT > 0;
		}
		
		public static var context3D:Context3D;
		static private var DUMMY_NORMAL:BitmapTextureResource;
		
		public function SpawnerBundle() 
		{
			COUNT++;
			// TODO: check for any ASSETS needed to load, before calling init
			
			
			init();
		}
		
		protected static function getDummyNormalResource():BitmapTextureResource {
			return  (DUMMY_NORMAL || uploadRes(DUMMY_NORMAL = new BitmapTextureResource( new BitmapData(16, 16, false, 0x8080FF) )));
		}
		
		static private function uploadRes(res:BitmapTextureResource):BitmapTextureResource 
		{
			res.upload(context3D);
			return res;
		}
		
		protected function init():void {
			ASSETS = null;
			COUNT--;
			onInitialized.dispatch(this);
		}
		
		protected final function uploadResources(vec:Vector.<Resource>):void {
			var i:int = vec.length;
			while (--i > -1) {
				vec[i].upload(context3D);
			}
		}
		
	}

}