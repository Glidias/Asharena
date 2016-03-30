package saboteur.rules 
{
	import ash.signals.Signal0;
	import saboteur.util.GameBuilder;
	import saboteur.util.SaboteurActionCard;
	import saboteur.util.SaboteurDeck;
	import saboteur.util.SaboteurPathUtil;
	import saboteur.util.SaboteurPlayer;
	/**
	 * A solitaire variant of Saboteur
	 * @author Glenn Ko
	 */
	public class AloneInTheMines extends BaseRules
	{
		private var _horizDir:int;
		public var reverseDirection:Boolean;
		public var middleCardFuther:Boolean;
		
		public var gameEnded:Boolean;
		public var onGameEnded:Signal0;
		public var onHandChange:Signal0;
		
		
		public var deck:SaboteurDeck;
		
		public var playerEast:int;
		public var playerSouth:int;
		public var lastPlayerEast:int;
		public var lastPlayerSouth:int;
		//public var player:SaboteurPlayer;
		
		public var playerCards:Array;
		
		public var MOVEMENT_ALLOWANCE:int;
		
		public function AloneInTheMines(reverseDirection:Boolean=false, middleCardFuther:Boolean=false) 
		{
			super();
			this.middleCardFuther = middleCardFuther;
			this.MOVEMENT_ALLOWANCE = 3;
			this.reverseDirection = reverseDirection;
			gameEnded = false;
		}
		
		override public function begin():void {
			super.begin();
			onHandChange = new Signal0();
			onGameEnded = new Signal0();
			//lonePlayer = SaboteurPlayer.create(SaboteurPlayer.GREEN_DWARF);
			
			// setup  map and starting player location
			playerEast = lastPlayerEast = 0;
			playerSouth = lastPlayerSouth= 0;
			builder.buildStartNodeAt(0, 0, pathUtil.getValue(SaboteurPathUtil.ALL_SIDES, SaboteurPathUtil.ARC_HORIZONTAL | SaboteurPathUtil.ARC_VERTICAL ) ); 
	
			// todo: refer to saboteur deck for proper turning layout
			builder.buildAt(_horizDir * 8, -2, pathUtil.getValue(SaboteurPathUtil.ALL_SIDES, SaboteurPathUtil.ARC_HORIZONTAL | SaboteurPathUtil.ARC_VERTICAL ), false, false);
			builder.buildAt(_horizDir * (middleCardFuther ? 8+1 : 8), 0, pathUtil.getValue(SaboteurPathUtil.ALL_SIDES, SaboteurPathUtil.ARC_HORIZONTAL | SaboteurPathUtil.ARC_VERTICAL ), false, false);
			builder.buildAt(_horizDir * 8, 2, pathUtil.getValue(SaboteurPathUtil.ALL_SIDES, SaboteurPathUtil.ARC_HORIZONTAL | SaboteurPathUtil.ARC_VERTICAL ), false, false);
			_horizDir = reverseDirection ? -1 : 1;
		
			// setup deck and draw out 3 cards for player
			deck = new SaboteurDeck();
			deck.setupPlayableDeck(true, true, true);
			playerCards = [];
		}
		
		
		
		override public function getPlayablePathCardLocations(value:uint):Array  {
			var locations:Array = super.getPlayablePathCardLocations(value);
			// TODO: check if the locations are in range for expenditure..., if not splice em
			
			return locations;
		}
		
		
		public function setPlayerPosition(east:int, south:int):void {
			playerEast = east;
			playerSouth = south;
			_validatePlayerPos();
		}
		
		
		private function _validatePlayerPos():void 
		{
			// TODO: if outta range...
			// _updateLastPlayerPos()
		}
		
		private function _updateLastPlayerPos():void 
		{
			lastPlayerEast = playerEast;
			lastPlayerSouth = playerSouth;
		}

		override public function playPathCard(east:int, south:int, value:uint, playerIndex:int = 0):Boolean {
			var result:Boolean = super.playPathCard(east, south, value, playerIndex);
			
			// TODO: check range and see if can reach target destination given amount of cards in deck
			//builder.pathGraph.getNode(east, south);
			
			if (result) {
				// check if reach into openable treasure spot
				// check if should end game or not if reach gold..
				
				// deduct sacrificed amount of cards from deck
		
				// if game not yet ended. draw from deck to refill deck!
				_updateLastPlayerPos();
				_refillHand();
			}
			else {
				
			}
			
			return result;
		}
		
		private function _endGame():void {
			gameEnded = true;
			
			// tally scores and stuffz
			
			onGameEnded.dispatch();
		}
		
		override public function playActionCard(card:SaboteurActionCard, playerIndex:int = 0, toPlayerIndex:int = 0):Boolean {
			if (!actionCardIsPlayable(card)) {
				return false;
			}
			return true;
		}
		
		public function discardingIsAllowed():Boolean {
			// TODO: check deck to see if can play any card, if so, return false
			var i:int = playerCards.length;
			while (--i > -1) {
				if (cardIsPlayableAt(i)) {
					return false;
				}
			}
			return true;
		}
		
		public function discardCard(card:*, playerIndex:int = 0):Boolean {
			if (!discardingIsAllowed()) {
				return false;
			}
			_updateLastPlayerPos();
			_refillHand();
			return true;
		}
		
		public function pathCardIsPlayable(value:uint):Boolean {
			var arr:Array = getPlayablePathCardLocations(value);
			return arr.length > 0;
		}
		
		public function actionCardIsPlayable(card:SaboteurActionCard):Boolean {
			// this will always return true, because repair cards act as auto-blockers when you draw a sabotage card...
			return true;
		}
		
		public function cardIsPlayableAt(index:int):Boolean {
			if (playerCards[index] == null) return false;
			return playerCards[index] is SaboteurActionCard ? actionCardIsPlayable(playerCards[index]) : pathCardIsPlayable(playerCards[index]);
		}
		
		
		
		
		
				
		private function _refillHand():void {
			// TODO:
			
			//onHandChange.dispatch();
		}
		
	}

}