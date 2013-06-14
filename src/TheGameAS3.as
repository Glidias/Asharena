package  
{
	import alternativa.engine3d.animation.AnimationClip;
	import alternativa.engine3d.animation.keys.Track;
	import alternativa.engine3d.animation.keys.TransformTrack;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.VertexAttributes;
	import alternativa.engine3d.loaders.ParserA3D;
	import alternativa.engine3d.loaders.ParserMaterial;
	import alternativa.engine3d.loaders.TexturesLoader;
	import alternativa.engine3d.materials.Material;
	import alternativa.engine3d.materials.TextureMaterial;
	import alternativa.engine3d.materials.TextureZClipMaterial;
	import alternativa.engine3d.objects.Skin;
	import alternativa.engine3d.objects.Surface;
	import alternativa.engine3d.RenderingSystem;
	import alternativa.engine3d.resources.ExternalTextureResource;
	import alternativa.engine3d.resources.TextureResource;
	import alternterrain.CollidableImpl;
	import ash.core.Entity;
	import components.Rot;
	import examples.WaterAndTerrain3rdPerson;
	import util.geom.Geometry;

	import components.Pos;
	import flash.Boot;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.net.registerClassAlias;
	import flash.utils.ByteArray;
	import systems.player.a3d.AnimationManager;
	import systems.player.a3d.GladiatorStance;
	import systems.rendering.RenderNode;
	import systems.SystemPriorities;
	import views.Alternativa3DView;

	/**
	 * This is running under AS3 using alternativa3d engine.
	 * @author Glenn Ko
	 */
	public class TheGameAS3 extends TheGame
	{
		
		// -- logisitics
		[Embed(source="../bin/skins/anim-gladiator.xml", mimeType="application/octet-stream")]
		public var ANIM_INFO:Class;
		
		[Embed(source="../bin/skins/animations.ani", mimeType="application/octet-stream")]
		public var ANIMS:Class;
		
		[Embed(source="../bin/skins/samnite_skinned.a3d", mimeType="application/octet-stream")]
		public var A3D_SKIN:Class;
		
		private var skinTexturePath:String = "skins/textures/";
	
		private var arenaSpawner:ArenaSpawner;	
		private var _view:WaterAndTerrain3rdPerson = new WaterAndTerrain3rdPerson();
		
		public function TheGameAS3(stage:Stage) 
		{
			super(stage);
			
			registerClassAlias("String", String);
						
			setupAnimStuff();
			
			stage.addChild(_view);
			
			_view.addEventListener(Event.COMPLETE, onViewInitialized);
			
					
			Boot.getTrace().blendMode = "invert";
			stage.addChild( Boot.getTrace() );
		}
		
		private function onViewInitialized(e:Event):void 
		{
			engine.addSystem( new RenderingSystem(_view.scene, _view), SystemPriorities.render );
			
			(e.currentTarget as IEventDispatcher).removeEventListener(e.type, onViewInitialized);
			
			arenaSpawner.context3D = _view.stage3D.context3D;	
			var injectMaterial:TextureZClipMaterial = setupSkins();
			arenaSpawner.addGladiator(ArenaSpawner.RACE_SAMNIAN, stage).add(keyPoll);
			_view.inject(arenaSpawner.currentPlayer, arenaSpawner.currentPlayer, arenaSpawner.currentPlayerEntity.get(Pos) as Pos,  arenaSpawner.currentPlayerEntity.get(Rot) as Rot, arenaSpawner.currentPlayerSkin, injectMaterial);
			startGame();
		}
	
		
		private function startGame():void {
					
			if (colliderSystem) {
				/*
				var geom:Geometry = new Geometry();
				geom.setVertices(  _view.box.geometry.getAttributeValues(VertexAttributes.POSITION)  );
				geom.setIndices(_view.box.geometry.indices);
				colliderSystem.collidable = geom;
				*/		
				colliderSystem._collider.threshold = 0.0001;
				colliderSystem.collidable = new CollidableImpl(_view.terrainLOD, _view.getWaterPlane());
			}
				
			// Setup rendering system
			ticker.start();	
		}

		
		override public function getSpawner():Spawner {	
			return (arenaSpawner=new ArenaSpawner(engine));
		}
		
		
		// -- LOGISITICS
		
		private var _textureLoader:TexturesLoader;
		
	//	/*
		private function setupSkins():TextureZClipMaterial 
		{
			
			
			var parserA3D:ParserA3D = new ParserA3D();
			parserA3D.parse( new A3D_SKIN() );
			
			//loadMaterials(  );
			
			//var diffuseRes:ExternalTextureResource = parserA3D.materials[0].textures.diffuse;
			//diffuseRes.url = skinTexturePath + diffuseRes.url;
			//_textureLoader.loadResource( diffuseRes);
			
			var sk:Skin = findSkin( parserA3D.objects );
			
			
			var textures:Vector.<ExternalTextureResource> = new Vector.<ExternalTextureResource>(); //create a vector ExternalTextureResource
			var injectMaterial:TextureZClipMaterial;
			for (var i:int = 0; i < sk.numSurfaces; i++){ //cycle through all surface
				var surface:Surface = sk.getSurface(i); //get the current surface
				var material:ParserMaterial = surface.material as ParserMaterial; //a material property, we obtain ParserMaterial (for materials in Section 1.3)
				if (material != null) { //if the material is there, not null
					
					var diffuse:ExternalTextureResource = material.textures["diffuse"]; //Create TextureResource-is the base class for all texture resources
					if (diffuse != null){ //if there is texture
						textures.push(diffuse); //add a vector with ExternalTextureResource
						diffuse.url = skinTexturePath + diffuse.url;
						surface.material = injectMaterial = new TextureZClipMaterial(diffuse); //and assign the surface
						
					}
				}
			}
			var texturesLoader:TexturesLoader = new TexturesLoader(_view.stage3D.context3D);
			_textureLoader = texturesLoader;
			texturesLoader.loadResources(textures); //load the textures in the context
			
		
			arenaSpawner.setupSkin(sk, ArenaSpawner.RACE_SAMNIAN );
			
			
		
			return injectMaterial;
			//ParserMaterial().
		}
		//*/
		
	
		
		
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
			GladiatorStance.ANIM_GROUPS = getAnimHash( XML( new ANIM_INFO() ) );
			
			var anim:AnimationManager = new AnimationManager();
			var bytes:ByteArray = new ANIMS();
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
