package alternativa.a3d.systems.radar 
{
	import alternativa.engine3d.core.Camera3D;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.objects.Sprite3D;
	import ash.core.System;
	import components.Rot;
	import alternativa.engine3d.alternativa3d;
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
		
		public function RadarMinimapSystem(rotateMap:Object3D=null, rot:Rot=null, rotObj:Object3D=null) 
		{
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
		}
		
	}

}
import alternativa.engine3d.core.Object3D;
import alternativa.engine3d.objects.Sprite3D;
import components.Pos;
import components.Rot;

class BlipNode {
	
}

