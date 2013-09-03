package views.ui.hud 
{
	import alternativa.a3d.systems.text.TextBoxChannel;
	import alternativa.engine3d.core.Object3D;
	import de.polygonal.motor.geom.primitive.AABB2;
	import alternativa.engine3d.alternativa3d;
	import flash.geom.Point;
	use namespace alternativa3d;
	
	/**
	 * ...
	 * @author Glidias
	 */
	public class BindLayoutTextBox 
	{
		private var textBox:TextBoxChannel;
		private var aabb:AABB2;
		private var obj:Object3D;
		private var _contentHeightOffset:Number =0;
		private var _centerY:Number=0;
		public var offsetY:Number;
		public var offsetX:Number;
		public var marginX:Number;
		public var marginY:Number;
		public var downwards:Boolean;
		
		public function BindLayoutTextBox(aabb:AABB2, obj:Object3D, textBox:TextBoxChannel, marginX:Number=4, marginY:Number=4, offsetX:Number=0, offsetY:Number=0, downwards:Boolean=true) 
		{
			super();
			this.offsetY = offsetY;
			this.offsetX = offsetX;
			this.textBox = textBox;
			this.aabb = aabb;
			this.obj = obj;
			this.marginX = marginX;
			this.marginY = marginY;
			this.downwards = downwards;
			
			if (downwards) textBox.onContentHeightChange.add(heightChange);
			
		}
		private function heightChange(height:Number, cropped:Boolean):void {
			
			_contentHeightOffset = height;
			if (_centerY == 0) return;
			obj._y = _contentHeightOffset + aabb.minY - _centerY + marginY + offsetY +textBox.lineSpacing;
			obj.transformChanged = true;
		}
		
		public function update(centerX:Number, centerY:Number):void {
			_centerY = centerY;
			var divisor:Number = textBox.lineSpacing + textBox.vSpacing;
			textBox.setShowItems(((aabb.maxY - aabb.minY) - marginY * 2) / divisor);
			textBox.setWidth(  (aabb.maxX - aabb.minX)- marginX * 2);
			// throw new Error("SHOULD NOT BE!"+aabb.minX);
			obj._x = aabb.minX - centerX + marginX + offsetX;
			obj._y = downwards ? _contentHeightOffset + aabb.minY - _centerY + marginY + offsetY +textBox.lineSpacing :  _contentHeightOffset +  aabb.maxY - centerY - marginY + offsetY +textBox.lineSpacing;
			
			obj.transformChanged = true;
		}
		
	}

}