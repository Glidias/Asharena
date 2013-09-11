package alternativa.a3d.systems.radar 
{
	import alternativa.engine3d.core.Camera3D;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.objects.Sprite3D;
	import ash.core.System;
	import components.Pos;
	import components.Rot;
	import alternativa.engine3d.alternativa3d;
	import flash.geom.Rectangle;
	use namespace alternativa3d;
	
	/**
	 * ...
	 * @author Glidias
	 */
	public class RadarMinimapSystem extends System
	{
		private var rotateMap:Object3D;
		private var rot:Rot;
		private var rotObj:Object3D;
		private var pos:Pos;
		
		public var worldToMiniScale:Number = 1;
		
		private var posObj:Object3D;
		private var posMap:Object3D;
		private var gridCoordinates:Rectangle;
		
		public function RadarMinimapSystem(rotateMap:Object3D=null, rot:Rot=null, rotObj:Object3D=null, posMap:Object3D=null, pos:Pos=null, posObj:Object3D=null, gridCoordinates:Rectangle=null) 
		{
			this.gridCoordinates = gridCoordinates;
			this.posMap = posMap;
			this.posObj = posObj;
			this.pos = pos;
			this.rotObj = rotObj;
			this.rot = rot;
			this.rotateMap = rotateMap;

		}
		override public function update(time:Number):void {
			if (rot != null) {
				rotateMap._rotationZ =rot.z;
				rotateMap.transformChanged = true;
			}
			else if (rotObj != null) {
				rotateMap._rotationZ = rotObj._z;
				rotateMap.transformChanged = true;
			}
			
			if (pos != null) {
				posMap._x = -pos.x * worldToMiniScale;
				posMap._y = -pos.y * worldToMiniScale;
				posMap.transformChanged = true;
			}
			else if (posObj != null) {
				posMap._x = -rotObj._x * worldToMiniScale;
				posMap._y = -rotObj._y * worldToMiniScale;
				posMap.transformChanged = true;
			}
			
			
			if (gridCoordinates != null) {
				
			}
		}
		
	}

}

import alternativa.engine3d.core.Object3D;
import alternativa.engine3d.objects.Sprite3D;
import components.Pos;
import components.Rot;

class BlipNode {
	
}

