/*
Feathers
Copyright 2012-2013 Joshua Tynjala. All Rights Reserved.

This program is free software. You can redistribute and/or modify it in
accordance with the terms of the accompanying license agreement.
*/
package views.ui.layout
{
	import flash.events.IEventDispatcher;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;


	/**
	 * Public properties and functions from <code>starling.display.DisplayObject</code>
	 * in helpful interface form.
	 *
	 * <p>Never cast an object to this type. Cast to <code>DisplayObject</code>
	 * instead. This interface exists only to support easier code hinting.</p>
	 *
	 * @see starling.display.DisplayObject
	 */
	public interface IFeathersDisplayObject extends IEventDispatcher
	{
		/**
		 * @see starling.display.DisplayObject#x
		 */
		function get x():Number;

		/**
		 * @private
		 */
		function set x(value:Number):void;

		/**
		 * @see starling.display.DisplayObject#y
		 */
		function get y():Number;

		/**
		 * @private
		 */
		function set y(value:Number):void;

		/**
		 * @see starling.display.DisplayObject#width
		 */
		function get width():Number;

		/**
		 * @private
		 */
		function set width(value:Number):void;

		/**
		 * @see starling.display.DisplayObject#height
		 */
		function get height():Number;

		/**
		 * @private
		 */
		function set height(value:Number):void;

		
	}
}
