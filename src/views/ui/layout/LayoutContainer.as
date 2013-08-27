package views.ui.layout 
{
	import de.polygonal.motor.geom.primitive.AABB2;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class LayoutContainer extends Shape implements IFeathersControl, ILayoutDisplayObject
	{
		private var _minWidth:Number =0;
		private var _maxWidth:Number =0;
		private var _minHeight:Number=0;
		private var _maxHeight:Number=0;
		
		public var anchor:AnchorLayoutData = new AnchorLayoutData();
		static public const ILLEGAL_WIDTH_ERROR:String = "illegalWidthError";
		static public const ILLEGAL_HEIGHT_ERROR:String = "illegalHeightError";
		private var _layoutData:ILayoutData;
		
		
		/**
		 * The width value explicitly set by calling the width setter or
		 * setSize().
		 */
		protected var explicitWidth:Number = NaN;

		/**
		 * The final width value that should be used for layout. If the width
		 * has been explicitly set, then that value is used. If not, the actual
		 * width will be calculated automatically. Each component has different
		 * automatic sizing behavior, but it's usually based on the component's
		 * skin or content, including text or subcomponents.
		 */
		protected var actualWidth:Number = 0;
		
		
		/**
		 * The height value explicitly set by calling the height setter or
		 * setSize().
		 */
		protected var explicitHeight:Number = NaN;

		/**
		 * The final height value that should be used for layout. If the height
		 * has been explicitly set, then that value is used. If not, the actual
		 * height will be calculated automatically. Each component has different
		 * automatic sizing behavior, but it's usually based on the component's
		 * skin or content, including text or subcomponents.
		 */
		protected var actualHeight:Number = 0;
		
		
		
		public function LayoutContainer() 
		{
			layoutData = anchor;
		}
		
		public var validateAABB:AABB2 = new AABB2();
		public var valid:Boolean = false;
		
		public function setupValidateAABB():void {
			validateAABB.minX = x;
			validateAABB.minY = y;
			validateAABB.maxX = x + width;
			validateAABB.maxY = y + height;
		}
		
		public function validateAABBPhase1():void {
			var valuer:Number;
			var other:LayoutContainer;
			if ( (other = anchor.leftAnchorDisplayObject as LayoutContainer) && isNaN(anchor.left) && !isNaN(valuer = other.anchor.right) ) {
				
				if (other.validateAABB.maxX + valuer >  validateAABB.minX) {
					validateAABB.minX = other.validateAABB.maxX + valuer;
					
				}
			}
			
			if ( (other = anchor.topAnchorDisplayObject as LayoutContainer) && isNaN(anchor.top) && !isNaN(valuer = other.anchor.bottom) ) {
				if (other.validateAABB.maxY + valuer >  validateAABB.minY) validateAABB.minY = other.validateAABB.maxY + valuer;
			}
			
			
			if ( (other = anchor.rightAnchorDisplayObject as LayoutContainer) && isNaN(anchor.right) && !isNaN(valuer = other.anchor.left) ) {
				if (other.validateAABB.minX - valuer <  validateAABB.maxX) validateAABB.maxX = other.validateAABB.minX + valuer;
			}
			
			if ( (other = anchor.bottomAnchorDisplayObject as LayoutContainer) && isNaN(anchor.bottom) && !isNaN(valuer = other.anchor.top) ) {
				if (other.validateAABB.minY - valuer <  validateAABB.maxY) validateAABB.maxY = other.validateAABB.minY + valuer;
			}
			
			
		}
		
		public function validateAABBPhase2():void {
			
			var other:LayoutContainer;
			if ( (other = anchor.leftAnchorDisplayObject as LayoutContainer) && !isNaN(anchor.left)  ) {
				validateAABB.minX = other.validateAABB.maxX + anchor.left;	
			}
			
			if ( (other = anchor.rightAnchorDisplayObject as LayoutContainer) && !isNaN(anchor.right)  ) {
				validateAABB.maxX = other.validateAABB.minX - anchor.right;	
			}
			
			if ( (other = anchor.topAnchorDisplayObject as LayoutContainer) && !isNaN(anchor.top)  ) {
				validateAABB.minY = other.validateAABB.maxY + anchor.top;	
			}
			if ( (other = anchor.bottomAnchorDisplayObject as LayoutContainer) && !isNaN(anchor.bottom)  ) {
				validateAABB.maxY = other.validateAABB.minY - anchor.bottom;	
			}
		}
		
		public function drawValidateAABB():void {
			var graphics:Graphics = this.graphics;
			graphics.clear();
			
			
			graphics.beginFill(0xFF0000, .3);
			graphics.drawRect(validateAABB.minX-x, validateAABB.minY-y, validateAABB.maxX -x, validateAABB.maxY - y);
		}
		
		override public function get width():Number {
		
			return actualWidth > _minWidth ? actualWidth : _minWidth;
		}
		override public function set width(value:Number):void
		{
			//if (_minWidth === _minWidth && value < _minWidth) value = _minWidth;  // trying this out
			if(this.explicitWidth == value)
			{
				return;
			}
			const valueIsNaN:Boolean = isNaN(value);
			if(valueIsNaN && isNaN(this.explicitWidth))
			{
				return;
			}
			this.explicitWidth = value;
			if(valueIsNaN)
			{
				this.actualWidth  = 0;
				invalidate();
			}
			else
			{
				this.setSizeInternal(value, this.actualHeight, true);
			}
		}
		
		/**
		 * Sets the width and height of the control, with the option of
		 * invalidating or not. Intended to be used when the <code>width</code>
		 * and <code>height</code> values have not been set explicitly, and the
		 * UI control needs to measure itself and choose an "ideal" size.
		 */
		protected function setSizeInternal(width:Number, height:Number, canInvalidate:Boolean):Boolean
		{
			if(!isNaN(this.explicitWidth))
			{
				width = this.explicitWidth;
			}
			else
			{
				if(width < this._minWidth)
				{
					width = this._minWidth;
				}
				else if(width > this._maxWidth)
				{
					width = this._maxWidth;
				}
			}
			if(!isNaN(this.explicitHeight))
			{
				height = this.explicitHeight;
			}
			else
			{
				if(height < this._minHeight)
				{
					height = this._minHeight;
				}
				else if(height > this._maxHeight)
				{
					height = this._maxHeight;
				}
			}
			if(isNaN(width))
			{
				throw new ArgumentError(ILLEGAL_WIDTH_ERROR);
			}
			if(isNaN(height))
			{
				throw new ArgumentError(ILLEGAL_HEIGHT_ERROR);
			}
			var resized:Boolean = false;
			if(this.actualWidth != width)
			{
				this.actualWidth = width;
				resized = true;
			}
			if(this.actualHeight != height)
			{
				this.actualHeight = height;
				resized = true;
			}
			 this.actualWidth * Math.abs(this.scaleX);
			this.actualHeight * Math.abs(this.scaleY);
			if(resized)
			{
				if(canInvalidate)
				{
					this.invalidate();
					
				}
			//	this.dispatchEventWith(FeathersEventType.RESIZE);
			}
			return resized;
		}
		

		
		
		private function invalidate():void 
		{
			valid = false;
		}
		
		
		
		
		override public function get height():Number {
			return actualHeight >= _minHeight ? actualHeight : _minHeight;
		}
		
		override public function set height(value:Number):void
		{
			if(this.explicitHeight == value)
			{
				return;
			}
			const valueIsNaN:Boolean = isNaN(value);
			if(valueIsNaN && isNaN(this.explicitHeight))
			{
				return;
			}
			this.explicitHeight = value;
			if(valueIsNaN)
			{
				this.actualHeight  = 0;
				this.invalidate();
			}
			else
			{
				this.setSizeInternal(this.actualWidth, value, true);
			}
		}
		
				
		public function validate():void 
		{
			valid = true;
		}
		
		/* INTERFACE views.ui.layout.IFeathersControl */
		
		public function get minWidth():Number 
		{
			return _minWidth;
		}
		
		public function set minWidth(value:Number):void 
		{
			_minWidth = value;
		}
		
		public function get minHeight():Number 
		{
			return _minHeight;
		}
		
		public function set minHeight(value:Number):void 
		{
			_minHeight = value;
		}
		
		public function get maxWidth():Number 
		{
			return _maxWidth;
		}
		
		public function set maxWidth(value:Number):void 
		{
			_maxWidth = value;
		}
		
		public function get maxHeight():Number 
		{
			return _maxHeight;
		}
		
		public function set maxHeight(value:Number):void 
		{
			_maxHeight = value;
		}
		
		public function setSize(width:Number, height:Number):void 
		{
			this.width = width;
			this.height = height;
		}

		
		/* INTERFACE views.ui.layout.ILayoutDisplayObject */
		
		public function get layoutData():ILayoutData 
		{
			return (anchor || _layoutData);
		}
		
		public function set layoutData(value:ILayoutData):void 
		{
			anchor = value as AnchorLayoutData;
			_layoutData = value;
		}
		
		
	}

}