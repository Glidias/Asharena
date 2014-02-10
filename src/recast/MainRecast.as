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
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.net.FileReference;
	import flash.ui.Keyboard;
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class MainRecast extends Sprite
	{
		public var MAX:uint;
		public var SQ_DIM:Number;
		public var RADIUS:Number;
		
		
		private var _worker:MainRecastWorker;

		private var targetSprite:Sprite = new Sprite();
		//private var tiles:Array;
		private var agentSprites:Array = [];
		private var previewer:RecastPreviewer;
		
		private var preferedPositions:Vector.<int> = new Vector.<int>(3, true);
		
		
		private var partyStartup:Startup;
		
		private var prng:PM_PRNG = new PM_PRNG();
		
		// [SWF(width="800", height="600", frameRate="60")]
		public function MainRecast() 
		{
			
			super();
						MainRecastWorker.MAX_AGENTS = 8;
			
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			

			MainRecastWorker.MAX_SPEED = 5.2*1.6
			MainRecastWorker.MAX_ACCEL = 10.0*16
			MainRecastWorker.MAX_AGENT_RADIUS =1.02;// 0.24 * 5;
			_worker = new MainRecastWorker();
			
			
		//	_worker.loadFileBytes( new myObjFile());
			
			
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
			_worker.initCrowd();
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
	
		
			
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
			
			drawAgents();
			
			
			previewer.addChild(_worker);
			
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
			_worldY =  y;
			createRandomObstacles(x, y, dx,dy);
			
		}
	
		private var NUM_TILES_ACROSS:Number = 8;
		private var TILE_SIZE:Number = 16;
		private var WORLD_TILE_SIZE:Number = TILE_SIZE * NUM_TILES_ACROSS;
		private var _worldX:Number;
		private var _worldY:Number;
		private var updateWorldThreshold:Number;
		
		private function createRandomObstacles(worldX:Number, worldY:Number, dx:Number, dy:Number):void {
			
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

		
		removeEventListener(Event.ENTER_FRAME, onEnterFrame);
		PopKeys.reset();

			
		_worker.addEventListener(MainRecastWorker.BUILD_DONE, onWorkerBulidDone);
		
			_worker.createZoneWithWavefront(wavefrontVertBuffer, wavefrontPolyBuffer, _worldX, _worldY, dx, dy);
			
			
			
			wavefrontVertBuffer = "";
			wavefrontPolyBuffer = "";
			wavefrontVertCount = 5;
			
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
		
		private var wavefrontVertBuffer:String = "";
		private var wavefrontPolyBuffer:String = "";
		private var wavefrontVertCount:int = 5;
		private var lastLeaderX:Number = 0;
		private var lastLeaderY:Number = 0;
		
		private function addBox(x:Number, y:Number, width:Number, height:Number):void {
			var r:Number = Startup.SMALL_RADIUS;
			var ig:ImmovableGate;
			partyStartup.simulation.addImmovable(ig = new ImmovableGate( x + width, y, x + width, y + height) );
			
			
			wavefrontVertBuffer += "\nv " + ig.x1 + " 16 " + ig.y1;
			wavefrontVertBuffer += "\nv " + ig.x0 + " 16 " + ig.y0;
			
			wavefrontVertBuffer += "\nv " + ig.x1 + " -2 " + ig.y1;
			wavefrontVertBuffer += "\nv " + ig.x0 + " -2 " + ig.y0;
			wavefrontPolyBuffer += "\nf " + (wavefrontVertCount + 0) + " " + (wavefrontVertCount + 2) + " "+(wavefrontVertCount + 3);
			wavefrontPolyBuffer += "\nf "+(wavefrontVertCount+1)+" "+(wavefrontVertCount+0)+" "+(wavefrontVertCount+3);
			wavefrontVertCount += 4;
			
			
			partyStartup.simulation.addImmovable(ig = new ImmovableGate( x , y, x + width, y) );
			
			
			wavefrontVertBuffer += "\nv " + ig.x1 + " 16 " + ig.y1;
			wavefrontVertBuffer += "\nv " + ig.x0 + " 16 " + ig.y0;
			
			wavefrontVertBuffer += "\nv " + ig.x1 + " -2 " + ig.y1;
			wavefrontVertBuffer += "\nv " + ig.x0 + " -2 " + ig.y0;
			wavefrontPolyBuffer += "\nf " + (wavefrontVertCount + 0) + " " + (wavefrontVertCount + 2) + " "+(wavefrontVertCount + 3);
			wavefrontPolyBuffer += "\nf "+(wavefrontVertCount+1)+" "+(wavefrontVertCount+0)+" "+(wavefrontVertCount+3);
			wavefrontVertCount += 4;
			
			
			partyStartup.simulation.addImmovable(ig = new ImmovableGate(  x, y + height, x , y) );
			
			
			
			
			wavefrontVertBuffer += "\nv " + ig.x1 + " 16 " + ig.y1;
			wavefrontVertBuffer += "\nv " + ig.x0 + " 16 " + ig.y0;
			
			wavefrontVertBuffer += "\nv " + ig.x1 + " -2 " + ig.y1;
			wavefrontVertBuffer += "\nv " + ig.x0 + " -2 " + ig.y0;
			wavefrontPolyBuffer += "\nf " + (wavefrontVertCount + 0) + " " + (wavefrontVertCount + 2) + " "+(wavefrontVertCount + 3);
			wavefrontPolyBuffer += "\nf "+(wavefrontVertCount+1)+" "+(wavefrontVertCount+0)+" "+(wavefrontVertCount+3);
			wavefrontVertCount += 4;
			
			partyStartup.simulation.addImmovable(ig = new ImmovableGate(x + width, y + height, x, y + height) );
		
			
			wavefrontVertBuffer += "\nv " + ig.x1 + " 16 " + ig.y1;
			wavefrontVertBuffer += "\nv " + ig.x0 + " 16 " + ig.y0;
			
			wavefrontVertBuffer += "\nv " + ig.x1 + " -2 " + ig.y1;
			wavefrontVertBuffer += "\nv " + ig.x0 + " -2 " + ig.y0;
			
			wavefrontPolyBuffer += "\nf " + (wavefrontVertCount + 0) + " " + (wavefrontVertCount + 2) + " "+(wavefrontVertCount + 3);
			wavefrontPolyBuffer += "\nf "+(wavefrontVertCount+1)+" "+(wavefrontVertCount+0)+" "+(wavefrontVertCount+3);
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
			
			var diffX:Number = partyStartup.movableA.x;
			var diffY:Number = partyStartup.movableA.y;
			var sqDist:Number = diffX * diffX + diffY * diffY;
			
		
			if (sqDist >= updateWorldThreshold ) {
				recenter();
			}
			
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
			
		//	partyStartup.tickPreview();
			drawAgents();
			
			
			
		}

		
		
		private function drawAgents():void
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