package alternativa.a3d.systems.hud 
{
	import alternativa.engine3d.core.Camera3D;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.Transform3D;
	import alternativa.engine3d.objects.Sprite3D;
	import alternativa.engine3d.spriteset.ISpriteSet;
	import alternativa.engine3d.utils.Object3DTransformUtil;
	import arena.components.char.MovementPoints;
	import ash.core.Engine;
	import ash.core.NodeList;
	import ash.core.System;
	import components.Pos;
	import components.Rot;
	import alternativa.engine3d.alternativa3d;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	use namespace alternativa3d;
	
	/**
	 * ...
	 * @author Glidias
	 */
	public class HealthBarRenderSystem extends System
	{
		private var nodeList:NodeList;

		private var data:Vector.<Number>;
		private var spriteSet:ISpriteSet;
		
		public var maskValue:uint;
		
		public function HealthBarRenderSystem(spriteSet:ISpriteSet, mask:uint=0) 
		{
			this.spriteSet = spriteSet;
			this.maskValue = mask;
			
			data = spriteSet.getSpriteData();
			
		}
		
		override public function addToEngine (engine:Engine) : void {
			nodeList = engine.getNodeList(HPBarNode);
		}
		
			private var epsilon:Number = 0.000001;
			
		override public function update(time:Number):void {
			data.fixed = false;
			var totalSprites:int = 0;
			var fullHealth:Number = 1 - epsilon
			//var noHealth:Number = epsilon;
			var count:int = 0;
			for (var n:HPBarNode = nodeList.head as HPBarNode; n != null; n = n.next as HPBarNode) {
				if ( n.health.flags != 0 && !(n.health.flags & maskValue) ) {  //n.entity.has(MovementPoints)
					continue;
				}
				var hpRatio:Number = n.health.hp / n.health.maxHP;
				hpRatio = hpRatio >= 1 ? fullHealth : hpRatio;
				data[count++] = n.pos.x;
				data[count++] = n.pos.y ;
				data[count++] = n.pos.z + n.size.z + 22;
				data[count++] = int(n.size.x) + hpRatio;
				totalSprites++;			
			}

		
			spriteSet.setNumSprites(totalSprites);
			data.fixed = true;
		}
		
	}

}

import alternativa.engine3d.core.Object3D;
import alternativa.engine3d.objects.Sprite3D;
import ash.ClassMap;
import ash.core.Node;
import components.Ellipsoid;
import components.Health;
import components.Pos;
import components.Rot;

class HPBarNode extends Node {
	public var pos:Pos;
	public var size:Ellipsoid;
	public var health:Health;
	
	public function HPBarNode() {
		
	}
	
	private static var _components:ClassMap;
	
	public static function _getComponents():ClassMap {
		if(_components == null) {
				_components = new ClassMap();
				_components.set(Pos, "pos");
				_components.set(Ellipsoid, "size");
				_components.set(Health, "health");
			
		}
			return _components;
	}
}



