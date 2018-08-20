package ashpc;

#if macro
import haxe.macro.*;
import haxe.macro.Expr;
import haxe.macro.Type;
#end

/**
 * ...
 * @author Glidias
 */
// -- usually core
import systems.movement.MovementSystem;
// TODO: Prescribed playcanvas rendering system with entity/graphNode

// -- This can be omitted if you aren't coding any IAnimatable stuff of your own.
import systems.animation.AnimationSystem;

// -- any physic effects (usually GravitySystem is the common one)
import systems.movement.GravitySystem;
import systems.movement.DampingSystem;

// --all reqiored for surface movement + GravitySystem (PlayerSurfaceMOvement can be omitted if no player KeyPoll controls involved)
import systems.movement.SurfaceMovementSystem;
import systems.movement.QPhysicsSystem;
//import systems.movement.PlayerSurfaceMovementSystem;

// -- jumping/jetting ability for player's Keypoll (if needed)
//import systems.player.PlayerJumpSystem;

// -- to clamp player ellipsoid position to a global altitude ground surface
import systems.collisions.GroundPlaneCollisionSystem;

// -- health tracking
import systems.sensors.HealthTrackingSystem;

// -- tweening
import systems.tweening.TweenSystem;


class Systems
{

	public function new() 
	{
		//exposePackages();
	}
	
	static macro function exposePackages():Expr {
		var imports = Context.getLocalImports();
		
		var listExpr:Array<Expr> = [macro var me:Dynamic = this];
		var currentPos = Context.currentPos();
		var retExpr:Expr = {expr:ExprDef.EBlock(listExpr), pos:currentPos };

		
		for ( i in 0...imports.length) {
			var imp = imports[i];
			var impA = getPathArr(imp.path);
			if (impA != null) {
				var className:String = impA[impA.length - 1];
				var classExpr:Expr = {expr:ExprDef.EConst(CIdent(className)), pos:currentPos };
				listExpr.push( macro me.$className = $e{classExpr} );
			}		
		}
		
		return retExpr;
	}
	
	#if macro
	static function getPathArr(ref:Array< { pos: Position, name: String } >):Array<String> {
		var arr:Array<String> = [];
		var prefix:String = ref[0].name;
		if ( prefix == "js" || prefix == "neko" || prefix == "cs" || prefix == "cpp" || prefix == "flash") return null;
		for (i in 0...ref.length) {
			arr.push(ref[i].name);
		}
		return arr;
	}
	#end
	
}