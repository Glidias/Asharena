package util 
{
	import alternativa.engine3d.core.Resource;
	import alternativa.engine3d.resources.BitmapTextureResource;
	import ash.signals.Signal1;
	import flash.display.BitmapData;
	import flash.display3D.Context3D;
	import flash.utils.describeType;
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class SpawnerBundle
	{
		public var ASSETS:Array;
		public var onInitialized:Signal1 = new Signal1();
		
		public static var context3D:Context3D;
		static private var DUMMY_NORMAL:BitmapTextureResource;
		
		public function SpawnerBundle() 
		{	
			if (ASSETS != null && ASSETS.length > 0) {  // check assets if need to load, if so, do not Call init and return!
				return;
			}
			init();
		}
		
		public function _doInit():void 
		{
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
			
			onInitialized.dispatch(this);
		}
		
		protected final function uploadResources(vec:Vector.<Resource>):void {
			var i:int = vec.length;
			while (--i > -1) {
				vec[i].upload(context3D);
			}
		}
		
		public static  function uploadResources(vec:Vector.<Resource>):void {
			var i:int = vec.length;
			while (--i > -1) {
				vec[i].upload(context3D);
			}
		}
		
	}

}