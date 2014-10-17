package arena.systems.enemy;
import arena.components.char.AggroMem;
import arena.components.char.EllipsoidPointSamples;
import arena.components.char.HitFormulas;
import arena.components.enemy.EnemyAggro;
import arena.components.enemy.EnemyIdle;
import arena.components.enemy.EnemyWatch;
import arena.components.weapon.Weapon;
import arena.systems.enemy.AggroMemNode;
import arena.systems.player.IVisibilityChecker;
import arena.systems.player.IWeaponLOSChecker;
import arena.systems.player.PlayerAggroNode;
import ash.core.Engine;
import ash.core.Entity;
import ash.core.NodeList;
import ash.signals.Signal0;
import ash.signals.Signal1;
import components.Health;
import components.Pos;
import components.Rot;
import components.tweening.Tween;
import de.polygonal.ds.BitVector;
import flash.errors.Error;
import flash.Vector.Vector;
import util.geom.PMath;



/**
 * Phased combat aggro memory manager/controller that runs manually on phaseStart, turnStart and turnEnd,
 * events outside of enterFrame update loop.
 * 
 * @see arena.components.char.AggroMem
 * 
 * @author Glenn Ko
 */
class AggroMemManager
{
	private var engine:Engine;
	
	public var playerAggroList:NodeList<PlayerAggroNode>;
	public var aggroList:NodeList<EnemyAggroNode>;
	public var watchList:NodeList<EnemyWatchNode>;
	public var idleList:NodeList<EnemyIdleNode>;
	public var idleNodeRemovedSignal:Signal1<EnemyIdleNode>;  // for dispatching cases where idle enemies become alert
	
	public var memList:NodeList<AggroMemNode>;  // keeps track of all currently alive entities

	// For phase
	public var activeArray:Vector<AggroMemNode>;
	public var aggroArray:Vector<AggroMemNode>;
	private var numActive:Int;
	private var numAggro:Int;
	private var activeSide:Int;
	
	// misc
	private var idleMask:BitVector;
	private var testPos:Pos;
	
	// For turn
	private var curPlayerIndex:Int;

	
	public function new() 
	{
		
		
	}
		
	// init
	public function init(engine:Engine, weaponLOSChecker:IWeaponLOSChecker, visibilityChecker:IVisibilityChecker=null):Void {
		this.weaponLOSChecker = weaponLOSChecker;
		this.engine = engine;
		this.visibilityChecker = visibilityChecker;
		//engine.getNodeList(
		
		aggroList = engine.getNodeList(EnemyAggroNode);
		watchList = engine.getNodeList(EnemyWatchNode);
		idleList = engine.getNodeList(EnemyIdleNode);
		playerAggroList = engine.getNodeList(PlayerAggroNode);
		
		memList = engine.getNodeList(AggroMemNode);
		
		activeArray = new Vector<AggroMemNode>();
		aggroArray = new Vector<AggroMemNode>();
		numActive = 0;
		numAggro = 0;
		
		idleNodeRemovedSignal = new Signal1<EnemyIdleNode>();
		
		idleMask = new BitVector(32);
		testPos = new Pos();
		
		_dummyPlayerNode = new PlayerAggroNode();
		
	}
	
	// Manually invoked methods
	

	
	public inline function isIdle(aggroMem:AggroMem):Bool {
		return !idleMask.has(aggroMem.index);
	}
	
	public inline function addToAggroMem(playerEntity:Entity, aggroEntity:Entity):Void {
		var aggroMem:AggroMem = aggroEntity.get(AggroMem);
		var playerMem:AggroMem = playerEntity.get(AggroMem);
		if (!aggroMem.bits.has(playerMem.index)) {
			aggroMem.bits.set(playerMem.index);
			if(_turnActive) aggroEntity.add(new EnemyWatch().init(aggroMem.watchSettings, playerAggroList.head) , EnemyWatch);
		}
		
	}
	
