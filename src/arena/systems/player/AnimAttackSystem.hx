package arena.systems.player;
import arena.components.weapon.AnimAttackMelee;
import ash.core.Engine;
import ash.core.NodeList;
import ash.core.System;
import components.ActionSignal;
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
	//public var count:Int = -1;
//
	public function new() 
	{
		super();
	}
	
	override public function addToEngine(engine:Engine):Void {
		nodeList = engine.getNodeList(AnimAttackNode);
		//nodeList.onAdded.add(onNodeAdded);
	}

	override public function removeFromEngine(engine:Engine):Void {
		//nodeList.onAdded.remove(onNodeAdded);
	//	nodeList = null;
	}
	
	public function onNodeAdded(node:AnimAttackNode):Void {
		
	}
	
	override public function update(time:Float):Void {
		var n:AnimAttackNode = nodeList.head;
		while ( n != null) {
			if (n.animMelee.targetPos != null) {
				
			}
			else {
				n.animMelee.curTime += time;
	
				if (n.animMelee.fixedStrikeTime>=0 && n.animMelee.curTime >= n.animMelee.fixedStrikeTime) {
					n.animMelee.targetHP.damage(n.animMelee.damageDeal);
					n.animMelee.fixedStrikeTime = -1;
					
					
				}
				
				if (n.animMelee.curTime >= n.weapon.anim_fullSwingTime) {
					n.signal.forceSet(PlayerAction.IDLE);
					n.entity.remove(AnimAttackMelee);
					//count--;
				}
			}
			n = n.next;
		}
	}
	
}

