package alternativa.engine3d.objects 
{
	import alternativa.engine3d.core.Object3D;
	/**
	 * ...
	 * @author Glidias
	 */
	public class TestBoxDisplay extends Object3D
	{
		
		public function TestBoxDisplay() 
		{
			
		}
		
		override alternativa3d function collectChildrenDraws(camera:Camera3D, lights:Vector.<Light3D>, lightsLength:int, useShadow:Boolean):void {
			
			camera = Hud2D.ORIGINAL_CAMERA;
			super.collectChildrenDraws(camera, lights, lightsLength, useShadow);
		
		}
	}

}