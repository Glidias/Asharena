package arena.systems.enemy;
import arena.components.char.HitFormulas;
import arena.components.char.MovementPoints;
import arena.components.enemy.EnemyAggro;
import arena.components.enemy.EnemyIdle;
import arena.components.enemy.EnemyWatch;
import arena.systems.enemy.EnemyAggroSystem.EnemyWatchNode;
import arena.systems.player.PlayerAggroNode;
import ash.core.Engine;
import ash.core.Node;
import ash.core.NodeList;
import ash.core.System;
import ash.fsm.EntityStateMachine;
import components.Ellipsoid;
import components.Pos;
import components.Rot;
import arena.components.weapon.Weapon;
import arena.components.weapon.WeaponState;
import util.geom.PMath;

/**
 * "Enemies" refer to the AI-controlled passive force entities in turn-based games, so they can refer to the friendly side 
 * during the enemy's turn. "Players" refer to the current "active" characters moving about in formation or solo. THeir movement points keep track of how much "time" they have moved, from which enemies can respond to that according to the time elapsed.
 * 
 * @author Glenn Ko
 */
class EnemyAggroSystem extends System
{

	private var aggroList:NodeList<EnemyAggroNode>;
	private var watchList:NodeList<EnemyWatchNode>;
	private var idleList:NodeList<EnemyIdleNode>;
	private var playerNodeList:NodeList<PlayerAggroNode>;
	
	 // inline, so need to recompile
	private static inline var ROT_FACING_OFFSET:Float = HitFormulas.ROT_FACING_OFFSET; 
	private static inline var ROT_PER_SEC:Float = (120 * PMath.DEG_RAD);
	
	public function new() 
	{
		super();

	}
	
	
	override public function addToEngine(engine:Engine):Void {
		aggroList = engine.getNodeList(EnemyAggroNode);
		watchList = engine.getNodeList(EnemyWatchNode);
		idleList = engine.getNodeList(EnemyIdleNode);
		
		playerNodeList = engine.getNodeList(PlayerAggroNode);
		playerNodeList.nodeRemoved.add(onPlayerNodeRemoved);

	}
	
	override public function removeFromEngine(engine:Engine):Void {
		// clean up all lists
		var i:EnemyIdleNode = idleList.head;  
		while (i != null) {	
			i.entity.remove(EnemyIdle);
			i = i.next;
		}
		
		
		var w:EnemyWatchNode = watchList.head;  
		while (w != null) {
			
				w.state.dispose();
				w.entity.remove(EnemyWatch);
				//w.entity.add(EnemyIdle);
			
			
			w = w.next;
		}
		//*/
		
		///*
		var a:EnemyAggroNode = aggroList.head;
		while (a != null) {
			
				a.state.dispose();
				a.entity.remove(EnemyAggro); // TODO: Revert back to old watch condition
				
				a = a.next;
		}
		
		playerNodeList.removeAllNoSignal();
		aggroList.removeAllNoSignal();
		idleList.removeAllNoSignal();
		
		
	}
	
	
	// if for some reason, a player dies...
	function onPlayerNodeRemoved(node:PlayerAggroNode) 
	{
		node.movementPoints.timeElapsed = -1; // flag as "dead" using negative time elapsed (which is "impossible") 
		//throw "REMOVED";
		// remove all invalid nodes in watchList and aggroList where the target is found to have this playerAggroNode	
		// naively set state back to IDLE??? to force new search for any player node? Why not do the timeElapsed < 0 check for playerNode to determine if he is dead or not?...and if so, change target...or perhaps, change target from within here?
		
		/*
		var w:EnemyWatchNode = watchList.head;  
		while (w != null) {
			if (w.state.target == node) {
				w.state.dispose();
				w.entity.remove(EnemyWatch);
				//w.entity.add(EnemyIdle);
			}
			
			w = w.next;
		}
		*/
		
		/*
		var a:EnemyAggroNode = aggroList.head;
		while (a != null) {
			if (a.state.watch.target == node) {
				
				a.entity.remove(EnemyAggro); // TODO: Revert back to old watch condition
				a.entity.add(a.state.watch, EnemyWatch);
				a.state.dispose();
			}
			
			a = a.next;
		}
		*/
	}
	
