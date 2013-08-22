package alternativa.engine3d.spriteset.materials 
{
	import alternativa.engine3d.materials.compiler.Procedure;
	import flash.geom.Vector3D;
	
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public interface IAtlasVertexMaterial 
	{
		
		function getAtlasTransformProcedure(maxSprites:int, NUM_REGISTERS_PER_SPR:int, viewAligned:Boolean = true, axis:Vector3D = null):Procedure;
	}
	
}