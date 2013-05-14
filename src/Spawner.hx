package ;
import ash.core.Engine;
import ash.core.Entity;
import components.ActionIntSignal;
import components.CollisionResult;
import components.controller.SurfaceMovement;
import components.DirectionVectors;
import components.Ellipsoid;
import components.Gravity;
import components.Jump;
import components.Pos;
import components.Rot;
import components.Vel;

/**
 * ...
 * @author Glenn Ko
 */

class Spawner 
{
	private var engine:Engine;
		
	public function new(engine:Engine) 
	{
		this.engine = engine;	
	}

	public function getGladiatorBase():Entity {
		var ent:Entity = new Entity();
		
		ent.add( new Pos() ).add( new Rot() ).add( new Vel() );
		
		ent.add( new SurfaceMovement() ).add( new DirectionVectors() );
		
		ent.add( new Gravity(400) ).add( new Jump(.8, 4495) );
		
		ent.add(  new Ellipsoid(16, 16, 72*.5)).add( new CollisionResult() );
		//.add(  new Ellipsoid(32,32,72)).add( new MoveResult() );
		
		ent.add( new ActionIntSignal() );
		
		return ent;
	}
	
	
	public static function getDestructor(entity:Entity, engine:Engine):Void->Void {
		return new Destructor(entity, engine).destroy;
	}

}




class Destructor {
	public var engine:Engine;
	public var entity:Entity;
	
	public function new(entity:Entity, engine:Engine):Void {
		this.engine = engine;
		this.entity = entity;
	}
	public function destroy():Void {
		engine.removeEntity(entity);
	}
	
}