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
	import components.DirectionVectors;
	import components.Pos;
	import flash.geom.Vector3D;
	import saboteur.util.CardinalVectors;
	import alternativa.engine3d.core.Camera3D;
	import alternativa.engine3d.alternativa3d;
	import saboteur.util.GameBuilder3D;
	import saboteur.util.SaboteurPathUtil;
	use namespace alternativa3d;
	
	/**
	 * This is a system used for the client player (head node) to help build 3d stuff along a 2d path-building grid
	 * that can be cardinally-rotated and offsetted.
	 * 
	 * It can later support checking against other players' grids as well (subsequent nodes), if multiple grids are added later.
	 * 
	 * It supports some optional components that work with Alternativa3D's camera for the head node builder.
	 * fromPos(Pos),  fromDirection(DirectionVectors)
	 * 
	 * If only fromPos is provided (no camera or fromDirection), than we treat fromPos as the intended build position, with no raycasting.
	 * If only the camera is provided, than ray is casted through camera's screen's center position.
	 * If both fromPos and fromDirection is provided, than camera reference doesn't need to be provided at all, and ray is casted with fromPos/fromDirection to determine build position.
	 * If camera is provided with fromPos (without fromDirection), than ray is casted from camera position along through fromPos
	 * If camera is provided with fromDirection (without fromPos), it is assumed the fromDirection.forward already stores the intended ray direction vector from the camera position.
	 * 
	 * @author Glenn Ko
	 */
	public class PathBuilderSystem extends System
	{
		/**
		 * Build distance ratio in relation to current grid east/south width to indicate how near to edge required
		 * before allowed to build. Lower ratios indiciate nearer to edge required.
		 */
		public var buildDistRatio:Number =  .5;
		
		private var curBuildId:int = 63; // -1;
		public function setBuildId(val:int):void  {
			curBuildId = val;
			validateVis();
		}
		public function getCurBuildID():int {
			return curBuildId;
		}
		
		public function setBuildIndex(index:uint):void {
			setBuildId(  SaboteurPathUtil.getInstance().getValueByIndex(index) );
		}
		
		private var camera:Camera3D;
		private var fromPos:Pos;
		private var fromDirection:DirectionVectors;
	
		private var origin:Vector3D = new Vector3D();
		private var direction:Vector3D = new Vector3D();
		
		private var nodeList:NodeList;
		

		
		private function validateVis():void 
		{
			if ( nodeList && nodeList.head) {
				fromPos = (nodeList.head as PathBuildingNode).entity.get(Pos) as Pos;
				fromDirection = (nodeList.head as PathBuildingNode).entity.get(DirectionVectors) as DirectionVectors;
				(nodeList.head as PathBuildingNode).builder.value = curBuildId;
				if (curBuildId >= 0) (nodeList.head as PathBuildingNode).builder.setBlueprintIdVis(curBuildId)
				else (nodeList.head as PathBuildingNode).builder.setBlueprintVis(false);
			}
		}
		private var _lastResult:int = -999;
		//private var camPos:Vector3D;
		
		public var signalBuildableChange:Signal1 = new Signal1();
		
		public function PathBuilderSystem(camera:Camera3D=null) 
		{
			this.camera = camera;
		//	camPos  = new Vector3D();
			
			
		}
		public function attemptDel():void 
		{
			var head:PathBuildingNode = nodeList.head as PathBuildingNode;
			if (head == null) return;
			if (_lastResult === SaboteurPathUtil.RESULT_OCCUPIED) head.builder.attemptRemove();
		}
			
		public function attemptBuild():void {
			var head:PathBuildingNode = nodeList.head as PathBuildingNode;
			if (head == null) return;
			if (_lastResult != SaboteurPathUtil.RESULT_VALID) return;
			head.builder.attemptBuild();
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
			
			var eastVal:Number;
			var southVal:Number;
			var eastOffset:int;
			var southOffset:int;

					
					
				var ge:int;
				var gs:int;
				
				if (fromPos != null) {
					origin.x = fromPos.x - builder.startScene._x;
					origin.y = fromPos.y - builder.startScene._y;
					origin.z = fromPos.z - builder.startScene._z;
					origin.x /= builder.startScene._scaleX;
					origin.y /= builder.startScene._scaleY;
					origin.z /= builder.startScene._scaleZ;
					
					eastVal = origin.x * cardinal.east.x + origin.y * cardinal.east.y + origin.z * cardinal.east.z ;
					southVal = origin.x * cardinal.south.x + origin.y * cardinal.south.y + origin.z * cardinal.south.z ;
					
					if (camera == null && fromDirection == null) {
						// resolve now (consider using floor instead of round, or hiding vis if occupied)
						ge = Math.round(eastVal * builder.gridEastWidth_i);
						gs = Math.round(southVal * builder.gridSouthWidth_i);
						builder.setBlueprintVis(true);
						builder.updateFloorPosition(ge, gs);
						return;
					}
					ge = Math.round(eastVal * builder.gridEastWidth_i);
					gs = Math.round(southVal * builder.gridSouthWidth_i);
				}
				else if (camera != null) {
					origin.x = camera._x - builder.startScene._x;
					origin.y = camera._y - builder.startScene._y;
					origin.z = camera._z - builder.startScene._z;
					origin.x /= builder.startScene._scaleX;
					origin.y /= builder.startScene._scaleY;
					origin.z /= builder.startScene._scaleZ;
					
					eastVal = origin.x * cardinal.east.x + origin.y * cardinal.east.y + origin.z * cardinal.east.z;
					southVal = origin.x * cardinal.south.x + origin.y * cardinal.south.y + origin.z * cardinal.south.z;
					
					ge =  Math.round(eastVal * builder.gridEastWidth_i);
					gs =  Math.round(southVal * builder.gridSouthWidth_i);
				}
				else {  // without camera, need at least a fromPos
					throw new Error("Need at least fromPos or camera to continue!");
				}
				
	
				if (!builder.isOccupiedAt(ge, gs)) {  // where builder is located (gridEast2/gridSouth2)
					builder.setBlueprintVis(false);
					return;
				}
				
				if (fromDirection == null) {
					if (fromPos == null) {
						camera.calculateRay(origin, direction, camera.view._width * .5, camera.view._height * .5);
					}
					else {
						direction.x = camera._x- builder.startScene._x - origin.x ;
						direction.y = camera._y -builder.startScene._y- origin.y ;
						direction.z = camera._z -builder.startScene._z- origin.z ;
						direction.normalize();
					}
				}
				else {
					direction.x = fromDirection.forward.x;
					direction.y = fromDirection.forward.y;
					direction.z = fromDirection.forward.z;
				}
				
			
				// Start raycasting from current grid position (direction along east and south axes)
				var de:Number = direction.x * cardinal.east.x + direction.y * cardinal.east.y + direction.z * cardinal.east.z;
				var ds:Number = direction.x * cardinal.south.x + direction.y * cardinal.south.y + direction.z * cardinal.south.z;
					var xoff:Number = (eastVal+builder.gridEastWidth * .5) - ge*builder.gridEastWidth;  // integer modulus + floating point
					xoff *= builder.gridEastWidth_i;
					var yoff:Number = (southVal+builder.gridSouthWidth * .5) - gs*builder.gridSouthWidth;  // integer modulus + floating point
					yoff *= builder.gridSouthWidth_i;
	
					
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
					// bound Z hit check if you wish to include it in
					//if (origin.z < builder._gridSquareBound.minZ || origin.z > builder._gridSquareBound.maxZ) {
						// hide building gizmo
						//	builder.setBlueprintVis(false)
						//	return;
					//}
					var vec:Vector3D = xt < yt ? cardinal.east : cardinal.south;
					
					builder.setBlueprintVis(true);
					
					var result:int;
					
					if ( Math.abs(vec.dotProduct(direction)) > (xt < yt ? builder.gridEastWidth : builder.gridSouthWidth ) * buildDistRatio  ) {
						result = builder.updateFloorPosition(ge + eastOffset, gs + southOffset);
						if (result === SaboteurPathUtil.RESULT_VALID) {
							builder.editorMat.color = GameBuilder3D.COLOR_OUTSIDE;
							result = SaboteurPathUtil.RESULT_OUT;
						}
						if (result != _lastResult) {
							_lastResult = result;
							signalBuildableChange.dispatch(result);
						}
						
						return;
					}
					
					ge += eastOffset;
					gs += southOffset;
					result = builder.updateFloorPosition(ge, gs);
					//if (ge === 0 && gs === 0) result = SaboteurPathUtil.RESULT_OUT;  // not allowed to bulid at genesis rule. 
					if (result != _lastResult) {
						_lastResult = result;
						signalBuildableChange.dispatch(result);
					}

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
	
	public function PathBuildingNode() {
		
	}

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