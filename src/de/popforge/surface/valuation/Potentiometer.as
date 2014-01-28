package de.popforge.surface.valuation
{
	import de.popforge.surface.display.DefaultTextFormat;
	
	import flash.display.CapsStyle;
	import flash.display.Graphics;
	import flash.display.LineScaleMode;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.utils.Timer;
	import flash.filters.BevelFilter;
	
	public class Potentiometer extends Sprite
	{
		static public const EVENT_CHANGED: String = 'onValueChanged';
		
		static public const ANGLE_MIN: Number = Math.PI*3/4;
		static public const ANGLE_MAX: Number = Math.PI*1/4;
		
		public var type: String;
		
		private var staticShape: Shape;
		private var valueCurve: Shape;
		private var labelField: TextField;
		
		private var timer: Timer;
		
		private var angleRange: Number;
		private var angleRatio: Number;
		private var dragOffset: Number;
		
		//-- range and current value
		private var defaultValue: Number;
		private var min: Number;
		private var max: Number;
		private var val: Number;
		
		//-- angle constraints
		private var angleMin: Number;
		private var angleMax: Number;
		
		public function Potentiometer( min: Number = 0, max: Number = 1, val: Number = 0, angleMin: Number = ANGLE_MIN, angleMax: Number = ANGLE_MAX )
		{
			this.min = min;
			this.max = max;
			defaultValue = this.val = val;
			
			this.angleMin = angleMin;
			this.angleMax = angleMax;

			angleRange = angleMax - angleMin;
			while( angleRange < 0 ) angleRange += Math.PI * 2;
			
			angleRatio = 0;
			
			createBody();
			
			setValue( val );
			
			addEventListener( Event.ADDED, onAdded );
			addEventListener( Event.REMOVED, onRemoved );
			
			timer = new Timer( 5, 0 );
			timer.addEventListener( TimerEvent.TIMER, moveKnob );
			
			doubleClickEnabled = true;
		}
		
		public function setValue( value: Number ): void
		{
			if( value < min ) value = min;
			else if( value > max ) value = max;
			
			angleRatio = ( ( val = value ) - min ) / ( max - min );
			
			drawValue( angleRatio );
		}
		
		public function getValue(): Number
		{
			return val;
		}
		
		public function setLabelText( text: String ): void
		{
			labelField.text = text;
			labelField.x = -labelField.textWidth >> 1;
		}
		
		private function onAdded( event: Event ): void
		{
			stage.addEventListener( MouseEvent.MOUSE_DOWN, onMouseDown );
			stage.addEventListener( MouseEvent.MOUSE_UP, onMouseUp );
			stage.addEventListener( MouseEvent.DOUBLE_CLICK, onMouseDoubleClick );
		}
		
		private function onRemoved( event: Event ): void
		{
			stage.removeEventListener( MouseEvent.MOUSE_DOWN, onMouseDown );
			stage.removeEventListener( MouseEvent.MOUSE_UP, onMouseUp );
			stage.removeEventListener( MouseEvent.DOUBLE_CLICK, onMouseDoubleClick );
		}
		
		private function onMouseDown( event: MouseEvent ): void
		{
			if( event.target == this )
			{
				dragOffset = mouseY;
				
				timer.start();
			}
		}
		
		private function onMouseUp( event: MouseEvent ): void
		{
			timer.stop();
		}
		
		private function moveKnob( event: Event ): void
		{
			angleRatio += ( dragOffset - mouseY ) / 8192;
			
			updateValue();
		}
		
		private function onMouseDoubleClick( event: MouseEvent ): void
		{
			if( event.target == this )
			{
				setValue( defaultValue );
				
				dispatchEvent( new Event( EVENT_CHANGED ) );
			}
		}
		
		private function updateValue(): void
		{
			if( angleRatio < 0 ) angleRatio = 0;
			else if( angleRatio > 1 ) angleRatio = 1;
			
			val = min + ( max - min ) * angleRatio;
			
			drawValue( angleRatio );
			
			dispatchEvent( new Event( EVENT_CHANGED ) );
		}

		private function drawValue( value: Number ): void
		{
			var g: Graphics = valueCurve.graphics;
			
			g.clear();
			g.lineStyle( 2, 0xaaaaaa, 1, false, LineScaleMode.NORMAL, CapsStyle.SQUARE );
			drawCircleSegment( g, 0, 0, 11, angleMin, angleMin + angleRange * value );
		}
		
		private function createBody(): void
		{
			staticShape = new Shape();
			staticShape.cacheAsBitmap = true;
			addChild( staticShape );
			
			valueCurve = new Shape();
			addChild( valueCurve );
			
			valueCurve.filters = [ new GlowFilter( 0xffffff, 1, 4, 4, .5, 3 ) ];
			
			var g: Graphics = staticShape.graphics;
			
			//-- bg
			g.beginFill( 0x3a3a3a );
			g.drawCircle( 0, 0, 15 );
			g.endFill();
			
			//-- knob
			g.beginFill( 0x565656 );
			g.lineStyle( 1, 0x202020 );
			g.drawCircle( 0, 0, 6 );
			g.endFill();
			
			//-- track
			g.lineStyle( 4, 0x1b1b1d, 1, false, LineScaleMode.NORMAL, CapsStyle.SQUARE );
			drawCircleSegment( g, 0, 0, 11, angleMin, angleMin + angleRange );
			
			labelField = new TextField();
			labelField.selectable = false;
			labelField.autoSize = TextFieldAutoSize.LEFT;
			labelField.defaultTextFormat = new DefaultTextFormat();
			labelField.y = 14;
			addChild( labelField );
		}
		
		private function drawCircleSegment( g: Graphics, x: Number, y: Number, radius: Number, startAngle: Number, endAngle: Number ): void
		{
			var angle: Number = startAngle;
			var angleMid: Number;
			var arc: Number = endAngle - angle;
			while( arc < 0 ) arc += Math.PI * 2;
			var segs: Number = Math.ceil( arc / ( Math.PI / 4 ) );
			var segAngle: Number = -arc / segs;
			var theta: Number = -segAngle / 2;
			var cosTheta: Number = Math.cos( theta );
			var ax: Number = Math.cos( angle ) * radius;
			var ay: Number = Math.sin( angle ) * radius;
			var bx: Number;
			var by: Number;
			var cx: Number;
			var cy: Number;
			g.moveTo( ax + x, ay + y );
			for( var i: int = 0 ; i < segs ; i++ )
			{
				angle += theta*2;
				angleMid = angle - theta;
				bx = x + Math.cos( angle ) * radius;
				by = y + Math.sin( angle ) * radius;
				cx = x + Math.cos( angleMid ) * ( radius / cosTheta );
				cy = y + Math.sin( angleMid ) * ( radius / cosTheta );
				g.curveTo( cx, cy, bx, by );
			}
		}
	}
}