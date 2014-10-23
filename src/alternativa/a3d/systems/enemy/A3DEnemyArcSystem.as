package alternativa.a3d.systems.enemy 
{
	import alternativa.a3d.objects.UVMeshSet2;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.materials.FillMaterial;
	import alternativa.engine3d.materials.Material;
	import alternativa.engine3d.resources.Geometry;
	import arena.components.char.AggroMem;
	import arena.systems.enemy.EnemyAggroNode;
	import arena.systems.enemy.EnemyIdleNode;
	import arena.systems.enemy.EnemyWatchNode;
	import arena.systems.player.PlayerAggroNode;
	import ash.core.Engine;
	import ash.core.NodeList;
	import ash.core.System;
	import flash.display3D.Context3D;
	import flash.geom.Vector3D;
	import util.SpawnerBundle;
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class A3DEnemyArcSystem  extends System
	{
		private var aggroList:NodeList;
		private var idleList:NodeList;
		private var watchList:NodeList;
		
		private var aggroArcs:UVMeshSet2;
		private var idleArcs:UVMeshSet2;
		private var watchArcs:UVMeshSet2;

		
		public var arcs:Object3D;
		
		private var playerList:NodeList;
		
		public function A3DEnemyArcSystem(scene:Object3D) 
		{
			this.scene = scene;
			this.arcs = new Object3D();
			scene.addChild(arcs);
			initUVMeshSets();
		}
		
		private function initUVMeshSets():void 
		{
			var geom:Geometry = UVMeshSet2.createDoubleSidedPlane( null, 16, 5);
			//UVMeshSet2.taperGeometryAtStart(geom, .5);
			var geom2:Geometry = UVMeshSet2.createDoubleSidedPlane( null, 16, 5);
			UVMeshSet2.taperGeometryAtEnd(geom2, .67);
			
			var mat1:Material;
			var mat2:Material;
			var mat3:Material;
			
			var obj:Object3D = new Object3D();
		
			aggroArcs = new UVMeshSet2(geom,geom2, mat1=new FillMaterial(0xFF0000, .4) );
			watchArcs = new UVMeshSet2(geom,geom2, mat2=new FillMaterial(0xFFFFFF, .4), aggroArcs.geometry );
			idleArcs = new UVMeshSet2(geom,geom2, mat3=new FillMaterial(0x0000FF, .4), aggroArcs.geometry );
			
			arcs.addChild(aggroArcs);
			arcs.addChild(watchArcs);
			arcs.addChild(idleArcs);
	
			
			SpawnerBundle.uploadResources(aggroArcs.getResources(true));
			SpawnerBundle.uploadResources(watchArcs.getResources(true));
			SpawnerBundle.uploadResources(idleArcs.getResources(true));
		}
		

		
		
		
		
		
		private function addToScene():void {
			scene.addChild(arcs);
			
		}
		
		private function removeFromScene():void {
			if (arcs.parent) arcs.parent.removeChild(arcs);
		}
		
		
		
		override public function addToEngine(engine:Engine):void {
			aggroList = engine.getNodeList(EnemyAggroNode);
			idleList = engine.getNodeList(EnemyIdleNode);
			watchList = engine.getNodeList(EnemyWatchNode);
			playerList = engine.getNodeList(PlayerAggroNode);
			
			// this should be added last
			addToScene();
			
			
			//aggroList.add(
		}
		
		override public function removeFromEngine(engine:Engine):void {
			
			removeFromScene();
			
		}
		
		private var scene:Object3D;
		private var playerPosition:Vector3D = new Vector3D();
		public var playerZOffset:Number =10;
		public var playerToEnemyZOffset:Number = 10;
		public var arcZOffset:Number = 124;
		
		override public function update(time:Number):void {
			if (playerList.head == null) return;
			
			var count:int;
			
			var player:PlayerAggroNode = playerList.head as PlayerAggroNode;
			playerPosition.x = player.pos.x;
			playerPosition.y = player.pos.y;
			playerPosition.z = player.pos.z + player.size.z + playerZOffset;
			
			var dataList:Vector.<Number>;
			var stride:int = 4 * 2;
			
		
			var index:int;
			
			
			
			index = 0;
			count = 0;
			dataList = aggroArcs.toUpload;
			for (var a:EnemyAggroNode = aggroList.head as EnemyAggroNode; a != null; a = a.next as EnemyAggroNode) {
				//if (a.entity.get(AggroMem).engaged) continue;
				
				if (a.state.fixed) continue;
				
				dataList[index++] = a.state.target.pos.x;
				dataList[index++] = a.state.target.pos.y;
				dataList[index++] = a.state.target.pos.z + a.state.target.size.z + playerZOffset;
				dataList[index++] = 0;
				
				dataList[index++] = a.pos.x;
				dataList[index++] = a.pos.y;
				dataList[index++] = a.pos.z;
				dataList[index++] = arcZOffset;
		
				count++;
			}
			aggroArcs.total = count;
			
			index = 0;
			count = 0;
			dataList = idleArcs.toUpload;
			for (var i:EnemyIdleNode = idleList.head as EnemyIdleNode; i != null; i = i.next as EnemyIdleNode) {
		
				
				dataList[index++] = playerPosition.x;
				dataList[index++] = playerPosition.y;
				dataList[index++] = playerPosition.z;
				dataList[index++] = 0;
				
				dataList[index++] = i.pos.x;
				dataList[index++] = i.pos.y;
				dataList[index++] = i.pos.z + 32 + playerToEnemyZOffset;
				dataList[index++] = arcZOffset;
				
				
				count++;
			}
			idleArcs.total = count;
			
			
			index = 0;
			count = 0;
			dataList = watchArcs.toUpload;
			for (var w:EnemyWatchNode = watchList.head as EnemyWatchNode; w != null; w = w.next as EnemyWatchNode) {
				
				//if (w.aggroMem.engaged) continue;
				dataList[index++] = playerPosition.x;
				dataList[index++] = playerPosition.y;
				dataList[index++] = playerPosition.z;
				dataList[index++] = 0;
				
				dataList[index++] = w.pos.x;
				dataList[index++] = w.pos.y;
				dataList[index++] = w.pos.z + 32 + playerToEnemyZOffset;
				dataList[index++] = arcZOffset;
				
				count++;
			}
			watchArcs.total = count;
			
			
		}
		
		
		
	}

}