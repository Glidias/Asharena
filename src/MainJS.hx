package;

#if js
import js.Lib;
#end

/*
import arena.pathfinding.GKDijkstra;
import arena.pathfinding.GKGraph;
import arena.pathfinding.GKGrapher;
import arena.pathfinding.GKNode;
*/

///*
import de.polygonal.ds.Graph;
//*/

///* 
import systems.collisions.EllipsoidCollider;
//*/

///* 
import altern.collisions.CollisionBoundNode;
//*/

///* 
import altern.ray.Raycaster;
//*/

///*
import altern.terrain.QuadTreePage;
import altern.terrain.QuadSquareChunk;
import altern.terrain.QuadChunkCornerData;
import altern.terrain.TerrainChunkState;
import altern.terrain.TerrainChunkStateList;
import altern.terrain.HeightMapInfo;
import altern.terrain.TerrainLOD;

import altern.terrain.QuadCornerData;

//*/


/* Ash-framework integration (problems with C-sharp atm)
import systems.collisions.EllipsoidColliderSystem;
*/


/**
 * Package for deploying to JS and other platforms (like C#) for third-party use (besides Flash)
 * @author Glidias
 */
class MainJS
{
	
	static function main() 
	{
		
		
		#if js
		// generate macro to expose to global via altern package based on class imports
		/*
		js.Browser.window.altern = {
			CollisionBoundNode,
		};
		*/
		#end
	}
	
}