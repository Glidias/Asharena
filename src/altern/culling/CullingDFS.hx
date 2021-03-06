package altern.culling;
import altern.collisions.CollisionBoundNode;
import components.BoundBox;
import components.Transform3D;
import util.TypeDefs;
import util.TypeDefs.Vector;
import util.geom.AABBUtils;

/**
 * Generic Culling DFS recursion utility
 * @author Glidias
 */
#if alternExpose @:expose #end
class CullingDFS 
{

	private var dfsStack:Array<CollisionBoundNode> = [];
	private var dfsStackCulling:Vector<Int> = new Vector<Int>();
	
	var root:CollisionBoundNode;
	
	public var initialCulling:Int = 63;
	public var checkBoundBox:BoundBox->Int->CollisionBoundNode->Int;
	public var checkChild:CollisionBoundNode->Int->Bool;
	public var processWorldToLocal:Transform3D->CollisionBoundNode-> Void;
	public var processLocalToWorld:Transform3D->CollisionBoundNode-> Void;
	public var processChild:CollisionBoundNode-> Int->Bool;
	
	private var _aabb:BoundBox = new BoundBox();

	public function new() 
	{
		
	}
	
	public function purge():Void {
		TypeDefs.setVectorLen(dfsStack, 0);
		TypeDefs.setVectorLen(dfsStackCulling, 0);
	}
	
	public function start():Bool {
		var di:Int = 0;
		dfsStack[di] = root;
		dfsStackCulling[di] = initialCulling;
		di++;
		
		while(--di >= 0) {
			// Go through entire scene graph, for all objects , attempt collidables collection into testIndices, testVertices aray
			var obj:CollisionBoundNode = dfsStack[di];
			var culling:Int = dfsStackCulling[di];
			
			if (obj.worldToLocalTransform == null) {
				obj.calculateLocalWorldTransforms();
			}
			// convert frustum points to local coordinate space and build test frstum
		
			var t:Transform3D = obj.worldToLocalTransform;
			if (processWorldToLocal != null) {
				processWorldToLocal(t, obj);
			}
			
			// testFrustum against local bounding box of obj (if availble)
			if (checkBoundBox != null && obj.boundBox != null) {
				AABBUtils.match(_aabb, obj.boundBox);
				AABBUtils.transform(_aabb, obj.localToWorldTransform);
				culling = checkBoundBox(_aabb,  culling, obj);
			} else {
				culling = 0;
			}
			
			if (culling >= 0) {
				var c = obj.childrenList;
				while (c != null) {
					if (checkChild == null || checkChild(c, culling)) {
						dfsStack[di] = c;
						dfsStackCulling[di] = culling;
						di++;
					}
					c = c.next;
				}
				
				t = obj.localToWorldTransform; 
				if (processLocalToWorld != null) {
					processLocalToWorld(t, obj);
				}
				if (processChild != null) {
					if (!processChild(obj, culling)) {
						return false;
					}
				}
				
			}
		}
		return true;
	}
	
}