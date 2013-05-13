package components;

/**
 * Extended jump component to indicate jump jetting ability as well.
 * @author Glenn Ko
 */
class JumpJet extends Jump
{

	public static inline var INTERVAL:Float = 0.01;
	
	public function new( jumpSpeed:Float) 
	{
		super(INTERVAL, jumpSpeed);
	}
	
}