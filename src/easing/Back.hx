package easing;

@:publicFields class Back #if !haxe3 implements haxe.Public #end {
	inline static function easeIn ( t : Float, b : Float, c : Float, d : Float ) : Float {
		return c * ( t /= d ) * t * ( ( 1.70158 + 1 ) * t - 1.70158 ) + b;
	}
	
	inline static function easeOut ( t : Float, b : Float, c : Float, d : Float ) : Float {
		return c * ( ( t = t / d - 1 ) * t * ( ( 1.70158 + 1 ) * t + 1.70158 ) + 1 ) + b;
	}
	
	inline static function easeInOut ( t : Float, b : Float, c : Float, d : Float ) : Float	{
		var s = 1.70158; 
		if ( ( t /= d * 0.5 ) < 1 )
			return c * 0.5 * ( t * t * ( ( ( s *= ( 1.525 ) ) + 1 ) * t - s ) ) + b;
		else
			return c * 0.5 * ( ( t -= 2 ) * t * ( ( ( s *= ( 1.525 ) ) + 1 ) * t + s ) + 2 ) + b;
	}
}
