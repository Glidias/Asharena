package arena.systems.player;
import arena.components.char.HitFormulas;
import arena.components.weapon.AnimAttackMelee;
import arena.components.weapon.AnimAttackRanged;
import arena.components.weapon.Weapon;
import arena.systems.weapon.IProjectileDomain;
import arena.systems.weapon.IProjectileHitResolver;
import ash.core.Engine;
import ash.core.Entity;
import ash.core.Node;
import ash.core.NodeList;
import ash.core.System;
import ash.signals.Signal0;
import components.ActionSignal;
import components.ActionUIntSignal;
import components.Ellipsoid;
import components.Health;
import components.Pos;
import systems.player.PlayerAction;

/**
 * Delayed damage dealing system for melee/ranged attack animations and projectiles
 * @author Glidias
 */
class AnimAttackSystem extends System implements IProjectileHitResolver
{
	private var nodeList:NodeList<AnimAttackNode>;
	private var _engine:Engine;
	private var _notResolved:Int;
	private var nodeListRanged:NodeList<AnimAttackRNode>;
	private var projectileDomainList:NodeList<ProjectileDomainNode>;
	
	//public var count:Int = -1;
	public var resolved:Signal0;
	public var projectileTimeLeft:Float;
	public var defaultProjHitResolver:IProjectileHitResolver;
//
	public function new() 
	{
		super();
		resolved = new Signal0();
		projectileTimeLeft = 0;
		defaultProjHitResolver = this;
	}
	
	override public function addToEngine(engine:Engine):Void {
		nodeList = engine.getNodeList(AnimAttackNode);
		nodeListRanged = engine.getNodeList(AnimAttackRNode);
		projectileDomainList = engine.getNodeList(ProjectileDomainNode);

		_engine = engine;		
		
		projectileTimeLeft = 0;
	}

	override public function removeFromEngine(engine:Engine):Void {
		//nodeList.onAdded.remove(onNodeAdded);
	//	nodeList = null;
	
	}
	
	public function onNodeAdded(node:AnimAttackNode):Void {
		
	}
	
	
	
	override public function update(time:Float):Void {
		var n:AnimAttackNode = nodeList.head;
		var notResolved:Int = n != null ? -1 :  0;
		
		// process fixed rangedTime accordingly
		var testTime:Float;
		
		// Process melee unit attack anims and damage dealings
		while ( n != null) {
			if (n.animMelee.targetPos != null) {
				n.animMelee.curTime += time;
				if (n.animMelee.fixedStrikeTime >= 0) {
					
					var timing:Float = HitFormulas.calculateAnimStrikeTimeAtRange(n.weapon, HitFormulas.get3DDist(n.pos, n.animMelee.targetPos, n.animMelee.targetEllipsoid));
					if (n.animMelee.curTime >= timing) {
						n.animMelee.targetHP.damage(n.animMelee.damageDeal);
						n.animMelee.fixedStrikeTime = -1;
					}
				}
			}
			else {
				n.animMelee.curTime += time;
	
				if (n.animMelee.fixedStrikeTime>=0 && n.animMelee.curTime >= n.animMelee.fixedStrikeTime) {
					n.animMelee.targetHP.damage(n.animMelee.damageDeal);
					n.animMelee.fixedStrikeTime = -1;
				}	
			}
			
			if (n.animMelee.curTime >= n.weapon.anim_fullSwingTime) {
				n.signal.forceSet(PlayerAction.IDLE);  
				
				n.entity.remove(AnimAttackMelee);
				//count--;
				
			}
			else notResolved = 1;
			n = n.next;
		}
		
			
			
		// Process current ranged projectiles
		projectileTimeLeft -= time;
		
		var d:ProjectileDomainNode = projectileDomainList.head;
		while (d != null) {
			testTime = d.domain.update(time);
			if (testTime > projectileTimeLeft) projectileTimeLeft = testTime;
			d = d.next;
		}
		
		
		// Process ranged unit attack anims and damage dealings
		var r:AnimAttackRNode = nodeListRanged.head;
		while (r != null) {
			var animRanged:AnimAttackRanged = r.animRanged;
			animRanged.curTime += time;
	
				if (animRanged.fixedStrikeTime>=0 && animRanged.curTime >= animRanged.fixedStrikeTime) {
					//r.animRanged.targetHP.damage(r.animRanged.damageDeal);
					
					animRanged.fixedStrikeTime = -1;
					
					if (r.weapon.projectileDomain != null) {
						if (animRanged.damageDeal == 0) {
							testTime = r.weapon.projectileDomain.launchStaticProjectile(
								animRanged.originX, animRanged.originY, animRanged.originZ, 
								animRanged.targetPos.x + animRanged.targetOffsetX, 
								animRanged.targetPos.y + animRanged.targetOffsetY, 
								animRanged.targetPos.z + animRanged.targetOffsetZ,
								animRanged.projectileSpeed);
						}
						else {
								testTime = r.weapon.projectileDomain.launchDynamicProjectile(
								animRanged.originX, animRanged.originY, animRanged.originZ,
								animRanged.targetPos,
								animRanged.projectileSpeed,
								r.entity,
								animRanged.targetEntity,
								animRanged.targetEllipsoid,
								animRanged.damageDeal
								);
						}
						if (testTime > projectileTimeLeft) projectileTimeLeft = testTime;
					}
					else {
						defaultProjHitResolver.processHit(r.entity, animRanged.targetEntity, animRanged.damageDeal, animRanged.targetPos.x, animRanged.targetPos.y, animRanged.targetPos.z);
					}
					
					// TODO: pool this for performance, same with AnimAttackRanged! Every other instantiation must use pooled impl.
					n.entity.remove(AnimAttackRanged);
				}	
			
			r = r.next;
		}
		
		
		if (projectileTimeLeft > 0) notResolved = 1;
		
		
		_notResolved = notResolved;
		if (notResolved  == -1) {
			_engine.updateComplete.addOnce( notifyFinish);
		}
	}
	
	public inline function getResolved():Bool {
		return _notResolved == 0;
	}
	
	private function notifyFinish() 
	{
		_notResolved = 0;
		resolved.dispatch();
	}
	
	public static inline function performMeleeAttackAction(attackAction:UInt, attackerEntity:Entity, targetEntity:Entity, targetDamage:Int):Void {
			var swinger = new AnimAttackMelee();
			
			swinger.init_i_static(attackerEntity.get(Weapon).anim_strikeTimeAtMaxRange, targetEntity.get(Health), targetDamage );
			attackerEntity.add(swinger);
			
			var sig:ActionUIntSignal = attackerEntity.get(ActionUIntSignal);
			sig.forceSet(attackAction);
	}
	
	/* INTERFACE arena.systems.weapon.IProjectileHitResolver */
	
	public function processHit(srcEntity:Entity, targetEntity:Entity, targetDamage:Int, ex:Float = 0, ey:Float = 0, ez:Float = 0):Void 
	{
		
		var hp:Health = targetEntity.get(Health);
		if (hp != null) {
			hp.damage(targetDamage);
		}
	}
	
}


class ProjectileDomainNode extends Node<ProjectileDomainNode> {
	public var domain:IProjectileDomain;
	
}

