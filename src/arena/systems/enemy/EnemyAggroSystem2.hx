package arena.systems.enemy;
import alternativa.engine3d.core.Object3D;
import arena.components.char.EllipsoidPointSamples;
import arena.components.char.HitFormulas;
import arena.components.char.MovementPoints;
import arena.components.enemy.EnemyAggro;
import arena.components.enemy.EnemyIdle;
import arena.components.enemy.EnemyWatch;
import arena.components.weapon.AnimAttackMelee;
import arena.components.weapon.AnimAttackRanged;
import arena.systems.player.IStance;
import arena.systems.player.IVisibilityChecker;
import arena.systems.player.IWeaponLOSChecker;
import arena.systems.weapon.ITimeChecker;
import haxe.Log;

import arena.systems.player.PlayerAggroNode;
import ash.core.Engine;
import ash.core.Entity;
import ash.core.Node;
import ash.core.NodeList;
import ash.core.System;
import ash.fsm.EntityStateMachine;
import ash.signals.Signal1;
import ash.signals.Signal2;
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
class EnemyAggroSystem2 extends System implements IWeaponLOSChecker implements IVisibilityChecker implements ITimeChecker
{

	public var aggroList:NodeList<EnemyAggroNode>;
	public var watchList:NodeList<EnemyWatchNode>;
	public var idleList:NodeList<EnemyIdleNode>;
	private var playerNodeList:NodeList<PlayerAggroNode>;
	
	 // inline, so need to recompile
	private static inline var ROT_FACING_OFFSET:Float = HitFormulas.ROT_FACING_OFFSET; 
	private static inline var ROT_PER_SEC:Float = (220 * PMath.DEG_RAD);
	
	// states to normally run with signals below (coudl be factored out to model class);
	public var currentAttackingEnemy:Entity;
	public var enemyCrit:Bool;
		
	/*
	public var onEnemyAttack:Signal1<Entity>;
	public var onEnemyReady:Signal1<Entity>;
	public var onEnemyStrike:Signal1<Entity>;
	public var onEnemyCooldown:Signal2<Entity, Float>;
	*/
	
	public var updating:Bool;
	
	public var timeChecker:ITimeChecker;
	
	
	public var useGrid:Bool;
	public var gridSize:Float;

	
	
	
	public function new() 
	{
		super();
		gridSize = 16;
		useGrid = false;  // need to manually enable grid
		
		/*
		onEnemyAttack = new Signal1<Entity>();
		onEnemyReady = new Signal1<Entity>();
		onEnemyStrike = new Signal1<Entity>();
		*/
		
		timeChecker = this;
	}
	
	
	override public function addToEngine(engine:Engine):Void {
		aggroList = engine.getNodeList(EnemyAggroNode);
		watchList = engine.getNodeList(EnemyWatchNode);
		idleList = engine.getNodeList(EnemyIdleNode);
		
		playerNodeList = engine.getNodeList(PlayerAggroNode);

		_reactCooldown = 0;
		
		if (aggroList.head != null) throw "AGgro list isn't clean!";
		if (watchList.head != null) throw "watchList list isn't clean!";
		if (idleList.head != null) throw "idleList list isn't clean!";

	}
	
	//var boolTest:Bool;
	
