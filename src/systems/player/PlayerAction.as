package systems.player {
	public class PlayerAction {
		static public const IDLE : int = 0;
		static public const STRAFE_LEFT : int = 1;
		static public const STRAFE_RIGHT : int = 2;
		static public const MOVE_FORWARD : int = 3;
		static public const MOVE_BACKWARD : int = 4;
		static public const STRAFE_LEFT_FAST : int = 5;
		static public const STRAFE_RIGHT_FAST : int = 6;
		static public const MOVE_FORWARD_FAST : int = 7;
		static public const MOVE_BACKWARD_FAST : int = 8;
		static public const IN_AIR : int = 9;
		static public const IN_AIR_FALLING : int = 10;
		static public const STATE_JUMP : int = -11;
	}
}
