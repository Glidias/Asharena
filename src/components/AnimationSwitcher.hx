package components;
import ash.core.Engine;
import ash.core.Entity;
import systems.animation.IAnimatable;

/**
 * ...
 * @author Glenn Ko
 */
class AnimationSwitcher implements IAnimatable
{
	private var hash:Hash<IAnimatable>;
	private var current:IAnimatable;
	
	public function new() 
	{
		hash = new Hash<IAnimatable>();
	}
	
	public inline function addAnimation(anim:IAnimatable, id:String):Void {
		hash.set(id, anim);
	}
	
	public inline function switchTo(id:String):Void {
		current = hash.get(id);
	}
	
	public inline function animate(time:Float):Void {
		if (current != null) current.animate(time);
		
	}
	
}
