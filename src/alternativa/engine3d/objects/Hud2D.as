package alternativa.engine3d.objects 
{
	import alternativa.engine3d.alternativa3d;
	import alternativa.engine3d.core.Camera3D;
	import alternativa.engine3d.core.Light3D;
	import alternativa.engine3d.core.Object3D;
	use namespace alternativa3d;
	/**
	 * Heads up display Object3D gateway container for orthographic 2d projection. Only add this as a child of the current camera you're using!
	 * Than, add all your 2D hud elements into this Hud2D container!
	 * 
	 * 
	 * @author Glenn Ko
	 */
	public class Hud2D extends Object3D
	{
		
		// ortho camera emulation (doesn't seem to work..)
		private static var ORTHO_CAM:Camera3D;
		private var orthoCamera:Camera3D;  // backup orthographic camera
		private var lastWidth:int = 0;
		private var lastHeight:int = 0;
		private var nearClipping:Number;
		private var farClipping:Number;
		private var fov:Number;
		
		
		public function Hud2D() 
		{
			if (ORTHO_CAM == null)  {  
				ORTHO_CAM = new Camera3D(1,999999);
				ORTHO_CAM.composeTransforms();
				ORTHO_CAM.localToGlobalTransform.copy(ORTHO_CAM.transform);
				ORTHO_CAM.globalToLocalTransform.copy(ORTHO_CAM.inverseTransform);
				ORTHO_CAM.cameraToLocalTransform.combine(ORTHO_CAM.inverseTransform, ORTHO_CAM.localToGlobalTransform);
				ORTHO_CAM.orthographic = true;
			}
			orthoCamera = ORTHO_CAM;
			
			
		
		}
		override alternativa3d function get useLights():Boolean {
			return false;
		}
		
		
		override alternativa3d function calculateChildrenVisibility(camera:Camera3D):void {
			
		///*
			if (!camera.orthographic) {
				if (lastWidth != camera.view._width || lastHeight != camera.view._height || nearClipping != camera.nearClipping || farClipping != camera.farClipping || fov != camera.fov) {
					lastWidth = camera.view._width;
					lastHeight = camera.view._height;
					nearClipping = camera.nearClipping;
					farClipping = camera.farClipping;
					fov = camera.fov;
					orthoCamera.fov = fov;
					orthoCamera.nearClipping = nearClipping;
					orthoCamera.farClipping = farClipping;
					orthoCamera.calculateProjection(lastWidth, lastHeight);
					orthoCamera.renderer = camera.renderer;
					orthoCamera.view = camera.view;
					orthoCamera.calculateFrustum(cameraToLocalTransform);
				}
	
				orthoCamera.context3D = camera.context3D;
				orthoCamera.view = camera.view;
				camera = orthoCamera;
			}
			
		
			//*/
		
			super.calculateChildrenVisibility(camera);
		}
		
	
		override alternativa3d function collectChildrenDraws(camera:Camera3D, lights:Vector.<Light3D>, lightsLength:int, useShadow:Boolean):void {
			
			if (!camera.orthographic) camera = orthoCamera;
			super.collectChildrenDraws(camera,lights,lightsLength,useShadow);
		}
	
		
	}

}