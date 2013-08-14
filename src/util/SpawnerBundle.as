package util 
{
	import alternativa.engine3d.core.Resource;
	import ash.signals.Signal0;
	import flash.display3D.Context3D;
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class SpawnerBundle
	{
		public var ASSETS:*;
		public var onInitialized:Signal0 = new Signal0();
		
		public static var context3D:Context3D;
		
		public function SpawnerBundle() 
		{
			// TODO: check for any ASSETS needed to load, before calling init
			init();
		}
		
		public function init():void {
			ASSETS = null;
			onInitialized.dispatch();
			
		}
		
		protected final function uploadResources(vec:Vector.<Resource>):void {
			var i:int = vec.length;
			while (--i > -1) {
				vec[i].upload(context3D);
			}
		}
		
	}

}