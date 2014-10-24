package alternativa.engine3d.utils 
{
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.alternativa3d;
	use namespace alternativa3d;
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class A3DUtils 
	{
		public static function findDescendantObjByNameRecursive(obj:Object3D, name:String):Object3D {
			if (obj.name === name) return obj;
			for (var c:Object3D = obj.childrenList; c != null; c = c.next) {
				
				var result:Object3D = findDescendantObjByNameRecursive(c, name);

				if (result != null) return result;
			}
			
			return null;
		}
	}

}