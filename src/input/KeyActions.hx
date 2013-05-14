package input;

/**
 * ...
 * @author Glenn Ko
 */

class KeyActions 
{

	public static inline var FORWARD:Int = (1<<0);
	public static inline var BACK:Int = (1<<1);
	public static inline var LEFT:Int = (1<<2);
	public static inline var RIGHT:Int = (1<<3);
	public static inline var ACCELERATE:Int = (1<<4);
	
	public static inline var JUMP:Int = (1<<5);
	
	// more stuff
	public static inline var SPELL:Int = (1<<6);
	public static inline var ACTIVATE:Int = (1<<7);
	public static inline var CHANGE_VIEW:Int = (1<<8);
	
	public static inline var DODGE_LEFT:Int =(1<<9);
	public static inline var DODGE_RIGHT:Int = (1<<10);
	
	public static inline var TOGGLE_CROUCH_COMBAT:Int = (1<<11);
	public static inline var TOGGLE_STANDING_COMBAT:Int =(1<<12);
	
}