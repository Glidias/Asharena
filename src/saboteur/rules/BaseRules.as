package saboteur.rules 
{
	import ash.signals.Signal1;
	import ash.signals.SignalAny;
	import saboteur.util.GameBuilder;
	import saboteur.util.SaboteurActionCard;
	import saboteur.util.SaboteurPathUtil;
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class BaseRules 
	{
		protected var gameBuilder:GameBuilder;
		protected var pathUtil:SaboteurPathUtil;
		public var onPlayBuildFailed:SignalAny;
		public var onPlayBuildSuccess:SignalAny;
		
		
		public function BaseRules() 
		{
			gameBuilder = new GameBuilder();
			onPlayBuildFailed = new SignalAny();
			onPlayBuildSuccess = new SignalAny();
			pathUtil = SaboteurPathUtil.getInstance();
		}
		
		public function setup():void {  // overwrite this for custom implementation
			
		}
		
		// validation + action attempts via rules. Return true if successful, false if not successful.
		public function playPathCard(east:int, south:int, value:uint, playerIndex:int = 0, handIndex:int=-1):Boolean {
			if ( gameBuilder.attemptBuild(east, south, value) ) {
				onPlayBuildSuccess.dispatch(east, south, value, playerIndex, handIndex);
				return true;
			}
			else {
				onPlayBuildFailed.dispatch(east, south, value, playerIndex, handIndex );
				return false;
			}
		}
		public function playActionCard(card:SaboteurActionCard, playerIndex:int = 0, toPlayerIndex:int = 0, handIndex:int=-1):Boolean {
			return true;
		}
		public function discardCard(card:*, playerIndex:int = 0, handIndex:int=0):Boolean {
			return true;
		}
		
		// can card be selected for either discarding or playing?
		public function canSelectCard(playerIndex:int, handIndex:int):Boolean {
			return true;
		}
		
		
		public function getGameBuilder():GameBuilder {
			return gameBuilder;
		}
		
	}

}