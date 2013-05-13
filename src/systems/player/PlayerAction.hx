package systems.player;

/**
 * Contains all basic movement-related action notification triggers for PlayerControlActionSystem (and other systems). Supports up to 32 player actions if using bitmask stsate. 
 * Adjust the numbers as you see fit. Eg. You can use similar numbers if they point to similar animations, with the exception of "STATE_" prefixed actions, or use a id to string binding
 * system like in the below XML. ids higher than zero indicate lower body animations. Ids lower or equal to zero indicate full-body animations.
 * 
 * @author Glenn Ko
 */
class PlayerAction
{
	public static inline var IDLE:Int = 0;
	
	public static inline var STRAFE_LEFT:Int = 1;
	public static inline var STRAFE_RIGHT:Int = 2;
	public static inline var MOVE_FORWARD:Int = 3;
	public static inline var MOVE_BACKWARD:Int = 4;
	
	public static inline var STRAFE_LEFT_FAST:Int = 5;
	public static inline var STRAFE_RIGHT_FAST:Int = 6;
	public static inline var MOVE_FORWARD_FAST:Int = 7;
	public static inline var MOVE_BACKWARD_FAST:Int = 8;
	
	public static inline var IN_AIR:Int = 9;
	public static inline var IN_AIR_FALLING:Int = 10;
	
	public static inline var STATE_JUMP:Int = -11;
	
	// Sample XML if you wish to bind PlayerAction ids to strings!
	
	/*
	 <actions>
		<a id="IDLE" str="left"></a>
		
		<a id="STRAFE_LEFT" str="left"></a>
		<a id="STRAFE_LEFT_FAST" str="left"></a>
		
		<a id="STRAFE_RIGHT" str="right"></a>
		<a id="STRAFE_RIGHT_FAST" str="right"></a>
		
		<a id="MOVE_FORWARD" str="forward"></a>
		<a id="MOVE_FORWARD_FAST" str="forward"></a>
		
		<a id="MOVE_BACKWARD" str="back"></a>
		<a id="MOVE_BACKWARD_FAST" str="back"></a>
		
		<a id="IN_AIR" str="air"></a>
		<a id="IN_AIR_FALLING" str="air"></a>
		
		<a id="STATE_JUMP" str="jump"></a>
	</actions>

	*/

	

}