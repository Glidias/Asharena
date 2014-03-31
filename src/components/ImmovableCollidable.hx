package components;

/**
 * Dynamic collision marker state.
 * Marker component for entities that aren't moving by default, but can collide against other moving entities and possibly become "awoken".
 * Will provide collision masks later on...among other things..
 * @author Glenn Ko
 */
class ImmovableCollidable
{

	public var wakable:Bool;
	

	
	public function new() 
	{
		
	}
	
	public function init(wakable:Bool=false):ImmovableCollidable {
		init_i(wakable);
		return this;
	}
	
	public inline function init_i(wakable:Bool=false):Void {
		this.wakable = wakable;
	}
	
}