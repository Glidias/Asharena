package saboteur.rules 
{
	import ash.signals.Signal0;
	import ash.signals.Signal1;
	import ash.signals.Signal2;
	import de.polygonal.ds.GraphNode;
	import haxe.Log;
	import saboteur.util.GameBuilder;
	import saboteur.util.SaboteurActionCard;
	import saboteur.util.SaboteurDeck;
	import saboteur.util.SaboteurPathUtil;
	import saboteur.util.SaboteurPlayer;
	import util.geom.Vec3;
	/**
	 * A solitaire variant of Saboteur
	 * @author Glenn Ko
	 */
	public class AloneInTheMines extends BaseRules
	{
		private var _horizDir:int;

		public var middleCardFuther:Boolean;
		
		public var gameEnded:Boolean;
		public var onGameEnded:Signal0;
		public var onHandChange:Signal1;
		public var onPositionChange:Signal2 = new Signal2();
		
		public var deck:SaboteurDeck;  // the main deck of usable cards
		
		// current solo player's position
		public var playerEast:int;
		public var playerSouth:int;
		private var _lastES:Vec3; // last pivot position
		
		//public var player:SaboteurPlayer;  // not needed atm since this is singleplayer rules
		public var playerCards:Array;  // cards in player's hands
		public var maxHandCardsAllowed:int;  // max amount of cards allowed in player's hands
		
		public var MOVEMENT_ALLOWANCE:int;  // movement allowance
		public var pathCardsOnly:Boolean = false;
		
		
	
		
		public function AloneInTheMines(reverseDirection:Boolean=false, middleCardFuther:Boolean=false) 
		{
			super();
			this.middleCardFuther = middleCardFuther;
			this.MOVEMENT_ALLOWANCE = 3;
			_horizDir = reverseDirection ? -1 : 0;
			_lastES = new Vec3();
			gameEnded = false;
		}
		
		override public function setup():void {
			
			onHandChange = new Signal1();
			onGameEnded = new Signal0();
			//lonePlayer = SaboteurPlayer.create(SaboteurPlayer.GREEN_DWARF);
			
			// setup  map and starting player location
			playerEast  = 0;
			playerSouth = 0;
			gameBuilder.buildStartNodeAt(0, 0, pathUtil.getValue(SaboteurPathUtil.ALL_SIDES, SaboteurPathUtil.ARC_HORIZONTAL | SaboteurPathUtil.ARC_VERTICAL ) ); 
	
			// todo: refer to saboteur deck for proper turning layout
			gameBuilder.buildAt(_horizDir * 8, -2, pathUtil.getValue(SaboteurPathUtil.ALL_SIDES, SaboteurPathUtil.ARC_HORIZONTAL | SaboteurPathUtil.ARC_VERTICAL ), false, false);
			gameBuilder.buildAt(_horizDir * (middleCardFuther ? 8+1 : 8), 0, pathUtil.getValue(SaboteurPathUtil.ALL_SIDES, SaboteurPathUtil.ARC_HORIZONTAL | SaboteurPathUtil.ARC_VERTICAL ), false, false);
			gameBuilder.buildAt(_horizDir * 8, 2, pathUtil.getValue(SaboteurPathUtil.ALL_SIDES, SaboteurPathUtil.ARC_HORIZONTAL | SaboteurPathUtil.ARC_VERTICAL ), false, false);

		
			// setup deck and draw out 3 cards for player
			deck = new SaboteurDeck();
			deck.setupPlayableDeck(true, !pathCardsOnly, true);
			playerCards = [];
		}
		
		
		
		override public function getPlayablePathCardLocations(value:uint):Array  {
			var locations:Array = super.getPlayablePathCardLocations(value);
			// TODO: check if the locations are in range for expenditure..., if not splice em
			
			return locations;
		}
		
		
		public function setPlayerPosition(east:int, south:int):void {
		
			_validatePlayerPos(east, south);
			playerEast = east;
			playerSouth = south;
		//	Log.trace(east + ", " + south);
		}
		
		
		private function _validatePlayerPos(ge:int, gs:int):void 
		{

			var rootNode:GraphNode = gameBuilder.pathGraph.getNode(ge, gs);
			gameBuilder.pathGraph.graph.clearMarks();
			
			//hudAssets.txt_chatChannel.appendMessage("moved:"+Math.random());
			
			if (rootNode != null) {
				var startNode:GraphNode = gameBuilder.pathGraph.getNode(_lastES.x, _lastES.y);
				if (startNode != null) {
						_foundWithinRange = false;
					gameBuilder.pathGraph.graph.DLBFS(MOVEMENT_ALLOWANCE, false, rootNode, checkIfNodeIsWithinRange, startNode); 
					if (!_foundWithinRange) {
						_lastES.x = playerEast;
						_lastES.y = playerSouth;
						onPositionChange.dispatch(_lastES.x, _lastES.y);
					}
				}
			}
		}
		
		private var _foundWithinRange:Boolean;
		private function checkIfNodeIsWithinRange(node:GraphNode, preflight:Boolean, data:Object=null):Boolean 
		{
			if (node === data) {
				_foundWithinRange = true;
				return false;
			}
			return true;
		}
		
		private function _updateLastPlayerPos():void 
		{
			_lastES.x = playerEast;
			_lastES.y = playerSouth;
			
			onPositionChange.dispatch(_lastES.x, _lastES.y);
		}

		override public function playPathCard(east:int, south:int, value:uint, playerIndex:int = 0):Boolean {
			var result:Boolean = super.playPathCard(east, south, value, playerIndex);
			
			// TODO: check range and see if can reach target destination given amount of cards in deck
			//gameBuilder.pathGraph.getNode(east, south);
			
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
			return SaboteurDeck.cardIsAction( playerCards[index] )  ? actionCardIsPlayable(playerCards[index]) : pathCardIsPlayable(playerCards[index]);
		}
		
		public function forceUpdateToCurrentPos():void 
		{
			_updateLastPlayerPos();
		}
		
		
		
		
		
				
		private function _refillHand():void {
			// TODO:

			var i:int = playerCards.length - maxHandCardsAllowed;
			
			while (--i > -1) {
				if (playerCards.length == 0) break;
				var card:* = playerCards.pop();
				if ( SaboteurDeck.cardIsAction(card) )  {
				//	if (playerCards.length
				}
				else {
					playerCards.push(card);
				}
			}
			
			onHandChange.dispatch(playerCards);
		}
		
		public function get lastES():Vec3 
		{
			return _lastES;
		}
		
	}

}