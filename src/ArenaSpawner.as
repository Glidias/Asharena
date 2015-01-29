package  
{
	import alternativa.engine3d.core.BoundBox;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.Resource;
	import alternativa.engine3d.loaders.ParserMaterial;
	import alternativa.engine3d.loaders.TexturesLoader;
	import alternativa.engine3d.materials.FillMaterial;
	import alternativa.engine3d.materials.Material;
	import alternativa.engine3d.materials.StandardMaterial;
	import alternativa.engine3d.materials.TextureMaterial;
	import alternativa.engine3d.objects.Mesh;
	import alternativa.engine3d.objects.Skin;
	import alternativa.engine3d.primitives.Box;
	import alternativa.engine3d.primitives.GeoSphere;
	import alternativa.engine3d.resources.BitmapTextureResource;
	import alternativa.engine3d.utils.Object3DUtils;
	import arena.components.char.AggroMem;
	import arena.components.char.ArenaCharacterClass;
	import arena.components.char.CharDefense;
	import arena.components.char.EllipsoidPointSamples;
	import arena.components.enemy.EnemyIdle;
	import arena.components.enemy.EnemyWatch;
	import arena.components.weapon.Weapon;
	import arena.components.weapon.WeaponSlot;
	import arena.systems.player.IStance;
	import ash.core.Engine;
	import ash.core.Entity;
	import ash.signals.Signal0;
	import ash.signals.Signal1;
	import components.ActionIntSignal;
	import components.ActionUIntSignal;
	import components.controller.SurfaceMovement;
	import components.Ellipsoid;
	import components.Health;
	import components.MovableCollidable;
	import components.Pos;
	import components.Rot;
	import components.Vel;
	import de.popforge.revive.member.MovableCircle;
	import flash.display.Stage;
	import flash.display3D.Context3D;
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;
	import input.KeyPoll;
	import systems.animation.IAnimatable;
	import systems.player.a3d.GladiatorStance;
	import alternativa.engine3d.alternativa3d;
	import util.geom.Vec3;
	use namespace alternativa3d;
	
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class ArenaSpawner extends Spawner 
	{
	
		private var skinDict:Dictionary = new Dictionary();
		private var charClasses:Dictionary = new Dictionary();
		
		public static const RACE_SAMNIAN:String = "Samnian";
		//public static const RACE_DOMOCHAI:String = "dimochai";
		//public static const RACE_FLAMMITE:String = "flammite";
		//public static const RACE_SLAVUS:String = "slavus";
		
		public var currentPlayer:Object3D;
		public var currentPlayerSkin:Skin;
		public var currentPlayerEntity:Entity;
		public function getPlayerEntity():Entity {
			return currentPlayerEntity;
		}
		private var _currentPlayerEntityChanged:Signal1 = new Signal1();
		public function get playerEntityChanged():Signal1 {
			return _currentPlayerEntityChanged;
		}	
		
		private var defaultEnemyWatchMelee:EnemyIdle = new EnemyIdle().init(9000, 200);
		
		private var gladiatorPointSamples:EllipsoidPointSamples;
		
		public function ArenaSpawner(engine:Engine, keyPoll:KeyPoll) 
		{
			super(engine);
			this.keyPoll = keyPoll;
			
			gladiatorPointSamples = new EllipsoidPointSamples();
			gladiatorPointSamples.init(new Vec3(32, 32, 72), 100);
			
		}
		
		public function switchPlayer(ent:Entity, stage:Stage):void {
			
			var gladiatorStance:GladiatorStance;
			
			if (currentPlayerEntity ) {
				gladiatorStance = currentPlayerEntity.get(IAnimatable) as GladiatorStance;
				if (gladiatorStance) gladiatorStance.unbindKeys(stage);
				currentPlayerEntity.remove(KeyPoll);
				setAsNonPlayer(currentPlayerEntity);
				var vel:Vel = currentPlayerEntity.get(Vel) as Vel;
				if (vel) {
					
					vel.x = 0;
					vel.y = 0;
			
					
				}
				
			}
			
			currentPlayerEntity = ent;
			if (ent == null) {
				currentPlayer = null;
				currentPlayerSkin = null;
				_currentPlayerEntityChanged.dispatch(null);
				return;
			}
		
			
			currentPlayer = ent.get(Object3D) as Object3D;
			currentPlayerSkin = findSkin(currentPlayer);
			setAsSinglePlayer(ent);
			gladiatorStance = ent.get(IAnimatable) as GladiatorStance;
			if (gladiatorStance) gladiatorStance.bindKeys(stage);
			
			keyPoll.resetAllStates();
			currentPlayerEntity.add(keyPoll, KeyPoll);
			
			
			
			_currentPlayerEntityChanged.dispatch(currentPlayerEntity);
			
			
		}
		
		public function findSkin(obj:Object3D):Skin {
			if (obj is Skin) return obj as Skin;
			
			var c:Object3D;
			for ( c = obj.childrenList; c != null; c = c.next) {
				if (c is Skin) return c as Skin;
			}
			return null;
		}
		
		public function getNullEntity():Entity {
			var ent:Entity = new Entity();
			ent.add( new Object3D(),  Object3D);
			ent.add( new Pos());
			ent.add( new Rot());
			
			return ent;
		}
		
		private var keyPoll:KeyPoll;
		public const DUMMY_MATERIAL:FillMaterial = new FillMaterial(0xDD64AA);
		private var dummyBox:Box;
		public function getNewDummyBox(context3D:Context3D):Box {
			dummyBox = new Box(32, 32, 72, 1, 1, 1, false, DUMMY_MATERIAL);
			dummyBox.geometry.upload(context3D);
			return dummyBox;
		}
		
		public function getPlayerBoxEntity(context3D:Context3D):Entity {
			var ent:Entity = new Entity();
			var box:Box;
			ent.add(dummyBox ? dummyBox.clone() : getNewDummyBox(context3D),  Object3D);
			

			ent.add( new Pos());
			ent.add( new Rot());
			
			return ent;
		}
		
		public function registerCharacterClass(charClass:ArenaCharacterClass, race:String):void {
			charClasses[race] = charClass;
		}
		
		public function setupSkin(skin:Skin, race:String):void {
			if ( skin._surfaces[0].material is StandardMaterial ) {
				skin.geometry.calculateNormals();
				skin.geometry.calculateTangents(0);
				
			}
			
			var charClass:ArenaCharacterClass;
			if (!charClasses[race]) {
				charClasses[race] = charClass = new ArenaCharacterClass();
				charClass.name = race;
			}

			skin._rotationX = Math.PI * .5;
			skin._rotationZ = Math.PI ;   // for tumble_right

			
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
			

			
			
			var mat:FillMaterial = new FillMaterial(0xFF0000, .2);
			box.setMaterialToAllSurfaces( mat);
			
			
			return box;
		}
		
		private function uploadMesh(m:Mesh, context3D:Context3D):Mesh {
			m.geometry.upload(context3D);
			return m;
		}
		
		public function getSkin(race:String, clone:Boolean=true):Skin {

			var skProto:Skin = skinDict[race];
			var sk:Skin = clone ? skProto.clone() as Skin : skProto;
			return sk;
		}

		
		private var sideTextureResources:Dictionary = new Dictionary();
		
		public function addTextureResourceSide(context3D:Context3D, race:String, side:int, resource:BitmapTextureResource):void {
			if (side < 1) throw new Error("Side needs to be at least 1 or higher from base 0!");
			resource.upload(context3D);
			var skProto:Skin = skinDict[race];
			var untypedMat:* = skProto.getSurface(0).material;
			untypedMat = untypedMat.clone();
			untypedMat.diffuseMap = resource;
			sideTextureResources[race + side] = untypedMat;
			
		}
		
		public function getMaterialSide(race:String, side:int):Material {
			
			return sideTextureResources[race + side];
		}
		
		public function addCrossStage(context3D:Context3D, pos:Pos=null, rot:Rot=null):void {
						
			addRenderEntity( upload( new Box(10, 900, 10, 1, 1, 1, false, new FillMaterial(0xFF0000) ),  context3D), pos || new Pos(), rot || new Rot() );
			addRenderEntity( upload( new Box(900, 10, 10, 1, 1, 1, false, new FillMaterial(0x00FF00) ),  context3D), pos || new Pos(), rot || new Rot() );
		}
		
		 public function addGladiator(race:String, playerStage:IEventDispatcher = null, x:Number = 0, y:Number=0, z:Number=0, azimuth:Number=0, side:int=0, name:String=null, weapon:Weapon=null, watchSettings:EnemyIdle=null, weaponList:WeaponSlot=null):Entity {
			var ent:Entity = getGladiatorBase(x,y,z, 0,0,0, playerStage!=null);
			var skProto:Skin = skinDict[race];
			var sk:Skin = skProto.clone() as Skin;
			if (weaponList != null) {
				ent.add(weaponList);
				if (weapon == null) weapon = weaponList.slots[0];
			}
			
			
			
			var def:CharDefense = ent.get(CharDefense) as CharDefense;
			def.evasion =  .7;// .6;//.4; .5; //1.125; //0.25;
			def.block = .7;// .65;// 1.125;// 0.25;
			
			if (side > 0) {
				var customMat:Material = getMaterialSide(race, side);
				if (customMat == null) throw new Error("No side material found!");
				sk.getSurface(0).material =customMat
				
			}
			
			var obj:Object3D;
			
			obj = new Object3D();
			if (name != null) obj.name = name;
			obj.boundBox = sk.boundBox;
			
			sk.boundBox = null;
			
			obj.addChild(sk);
			ent.add(obj, Object3D);
			
			
			
			ent.add(charClasses[race], ArenaCharacterClass);
			
			/*
			var bb:BoundBox;
			//bb = obj.boundBox;
			bb = new BoundBox();
			bb.minX = -16;
			bb.minY  = -16;
			bb.minZ = -16;
			bb.maxX = 16;
			bb.maxY = 16;
			bb.maxZ = 16;
			*/
			
			(ent.get(Rot) as Rot).z = azimuth;
			
			var ellipsoid:Ellipsoid = ent.get(Ellipsoid) as Ellipsoid;
		//	ellipsoid.z = ellipsoid.x = ellipsoid.y = 36;
			//addRenderEntity(getBoundingBox(bb), ent.get(Pos) as Pos, ent.get(Rot) as Rot);
			var m:Mesh;
				//addRenderEntity(m = uploadMesh(new GeoSphere(1, 2, false, new FillMaterial(0xFF0000, .5))), ent.get(Pos) as Pos, ent.get(Rot) as Rot);
				//m.scaleX = ellipsoid.x;
				//m.scaleY = ellipsoid.y;
				//m.scaleZ = ellipsoid.z;
			
			var actions:ActionIntSignal = ent.get(ActionIntSignal) as ActionIntSignal;	
			var gladiatorStance:GladiatorStance = new GladiatorStance(sk, ent.get(SurfaceMovement) as SurfaceMovement, ellipsoid );
			//gladiatorStance.boneShield.addChild( dummyBox );
			
			if (playerStage != null) {
				gladiatorStance.bindKeys(playerStage);
				currentPlayer = obj;
				currentPlayerSkin = sk;
				currentPlayerEntity = ent;
				ent.add(keyPoll, KeyPoll);
			}
			
			//ent.add(
			actions.add( gladiatorStance.handleAction );
			var attacks:ActionUIntSignal = ent.get(ActionUIntSignal) as ActionUIntSignal;	
			attacks.add(gladiatorStance.handleAttack);
			ent.add(gladiatorStance, IAnimatable);
			ent.add(gladiatorStance, IStance);
			
		
			
			ent.add(gladiatorPointSamples);
			//ent.add( new MovableCollidable().init() );
			
			if (weapon != null) {
				ent.add(weapon);
				gladiatorStance.switchWeapon(weapon);
				if (weapon.fireMode <= 0 && watchSettings == null) {
					watchSettings = new EnemyIdle().init(9000, weapon.range);
				}
			}
			ent.add( new AggroMem().init( (watchSettings || defaultEnemyWatchMelee), side) );
				
			
			engine.addEntity(ent);
			
			
			
			return ent;
		}
		
		/*
		public function XkillGladiator(ent:Entity):void {
			
			// todo: only send signal later...
			ent.remove(Health);
			
			ent.remove(Ellipsoid); // prevent any form of targeting
			ent.remove(Vel);  // stop enemy dead in tracks, prevent gravity from affecting (this might change for airborne enemies)
			
			ent.remove(Weapon);
			ent.remove(AggroMem);
			
			
			//ent.remove(SurfaceMovement);
			//ent.remove(Rot);
			
			var stance:IStance = ent.get(IStance) as IStance;
			if (stance != null) {
				stance.kill(0);
			}
		}
		*/
		
		public function killGladiator2(ent:Entity, deadScene:Object3D):void {
			
			var obj:Object3D = ent.get(Object3D) as Object3D;
			if (obj != null) deadScene.addChild(obj);
			
			var stance:IStance = ent.get(IStance) as IStance;
			var anim:IAnimatable = ent.get(IAnimatable) as IAnimatable;
			
			
			

			engine.removeEntity(ent);
			ent.remove(Health);
			
			// TODO: if gladiator/entity is airborne, need to wait for gladiator to drop to ground first prior to removal,
			// so need to re-add  or consider (Ellipsoid, Pos, Gravity, Vel, SurfaceMovement)
			
			if (stance != null && stance === anim) {
				engine.addEntity( new Entity().add(anim, IAnimatable) );
				stance.kill(0);
			}
			
			//ent.remove(SurfaceMovement);
			//ent.remove(Rot);
		}
		
		public function disableStanceControls(stage:Stage):void 
		{
			var gladiatorStance:GladiatorStance;
			
			
			gladiatorStance = currentPlayerEntity ? currentPlayerEntity.get(IAnimatable) as GladiatorStance : null;
			if (gladiatorStance) gladiatorStance.unbindKeys(stage);
		}
		
		private function upload(obj:Object3D,context3D:Context3D, hierachy:Boolean=false):Object3D 
		{
			var resources:Vector.<Resource> = obj.getResources(hierachy);
			var i:int = resources.length;
			while (--i > -1) {
				resources[i].upload(context3D);
			}
			return obj;
		}
		
	}

}