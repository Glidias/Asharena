package alternativa.a3d.systems.radar 
{
	import alternativa.engine3d.core.Camera3D;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.objects.Sprite3D;
	import ash.core.System;
	import components.Pos;
	import components.Rot;
	import alternativa.engine3d.alternativa3d;
	import flash.geom.Point;
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
		private var gridWidthH:Number = 16;
		private var gridHeightH:Number =16;
		private var gridPx:Number = 1/32;
		private var gridPy:Number = 1 / 32;
		
	
		
		public function setGridPixels(width:Number, height:Number):void {
			gridPx=1 / width;
			gridPy = 1 / height;
			gridWidthH = width*.5;
			gridHeightH = height*.5;
		}
		
		public function RadarMinimapSystem(worldToMiniScale:Number, rotateMap:Object3D=null, rot:Rot=null, rotObj:Object3D=null, posMap:Object3D=null, pos:Pos=null, posObj:Object3D=null, gridCoordinates:Rectangle=null, gridPixels:Point=null) 
		{
			this.worldToMiniScale = worldToMiniScale;
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
			
			var px:Number;
			var py:Number;
			if (gridCoordinates != null) {
				if (pos != null) {
				//	gridCoordinates.x
					px = (pos.x  * worldToMiniScale - gridWidthH) * gridPx;
					py = (pos.y * -worldToMiniScale - gridHeightH )* gridPy;
					px -= int(px);
					py -= int(py);
					gridCoordinates.x = px;
					gridCoordinates.y = py;
				}
				else if (posObj != null) {
					
					px = (posObj._x  * worldToMiniScale - gridWidthH) * gridPx;
					py = (posObj._y * -worldToMiniScale - gridHeightH )* gridPy;
					px -= int(px);
					py -= int(py);
					gridCoordinates.x = px;
					gridCoordinates.y = py;
				}
			}
		}
		
	}

}

import alternativa.engine3d.core.Object3D;
import alternativa.engine3d.objects.Sprite3D;
import ash.ClassMap;
import components.Pos;
import components.Rot;
import alternativa.a3d.systems.radar.RadarComponent;

class BlipNode {
	public var pos:Pos;
	public var rad:RadarComponent;
	
	public function BlipNode() {
		
	}
	
	private static var _components:ClassMap;
	
	public static function _getComponents():ClassMap {
		if(_components == null) {
				_components = new ClassMap();
				_components.set(Pos, "pos");
				_components.set(RadarComponent, "rad");
			
		}
			return _components;
	}
}

