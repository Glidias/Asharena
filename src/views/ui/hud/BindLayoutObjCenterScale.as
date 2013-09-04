package views.ui.hud 
{
	import alternativa.engine3d.alternativa3d;
	import alternativa.engine3d.core.Object3D;
	import de.polygonal.motor.geom.primitive.AABB2;
	use namespace alternativa3d;
	/**
	 * ...
	 * @author Glidias
	 */
	public class BindLayoutObjCenterScale 
	{
		private var aabb:AABB2;
		private var obj:Object3D;
		public var includeScale:Boolean;
		
		public function BindLayoutObjCenterScale(aabb:AABB2, obj:Object3D, includeScale:Boolean=true) 
		{
			this.obj = obj;
			this.aabb = aabb;
			this.includeScale = includeScale;
			
		}
		
		public function update(centerX:Number, centerY:Number):void {
			
			var x:Number = aabb.maxX - aabb.minX;
			var y:Number = aabb.maxY - aabb.minY;
			if (includeScale) {
				obj._scaleX = x;
				obj._scaleY = y;
			}
			
			x *= .5;
			y *= .5;
			x += aabb.minX;
			y += aabb.minY;
			x -= centerX;
			y -= centerY;
			obj._x = x;
			obj._y = y;
			
			obj.transformChanged = true;
		}
		
	}

}