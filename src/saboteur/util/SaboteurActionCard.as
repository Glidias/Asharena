package saboteur.util 
{
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class SaboteurActionCard 
	{
		public var action:String;
		public var flags:uint;

		public function SaboteurActionCard() 
		{
			
		}
		public static function create(action:String, flags:uint=0):SaboteurActionCard {
			var card:SaboteurActionCard = new SaboteurActionCard();
			card.action = action;
			card.flags = flags;
			return card;
		}
		
		public function clone():SaboteurActionCard {
			var card:SaboteurActionCard = new SaboteurActionCard();
			card.action = action;
			card.flags = flags;
			return card;
		}
		
		public function toString():String {
			return "[ActionCard:" + action +":"+flags+"]";
		}
		
	}

}