package saboteur.util 
{
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class SaboteurPlayer 
	{
		public var role:String;
		public var name:String;
		public var index:int;
		
		public var brokenFlags:int;
		
		public static const GREEN_DWARF:String = "greenDwarf";
		
		public function SaboteurPlayer() 
		{
			
		}
		
		public static function create(role:String, name:String="Player"):SaboteurPlayer {
			var pl:SaboteurPlayer = new SaboteurPlayer();
			pl.role = role;
			pl.name = name;
			brokenFlags = 0;
		}
		
	}

}