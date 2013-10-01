package saboteur.models 
{
	import saboteur.util.SaboteurPathUtil;
	/**
	 * Model class to keep track of player inventory item states. Can be used as a component.
	 * @author Glenn Ko
	 */
	public class PlayerInventory 
	{
		public static const EMPTY:int = 0;
		
		public static const CATEGORY_PATH:int = 1;
		public static const CATEGORY_AFFECT_SELF:int = 2;
		public static const CATEGORY_AFFECT_OTHERS_POSITIVE:int = 3;
		public static const CATEGORY_AFFECT_OTHERS_NEGATIVE:int = 4;
		public static const CATEGORY_AFFECT_ENVIRONMENT:int = 5;

		public var numItems:int = 0;
		
		public var itemSlots:Vector.<int>;
		public var itemSlotCategories:Vector.<int>;
		public var itemSlotCatCooldowns:Vector.<Number>;
		
		public var itemCatCooldowns:Vector.<Number>;
		
		private static const pathUtil:SaboteurPathUtil = SaboteurPathUtil.getInstance();
		private var numPathCards:int;
		
		public function PlayerInventory() 
		{
			numPathCards = pathUtil.combinations.length;
			
			itemSlots = new Vector.<int>();
			itemSlotCategories = new Vector.<int>();
			itemSlotCatCooldowns = new Vector.<int>();
			
			itemCatCooldowns = new Vector.<Number>(6, true);  // 1st index unused
			
			
			setCapacity(6);
		}
		
		public function setCapacity(amt:int):void {
			
			itemSlots.length = amt;
			itemSlotCategories.length = amt;
			itemSlotCatCooldowns.length = amt;
		}
		
		
		public function getPathValueAtSlot(slot:int):int {
			
			return  itemSlotCategories[slot] == CATEGORY_PATH ?   pathUtil.getValueByIndex(itemSlotCategories[slot]) : -1;
		}
		
		public function addItem(category:int = -1):int {  // CATEGORY_PATH
			if (numItems == itemSlots.length) return -1;
		
			numItems++;
			// find first availalbe slot
			
			category = category >= 0 ? category : CATEGORY_PATH;
			return 0;  // please return first available slot
			
		}
		
		public function removeItemAtSlot(slot:int):Boolean {
			if (numItems == 0) return false;
			
			return false;
		}
		
		
		
		public function getCapacity():int {
			return itemSlots.length;
		}
		
	}

}