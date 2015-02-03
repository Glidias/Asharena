package alternativa.a3d.systems.enemy 
{
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.RayIntersectionData;
	import alternativa.types.Float;
	import arena.components.char.EllipsoidPointSamples;
	import arena.components.weapon.Weapon;
	import arena.systems.enemy.AggroMemNode;
	import arena.systems.player.IWeaponLOSChecker;
	import ash.core.Engine;
	import ash.core.Node;
	import ash.core.NodeList;
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
		
		public var aggroMemList:NodeList;
		
		public function A3DEnemyAggroSystem(rayScene:Object3D) 
		{
			this.rayScene = rayScene;
		}
		
		override public function addToEngine (engine:Engine) : void {
			super.addToEngine(engine);
			aggroMemList = engine.getNodeList(AggroMemNode);
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
			var dm:Number;
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
			
			dm = 1 /	Math.sqrt( des3.x * des3.x + des3.y * des3.y + des3.z * des3.z );
			des3.x *= dm;
			des3.y *= dm;
			des3.z *= dm;
			dest.x = des3.x;
			dest.y = des3.y;
			dest.z = des3.z;

			src3.x = src3.x - target.x;
			src3.y = src3.y - target.y;
			src3.z = src3.z - target.z;
			var d:Number = Intersect3D.rayIntersectsEllipsoid(src3, des3, targetSize );
			if ( d < 0) {
				//throw new Error("SHOULD NOT BE! There should be intersection!");
				return false;
				
			//	//d = src3.x * des3.x  + src3.y * des3.y + src3.z * des3.z;
			//	d = d < 0 ? -d : d;
			}
			
			var data:RayIntersectionData = rayScene.intersectRay(src, dest);
			//data = null;
			//if (data != null && data.time <= d) throw new Error("BLOCKED!");
			
			return data != null ? data.time > d : true;
		}
		//*/
		
		
		public function getTotalExposure( attacker:Pos, weapon:Weapon, target:Pos, targetSize:Ellipsoid, targetPts:EllipsoidPointSamples):Number {
			// TODO: consider stance...
			var sizeX:Number = targetSize.x;
			var sizeY:Number = targetSize.y;
			var sizeZ:Number = targetSize.z;
			
			var d:Number;
			var dm:Number;
			var data:RayIntersectionData;
			
			// get normalized right vector
			des3.x =  (target.y - attacker.y);
			des3.y =   -(target.x- attacker.x);
			des3.z = 1/ Math.sqrt(des3.x * des3.x + des3.y * des3.y);
			des3.x *= des3.z;
			des3.y *= des3.z;
			
			// move up src position by right vector and height offset to get muzzle position
			src3.x = attacker.x + des3.x*weapon.sideOffset;
			src3.y = attacker.y + des3.y*weapon.sideOffset;
			src3.z = attacker.z + weapon.heightOffset;
			src.x = src3.x;
			src.y = src3.y;
			src.z = src3.z;
			
			var aimIndex:int = 0;
			
			var len:int = targetPts.numPoints;
			var count:int = 0;
			for (var i:int = 0; i < len; i++) {
				
				dest.x = target.x + targetPts[aimIndex]*sizeX;
				dest.y = target.y + targetPts[aimIndex+1]*sizeY;
				dest.z = target.z + targetPts[aimIndex + 2]*sizeZ;
			
				
				
				// get difference ray dir
				des3.x =  dest.x - src3.x;
				des3.y =  dest.y- src3.y;
				des3.z =   dest.z - src3.z;
				
				// get normalized ray dir
				d = Math.sqrt( des3.x * des3.x + des3.y * des3.y + des3.z * des3.z );
				dm = 1 /	d;
				dest.x = des3.x*dm;
				dest.y = des3.y*dm;
				dest.z = des3.z * dm;
				
				// TODO: optimize ray intersection data set for scene..
				data = rayScene.intersectRay(src, dest);  // TODO: ensure target excluded
				if ( data == null || data.time >= d) {  // clear shot through
					count++;
				}
				
				
				aimIndex += 3;
			}
			
			
			
			return count / len;
			
		}
		


		public function validateWeaponLOS2(attacker:Pos, weapon:Weapon, target:Pos, targetSize:Ellipsoid, targetPts:EllipsoidPointSamples, inputPos:Vec3, aimIndex:int, aimedOnTarget:Boolean) : int {
			var data:RayIntersectionData;
			var dm:Number;
			// compare ray from weapon origin to ellipsoid distance vs distance of RayIntersectionData distance
			
			// TODO: consider stance...
			var sizeX:Number = targetSize.x;
			var sizeY:Number = targetSize.y;
			var sizeZ:Number = targetSize.z;
			
			// get normalized right vector
			des3.x =  (target.y - attacker.y);
			des3.y =   -(target.x- attacker.x);
			des3.z = 1/ Math.sqrt(des3.x * des3.x + des3.y * des3.y);
			des3.x *= des3.z;
			des3.y *= des3.z;
			
	
			
			// move up src position by right vector and height offset to get muzzle position
			src3.x = attacker.x + des3.x*weapon.sideOffset;
			src3.y = attacker.y + des3.y*weapon.sideOffset;
			src3.z = attacker.z + weapon.heightOffset;
			src.x = src3.x;
			src.y = src3.y;
			src.z = src3.z;

			// Raycast result:
			// -4 enemy hit deflect
			// -3 nothing hit 
			// -2 friendly fire hit, (should hold fire)
			// -1 static obstalce hit deflect
			// 0 - center of mass of target hit
			// 1 - index of target hit spot-1
			
			var nearestResult:int = -3; 
			var d:Number;
			
			if (aimIndex >= 0) {  
			
				if (aimIndex != 0 ) {  // aim at index point-1
					nearestResult = aimIndex;
					aimIndex--;
					aimIndex *= 3;
					dest.x = target.x + targetPts[aimIndex]*sizeX;
					dest.y = target.y + targetPts[aimIndex+1]*sizeY;
					dest.z = target.z + targetPts[aimIndex + 2]*sizeZ;

				}	
				else {
					dest.x = target.x;
					dest.y = target.y;
					dest.z = target.z;
					nearestResult = 0;
				}
				
				// get difference ray dir
				des3.x =  dest.x - src3.x;
				des3.y =  dest.y- src3.y;
				des3.z =   dest.z - src3.z;
				
				// get normalized ray dir
				d = Math.sqrt( des3.x * des3.x + des3.y * des3.y + des3.z * des3.z );
				dm = 1 /	d;
				dest.x = des3.x*dm;
				dest.y = des3.y*dm;
				dest.z = des3.z*dm;

				// TODO: broadphase intersect ray sample
				data = rayScene.intersectRay(src, dest);  // TODO: ensure target excluded
				if ( data != null && data.time < d) {  // intercept ray
					
					if ( data.object.name === "e") {
						nearestResult = -4;
					}
					else if (data.object.name === "f") {
						nearestResult = -2;
					}
					else {
						nearestResult = -1;
					}
				}
			}
			else  { // run through all possible cases
				throw new Error("All raycast check...Not supported at the moment!");
			}
			
			
			// Deviation phase (kiv for now)
			/*
			if (nearestResult >= 0) {  // successful targeting over hit spot...Now, attempt to shoot deviated ray for FinalRaycast!
				
				// TODO: deviate dest accordginly!!
				//Math.random() * 2;
				
				data = rayScene.intersectRay(src, dest);  // TODO: ensure target included
				if ( data != null && data.time < d) { 
					if ( data.object.name === "e") {
						nearestResult = -4;
					}
					else if (data.object.name === "f") {
						nearestResult = -2;
					}
					else if (data.object.name === "t") {  // TARGET HIT!!
						// record final position
						// TODO: globalise pt 
						inputPos.x = data.point.x;
						inputPos.y = data.point.y;
						inputPos.z = data.point.z;
					}
					else {
						nearestResult = -1;
					}
				}
			}
			*/

			
			return nearestResult;
		}

		
	}

}