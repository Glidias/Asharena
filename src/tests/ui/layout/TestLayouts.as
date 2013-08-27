package tests.ui.layout 
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
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
		private var contRight:LayoutContainer = new LayoutContainer();
		private var contLeft:LayoutContainer = new LayoutContainer();
		private var contTop:LayoutContainer = new LayoutContainer();
		private var contBottom:LayoutContainer = new LayoutContainer();
		private var contBottomLeft:LayoutContainer = new LayoutContainer();
		private var contBottomRight:LayoutContainer = new LayoutContainer();
		private var contCenter:LayoutContainer = new LayoutContainer();
		private var contTopLeft:LayoutContainer = new LayoutContainer();
		
		private var itemsToLayout:Vector.<DisplayObject>;
		private var stageBounds:ViewPortBounds = new ViewPortBounds();
		
		public function TestLayouts() 
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.addEventListener(Event.RESIZE, onStageResize);
			
			contRight.minWidth = 200 - 8;
			contRight.minHeight = 32;
			//contRight.anchor.left = 4;
			contRight.anchor.right = 4;
			contRight.anchor.top = 4;
			contRight.anchor.bottom = 4;
			
			contRight.anchor.leftAnchorDisplayObject = contCenter;
			contRight.anchor.bottomAnchorDisplayObject = contBottom;
			
			contLeft.width = 200;
			contLeft.anchor.left =4;
			contLeft.anchor.right = 4;
			contLeft.anchor.top = 4;
			contLeft.anchor.bottom = 4;
			contLeft.anchor.rightAnchorDisplayObject = contCenter;
			contLeft.anchor.bottomAnchorDisplayObject = contBottom;
			contLeft.anchor.topAnchorDisplayObject = contTop;
			
	
			contCenter.anchor.left = 4;
			contCenter.anchor.right = 4;
			contCenter.anchor.rightAnchorDisplayObject = contRight;
			contCenter.anchor.leftAnchorDisplayObject = contLeft;
			contCenter.minWidth = 300;
			contCenter.minHeight = 300;
			contCenter.anchor.top = 4;
			contCenter.anchor.bottom = 4;
			contCenter.anchor.bottomAnchorDisplayObject = contBottom;
			contCenter.anchor.topAnchorDisplayObject = contTop;
			
			
			contTopLeft.height = 233;
			contTopLeft.width = 250;
			contTopLeft.anchor.top = 4;
			contTopLeft.anchor.left = 4;
			
			contLeft.anchor.topAnchorDisplayObject = contTopLeft;
		
		
			contTop.anchor.leftAnchorDisplayObject = contTopLeft;
			
			
			contBottom.anchor.bottom = 4;
			contBottom.height = 100;
			contBottom.anchor.left = 4;
			contBottom.anchor.right = 4;
			contBottom.anchor.topAnchorDisplayObject = contCenter;
		
			contTop.anchor.top = 4;
			contTop.anchor.right = 4;
			contTop.anchor.left = 4;
			contTop.anchor.rightAnchorDisplayObject = contRight;
			contTop.height = 100;
			
			//contCenter.anchor.left = 4;
			//contCenter.anchor.right = 4;
			
			contCenter.anchor.top = 4;
			contCenter.anchor.bottom = 4;
			
			
			
			itemsToLayout = new <DisplayObject>[contRight, contCenter, contLeft, contTopLeft, contTop, contBottom];
			
		

			
			var i:int = itemsToLayout.length;
			while (--i > -1) {
				addChild(itemsToLayout[i]);
			}
			
			
			onStageResize();
			
		}
		
		private function onStageResize(e:Event=null):void 
		{
			
			stageBounds.explicitWidth = stage.stageWidth;
			stageBounds.explicitHeight = stage.stageHeight;
			
			anchorLayout.layout(itemsToLayout, stageBounds);
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