	public function notifyStartPhase(side:Int):Void {
		numActive= 0;
		numAggro= 0;
		
		this.activeSide = side;
		
		// refresh list of active/aggro entities that are alive at the start of the phase (indexing them), clean up their aggro memory 
		var am:AggroMemNode = memList.head;
		while (am != null) {
			am.mem.bits.resize(32);
			am.mem.bits.clrAll();
			
			if (am.mem.side != side) {
				am.mem.index = numAggro;
				aggroArray[numAggro++] = am;
			}
			else {
				am.mem.index = numActive;
				activeArray[numActive++] = am;
			}
			am = am.next;
		}
		
		
		activeArray.length = numActive;
		aggroArray.length = numAggro;
		idleMask.resize(numActive);
		
		
		//  update all aggroing entities' aggroMems based off FOV/LOS against those from the active side
		var i:Int = numAggro;
		var ac:AggroMemNode;
		while (--i > -1) {
			am = aggroArray[i];
			if (am.mem.bits.capacity() < numActive) am.mem.bits.resize(numActive);
			updateAggroMem(am.entity, am.mem, am.pos, am.rot);
		}
	}
	
	private inline function updateAggroMem(ent:Entity, aggroMem:AggroMem, posA:Pos, rotA:Rot):Void {
		var a:Int = numActive;
		var ac:AggroMemNode;
		while ( --a > -1) {
			//ac.mem
			ac = activeArray[a];
			
			
			if (ac.entity == null) continue;
			testPos.x = ac.pos.x;
			testPos.y = ac.pos.y;
			testPos.z = ac.pos.z + ac.size.z;
		
			_dummyPlayerNode.pos = ac.pos;
				_dummyPlayerNode.size = ac.size;
				_dummyPlayerNode.pointSamples = ac.entity.get(EllipsoidPointSamples);
			if ( hasFOVWithLOS(aggroMem.watchSettings.fov, posA, rotA, testPos, ac.mem.watchSettings.eyeHeightOffset) ) {
				aggroMem.bits.set(a);
			}
		}
	}
	
	private inline function getRotDestAngle(posA:Pos, rotA:Rot, posB:Pos):Float {
		var dx:Float = posB.x - posA.x;
		var dy:Float = posB.y - posA.y;
		var tarAng:Float = Math.atan2(dy, dx) + HitFormulas.ROT_FACING_OFFSET;
		return getDestAngle(rotA.z, tarAng);
	}
	
	private inline function getDestAngle(actualangle:Float, destangle:Float):Float {
		 var difference:Float = destangle - actualangle;
        if (difference < -PMath.PI) difference += PMath.PI2;
        if (difference > PMath.PI) difference -= PMath.PI2;
		return difference + actualangle;

	}
	
	
	
	// Used for EnemyWatch entities to prioritise end-turn facing over aggro-dist entities. 
	private inline  function findNearestActiveNodeToRot(posA:Pos, rotA:Rot, aggroSqDist:Float, eyeHeight:Float):Float {
		var a:Int = numActive;
		var ac:AggroMemNode;
		var result:AggroMemNode = null;
		var closestD:Float = PMath.FLOAT_MAX;
		// should prioritise according to distance, rotation, or some combination of both?
		
		// should just priotisse acocording to distance...
		// what if target is already marked by someone else???
		
		// Need a priority list determination for more "intellitgent" teamwork-oriented facing ai,
		//  Factors include:
		// - Is unit already covered by someone else?
		// - Health, no. of hits required left to kill in relation to above
		// - Distance to unit
		// - Percentage chance to hit/critical?
		
		// For now, just find nearest target naively...and see how it goes
		
		while ( --a > -1) {
			//ac.mem
			ac = activeArray[a];
			if (ac.entity == null) {
				continue;
			}
			var d:Float = getSqDist(posA, ac.pos);
			if (d <= aggroSqDist && d < closestD) {
				 // check LOS 
				// /*
				testPos.x = ac.pos.x;
				testPos.y = ac.pos.y;
				testPos.z = ac.pos.z;// + ac.size.z;
				//	*/
		
				_dummyPlayerNode.pos = ac.pos;
				_dummyPlayerNode.size = ac.size;
				_dummyPlayerNode.pointSamples = ac.entity.get(EllipsoidPointSamples);
				if ( ac.health.hp > 0 && hasLOS(posA, testPos, eyeHeight) ) {
					result = ac;
					closestD = d;
					
				}
			}
		}
		
		if (result != null) {
			_result = result;
			return  getRotDestAngle(posA, rotA, result.pos);
		}
		else {
			return PMath.FLOAT_MAX;
		}
		
	}
	
