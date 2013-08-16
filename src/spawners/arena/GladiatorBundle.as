package spawners.arena 
{
	import alternativa.engine3d.animation.AnimationClip;
	import alternativa.engine3d.animation.keys.Track;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.loaders.ParserA3D;
	import alternativa.engine3d.loaders.ParserMaterial;
	import alternativa.engine3d.materials.compiler.SamplerVariable;
	import alternativa.engine3d.materials.Material;
	import alternativa.engine3d.materials.NormalMapSpace;
	import alternativa.engine3d.materials.StandardTerrainMaterial;
	import alternativa.engine3d.materials.StandardTerrainMaterial2;
	import alternativa.engine3d.materials.TextureMaterial;
	import alternativa.engine3d.materials.TextureZClipMaterial;
	import alternativa.engine3d.materials.VertexLightTextureMaterial;
	import alternativa.engine3d.objects.Skin;
	import alternativa.engine3d.objects.Surface;
	import alternativa.engine3d.resources.BitmapTextureResource;
	import ash.core.Engine;
	import flash.display.BitmapData;
	import flash.utils.ByteArray;
	import systems.player.a3d.AnimationManager;
	import systems.player.a3d.GladiatorStance;
	import util.SpawnerBundle;
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class GladiatorBundle extends SpawnerBundle
	{
		public var arenaSpawner:ArenaSpawner;
		
		
		public function GladiatorBundle(spawner:ArenaSpawner) 
		{
			ASSETS = [GladiatorialAnims, Samnian];
			
			this.arenaSpawner = spawner;
			
			super();
		}
		
		override protected function init():void {
			setupAnimStuff();
			
			setupSkin( new Samnian.$_MODEL(), new Samnian.$_TEXTURE().bitmapData, ArenaSpawner.RACE_SAMNIAN);
			
			super.init();
		}
		
		
		
		private function setupSkin(a3d:ByteArray, texture:BitmapData, raceName:String):void 
		{
			
			
			var parserA3D:ParserA3D = new ParserA3D();
			parserA3D.parse(a3d );

			
			var sk:Skin = findSkin( parserA3D.objects );
			
		
			var diffuse:BitmapTextureResource = new BitmapTextureResource(texture);
			diffuse.upload(context3D);
			sk.geometry.calculateNormals();
			/*
			
			var standard:StandardTerrainMaterial = new StandardTerrainMaterial(diffuse, getDummyNormalResource());
			standard.normalMapSpace = NormalMapSpace.OBJECT;
			standard.glossiness = 0;
			standard.specularPower = 0;
			sk.geometry.calculateTangents(0);
			*/
			var textureMat:VertexLightTextureMaterial = new VertexLightTextureMaterial(diffuse);
			
			var injectMaterial:Material =  textureMat;
			sk.setMaterialToAllSurfaces(injectMaterial);
			
			
	
		
			arenaSpawner.setupSkin(sk,raceName );
			sk.geometry.upload(context3D);
			

		
		}
		
		
	
		
		
		private function findSkin(objects:Vector.<Object3D>):Skin {
			for each(var obj:Object3D in objects) {
				if (obj is Skin) return obj as Skin;
			}
			throw new Error("Could not find skin:");
			return null;
		}
		

		
		private function setupAnimStuff():void 
		{
			// Setup animations for alternativa3d
			GladiatorStance.ANIM_GROUPS = getAnimHash( XML( new GladiatorialAnims.ANIM_INFO() ) );
			
			var anim:AnimationManager = new AnimationManager();
			var bytes:ByteArray = new GladiatorialAnims.$_ANIMATIONS();
			bytes.uncompress();
			anim.readExternal( bytes); 
			
			GladiatorStance.ANIM_MANAGER = anim;
			
			removeAnimationTrack(anim, "run", "Bip01");
		}
		
		private function removeAnimationTrack(animManager:AnimationManager, animName:String, boneName:String):void 
		{
			var anim:AnimationClip = animManager.getAnimationByName(animName);
			
			var len:int = anim.numTracks;
			for (var i:int = 0; i < len ; i++) {
				var t:Track = anim.getTrackAt(i);
				if (t.object === boneName) {
					anim.removeTrack(t);
					
					return;
				}
			}
			
		}
		
		
		private function getAnimHash(xml:XML):Object {
			var obj:Object = { };
			var list:XMLList = xml..anims;
			
			for each(var animListNode:XML in list) {
				var suffix:String = animListNode.@suffix;
				var arr:Array = [];
				obj[suffix] = arr;
				var aList:XMLList = animListNode.a;
				for each( var a:XML in aList) {
					arr.push( String( a.@id ) );
				}
			}
			return obj;
		}

		
	}

}