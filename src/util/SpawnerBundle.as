package util 
{
	import alternativa.engine3d.core.Resource;
	import ash.signals.Signal1;
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
		
		public function SpawnerBundle() 
		{
			COUNT++;
			// TODO: check for any ASSETS needed to load, before calling init
			
			
			init();
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