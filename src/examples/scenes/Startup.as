package examples.scenes
{
	import de.popforge.revive.application.SceneContainer;
	import de.popforge.revive.display.IDrawAble;
	import de.popforge.revive.forces.*;
	import de.popforge.revive.geom.Vec2D;
	import de.popforge.revive.member.*;
	import de.popforge.revive.resolve.DynamicIntersection;
	import de.popforge.revive.resolve.IDynamicIntersectionTestAble;
	import de.popforge.surface.io.PopKeys;
	import examples.scenes.test.MovableChar;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.geom.Point;
	import flash.ui.Keyboard;

	/*  
	 
	ROADMAP:
	
	PHASE 1: Within blob
	- Test Wedge Followers 3D / 2D
	
	  -  unlink members that do not have a footing ( determine this with tribit check against bitgrid and fake-slide them down by trinormal,  (or with actual bot movement) until they've halted their velocity (ie. exited the triangle or blocked) and so the force can be removed.
			Do not re-add the force in the next frame, unless he ventures into another new triangle.
	   - disable foosteps when leader has no footing (eg. sliding off slope), or continue to add foosteps there..not sure which is better..
	   but the latter approach would mean members would "foolishly" follow leader and slide down slope with him. Perhaps,
	   they need to consider the extent of the "fall" and determine if it's wise to slide down with him, or not fall off at all.	 
		  
		What happens if they can't find foosteps towards leader?
		- terrain edge pathfinding as a final resort if footsteps cannot be found. Simply use heightmap to determine traversability of edge slopes.
			- Cop out teleport. So long as you look away from follower, follower will teleport behind you when you turn around..
			 (or , if this case  is rare,.....consider losing a command point to move follower as well..assuming he was genuinely lost, especially in cases where there is no clear safe path for him to follow leader)
	
		__________________
	To do the above:
			 	- Leader position is a fixed spring position. Create blocking triangles for all members (ie.sloping triangles), when trying to find path-find towards leader. When a leader enters a steep triangle, no footstep is recorded, and since he's inside a solid tri-block, and so links will automatically be broken. 
		- All members should temporarily halt at this time, and avoid even linking to the next leader's foostep.
		- Once leader regains a footing, attempt to resolve this by regular following procedures, or pathfinding if regular following procedures fail.  Realistically, members should be able to visually see leader in order to execute pathfinding to his location, and the route towards the leader should be something his trekking skill can handle. Otherwise , a command point is effectivley lost having to micromanage that member that was "lost". If the sliding down is deemed "safe", a regular following procedure can be used by disabling the triangle for members wishing to slide down, running straight towards the leader, ignoring the triangle. 
		- At anytime where no striaght route towards leader can be found, have to use pathfinding.
	
	 
	- Do up follower spread out recovery check and resolution. Test 2D/3D.
	   -Clean up foostep memory
	- Do up Column followers lock
	- Do up strict circle formation.
	
	PHASE 2: Outside Blob
	- Do up strict block formation with timed rotation mechanics.
	- Extend followers outside blob for Column (should be trivial)
	- Extend followers outside blob for Wedge (need to test this.).
	
	NOTES:
	____________	
	Within Blob: ( <= 4-man team)
	1) Strict Circle formation (fully rotatable formation with minimal/zero rotation time penalty)
	2) Wedge followers (vanguard-leading, will still use columns/semi-columns in certain areas)
	3) Column followers (fixed column with either vanguard/rearguard leading movement)
	____________
	Outside Blob ( > 4-men)
	1) Strict Block Formation
	2) Wedge follower extension (vanguard leading, will still use columns/semi-columns in certain areas)
	3) Column followers extension (fixed column with either vanguard/rearguard leading movement)
	*/
			
	public class Startup extends SceneContainer
	{
		
		private var personA:Person = new Person(MovableChar.COLORS[0], "leader", SMALL_RADIUS);
		private var personB:Person = new Person(MovableChar.COLORS[1], "person b", SMALL_RADIUS);
		private var personC:Person = new Person(MovableChar.COLORS[2], "person c", SMALL_RADIUS);
		private var personD:Person = new Person(MovableChar.COLORS[3], "person d", SMALL_RADIUS);
		private var footing:int = new Vector.<int>(3,true);
		
		public function Startup()
		{
			super();
			simulation.globalDrag = 1;
			simulation.globalForce = new Vec2D(0, 0);
			
			if (stage)  createScene();
			createParty();
			
			if (stage)  createStageBounds();
			if (stage)  drawImmovables();
			
			if (stage) {
				addChild(personA);
				addChild(personB);
				addChild(personC);
				addChild(personD);
			}
			
			if (stage) {
				stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
				PopKeys.initStage(stage);
			}
		}
		
		public function manualInit2DPreview(cont:Sprite):void {
			cont.addChild(this);
			addChild(personA);
			addChild(personB);
			addChild(personC);
			addChild(personD);
		}
		
		private function createParty():void 
		{
			var pos:Array = POSITIONS_COLUMN_JITTERD;
			
			var mainhead:Number = LARGE_RADIUS ;
			movableA = new MovableChar( pos[0].x, pos[0].y, SMALL_RADIUS, 0 );
			
			simulation.addMovable( movableA );
			movableB = new MovableChar( pos[1].x, pos[1].y, LARGE_RADIUS , 1 );
			simulation.addMovable( movableB );
			movableC = new MovableChar( pos[2].x, pos[2].y, LARGE_RADIUS, 2 );
			simulation.addMovable( movableC );
			movableD = new MovableChar( pos[3].x, pos[3].y, LARGE_RADIUS, 3 );
			simulation.addMovable( movableD );
			
			personA.x = movableA.x; personA.y = movableA.y;
			personB.x = movableB.x; personB.y = movableB.y;
			personC.x = movableC.x; personC.y = movableC.y;
			personD.x = movableD.x; personD.y = movableD.y;
	
			memberCircleLookup.push(movableB);
			memberCircleLookup.push(movableC);
			memberCircleLookup.push(movableD);
					
			memberCharLookup.push(personB);
			memberCharLookup.push(personC);
			memberCharLookup.push(personD);
			
			footsteps.push(movableA.x);
			footsteps.push(movableA.y);
			
			if (stage) simulation.addForce(new ArrowKeys(movableA));
			
			var force: IForce;
			var tension:Number =1;
			
			targetSpringRest =  mainhead * 2 + 1;
			var restLength:Number = targetSpringRest;// -1;// mainhead * 2 + 1;
			
			if (!FOLLOW_LEADER_SPRING) {
				force = new Spring( movableA, movableB, tension);
				simulation.addForce( force );
				springs.push(force);
				
				force = new Spring( movableB, movableC, tension);
				simulation.addForce( force );
				springs.push(force);
				
				force = new Spring( movableC, movableD, tension);
				simulation.addForce( force );
				springs.push(force);
			}
			else {
			
				
				force = new FixedSpring( movableA.x, movableA.y, movableB, tension);
				simulation.addForce( force );
				springs.push(force);
				fixedSprings.push(force);
				
				force = new FixedSpring( movableA.x, movableA.y, movableC, tension);
				simulation.addForce( force );
				springs.push(force);
				fixedSprings.push(force);
				
				force = new FixedSpring( movableA.x, movableA.y, movableD, tension );
				simulation.addForce( force );
				springs.push(force);
				fixedSprings.push(force);
				
				/*
				force = new Spring( movableB, movableC, tension);
				simulation.addForce( force );
				
				force = new Spring( movableD, movableB, tension);
				simulation.addForce( force );
				
				force = new Spring( movableD, movableC, tension);
				simulation.addForce( force );
				*/
				
			}
			
			//simulation.addMovable( new MovableCircle(13, 13, 4) );
			//simulation.addMovable( new MovableCircle(13, 23, 4) );
			
		}
		
		private function onKeyDown(e:KeyboardEvent):void 
		{
			var kc:uint = e.keyCode;
			
			if (kc === Keyboard.P) {  // test person BCD spread out
				var spr:Spring;
				springs.push(spr = new Spring(movableB, movableD, 1) );
				simulation.addForce(spr);
				springs.push(spr = new Spring(movableC, movableD, 1) );
				simulation.addForce(spr);
			}
			
		}
		
		
		private var POSITIONS_COLUMN:Array = [ 
			new Point(256, 96),
			new Point(256, 128),
			new Point(256, 160),
			new Point(256, 192) 
		];
		
		private var POSITIONS_COLUMN_STAGGERED:Array = [ 
			new Point(256+16, 96),
			new Point(256-16, 128),
			new Point(256+16, 160),
			new Point(256-16, 192) 
		];
		private var POSITIONS_COLUMN_JITTERD:Array = [ 
			new Point(256+4, 96),
			new Point(256-4, 128),
			new Point(256+4, 160),
			new Point(256-4, 192) 
		];
		
		
		private var POSITIONS_WEDGE:Array = [ 
			new Point(256, 96),
			new Point(256-32, 96+32),
			new Point(256+32, 96+32),
			new Point(256, 96+64) 
		];
		
		private var POSITIONS_BLOCK:Array = [ 
			new Point(256, 96),
			new Point(256, 128),
			new Point(256, 160),
			new Point(256, 192) 
		];
		
		private static var FOLLOW_LEADER_SPRING:Boolean = true;
		public var movableA:MovableCircle;
		public var movableB:MovableCircle;
		public var movableC:MovableCircle;
		public var movableD:MovableCircle;
		
		
		private var testCircle:MovableCircle = new MovableCircle(0, 0, 3);
		
		private var invalidMembers:Vector.<int> = new Vector.<int>();
		private var validMembers:Vector.<int> =  new Vector.<int>();
		private var memberCircleLookup:Vector.<MovableCircle> = new Vector.<MovableCircle>();
		private var memberCharLookup:Vector.<Person> = new Vector.<Person>();
		
		private var fixedSprings:Array = [];
		
		private function switchSpring(index:int, force:IForce):* {
			if (springs[index] === force) return;
			simulation.removeForce(springs[index]);
			simulation.addForce(force);
			springs[index] = force;
			var forcer:Object = (force as Object);
			forcer.autoSetRestLength();
			//if (forcer.restLength != (forcer.targetLength >= 0 ? forcer.targetLength : for
			return force;
		}
		
		
	
		private var freqFootsteps:int = 0;
		private var footsteps:Vector.<Number> = new Vector.<Number>();
		
		
		public function tick():void {
			onEnterFrame(null);
		}
		
		private static const DUMMY_EVENT:Event = new Event("enterFrame");
		public function tickPreview():void {
			onEnterFrame(DUMMY_EVENT);
		}
		
		override protected function onEnterFrame( event: Event ): void
		{
			var i:int;
			
			// for any small radius person following the leader, check if can expand radius out and still fit within environment. Does expanding radius out collide with other players from B,C,D? If so, add temporary spring out links between them.
			
			var numValid:int = 0;
			var numInvalid:int = 0;
			

			
			
			if (enableFootsteps) {
				var lastX:Number = footsteps[footsteps.length - 2];
				var lastY:Number = footsteps[footsteps.length - 1];
				lastX  = movableA.x - lastX;
				lastY  = movableA.y - lastY;
				lastX *= lastX;
				lastY *= lastY;
				if (lastX + lastY > footStepThreshold) {
					footsteps.push(movableA.x);
					footsteps.push(movableA.y);
				}
			}

			
			// check valid links
			//for each(var obstacle:IDynamicIntersectionTestAble in simulation.immovables) {
				if ( checkLinkToLeaderBlocked( movableB, personB, movableB.r ) ) {
					if (movableB.r != SMALL_RADIUS) {
						movableB.r = SMALL_RADIUS;
						if (checkLinkToLeaderBlocked( movableB, personB, SMALL_RADIUS-4)) {
							// add to invalid
							invalidMembers[numInvalid++] = 0; 
						}
						else {
							// add to valid
							validMembers[numValid++] = 0;
							switchSpring(0, fixedSprings[0]);
							
						}
					}
					else { // add to invalid
						
						
						invalidMembers[numInvalid++] = 0; 

					}
				}
				else {
							// add to valid
					validMembers[numValid++] = 0;
						switchSpring(0, fixedSprings[0]);
							
				}
						
				if ( checkLinkToLeaderBlocked( movableC, personC,  movableC.r  ) ) {
					if (movableC.r != SMALL_RADIUS) {
						movableC.r = SMALL_RADIUS;
						if (checkLinkToLeaderBlocked( movableC, personC, SMALL_RADIUS-4)) {
							// add to invalid
							invalidMembers[numInvalid++] = 1; //throw new Error("C");
						}
						else {
							// add to valid
							validMembers[numValid++] = 1;
							switchSpring(1, fixedSprings[1]);
						}
					}
					else { // add to invalid
						
						
						invalidMembers[numInvalid++] = 1; 

					}
				}
				else {
							// add to valid
					validMembers[numValid++] = 1;
						switchSpring(1, fixedSprings[1]);
							
				}
				
				if ( checkLinkToLeaderBlocked( movableD, personD,  movableD.r  ) ) {
					if (movableD.r != SMALL_RADIUS) {
						movableD.r = SMALL_RADIUS;
						if ( checkLinkToLeaderBlocked( movableD, personD, SMALL_RADIUS-4)) {
							// add to invalid
							invalidMembers[numInvalid++] = 2;// throw new Error("D");
							
						}
						else {
							// add to valid
							validMembers[numValid++] = 2;
							switchSpring(2, fixedSprings[2]);
						}
					}
					else{ // add to invalid
						invalidMembers[numInvalid++] = 2; 

					}
				}
				else {
					// add to valid
					validMembers[numValid++] = 2;
					switchSpring(2, fixedSprings[2]);
							//throw new Error("A");
				}
			//}
			
			var index:int;
			var u:int;
			for (i = 0; i < numInvalid; i++) {
				
				index = invalidMembers[i];
				u = numValid;
				var resolved:Boolean = false;
				while (--u > -1) {
					if ( checkLinkToLeaderBlocked(memberCircleLookup[index], memberCharLookup[index], SMALL_RADIUS, memberCircleLookup[validMembers[u]] ) ) {
						
						
					}
					else {
						validMembers[numValid++] = index;
						
						switchSpring(index, new Spring(memberCircleLookup[index], memberCircleLookup[validMembers[u]], 1) );
						
						resolved = true;
						break;
					}
				}
				
				
				if (!resolved) {
				//	simulation.removeForce(springs[index]);
					//springs[index] = NULL_SPRING;
					
					
					var f:int = footsteps.length;
					f -= 2;
					while (f >= 0) {
						
						testLeader.x =  footsteps[f];
						testLeader.y = footsteps[f + 1];
						if (!checkLinkToLeaderBlocked(memberCircleLookup[index], memberCharLookup[index], SMALL_RADIUS-2, testLeader) ) {
							switchSpring(index, new FixedSpring(testLeader.x, testLeader.y, memberCircleLookup[index], 1) );
							
							springs[index].targetLength = 0.1;
							resolved = true;
							break;
						}
						f -= 2;
					}
					
					if (!resolved) {
						switchSpring(index, NULL_SPRING);
					}
					
					
					
					
					/*
					if (numValid > 0) {

						springs[index] = new Spring(memberCircleLookup[index], memberCircleLookup[validMembers[numValid-1]], 1);
						simulation.addForce(springs[index]);
							validMembers[numValid++] = index;
						resolved = true;
					}
					else {
						
					
						switchSpring( 0, new Spring( movableA, movableB, 1) );
						switchSpring( 1, new Spring( movableB, movableC, 1) );
						switchSpring( 2, new Spring( movableC, movableD, 1) );
						
						
						//simulation.removeForce(springs[index]);
						
						
						
						
					}
					*/
					
						
				}
				
			}
			
			
			
	
			
			i = springs.length;
			while (--i > -1) {
				transitSpringLength(springs[i], targetSpringRest);
				
			}
		
			super.onEnterFrame(event);
		//	if (movableA.velocity.length() ) throw new Error(movableA.velocity);
			/*
			mShape.graphics.beginFill(0xFF0000, 1);
			var len:int = footsteps.length;
			for (var p:int = 0; p < len; p+=2 ) 
			{
				//drawAble.draw( mShape.graphics );
				mShape.graphics.drawCircle( footsteps[p], footsteps[p + 1], 2);
			}
			*/
			
			i = fixedSprings.length;
				while (--i > -1) {
					
						
						fixedSprings[i].x = movableA.x;
						fixedSprings[i].y = movableA.y;
					
					
				}
				
			// move guys to match formation points
			personA.x = movableA.x; personA.y = movableA.y;
			personB.moveToTargetLocation(movableB.x, movableB.y);
			personC.moveToTargetLocation(movableC.x, movableC.y);
			personD.moveToTargetLocation(movableD.x, movableD.y);
			
			//
			
			
			// check for temporary BCD springs that can afford to be removed (ie. completed)
		}
		
		private var testLeader:MovableCircle = new MovableCircle(1, 1, 1);
		
		private function checkLinkToLeaderBlocked(movable:MovableCircle, person:Person, radius:Number, customLeader:MovableCircle=null):Boolean 
		{
			
			//radius -= 2;
			
			if (!customLeader) customLeader = movableA;
		
			for each(var obstacle:IDynamicIntersectionTestAble in simulation.immovables) {
				
				//if (!(obstacle is ImmovableCircleOuter) ) return false
				testCircle.x = movable.x;
				testCircle.y = movable.y;
				testCircle.r = radius;
				testCircle.velocity.x = customLeader.x - movable.x;
				testCircle.velocity.y = customLeader.y - movable.y;
				var dist:Number = testCircle.velocity.length();
				
				testCircle.velocity.scale( (dist - testCircle.r - (obstacle is ImmovableCircleOuter ?  (obstacle as ImmovableCircleOuter).r : 0 )  ) / dist );
				
				var intersect:DynamicIntersection = obstacle.dIntersectMovableCircle(testCircle, 1);
				//if (intersect) throw new Error(intersect.dt + ", "+person.name);
				if ( intersect != null) return true;
				
			}
			return false;
		}
		
		
		
		
		
		private var springs:Array = [];
		private var footStepThreshold:Number = 16 * 16;
		public function setFootstepThreshold(val:Number):void {
			footStepThreshold = val * val;
		}
		public var targetSpringRest:Number;
		public var enableFootsteps:Boolean = true;
		
		public function transitSpringLength(spring:*, targetSpringRest:Number):void {
			if (spring.targetLength >= 0) {
				targetSpringRest = spring.targetLength;
			}
				
			var decresing:Boolean = targetSpringRest <= spring.restLength;
			var diff:Number = decresing ? spring.restLength - targetSpringRest : targetSpringRest - spring.restLength;
			spring.restLength += (decresing  ? -1 : 1);
			if (diff < 1) spring.restLength = targetSpringRest;
			
			
		}
		
		public static var LARGE_RADIUS:Number = 16;
		public static var SMALL_RADIUS:Number = LARGE_RADIUS * .45;

		static public const NULL_SPRING:Spring = new Spring( new MovableCircle(0,0,2), new MovableCircle(1,1,2) );
		
		public function createScene(): void
		{
			
			
			var movableCircle: ImmovableCircleOuter;
			movableCircle = new ImmovableCircleOuter( 128, 196, 8 );
			simulation.addImmovable( movableCircle );
			movableCircle = new ImmovableCircleOuter( 64, 196, 16 );
			simulation.addImmovable( movableCircle );
			movableCircle = new ImmovableCircleOuter( 160, 196, 8 );
			simulation.addImmovable( movableCircle );
			movableCircle = new ImmovableCircleOuter( 196+16, 196, 16 );
			simulation.addImmovable( movableCircle );
			var i:int = 44;
			while (--i > -1) {
				movableCircle = new ImmovableCircleOuter( Math.random()*400, 220+Math.random()*200, 16 );
			simulation.addImmovable( movableCircle );
			}
			

			
			var immovable: Immovable;
			
			//-- just some immovables
			immovable = new ImmovableCircleInnerSegment( 128, HEIGHT - 128, 128, Math.PI/2, Math.PI );
			simulation.addImmovable( immovable );
			immovable = new ImmovableCircleInnerSegment( 128, 128, 128, Math.PI, -Math.PI/2 );
			simulation.addImmovable( immovable );
			immovable = new ImmovableCircleOuterSegment( WIDTH - 64, HEIGHT/2, 64, Math.PI, -Math.PI/2 );
			simulation.addImmovable( immovable );
			immovable = new ImmovableGate( WIDTH - 64, HEIGHT/2 - 64, WIDTH, HEIGHT/2 - 64 );
			simulation.addImmovable( immovable );
			immovable = new ImmovablePoint( WIDTH - 128, HEIGHT/2 );
			simulation.addImmovable( immovable );
			immovable = new ImmovableGate( WIDTH, HEIGHT/2, WIDTH - 128, HEIGHT/2 );
			simulation.addImmovable( immovable );
			immovable = new ImmovableBezierQuadric( WIDTH/2, HEIGHT, WIDTH-192, HEIGHT/2, WIDTH, HEIGHT, false );
			simulation.addImmovable( immovable );
		}
		
		public function redrawImmovables():void 
		{
			iShape.graphics.clear();
			drawImmovables();
		}
		
		public function displaceMovables(x:Number, y:Number):void 
		{
			movableA.x += x;
			movableB.x += x;
			movableC.x += x;
			movableD.x += x;
		
			
			movableA.y += y;
			movableB.y += y;
			movableC.y += y;
			movableD.y += y;
			
			if (movableA.x != 0 || movableA.y!=0) throw new Error("SHOULD NOT BE!:"+movableA.x + ", "+movableA.y);
		var i:int = fixedSprings.length;
				while (--i > -1) {
					
						
						fixedSprings[i].x = movableA.x;
						fixedSprings[i].y = movableA.y;
					
					
				}
			
			personA.x = movableA.x; personA.y = movableA.y;
			/*	
			personB.x = movableB.x; personB.y = movableB.y;
			
			personC.x = movableA.x; personC.y = movableC.y;
			
			personD.x = movableD.x; personD.y = movableD.y;
			*/
			
		}
	}
}
import flash.display.Sprite;
import flash.geom.Vector3D;

class Person extends Sprite {
	
	private var forwardVec:Vector3D = new Vector3D();
	public var speed:Number;
	public var speedCap:Number;
	

	
	public function Person(color:uint, name:String, radius:Number, speed:Number=222) {
		this.speed = speed;
		graphics.beginFill(color, 1);
		graphics.drawCircle(0, 0, radius  );
		this.name = name;
	}
	
	public function moveToTargetLocation(targetX:Number, targetY:Number):void {
		forwardVec.x = (targetX - x)
		forwardVec.y = (targetY - y);
		if (forwardVec.lengthSquared > speed*speed) {
			forwardVec.normalize();
			forwardVec.x *= speed;
			forwardVec.y *= speed;
			x += forwardVec.x;
			y += forwardVec.y;
		}
		else {
			x = targetX;
			y = targetY;
		}
		
		
		 
	}
	
}