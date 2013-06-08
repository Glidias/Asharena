package views 
{
	import alternativa.engine3d.materials.FillMaterial;
	import alternativa.engine3d.materials.StandardMaterial;
	import alternativa.engine3d.primitives.Box;
	import alternativa.engine3d.primitives.Plane;
	import alternativa.engine3d.resources.BitmapTextureResource;
	import alternativa.engine3d.Template;
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.ui.Keyboard;
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class Alternativa3DView extends Template
	{
		
		public var box:Box;
		public function Alternativa3DView() 
		{
			super();
			
			addEventListener(VIEW_CREATE, onViewCreated);
			
			box = new Box(800, 800, 200, 1, 1, 1, true, getColorStandardMaterial(0x888888) );
			
			
			//box.z += 800 * .5 - 70;
		}
		
		private function onViewCreated(e:Event):void 
		{
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			
			cameraController.speed = 0;
				
			
			createWorld();
			
			startRendering();
			
			dispatchEvent( new Event(Event.COMPLETE) );
		}
		
		private var normResource:BitmapTextureResource = new BitmapTextureResource(new BitmapData(2, 2, false, 0xCCCCCC) );

		private function createWorld():void 
		{
				box.matrix = new Matrix3D();
				scene.matrix = new Matrix3D();
			scene.addChild( box);
		
		}
		
		private function getColorStandardMaterial(color:uint):StandardMaterial {
			return new StandardMaterial( new BitmapTextureResource( new BitmapData(2, 2, false, color) ), normResource);
		}
		
		private function onKeyDown(e:KeyboardEvent):void 
		{
			if (e.keyCode === Keyboard.V) {
				cameraController.speed = 33;
			}
		}
		
		private function onKeyUp(e:KeyboardEvent):void 
		{
				if (e.keyCode === Keyboard.V) {
				cameraController.speed = 0;
			}
		}
		
	}

}