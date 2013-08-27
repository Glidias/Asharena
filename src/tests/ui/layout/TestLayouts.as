package tests.ui.layout 
{
	import alternativa.engine3d.animation.events.NotifyEvent;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import views.ui.layout.AnchorLayout;
	import views.ui.layout.LayoutContainer;
	import views.ui.layout.ViewPortBounds;
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class TestLayouts extends Sprite
	{
		private var anchorLayout:AnchorLayout = new AnchorLayout();
		public var contRight:LayoutContainer = new LayoutContainer();
		public var contLeft:LayoutContainer = new LayoutContainer();
		public var contTop:LayoutContainer = new LayoutContainer();
		public var contBottom:LayoutContainer = new LayoutContainer();
		public var contBottomLeft:LayoutContainer = new LayoutContainer();
		public var contBottomRight:LayoutContainer = new LayoutContainer();
		public var contCenter:LayoutContainer = new LayoutContainer();
		public var contTopLeft:LayoutContainer = new LayoutContainer();
		public var contMiddleLeft:LayoutContainer = new LayoutContainer();
		public var contTopRight:LayoutContainer = new LayoutContainer();
		private var itemsToLayout:Vector.<DisplayObject>;
		
		private var crosshairCenter:Shape = new Shape();
		
		
		private var stageBounds:ViewPortBounds = new ViewPortBounds();
		private var _stage:Stage;
		
		/*
		 Radar (top-right)
		Path/Build-tile state (top right just below radar or on top)
		Tools/Numeric-Selection (mid-left)
		Tips/Help/Warnings/Messages (left(bottom)) 
		Weapon/portrait (top-left)
		Chat/Notifications (top)
		Buffs  (right) Just icons that you place at the side like in typical Daggerfall/Heretic style
		Penalties (Just below portrait) (3 pentalty slots)
		*/	
		
		override public function get stage():Stage {
			return _stage || super.stage;
		}
		
		public function TestLayouts(stager:Stage=null) 
		{
			_stage = stager;
			stager =  stage;
			stager.align = StageAlign.TOP_LEFT;
			stager.scaleMode = StageScaleMode.NO_SCALE;
			stage.addEventListener(Event.RESIZE, onStageResize);
			
			contRight.minWidth = 200 - 8;
			contRight.minHeight = 32;
			//contRight.anchor.left = 4;
			contRight.anchor.right = 4;
			contRight.anchor.top = 4;
			contRight.anchor.bottom = 4;
			
			contRight.anchor.leftAnchorDisplayObject = contCenter;
			contRight.anchor.bottomAnchorDisplayObject = contBottom;
			contRight.anchor.topAnchorDisplayObject = contTopRight;
			
			contTopRight.anchor.left = 4;
			contTopRight.anchor.leftAnchorDisplayObject = contTop;
			contTopRight.anchor.right = 4;
			contTopRight.anchor.top = 4;
			contTopRight.width = 200 - 8;
			contTopRight.height = 200 - 8;
			
			
			contLeft.width = 254;
			contLeft.anchor.left =4;
			contLeft.anchor.right = 4;
			contLeft.anchor.top = 84;
			contLeft.anchor.bottom = 4;
			//contLeft.minWidth = 200;
			contLeft.anchor.rightAnchorDisplayObject = contCenter;
			contLeft.anchor.bottomAnchorDisplayObject = contBottom;
			contLeft.anchor.topAnchorDisplayObject = contTop;
			contLeft.minWidth = 350;
		
	
			contCenter.anchor.left = 4;
			contCenter.anchor.right = 4;
			contCenter.anchor.rightAnchorDisplayObject = contRight;
			contCenter.anchor.leftAnchorDisplayObject = contLeft;
			contCenter.minWidth = 200;
			contCenter.minHeight = 120;
			contCenter.anchor.top = 4;
			contCenter.anchor.bottom = 4;
			contCenter.anchor.bottomAnchorDisplayObject = contBottom;
			contCenter.anchor.topAnchorDisplayObject = contTop;
			contCenter.alpha = .4;
			//contCenter.anchor.horizontalCenter = .5;
			
			contTopLeft.height = 120;
			contTopLeft.width = 128;
			contTopLeft.anchor.top = 4;
			contTopLeft.anchor.left = 4;
			
			contLeft.anchor.topAnchorDisplayObject = contMiddleLeft;
		contLeft.anchor.top = 4;
		contLeft.anchor.bottom = 4;
		
			contTop.anchor.leftAnchorDisplayObject = contTopLeft;
			
			
			contBottom.anchor.bottom = 4;
			contBottom.height = 16;
			contBottom.anchor.left = 4;
			contBottom.anchor.right = 4;
			contBottom.anchor.topAnchorDisplayObject = contMiddleLeft;
		
			contTop.anchor.top = 4;
			contTop.anchor.right = 4;
			contTop.anchor.left = 4;
			contTop.anchor.rightAnchorDisplayObject = contRight;
			contTop.height = 100;
			
			//contCenter.anchor.left = 4;
			//contCenter.anchor.right = 4;
			
			contCenter.anchor.top = 4;
			contCenter.anchor.bottom = 4;
			
			contMiddleLeft.anchor.left = 4;
		
			contMiddleLeft.anchor.top = 4;
			contMiddleLeft.width = 170;
			contMiddleLeft.minHeight = 256;
			
			contMiddleLeft.anchor.topAnchorDisplayObject = contTopLeft;
			//contMiddleLeft.anchor.bottomAnchorDisplayObject = contLeft;
			
			addChild(crosshairCenter);
			
			
			itemsToLayout = new <DisplayObject>[contRight, contCenter, contLeft,contMiddleLeft, contTopLeft,contTopRight, contTop, contBottom];
			
		

			
			var i:int = itemsToLayout.length;
			while (--i > -1) {
				addChild(itemsToLayout[i]);
			}
			
			
			onStageResize(); onStageResize();

		}
		
		private function onStageResize(e:Event=null):void 
		{
			
			updateStage();
			stage.addEventListener(Event.RENDER, onNextFrame);
			stage.invalidate();
		
		}
		
		private function onNextFrame(e:Event):void 
		{
			(e.currentTarget as IEventDispatcher).removeEventListener(e.type, onNextFrame);
			updateStage();
		}
		
		private function updateStage():void 
		{
			stageBounds.explicitWidth = stage.stageWidth;
			stageBounds.explicitHeight = stage.stageHeight;
			if (stageBounds.explicitWidth < 640) stageBounds.explicitWidth = 640;
			if (stageBounds.explicitHeight < 480) stageBounds.explicitHeight = 480;
			anchorLayout.layout(itemsToLayout, stageBounds);

				
			crosshairCenter.x = stageBounds.explicitWidth * .5;
			crosshairCenter.y = stageBounds.explicitHeight * .5;
			crosshairCenter.graphics.beginFill(0, 1);
			crosshairCenter.graphics.drawCircle(0, 0, 4);
				
			contLeft.width = .35 * stageBounds.explicitWidth;
		//	contLeft.anchor.top = 4;// .5 * stageBounds.explicitHeight;
				
			var i:int = itemsToLayout.length;
			while (--i > -1) {
				(itemsToLayout[i] as LayoutContainer).setupValidateAABB();
			}
			
			i  = itemsToLayout.length;
			while (--i > -1) {
				(itemsToLayout[i] as LayoutContainer).validateAABBPhase1();
			}
			
			i  = itemsToLayout.length;
			while (--i > -1) {
				(itemsToLayout[i] as LayoutContainer).validateAABBPhase2();
			}
			
			
			i  = itemsToLayout.length;
			while (--i > -1) {
				(itemsToLayout[i] as LayoutContainer).drawValidateAABB();
			}
	
		}
		
	
		
	}

}