package spawners 
{
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.Resource;
	import alternativa.engine3d.loaders.ParserA3D;
	import alternativa.engine3d.materials.Material;
	import alternativa.engine3d.materials.TextureMaterial;
	import alternativa.engine3d.objects.Mesh;
	import alternativa.engine3d.objects.Skin;
	import alternativa.engine3d.resources.BitmapTextureResource;
	import alternativa.engine3d.resources.ExternalTextureResource;
	import alternativa.engine3d.utils.MaterialProcessor;
	import flash.display.BitmapData;
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	import systems.player.a3d.AnimationManager;
	import util.SpawnerBundle;
	/**
	 * Basic utility bundle package to load in a 3d model class and any other assosiated assets with it (include sub 3d-models support for both internal classes and _suffix)
	 * @author Glenn Ko
	 */
	public class ModelBundle extends SpawnerBundle
	{
		private var rootClasse:Class;
		private var moreSubClasses:Array;
		
		public var root:ModelPacket;
		public var subModels:Object;
		
		
		/**
		 * Constructor
		 * @param	classe	The main root class to reference assets with the main root model packet
		 * @param	moreSubClasses	Any additional classes to be registered as a submodel packet
		 * @param	simpleTexture	Optional flag to enforce simple TextureMaterial/LightmapMaterial only
		 */
		public function ModelBundle(classe:Class, moreSubClasses:Array=null, simpleTexture:Boolean=false) 
		{
			this.simpleTexture = simpleTexture;
			this.moreSubClasses = moreSubClasses;
			this.rootClasse = classe;
			ASSETS =moreSubClasses == null ?  [classe] : [classe].concat(moreSubClasses);
			
			super();

		}
		
		public function getSubModelPacket(id:String):ModelPacket {
			if (subModels == null) throw new Error("No sub models available!")
			var me:ModelPacket = subModels[id];
			if (id == null) throw new Error("Couldn't find sub model packet:" + id);
			return me;
		}
		
		private function processClasse(parser:ParserA3D, classe:Object, subName:String=null):ModelPacket 
		{
			var rootModelPacket:ModelPacket;
			var modelPacket:ModelPacket  = rootModelPacket= new ModelPacket();
			var mesh:Object3D;
			var type:String;
			var n:XML;
			var ider:String;
			var nameSpl:Array;
			var namer:String;
			var xml:XML;
			if ((classe as Class) == null) throw new Error("invalid class:" + classe);
			xml = describeType(classe);
				var variables : XMLList = xml.variable;
				var methods : XMLList = xml.method;
				//throw new Error(classe);
				for each(n in variables) { 
					
					namer = n.@name;
					nameSpl = namer.split("_");
					type = nameSpl[0];
					if (namer === "$_MODEL" || type === "MODEL" ) {
						ider = nameSpl[nameSpl.length - 1];
						
						if (namer != "$_MODEL") {
							if (subModels == null) subModels = { };
							subModels[nameSpl[1]] = modelPacket = new ModelPacket();
						}
						else modelPacket = rootModelPacket;
						
						parser.parse(new (classe[namer])());
						mesh = parser.objects[1] as Mesh || parser.objects[0] as Mesh || parser.hierarchy[0];  // todo: this is rather hackish. Use a proper search instead
						modelPacket.hierarchy  = parser.hierarchy;
						modelPacket.root =parser.hierarchy != null &&  parser.hierarchy.length != 0 ? parser.hierarchy[0] : mesh;
						
						//throw new Error(mesh.geometry.numTriangles
					
						//modelHash[ider] = mesh;
						modelPacket.model = mesh;
						
						if (parser.animations != null && parser.animations.length != 0) {
							modelPacket.animClip = parser.animations[0];
							modelPacket.animationClips = parser.animations;
						}

					}
				}
				
		
				for each(n in variables) { 
					namer = n.@name;
					nameSpl = namer.split("_");
					type = nameSpl[0];
					if (namer === "$_TEXTURE" || type === "TEXTURE") {
						ider = nameSpl[nameSpl.length - 1];
						modelPacket = namer != "$_TEXTURE" ? subModels[nameSpl[1]]  : rootModelPacket;
	
						var data:BitmapData = new (classe[namer])().bitmapData;
						modelPacket.texture = data;
					}
					else if (namer === "$_ANIMATIONS" || type === "ANIMATIONS") {  // TODO: setup animation manager reference
						
					}
					
				}
				
				// assumption made that if root level has no bounding box, skin (assumed animated), should NOT have a bounding box
				// Root will ALWAYS have a calculated bounding box in relation to it's childrens' bounding boxes.
					if (rootModelPacket.model is Skin && rootModelPacket.root.boundBox == null) {
						rootModelPacket.model.boundBox = null;
					}
				
				
			//	if (rootModelPacket.model != null) throw new Error("Found model:" + rootModelPacket.model);
				//if (rootModelPacket.model == null && modelPacket.texture == null) throw new Error("Model packet is empty: "+subName);
				
				
				if (subName != null) {
					if (subModels == null) subModels = { };
					subModels[subName] = rootModelPacket;
					return rootModelPacket;
				}
				
	
				var getSubClasses:XMLList = xml.method.(@name == "$getSubClasses");
				if (getSubClasses.length()) {
					var subClassList:Array = rootClasse["$getSubClasses"]();
					var i:int = subClassList.length;
					while (--i > -1 ) {
						processClasse(parser, subClassList[i], getShortStringForClass(subClassList[i]));
					}
				}
				
			
				
				
				return rootModelPacket;
		}
		
		private function getShortStringForClass(object:Object):String 
		{
				var str:String = object.toString();
						str = str.slice(7, str.length - 1);
						return str;
		}
		
		private var simpleTexture:Boolean;
		private static var MATERIAL_PROCESSOR:MaterialProcessor;
		public static var AUTO_UPLOAD:Boolean = true;
		
		override protected function init():void {
			if (MATERIAL_PROCESSOR == null) {
				MATERIAL_PROCESSOR = new MaterialProcessor(context3D);
			}
			
			var collectedObjects:Vector.<Object3D> = new Vector.<Object3D>();
			var collectedPackets:Vector.<ModelPacket> = new Vector.<ModelPacket>();
			var collectedObjCount:int = 0;
			
			var modelPacket:ModelPacket;
			var parser:ParserA3D = new ParserA3D();

			root = processClasse(parser, rootClasse);

			if (root != null && root.model != null) {
				collectedObjects[collectedObjCount] = root.model;
				collectedPackets[collectedObjCount] = root;
				collectedObjCount++;
			}
			
			var i:int;
			var len:int;
			
			
			//if (subModels == null) subModels = { };
			
			
			// process additioannl submodels if needed
			if (moreSubClasses != null) {
		
				len = moreSubClasses.length;
				for (i = 0; i < len; i++) {
					
					processClasse(parser, moreSubClasses[i], getShortStringForClass(moreSubClasses[i]) );
				}
			}
			
			
			// collect all subModels
			if (subModels != null) {
				for (var p:String in subModels) {
					modelPacket = subModels[p];
					if (modelPacket.model != null) {
						collectedObjects[collectedObjCount] = modelPacket.model;
						collectedPackets[collectedObjCount] = modelPacket;
						collectedObjCount++;
					}
				}
			}
			
			
			MATERIAL_PROCESSOR.setupMaterials(collectedObjects, simpleTexture);
			
			for (i = 0; i < collectedObjCount; i++) {
				var scene:Object3D = collectedObjects[i];
				
				var resources:Vector.<Resource> =  scene.getResources(true, ExternalTextureResource);
				
				modelPacket = collectedPackets[i];
			
				if (modelPacket.texture != null) {
						
					for each (var textureResource:ExternalTextureResource in resources) {
						// todo: support atf texture case, and multiple textures mapping for ModelPacket
						MATERIAL_PROCESSOR.setupExternalTexture(textureResource, modelPacket.texture, false);
						//	throw new Error("A");
						//MATERIAL_PROCESSOR.setupExternalTexture(textureResource, textureURLMap[textureName], false);
					}
				}
			}

			
			if (AUTO_UPLOAD) uploadAll();
			
			
			super.init();
			
			// based off class, assign model, material, animManager 
			
			// if got root modelPacket
			
			// if got subModels....do so for each
		}
		
		
		public function uploadAll():void {
			if (root != null && root.model!=null) {
				uploadResources( root.model.getResources(true, null) ); 
	
			}
			if (subModels != null) {
				for (var id:String in subModels) {
					var modelPacket:ModelPacket = (subModels[id] as ModelPacket);

					if (modelPacket.model) {
						uploadResources(modelPacket.model.getResources(true, null) );
					}
					
					
				}
			}
		}
		
		
		
	}

}
