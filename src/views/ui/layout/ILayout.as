package views.ui.layout 
{
	import flash.display.DisplayObject;
	
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public interface ILayout 
	{
		
		function layout(items:Vector.<DisplayObject>, viewPortBounds:ViewPortBounds = null, result:LayoutBoundsResult = null):LayoutBoundsResult;
	}
	
}