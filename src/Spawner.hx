package ;
import arena.components.char.AggroSpecs;
import arena.components.char.CharDefense;
import arena.components.char.CharTurnSpecs;
import arena.components.weapon.WeaponState;
import arena.systems.player.PlayerAggro;
import ash.core.Engine;
import ash.core.Entity;
import components.ActionIntSignal;
import components.ActionUIntSignal;
import components.CollisionResult;
import components.controller.SurfaceMovement;
import components.DirectionVectors;
import components.Ellipsoid;
import components.Gravity;
import components.Health;
import components.Jump;
import components.MoveResult;
import components.Pos;
import components.Rot;
import components.Vel;
import util.geom.PMath;

/**
 * ...
 * @author Glenn Ko
 */

class Spawner 
{
	private var engine:Engine;
	
	public var globalTurnSpecs:CharTurnSpecs;
	public var globalAggroMeleeSpecs:AggroSpecs;
	public var globalAggroRangedSpecs:AggroSpecs;
		
	public function new(engine:Engine) 
	{
		this.engine = engine;	
		
		this.globalTurnSpecs = new CharTurnSpecs().setupAsharena();
		this.globalAggroMeleeSpecs = new AggroSpecs().setupAsharenaStandard(false);
		this.globalAggroRangedSpecs = new AggroSpecs().setupAsharenaStandard(true);

	}

	public function getGladiatorBase(x:Float = 0, y:Float = 0, z:Float = 0, rx:Float = 0, ry:Float = 0, rz:Float=0, isPlayer:Bool=true):Entity {
		var ent:Entity = new Entity();
		
		
		ent.add( new Pos(x, y, z) ).add( new Rot(rx, ry, rz) ).add( new Vel() );
		
		
		ent.add( new AggroSpecs().setupAsharenaStandard(false, true) );  //
		ent.add( globalTurnSpecs );
		
		
		ent.add( new PlayerAggro().init() );
		
		ent.add( new SurfaceMovement() ).add( new DirectionVectors() );
		
		ent.add( new Gravity(10*5) ).add( new Jump(.8, 4495*5) );
		
		var coll:CollisionResult;
		ent.add(  new Ellipsoid(20, 20, 36)).add( coll = new CollisionResult() ).add( new MoveResult() );
		coll.flags |= CollisionResult.FLAG_MAX_GROUND_NORMAL;
		if (isPlayer) {
			
		}
		
		ent.add( new Health().init() );
		//.add(  new Ellipsoid(32,32,72)).add( new MoveResult() );
		
		ent.add( new ActionUIntSignal() );
		ent.add( new ActionIntSignal() );
		ent.add( new WeaponState().init() );
		ent.add( new CharDefense().init(.5, .5, 45*PMath.DEG_RAD) );
		return ent;
	}
	

	
	public function setAsSinglePlayer(ent:Entity):Entity {
		
		
		return ent;
	}
	
	public function setAsNonPlayer(ent:Entity):Entity {
		
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