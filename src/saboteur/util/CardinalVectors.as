package saboteur.util 
{
import alternativa.engine3d.core.BoundBox;
import alternativa.engine3d.core.Object3D;
import flash.geom.Vector3D;
import flash.utils.Dictionary;

public class CardinalVectors {
	public var east:Vector3D = new Vector3D(0, -1, 0);
	public var north:Vector3D = new Vector3D(1,0, 0);
	public var west:Vector3D = new Vector3D(0, 1, 0);
	public var south:Vector3D = new Vector3D( -1, 0, 0);
	
	public function CardinalVectors() {
		
	}
	
	public function transform(vec:Vector3D, obj:Object3D, distance:Number):void {
		obj.x += vec.x * distance;
		obj.y += vec.y * distance;
		obj.z += vec.z * distance;
	}
	
	public function set(vec:Vector3D, obj:Object3D, distance:Number):void {
		obj.x = vec.x * distance;
		obj.y = vec.y * distance;
		obj.z = vec.z * distance;
	}
	
	public function getDist(vec:Vector3D, boundBox:BoundBox, numGridSquares:uint=1, scaler:Number=2):Number {
		var val:Number =  (boundBox.maxX * vec.x +  boundBox.maxY * vec.y +   boundBox.maxZ * vec.z);
		val = val < 0 ? -val : val;
		val *= numGridSquares;
		val *= scaler;
		return val;
	}
	
}

}