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
			
			var c:SaboteurActionCard;
			var value:uint;
			
			// Path cards
			// crystals
			value = pathUtil.getValue( SaboteurPathUtil.WEST, 0, SaboteurPathUtil.SABO2_CRYSTAL);
			pathCards.push(value);
			value = pathUtil.getValue( SaboteurPathUtil.SOUTH, 0, SaboteurPathUtil.SABO2_CRYSTAL);
			pathCards.push(value);
			value = pathUtil.getValue( SaboteurPathUtil.EAST | SaboteurPathUtil.WEST | SaboteurPathUtil.SOUTH, SaboteurPathUtil.ARC_HORIZONTAL, SaboteurPathUtil.SABO2_CRYSTAL);
			pathCards.push(value);
			value = pathUtil.getValue( SaboteurPathUtil.ALL_SIDES, SaboteurPathUtil.ARC_HORIZONTAL, SaboteurPathUtil.SABO2_CRYSTAL);
			pathCards.push(value);
			value = pathUtil.getValue( SaboteurPathUtil.NORTH | SaboteurPathUtil.SOUTH | SaboteurPathUtil.EAST, SaboteurPathUtil.ARC_VERTICAL, SaboteurPathUtil.SABO2_CRYSTAL);
			pathCards.push(value);
			
			value = pathUtil.getValue( SaboteurPathUtil.ALL_SIDES, SaboteurPathUtil.ARC_VERTICAL, SaboteurPathUtil.SABO2_CRYSTAL);
			pathCards.push(value);
			value = pathUtil.getValue( SaboteurPathUtil.ALL_SIDES, SaboteurPathUtil.ARC_VERTICAL|SaboteurPathUtil.ARC_HORIZONTAL, SaboteurPathUtil.SABO2_CRYSTAL);
			pathCards.push(value);
			value = pathUtil.getValue( SaboteurPathUtil.WEST|SaboteurPathUtil.EAST, SaboteurPathUtil.ARC_HORIZONTAL, SaboteurPathUtil.SABO2_CRYSTAL);
			pathCards.push(value);
			value = pathUtil.getValue( SaboteurPathUtil.WEST|SaboteurPathUtil.EAST|SaboteurPathUtil.SOUTH, SaboteurPathUtil.ARC_HORIZONTAL, SaboteurPathUtil.SABO2_CRYSTAL);
			pathCards.push(value, value);
			
			// blue door
			value = pathUtil.getValue( SaboteurPathUtil.WEST|SaboteurPathUtil.EAST, SaboteurPathUtil.ARC_HORIZONTAL, SaboteurPathUtil.SABO2_DOOR_BLUE);
			pathCards.push(value);
			value = pathUtil.getValue( SaboteurPathUtil.WEST|SaboteurPathUtil.SOUTH, SaboteurPathUtil.ARC_SOUTH_WEST, SaboteurPathUtil.SABO2_DOOR_BLUE);
			pathCards.push(value);
			value = pathUtil.getValue( SaboteurPathUtil.NORTH|SaboteurPathUtil.SOUTH, SaboteurPathUtil.ARC_VERTICAL, SaboteurPathUtil.SABO2_DOOR_BLUE);
			pathCards.push(value);
			
			// green door
			value = pathUtil.getValue( SaboteurPathUtil.WEST|SaboteurPathUtil.EAST, SaboteurPathUtil.ARC_HORIZONTAL, SaboteurPathUtil.SABO2_DOOR_GREEN);
			pathCards.push(value);
			value = pathUtil.getValue( SaboteurPathUtil.EAST|SaboteurPathUtil.SOUTH, SaboteurPathUtil.ARC_SOUTH_EAST, SaboteurPathUtil.SABO2_DOOR_GREEN);
			pathCards.push(value);  // weird assymetrical appraoch here..not congruent flip with blue counterpart. Ask game-designer why???
			value = pathUtil.getValue( SaboteurPathUtil.NORTH|SaboteurPathUtil.SOUTH|SaboteurPathUtil.EAST, SaboteurPathUtil.ARC_VERTICAL, SaboteurPathUtil.SABO2_DOOR_GREEN);
			pathCards.push(value);  // weird assymetrical appraoch here...excess bit on east-side. Ask game-designer why???
			
			// ladders
			value = pathUtil.getValue( SaboteurPathUtil.WEST|SaboteurPathUtil.NORTH, SaboteurPathUtil.ARC_NORTH_WEST, SaboteurPathUtil.SABO2_LADDER);
			pathCards.push(value);
			value = pathUtil.getValue( SaboteurPathUtil.SOUTH, 0, SaboteurPathUtil.SABO2_LADDER);
			pathCards.push(value);
			value = pathUtil.getValue( SaboteurPathUtil.NORTH|SaboteurPathUtil.EAST, SaboteurPathUtil.ARC_NORTH_EAST, SaboteurPathUtil.SABO2_LADDER);
			pathCards.push(value);
			value = pathUtil.getValue( SaboteurPathUtil.EAST, 0, SaboteurPathUtil.SABO2_LADDER);
			pathCards.push(value);
			
			// tunnels
			value = pathUtil.getValue( SaboteurPathUtil.ALL_SIDES, SaboteurPathUtil.ARC_VERTICAL|SaboteurPathUtil.ARC_HORIZONTAL, SaboteurPathUtil.SABO2_LADDER);
			pathCards.push(value, value);
			
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