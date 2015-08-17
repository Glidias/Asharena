package alternativa.engine3d.controllers 
{
	import alternativa.engine3d.core.Object3D;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class SpinController 
	{
		private var dispatcher:IEventDispatcher;
		private var stage:Stage;
		private var _mouseData:MouseData = new MouseData();
		
		private var throwTimer:Timer;
		private var dragTimer:Timer;
		private var object:Object3D;
		private var dragSpeed:Number = 0.001;
		private var throwSpeed:Number = 0.001;
		
		public function setFrameRates(dragFPS:int, throwFPS:int = 0):void {
			if (dragFPS == 0) dragFPS = 60;
			if (throwFPS == 0) throwFPS = dragFPS;
			
			dragFPS = 1000 / dragFPS;
			throwFPS = 1000 / throwFPS;
			throwTimer.delay = throwFPS;
			dragTimer.delay = dragFPS;
	
		}
		
		public function setSpinSpeeds(dragSpeed:Number, throwSpeed:Number = 0):void {
			this.throwSpeed = throwSpeed;
			

			if (dragSpeed == 0) dragSpeed = 0.001;
			
			if (throwSpeed == 0) throwSpeed = dragSpeed;
			this.dragSpeed = dragSpeed;
			this.throwSpeed = throwSpeed;
			
		}
		
		public function SpinController(dispatcher:IEventDispatcher, stage:Stage, object:Object3D) 
		{
			this.object = object;
			this.stage = stage;
			this.dispatcher = dispatcher;
			init();
			
		}
		
		private function init():void 
		{
			initListeners();
		}
		
		private function initListeners():void 
		{
	
			throwTimer = new Timer(1000/60);
			throwTimer.addEventListener(TimerEvent.TIMER, onThrowTick, false, 0, true);
			
			dragTimer = new Timer(1000/60);
			dragTimer.addEventListener(TimerEvent.TIMER, onDragTick, false, 0, true);
			
			
		//	_viewer2.addEventListener(MouseEvent.ROLL_OVER, onViewerOver, false, 0, true);
			//	_viewer2.addEventListener(MouseEvent.ROLL_OUT, onViewerOut, false, 0, true);
			dispatcher.addEventListener(MouseEvent.MOUSE_DOWN, onDownHandler, false, 0, true);
		}
		
		private function startDragTimer():void 
		{
			dragTimer.start();
		}
		private function onDragTick(e:TimerEvent):void 
		{
			_mouseData.velocityX = stage.mouseX - _mouseData.currentX;
			_mouseData.velocityY = stage.mouseY - _mouseData.currentY;
			_mouseData.currentX  = stage.mouseX;
			_mouseData.currentY  = stage.mouseY;
			
			object.rotationY -= _mouseData.velocityX * dragSpeed;
	
		}
		
		private function stopDragTimer():void 
		{
			dragTimer.stop();
		}
		
		private function onDownHandler(e:MouseEvent):void 
		{
			
			stopThrow();
			
			_mouseData.startX = stage.mouseX;
			_mouseData.startY = stage.mouseY;
			_mouseData.currentX = stage.mouseX;
			_mouseData.currentY = stage.mouseY;
			_mouseData.isDragging = true;
			stage.addEventListener(MouseEvent.MOUSE_UP, onUpHandler, false, 0, true);
			stage.addEventListener(Event.MOUSE_LEAVE, onUpHandler, false, 0, true);
		//	_viewer2.addEventListener(MouseEvent.MOUSE_MOVE, onMoveHandler, false, 0, true);
			

			startDragTimer();
		}
		
		private function onUpHandler(e:Event):void 
		{
			stopDragTimer();

		
			_mouseData.isDragging = false;
			stage.removeEventListener(MouseEvent.MOUSE_UP, onUpHandler);
			stage.removeEventListener(Event.MOUSE_LEAVE, onUpHandler);
		//	dispatcher.removeEventListener(MouseEvent.MOUSE_MOVE, onMoveHandler);
			startThrow();
		}
		private function startThrow():void 
		{
			throwTimer.start();
		}
		
		private function onThrowTick(e:TimerEvent):void 
		{
			_mouseData.velocityX *= .95;
			_mouseData.velocityY *= .95;
				
			if (Math.abs(_mouseData.velocityX) < .1 && Math.abs(_mouseData.velocityY) < .1) { 
				
				_mouseData.velocityX = 0;
				_mouseData.velocityY = 0;
				stopThrow();
				
			}
			object.rotationY -= _mouseData.velocityX * throwSpeed;
			
			
		}
		
		private function stopThrow():void 
		{
			stage.removeEventListener(MouseEvent.MOUSE_UP, onUpHandler);
			throwTimer.stop();
		}
		
	}

}