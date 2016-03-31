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
		protected var builder:GameBuilder;
		protected var pathUtil:SaboteurPathUtil;
		public var onPlayBuildFailed:SignalAny;
		public var onPlayBuildSuccess:SignalAny;
		
		
		public function BaseRules() 
		{
			builder = new GameBuilder();
			onPlayBuildFailed = new SignalAny();
			onPlayBuildSuccess = new SignalAny();
			pathUtil = SaboteurPathUtil.getInstance();
		}
		
		public function setup():void {  // overwrite this for custom implementation
			
		}
		
		public function playPathCard(east:int, south:int, value:uint, playerIndex:int = 0):Boolean {
			if ( builder.attemptBuild(east, south, value) ) {
				onPlayBuildSuccess.dispatch(east, south, value, playerIndex);
				return true;
			}
			else {
				onPlayBuildFailed.dispatch(east, south, value, playerIndex );
				return false;
			}
		}
		
		public function getPlayablePathCardLocations(value:uint):Array  {
			var locations:Array = [];
			// TODO:
			return locations;
		}
		
		public function playActionCard(card:SaboteurActionCard, playerIndex:int = 0, toPlayerIndex:int = 0):Boolean {
			return true;
		}
		
		
		
		public function getBuilder():GameBuilder {
			return builder;
		}
		
	}

}