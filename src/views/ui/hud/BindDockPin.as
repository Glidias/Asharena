package views.ui.hud 
{
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.alternativa3d;
	use namespace alternativa3d;
	/**
	 * Pin toa  corner
	 * @author Glenn Ko
	 */
	public class BindDockPin 
	{
		private var horizontalOffset:int;
		private var verticalOffset:int;
		private var obj:Object3D;
		public static const LEFT:int = -1;
		public static const CENTER:int = 0;
		public static const RIGHT:int = 1;
		
		public static const TOP:int = -1;
		public static const BOTTOM:int = 1;
		
		public var minCenterX:Number = 0;
		public var minCenterY:Number = 0;

		
		
		public function BindDockPin(obj:Object3D, verticalOffset:int, horizontalOffset:int) 
		{
			this.obj = obj;
			this.verticalOffset = verticalOffset;
			this.horizontalOffset = horizontalOffset;
			
		}
		
		public function update(centerX:Number, centerY:Number):void {
			centerX = centerX < minCenterX ? minCenterX+(minCenterX-centerX) : centerX;
			centerY = centerY < minCenterY ? minCenterY+(minCenterY-centerY) : centerY;
			obj._x = centerX * horizontalOffset;
			obj._y = centerY * verticalOffset;
			obj.transformChanged = true;
		}
		
	}

}