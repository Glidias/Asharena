package spawners 
{
	/**
	 * Model packet class to hold references to 3d model, 3d objects, and other assets from .a3d and external asset files per model
	 * @author Glenn Ko
	 */
	import alternativa.engine3d.animation.AnimationClip;
	import alternativa.engine3d.animation.AnimationController;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.materials.Material;
	import alternativa.engine3d.objects.Mesh;
	import alternativa.engine3d.objects.Skin;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import systems.player.a3d.AnimationManager;
	import alternativa.engine3d.alternativa3d;
	use namespace alternativa3d;


	public class ModelPacket {
		// a valid model packet needs either 1 of these
		public var model:Object3D;    // $_MODEL		.a3d file (any model within, prefably the Mesh or Skin)
		public var texture:BitmapData;  // $_TEXTURE		any .png/jpg file resource to apply directly onto entire model
		public var hierarchy:Vector.<Object3D>;  // .a3d the hierachy Object3D reference
		public var root:Object3D; // assumed first object3D in hierachy by default
		
		public var animManager:AnimationManager;  // $_ANIMATIONS  parsed .ani file to produce animation manager for handling multiple animation clips
		public var animClip:AnimationClip;  // .a3d file (first animation clip in animationClips)...assumed only meant to handle 1 single animation clip (or you must slice 'em up manually on your own)
		public var animationClips:Vector.<AnimationClip>;  // .a3d all animationClips reference
		
	//	public static const INDEX_MODEL:int = 0;
		//public static const INDEX_ANIM:int = 1;
		
		public function ModelPacket() {
			
		}
		
		public function getRootTransform():Object3D {
			var rootC:Object3D = new Object3D();
			rootC.matrix = root.matrix;// = root
			return rootC;
		}
		
		public function getMaterial():Material {
			var ref:Mesh = model as Mesh;
			return ref.getSurface(0).material;
		}
		
		public function get3DStaticRoot():Object3D {
			var ref:Object3D =  root;
			if (ref == null) throw new Error("Model scene root is null");
			//throw new Error(ref);
			return ref.clone();
		}
		
		public function get3DStaticModel():Object3D {
			var ref:Object3D =  model;
			if (ref == null) throw new Error("Model is null");
			return ref.clone();
		}
		
	
		// temp convenience method, will depreciate and move elsewhere
		public static function scale(obj:Object3D, scale:Number):Object3D {
			obj._scaleX = scale;
			obj._scaleY = scale;
			obj._scaleZ = scale;
			obj.transformChanged = true;
			return obj;
		}
		public static function scaleBy(obj:Object3D, scale:Number):Object3D {
			obj._scaleX *= scale;
			obj._scaleY *= scale;
			obj._scaleZ *= scale;
			obj.transformChanged = true;
			return obj;
		}
		
		public function get3DStaticSkin():Skin {
			var ref:Skin =  model as Skin;
			if (ref == null) throw new Error( "Skin not found for model:" + ref);
			//throw new Error(ref);
			return ref.clone() as Skin;
		}
		
		public function get3DAnimatedSkinRoot(optionalAnimatable:Boolean=false):Array {
			var root:Object3D = get3DStaticRoot();
			var anim:* = setupAnimFor(root, optionalAnimatable);
			return anim ? [root, anim] : [root];
		}
		
		public function get3DAnimatedModelRoot(optionalAnimatable:Boolean=false):Array {
			var root:Object3D = get3DStaticRoot();
			var anim:* = setupAnimFor(root, optionalAnimatable);
			return anim ? [root, anim ] : [root];
		}
		
		public function get3DAnimatedSkin(optionalAnimatable:Boolean=false):Array {
			var ref:Skin = get3DStaticSkin();
			var anim:* = setupAnimFor(ref, optionalAnimatable);
			return anim ? [ref, anim] : [ref];
		}
		
		public function get3DAnimatedModel(optionalAnimatable:Boolean=false):Array {
			var ref:Object3D = get3DStaticModel();
			var anim:* = setupAnimFor(ref, optionalAnimatable);
			return anim ? [ref, anim ] : [ref];
		}
		
		
		
		public function setupAnimFor(ref:Object3D, optionalAnimatable:Boolean=false):* 
		{
			var animOutput:* = null;
			
			if (animManager != null) {
				animOutput = animManager.cloneFor(ref);
			}
			else if (animClip != null) {
				var cClip:AnimationClip;
				cClip = animClip.clone(); 
				cClip.time =  animClip.time;  // clone doesn't match time/speed, will perform this.
				cClip.speed = animClip.speed;
				cClip.attach(ref, true);
				var controller:AnimationController = new AnimationController();
				controller.root = cClip;
				animOutput = controller;
			}
			else if (!optionalAnimatable) {
				throw new Error("Didn't find animation dependencies for:" + model);
			}
			return  animOutput;
		}
		
		
		
	}

}