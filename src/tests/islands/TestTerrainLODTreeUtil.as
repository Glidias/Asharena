package tests.islands 
{
	import alternterrain.util.TerrainLODTreeUtil;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.text.TextField;
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class TestTerrainLODTreeUtil extends Sprite
	{
		private var treeUtil:TerrainLODTreeUtil = new TerrainLODTreeUtil();
		private var field:TextField;
		
		public function TestTerrainLODTreeUtil() 
		{
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			addChild(treeUtil.previewShape);
			treeUtil.previewShape.scaleX = 32 / treeUtil.smallestSquareSize / 4;
			treeUtil.previewShape.scaleY = 32/treeUtil.smallestSquareSize / 4;
		
			graphics.clear();
			graphics.beginFill(0xDDDDDD, 1);
			graphics.drawRect(0, 0, 512, 512);
			
			graphics.lineStyle(0, 0xFFFFFF);
			graphics.moveTo(256, 0);
			graphics.lineTo(256, 512);
			
			graphics.moveTo(0, 256);
			graphics.lineTo(512, 256);
			addEventListener(Event.ENTER_FRAME, onEnterframe);
	
			
			field =  new TextField();
			field.autoSize = "left";
			
			addChild(field);
		}
		
		private function onEnterframe(e:Event):void 
		{
			var shape:Shape = treeUtil.previewShape;
		//	shape.x = -stage.stageWidth * .5;
		//	shape.x = -stage.stageWidth * .5;
		//	shape.y =  -stage.stageHeight * .5;
		
			field.text = Math.floor(Math.round(shape.mouseX/(treeUtil.boundingSpace.width*.5)))+ "::"+ ( Math.round( shape.mouseX/treeUtil.boundingSpace.width*2)==1 && Math.round(shape.mouseY/treeUtil.boundingSpace.height*2)==1 ? "within bounds" : "outside bounds need to shift" );
			
			treeUtil.update( shape.mouseX , shape.mouseY );
			
			// 
		}
		
		
		
	}

}