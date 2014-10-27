package systems.tweening;
import ash.core.Engine;
import ash.core.Node;
import ash.core.NodeList;
import ash.core.System;
import ash.tools.ListIteratingSystem;
import components.tweening.Tween;
import components.tweening.TweenGroup;

/**
 * ...
 * @author Glenn Ko
 */
class TweenSystem extends System
{

	private var nodeList:NodeList<TweenNode>;
	private var groupList:NodeList<TweenGroupNode>;
	private var _engine:Engine;
	
	public function new() 
	{
		super();
	}
	
	override public function addToEngine(engine:Engine):Void {
		_engine = engine;
		nodeList = engine.getNodeList(TweenNode);
		groupList = engine.getNodeList(TweenGroupNode);
	}
	
	private inline function updateGroup(tw:TweenGroup):Bool {
		var kill:Bool = false;
		var i:Int;

		if (tw.t > tw.duration) {
			if (tw.repeatCount > 0) {  // repeat
				tw.t = tw.duration;
				tw.repeatCount--;
			}
			else if (tw.repeatCount == 0) {  // stop at end frame
				tw.t = tw.duration;
				
				kill = true;
				
				
			}
			else {  // loop uindeifnitely
				tw.t -= tw.duration;
			}
		}
		
		var t:Tween;
		var tweens:Array<Tween> = tw.tweens;
		i = tweens.length;
		
		while (--i > -1) {
			t = tweens[i];
			t.t = tw.t;
			updateTween(t);   // could consider whether can remove tween from given group>???
		}
		
			
		return kill;
	}
	
	
	private inline function updateTween(tw:Tween):Bool {
		var kill:Bool = false;
		var i:Int;
			
		if (tw.t > tw.duration) {
			if (tw.repeatCount > 0) {  // repeat
				tw.t = tw.duration;
				tw.repeatCount--;
			}
			else if (tw.repeatCount == 0) {  // stop at end frame
				tw.t = tw.duration;
				
				kill = true;
				
			}
			else {  // loop uindeifnitely
				tw.t -= tw.duration;
			}
		}

			i = tw.arrLen;
			while (--i > -1) {
			
				if ( (tw.funcMask & (1 << i)) != 0) untyped tw.target[ tw.props[i] ]( tw.ease(tw.t, tw.startVals[i], tw.endVals[i], tw.duration) );
				else  untyped tw.target[  tw.props[i] ] = tw.ease(tw.t, tw.startVals[i], tw.endVals[i], tw.duration);
			}
			return kill;
	}
	
	override public function update(time:Float):Void {
		var n:TweenNode = nodeList.head;
		
		while (n != null) {
			n.tween.t += time;
			if ( updateTween(n.tween) ) {
				if (n.tween.onComplete != null) {
					//n.tween.onComplete();
					_engine.updateComplete.addOnce(n.tween.onComplete);
				}
				n.tween.dead = true;
				n.entity.remove(Tween);
				
			}
			n = n.next;
		}
		
		
		var g:TweenGroupNode = groupList.head;
		while (g != null) {
			g.group.t += time;
			if ( updateGroup( g.group ) ) {
				if (g.group.onComplete != null) {
				//	g.group.onComplete();
					_engine.updateComplete.addOnce(g.group.onComplete);
				}
				g.group.dead = true;
				g.entity.remove(TweenGroup);
			}
			g = g.next;
		}
	}
	
}

class TweenNode extends Node<TweenNode> {
	
	public var tween:Tween;
	
}

class TweenGroupNode extends Node<TweenGroupNode> {
	public var group:TweenGroup;
}