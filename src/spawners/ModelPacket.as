package spawners 
{
	/**
	 * ...
	 * @author Glenn Ko
	 */
	import alternativa.engine3d.animation.AnimationClip;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.materials.Material;
	import systems.player.a3d.AnimationManager;


	public class ModelPacket {
		// a valid model packet needs either 1 of these
		public var model:Object3D;    // $_MODEL		.a3d file (any model within)
		public var material:Material;  // $_TEXTURE		any .png/jpg file resource to apply directly onto entire model
		public var animManager:AnimationManager;  // $_ANIMATIONS  parsed .ani file to produce animation manager for handling multiple animation clips
		public var animClip:AnimationClip;  // .a3d file (any single animation clip within)...assumed only meant to handle 1 single animation clip (or you must slice 'em up manually on your own)
		
		public function ModelPacket() {
			
		}
	}

}