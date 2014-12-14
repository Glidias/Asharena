package spawners.arena 
{
	import alternativa.engine3d.animation.AnimationClip;
	import alternativa.engine3d.animation.keys.Track;
	import alternativa.engine3d.animation.keys.TransformKey;
	import alternativa.engine3d.animation.keys.TransformTrack;
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
	import alternativa.engine3d.materials.VertexLightZClipMaterial;
	import alternativa.engine3d.objects.Skin;
	import alternativa.engine3d.objects.Surface;
	import alternativa.engine3d.resources.BitmapTextureResource;
	import ash.core.Engine;
	import flash.display.BitmapData;
	import flash.geom.ColorTransform;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	import systems.player.a3d.AnimationManager;
	import systems.player.a3d.GladiatorStance;
	import util.geom.PMath;
	import util.SpawnerBundle;
	import alternativa.engine3d.alternativa3d;
	use namespace alternativa3d;
	
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class GladiatorBundle extends SpawnerBundle
	{
		public var textureMat:VertexLightZClipMaterial;
		public var arenaSpawner:ArenaSpawner;
		
		
		public function GladiatorBundle(spawner:ArenaSpawner) 
		{
			ASSETS = [GladiatorialAnims, Samnian];
			
			this.arenaSpawner = spawner;
			
			super();
		}
		
		public function getSideTexture(side:int):BitmapTextureResource {
			var bmd:BitmapData = new Samnian.$_TEXTURE().bitmapData;

			//var invertTransform:ColorTransform = new ColorTransform(-1,-1,-1,1,255,255,255,0)
			//bmd.colorTransform(bmd.rect, invertTransform);
			bmd.draw(bmd, null, null, "invert");
			return new BitmapTextureResource(bmd);
			
			
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
			textureMat = new VertexLightZClipMaterial(diffuse);
			
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
			var xml:XML = XML( new GladiatorialAnims.ANIM_INFO() );
			GladiatorStance.ANIM_GROUPS = getAnimHash( xml );
			
			var anim:AnimationManager = new AnimationManager();
			var bytes:ByteArray = new GladiatorialAnims.$_ANIMATIONS();
			bytes.uncompress();
			anim.readExternal( bytes); 
			
			var rootTrack:TransformTrack = new TransformTrack("Bip01");
			var mat:Matrix3D = new Matrix3D();
			//mat.appendRotation( -.7 * Math.PI * PMath.RAD_DEG, new Vector3D(0,-1,0) );
			//mat.appendRotation( -.7 * Math.PI * PMath.RAD_DEG, new Vector3D(0,-1,0) );
			mat.rawData = new <Number>[-0.21651622653007507,-2.9080050012453285e-7,0.9762790203094482,0,0.9762790203094482,-1.9478005697237677e-7,0.21651622653007507,0,1.271966567628624e-7,1,3.260754510847619e-7,0,1.4892919063568115,0,-1.2974472045898438,1];
			
			
			mat.appendRotation( -.4 * PMath.RAD_DEG, Vector3D.Y_AXIS );
			rootTrack.addKey(0, mat);
			
			
			// -.7*Math.PI
			var aimRotList:XMLList = xml..a.(hasOwnProperty("@aimrot") && @aimrot=="true");
			var len:int = aimRotList.length();
			for (var i:int = 0; i < len; i++) {
				var aimAnim:XML = aimRotList[i];
				var aimId:String = aimAnim.@id;
				//removeAnimationTrack(anim, aimId, "Bip01");
				anim.getAnimationByName(aimId).addTrack( rootTrack);
			}
			

			
			var leftTrack:TransformTrack = new TransformTrack("Bip01");
			mat = new Matrix3D( new <Number>[4.214572513205894e-8,3.076312538041748e-10,1,0,1,-4.443769441309087e-8,-4.214572513205894e-8,0,4.443769441309087e-8,1,-3.0763314118331664e-10,0,-0.46240830421447754,-1.0343351364135742,-0.9343122839927673,1]);
			var rootCombatMat:Matrix3D = mat.clone();
			mat.appendRotation( -.0 * PMath.RAD_DEG, Vector3D.Y_AXIS);
			var leftKey:TransformKey = leftTrack.addKey( 0, mat);
			
			var rightTrack:TransformTrack = new TransformTrack("Bip01");
			mat = rootCombatMat.clone();
			mat.appendRotation( .0* PMath.RAD_DEG, Vector3D.Y_AXIS);
			var rightKey:TransformKey = rightTrack.addKey( 0, mat);
				
				
			//anim.getAnimationByName("combat_moveleft").addTrack( rootTrack);
			//anim.getAnimationByName("combat_moveright").addTrack( rootTrack);
			rootTrack = getAnimationTrack(anim, "combat_moveright", "Bip01") as TransformTrack;
			var k:TransformKey
			for (k = rootTrack.keyFramesList as TransformKey; k != null; k = k.next as TransformKey) {
			
			 k.rotation =  rightKey.rotation;// new  Vector3D( -0.6300261541953068, -0.3210402586680686, -0.3210403625445252 
			}
			
			rootTrack = getAnimationTrack(anim, "combat_moveleft", "Bip01") as TransformTrack;
			for (k = rootTrack.keyFramesList as TransformKey; k != null; k = k.next as TransformKey) {
			
			 k.rotation =  leftKey.rotation;// new  Vector3D( -0.6300261541953068, -0.3210402586680686, -0.3210403625445252 
			}
			//throw new Error(rootTrack.keys.length);
			
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
		
		private function getAnimationTrack(animManager:AnimationManager, animName:String, boneName:String):Track 
		{
			var anim:AnimationClip = animManager.getAnimationByName(animName);
			
			var len:int = anim.numTracks;
			for (var i:int = 0; i < len ; i++) {
				var t:Track = anim.getTrackAt(i);
				if (t.object === boneName) {
					return t;
					
					
				}
			}
			return null;
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