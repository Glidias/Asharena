package alternativa.engine3d 
{
	import alternativa.engine3d.core.Object3D;
	import systems.rendering.IRenderable;
	import systems.rendering.RenderNode;
	import systems.rendering.RenderSystem;
	import alternativa.engine3d.alternativa3d;
	use namespace alternativa3d;
	
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class RenderingSystem extends RenderSystem
	{
		private var scene:Object3D;
	
		public function RenderingSystem(scene:Object3D, renderingSystem:IRenderable=null) 
		{
			this.scene = scene;
			this.renderEngine = renderingSystem;
		}
		
	
		override public function onAddedNode(node:RenderNode):void {
			if (!node.object._parent) scene.addChild( node.object );
			
		}
		
		override public function onRemovedNode(node:RenderNode):void {
			if (node.object._parent === scene) scene.removeChild( node.object);
		}
	
		override public function update(time:Number):void {
			for (var r:RenderNode = nodeList.head as RenderNode; r != null; r = r.next as RenderNode) {
				r.object._x = r.pos.x;
				r.object._y = r.pos.y;
				r.object._z = r.pos.z;
				r.object._rotationX = r.rot.x;
				r.object._rotationY = r.rot.y;
				r.object._rotationZ = r.rot.z;
				r.object.transformChanged = true;
			}
			if (renderEngine != null) renderEngine.render();
		}
		
	}

}