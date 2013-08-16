package alternativa.a3d.collisions 
{
	import alternativa.engine3d.core.BoundBox;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.VertexAttributes;
	import alternativa.engine3d.objects.Mesh;
	import alternativa.engine3d.utils.Object3DUtils;
	import flash.utils.Dictionary;
	import util.geom.Geometry;
	import alternativa.engine3d.alternativa3d;
	use namespace alternativa3d;
	
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class CollisionUtil 
	{
		
		public function CollisionUtil() 
		{
			
		}
		
		public static function calculateCollisionGraph(scene:Object3D):CollisionBoundNode {
			 Object3DUtils.calculateHierarchyBoundBox(scene, null, (scene.boundBox || (scene.boundBox = new BoundBox())) );
			return getCollisionGraph(scene);
		}
		
		
		public static function getCollisionGraph(scene:Object3D):CollisionBoundNode {
			
			var rootNode:CollisionBoundNode = new CollisionBoundNode();
			var classe:Class = Object(scene).constructor;
			rootNode.setup(scene, FUNC_MAP[classe] ? FUNC_MAP[classe](scene) : scene is Mesh ? FUNC_MAP[Mesh](scene) : null);
			if ( scene.childrenList != null) rootNode.setupChildren(scene, FUNC_MAP);
			rootNode.validate(scene);
			return rootNode;
			
		}
		
		
		private static var FUNC_MAP:Dictionary = getNewFuncMap();
		private static function getNewFuncMap():Dictionary {
			var dict:Dictionary = new Dictionary();
			
			dict[Mesh] = getGeometryFromMesh;
			
			return dict;
		}
		
		public static function registerConversionFunc(classe:Class, method:Function):void {
			FUNC_MAP[classe] = method;
		}
		
		private static var GEOMETRY_CACHE:Dictionary = new Dictionary();
		public static function flushGeometryCache():void {
			GEOMETRY_CACHE = new Dictionary();
		}
		
		
		public static function getGeometryFromMesh(mesh:Mesh):Geometry {
			if (GEOMETRY_CACHE[mesh.geometry] != null) return GEOMETRY_CACHE[mesh.geometry];
			var geometry:Geometry = new Geometry();
			geometry.setVertices(mesh.geometry.getAttributeValues(VertexAttributes.POSITION));
			geometry.setIndices(mesh.geometry._indices);
			GEOMETRY_CACHE[mesh.geometry] = geometry;
			return geometry;
		}
		
	}

}