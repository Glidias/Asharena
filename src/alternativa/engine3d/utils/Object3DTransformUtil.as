package alternativa.engine3d.utils 
{
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.Transform3D;
	import alternativa.engine3d.alternativa3d;
	use namespace alternativa3d;
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class Object3DTransformUtil 
	{
		
		public function Object3DTransformUtil() 
		{
			
		}
		
		public static function calculateLocalToGlobal(obj:Object3D):Transform3D {
			if (obj.transformChanged) obj.composeTransforms();
			var trm:Transform3D = obj.localToGlobalTransform;
			
			trm.copy(obj.transform);
			var root:Object3D = obj;
			while (root.parent != null) {
				root = root.parent;
				if (root.transformChanged) root.composeTransforms();
				trm.append(root.transform);
			}
			
			return trm;
			
		}
		
		public static function calculateLocalToGlobal2(obj:Object3D, trm:Transform3D=null):Transform3D {
			if (obj.transformChanged) obj.composeTransforms();
			trm = trm || new Transform3D();
			
			trm.copy(obj.transform);
			var root:Object3D = obj;
			while (root.parent != null) {
				root = root.parent;
				if (root.transformChanged) root.composeTransforms();
				trm.append(root.transform);
			}
			
			return trm;
			
		}
		
		public static function calculateGlobalToLocal2(obj:Object3D, trm:Transform3D=null):Transform3D {
			if (obj.transformChanged) obj.composeTransforms();
			trm = trm || new Transform3D();
			
			trm.copy(obj.inverseTransform);
			var root:Object3D = obj;
			while (root.parent != null) {
				root = root.parent;
				if (root.transformChanged) root.composeTransforms();
				trm.prepend(root.inverseTransform);
			}
			return trm;
		}
		
		
	}

}