package alternativa.a3d.systems.animation 
{
	import alternativa.engine3d.animation.AnimationClip;
	import alternativa.engine3d.animation.AnimationController;
	import haxe.Log;
	import systems.animation.IAnimatable;
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class AnimControllerComponent implements IAnimatable
	{
		public var controller:AnimationController;
		
		public function AnimControllerComponent(controller:AnimationController) 
		{
			this.controller = controller;
			
		}
		
		/* INTERFACE systems.animation.IAnimatable */
		
		public function animate(time:Number):void 
		{
			//throw new Error("A");
			//Log.trace("A:"+(controller.root as AnimationClip).objects);
			controller.update(time);
		}
		
	}

}