package alternativa.engine3d.materials 
{
	import alternativa.engine3d.alternativa3d;
	import alternativa.engine3d.core.Camera3D;
	import alternativa.engine3d.core.Light3D;
	import alternativa.engine3d.core.Renderer;
	import alternativa.engine3d.objects.Surface;
	import alternativa.engine3d.resources.Geometry;
	use namespace alternativa3d;
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class FillHudMaterial extends FillMaterial
	{
		public var objectRenderPriority:int;
		
		public function FillHudMaterial(color:uint, alpha:Number=1) 
		{
			objectRenderPriority = Renderer.NEXT_LAYER;
			super(color, alpha);
		}
		
		override alternativa3d function collectDraws (camera:Camera3D, surface:Surface, geometry:Geometry, lights:Vector.<Light3D>, lightsLength:int, useShadow:Boolean, objectRenderPriority:int = -1) : void {
			
			super.collectDraws(camera, surface, geometry, lights, lightsLength, useShadow, this.objectRenderPriority);
		}
		
		public static function fromFillMaterial(mat:FillMaterial):FillHudMaterial {
			var me:FillHudMaterial = new FillHudMaterial(mat.color, mat.alpha);
			//me.clonePropertiesFrom(mat);
			return me;
		}
		
		
	}

}