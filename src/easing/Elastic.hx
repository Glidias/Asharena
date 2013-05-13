package easing;

@:publicFields class Elastic #if !haxe3 implements haxe.Public #end {
	inline static function easeIn ( t : Float, b : Float, c : Float, d : Float ) : Float {
		if ( t == 0 ) {
			return b;
		} if ( ( t /= d ) == 1 ) {
			return b + c;
		} else {
			var p = d * .3;
			var s = p * 0.25;
			return -( c * Math.pow( 2, 10 * ( t -= 1 ) ) * Math.sin( ( t * d - s ) * ( 2 * Math.PI ) / p ) ) + b;
		}
	}
	
	inline static function easeOut ( t : Float, b : Float, c : Float, d : Float ) : Float {
		if ( t == 0 ) {
			return b;
		} else if ( ( t /= d ) == 1 ) {
			return b + c;
		} else {
			var p = d * .3;
			var	s = p * 0.25;
			return ( c * Math.pow( 2, -10 * t ) * Math.sin( ( t * d - s ) * ( 2 * Math.PI ) / p ) + c + b );
		}
	}
	
	inline static function easeInOut ( t : Float, b : Float, c : Float, d : Float ) : Float	{
		if ( t == 0 ){
			return b;
		} else if ( ( t /= d / 2 ) == 2 ) {
			return b + c;
		} else {
			var p = d * ( .3 * 1.5 );
			var	s = p * 0.25;
			if ( t < 1 )
				return -.5 * ( c * Math.pow( 2, 10 * ( t -= 1 ) ) * Math.sin( ( t * d - s ) * ( 2 * Math.PI ) / p ) ) + b;
			else
				return c * Math.pow( 2, -10 * ( t -= 1 ) ) * Math.sin( ( t * d - s ) * ( 2 * Math.PI ) / p ) * .5 + c + b;
		}
	}
}
