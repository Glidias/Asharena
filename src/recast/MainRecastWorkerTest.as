package recast
{
	import de.polygonal.math.PM_PRNG;
	import de.popforge.revive.forces.ArrowKeys;
	import de.popforge.revive.member.Immovable;
	import de.popforge.revive.member.ImmovableCircleOuter;
	import de.popforge.revive.member.ImmovableGate;
	import de.popforge.surface.io.PopKeys;
	import examples.scenes.Startup;
	import examples.scenes.test.MovableChar;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.net.FileReference;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.system.MessageChannel;
	import flash.system.Worker;
	import flash.system.WorkerDomain;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class MainRecastWorkerTest extends Sprite
	{
		public var MAX:uint;
		public var SQ_DIM:Number;
		public var RADIUS:Number;
		
		
		private var _worker:MainRecastWorker;
		
		private var worker1:Worker;
		private var curWorker:Worker;

		private var targetSprite:Sprite = new Sprite();
		//private var tiles:Array;
		private var agentSprites:Array = [];
		private var previewer:RecastPreviewer;
		
		private var preferedPositions:Vector.<int> = new Vector.<int>(3, true);
		
		
		private var partyStartup:Startup;
		
		private var prng:PM_PRNG = new PM_PRNG();

		// [SWF(width="800", height="600", frameRate="60")]
		public function MainRecastWorkerTest() 
		{
			
			super();
			
			
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			
			var loader:URLLoader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.BINARY;
			loader.addEventListener(Event.COMPLETE, onLoadComplete);
			loader.load(new URLRequest("recastworker.swf"));
			
			var field:TextField = new TextField();
			field.autoSize = "left";
			field.text = "Please wait while we load AS3 Recast/Detour pathfinding worker...";
			addChild(field);
			
		}
		
		private function onLoadComplete(e:Event):void 
		{
			removeChildAt(0);
			var urlLoader:URLLoader = (e.currentTarget as URLLoader);
			urlLoader.removeEventListener(e.type, onLoadComplete);
			init(urlLoader.data);
		}
		
		
		private function init(workerBytes:ByteArray):void {
			MainRecastWorker.MAX_AGENTS = 8;
			MainRecastWorker.MAX_SPEED = 5.2*1.6
			MainRecastWorker.MAX_ACCEL = 10.0*16
			MainRecastWorker.MAX_AGENT_RADIUS =1.02;// 0.24 * 5;
			_worker = new MainRecastWorker(true);
			
			bridge = new RecastWorkerBridge();
			
			worker1 = curWorker = createPrimodialWorker(workerBytes);
			
			addChild(previewer = new RecastPreviewer());
			previewer.scaleX = 4;
			previewer.scaleY = 4;
			previewer.y -= 40;


			//previewer.drawNavMesh(_worker.lib.getTiles());
			//previewer.drawMesh(_worker.lib.getTris(), _worker.lib.getVerts());
			
			
		
			MAX = PM_PRNG.MAX;
			SQ_DIM = Math.sqrt(MAX);
			RADIUS = SQ_DIM * .5;
			
			
			PopKeys.initStage(stage);
		
			Startup.LARGE_RADIUS = 2;
			Startup.SMALL_RADIUS = Startup.LARGE_RADIUS * .5 ;
			Startup.SPRING_SPEED = 313131; // 0.08; // for now, until resolve mem issues  //313131; //
			Startup.START_X = 0;
			Startup.START_Y = 0;
			partyStartup = new Startup();
		//	partyStartup.enableFootsteps = false;
		//	partyStartup.footsteps.length = 0;
		
			setWorldCenter(0, 0, 0 ,0);
			//_worker.initCrowd();
			
			

			updateWorldThreshold = 2 * TILE_SIZE;
			updateWorldThreshold *= updateWorldThreshold;
			
			
			//partyStartup.targetSpringRest = Startup.LARGE_RADIUS *2;
			partyStartup.setFootstepThreshold(2);
			partyStartup.simulation.addForce(new ArrowKeys(partyStartup.movableA, .15));
			//partyStartup.simulation.addForce(new ArrowKeys(partyStartup.movableB, .08));
			//partyStartup.simulation.addForce(new ArrowKeys(partyStartup.movableC, .08));
			//partyStartup.simulation.addForce(new ArrowKeys(partyStartup.movableD, .08));
			partyStartup.manualInit2DPreview(previewer);
			partyStartup.movableA.x = 0;
			partyStartup.movableA.y = 0;
			
			preferedPositions[0] = 0;
			preferedPositions[1] = 1;
			preferedPositions[2] = 2;
		//	partyStartup.footStepCallback = onLeaderFootstep;
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			

			
			addAgent(partyStartup.movableB.x, partyStartup.movableB.y, 0xFF0000);
			addAgent(partyStartup.movableC.x, partyStartup.movableC.y, 0x00FF00);
			addAgent(partyStartup.movableD.x, partyStartup.movableD.y, 0x0000FF);
			_worker.addAgent(partyStartup.movableA.x, partyStartup.movableA.y);
			
			previewer.addChild(_worker);
			
			setAgents();
			

		}
		
		public function setAgents():void {
			
			bridge.toWorkerBytes.position = 0;
			
			bridge.toWorkerBytes.writeInt(4);
			
			bridge.toWorkerBytes.writeFloat(partyStartup.movableB.x);
			bridge.toWorkerBytes.writeFloat(partyStartup.movableB.y);
			
			bridge.toWorkerBytes.writeFloat(partyStartup.movableC.x);
			bridge.toWorkerBytes.writeFloat(partyStartup.movableC.y);
			
			bridge.toWorkerBytes.writeFloat(partyStartup.movableD.x);
			bridge.toWorkerBytes.writeFloat(partyStartup.movableD.y);
			
			bridge.toWorkerBytes.writeFloat(partyStartup.movableA.x);
			bridge.toWorkerBytes.writeFloat(partyStartup.movableA.y);
			
			bridge.toMainChannelSync.addEventListener(Event.CHANNEL_MESSAGE, onAgentsSetup);
			curWorkerMessageChannel.send(RecastWorkerBridge.CMD_SET_AGENTS);
		}
		
		private function onAgentsSetup(e:Event):void 
		{
			
			
			(e.currentTarget as IEventDispatcher).removeEventListener(e.type, onAgentsSetup);
			
		
			
			drawSyncAgents();
		}
		
		
		
		
		private function createPrimodialWorker(workerBytes:ByteArray):Worker 
		{
			
			var worker:Worker = WorkerDomain.current.createWorker(workerBytes);
			bridge.MAX_SPEED = 5.2 * 1.6;
			bridge.MAX_ACCEL = 10.0 * 16;
			bridge.MAX_AGENT_RADIUS = 1.02;
			bridge.usingChannel2 = false;
			bridge.initAsPrimordial(worker);
			bridge.setupErrorThrowHandler();
			
			curWorkerMessageChannel = bridge.toWorkerChannel;
			bridge.toMainChannel.addEventListener(Event.CHANNEL_MESSAGE, onReceivedFromWorkerNavMesh);		
			
			
			
			worker.start();
			return worker;
		}
		
		private function onReceivedFromWorkerNavMesh(e:Event):void 
		{
			
			// draw nav mesh preview from byte array
			
			
			
			bridge.originPosBytes.position = 0;
			bridge.originPosBytes.writeFloat(_worldX);
			bridge.originPosBytes.writeFloat(_worldY);
			
			bridge.leaderPosBytes.position = 0;
			bridge.leaderPosBytes.writeFloat(0);
			bridge.leaderPosBytes.writeFloat(0);
			
			lastLeaderX = 0;
			lastLeaderY = 0;
		}
		
		
		
		private function onLeaderFootstep():void 
		{
			
			var offsetX:Number;
			var offsetY:Number;
			

			var formationState:int = partyStartup.formationState;
			var resolveFlankers:Boolean = formationState > 0;
			for (var i:int = 0; i < 3; i++) {
				var curCircle:MovableChar = partyStartup.memberCircleLookup[i];
				var tarCircle:MovableChar = curCircle.following != -2 ? curCircle : partyStartup.movableA;
				if (curCircle.slot >= 0 ) {
					preferedPositions[i] = curCircle.slot;
					_worker.moveAgent(curCircle.slot, tarCircle.x + tarCircle.offsetX, 0,  tarCircle.y + tarCircle.offsetY); 
				}
				else {
					
					_worker.moveAgent( (!resolveFlankers ? preferedPositions[i] : preferedPositions[i] != partyStartup.rearGuard.slot ? preferedPositions[i] : partyStartup.lastRearGuardSlot), tarCircle.x + tarCircle.offsetX, 0,  tarCircle.y + tarCircle.offsetY); 
				}
				
				// NOTE: this does not determine flank averages...
			}
			
			/*
			offsetX = partyStartup.movableB.offsetX;
			offsetY =  partyStartup.movableB.offsetY;
			_worker.moveAgent(0, partyStartup.movableB.x + offsetX, 0,  partyStartup.movableB.y + offsetY); 
			
			offsetX = partyStartup.movableC.offsetX;
			offsetY =  partyStartup.movableC.offsetY;
			_worker.moveAgent(1, partyStartup.movableC.x + offsetX, 0,  partyStartup.movableC.y + offsetY); 
			
			offsetX = partyStartup.movableD.offsetX;
			offsetY =  partyStartup.movableD.offsetY;
			_worker.moveAgent(2, partyStartup.movableD.x + offsetX, 0,  partyStartup.movableD.y+ offsetY); 
			*/
			
		}
		
		private function addAgent(x:Number, y:Number, color:uint=0xFF0000):void {
			_worker.addAgent(x, y);
			var child:DisplayObject;
			agentSprites.push( previewer.addChild( child = new AgentSpr(color)) );
			
			child.x = x;
			child.y = y;
			
			//child.x = x;
			//child.y = y;
		}
		
		private function onKeyDown(e:KeyboardEvent):void 
		{
			if (e.keyCode === Keyboard.U) {
				recenter();
			}
			else if (e.keyCode === Keyboard.P) {
				_worker.stopAllAgents();
			}
		}
		
		private function recenter():void 
		{
		
			
			
			var newX:Number = partyStartup.movableA.x;
			var newY:Number = partyStartup.movableA.y;
				
			partyStartup.displaceMovables( -newX, -newY);
			
					
			setWorldCenter(newX + _worldX, newY + _worldY, -newX, -newY );
			
				
		}
		
		private function getSeededVal(seed:uint):Number {
			prng.seed = seed;
			return prng.nextDouble();
		}
		
		
		private function setWorldCenter(x:Number, y:Number, dx:Number, dy:Number):void 
		{
			_worldX = x;
			_worldY = y;
			
			
			createRandomObstacles(x, y, dx, dy);
		}
	
		private var NUM_TILES_ACROSS:Number = 8;
		private var TILE_SIZE:Number = 16;
		private var WORLD_TILE_SIZE:Number = TILE_SIZE * NUM_TILES_ACROSS;
		private var _worldX:Number;
		private var _worldY:Number;
		private var updateWorldThreshold:Number;
		
		private function createRandomObstacles(worldX:Number, worldY:Number, dx:Number, dy:Number):void {
			
			bridge.toWorkerVertexBuffer.position = 0;
			bridge.toWorkerIndexBuffer.position = 0;
			
			
			var invTileSize:Number = 1 / TILE_SIZE;
		
			partyStartup.simulation.immovables = [];
			// unique seed per tile (not very large world supported...but for testing only..)
			
			
			
			var hTilesAcross:int = NUM_TILES_ACROSS * .5;
			var startWorldX:Number=worldX- hTilesAcross * TILE_SIZE;
			var startWorldY:Number =worldY- hTilesAcross * TILE_SIZE;
			var xMin:int = Math.floor( startWorldX * invTileSize);
			var yMin:int = Math.floor( startWorldY * invTileSize);
			var xMax:int = Math.ceil( (worldX + hTilesAcross * TILE_SIZE) * invTileSize)
			var yMax:int = Math.ceil( (worldY + hTilesAcross * TILE_SIZE) * invTileSize)

			for (var x:int = xMin; x < xMax; x++) {
				var lx:Number = x*TILE_SIZE - worldX;
				for (var y:int = yMin; y < yMax; y++) {
					if (Math.abs(y) < 1 || Math.abs(x) < 1) continue;
					//if (getSeed(x, y) == prng.seed) throw new Error("SHOULD BE UNIQUE!");
					prng.seed =  getSeed(x, y);
				
					var ly:Number = y*TILE_SIZE - worldY;
					var val:Number = prng.nextDouble();
					if ( val > 0.5) { // tree stump
				
						addBox(prng.nextDoubleRange(Startup.LARGE_RADIUS + lx, lx + TILE_SIZE - Startup.LARGE_RADIUS),  prng.nextDoubleRange(Startup.LARGE_RADIUS + ly, ly + TILE_SIZE - Startup.LARGE_RADIUS), Startup.LARGE_RADIUS, Startup.LARGE_RADIUS  );
					}
					else if (val > 0.4) {  // sandbag
						addBox(lx,ly,6,3 );
					}
					else {  // solid full block
						addBox(lx,ly,16,16 );
					}
					
				}
			}
		
			
		
			
			
		//	throw new Error([xMin, xMax, yMin, yMax]);
	
		
			
			partyStartup.redrawImmovables(); 
			
			
			
		//	new FileReference().save(MainRecastWorker.PLANE_VERTICES+wavefrontVertBuffer + "\n" + MainRecastWorker.PLANE_INDICES + wavefrontPolyBuffer, "testwavefront.obj");

		wavefrontVertCount = 5;

		// async
		
			bridge.toWorkerVertexBuffer.length = bridge.toWorkerVertexBuffer.position;
			bridge.toWorkerIndexBuffer.length = bridge.toWorkerIndexBuffer.position;
		
			bridge.toWorkerBytes.position = 0;
			bridge.toWorkerBytes.writeFloat(_worldX);
			bridge.toWorkerBytes.writeFloat(_worldY);
			bridge.toWorkerBytes.writeFloat(dx);
			bridge.toWorkerBytes.writeFloat(dy);
			curWorkerMessageChannel.send(RecastWorkerBridge.CMD_CREATE_ZONE);
			
			// sync
			
				removeEventListener(Event.ENTER_FRAME, onEnterFrame);
			PopKeys.reset();
			_worker.addEventListener(MainRecastWorker.BUILD_DONE, onWorkerBulidDone);
			
			//_worker.createZoneWithWavefront(wavefrontVertBuffer, wavefrontPolyBuffer, _worldX, _worldY, dx, dy);
			_worker.createZone(bridge.toWorkerVertexBuffer, bridge.toWorkerIndexBuffer, _worldX, _worldY, dx, dy);
			
		
			
			previewer.drawNavMesh(_worker.lib.getTiles());
		}
		
		private function onWorkerBulidDone(e:Event):void 
		{
				

		
			
			_worker.removeEventListener(e.type, onWorkerBulidDone);
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
		//	_worker.validateAgents();
			lastLeaderX = 0;
			lastLeaderY = 0;
			
		
			onLeaderFootstep();
			
		}
		

		private var wavefrontVertCount:int = 5;
		
		
		//private var vertBuffer:ByteArray
		
		private var lastLeaderX:Number = 0;
		private var lastLeaderY:Number = 0;

		private var bridge:RecastWorkerBridge;
		private var curWorkerMessageChannel:MessageChannel;
		
		private function addBox(x:Number, y:Number, width:Number, height:Number):void {
			var r:Number = Startup.SMALL_RADIUS;
			var ig:ImmovableGate;
			partyStartup.simulation.addImmovable(ig = new ImmovableGate( x + width, y, x + width, y + height) );
			
			
			
		
			bridge.toWorkerVertexBuffer.writeFloat(ig.x1);
			bridge.toWorkerVertexBuffer.writeFloat(16);
			bridge.toWorkerVertexBuffer.writeFloat(ig.y1);
			
			bridge.toWorkerVertexBuffer.writeFloat(ig.x0);
			bridge.toWorkerVertexBuffer.writeFloat(16);
			bridge.toWorkerVertexBuffer.writeFloat(ig.y0);
			
			bridge.toWorkerVertexBuffer.writeFloat(ig.x1);
			bridge.toWorkerVertexBuffer.writeFloat(-2);
			bridge.toWorkerVertexBuffer.writeFloat(ig.y1);
			
			bridge.toWorkerVertexBuffer.writeFloat(ig.x0);
			bridge.toWorkerVertexBuffer.writeFloat(-2);
			bridge.toWorkerVertexBuffer.writeFloat(ig.y0);
			
			bridge.toWorkerIndexBuffer.writeInt(wavefrontVertCount + 0);
			bridge.toWorkerIndexBuffer.writeInt(wavefrontVertCount + 2);
			bridge.toWorkerIndexBuffer.writeInt(wavefrontVertCount + 3);
			
			bridge.toWorkerIndexBuffer.writeInt(wavefrontVertCount + 1);
			bridge.toWorkerIndexBuffer.writeInt(wavefrontVertCount + 0);
			bridge.toWorkerIndexBuffer.writeInt(wavefrontVertCount + 3);
			
			wavefrontVertCount += 4;

			
			partyStartup.simulation.addImmovable(ig = new ImmovableGate( x , y, x + width, y) );
			
		
			
			
			bridge.toWorkerVertexBuffer.writeFloat(ig.x1);
			bridge.toWorkerVertexBuffer.writeFloat(16);
			bridge.toWorkerVertexBuffer.writeFloat(ig.y1);
			
			bridge.toWorkerVertexBuffer.writeFloat(ig.x0);
			bridge.toWorkerVertexBuffer.writeFloat(16);
			bridge.toWorkerVertexBuffer.writeFloat(ig.y0);
			
			bridge.toWorkerVertexBuffer.writeFloat(ig.x1);
			bridge.toWorkerVertexBuffer.writeFloat(-2);
			bridge.toWorkerVertexBuffer.writeFloat(ig.y1);
			
			bridge.toWorkerVertexBuffer.writeFloat(ig.x0);
			bridge.toWorkerVertexBuffer.writeFloat(-2);
			bridge.toWorkerVertexBuffer.writeFloat(ig.y0);
			
			bridge.toWorkerIndexBuffer.writeInt(wavefrontVertCount + 0);
			bridge.toWorkerIndexBuffer.writeInt(wavefrontVertCount + 2);
			bridge.toWorkerIndexBuffer.writeInt(wavefrontVertCount + 3);
			
			bridge.toWorkerIndexBuffer.writeInt(wavefrontVertCount + 1);
			bridge.toWorkerIndexBuffer.writeInt(wavefrontVertCount + 0);
			bridge.toWorkerIndexBuffer.writeInt(wavefrontVertCount + 3);
			
			wavefrontVertCount += 4;
			
			partyStartup.simulation.addImmovable(ig = new ImmovableGate(  x, y + height, x , y) );
			
			
			
			
			
			bridge.toWorkerVertexBuffer.writeFloat(ig.x1);
			bridge.toWorkerVertexBuffer.writeFloat(16);
			bridge.toWorkerVertexBuffer.writeFloat(ig.y1);
			
			bridge.toWorkerVertexBuffer.writeFloat(ig.x0);
			bridge.toWorkerVertexBuffer.writeFloat(16);
			bridge.toWorkerVertexBuffer.writeFloat(ig.y0);
			
			bridge.toWorkerVertexBuffer.writeFloat(ig.x1);
			bridge.toWorkerVertexBuffer.writeFloat(-2);
			bridge.toWorkerVertexBuffer.writeFloat(ig.y1);
			
			bridge.toWorkerVertexBuffer.writeFloat(ig.x0);
			bridge.toWorkerVertexBuffer.writeFloat(-2);
			bridge.toWorkerVertexBuffer.writeFloat(ig.y0);
			
			bridge.toWorkerIndexBuffer.writeInt(wavefrontVertCount + 0);
			bridge.toWorkerIndexBuffer.writeInt(wavefrontVertCount + 2);
			bridge.toWorkerIndexBuffer.writeInt(wavefrontVertCount + 3);
			
			bridge.toWorkerIndexBuffer.writeInt(wavefrontVertCount + 1);
			bridge.toWorkerIndexBuffer.writeInt(wavefrontVertCount + 0);
			bridge.toWorkerIndexBuffer.writeInt(wavefrontVertCount + 3);
			
			wavefrontVertCount += 4;
			
			partyStartup.simulation.addImmovable(ig = new ImmovableGate(x + width, y + height, x, y + height) );

			
			bridge.toWorkerVertexBuffer.writeFloat(ig.x1);
			bridge.toWorkerVertexBuffer.writeFloat(16);
			bridge.toWorkerVertexBuffer.writeFloat(ig.y1);
			
			bridge.toWorkerVertexBuffer.writeFloat(ig.x0);
			bridge.toWorkerVertexBuffer.writeFloat(16);
			bridge.toWorkerVertexBuffer.writeFloat(ig.y0);
			
			bridge.toWorkerVertexBuffer.writeFloat(ig.x1);
			bridge.toWorkerVertexBuffer.writeFloat(-2);
			bridge.toWorkerVertexBuffer.writeFloat(ig.y1);
			
			bridge.toWorkerVertexBuffer.writeFloat(ig.x0);
			bridge.toWorkerVertexBuffer.writeFloat(-2);
			bridge.toWorkerVertexBuffer.writeFloat(ig.y0);
			
			bridge.toWorkerIndexBuffer.writeInt(wavefrontVertCount + 0);
			bridge.toWorkerIndexBuffer.writeInt(wavefrontVertCount + 2);
			bridge.toWorkerIndexBuffer.writeInt(wavefrontVertCount + 3);
			
			bridge.toWorkerIndexBuffer.writeInt(wavefrontVertCount + 1);
			bridge.toWorkerIndexBuffer.writeInt(wavefrontVertCount + 0);
			bridge.toWorkerIndexBuffer.writeInt(wavefrontVertCount + 3);
			
			wavefrontVertCount += 4;
			
			
			partyStartup.simulation.addImmovable( new ImmovableCircleOuter(x + r, y + r, r) );
			partyStartup.simulation.addImmovable( new ImmovableCircleOuter(x+width - r, y + r, r) );
			partyStartup.simulation.addImmovable( new ImmovableCircleOuter(x +width- r, y + height - r, r) );
			partyStartup.simulation.addImmovable( new ImmovableCircleOuter(x + r, y + height- r, r) );
			
			/*
			partyStartup.simulation.addImmovable( new ImmovableGate(x + width, y + height,  x + width, y) );
			partyStartup.simulation.addImmovable( new ImmovableGate( x + width, y, x , y) );
			partyStartup.simulation.addImmovable( new ImmovableGate(   x , y, x, y+height ));
			partyStartup.simulation.addImmovable( new ImmovableGate( x, y+height,x+width, y+height) );
			*/
		}
		
		public function getSeed(x:int, y:int):uint {
		
			var a:uint =  ( (y +RADIUS) * SQ_DIM + x + RADIUS);
			
			 a = (a ^ 61) ^ (a >> 16);
			a = a + (a << 3);
			a = a ^ (a >> 4);
			a = a * 0x27d4eb2d;
			a = a ^ (a >> 15);
			return a;
		}
		
		private function onEnterFrame(e:Event):void 
		{

			partyStartup.tickPreview();
		
			var diffX:Number = partyStartup.movableA.x;
			var diffY:Number = partyStartup.movableA.y;
			var sqDist:Number = diffX * diffX + diffY * diffY;
			
		
			if (sqDist >= updateWorldThreshold ) {
				recenter();
			}
			
			// async
			bridge.leaderPosBytes.position = 0;
			bridge.leaderPosBytes.writeFloat( partyStartup.movableA.x);
			bridge.leaderPosBytes.writeFloat( partyStartup.movableA.y);
			// sync
			_worker.setAgentX(3, partyStartup.movableA.x);
			_worker.setAgentZ(3, partyStartup.movableA.y);
			
			
			diffX -= lastLeaderX;
			diffY -= lastLeaderY;
			
			
			sqDist =  diffX * diffX + diffY * diffY;
			if (sqDist > 1) {
				lastLeaderX = partyStartup.movableA.x;
				lastLeaderY = partyStartup.movableA.y;
				onLeaderFootstep();
			
			}
			
			
			drawSyncAgents();	
			
		}

		
		
		private function drawSyncAgents():void
		{
			for ( var i:int = 0; i < agentSprites.length; i++ )
			{
				var agentPtr:uint = _worker.agentPtrs[i];
				//_worker.setAgentX(i, Math.random() * 32);
				//_worker.setAgentZ(i, Math.random() * 32);
				var ux:Number = _worker.getAgentX(i);
				var uz:Number = _worker.getAgentZ(i);
				agentSprites[i].x = ux;
				agentSprites[i].y = uz;
				//throw new Error([ux, uz]);
			}
		}
		

		
		
		
	}

}
import examples.scenes.Startup;
import flash.display.Shape;

class AgentSpr extends Shape {
	public function AgentSpr(color:uint=0xFF0000) {
		
		graphics.beginFill(color, 1);
		graphics.drawCircle(0, 0, Startup.SMALL_RADIUS);
		
	}
	
}