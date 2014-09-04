package alternativa.a3d.objects 
{
	import components.Ellipsoid;
	import ash.core.Entity;
	import components.Pos;
	import arena.systems.weapon.IProjectileDomain;
	import arena.systems.weapon.IProjectileHitResolver;
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class ProjectileDomain implements IProjectileDomain
	{
		private var launcher:IProjectileLauncher;
		private var resolver:IProjectileHitResolver;
		
		private var startPos:Vector3D = new Vector3D();
		private var endPos:Vector3D = new Vector3D();
		
		public var zOffsetRatio:Number = .5;
		
		private var dynamicIndices:Vector.<int> = new Vector.<int>();
		private var totalIndices:int = 0;
		
		private var toRemoveIndices:Vector.<int> = new Vector.<int>();
		private var removeCount:int = 0;
		
		private var data:Vector.<Number> = new Vector.<Number>();
		private var indexSize:int;
		private var timeStampOffset:int;
		private var totalTimeOffset:int;
		
		private var dataHash:Dictionary = new Dictionary();
		private var endPosOffset:int;

		
		public function ProjectileDomain(launcher:IProjectileLauncher=null) 
		{
			if (launcher != null) {
				init(launcher);
			}
		}
		
		public function init(launcher:IProjectileLauncher):void {
			this.launcher = launcher;
			
			data = launcher.getDataVector();
			indexSize = launcher.getIndexSize();
			timeStampOffset = launcher.getTimeStampOffset();
			totalTimeOffset = launcher.getTotalTimeOffset();
			endPosOffset = launcher.getEndPositionOffset();
		}
		
		/* INTERFACE arena.systems.weapon.IProjectileDomain */
		
		public function update(time:Number):Number 
		{
			
			var remainingTime:Number = 0;
			var testTime:Number;
			
			launcher.update(time);
			var timeStamp:Number = launcher.getTime();
			
			// TODO:
			// cleanup
			for (i = 0; i < removeCount; i++) {
				totalIndices--;
			}	
			removeCount = 0;
			
			// determine any resolvers to trigger
			for (var i:int = 0; i < totalIndices; i++ ) {
				//dynamicIndices[i];
				var index:int = dynamicIndices[i];
				var baseI:int = index * indexSize;
				var endTime:Number = dataHash[baseI + timeStampOffset] + dataHash[baseI + totalTimeOffset];
				if (timeStamp  >= endTime ) {
					var arr:Array = dataHash[index];
					delete dataHash[index];
					toRemoveIndices[removeCount++] = i;
					resolver.processHit( arr[0], arr[1], arr[2], data[baseI + endPosOffset], data[baseI + endPosOffset + 1], data[baseI + endPosOffset + 2] ); 
				}
				
			}
			
			return 0;
		}
		
		public function setHitResolver(resolver:IProjectileHitResolver):void 
		{
			this.resolver = resolver;
			//resolver.processHit(
			
		}
		
		public function launchStaticProjectile(sx:Number, sy:Number, sz:Number, ex:Number, ey:Number, ez:Number, speed:Number):Number 
		{
			startPos.x = sx;
			startPos.y = sy;
			startPos.z = sz;
			endPos.x = ex;
			endPos.y = ey;
			endPos.z = ez;
			return launcher.launchNewProjectile(startPos, endPos, speed);
		}
		
		public function launchDynamicProjectile(sx:Number, sy:Number, sz:Number, pos:Pos, speed:Number,  launcherEntity:Entity, targetEntity:Entity, targetEllipsoid:Ellipsoid, hpDeal:int):Number 
		{
			startPos.x = sx;
			startPos.y = sy;
			startPos.z = sz;
			endPos.x = pos.x;
			endPos.y = pos.y;
			endPos.z = pos.z + zOffsetRatio * targetEllipsoid.z;
			var result:Number = launcher.launchNewProjectile(startPos, endPos, speed);
			var indexer:int =  launcher.getLastLaunchedIndex();
			dynamicIndices[totalIndices++] = indexer;
			dataHash[indexer ] = [launcherEntity, targetEntity,  hpDeal];
			return result;
		}
		
		
		
	}

}