	override public function removeFromEngine(engine:Engine):Void {
		currentAttackingEnemy = null;
		updating = false;
		
		/*
		var p:PlayerAggroNode = playerNodeList.head;
		while (p != null) {
			p.weaponState.delay = p.weaponState.cooldown > 0 ? p.weaponState.cooldown : 0;
			p = p.next;
		}
		*/
		
		// clean up all lists
		var i:EnemyIdleNode = idleList.head;  
		while ( i != null) {
			//i.weaponState.delay = i.weaponState.cooldown > 0 ? i.weaponState.cooldown : 0;
			i.entity.remove(EnemyIdle);
			i = i.next;
		}
		
		
		var w:EnemyWatchNode = watchList.head;  
		while (w != null) {
				//w.weaponState.delay = w.weaponState.cooldown > 0 ? w.weaponState.cooldown : 0;
				/*
				if (w.entity.get(WeaponState).trigger) {
					throw "SHOULD Not have trigger if on watch state!";
				}
				*/
				w.state.dispose();
				//w.entity.remove(EnemyWatch);
				//w.entity.add(EnemyIdle);
			w = w.next;
		}
		w = watchList.head;
		while ( w != null) {
			w.entity.remove(EnemyWatch);
			w = w.next;
		}
		//*/
		
		///*
		var a:EnemyAggroNode = aggroList.head;
		while (a != null) {
			
				//a.weaponState.delay = a.weaponState.cooldown > 0 ? a.weaponState.cooldown : 0;
				a.weaponState.cancelTrigger();
				a.state.dispose();
				/*
				if (a.entity.get(WeaponState).trigger) {
					throw "SHOULD Not have trigger if out of aggro state!";
				}
				*/
				
			//	a.entity.remove(EnemyAggro); // TODO: Revert back to old watch condition
				
				a = a.next;
		}
		
		a = aggroList.head;
		while ( a != null) {
			a.entity.remove(EnemyAggro);
			a= a.next;
		}
		
		// should this be done!???
		watchList.removeAllNoSignal();
		playerNodeList.removeAllNoSignal();
		aggroList.removeAllNoSignal();
		idleList.removeAllNoSignal();
		
		
	
	}
	public static inline var STATE_FLAG_READY:Int = 0;
	public static inline var STATE_FLAG_TRIGGER:Int = 1;
	public static inline var STATE_FLAG_STRUCK:Int = 2;
	public static inline var STATE_FLAG_COOLDOWN:Int = 3;
	
	public function resetCooldownsOfAllAggro():Void {
		var a:EnemyAggroNode = aggroList.head;
		while (a != null) {
			if ( a.state.flag == STATE_FLAG_STRUCK || a.state.flag==STATE_FLAG_COOLDOWN ) {
				a.weaponState.cancelTrigger();
				a.state.flag = 0;
			}
			a = a.next;
		}
	}
	
	

	


	
	// Utility methods
	
	private inline function getDestAngle(actualangle:Float, destangle:Float):Float {
		 var difference:Float = destangle - actualangle;
        if (difference < -PMath.PI) difference += PMath.PI2;
        if (difference > PMath.PI) difference -= PMath.PI2;
		return difference + actualangle;

	}
	
	private inline function getDiffAngle(actualangle:Float, destangle:Float):Float {
		 var difference:Float = destangle - actualangle;
        if (difference < -PMath.PI) difference += PMath.PI2;
        if (difference > PMath.PI) difference -= PMath.PI2;
		return difference;

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
	
	private inline function getDestAngle2D(actualangle:Float, destangle:Float, rotSpeed:Float, difference:Float):Float {
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
		
		
		
	}
	
	
	// --- OVERRIDABLE	
	
	// overwrite this method to include some form of ray-casting/occlusion detection algorithm to detect LOS visiblity
	
	public function validateVisibility(enemyPos:Pos, enemyEyeHeight:Float, playerNode:PlayerAggroNode):Bool {
		return true;
	}
	
	public function validateWeaponLOS(attacker:Pos, sideOffset:Float, heightOffset:Float, target:Pos, targetSize:Ellipsoid):Bool {
		return true;
	}
	
	/* INTERFACE arena.systems.weapon.ITimeChecker */
	
	public function checkTime(val:Float):Void 
	{
		
	}
	
	/* INTERFACE arena.systems.player.IWeaponLOSChecker */
	
	public function getTotalExposure(attacker:Pos, weapon:Weapon, target:Pos, targetSize:Ellipsoid, targetStance:IStance, targetPts:EllipsoidPointSamples):Float 
	{
		return 1;
	}
	
}