	/**
	 * 
	 * @param	fovA
	 * @param	posA
	 * @param	rotA
	 * @param	posB	
	 * @return
	 */
	public inline function hasFOV(fovA:Float, posA:Pos, rotA:Rot, posB:Pos):Bool {
		
		return HitFormulas.targetIsWithinFOV(posA, rotA, posB, fovA);  // && hasLOS(posA, posB)
	}
	
	public inline function hasFOVWithLOS(fovA:Float, posA:Pos, rotA:Rot, posB:Pos, eyeHeight:Float):Bool {
		
		return HitFormulas.targetIsWithinFOV(posA, rotA, posB, fovA) && hasLOS(posA, posB, eyeHeight);  // && hasLOS(posA, posB)
	}
	
	
	

	public inline function hasLOS(posA:Pos, posB:Pos, posAEyeHeight:Float):Bool {
			
		//_dummyPlayerNode.pointSamples
		//validateVisibility(enemyPos:Pos, enemyEyeHeight:Float, playerNode:PlayerAggroNode):Bool;
		return visibilityChecker != null ? visibilityChecker.validateVisibility(posA, posAEyeHeight, _dummyPlayerNode) : true;
		
	}
	
	/**
	 * Gets all oblivious idle entities in relation chosen to player entity and updates idleMask accordingly.
	 * This is useful for previewing AI entities that are unaware of chosen character, allowing one to plan sneak attacks.
	 * @param	playerEntity
	 */
	public function getIdleEnemies(playerEntity:Entity):Void {
		var mem:AggroMem = playerEntity.get(AggroMem);
		var plIndex:Int = mem.index;

		var am:AggroMemNode;
		var i:Int = numAggro;
		while (--i > -1) {
			am = aggroArray[i];
			if (am.entity == null) continue;
			if (!am.mem.bits.has(plIndex)) {
				idleMask.set(i);
			}
		}
	}
	
	private inline function withinSqDist(posA:Pos, posB:Pos, sqDist:Float):Bool {
		var dx:Float = posB.x - posA.x;
		var dy:Float = posB.y - posA.y;
		var dz:Float = posB.z - posA.z;
		return dx * dx + dy * dy + dz*dz <= sqDist;
	}
	
	private inline function withinDist(posA:Pos, posB:Pos, dist:Float):Bool {
		var dx:Float = posB.x - posA.x;
		var dy:Float = posB.y - posA.y;
		var dz:Float = posB.z - posA.z;
		return Math.sqrt(dx * dx + dy * dy + dz*dz) <= dist;
	}
	
	private inline function getSqDist(posA:Pos, posB:Pos):Float {
		var dx:Float = posB.x - posA.x;
		var dy:Float = posB.y - posA.y;
		var dz:Float = posB.z - posA.z;
		return dx * dx + dy * dy + dz*dz;
	}
	public var weaponLOSChecker:IWeaponLOSChecker;
	private var _turnActive:Bool = false;
	private var _dummyPlayerNode:PlayerAggroNode;
	private var _result:AggroMemNode;
	public var visibilityChecker:IVisibilityChecker;
	
	private function findEngagement(w:AggroMemNode, distCombat:Float):Bool {
		///*
		var playerPos:Pos;
		if (numActive == 0) throw "No active";
		for ( i in 0...numActive) {
			if (w.mem.bits.has(i)) {
				playerPos = activeArray[i].pos;
				
				if ( HitFormulas.targetIsWithinArcAndRangeSq(w.pos, w.rot, playerPos, distCombat, Math.PI*.15 ) ) return true;
			}
		}
		//*/
		//var val:Float = findNearestActiveNodeToRot(w.pos, w.rot, distCombat, w.state.watch.eyeHeightOffset);
		//return (val != PMath.FLOAT_MAX)
		return false;
	}
	
	private inline function findThreateningRange(weap:Weapon):Float {
		return weap != null ? PMath.maxF(weap.range, weap.fireMode <= 0 ? EnemyIdle.DEFAULT_AGGRO_RANGE : weap.range) : -1;
	}
	
	
	
