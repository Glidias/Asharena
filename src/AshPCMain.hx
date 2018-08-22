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

// HAXE utilities
import util.LibUtil;
;
// CORE Game/Framework
import ashpc.CreateScript;
import systems.player.PlayerAction;
import systems.SystemPriorities;

// CORE Ash
import ash.core.Entity;
import ash.core.System;
import ash.core.Engine;
import ash.fsm.EngineState; // you may omit this if you aren't using FSM for engine

///*  Collision scene package
// ///* If you're gonna set up a collision scene in Playcanvas, these packages are all usually required.
import altern.collisions.CollisionBoundNode;
import util.geom.AABBUtils;
import components.Transform3D;
import components.BoundBox;
import util.geom.Geometry;
import systems.collisions.ITCollidable;
import altern.ray.IRaycastImpl;
import altern.partition.js.BVHTree;	// this package required for optimizing "staticCollisionMesh" scripts!
//*/


// EXTRA HAXE PACKAGES BELOW

///*  Ellipsoid collider standalone usage
import systems.collisions.EllipsoidCollider;
#if !flash9
import jeash.geom.Vector3D;	// generally useful in certain cases depending on type requirements
#end
//*/

///*  Raycasting standalone usage
import altern.ray.Raycaster;
//*/


/* Culling/clipping package
import altern.culling.CullingPlane;
*/


/*  Serialization package
import hxbit.Serializer;
import haxe.io.Bytes;
*/


/*  Terrain core requirements
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
*/


/* Terrain collision requirements
import altern.terrain.TerrainCollidable;
*/


/**
 * Package boilerplate for deploying to Ash + Playcanvas framework on Javascript platform
 * @author Glidias
 */
@:expose("ashpc")
class AshPCMain 
{
	static function main() 
	{
		
		#if js
		exposePackages();
		//untyped __js__("$hx_exports['$hxClasses'] = $hxClasses");
		var p = untyped pc.createScript('_ash_');
		p.prototype.initialize = function(){ untyped __js__("this").entity.script.destroy('_ash_'); }
		untyped AshPCMain.components = new ashpc.Components();
		untyped AshPCMain.systems = new ashpc.Systems();
		#end
		
	}

	
	static macro function exposePackages():Expr {
		var imports = Context.getLocalImports();
		var listExpr:Array<Expr> = [macro var me:Dynamic = AshPCMain];
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