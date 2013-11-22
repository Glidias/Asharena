/*
 *                            _/                                                    _/
 *       _/_/_/      _/_/    _/  _/    _/    _/_/_/    _/_/    _/_/_/      _/_/_/  _/
 *      _/    _/  _/    _/  _/  _/    _/  _/    _/  _/    _/  _/    _/  _/    _/  _/
 *     _/    _/  _/    _/  _/  _/    _/  _/    _/  _/    _/  _/    _/  _/    _/  _/
 *    _/_/_/      _/_/    _/    _/_/_/    _/_/_/    _/_/    _/    _/    _/_/_/  _/
 *   _/                            _/        _/
 *  _/                        _/_/      _/_/
 *
 * POLYGONAL - A HAXE LIBRARY FOR GAME DEVELOPERS
 * Copyright (c) 2013 Michael Baczynski, http://www.polygonal.de
 *
 * Permission is hereby granted, free of charge, to any person obtaining
 * a copy of this software and associated documentation files (the
 * "Software"), to deal in the Software without restriction, including
 * without limitation the rights to use, copy, modify, merge, publish,
 * distribute, sublicense, and/or sell copies of the Software, and to
 * permit persons to whom the Software is furnished to do so, subject to
 * the following conditions:
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 * LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 * OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 * WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
package de.polygonal.core.scene;

import de.polygonal.core.math.Limits;
import de.polygonal.core.sys.Entity;
import de.polygonal.core.util.Assert;
import haxe.ds.StringMap;

class SceneStack extends Entity
{
	var _transitions:StringMap<Class<SceneTransition>>;
	
	var _sceneBag:Entity;
	
	public function new()
	{
		super();
		_transitions = new StringMap<Class<SceneTransition>>();
		
		//scenes are added to this bag
		_sceneBag = new Entity("sceneBag");
		super.add(_sceneBag);
		commit();
	}
	
	public function setTransition(a:Dynamic, b:Dynamic, transition:Class<SceneTransition>, ?invertTransition:Class<SceneTransition>):Void
	{
		if (transition == null)
		{
			_transitions.set(getKey(a, b), NullTransition);
			if (invertTransition != null)
				_transitions.set(getKey(b, a), invertTransition);
			else
				_transitions.set(getKey(b, a), NullTransition);
			return;
		}
		
		_transitions.set(getKey(a, b), transition);
		if (invertTransition != null)
			_transitions.set(getKey(b, a), invertTransition);
	}
	
	public function setDefaultTransition(transition:Class<SceneTransition>):Void
	{
		_transitions.set(getKey(null, null), transition);
	}
	
	override public function add(child:Entity, priority = Limits.UINT16_MAX):Entity
	{
		return throw "use push() instead";
	}
	
	override function onRemoveDescendant(x:Entity):Void
	{
		if (x.is(Scene))
		{
			L.i("scene " + x.id + " was removed");
			
			//update priorities (=z indices)
			var z = 0;
			var sibling = x.treeNode.getFirstSibling();
			while (sibling != null)
			{
				if (sibling.val == x)
					sibling.val.priority = Limits.UINT16_MAX;
				else
					sibling.val.priority = z++;
				sibling = sibling.next;
			}
			
			//trace(_sceneBag.treeNode);
		}
	}
	
	public function push(scene:Scene):Void
	{
		#if debug
		D.assert(scene != null, "scene is null");
		#end
		
		var a:Scene = null;
		var b:Scene = null;
		
		var sceneExists = _sceneBag.treeNode.contains(scene);
		//trace( "sceneExists : " + sceneExists );
		
		if (sceneExists)
		{
			var topMostScene:Scene = cast _sceneBag.treeNode.getLastChild().val;
			scene.treeNode.setLast();
			
			scene.priority = topMostScene.priority;
			topMostScene.priority = scene.priority - 1;
			
			a = topMostScene;
			b = scene;
			
			#if debug
			D.assert(a != b, "a != b");
			#end
		}
		else
		{
			//last child contains topmost scene
			if (_sceneBag.treeNode.hasChildren())
				a = cast _sceneBag.treeNode.getLastChild().val;
			b = scene;
			_sceneBag.add(b, a == null ? 0 : a.priority + 1);
			
			_sceneBag.commit();
			//trace(_sceneBag.treeNode);
		}
		
		runTransition(a, b);
	}
	
	public function pop():Void
	{
		var numChildren = _sceneBag.treeNode.numChildren();
		
		//TODO asserts
		var a:Scene = cast _sceneBag.treeNode.getChildAt(numChildren - 1).val;
		var b:Scene = cast _sceneBag.treeNode.getChildAt(numChildren - 2).val;
		
		runTransition(a, b);
	}
	
	
	
	
	
	
	function runTransition(a:Scene, b:Scene):Void
	{
		var transition = getTransition(a, b);
		if (transition == null)
		{
			if (a != null)
			{
				a.onHideStart(b);
				a.onHideEnd(b);
			}
			
			b.onShowStart(a);
			b.onShowEnd(a);
		}
		else
		{
			super.add(transition);
			commit();
		}
	}
	
	function getTransition(a:Scene, b:Scene):SceneTransition
	{
		var transitionClass = _transitions.get(getKey(a, b));
		if (transitionClass == null)
			transitionClass = _transitions.get(getKey(null, null));
		
		return
		if (transitionClass != null)
		{
			var transition = Type.createInstance(transitionClass, []);
			transition.a = cast a;
			transition.b = cast b;
			transition;
		}
		else
			null;
	}
	
	function getKey(a:Dynamic, b:Dynamic):String
	{
		var key = "";
		
		if (Type.getClass(a) != null) a = Type.getClass(a);
		key += Type.getClassName(a);
		
		if (Type.getClass(b) != null) b = Type.getClass(b);
		key += Type.getClassName(b);
		
		return key;
	}
}

private class NullTransition extends SceneTransition
{
	public function new()
	{
		super(SceneTransitionMode.Sequential, 0);
	}
}