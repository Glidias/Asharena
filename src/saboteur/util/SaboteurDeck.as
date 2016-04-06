package saboteur.util 
{
	/**
	 * The Saboteur-1 playable deck of cards
	 * @author Glenn Ko
	 */
	public class SaboteurDeck 
	{
		protected var pathCards:Array = [];
		protected var actionCards:Array = [];
		public var playableCards:Array;
		protected var pathUtil:SaboteurPathUtil;
		
		public static const ACTION_MAP:String = "actionMap";
		public static const ACTION_COLLAPSE:String = "actionCollapse";
		public static const ACTION_BREAK:String = "actionBreak";
		public static const ACTION_REPAIR:String = "actionRepair";
		
		public static const FLAG_PICKAXE:int = (1 << 0);
		public static const FLAG_LAMP:int = (1 << 1);
		public static const FLAG_TROLLEY:int = (1 << 2);
		
		
	
		public function SaboteurDeck() 
		{
			var value:uint;
			pathUtil = SaboteurPathUtil.getInstance();
			
			// Set up path cards
			
			// turn single #1 cohesive corner
			value = pathUtil.getValue( SaboteurPathUtil.SOUTH | SaboteurPathUtil.EAST, SaboteurPathUtil.ARC_SOUTH_EAST);
			pathCards.push(value, value);
			value = pathUtil.getValue(SaboteurPathUtil.NORTH | SaboteurPathUtil.WEST, SaboteurPathUtil.ARC_NORTH_WEST); // pathUtil.getFlipValue(value);
			pathCards.push(value, value);
			
			// turn single #2 cohesive corner
			value = pathUtil.getValue( SaboteurPathUtil.SOUTH | SaboteurPathUtil.WEST, SaboteurPathUtil.ARC_SOUTH_WEST);
			pathCards.push(value, value);
			value = pathUtil.getValue(SaboteurPathUtil.NORTH | SaboteurPathUtil.EAST, SaboteurPathUtil.ARC_NORTH_EAST);   // flip congruent
			pathCards.push(value, value, value );  
			
			// single dead end along horizontal east/west
			value = pathUtil.getValue(SaboteurPathUtil.WEST, 0);
			pathCards.push(value);
			
			// single dead end along vertical south to north
			value = pathUtil.getValue(SaboteurPathUtil.SOUTH, 0);
			pathCards.push(value);
			
			// dead end in middle with all sides
			value = pathUtil.getValue(SaboteurPathUtil.ALL_SIDES, 0);
			pathCards.push(value);
			
			// dead end in middle with 3 sides
			value = pathUtil.getValue(SaboteurPathUtil.NORTH | SaboteurPathUtil.SOUTH | SaboteurPathUtil.WEST, 0); // along vert stretch
			pathCards.push(value);
			value = pathUtil.getValue(SaboteurPathUtil.NORTH | SaboteurPathUtil.WEST | SaboteurPathUtil.EAST, 0); // along horizontal stretch
			pathCards.push(value);
			
			// dead end in middle with 2 sides
			// along turning
			value = pathUtil.getValue(SaboteurPathUtil.SOUTH | SaboteurPathUtil.EAST, 0);
			pathCards.push(value);
			value = pathUtil.getValue(SaboteurPathUtil.SOUTH | SaboteurPathUtil.WEST, 0);
			pathCards.push(value);
			// along straight
			value = pathUtil.getValue(SaboteurPathUtil.NORTH | SaboteurPathUtil.SOUTH, 0);
			pathCards.push(value);
			value = pathUtil.getValue(SaboteurPathUtil.WEST | SaboteurPathUtil.EAST, 0);
			pathCards.push(value);
			
			// straight horizontal
			value = pathUtil.getValue(SaboteurPathUtil.WEST | SaboteurPathUtil.EAST, SaboteurPathUtil.ARC_HORIZONTAL);
			pathCards.push(value, value, value);
			// straight vertical
			value = pathUtil.getValue(SaboteurPathUtil.NORTH | SaboteurPathUtil.SOUTH, SaboteurPathUtil.ARC_VERTICAL);
			pathCards.push(value, value, value, value);  // assymetry here with 4 cards instead of 3, this favours saboteurs if game-map is played horizontally as per standard
			
			// T-junction along horizontal
			value = pathUtil.getValue(SaboteurPathUtil.NORTH | SaboteurPathUtil.SOUTH | SaboteurPathUtil.EAST, SaboteurPathUtil.ARC_NORTH_EAST | SaboteurPathUtil.ARC_SOUTH_EAST);
			pathCards.push(value, value, value);

			value = pathUtil.getValue(SaboteurPathUtil.NORTH | SaboteurPathUtil.SOUTH | SaboteurPathUtil.WEST, SaboteurPathUtil.ARC_SOUTH_WEST | SaboteurPathUtil.ARC_NORTH_WEST); // flip congruent value
			pathCards.push(value, value);  
			
		
			
			// T-junction along vertical
			value = pathUtil.getValue(SaboteurPathUtil.WEST | SaboteurPathUtil.EAST | SaboteurPathUtil.NORTH, SaboteurPathUtil.ARC_NORTH_EAST | SaboteurPathUtil.ARC_NORTH_WEST);
			pathCards.push(value,value,value,value);
			value = pathUtil.getValue(SaboteurPathUtil.WEST | SaboteurPathUtil.EAST | SaboteurPathUtil.SOUTH,  SaboteurPathUtil.ARC_SOUTH_EAST | SaboteurPathUtil.ARC_SOUTH_WEST); // flip congruent value
			pathCards.push(value);  // the flip congruent, why does the deck I use has only 1 of this but the above has 4? Why not 3/2 which is more balanced? Ask the game designer again...lol!
			
			// ...and the 5 crosses
			value = pathUtil.getValue(SaboteurPathUtil.ALL_SIDES, SaboteurPathUtil.ARC_VERTICAL | SaboteurPathUtil.ARC_HORIZONTAL);
			pathCards.push(value, value, value, value, value);
			
			
			
			// ensure 40 path cards total....
			//throw new Error(pathCards.length);
			var c:SaboteurActionCard;
			
			actionCards.push( c = SaboteurActionCard.create(ACTION_MAP) );
			actionCards.push( c.clone(), c.clone(), c.clone(), c.clone(), c.clone() );
			
			actionCards.push( c = SaboteurActionCard.create(ACTION_COLLAPSE) );
			actionCards.push( c.clone(), c.clone() );
			
			actionCards.push( c = SaboteurActionCard.create(ACTION_BREAK, FLAG_LAMP) );
			actionCards.push( c.clone(), c.clone() );
			actionCards.push( c = SaboteurActionCard.create(ACTION_BREAK, FLAG_TROLLEY) );
			actionCards.push( c.clone(), c.clone() );
			actionCards.push( c = SaboteurActionCard.create(ACTION_BREAK, FLAG_PICKAXE) );
			actionCards.push( c.clone(), c.clone() );
			
			actionCards.push( c = SaboteurActionCard.create(ACTION_REPAIR, FLAG_PICKAXE | FLAG_LAMP) );
			actionCards.push( c = SaboteurActionCard.create(ACTION_REPAIR, FLAG_PICKAXE | FLAG_TROLLEY) );
			actionCards.push( c = SaboteurActionCard.create(ACTION_REPAIR, FLAG_LAMP | FLAG_TROLLEY) );
			
			actionCards.push( c = SaboteurActionCard.create(ACTION_REPAIR, FLAG_PICKAXE) );
			actionCards.push( c.clone() );
			actionCards.push( c = SaboteurActionCard.create(ACTION_REPAIR, FLAG_LAMP) );
			actionCards.push( c.clone() );
			actionCards.push( c = SaboteurActionCard.create(ACTION_REPAIR, FLAG_TROLLEY) );
			actionCards.push( c.clone() );
			
			// ensure 27 action cards total....
			//throw new Error(actionCards.length);
			
		//	validatePathCards();
			

		}
		
		public function validatePathCards():Boolean {
			for (var i:int = 0; i < pathCards.length; i++) {
				if ( pathUtil.getIndexByValue( pathCards[i] ) < 0)  {
					throw new Error("invalid:" + pathCards[i] + ", @" + i);
					return false;
				}
			}
			return true;
		}
		
		public static function cardIsAction(card:*):Boolean {
			return card is SaboteurActionCard;
		}
		/*
		public static function cardIsPath(card:*):Boolean {
			return !(card is SaboteurActionCard);
		}
		*/
		
		public function setupPlayableDeck(includePathCards:Boolean = true, includeActionCards:Boolean = true, doShuffle:Boolean=true):SaboteurDeck {
			playableCards = [];
			if (includePathCards) playableCards = playableCards.concat(pathCards);
			if (includeActionCards) playableCards = playableCards.concat(actionCards);
			
			if (doShuffle) shuffle();
		
			return this;
		}
		
		/*  // if needed later for custom games...
		public function setupCustomDeck(pathCards:Boolean = true, actionCards:Boolean = true, ignoreActions:Object=null, doShuffle:Boolean=true):SaboteurDeck {
			playableCards = [];
			if (pathCards) playableCards = playableCards.concat(pathCards);
			if (actionCards) playableCards = playableCards.concat(actionCards);
			
			if (doShuffle) shuffle();
			return this;
		}
		*/
		
		public function drawSingle():* {
			return playableCards.pop();
		}
		
		public function drawMultiple(amount:int):Array {
			var arr:Array = [];
			var i:int = amount;
			while (--i > -1) {
				arr.push(playableCards.pop());
			}
			return arr;
		}
		
		
		public function shuffle():void {
			if (playableCards == null) throw new Error("No playable deck yet. WHy not setupPlayableDeck() first!?");
			arrayShuffleFisherYates(playableCards);
		}
		
		public static function arrayShuffleFisherYates(array:Array):Array
		{
			var m:int = array.length;
			var i:int;
			var temp:*;
		 
			// while there are still elements to shuffle
			while (m)
			{
				i = int(Math.random() * m--);
		 
				// swap it with the current element
				temp = array[m];
				array[m] = array[i];
				array[i] = temp;
			}
		 
			return array;
		}
		
		
		
	}

}