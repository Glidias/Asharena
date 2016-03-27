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
	
	public function setupEastSouth(e:Vector3D, s:Vector3D):void {
		east.x = e.x;
		east.y = e.y;
		east.z = e.z;
		
		south.x = s.x;
		south.y = s.y;
		south.z = s.z;
		
		west.x = -e.x;
		west.y = -e.y;
		west.z = -e.z;
		
		north.x = -s.x;
		north.y = -s.y;
		north.z = -s.z;
	}
	
	public function clone():CardinalVectors {
		var me:CardinalVectors = new CardinalVectors();
		me.east  = east.clone();
		me.north = north.clone();
		me.west = west.clone();
		me.south = south.clone();
		return me;
	}
	
	
	
	public function transform(vec:Vector3D, obj:Object3D, distance:Number):void {
		obj.x += vec.x * distance;
		obj.y += vec.y * distance;
		obj.z += vec.z * distance;
	}
	
	public function transformPos(vec:Vector3D, obj:Vector3D, distance:Number):void {
		obj.x += vec.x * distance;
		obj.y += vec.y * distance;
		obj.z += vec.z * distance;
	}
	
	public function set(vec:Vector3D, obj:Object3D, distance:Number):void {
		obj.x = vec.x * distance;
		obj.y = vec.y * distance;
		obj.z = vec.z * distance;
	}
	
	
	public function setPos(vec:Vector3D, obj:Vector3D, distance:Number):void {
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
	
	public function syncNorthWest():void 
	{
		west.x = -east.x;
		west.y = -east.y;
		west.z = -east.z;
		
		north.x = -south.x;
		north.y = -south.y;
		north.z = -south.z;
	}
	
}

}