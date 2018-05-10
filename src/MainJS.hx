package;

#if js
import js.Lib;
#end

#if macro
import haxe.macro.*;
import haxe.macro.Expr;
import haxe.macro.Type;
#end


/*
import arena.pathfinding.GKDijkstra;
import arena.pathfinding.GKGraph;
import arena.pathfinding.GKGrapher;
import arena.pathfinding.GKNode;
*/

/*
import de.polygonal.ds.Graph;
*/

/* 
import systems.collisions.EllipsoidCollider;
*/

/* 
import altern.collisions.CollisionBoundNode;
*/

/* 
import altern.ray.Raycaster;
*/

import altern.culling.CullingPlane;

///*
import altern.terrain.QuadTreePage;
import altern.terrain.QuadSquareChunk;
import altern.terrain.QuadChunkCornerData;
import altern.terrain.TerrainChunkState;
import altern.terrain.TerrainChunkStateList;
import altern.terrain.HeightMapInfo;
import altern.terrain.TerrainLOD;

import altern.terrain.TerrainGeomTools;
import altern.terrain.QuadCornerData;
import altern.terrain.GeometryResult;

//*/


/* Ash-framework integration (problems with C-sharp atm)
import systems.collisions.EllipsoidColliderSystem;
*/


/**
 * Package for deploying to JS and other platforms (like C#) for third-party use (besides Flash)
 * @author Glidias
 */
@:expose("altern")
class MainJS 
{
	static function main() 
	{
		
		#if js

		exposePackages();
		
		#end
		
	}

	
	static macro function exposePackages():Expr {
		var imports = Context.getLocalImports();
		var listExpr:Array<Expr> = [macro var me:Dynamic = MainJS];
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
		if (prefix == "haxe" || prefix == "js" || prefix == "neko" || prefix == "cs" || prefix == "cpp" || prefix == "flash") return null;
		for (i in 0...ref.length) {
			arr.push(ref[i].name);
		}
		return arr;
	}
	
	
	#end
}