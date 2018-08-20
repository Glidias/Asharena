package ashpc;

#if macro
import haxe.macro.*;
import haxe.macro.Expr;
import haxe.macro.Type;
#end

// -- usually core (though Scale can usually be omitted as it's rather uncommon)
import components.Pos;
import components.Rot;
import components.Vel;
import components.Scale;

// -- This can be omitted if you aren't coding any IAnimatable stuff of your own.
import systems.animation.IAnimatable;

// -- all required for player movement + on surface clamping (usually with Gravity) + KeyPoll/Keyindings
import components.Ellipsoid;
import components.CollisionResult;
import components.MoveResult;

import components.controller.SurfaceMovement;
import components.DirectionVectors;

// import input.KeyPoll;  // TODO: cross-platform version @:pcSingleton

// -- jumping/jetting ability
import components.Jump;

// -- physic effects
import components.Gravity;
import components.Damp;
import components.Bounce;
import components.Sticky;

// -- signals
import components.ActionSignal;
import components.ActionIntSignal; 
import components.ActionUIntSignal;


// -- dynamic collisions
import components.MovableCollidable;
import components.ImmovableCollidable;

// -- health tracking
import components.Health;

// -- for tweening
import components.tweening.Tween;

/**
 * ...
 * @author Glidias
 */
class Components
{

	public function new() 
	{
		exposePackages();
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