	// overwrite this method to include some form of ray-casting/occlusion detection algorithm to detect LOS visiblity
	
	public function validateVisibility(enemyPos:Pos, playerNode:PlayerAggroNode):Bool {
		return true;
	}

	
	
	private inline function getDestAngle(actualangle:Float, destangle:Float):Float {
		 var difference:Float = destangle - actualangle;
        if (difference < -PMath.PI) difference += PMath.PI2;
        if (difference > PMath.PI) difference -= PMath.PI2;
		return difference + actualangle;

	}
	
	private inline function getDestAngle2(actualangle:Float, destangle:Float, rotSpeed:Float):Float {
		
		 var difference:Float = destangle - actualangle;
		
        if (difference < -PMath.PI) difference += PMath.PI2;
        if (difference > PMath.PI) difference -= PMath.PI2;

		var t:Float = rotSpeed/PMath.abs(difference);
		if (t > 1) t = 1;
		
		destangle= actualangle + difference;
		
		return  PMath.slerp(actualangle, destangle, t);

	}
	
	private inline function getDestAngleDirection(actualangle:Float, destangle:Float):Float {
		 var difference:Float = destangle - actualangle;
        if (difference < -PMath.PI) difference += PMath.PI2;
        if (difference > PMath.PI) difference -= PMath.PI2;
		return difference*difference > .0005 ? difference > 0 ? 1 : -1 : 0;

	}
	
