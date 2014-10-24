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
		
		public var zOffsetRatio:Number = 0;// .5;
		
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
			
	
			// cleanup
			for (i = 0; i < removeCount; i++) {
				totalIndices--;
				index = toRemoveIndices[i];
				
				if (index != totalIndices) {  // pop back
					dynamicIndices[index] = dynamicIndices[totalIndices];
					//delete dataHash[dynamicIndices[totalIndices]];
				}
				else {  // regular pop
					delete dataHash[index];
				}
			}	
			removeCount = 0;
			
			//if (totalIndices > 0) throw new Error("A");
			// determine any resolvers to trigger'
			

			for (var i:int = 0; i < totalIndices; i++ ) {
				//dynamicIndices[i];
				var index:int = dynamicIndices[i];
				var baseI:int = index * indexSize;
				var arr:Array = dataHash[index];
					if (arr == null) throw new Error("Null arr found!");
				var pos:Pos = arr[3];
				var hpDeal:int = arr[2];
			
				
				
				data[baseI + endPosOffset] = pos.x;
				data[baseI + endPosOffset+1] = pos.y;
				data[baseI + endPosOffset + 2] = hpDeal != 0 ?   pos.z + zOffsetRatio * arr[4] :  pos.z  - arr[4];
				
				var endTime:Number = data[baseI + timeStampOffset] + data[baseI + totalTimeOffset];
				if (timeStamp  >= endTime ) {
	
					resolver.processHit( arr[0], arr[1], arr[2], data[baseI + endPosOffset], data[baseI + endPosOffset + 1], data[baseI + endPosOffset + 2] );
					
					 
					toRemoveIndices[removeCount++] = i;
					data[baseI + endPosOffset] = 9999999999999;
					data[baseI + endPosOffset+1] =9999999999999;
					data[baseI + endPosOffset + 2] = 9999999999999;
					data[baseI ] = 9999999999999;
					data[baseI +1] =9999999999999;
					data[baseI +2] = 9999999999999;
					
					
					
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
			endPos.z =hpDeal != 0 ?   pos.z + zOffsetRatio * targetEllipsoid.z :  pos.z - targetEllipsoid.z;
			var result:Number = launcher.launchNewProjectile(startPos, endPos, speed);
			var indexer:int =  launcher.getLastLaunchedIndex();
			dynamicIndices[totalIndices++] = indexer;
			if (launcherEntity == null || targetEntity == null || pos == null) throw new Error("NULl data!");
			dataHash[indexer ] = [launcherEntity, targetEntity,  hpDeal, pos, targetEllipsoid.z];
			return result;
		}
		
		
		
	}

}