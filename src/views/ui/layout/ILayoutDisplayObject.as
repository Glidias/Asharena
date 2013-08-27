/*
Feathers
Copyright 2012-2013 Joshua Tynjala. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package views.ui.layout
{


	/**
	 * Dispatched when a property of the display object's layout data changes.
	 *
	 * @eventType feathers.events.FeathersEventType.LAYOUT_DATA_CHANGE
	 */
	[Event(name="layoutDataChange",type="flash.events.Event")]

	/**
	 * A display object that may be associated with extra data for use with
	 * advanced layouts.
	 */
	public interface ILayoutDisplayObject extends IFeathersDisplayObject
	{
		/**
		 * Extra parameters associated with this display object that will be
		 * used by the layout algorithm.
		 */
		function get layoutData():ILayoutData;

		/**
		 * @private
		 */
		function set layoutData(value:ILayoutData):void;

		
	}
}
