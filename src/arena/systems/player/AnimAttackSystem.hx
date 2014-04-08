package arena.systems.player;
import arena.components.char.HitFormulas;
import arena.components.weapon.AnimAttackMelee;
import arena.components.weapon.Weapon;
import ash.core.Engine;
import ash.core.Entity;
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
 * Delayed damage dealing system for melee attack animations
 * @author Glidias
 */
class AnimAttackSystem extends System
{
	private var nodeList:NodeList<AnimAttackNode>;
	private var _engine:Engine;
	//public var count:Int = -1;
	public var resolved:Signal0;
//
	public function new() 
	{
		super();
		resolved = new Signal0();
	}
	
	override public function addToEngine(engine:Engine):Void {
		nodeList = engine.getNodeList(AnimAttackNode);
		//nodeList.onAdded.add(onNodeAdded);
		_engine = engine;
	}

	override public function removeFromEngine(engine:Engine):Void {
		//nodeList.onAdded.remove(onNodeAdded);
	//	nodeList = null;
	}
	
	public function onNodeAdded(node:AnimAttackNode):Void {
		
	}
	
	override public function update(time:Float):Void {
		var n:AnimAttackNode = nodeList.head;
		var notResolved:Int = n!=null ? -1 :  0;
		
		while ( n != null) {
			if (n.animMelee.targetPos != null) {
				n.animMelee.curTime += time;
				if (n.animMelee.fixedStrikeTime >= 0) {
					
					var timing:Float = HitFormulas.calculateAnimStrikeTimeAtRange(n.weapon, HitFormulas.get2DDist(n.pos, n.animMelee.targetPos, n.animMelee.targetEllipsoid));
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
		
		if (notResolved  == -1) {
			_engine.updateComplete.addOnce( notifyFinish);
		}
	}
	
	private function notifyFinish() 
	{
		resolved.dispatch();
	}
	
	public static inline function performMeleeAttackAction(attackAction:UInt, attackerEntity:Entity, targetEntity:Entity, targetDamage:Int):Void {
			var swinger = new AnimAttackMelee();
			
			swinger.init_i_static(attackerEntity.get(Weapon).anim_strikeTimeAtMaxRange, targetEntity.get(Health), targetDamage );
			attackerEntity.add(swinger);
			
			var sig:ActionUIntSignal = attackerEntity.get(ActionUIntSignal);
			sig.forceSet(attackAction);
	}
	
}