	override public function update(time:Float):Void {
		
		var p:PlayerAggroNode;
		
		if (playerNodeList.head == null) return;
		
		p = playerNodeList.head;
		
		
		
		var playerPos:Pos = p.pos;
		var enemyPos:Pos;
		var dx:Float;
		var dy:Float;
		//var dz:Float;
		
		var pTimeElapsed:Float = p.movementPoints.timeElapsed;
		
		if (pTimeElapsed <= 0) return; // being a turn based game, time only passes when player moves
		
		var i:EnemyIdleNode = idleList.head;
		var rangeSq:Float;
		
		while (i != null) {  // assign closest player target to watch
			enemyPos = i.pos;
			rangeSq = i.state.alertRangeSq;
			dx =  playerPos.x - enemyPos.x;
			dy = playerPos.y - enemyPos.y;
			//dz = playerPos.z - enemyPos.z;
			if (dx * dx + dy * dy <= rangeSq && validateVisibility(enemyPos, p) ) {  // TODO: Include rotation facing direction as a factor for EnemyIdle case to allow backstabs
				i.entity.remove(EnemyIdle);
				i.entity.add(new EnemyWatch().init(i.state,p), EnemyWatch); // TODO: Pool ENemyWatch
			}
			i = i.next;
		}
		
	
		var newAggro:EnemyAggro;
		var rangeToAttack:Float;
		
		var w:EnemyWatchNode = watchList.head;
		while (w != null) {  // check closest valid player target, if it's same or different..  and consider aggroing if player gets close enough, 
			enemyPos = w.pos;
			
			rangeSq = w.state.watch.aggroRangeSq;
			dx =  playerPos.x - enemyPos.x;
			dy = playerPos.y - enemyPos.y;
			//dz = playerPos.z - enemyPos.z;
			
			if (dx * dx + dy * dy <= rangeSq && validateVisibility(enemyPos, p) ) { 
				
				w.entity.remove(EnemyWatch);
				newAggro = new EnemyAggro();
				rangeToAttack = w.weapon.critMinRange + Math.random()*( w.weapon.range - w.weapon.critMinRange); 
				newAggro.attackRangeSq = PMath.getSquareDist(rangeToAttack);
				newAggro.watch = w.state.watch;
				newAggro.target = w.state.target;
				w.entity.add(newAggro, EnemyAggro);
			}
			
			w = w.next;
		}
		
		
		var a:EnemyAggroNode = aggroList.head; 
		var aWeaponState:WeaponState; 
		while (a != null) { 
			
			aWeaponState = a.weaponState;
			var pTarget:PlayerAggroNode = a.state.target;
			pTimeElapsed = pTarget.movementPoints.timeElapsed;
			
			
			dx = pTarget.pos.x - a.pos.x;
			dy = pTarget.pos.y - a.pos.y;
			
			if (pTimeElapsed < 0) { // player is dead, find new player to aggro 
				
			}
			else {  // find nearest valid target , if it's diff or not, and change accordingly
				// consider if player is out of aggro range to go back to watch
				rangeSq = a.state.watch.aggroRangeSq + 40;  // the +40 threshold should be a good enough measure to prevent oscillation
				/*
				if (dx * dx + dy * dy > rangeSq) {  
					// revert back for now, forget about finding another target
					a.entity.remove(EnemyAggro);
					
					a.entity.add(new EnemyWatch().init(a.state.watch,a.state.target), EnemyWatch); // TODO: Pool ENemyWatch
					a = a.next;
					continue;
				}
				*/
			}
			
			
			// always rotate enemy to face player target
			
			var targRotZ:Float = Math.atan2(dy, dx) + ROT_FACING_OFFSET;
		//	targRotZ = getDestAngle(a.rot.z, targRotZ);
			
			a.rot.z = getDestAngle2(a.rot.z, targRotZ, ROT_PER_SEC * pTimeElapsed);  // getDestAngleDirection(a.rot.z, targRotZ)  * (2 * PMath.DEG_RAD) * pTimeElapsed;
			
			
			// determine if within "suitable" range to strike/engage player
			/*
			if (aWeaponState.trigger) {  // determine when target strikes target, or cancel attack if possible
				aWeaponState.attackTime  += pTimeElapsed;
				
				if (aWeaponState.cooldown > 0) {
					aWeaponState.cooldown -= pTimeElapsed;
					
					if (aWeaponState.cooldown <= 0) {
						aWeaponState.trigger = false;
						
					}
				}
			}
			*/

			// Weapon summary
			
			// if got weapon state attacking, continue to tick it down, and finally determine hit/miss or cancel if target is already dead 

			// else if within range, attempt to trigger attack via weaponState
			
			// if hit/miss already determined or not attacking anymore, continue to find nearer target to aggro, , and if not so and current target is invalid or already dead, find another target within watch distance and reevert back to old watch state for that target. If no target found within watch distance, need to revert back to  idle state.
			
			a = a.next;
		}
		
		
		
	}
	
}

// For enemies that are already aggroing a target, possibly engaging him, or standing ground and rotating to always face target, attacking them if within range. They might change targets if another target gets closer, so long as they aren't attacking with their weapons at the moment.

class EnemyAggroNode extends Node<EnemyAggroNode> {
	public var pos:Pos;
	public var ellipsoid:Ellipsoid;
	public var weapon:Weapon;
	public var weaponState:WeaponState;
	public var rot:Rot;
	
	public var state:EnemyAggro;	
	//public var stateMachine:EntityStateMachine;
}

// For enemies that are alerted against nearest visible opposing player, and will actively look around for any other potential player targets to aggro.

class EnemyWatchNode extends Node<EnemyWatchNode> { 
	public var pos:Pos;
	public var rot:Rot;
	public var weapon:Weapon;
	
	public var state:EnemyWatch;	
	//public var stateMachine:EntityStateMachine;
}



// For calm enemies that aren't alerted (situation safe). THey might scan horizon from time to time.

class EnemyIdleNode extends Node<EnemyIdleNode> {  
	public var pos:Pos;
	public var rot:Rot;
	
	public var state:EnemyIdle;	
	
	//public var stateMachine:EntityStateMachine;
}
