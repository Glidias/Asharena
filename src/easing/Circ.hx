package easing;

@:publicFields class Circ #if !haxe3 implements haxe.Public #end {
	inline static function easeIn ( t : Float, b : Float, c : Float, d : Float ) : Float {
		return -c * ( Math.sqrt( 1 - ( t /= d ) * t ) - 1 ) + b;
	}
	
	inline static function easeOut ( t : Float, b : Float, c : Float, d : Float ) : Float {
		return c * Math.sqrt( 1 - ( t = t / d - 1 ) * t ) + b;
	}
	
	inline static function easeInOut ( t : Float, b : Float, c : Float, d : Float ) : Float {
		if ( ( t /= d * 0.5 ) < 1 )
			return -c * 0.5 * ( Math.sqrt( 1 - t * t ) - 1 ) + b;
		else
			return c * 0.5 * ( Math.sqrt( 1 - ( t -= 2 ) * t ) + 1 ) + b;
	}
}
