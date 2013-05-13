package  
{
	import alternativa.engine3d.core.BoundBox;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.loaders.ParserMaterial;
	import alternativa.engine3d.loaders.TexturesLoader;
	import alternativa.engine3d.materials.FillMaterial;
	import alternativa.engine3d.materials.StandardMaterial;
	import alternativa.engine3d.materials.TextureMaterial;
	import alternativa.engine3d.objects.Skin;
	import alternativa.engine3d.primitives.Box;
	import alternativa.engine3d.resources.BitmapTextureResource;
	import alternativa.engine3d.utils.Object3DUtils;
	import ash.core.Engine;
	import ash.core.Entity;
	import components.ActionIntSignal;
	import components.Pos;
	import components.Rot;
	import flash.display3D.Context3D;
	import flash.utils.Dictionary;
	import systems.animation.IAnimatable;
	import systems.player.a3d.GladiatorStance;
	import alternativa.engine3d.alternativa3d;
	use namespace alternativa3d;
	
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class ArenaSpawner extends Spawner
	{
	
		private var skinDict:Dictionary = new Dictionary();
		
		
		public static const RACE_SAMNIAN:String = "samnian";
		public var context3D:Context3D;
		
		public function ArenaSpawner(engine:Engine) 
		{
			super(engine);
		}
		
		public function setupSkin(skin:Skin, race:String):void {
			if ( skin._surfaces[0].material is StandardMaterial ) {
				skin.geometry.calculateNormals();
				skin.geometry.calculateTangents(0);
				
			}

			skin._rotationX = Math.PI * .5;
			skin._rotationZ = Math.PI;
			skin.calculateBoundBox();
			var obj:Object3D = new Object3D();
			obj.addChild(skin);
			Object3DUtils.calculateHierarchyBoundBox(obj, obj, obj.boundBox=new BoundBox());
			skin.boundBox = obj.boundBox;
			skin.boundBox.minX -= 10;
			skin.boundBox.minY -= 10;
			skin.boundBox.minZ -=10;
			skin.boundBox.maxX += 10;
			skin.boundBox.maxY += 10;
			skin.boundBox.maxZ += 10;
			
			skin.geometry.upload(context3D);
			
			skinDict[race] = skin;
		}
		
		private function addRenderEntity(obj:Object3D, pos:Pos, rot:Rot):Entity {
			var ent:Entity = new Entity();
			ent.add(pos).add(rot).add(obj, Object3D);
			engine.addEntity(ent);
			return ent;
		}
		
		private function getBoundingBox(bb:BoundBox):Box {
			var box:Box = new Box((bb.maxX - bb.minX), (bb.maxY - bb.minY), (bb.maxZ - bb.minZ) );
			
			box.x = bb.minX + (bb.maxX - bb.minX) * .5;
			box.y = bb.minY + (bb.maxY - bb.minY) * .5;
			box.z = bb.minZ + (bb.maxZ - bb.minZ) * .5;
			
			box.geometry.upload(context3D);
			var mat:FillMaterial = new FillMaterial(0xFF0000, .2);
			box.setMaterialToAllSurfaces( mat);
			
			
			return box;
		}
		
		 public function addGladiator(race:String):Entity {
			var ent:Entity = getGladiatorBase();
			var skProto:Skin = skinDict[race];
			var sk:Skin = skProto.clone() as Skin;
			
			var obj:Object3D;
			
			obj = new Object3D();
			obj.boundBox = sk.boundBox;
			
			sk.boundBox = null;
			
			obj.addChild(sk);
			ent.add(obj, Object3D);
			
			var bb:BoundBox;
			bb = obj.boundBox;
			
			//addRenderEntity(getBoundingBox(bb), ent.get(Pos) as Pos, ent.get(Rot) as Rot);
			
			var actions:ActionIntSignal = ent.get(ActionIntSignal) as ActionIntSignal;	
			var gladiatorStance:GladiatorStance = new GladiatorStance(sk);
			actions.add( gladiatorStance.handleAction );
			ent.add(gladiatorStance, IAnimatable);
			
			engine.addEntity(ent);
			
			return ent;
		}
		
	}

}