	// This is called right after turn is started, where MovementPoints is given to playerEnt after transioinining into player.
	public function notifyTurnStarted(playerEnt:Entity):Void {
		// determine which entities in memList should start in Idle, Watch, or Aggro states, if they don't belong to activeSide (ai side) according to playerEnt
		
		if (playerAggroList.head == null) throw "Player aggro head node not found! Should be available at this time!";
		_turnActive = true;
		var mem:AggroMem = playerEnt.get(AggroMem);
		var plIndex:Int = mem.index;
		var playerPos:Pos = playerEnt.get(Pos);
		var plWeap:Weapon = playerEnt.get(Weapon);
		var plWeapTRange:Float = plWeap != null ? findThreateningRange(plWeap) : 0;
		
		curPlayerIndex = plIndex;
		
		var am:AggroMemNode;
		var aggro:EnemyAggro;
		am = memList.head;
		

		while (am != null) {
			am.mem.cooldown = 0;
			
			if (am.mem.side == activeSide) {  // active non-aggro ai side, shoudl be ignored...
				am = am.next;
				continue;
			}
			
			if (am.mem.bits.has(plIndex)) {  // place AI in either watch/aggro
				if (withinSqDist(playerPos, am.pos, am.mem.watchSettings.aggroRangeSq) ) {
					//	
					// determine if need to pre-trigger
					am.entity.add(new EnemyAggro().initSimple(playerAggroList.head,am.mem.watchSettings ) , EnemyAggro);
				}
				else {
					am.entity.add(new EnemyWatch().init(am.mem.watchSettings, playerAggroList.head) , EnemyWatch);
				}
			}
			else {   // place AI in idle state
				am.entity.add(am.mem.watchSettings, EnemyIdle);
			}
			
			var distCombat:Float = plWeap != null ? PMath.maxF( findThreateningRange(am.entity.get(Weapon)), plWeapTRange) : findThreateningRange(am.entity.get(Weapon));
			am.mem.engaged = findEngagement(am, distCombat);  
			//if (am.mem.engaged) throw "Got engaged";
			am = am.next;
		}
		
		
		
	
		// for entities in Aggro state, they are assigned a attack-trigger range based off their weapon's ranges (factor out method to Hitformulas), determine if playerEnt is within trigger range and if so, pull the trigger even before the player moves!
		var a:EnemyAggroNode = aggroList.head;
		while ( a != null) {
			var aWeapon:Weapon = a.weapon;
			while(aWeapon != null) {
				a.state.setAttackRange( (EnemyAggroSystem.ALLOW_KITE_RANGE & EnemyAggroSystem.KITE_ALLOWANCE) != 0 ? HitFormulas.rollRandomAttackRangeForWeapon(aWeapon, playerAggroList.head.size) : aWeapon.range + playerAggroList.head.size.x );
				var checkedLOS:Bool = false;
				//
				if ( HitFormulas.targetIsWithinArcAndRangeSq(a.pos, a.rot, playerAggroList.head.pos, a.state.attackRangeSq, aWeapon.hitAngle) &&  (checkedLOS=true) && weaponLOSChecker.validateWeaponLOS(a.pos, aWeapon.sideOffset, aWeapon.heightOffset, playerAggroList.head.pos, playerAggroList.head.size)  )   { // TODO: validate other LOS factors
					a.state.flag = 1;
					a.weaponState.pullTrigger(aWeapon);
					if (aWeapon.fireMode <= 0 && a.weaponState.attackTime >= 0) a.weaponState.attackTime = -Math.random() * a.weaponState.randomDelay;
					break;
				}
				else if (checkedLOS) {
					a.state.flag = -1;
				}
				aWeapon = aWeapon.nextFireMode;
			}
			a = a.next;
		}
		
		// Add idleChange signal to listen...this signal is used to automatically add playerEnt to aggroMem if triggering occurs, among other things like hud indiciator changes! EnemyIdle indicates units oblivious to the active playerEnt's position.
		idleList.nodeRemoved.add( onIdleNodeRemoved);
	}
	
	
	function onIdleNodeRemoved(node:EnemyIdleNode):Void 
	{
		
		var aggroMem:AggroMem = node.entity.get(AggroMem);
		if (aggroMem != null) {
			aggroMem.bits.set(curPlayerIndex);
		}
		idleNodeRemovedSignal.dispatch(node);
	}
	
	
	 // This is called just before changing state to transioinoing out, just before removing MovementPoints from player entity.
	public function notifyEndTurn():Void { 
		
		// remove idleChange signal...
		_turnActive = false;
		idleList.nodeRemoved.remove( onIdleNodeRemoved);
		
		// ROTATION dirty FOV/LOS update
		// go through all EnemyWatch entities, update aggroMemory of them (if available) based off their ending FOV/LOS () for those that ended up rotating (due to being previously going to aggro state)
		// do the same for all EnemyAggro entities.....
		var w:EnemyWatchNode = watchList.head;  
		var aggroMem:AggroMem;
		while ( w != null) {
			
			if (w.state.rotDirty) {
				aggroMem =  w.entity.get(AggroMem);
				if (aggroMem!=null) {
					updateAggroMem(w.entity, aggroMem, w.pos, w.rot);
				}
			}
		//	w.stance.updateTension( -1, 1);
			w = w.next;
		}

		var a:EnemyAggroNode = aggroList.head;
		while ( a != null) {
			aggroMem = a.entity.get(AggroMem);
			if (aggroMem!=null) {
				updateAggroMem(a.entity, aggroMem, a.pos, a.rot);
			}
		//	a.stance.updateTension(-1, 1);
			a= a.next;
		}
		
		//  for all ENemyWatch entities, turn them to face closest alive one within aggro range (and LOS) using their aggroMemory (by iterating through all bits in the aggro memory and checkign any flagged bits). 
		w = watchList.head;  
		while ( w != null) {
			var val:Float = findNearestActiveNodeToRot(w.pos, w.rot, w.state.watch.aggroRangeSq, w.state.watch.eyeHeightOffset);
			if (val != PMath.FLOAT_MAX) {  // rotate to face rotation value
				
				engine.addEntity( new Entity().add( new Tween(w.rot, 1.3, { z:val } ) ) );
				//w.stance.setPitchAim( Weapon.getPitchRatio(_result.pos.x- w.pos.x, _result.pos.y - w.pos.y, _result.pos.z-w.pos.z, w.weapon.minPitch, w.weapon.maxPitch));
				engine.addEntity( new Entity().add( new Tween(w.stance, 1.3, { setPitchAim:Weapon.getPitchRatio(_result.pos.x - w.pos.x, _result.pos.y - w.pos.y, _result.pos.z - w.pos.z, w.weapon.minPitch, w.weapon.maxPitch) } ) ) );
				
			}
			w = w.next;
		}
		
	
		// (optional but good to have.) For all EnemyAggro entities, turn them to face closest alive one within attack bi-vice-versa range if their target no longer lies within bi-attack range
		a= aggroList.head;  
		while ( a != null) {

			if (a.state.target.entity == null) {
			
				continue;
				a = a.next;
			}
			
			var plWeap:Weapon = a.state.target.entity.get(Weapon);
			var distCombat:Float = plWeap!=null ? PMath.maxF(a.weapon.range, plWeap.range ) : a.weapon.range;
			if ( a.state.target.health.hp <=0 || !HitFormulas.targetIsWithinArcAndRangeSq(a.pos, a.rot, a.state.target.pos, distCombat, a.weapon.hitAngle  ) ) {
				a.state.setAttackRange(a.weapon.range);
				var val:Float = findNearestActiveNodeToRot(a.pos, a.rot, a.state.attackRangeSq, a.state.watch.eyeHeightOffset);
				if (val != PMath.FLOAT_MAX) {  // rotate to face rotation value
					engine.addEntity( new Entity().add( new Tween(a.rot, 1.3, { z:val } ) ) );
					//a.stance.setPitchAim( Weapon.getPitchRatio(_result.pos.x- a.pos.x, _result.pos.y - a.pos.y, _result.pos.z-a.pos.z, a.weapon.minPitch, a.weapon.maxPitch));
					engine.addEntity( new Entity().add( new Tween(a.stance, 1.3, { setPitchAim:Weapon.getPitchRatio(_result.pos.x- a.pos.x, _result.pos.y - a.pos.y, _result.pos.z-a.pos.z, a.weapon.minPitch, a.weapon.maxPitch) } ) ) );
				}
			}
			a = a.next;
		}
		
		
	}

	
}