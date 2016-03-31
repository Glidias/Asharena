package saboteur.systems 
{
	import alternativa.a3d.collisions.CollisionBoundNode;
	import alternativa.engine3d.core.BoundBox;
	import alternativa.engine3d.core.Debug;
	import alternativa.engine3d.core.Object3D;
	import ash.core.Engine;
	import ash.core.NodeList;
	import ash.core.System;
	import ash.signals.Signal0;
	import ash.signals.Signal1;
	import ash.signals.Signal2;
	import ash.signals.Signal3;
	import ash.signals.SignalAny;
	import components.ActionIntSignal;
	import components.ActionUIntSignal;
	import components.DirectionVectors;
	import components.Pos;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import haxe.Log;

	import saboteur.models.IBuildModel;
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
	public class PathBuilderSystem extends System implements IBuildModel, IBuildAttempter
	{
		/**
		 * Build distance ratio in relation to current grid east/south width to indicate how near to edge required
		 * before allowed to build. Lower ratios indiciate nearer to edge required.
		 */
		public var buildDistRatio:Point =  new Point(.5, .5);
		
		// relavant data if this is used as the IBUildModel
		private var curBuildId:int = -1; // -1;  // 63
		public function setBuildId(val:int):void  {
			curBuildId = val;
			validateVis();
		}
		public function getCurBuildID():int {
			return curBuildId;
		}
	
		
		
		public function getCurBuilder():GameBuilder3D {
			if (nodeList == null) throw new Error("not yet added to engine yet!");
			return nodeList.head ? (nodeList.head as PathBuildingNode).builder : null;
		}

		
		private var camera:Camera3D;
		private var fromPos:Pos;
		private var fromDirection:DirectionVectors;
	
		private var origin:Vector3D = new Vector3D();
		private var direction:Vector3D = new Vector3D();
		
		private var nodeList:NodeList;
		public var onEndPointStateChange:ActionIntSignal = new ActionIntSignal();
		private var _lastGe:int = 0;
		private var _lastGs:int = 0;
		
		private var _buildModel:IBuildModel;
		
		private function validateVis():void 
		{
			if ( nodeList && nodeList.head) {
				fromPos = (nodeList.head as PathBuildingNode).entity.get(Pos) as Pos;
				fromDirection = (nodeList.head as PathBuildingNode).entity.get(DirectionVectors) as DirectionVectors;
				var resultId:int;
				(nodeList.head as PathBuildingNode).builder.value = resultId= _buildModel.getCurBuildID();
				if (curBuildId >= 0) {  (nodeList.head as PathBuildingNode).builder.setBlueprintVis(true) }
				else (nodeList.head as PathBuildingNode).builder.setBlueprintVis(false);
			}
		}
		private var _lastResult:int = -999;
		//private var camPos:Vector3D;
		
		public var signalBuildableChange:Signal1 = new Signal1();
		private var pathUtil:SaboteurPathUtil = SaboteurPathUtil.getInstance();

		public const onBuildFailed:Signal0= new Signal0();
		public const onBuildSucceeded:Signal2 = new Signal2();
		
		public const onDelFailed:Signal0= new Signal0();
		public const onDelSucceeded:Signal1 = new Signal1();
		
		public var buildToValidity:Boolean=false;  // set this to true to use traditional boardgame saboteur rules where spatial position of videogame player avatar doesn't matter
		public var onPositionTileChange:Signal2 = new Signal2();
		
		
		public function PathBuilderSystem(camera:Camera3D=null) 
		{
			this.camera = camera;
			_buildModel = this;
			//	camPos  = new Vector3D();
			onEndPointStateChange.current = -2;
			
			
		}
		public function attemptDel():Boolean 
		{
			var head:PathBuildingNode = nodeList.head as PathBuildingNode;
			if (head == null) {
				//onDelFailed.dispatch();
				return false;
			}
			if (_lastResult === SaboteurPathUtil.RESULT_OCCUPIED) {
				// double check for  3d builders as well?
				 //pathUtil.getValidResult(head.builder.getBuildDict(), head.builder3.gridBuildAt.x, head.builder3.gridBuildAt.y, head.builder3.value, null ) === SaboteurPathUtil.RESULT_OCCUPIED
				if (head.builder.attemptRemove()) {   
					onDelSucceeded.dispatch(head.builder)
				}
				else {
					onDelFailed.dispatch();
					Log.trace("del failed exception. this shoudn't conventionally happen due to doublecheck with frame coherancy")
				}
			}
			return true;
		}
			
		public function attemptBuild():Boolean {
			var head:PathBuildingNode = nodeList.head as PathBuildingNode;
			if (head == null) {
				//onBuildFailed.dispatch();
			
				return false;
			}
			if (_lastResult != SaboteurPathUtil.RESULT_VALID) {  
				onBuildFailed.dispatch();
				return false;
			}
			
			// double check for 3d builders as well?
			// pathUtil.getValidResult(head.builder.getBuildDict(), head.builder3.gridBuildAt.x, head.builder3.gridBuildAt.y, head.builder3.value, null ) === SaboteurPathUtil.RESULT_VALID
			if (head.builder.attemptBuild()) { 
				onBuildSucceeded.dispatch(curBuildId, head.builder);
				return true;
			}
			else {
				onBuildFailed.dispatch();
				Log.trace("build failed exception. this shoudlnt' conventionally happen due to doublecheck with frame coherancy")
			}
			return false;
		}
		
		override public function addToEngine(engine:Engine):void {
			nodeList = engine.getNodeList(PathBuildingNode);
			nodeList.nodeAdded.add( onNodeAdded);
			validateVis();
		}
		
		override public function removeFromEngine(engine:Engine):void {
			var head:PathBuildingNode = nodeList.head as PathBuildingNode;
			if (head == null) return;
			head.builder.setBlueprintVis(false);
		}
		
		private function onNodeAdded(node:PathBuildingNode):void 
		{
			if (node === nodeList.head) validateVis();
			
			//camera.debug = true;
			//camera.addToDebug( Debug.BOUNDS, node.builder.blueprint);
			//camera.addToDebug( Debug.BOUNDS, node.builder.genesis);
		}
		
		//private var _lastGe:int = -int.MAX_VALUE;
		//private var _lastGs:int = -int.MAX_VALUE;	
		/*
		public var onGridPositionChange()
		private function validateFloorPosition(ge:int, gs:int):void {
			if (_lastGe != ge || _lastGs != gs) {
				_lastGe = ge;
				_lastGs = gs;
			}
		}
		*/
		
		override public function update(time:Number):void {
			var endPtResult:int;

		
			
			var curBuild:PathBuildingNode = nodeList.head as PathBuildingNode;
			if (curBuild == null) return;
			
			
			var builder:GameBuilder3D = curBuild.builder;
			var cardinal:CardinalVectors = builder.cardinal;
			
			var eastVal:Number;
			var southVal:Number;
			var eastOffset:int;
			var southOffset:int;

				var key:uint ;
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
						key = pathUtil.getGridKey(ge, gs);
						endPtResult = builder.pathGraph.endPoints[key] != null ? builder.pathGraph.endPoints[key]  : -1;
						
						// TODO: this case won't be correct
						if (curBuildId < 0 || endPtResult<= 0) {  // !builder.isOccupiedAt(ge, gs)  // where builder is located (gridEast2/gridSouth2)
							builder.setBlueprintVis(false);
							builder.updateFloorPosition(ge, gs, buildToValidity);
							onEndPointStateChange.set(endPtResult); 
							return;
						}
						
						builder.setBlueprintVis(true);
						builder.updateFloorPosition(ge, gs, buildToValidity);
						onEndPointStateChange.set(endPtResult); 
						return;
					}
					ge = Math.round(eastVal * builder.gridEastWidth_i);
					gs = Math.round(southVal * builder.gridSouthWidth_i);
					if (ge != _lastGe || gs != _lastGs) {
				
						onPositionTileChange.dispatch(ge, gs);
						_lastGe = ge;
						_lastGs = gs;
					}	
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
					/*
					if (ge != _lastGe || gs != _gs) {
						_lastGe = ge;
						_gs = gs;
						Log.trace("Updating coordinate:" + _lastGe + ", " + _gs);
					}
					*/
				}
				else {  // without camera, need at least a fromPos
					throw new Error("Need at least fromPos or camera to continue!");
				}
			
				//if (!buildToValidity) {
					key = pathUtil.getGridKey(ge, gs);
					endPtResult = builder.pathGraph.endPoints[key] != null ? builder.pathGraph.endPoints[key]  : -1;
				//}
				
				if (curBuildId < 0 || !builder.isOccupiedAt(ge, gs) ) {  //  // where builder is located (gridEast2/gridSouth2)
					builder.setBlueprintVis(false);
					//builder.updateFloorPosition(ge, gs);
					result = SaboteurPathUtil.RESULT_OUT;
					if (result != _lastResult) {
							_lastResult = result;
							signalBuildableChange.dispatch(result);
						}
					onEndPointStateChange.set(endPtResult); 
					return;
				}

				if (fromDirection == null) {
					if (fromPos == null) {   // calculate ray manually from camera screen center
						
						camera.calculateRay(origin, direction, camera.view._width * .5, camera.view._height * .5);
					}
					else {  // cast ray from camera position through origin position
						direction.x =   fromPos.x - camera._x;
						direction.y =  fromPos.y -camera._y;
						direction.z = fromPos.z -camera._z;
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
					
					ge += eastOffset;
					gs += southOffset;
					
					if (!buildToValidity && endPtResult <= 0 ) {  // exit case for no valid path to build at location
						builder.setBlueprintVis(true);
						result = builder.updateFloorPosition(ge, gs, buildToValidity);
						if (result != SaboteurPathUtil.RESULT_OCCUPIED) {
							result = SaboteurPathUtil.RESULT_OUT;
							builder.setBlueprintVis(false);
						}
	
						if (result != _lastResult) {
							_lastResult = result;
							signalBuildableChange.dispatch(result);
						}
						onEndPointStateChange.set(endPtResult);
						return;
					}
					
					if ( xt < yt ?   xt - int(xt) > buildDistRatio.x  :   yt - int(yt) > buildDistRatio.y ) {  
						result = builder.updateFloorPosition(ge , gs,buildToValidity );
						if (result === SaboteurPathUtil.RESULT_VALID) {
							builder.editorMat.color = GameBuilder3D.COLOR_OUTSIDE;
							result = SaboteurPathUtil.RESULT_OUT;
						}
						if (result != _lastResult) {
							_lastResult = result;
							signalBuildableChange.dispatch(result);
						}
						
						onEndPointStateChange.set(endPtResult);
						return;
					}

					result = builder.updateFloorPosition(ge, gs, buildToValidity);
					
					//if (ge === 0 && gs === 0) result = SaboteurPathUtil.RESULT_OUT;  // not allowed to bulid at genesis rule. 
					if (result != _lastResult) {
						_lastResult = result;
						signalBuildableChange.dispatch(result);
					}
					
					onEndPointStateChange.set(endPtResult);

			}
			
	
				
			
			public function get lastResult():int 
			{
				return _lastResult;
			}
			
			public function get lastGe():int 
			{
				return _lastGe;
			}
			
			public function get lastGs():int 
			{
				return _lastGs;
			}
			
			public function get buildModel():IBuildModel 
			{
				return _buildModel;
			}
			
			public function set buildModel(value:IBuildModel):void 
			{
				_buildModel = value;
				validateVis();
			}
		
	
		
	}

}
import alternativa.engine3d.core.Camera3D;
import ash.ClassMap;
import ash.core.Node;
import components.Pos;
import saboteur.util.CardinalVectors;
import saboteur.util.GameBuilder3D;


class PathBuildingNode extends Node {
	public var builder:GameBuilder3D;
	//public var playerPos:Pos;
	
	public function PathBuildingNode() {
		
	}

	private static var _components:ClassMap;
	
	public static function _getComponents():ClassMap {
		if(_components == null) {
				_components = new ash.ClassMap();
				_components.set(GameBuilder3D, "builder");
				//_components.set(Camera3D, "camera");
			}
			return _components;
	}
}