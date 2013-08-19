package views.engine3d 
{
	/**
	 * Bare bones main view3d class
	 * @author Glenn Ko
	 */
    import alternativa.engine3d.core.Camera3D;
    import alternativa.engine3d.core.Object3D;
    import alternativa.engine3d.core.View;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Stage;
	import systems.rendering.IRenderable;

	import ash.signals.Signal0;
    import alternativa.engine3d.lights.AmbientLight;
    import alternativa.engine3d.lights.DirectionalLight;
	
    import flash.display.Sprite;
    import flash.display.Stage3D;
	
    import flash.display.StageAlign;
    import flash.display.StageQuality;
    import flash.display.StageScaleMode;
	
    import flash.events.Event;
	import alternativa.engine3d.alternativa3d;
	use namespace alternativa3d;

    public class MainView3D extends Sprite implements IRenderable {
		private var _stage:Stage;

       public var onViewCreate:Signal0 = new Signal0();
        
        public var stage3D:Stage3D
        public var camera:Camera3D
        public var scene:Object3D
        
        public var directionalLight:DirectionalLight;
        public var ambientLight:AmbientLight;   
        
        public function MainView3D() {
            addEventListener(Event.ADDED_TO_STAGE, init);
        }
        
        protected function init(e:Event = null):void 
        {
			_stage = stage;
            removeEventListener(Event.ADDED_TO_STAGE, init);
            
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
            stage.quality = StageQuality.HIGH;            
            
            //Stage3Dを用意
            stage3D = stage.stage3Ds[0];
            //Context3Dの生成、呼び出し、初期化
            stage3D.addEventListener(Event.CONTEXT3D_CREATE, onContextCreate);
            stage3D.requestContext3D();
        }
        
        
        private function onContextCreate(e:Event):void {
            stage3D.removeEventListener(Event.CONTEXT3D_CREATE, onContextCreate);
            //View3D(表示エリア)の作成
            var view:View = new View(stage.stageWidth, stage.stageHeight);
            view.antiAlias = 4
            addChild(view);
            
            //Scene（コンテナ）の作成
            scene = new Object3D();

            //Camera（カメラ）の作成
            camera = new Camera3D(1, 100000);
            camera.view = view;
            scene.addChild(camera)
           // ..camera.diagram
		   
            addChild(camera.diagram);
			view.hideLogo();

            
            //Lightを追加
            ambientLight = new AmbientLight(0xFFFFFF);
            ambientLight.intensity = 0.5;
            scene.addChild(ambientLight);
            
            //Lightを追加
            directionalLight = new DirectionalLight(0xFFFFFF);
            //手前右上から中央へ向けた指向性light
            directionalLight.x = 0;
            directionalLight.y = -100;
            directionalLight.z = -100;
            directionalLight.lookAt(0, 0, 0);
            scene.addChild(directionalLight);
            //directionalLight.visible = false;
            
        
        
			onViewCreate.dispatch();
			
			
			stage.addEventListener(Event.RESIZE, onStageResize);
        }
		
		private function onStageResize(e:Event):void 
		{
			camera.view.width = stage.stageWidth;
			camera.view.height = stage.stageHeight;
		}
		
		
		   public function takeScreenshot( method:Function=null) : Bitmap  //width:int, height:int,
			{
			  var view:View = camera.view;

			  view.renderToBitmap = true;
			  camera.render(stage3D);
			 var canvas:BitmapData =  view.canvas.clone();
			 // var bitmapData:BitmapData = view.canvas.clone();
			  view.renderToBitmap = false;
			//  view.width = oldWidth;
			//  view.height = oldHeight;   
				var child:Bitmap = new Bitmap(canvas);
				stage.addChildAt( child,0 );
			 // take screenshot here
				 if (method!= null && method() ) {
					if (child.parent) child.parent.removeChild(child);
				 }
			  return child;
		}
		
		
		/*
		public function startRendering():void {
			
            addEventListener(Event.ENTER_FRAME, onRenderTick);
		}
		
		private function onRenderTick(e:Event):void 
		{
			render();
		}
		
		public function stopRendering():void {
			 removeEventListener(Event.ENTER_FRAME, onRenderTick);
		}
		*/
		

		/* INTERFACE systems.rendering.IRenderable */
		
		public function render():void 
		{
			camera.render(stage3D);
		}
		
		public function get viewBackgroundColor():uint 
		{
			return camera.view.backgroundColor;
		}
		
		public function set viewBackgroundColor(value:uint):void 
		{
			camera.view.backgroundColor = value;
		}
        
     
    }

}