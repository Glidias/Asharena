package alternativa.a3d.systems.hud
{
	import alternativa.a3d.collisions.CollisionBoundNode;
	import alternativa.engine3d.core.Object3D;
	import arena.components.char.MovementPoints;
	import components.controller.SurfaceMovement;
	import components.Gravity;
	import systems.collisions.EllipsoidCollider;
	import systems.collisions.IECollidable;
	
	import alternativa.engine3d.core.RayIntersectionData;
	import arena.views.hud.ArenaHUD;
	import ash.core.System;
	import components.Ellipsoid;
	import components.Pos;
	import components.Rot;
	import flash.geom.Vector3D;
	import alternativa.a3d.rayorcollide.ITrajRaycastImpl;

	import util.geom.Vec3;
	
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class DestCalcTester extends System
	{
		public var collisionNode:IECollidable;
		public var ellipsoid:Ellipsoid;
		private var collider:EllipsoidCollider;
		public var rot:Vec3;
		private var velocity:Vector3D;
		public var distance:Number;
		private var source:Vector3D;
		private var resPlane:Vector3D;
		private var resPoint:Vector3D;
		public var obj3D:Object3D;
		public var pos:Vec3;
		public var gravity:Gravity;
		public var speed:Number;
		public var surfaceMovement:SurfaceMovement;
		public var movementPoints:MovementPoints;
		
		public function DestCalcTester(ellipsoid:Ellipsoid, pos:Vec3, rot:Vec3, collisionNode:IECollidable, obj3D:Object3D)
		{
			this.obj3D = obj3D;
			this.pos = pos;
			this.rot = rot;
			this.ellipsoid = ellipsoid;
			this.collisionNode = collisionNode;
			collider = new EllipsoidCollider(32, 32, 32);
			velocity = new Vector3D();
			resPoint = new Vector3D();
			resPlane = new Vector3D();
			source = new Vector3D();
			distance = 222;
			
			speed = 100;
		}
		
		
		
		
		override public function update(t:Number):void
		{
			collider.radiusX = ellipsoid.x;
			collider.radiusY = ellipsoid.y;
			collider.radiusZ = ellipsoid.z;
			
			
			if (surfaceMovement != null) {
				speed = surfaceMovement.WALK_SPEED;
			}
			if ( movementPoints != null) {
				distance = ( movementPoints.movementTimeLeft >= 0 ?  movementPoints.movementTimeLeft : 0) * speed;
			}
			
			
			velocity.x  =  -Math.sin(rot.z) * distance;
			velocity.y = Math.cos(rot.z) * distance;
			velocity.z =   0;// gravity !=  null ? -gravity.force * distance / speed : 0;
			//if (velocity.z > 0 ) throw new Error("SHOULD NOT BE");
			source.x = pos.x;
			source.y = pos.y;
			source.z = pos.z;
			
			var dest:Vector3D = collider.calculateDestination(source, velocity, collisionNode);
			obj3D.x = dest.x;
			obj3D.y = dest.y;
			obj3D.z = dest.z - ellipsoid.z;
			
			
			source.x =obj3D.x;
			source.y =obj3D.y;
			source.z = obj3D.z + ellipsoid.z;
			
			velocity.x = 0;
			velocity.y = 0;
			velocity.z = -999;
			if ( collider.getCollision(source, velocity, resPoint, resPlane, collisionNode) ) {
					
				obj3D.z = resPoint.z - ellipsoid.z;
				//throw new Error("A");
				
			}
			
		
			
		}
	}

}