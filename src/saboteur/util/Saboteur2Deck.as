package saboteur.util 
{
	/**
	 * The Saboteur-2 playable deck of cards
	 * @author Glenn Ko
	 */
	public class Saboteur2Deck extends SaboteurDeck
	{
		public static const ACTION_THEFT:String = "actionTheft";
		public static const ACTION_SWITCH_TOOLS:String = "actionSwitchTools";  // exchange entire hand
		public static const ACTION_STOP_THEFT:String = "actionStopTheft";
		public static const ACTION_SEND_TO_JAIL:String = "actionSendToJail";  //rmb, jailed people don't get gold, and can play action cards only but not paths.
		public static const ACTION_FREE_FROM_JAIL:String = "actionFreeFromJail";
		public static const ACTION_HAT_SWAP:String = "actionHatSwap";  // switch role of some dwarf to another one in the remaining role-deck. (disccarded role is still kept secret) 
		public static const ACTION_JOB_AUDIT:String = "actionJobAudit";    // peek into other player's role 
		
		public function Saboteur2Deck() 
		{
			super();
			
			
			// todo later; pathcards for saboteur2 deck
			
			// Action cards
			actionCards.push( c = SaboteurActionCard.create(ACTION_THEFT) );
			actionCards.push( c.clone(), c.clone(), c.clone() );
			
			actionCards.push( c = SaboteurActionCard.create(ACTION_SWITCH_TOOLS) );
			actionCards.push( c.clone() );
			
				actionCards.push( c = SaboteurActionCard.create(ACTION_STOP_THEFT) );
			actionCards.push( c.clone(), c.clone() );
			
			actionCards.push( c = SaboteurActionCard.create(ACTION_SEND_TO_JAIL) );
			actionCards.push( c.clone(), c.clone() );
			
			actionCards.push( c = SaboteurActionCard.create(ACTION_SEND_TO_JAIL) );
			actionCards.push( c.clone(), c.clone(), c.clone() );
			
			actionCards.push( c = SaboteurActionCard.create(ACTION_HAT_SWAP) );
			actionCards.push( c.clone() );
			
			actionCards.push( c = SaboteurActionCard.create(ACTION_JOB_AUDIT) );
			actionCards.push( c.clone() );
			
			
			
	
			
		}
		
	}

}