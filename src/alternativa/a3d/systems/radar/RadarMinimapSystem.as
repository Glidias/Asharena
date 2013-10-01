package alternativa.a3d.systems.radar 
{
	import alternativa.engine3d.core.Camera3D;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.Transform3D;
	import alternativa.engine3d.objects.Sprite3D;
	import alternativa.engine3d.utils.Object3DTransformUtil;
	import ash.core.System;
	import components.Pos;
	import components.Rot;
	import alternativa.engine3d.alternativa3d;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
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
		public var gridRotObject:Object3D;
		private var gridObject:Object3D;
		private var gridObjectTransform:Transform3D;
		public function setGridObject(obj:Object3D):void {
			gridObject = obj;
			gridObjectTransform = Object3DTransformUtil.calculateGlobalToLocal2(gridObject);
		}
		
		
		public function setGridPixels(width:Number, height:Number):void {
			gridPx=1 / width;
			gridPy = 1 / height;
			gridWidthH = width*.5;
			gridHeightH = height*.5;
		}
		
		public function RadarMinimapSystem(worldToMiniScale:Number, rotateMap:Object3D=null, rot:Rot=null, rotObj:Object3D=null, posMap:Object3D=null, pos:Pos=null, posObj:Object3D=null, gridCoordinates:Rectangle=null, gridObject:Object3D= null, gridRotObject:Object3D=null) 
		{
			this.worldToMiniScale = worldToMiniScale;
			this.gridCoordinates = gridCoordinates;
			this.posMap = posMap;
			this.posObj = posObj;
			this.pos = pos;
			this.rotObj = rotObj;
			this.rot = rot;
			this.rotateMap = rotateMap;
			this.gridObject = gridObject || (new Object3D());
			gridObjectTransform = Object3DTransformUtil.calculateGlobalToLocal2(gridObject);
			
			this.gridRotObject = gridRotObject || (new Object3D());
			
			
		}
		
		
		override public function update(time:Number):void {
			var t:Transform3D;
			
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
					
					if (gridRotObject._rotationZ != gridObject._rotationZ) {
						gridRotObject._rotationZ = gridObject._rotationZ;
						gridRotObject.transformChanged = true;
					}
					
					if (gridRotObject._rotationZ == 0) {   
						px = pos.x;
						py = pos.y;
						px -= gridObject._x;
						py -= gridObject._y;
					}
					else {  // we need to translate position into local coordinate space of rotated grid
						if (gridRotObject.transformChanged) {
							Object3DTransformUtil.calculateGlobalToLocal2(gridObject, gridObjectTransform);
						}
						t = gridObjectTransform;
						px = t.a * pos.x + t.b * pos.y + t.c * pos.z + t.d;
						py = t.e * pos.x + t.f * pos.y + t.g * pos.z + t.h;
						px *= gridObject._scaleX;
						py *= gridObject._scaleX;		
					}
					
					
					px = ( px  * worldToMiniScale - gridWidthH) * gridPx;
					py = ( py * -worldToMiniScale - gridHeightH )* gridPy;
					px -= int(px);
					py -= int(py);
					gridCoordinates.x = px;
					gridCoordinates.y = py;
				}
				else if (posObj != null) {
					
					if (gridRotObject._rotationZ == 0) {   
						px = posObj._x;
						py = posObj._y;
						px -= gridObject._x;
						py -= gridObject._y;
					}
					else {  // we need to translate position into local coordinate space of rotated grid
						if (gridRotObject.transformChanged) {
							Object3DTransformUtil.calculateGlobalToLocal2(gridObject, gridObjectTransform);
						}
						t = gridObjectTransform;
						px = t.a * posObj._x + t.b * posObj._y + t.c * posObj._z + t.d;
						py = t.e * posObj._x + t.f * posObj._y + t.g * posObj._z + t.h;
						px *= gridObject._scaleX;
						py *= gridObject._scaleX;		
					}
					
					
					px = (px  * worldToMiniScale - gridWidthH) * gridPx;
					py = (py * -worldToMiniScale - gridHeightH )* gridPy;
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



