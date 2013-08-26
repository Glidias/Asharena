/*
Feathers
Copyright 2012-2013 Joshua Tynjala. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package views.ui.layout
{
	import flash.geom.Rectangle;

	

	/**
	 * Basic interface for Feathers UI controls. A Feathers control must also
	 * be a Starling display object.
	 */
	public interface IFeathersControl extends IFeathersDisplayObject
	{
		/**
		 * @copy feathers.core.FeathersControl#minWidth
		 */
		function get minWidth():Number;

		/**
		 * @private
		 */
		function set minWidth(value:Number):void;

		/**
		 * @copy feathers.core.FeathersControl#minHeight
		 */
		function get minHeight():Number;

		/**
		 * @private
		 */
		function set minHeight(value:Number):void;

		/**
		 * @copy feathers.core.FeathersControl#maxWidth
		 */
		function get maxWidth():Number;

		/**
		 * @private
		 */
		function set maxWidth(value:Number):void;

		/**
		 * @copy feathers.core.FeathersControl#maxHeight
		 */
		function get maxHeight():Number;

		/**
		 * @private
		 */
		function set maxHeight(value:Number):void;

		
		/**
		 * @copy feathers.core.FeathersControl#setSize()
		 */
		function setSize(width:Number, height:Number):void;

		/**
		 * @copy feathers.core.FeathersControl#validate()
		 */
		function validate():void;
	}
}
