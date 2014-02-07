package recast
{
	import de.polygonal.math.PM_PRNG;
	import de.popforge.revive.forces.ArrowKeys;
	import de.popforge.revive.member.Immovable;
	import de.popforge.revive.member.ImmovableCircleOuter;
	import de.popforge.revive.member.ImmovableGate;
	import de.popforge.surface.io.PopKeys;
	import examples.scenes.Startup;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class MainRecast extends Sprite
	{
		public var MAX:uint;
		public var SQ_DIM:Number;
		public var RADIUS:Number;
		//[Embed(source="../../bin/flat.obj", mimeType="application/octet-stream")]
		//private var myObjFile:Class;
		
		private var _worker:MainRecastWorker;

		private var targetSprite:Sprite = new Sprite();
		//private var tiles:Array;
		private var agentSprites:Array = [];
		private var previewer:RecastPreviewer;
		
		
		private var partyStartup:Startup;
		
		private var prng:PM_PRNG = new PM_PRNG();
		
		public function MainRecast() 
		{
			
			super();
			
			_worker = new MainRecastWorker();
			
		//	_worker.loadFile( new myObjFile());
		//	_worker.createZone( new <Number>[], new <uint>[]);
			
			addChild(previewer = new RecastPreviewer());
			previewer.scaleX = 4;
			previewer.scaleY = 4;


			previewer.drawNavMesh(_worker.lib.getTiles());
			//previewer.drawMesh(_worker.lib.getTris(), _worker.lib.getVerts());
			
		//	_worker.addAgent(0, 0);
		
			MAX = PM_PRNG.MAX;
			SQ_DIM = Math.sqrt(MAX);
			RADIUS = SQ_DIM * .5;
			
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);
			PopKeys.initStage(stage);
		
			Startup.LARGE_RADIUS = 2;
			Startup.SMALL_RADIUS = Startup.LARGE_RADIUS * .45 ;

			updateWorldThreshold = 2 * TILE_SIZE;
			updateWorldThreshold *= updateWorldThreshold;
			
			partyStartup = new Startup();
			//partyStartup.targetSpringRest = Startup.LARGE_RADIUS *2;
			partyStartup.setFootstepThreshold(2);
			partyStartup.simulation.addForce(new ArrowKeys(partyStartup.movableA, .05));
			partyStartup.manualInit2DPreview(previewer);
			partyStartup.movableA.x = 0;
			partyStartup.movableA.y = 0;
			
			addEventListener(Event.ENTER_FRAME, onEnterFrame);

			setWorldCenter(0, 0);
			
			
		}
		
		private function getSeededVal(seed:uint):Number {
			prng.seed = seed;
			return prng.nextDouble();
		}
		
		
		private function setWorldCenter(x:Number, y:Number):void 
		{
			_worldX = x;
			_worldY =  y;
			createRandomObstacles(x, y);
		}
	
		private var NUM_TILES_ACROSS:Number = 8;
		private var TILE_SIZE:Number = 16;
		private var WORLD_TILE_SIZE:Number = TILE_SIZE * NUM_TILES_ACROSS;
		private var _worldX:Number;
		private var _worldY:Number;
		private var updateWorldThreshold:Number;
		
		private function createRandomObstacles(worldX:Number, worldY:Number):void {
			
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
					//if (getSeed(x, y) == prng.seed) throw new Error("SHOULD BE UNIQUE!");
					prng.seed =  getSeed(x, y);
				
					var ly:Number = y*TILE_SIZE - worldY;
					var val:Number = prng.nextDouble();
					if ( val > 0.6) { // tree stump
				//	addBox(x*TILE_SIZE,y*TILE_SIZE,16,16 );
						addBox(prng.nextDoubleRange(Startup.LARGE_RADIUS+lx, lx + TILE_SIZE - Startup.LARGE_RADIUS),  prng.nextDoubleRange(Startup.LARGE_RADIUS+ly, ly + TILE_SIZE - Startup.LARGE_RADIUS), Startup.LARGE_RADIUS, Startup.LARGE_RADIUS  );
					}
					else if (val > 0.2) {  // sandbag
						addBox(lx,ly,6,3 );
					}
					else {  // solid full block
						addBox(lx,ly,16,16 );
					}
					
					
				}
			}
			
		//	throw new Error([xMin, xMax, yMin, yMax]);
	
			partyStartup.redrawImmovables();
			
		}
		
		private function addBox(x:Number, y:Number, width:Number, height:Number):void {
			partyStartup.simulation.addImmovable( new ImmovableGate( x + width, y, x + width, y + height) );
			partyStartup.simulation.addImmovable( new ImmovableGate( x , y, x + width, y) );
			partyStartup.simulation.addImmovable( new ImmovableGate(  x, y+height, x , y) );
			partyStartup.simulation.addImmovable( new ImmovableGate(x + width, y + height, x, y + height) );
			
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
			var diffX:Number = partyStartup.movableA.x - _worldX;
			var diffY:Number = partyStartup.movableA.y - _worldY;
			if (diffX * diffX + diffY * diffY >= updateWorldThreshold ) {
				
				setWorldCenter(partyStartup.movableA.x, partyStartup.movableA.y);
				partyStartup.displaceMovables(-diffX, -diffY);
			}
			partyStartup.tickPreview();
		}

		
		
		private function drawAgents():void
		{
			for ( var i:int = 0; i < agentSprites.length; i++ )
			{
				var agentPtr:uint = _worker.lib.getAgentPosition(agentSprites[i].idx);
				
				var ux:Number = _worker.getAgentX(i);
				var uz:Number = _worker.getAgentZ(i);
				agentSprites[i].x = ux;
				agentSprites[i].y = uz;
			}
		}
		

		
		
		
	}

}