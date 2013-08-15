package saboteur.systems 
{
	import alternativa.engine3d.core.BoundBox;
	import alternativa.engine3d.core.Debug;
	import alternativa.engine3d.core.Object3D;
	import ash.core.Engine;
	import ash.core.NodeList;
	import ash.core.System;
	import ash.signals.Signal0;
	import ash.signals.Signal1;
	import flash.geom.Vector3D;
	import saboteur.util.CardinalVectors;
	import alternativa.engine3d.core.Camera3D;
	import alternativa.engine3d.alternativa3d;
	import saboteur.util.GameBuilder3D;
	import saboteur.util.SaboteurPathUtil;
	use namespace alternativa3d;
	
	/**
	 * THis is a system used for the client player to help build stuff along a path-building grid.
	 * 
	 * It can later support checking against other players' grids as well, if multiple grids are added later.
	 * @author Glenn Ko
	 */
	public class PathBuilderSystem extends System
	{
		public var buildDistRatio:Number =  .5;
		private var camera:Camera3D;

	
		private var origin:Vector3D = new Vector3D();
		private var direction:Vector3D = new Vector3D();
		
		private var nodeList:NodeList;
		
		private var curBuildId:int = 63; // -1;
		public function setBuildId(val:int):void  {
			curBuildId = val;
			validateVis();
			
		}
		
		private function validateVis():void 
		{
			if ( nodeList && nodeList.head) {
				(nodeList.head as PathBuildingNode).builder.value = curBuildId;
				if (curBuildId >= 0) (nodeList.head as PathBuildingNode).builder.setBlueprintIdVis(curBuildId)
				else (nodeList.head as PathBuildingNode).builder.setBlueprintVis(false);
			}
		}
		private var _lastResult:int = -999;
		private var camPos:Vector3D;
		
		//public var signalBuildableChange:Signal1 = new Signal1();
		
		public function PathBuilderSystem(camera:Camera3D) 
		{
			this.camera = camera;
			camPos  = new Vector3D();
			
			
		}
		
		override public function addToEngine(engine:Engine):void {
			nodeList = engine.getNodeList(PathBuildingNode);
			nodeList.nodeAdded.add( onNodeAdded);
			validateVis();
		}
		
		private function onNodeAdded(node:PathBuildingNode):void 
		{
			if (node === nodeList.head) validateVis();
			
			//camera.debug = true;
			//camera.addToDebug( Debug.BOUNDS, node.builder.blueprint);

			//camera.addToDebug( Debug.BOUNDS, node.builder.genesis);
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
			var southVal:Number;
			var eastOffset:int;
			var southOffset:int;
			
			// we assume camera in global coordiante space, later, we do a proper function for this!
				
			// for now, we use camera position to determine current builder's location, so only case 111 should occur
			//if ( (camPos._x < _lastGridBound.minX || camPos._y < _lastGridBound.minY || camPos._x > _lastGridBound.maxX || camPos._y > _lastGridBound.maxY ) 

				camPos.x = camera._x;
				camPos.y = camera._y;
				camPos.z = camera._z;
				
				eastVal = camPos.x * cardinal.east.x + camPos.y * cardinal.east.y + camPos.z * cardinal.east.z ;
				southVal = camPos.x * cardinal.south.x + camPos.y * cardinal.south.y + camPos.z * cardinal.south.z ;
				var ge:int = Math.round(eastVal * builder.gridEastWidth_i);
				var gs:int = Math.round(southVal * builder.gridSouthWidth_i);
				
				
				if (!builder.isOccupiedAt(ge, gs)) {
					builder.setBlueprintVis(false);
					return;
				}
				
				camera.calculateRay(origin, direction, camera.view._width * .5, camera.view._height * .5);
				
				var de:Number = direction.x * cardinal.east.x + direction.y * cardinal.east.y + direction.z * cardinal.east.z;
				var ds:Number = direction.x * cardinal.south.x + direction.y * cardinal.south.y + direction.z * cardinal.south.z;
				// direction should be transformed to local rotated coordinate space of builder object3d if required... ! important
			
					var xoff:Number = (eastVal+builder.gridEastWidth * .5) - ge*builder.gridEastWidth;  // integer modulus + floating point
					xoff *= builder.gridEastWidth_i;
					var yoff:Number = (southVal+builder.gridSouthWidth * .5) - gs*builder.gridSouthWidth;  // integer modulus + floating point
					yoff *= builder.gridSouthWidth_i;
	
				
				// camera position must be inside bound, or else camera ray must intersect bound, and if so, get ray exit position
			//	if ( !(camPos.x < camPos.minX || camPos._y < _lastGridBound.minY || camPos._x > _lastGridBound.maxX || camPos._y > _lastGridBound.maxY)   ) {
					
					var xt:Number;
					var yt:Number;
					
					if (de > 0) {

						xt= (1 - xoff) / de;
					}
					else if (de == 0) {
						xt = Number.MAX_VALUE;  // in case divide by zero infinity doesn't result in a "large" value
					}
					else {
						xt = -xoff / de;
			
					}
					
					if (ds > 0) {
						yt = (1 - yoff) / ds;
					}
					else if (ds == 0) {
						yt = Number.MAX_VALUE;  // in case divide by zero infinity doesn't result in a "large" value
					}
					else {
						yt = -yoff / ds;
					}
					
					if (yt < 0 || xt < 0) throw new Error("Should not be! Time should not be less than zero!");

					if (xt < yt) { 
						direction.scaleBy(xt*builder.gridEastWidth);
						eastOffset = de < 0 ? -1 : 1;
						southOffset = 0;
					}
					else {
						direction.scaleBy(yt*builder.gridSouthWidth);
						southOffset = ds < 0 ? -1 : 1;
						eastOffset = 0;
					}
					origin.x += direction.x;
					origin.y += direction.y;
					origin.z += direction.z;
					//if (origin.z < builder._gridSquareBound.minZ || origin.z > builder._gridSquareBound.maxZ) {
						// hide building gizmo
					
						//	builder.setBlueprintVis(false);

						//	return;
					//}
					var vec:Vector3D = xt < yt ? cardinal.east : cardinal.south;
					
					builder.setBlueprintVis(true);
					
					var result:int;
					if ( Math.abs(vec.dotProduct(direction)) > (xt < yt ? builder.gridEastWidth : builder.gridSouthWidth ) * buildDistRatio  ) {
						builder.updateFloorPosition(ge+eastOffset, gs+southOffset);
						builder.editorMat.color = GameBuilder3D.COLOR_OUTSIDE;
						_lastResult = SaboteurPathUtil.RESULT_OUT;
						if (result != _lastResult) {
							_lastResult = result;
							//signalBuildableChange.dispatch(result);
						}
						
						return;
					}
					
					
					result= builder.updateFloorPosition(ge+eastOffset, gs+southOffset);
					if (result != _lastResult) {
						_lastResult = result;
						//signalBuildableChange.dispatch(result);
					}
				
					
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
			
			public function get lastResult():int 
			{
				return _lastResult;
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
}