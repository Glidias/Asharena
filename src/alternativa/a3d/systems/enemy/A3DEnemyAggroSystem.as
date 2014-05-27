package alternativa.a3d.systems.enemy 
{
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.RayIntersectionData;
	import arena.systems.player.IWeaponLOSChecker;
	import flash.geom.Vector3D;
	import systems.collisions.Intersect3D;
	import util.geom.Vec3;
	
	import arena.systems.enemy.EnemyAggroSystem;
	import arena.systems.player.PlayerAggroNode;
	import components.Ellipsoid;
	import components.Pos;
	/**
	 * Temporary class for now until collidable supports geometry under Haxe supports raycasting as well
	 * @author Glenn Ko
	 */
	public class A3DEnemyAggroSystem extends EnemyAggroSystem 
	{
		private var rayScene:Object3D;
		private var src3:Vec3 = new Vec3();
		private var des3:Vec3 = new Vec3();
		private var src:Vector3D = new Vector3D();
		private var dest:Vector3D = new Vector3D();
		
		public function A3DEnemyAggroSystem(rayScene:Object3D) 
		{
			this.rayScene = rayScene;
		}
	//	/*
		override public function validateVisibility(enemyPos:Pos, enemyEyeHeight:Number, playerNode:PlayerAggroNode) : Boolean {
			// compare ray from eye to ellipsoid distance vs distance of RayIntersectionData distance
			
			src3.x = enemyPos.x;
			src3.y = enemyPos.y;
			src3.z = enemyPos.z + enemyEyeHeight;
			
			var randomPt:int = int(Math.random() * playerNode.pointSamples.numPoints);
			var px:Number = playerNode.pos.x +  playerNode.pointSamples.points[randomPt] * playerNode.size.x * playerNode.pointSamples.maxD;
			var py:Number = playerNode.pos.y +  playerNode.pointSamples.points[randomPt+1] * playerNode.size.y * playerNode.pointSamples.maxD;
			var pz:Number = playerNode.pos.z +  playerNode.pointSamples.points[randomPt + 2] * playerNode.size.z * playerNode.pointSamples.maxD;
			
			
			des3.x = px - src3.x;
			des3.y = py- src3.y;
			des3.z = pz - src3.z;
			var dm:Number = 1 /	Math.sqrt( des3.x * des3.x + des3.y * des3.y + des3.z * des3.z );
			des3.x *= dm;
			des3.y *= dm;
			des3.z *= dm;
			src.x = src3.x;
			src.y = src3.y;
			src.z = src3.z;
			dest.x = des3.x;
			dest.y = des3.y;
			dest.z = des3.z;
			
			src3.x = enemyPos.x - playerNode.pos.x;
			src3.y = enemyPos.y - playerNode.pos.y;
			src3.z = enemyPos.z - playerNode.pos.z;
			var d:Number = Intersect3D.rayIntersectsEllipsoid(src3, des3, playerNode.size );
			
			if ( d < 0) {
				//throw new Error("Should not really happen...really!")
				return false;
			}
			
			var data:RayIntersectionData = rayScene.intersectRay(src, dest);
			//if (data != null) throw new Error("RRRGOT Intersect!");
			return data != null ? data.time > d : true;
		}
		//*/
		
	//	/*
		override public function validateWeaponLOS (attacker:Pos, sideOffset:Number, heightOffset:Number, target:Pos, targetSize:Ellipsoid) : Boolean {
			// compare ray from weapon origin to ellipsoid distance vs distance of RayIntersectionData distance
			
			des3.x =  (target.y - attacker.y);
			des3.y =   -(target.x- attacker.x);
			des3.z = 1/ Math.sqrt(des3.x * des3.x + des3.y * des3.y);
			des3.x *= des3.z;
			des3.y *= des3.z;
			
			src3.x = attacker.x + des3.x*sideOffset;
			src3.y = attacker.y + des3.y*sideOffset;
			src3.z = attacker.z + heightOffset;
			src.x = src3.x;
			src.y = src3.y;
			src.z = src3.z;
			
			des3.x =  target.x - src3.x;
			des3.y =   target.y- src3.y;
			des3.z =    target.z - src3.z;
			
			var dm:Number = 1 /	Math.sqrt( des3.x * des3.x + des3.y * des3.y + des3.z * des3.z );
			des3.x *= dm;
			des3.y *= dm;
			des3.z *= dm;
			dest.x = des3.x;
			dest.y = des3.y;
			dest.z = des3.z;
			
			
			src3.x = attacker.x - target.x;
			src3.y = attacker.y - target.y;
			src3.z = attacker.z - target.z;
			var d:Number = Intersect3D.rayIntersectsEllipsoid(src3, des3, targetSize );
			if ( d < 0) return false;
			
			var data:RayIntersectionData = rayScene.intersectRay(src, dest);
			
			//if (data != null && data.time <= d) throw new Error("BLOCKED!");
			
			return data != null ? data.time > d : true;
		}
		//*/
		
	}

}