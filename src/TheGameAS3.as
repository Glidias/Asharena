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
	import alternativa.engine3d.objects.Skin;
	import alternativa.engine3d.RenderingSystem;
	import alternativa.engine3d.resources.ExternalTextureResource;
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
		private var _view:Alternativa3DView = new Alternativa3DView();
		
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
	
			arenaSpawner.context3D = _view.stage3D.context3D;
			setupSkins();
			
			(e.currentTarget as IEventDispatcher).removeEventListener(e.type, onViewInitialized);
			startGame();
		}
	
		
		private function startGame():void {
			
			var geom:Geometry = new Geometry();

			//geom.setVertices( _view.box.geometry.getAttributeValues(VertexAttributes.POSITION) );
			//geom.addTriFaces(_view.box.geometry.indices);
			
			if (colliderSystem) {
				geom.setVertices(  _view.box.geometry.getAttributeValues(VertexAttributes.POSITION)  );
				//geom.indices = _view.box.geometry.indices;
				geom.addTriFaces(_view.box.geometry.indices);
				colliderSystem.collidable = geom;
			}
			
			
			// Setup rendering system
			engine.addSystem( new RenderingSystem(_view.scene), SystemPriorities.render );
			
			
		//	arenaSpawner.addCrossStage();
			arenaSpawner.addGladiator(ArenaSpawner.RACE_SAMNIAN, stage).add(keyPoll); //.get(Pos) as Pos
			
			
			ticker.start();	
		}

		
		override public function getSpawner():Spawner {
			
			return (arenaSpawner=new ArenaSpawner(engine));
		}
		
		
		
		// -- LOGISITICS
		
		private var _textureLoader:TexturesLoader;
		
		private function setupSkins():void 
		{
			_textureLoader = new TexturesLoader(_view.stage3D.context3D);
			
			var parserA3D:ParserA3D = new ParserA3D();
			parserA3D.parse( new A3D_SKIN() );
			
			//loadMaterials(  );
			
			var diffuseRes:ExternalTextureResource = parserA3D.materials[0].textures.diffuse;
			diffuseRes.url = skinTexturePath + diffuseRes.url;
			_textureLoader.loadResource( diffuseRes);
			
			var sk:Skin = findSkin( parserA3D.objects );
			
			arenaSpawner.setupSkin(sk  , ArenaSpawner.RACE_SAMNIAN );
			
			
			//ParserMaterial().
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
