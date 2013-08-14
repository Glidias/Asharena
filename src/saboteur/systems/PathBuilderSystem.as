package saboteur.systems 
{
	import alternativa.engine3d.core.BoundBox;
	import alternativa.engine3d.core.Object3D;
	import ash.core.NodeList;
	import ash.core.System;
	import flash.geom.Vector3D;
	import saboteur.util.CardinalVectors;
	import alternativa.engine3d.core.Camera3D;
	import alternativa.engine3d.alternativa3d;
	import saboteur.util.GameBuilder3D;
	use namespace alternativa3d;
	
	/**
	 * THis is a system used for the client player to help build stuff along a path-building grid.
	 * 
	 * It can later support checking against other players' grids as well, if multiple grids are added later.
	 * @author Glenn Ko
	 */
	public class PathBuilderSystem extends System
	{
		private var camera:Camera3D;
		private var _lastGridBound:BoundBox;
	
		private var origin:Vector3D = new Vector3D();
		private var direction:Vector3D = new Vector3D();
		
		private var nodeList:NodeList;
		
		public var curBuildId:int = -1;
		
		public function PathBuilderSystem(camera:Camera3D) 
		{
			this.camera = camera;
			
			_lastGridBound = new BoundBox();
			_lastGridBound.maxX = -Number.MAX_VALUE;
			_lastGridBound.maxY = -Number.MAX_VALUE;
		}
		
		override public function update(time:Number):void {
			if (curBuildId < 0) return;
			
			var curBuild:PathBuildingNode = nodeList.head as PathBuildingNode;
			if (curBuild == null) return;
			
			var cardinal:CardinalVectors = curBuild.cardinalVectors;
			var builder:GameBuilder3D = curBuild.builder;
			
			var x:Number;
			var y:Number;
			var eastVal:Number;
			var northVal:Number;
			var eastOffset:int;
			var northOffset:int;
			// for now, we use camera position to determine current builder's location, so only case 111 should occur
			//if ( (camera._x < _lastGridBound.minX || camera._y < _lastGridBound.minY || camera._x > _lastGridBound.maxX || camera._y > _lastGridBound.maxY ) 

				// update world scene builder bounds according to camera position,  !important
				//builder.update
				
				// check with builder whether can potentially build across any adjacient tile, if cannot, hide building gizmo & return; /
				
				
				camera.calculateRay(origin, direction, camera.view._width * .5, camera.view._height * .5);
				// direction should be transformed to local rotated coordinate space of builder object3d if required...
				
				// camera position must be inside bound, or else camera ray must intersect bound, and if so, get ray exit position
			//	if ( !(camera._x < _lastGridBound.minX || camera._y < _lastGridBound.minY || camera._x > _lastGridBound.maxX || camera._y > _lastGridBound.maxY)   ) {
					// check if ray exit position lies within _lastGridBound's z altitude range (else return), but if so, check with builder if can build accross adjacient tile
					eastVal = direction.x * cardinal.east.x + direction.y * cardinal.east.y + direction.z * cardinal.east.z;
					northVal = direction.x * cardinal.north.x + direction.y * cardinal.north.y + direction.z * cardinal.north.z;
					
					if (direction.x > 0) {
						x = _lastGridBound.maxX - camera._x;
					}
					else {
						x = camera._x - _lastGridBound.minX;
					}
					x /= direction.x;
					if (direction.y > 0) {
						y = _lastGridBound.maxY - camera._y;
					}
					else {
						y = camera._y  - _lastGridBound.minY;
					}
					y /= direction.y;
					
					if (x < y) { 
						direction.scaleBy(x);
						eastOffset = eastVal < 0 ? -1 : 1;
						northOffset = 0;
					}
					else {
						direction.scaleBy(y);
						northOffset = northVal < 0 ? -1 : 1;
						eastOffset = 0;
					}
					origin.x += direction.x;
					origin.y += direction.y;
					origin.z += direction.z;
					if (origin.z < _lastGridBound.minZ || origin.z > _lastGridBound.maxZ) {
						// hide building gizmo
						return;
					}
					// check with builder whether can build or not or not.
					//builder.floor
					
					
					
			//	}
			//	else if (_lastGridBound.intersectRay(origin, direction)) {
			//		throw new Error("For now, this hsouldn't be the case 222 ");
			//	}
			//	else {
			//		throw new Error("For now, this hsouldn't be the case 333");
			//	}
				
					
			}
			
				
						public function calcBoundIntersection(point:Vector3D, origin:Vector3D, direction:Vector3D, minX:Number, minY:Number, minZ:Number, maxX:Number, maxY:Number, maxZ:Number):Number {

				
				if (origin.x >= minX && origin.x <= maxX && origin.y >= minY && origin.y <= maxY && origin.z >= minZ && origin.z <= maxZ) return 0;  // true
				
				if (origin.x < minX && direction.x <= 0) return -1;
				if (origin.x > maxX && direction.x >= 0) return -1;
				if (origin.y < minY && direction.y <= 0) return -1;
				if (origin.y > maxY && direction.y >= 0) return -1;
				if (origin.z < minZ && direction.z <= 0) return -1;
				if (origin.z > maxZ && direction.z >= 0) return -1;
				var a:Number;
				var b:Number;
				var c:Number;
				var d:Number;
				var threshold:Number = 0.000001;
				// Intersection of X and Y projection
				if (direction.x > threshold) {
					a = (minX - origin.x) / direction.x;
					b = (maxX - origin.x) / direction.x;
				} else if (direction.x < -threshold) {
					a = (maxX - origin.x) / direction.x;
					b = (minX - origin.x) / direction.x;
				} else {
					a = -1e+22;
					b = 1e+22;
				}
				if (direction.y > threshold) {
					c = (minY - origin.y) / direction.y;
					d = (maxY - origin.y) / direction.y;
				} else if (direction.y < -threshold) {
					c = (maxY - origin.y) / direction.y;
					d = (minY - origin.y) / direction.y;
				} else {
					c = -1e+22;
					d = 1e+22;
				}
				if (c >= b || d <= a) return -1;
				if (c < a) {
					if (d < b) b = d;
				} else {
					a = c;
					if (d < b) b = d;
				}
				// Intersection of XY and Z projections
				if (direction.z > threshold) {
					c = (minZ - origin.z) / direction.z;
					d = (maxZ - origin.z) / direction.z;
				} else if (direction.z < -threshold) {
					c = (maxZ - origin.z) / direction.z;
					d = (minZ - origin.z)  / direction.z;
				} else {
					c = -1e+22;
					d = 1e+22;
				}
				
				c = c > a ? c : a;  // added to ensure reference is correct!
				d = d < b ? d : b;
	
				if (c >= b || d <= a) return -1;
	 
				point.x = origin.x + direction.x * c;
				point.y = origin.y + direction.y * c;
				point.z = origin.z + direction.z * c;
				
				//if (c < 0) throw new Error("WRONG DIRECTION!");
				
				return c;
			}
		
			
	
	
		
	}

}
import alternativa.engine3d.core.Camera3D;
import ash.core.Node;
import ash.ObjectMap;
import components.Pos;
import saboteur.util.CardinalVectors;
import saboteur.util.GameBuilder3D;


class PathBuildingNode extends Node {
	public var builder:GameBuilder3D;
	public var cardinalVectors:CardinalVectors;
	//public var playerPos:Pos;

	private static var _components:ObjectMap;
	public static function _getComponents():ObjectMap {
		if(_components == null) {
				_components = new ash.ObjectMap();
				_components.set(GameBuilder3D, "builder");
				_components.set(CardinalVectors, "cardinalVectors");
				//_components.set(Camera3D, "camera");
			}
			return _components;
	}
	
};