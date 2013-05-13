package easing;

@:publicFields class Quad #if !haxe3 implements haxe.Public #end {
	inline static function easeIn ( t : Float, b : Float, c : Float, d : Float ) : Float {
		return c * ( t /= d ) * t + b;
	}
	
	inline static function easeOut ( t : Float, b : Float, c : Float, d : Float ) : Float {
		return -c * ( t /= d ) * ( t - 2 ) + b;
	}
	
	inline static function easeInOut ( t : Float, b : Float, c : Float, d : Float ) : Float {
		if ( ( t /= d * 0.5 ) < 1 )
			return c * 0.5 * t * t + b;
		else
			return -c * 0.5 * ( ( --t ) * ( t - 2 ) - 1 ) + b;
	}
}
