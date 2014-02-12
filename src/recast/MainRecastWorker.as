/**
 * Demo project for Recast navigation AS3 library (alpha)
 * Very simple 2d example
 * 
 * @author Zo Douglass
 * 
 * Source: https://github.com/zodouglass/RecastAS3
 * Email: zo@zodotcom.com
 * 
 * TODO - add wrapper class for swc library for autocomplete and compile checking
 */
package recast 
{
	import cmodule.recast.CLibInit;
	import cmodule.recast.MemUser;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.system.MessageChannel;
	import flash.system.Worker;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import flash.utils.getTimer;
	import flash.utils.setInterval;
	import flash.utils.setTimeout;
	import util.AS3WorkerBridge;
	
	 [SWF(width="800", height="600", frameRate="60")]
	public class MainRecastWorker extends Sprite
	{
		private static var OBJ_FILE:String = "nav_test.obj";// "dungeon.obj"; //dungeon
		private static var OBJ_HEIGHT:Number = 0; //since we are doing 2d, need to pass an appropriate surface height of the obj mesh
		
		public static var MAX_AGENTS:int = 60;
		public static var MAX_AGENT_RADIUS:Number = 0.24*WORLD_SCALE;
		public static var MAX_SPEED:Number = 3.5*3
		public static var MAX_ACCEL:Number = 8.0*3
		
		private static const WORLD_SCALE:Number =5 
		
	
		private static var SCALE:Number = 10 / WORLD_SCALE;
			
		public var lib:Object;
		private var memUser:MemUser = new MemUser();
		public var agentPtrs:Vector.<uint> = new Vector.<uint>();
		private var oldAgentPtrs:Vector.<uint>;
		
		private var bridge:RecastWorkerBridge = new RecastWorkerBridge();

		public function MainRecastWorker(sync:Boolean=false) 
		{
			this.sync = sync;
			//this.scaleX = this.scaleY = SCALE;
			///this.x = 300;
			//this.y = 300;
			
			if (!Worker.current.isPrimordial) {
				try {
					init(true);
				}
				catch (e:Error) {
					bridge.sendError(e);
				}
			}
			else {
				//IslandGenWorker.BYTES = loaderInfo.bytes;
				if (sync) init();
			}
			
		}
		
		private function init(isWorker:Boolean=false):void {
			if (isWorker) {
				
				bridge.initAsChild();
				MAX_ACCEL = bridge.MAX_ACCEL;
				MAX_AGENT_RADIUS = bridge.MAX_AGENT_RADIUS
				MAX_AGENTS = bridge.MAX_AGENTS;
				MAX_SPEED = bridge.MAX_SPEED;
				
				
				listenChannel = (!bridge.usingChannel2 ? bridge.toWorkerChannel : bridge.toWorkerChannel2);
				listenChannel.addEventListener(Event.CHANNEL_MESSAGE, onReceivedMessageFromMain);
				
			}
			initCLib();
			if (isWorker) {
				bridge.toMainChannelSync.send(AS3WorkerBridge.RESPONSE_SYNC);
			}
		}
		
		private function onReceivedMessageFromMain(e:Event):void 
		{
			try {
				var cmd:int = listenChannel.receive();
				
				if (cmd === RecastWorkerBridge.CMD_MOVE_AGENTS) {
					
					respond_moveAgents();
				}
				else if (cmd === RecastWorkerBridge.CMD_CREATE_ZONE) {
					respond_createZone();
					bridge.toMainChannel.send(RecastWorkerBridge.RESPONSE_CREATE_ZONE_DONE);
				}
				else if (cmd === RecastWorkerBridge.CMD_SET_AGENTS) {
					bridge.toWorkerBytesMutex.lock();
					respond_setAgents();
					bridge.toWorkerBytesMutex.unlock();
					bridge.toMainChannelSync.send(AS3WorkerBridge.RESPONSE_SYNC);
				}	
			}
			catch (err:Error) {
				bridge.sendError(err);
			}
		}
		
		private function respond_createZone():void 
		{
			bridge.toWorkerBytes.position = 0;
		
			createZone(bridge.toWorkerVertexBuffer, bridge.toWorkerIndexBuffer, bridge.toWorkerBytes.readFloat(), bridge.toWorkerBytes.readFloat(), bridge.toWorkerBytes.readFloat(), bridge.toWorkerBytes.readFloat());
			
			
		}
		
		private function respond_moveAgents():void 
		{
			bridge.targetAgentPosMutex.lock();
			bridge.targetAgentPosBytes.position = 0;
		
			var numAgentsToMove:int = bridge.targetAgentPosBytes.readInt();
			
			var leaderX:Number = getAgentX(3);
			var leaderY:Number = getAgentZ(3);
			for (var i:int = 0; i < numAgentsToMove; i++) {

				

				moveAgent( bridge.targetAgentPosBytes.readInt() ,
				bridge.targetAgentPosBytes.readFloat(),
				bridge.targetAgentPosBytes.readFloat(),
				bridge.targetAgentPosBytes.readFloat() );
	
				
			}
			bridge.targetAgentPosMutex.unlock();
			
		}
		
		private function respond_setAgents():void 
		{
			var i:int = agentCount;
			
			while (--i > -1) {
				lib.removeAgent(i );
			}
			
			bridge.toWorkerBytes.position = 0;
			
			var numAgentsToCreate:int = bridge.toWorkerBytes.readInt();
			
			for (i=0; i < numAgentsToCreate; i++) {
				
				addAgent( bridge.toWorkerBytes.readFloat(), bridge.toWorkerBytes.readFloat() );
			}
			
		}
		
		private var libs:Array = [];
		private var timeIn:int;
		private var _debugField:TextField;
		private var loader:CLibInit;
		
		private function initCLib():void {
			loader = new CLibInit();
			//now call the CLib init function
			lib = loader.init();
		
			//set mesh settings		
			var m_cellSize:Number = 0.3,
			m_cellHeight:Number = 0.3,
			m_agentHeight:Number = 3.0*WORLD_SCALE,
			m_agentRadius:Number = MAX_AGENT_RADIUS,
			m_agentMaxClimb:Number = 0.9*WORLD_SCALE,
			m_agentMaxSlope:Number = 45.0,
			m_regionMinSize:Number = 8*WORLD_SCALE,
			m_regionMergeSize:Number = 20*WORLD_SCALE,
			m_edgeMaxLen:Number = 12.0*WORLD_SCALE,
			m_edgeMaxError:Number = 1.3*WORLD_SCALE,
			m_vertsPerPoly:Number = 6.0,
			m_detailSampleDist:Number = 6.0*WORLD_SCALE,
			m_detailSampleMaxError:Number = 1.0*WORLD_SCALE,
			m_tileSize:int = m_cellSize*260,
			m_maxObstacles:int = 1024;
			
			lib.meshSettings(m_cellSize, 
							m_cellHeight, 
							m_agentHeight, 
							m_agentRadius, 
							m_agentMaxClimb, 
							m_agentMaxSlope, 
							m_regionMinSize, 
							m_regionMergeSize, 
							m_edgeMaxLen, 
							m_edgeMaxError, 
							m_vertsPerPoly, 
							m_detailSampleDist, 
							m_detailSampleMaxError, 
							m_tileSize, 
							m_maxObstacles,
							false);
							
			
		}
		
		
		private function doDummyLoad():void {
			loadFile( PLANE_VERTICES + "\n" + PLANE_INDICES, 0,0,0,0 );
			lib.initCrowd(MAX_AGENTS, MAX_AGENT_RADIUS); //maxagents, max agent radius			
		}
		
		public function initCrowd():void {
			lib.initCrowd(MAX_AGENTS, MAX_AGENT_RADIUS);
		}
		
		private var lastMapX:Number;
		private var lastMapY:Number;
		private var targetMapX:Number;
		private var targetMapY:Number;

		
		private var loadCount:int = 0;
		public function loadFile(contents:String, x:Number , y:Number, dx:Number , dy:Number ):int {
		
		
			targetMapX = x;
			targetMapY = y;
			stopAllAgents();
			
			var byteArray:ByteArray = new ByteArray();
			byteArray.writeMultiByte(contents, "iso-8859-1");
			TOGGLE = !TOGGLE;
			var suffix:String = String(loadCount++);// ( TOGGLE ? "_" : "");
		
			loader.supplyFile(OBJ_FILE + suffix, byteArray );
			
			lib.loadMesh(OBJ_FILE+suffix);
			
			 lib.buildMesh();
			//
			
			return validateNewNavMesh(dx,dy);
			
		}
		
		public function loadFileBytes(byteArray:ByteArray):int {
			
			
		
			TOGGLE = !TOGGLE;
			var suffix:String = ( TOGGLE ? "_" : "");
			loader.supplyFile(OBJ_FILE+suffix, byteArray );
			lib.loadMesh(OBJ_FILE+suffix);
			lib.buildMesh();
			
			
			return validateNewNavMesh(0, 0);
			
		}
		
		public var orphanedAgentIndices:Vector.<int> = new Vector.<int>();
		
		
		
		// TODO: need to do this up proper...
		private function validateNewNavMesh(dx:Number, dy:Number):int
		{
			
		//	graphics.clear();
			//graphics.beginFill(0xAAAAAA, .7);
			
			
			
			var newAgents:Vector.<uint> = new Vector.<uint>();
			
			var newAgentCount:int = 0;
			var numOrphans:int = 0;
			var xDiff:Number = targetMapX - lastMapX;
			var yDiff:Number = targetMapY - lastMapY;
			var len:int =  agentPtrs.length;
			
			var minX:Number = targetMapX - 64;
			var minY:Number = targetMapY - 64;
			var maxX:Number = targetMapX + 64;
			var maxY:Number = targetMapY + 64;
			
			
			
			var tarPositions:Array = [];
			
		
			
			for (i = 0; i < len; i++) {
				var tarX:Number =  getAgentX(i) + dx;
				var tarY:Number =  getAgentZ(i) + dy;
				tarPositions.push(tarX);
				tarPositions.push(tarY);

			}
			
		
			

			
			for (var i:int = 0; i < len; i++) {
				
				tarX = tarPositions[(i << 1) ];
				tarY = tarPositions[(i << 1) + 1];
				
				if (true || tarX >= minX && tarY >= minY && tarX <= maxX && tarY <= maxY) {  // check which agents are still within vincity, reset their positions
					//

				//	if (TOGGLE) 
				replaceAgent(tarX, tarY, i);
				}
				else {
					throw new Error("Havne't handled orphaned agent case yet!");
					lib.removeAgent( agentPtrs[i] );
					agentCount--;
					orphanedAgentIndices[numOrphans++] = i;
				}
			}
			
				//if (len) {
					//throw new Error(ZoneCreateCount + ", "+slotOffset);
				//	slotOffset += 4;
				//}
		
			//agentPtrs = newAgents;
			
			//if (numOrphans > 0) {
				validateAgents();
			//}
			
			
			
			return numOrphans;
		}
		
	
		
		
		private function onEnterFrame(e:Event):void 
		{
			update();
			
		}
		

		public static const PLANE_VERTICES:String = "v -64 0 -64\nv 64 0 -64\nv -64 0 64\nv 64 0 64";
		public static const PLANE_INDICES:String = "f 1 3 4\nf 1 4 2";
		static public const BUILD_DONE:String = "buildDone";
		public var numOrphans:int;

		public function createZone(vertexBuffer:ByteArray, indexBuffer:ByteArray, x:Number, y:Number, dx:Number, dy:Number):void {
			
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			targetMapX = x;
			targetMapY = y;
			
			
			vertexBuffer.position = 0;
			indexBuffer.position = 0;
			var appendVertices:String = createStringFromVertexBuffer(vertexBuffer);
			var appendIndices:String = createStringFromIndexBuffer(indexBuffer);
			
			numOrphans = loadFile( PLANE_VERTICES + appendVertices + "\n" + PLANE_INDICES + appendIndices, x, y, dx, dy);
			
			if (ZoneCreateCount == 0) {
				initCrowd();
			}
			ZoneCreateCount++;
			dispatchEvent( new Event(BUILD_DONE));
			
		}
		

		private var ZoneCreateCount:int = 0;
		public function createZoneWithWavefront(appendVertices:String, appendIndices:String ,x:Number, y:Number, dx:Number, dy:Number ):void {
			
			removeEventListener(Event.ENTER_FRAME, onEnterFrame);
	targetMapX = x;
	targetMapY = y;
		numOrphans = loadFile( PLANE_VERTICES + appendVertices + "\n" + PLANE_INDICES + appendIndices, x,y, dx, dy);

		if (ZoneCreateCount == 0) {
			initCrowd();
		}
		ZoneCreateCount++;
		dispatchEvent( new Event(BUILD_DONE));
		 
		}
		
		private function createStringFromVertexBuffer(vertexBuffer:ByteArray):String 
		{
			var i:int = (vertexBuffer.length - vertexBuffer.position) >> 2;
			i /= 3;
			var str:String = "";
			while (--i > -1) {
				str	+= "\nv " +vertexBuffer.readFloat() + " "+vertexBuffer.readFloat()+ " "+vertexBuffer.readFloat();
			}
			return str;
		}
		
		private function createStringFromIndexBuffer(indexBuffer:ByteArray):String 
		{
			var i:int = (indexBuffer.length - indexBuffer.position) >> 2;
			i /= 3;
			
			var str:String = "";
			while (--i > -1) {
				str += "\nf "+indexBuffer.readInt()+ " "+indexBuffer.readInt()+ " "+indexBuffer.readInt();
			}
			return str;
		}
		
		/*
		private function updateDestination(x:Number, y:Number):void 
		{
			globalDestX = x;
			globalDestY = y;
			
			// conveert global coordinate to local coordinate
			x -= lastMapX;
			y -= lastMapY;
			var len:int = agentPtrs.length;
			for ( var i:int = 0; i < len; i++ )
			{	
				lib.moveAgent(i, x, OBJ_HEIGHT, y); 
			}
		}
		*/
		
		private var agentCount:int = 0;
		private var globalDestX:Number = 0;
		private var globalDestY:Number = 0;
		private var TOGGLE:Boolean=true;
		private var sync:Boolean;
		private var slotOffset:int = 0;
		private var listenChannel:MessageChannel;
		
		public function addAgent(ax:Number, ay:Number):uint
		{
			
			var radius:Number = MAX_AGENT_RADIUS;
			var height:Number = 2;
			var maxAccel:Number = MAX_ACCEL;
			var maxSpeed:Number = MAX_SPEED;
			var collisionQueryRange:Number = 12.0;
			var pathOptimizationRange:Number = 150;
			
			var agentId:int = lib.addAgent(ax, OBJ_HEIGHT, ay, radius, height, maxAccel, maxSpeed, collisionQueryRange, pathOptimizationRange);
			var agentPtr:uint = lib.getAgentPosition(agentId);
			if (agentId != agentCount) throw new Error("MISMATCH index 11!"+agentCount );
			agentPtrs[agentCount++] = agentPtr;
			validateAgents();
			return agentPtr;
		}
		
		
		private function replaceAgent(ax:Number, ay:Number, index:int):void
		{
			
			var radius:Number = MAX_AGENT_RADIUS;
			var height:Number = 2;
			var maxAccel:Number = MAX_ACCEL;
			var maxSpeed:Number = MAX_SPEED;
			var collisionQueryRange:Number = 12.0;
			var pathOptimizationRange:Number = 150;//30.0*WORLD_SCALE;
			lib.removeAgent( index );
			
			

				var agentId:int = lib.addAgent(ax, OBJ_HEIGHT, ay, radius, height, maxAccel, maxSpeed, collisionQueryRange, pathOptimizationRange);
		
			if (index ==0 && agentId != index) {
				slotOffset = agentId;
			}

			if (agentId!= index ) throw new Error("MISMATCH index!" + index + ", " + agentId );
			
			var agentPtr:uint = lib.getAgentPosition(agentId);
			
			
			agentPtrs[agentId] = agentPtr;
	
			
		}
		
		
		public function validateAgents():void 
		{
			if (agentCount > 0) addEventListener(Event.ENTER_FRAME, onEnterFrame)
			else removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			
		}
		
		public function removeAgent(index:int):void
		{
			var spliced:Vector.<uint> = agentPtrs.splice(index, 1);
			lib.removeAgent(index );
			agentCount--;
			validateAgents();
		}
		
		
		private function moveVelocity(idx:int):void
		{
			var ux:Number = getAgentX(idx);
			var uz:Number = getAgentZ(idx);
			var diff:Point = new Point( ux, uz).subtract( new Point( this.mouseX, this.mouseY));
			diff.normalize(1);
			
			lib.removeAgent(idx);
			
			
			var agentId:int = addAgent( ux, uz);
			
			
			lib.requestMoveVelocity(agentId, -diff.x * MAX_SPEED, 0, -diff.y * MAX_SPEED );
		}
		
		public function update():void
		{
			//try { 
			
			if (bridge != null && bridge.leaderPosBytes && bridge.leaderPosBytes.length>0) {
				bridge.leaderPosBytes.position = 0;
				setAgentX(bridge.leaderIndex, bridge.leaderPosBytes.readFloat());
				setAgentZ(bridge.leaderIndex, bridge.leaderPosBytes.readFloat());
			}
			
			lib.update(0.03); //pass dt in seconds
			if (bridge != null) {
				bridge.toMainAgentPosMutex.lock();
				bridge.toMainAgentPosBytes.position = 0;
				var len:int = agentPtrs.length; // consider, use Domain Memory and share it's bytearray to Main app.
				for (var i:int = 0; i < len; i++) {
					 bridge.toMainAgentPosBytes.writeFloat( memUser._mrf(agentPtrs[i]) );
					 bridge.toMainAgentPosBytes.writeFloat( memUser._mrf(agentPtrs[i] + 8) );
				}
				bridge.toMainAgentPosMutex.unlock();
			}
			
			//}
			//catch (e:Error) {
			//	bridge.sendError(e);
			//}
		}
		
		
		public function getAgentX(i:int):Number
		{
			return memUser._mrf(agentPtrs[i]);	
		}
		
		public function getAgentY(i:int):Number
		{
		
			return memUser._mrf(agentPtrs[i] + 4); // + 4 since a float takes up 4 bytes
			
			
		}
		
		
		public function getAgentZ(i:int):Number
		{
		
			return memUser._mrf(agentPtrs[i] + 8);
			
	
		}
		
		public function setAgentX(i:int, val:Number):void
		{
		
			 memUser._mwf( agentPtrs[i], val);
		
		}
		
		public function setAgentY(i:int, val:Number):void
		{

			 memUser._mwf( agentPtrs[i] + 4, val); // + 4 since a float takes up 4 bytes
			
		
		}
		
		
		public function setAgentZ(i:int, val:Number):void
		{
		
			 memUser._mwf( agentPtrs[i] + 8, val);
			
			
		}
		
		
		
		public function moveAgent(slot:int, offsetX:Number, z:Number, offsetY:Number):void 
		{
			lib.moveAgent(slotOffset + slot, offsetX, z, offsetY);
		}
		
		public function stopAllAgents():void 
		{
			var i:int = agentPtrs.length;
			while (--i > -1) {
				lib.requestMoveVelocity(i, 0,0,0);
			}
			
			
		}
		
	
		
		
	
	}

}