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

///*  Ellipsoid collider for collision scene package
import systems.collisions.EllipsoidCollider;
#if !flash9
import jeash.geom.Vector3D;
#end
//*/

///*  Collision scene package
import altern.collisions.CollisionBoundNode;
import components.Transform3D;
import util.geom.Geometry;
//*/

///*  Raycasting package
import altern.ray.Raycaster;
//*/

///* Culling/clipping package
import altern.culling.CullingPlane;
//*/


///*  Terrain core requirements
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

import altern.culling.CullingPlane;
//*/


///* Terrain collision requirements
import altern.terrain.TerrainCollidable;
//*/


/* Ash-framework integration (problem compiling to C-sharp code atm)
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