package saboteur.rules 
{
	import ash.signals.Signal0;
	import ash.signals.Signal1;
	import ash.signals.Signal2;
	import de.polygonal.ds.GraphNode;
	import haxe.Log;
	import saboteur.models.PlayerInventory;
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
		public var onHandChange:Signal2;
		public var onPositionChange:Signal2 = new Signal2();
		
		public var deck:SaboteurDeck;  // the main deck of usable cards
		
		// current solo player's position
		public var playerEast:int;
		public var playerSouth:int;
		private var _lastES:Vec3; // last pivot position
		
		//public var player:SaboteurPlayer;  // not needed atm since this is singleplayer rules
		private var playerCards:Array;  // cards in player's hands
		private var _playerInventory:PlayerInventory;
		public var maxHandCardsAllowed:int;  // max amount of cards allowed in player's hands
		
		public var MOVEMENT_ALLOWANCE:int;  // movement allowance
		public var pathCardsOnly:Boolean = false;
		
		public static const DIST:Number = 2;
		
	
		
		public function AloneInTheMines(reverseDirection:Boolean=false, middleCardFuther:Boolean=false) 
		{
			super();
			this.middleCardFuther = middleCardFuther;
			this.MOVEMENT_ALLOWANCE = 3;
			maxHandCardsAllowed = 3;
			_playerInventory = new PlayerInventory();
			_playerInventory.onEquipedSlotChange.add(setDefaultHandIndex);
			_horizDir = reverseDirection ? -1 : 0;
			_lastES = new Vec3();
			gameEnded = false;
			onHandChange = new Signal2();

			onGameEnded = new Signal0();
			onPlayBuildSuccess.add(onPlayBuildSuccessful);
		}
		
		private function onPlayBuildSuccessful(east:int, south:int, value:int, playerIndex:int=0, handIndex:int=-1):void {
			
			notifyPlayBuildSuccess();
		}
		
		public function notifyPlayBuildSuccess():void 
		{
			_refillHand();
			_updateLastPlayerPos();
		}
		
		override public function setup():void {
			
			
			//lonePlayer = SaboteurPlayer.create(SaboteurPlayer.GREEN_DWARF);
			
			// setup  map and starting player location
			playerEast  = 0;
			playerSouth = 0;
			gameBuilder.buildStartNodeAt(0, 0, pathUtil.getValue(SaboteurPathUtil.ALL_SIDES, SaboteurPathUtil.ARC_HORIZONTAL | SaboteurPathUtil.ARC_VERTICAL ) ); 
	
			var dist:int = DIST;
			// todo: refer to saboteur deck for proper turning layout
			gameBuilder.buildAt(_horizDir * dist, -2, pathUtil.getValue(SaboteurPathUtil.ALL_SIDES, SaboteurPathUtil.ARC_HORIZONTAL | SaboteurPathUtil.ARC_VERTICAL ), false, false);
			gameBuilder.buildAt(_horizDir * (middleCardFuther ? dist+1 : dist), 0, pathUtil.getValue(SaboteurPathUtil.ALL_SIDES, SaboteurPathUtil.ARC_HORIZONTAL | SaboteurPathUtil.ARC_VERTICAL ), false, false);
			gameBuilder.buildAt(_horizDir * dist, 2, pathUtil.getValue(SaboteurPathUtil.ALL_SIDES, SaboteurPathUtil.ARC_HORIZONTAL | SaboteurPathUtil.ARC_VERTICAL ), false, false);

		
			// setup deck and draw out cards for player
			deck = new SaboteurDeck();
			deck.setupPlayableDeck(true, !pathCardsOnly, true);
			playerCards = [];
			
			_refillHand(true);
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
						deck.drawSingle();
					//	Log.trace(deck.playableCards.length + " cards left");
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
		
		public var defaultHandIndex:int = -1;
		public function setDefaultHandIndex(val:int):void {
			defaultHandIndex = val;
		}
		

		override public function playPathCard(east:int, south:int, value:uint, playerIndex:int = 0, handIndex:int=-1):Boolean {  // todo: relink to this  method for Ibuildattempter
			var result:Boolean = super.playPathCard(east, south, value, playerIndex);
			
			if (handIndex < 0) handIndex = defaultHandIndex;
			
			// TODO: check range and see if can reach target destination given amount of cards in deck
			//gameBuilder.pathGraph.getNode(east, south);
			
			if (result) {
			
				// remove card from player hand if needed
				if (handIndex >= 0 && handIndex < playerCards.length) {
					playerCards.splice(handIndex, 1);
				}
				
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
		
		override public function playActionCard(card:SaboteurActionCard, playerIndex:int = 0, toPlayerIndex:int = 0, fromHandIndex:int=-1):Boolean {
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
		
		override public function discardCard(card:*, playerIndex:int = 0, handIndex:int=0):Boolean {
			if (!discardingIsAllowed()) {
				return false;
			}
			_updateLastPlayerPos();
			_refillHand();
			return true;
		}
		
		
		protected var _endPointsCollected:Array = [];
		protected var _endPointsCollectCount:int = 0;
		
		public function getPathCardValueLocations(value:uint):int  {
			// TODO: range limit based off remaining deck size
			var count:int = gameBuilder.getPlayablePathCardLocationsByGraph(_endPointsCollected, value, GameBuilder.ALLOW_FLIP);
			_endPointsCollectCount = count;
			return count;
		}
		
		public function pathCardIsPlayable(value:uint):Boolean {
			// TODO: range limit based off remaining deck size
			var count:int = gameBuilder.getPlayablePathCardLocationsByGraph(_endPointsCollected, value, GameBuilder.ALLOW_FLIP | GameBuilder.EARLY_OUT);
			_endPointsCollectCount = count;
			return count !=0;
		}
		
		public function actionCardIsPlayable(card:SaboteurActionCard):Boolean {
			// this will always return true, because repair cards act as auto-blockers when you draw a sabotage card...
			return true;
		}
		public function getEndPointsCollected():Array 
		{
			return _endPointsCollected.slice(0, _endPointsCollectCount);
		}
		
		public function cardIsPlayableAt(index:int):Boolean {
			if (playerCards[index] == null) return false;
			return SaboteurDeck.cardIsAction( playerCards[index] )  ? actionCardIsPlayable(playerCards[index]) : pathCardIsPlayable(playerCards[index]);
		}
		
		public function forceUpdateToCurrentPos():void 
		{
			_updateLastPlayerPos();
		}
		
		override public function canSelectCard(playerIndex:int, handIndex:int):Boolean  {
			//throw new Error(handIndex);
			return (_playerInventory.usabilityMask & (1<<handIndex))!=0 || _playerInventory.usabilityMask  == 0;
		}
				
		private function _refillHand(firstDraw:Boolean=false):void {
		

			var i:int = maxHandCardsAllowed - playerCards.length;
			
			while (--i > -1) {
				if (deck.playableCards.length == 0) break;
				var card:* = deck.drawSingle();
				if ( SaboteurDeck.cardIsAction(card) )  {
					// TODO:
					//	if (playerCards.length
				}
				else {

				//	if (pathUtil.getIndexByValue(card) < 0) throw new Error("Invalid path card drawn:"+card);
					playerCards.push(card);
				}
			}
			var usabilityMask:uint = 0;
			var len:int = playerCards.length;
			for (i=0 ; i < len; i++) {
				usabilityMask |= cardIsPlayableAt(i) ? (1 << i) : 0;
			}
			_playerInventory.usabilityMask = usabilityMask;
			onHandChange.dispatch(playerCards, usabilityMask);
			
			//Log.trace(deck.playableCards.length + " cards left");
			
		}
		
		public function get lastES():Vec3 
		{
			return _lastES;
		}
		
		public function get playerInventory():PlayerInventory 
		{
			return _playerInventory;
		}
		
		public function set playerInventory(value:PlayerInventory):void 
		{
			_playerInventory = value;
		}
		
	
		
	}

}