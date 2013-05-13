package easing;

@:publicFields class Quart #if !haxe3 implements haxe.Public #end {
	inline static function easeIn ( t : Float, b : Float, c : Float, d : Float ) : Float {
		return c * ( t /= d ) * t * t * t + b;
	}
	
	inline static function easeOut ( t : Float, b : Float, c : Float, d : Float ) : Float {
		return -c * ( ( t = t / d - 1 ) * t * t * t - 1 ) + b;
	}
	
	inline static function easeInOut ( t : Float, b : Float, c : Float, d : Float ) : Float {
		if ( ( t /= d * 0.5 ) < 1 )
			return c * 0.5 * t * t * t * t + b;
		else
			return -c * 0.5 * ( ( t -= 2 ) * t * t * t - 2) + b;
	}
}
