package spawners 
{
	/**
	 * Model packet class to retrieve out models
	 * @author Glenn Ko
	 */
	import alternativa.engine3d.animation.AnimationClip;
	import alternativa.engine3d.animation.AnimationController;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.materials.Material;
	import alternativa.engine3d.objects.Skin;
	import systems.player.a3d.AnimationManager;


	public class ModelPacket {
		// a valid model packet needs either 1 of these
		public var model:Object3D;    // $_MODEL		.a3d file (any model within)
		public var material:Material;  // $_TEXTURE		any .png/jpg file resource to apply directly onto entire model
		public var animManager:AnimationManager;  // $_ANIMATIONS  parsed .ani file to produce animation manager for handling multiple animation clips
		public var animClip:AnimationClip;  // .a3d file (any single animation clip within)...assumed only meant to handle 1 single animation clip (or you must slice 'em up manually on your own)
		
		public var animOutput:*;  // this could either be AnimationManager of AnimationController of a single animationclip
		
		public function ModelPacket() {
			
		}
		
		public function get3DStaticModel():Object3D {
			var ref:Object3D =  model;
			if (ref == null) throw new Error("Model is null");
			return ref.clone();
		}
		public function get3DStaticSkin():Skin {
			var ref:Skin =  model as Skin;
			if (ref == null) throw new Error( "Skin not found for model:" + ref);
			
			return ref.clone() as Skin;
		}
		
		public function get3DAnimatedSkin(optionalAnimatable:Boolean=false):Skin {
			var ref:Skin = get3DStaticSkin();
			setupAnimFor(ref, optionalAnimatable);
			return ref;
		}
		
		public function get3DAnimatedModel(optionalAnimatable:Boolean=false):Object3D {
			var ref:Object3D = get3DStaticModel();
			setupAnimFor(ref, optionalAnimatable);
			return ref;
		}
		
		private function setupAnimFor(ref:Object3D, optionalAnimatable:Boolean):void 
		{
			if (animManager != null) {
				animOutput = animManager.cloneFor(ref);
			}
			else if (animClip != null) {
				var cClip:AnimationClip;
				cClip = animClip.clone();
				cClip.attach(ref, true);
				var controller:AnimationController = new AnimationController();
				controller.root = cClip;
				animOutput = controller;
			}
			else if (!optionalAnimatable) {
				throw new Error("Didn't find animation dependencies for:" + model);
			}
		}
		
		
		
	}

}