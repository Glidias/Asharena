package saboteur.models 
{
	import saboteur.util.SaboteurPathUtil;
	/**
	 * Model class to keep track of player inventory item states. Can be used as a component.
	 * @author Glenn Ko
	 */
	public class PlayerInventory 
	{
		public static const CATEGORY_EMPTY:int = 0;
		
		public static const CATEGORY_PATH:int = 1;
		public static const CATEGORY_AFFECT_SELF:int = 2;
		public static const CATEGORY_AFFECT_OTHERS_POSITIVE:int = 3;
		public static const CATEGORY_AFFECT_OTHERS_NEGATIVE:int = 4;
		public static const CATEGORY_AFFECT_ENVIRONMENT:int = 5;
		
		

		public var numItems:int = 0;
		
		public var itemSlots:Vector.<int>;  // the item ids
		public var itemSlotCategories:Vector.<int>;  // the item cateogry ids
		//public var itemSlotCatCooldowns:Vector.<Number>;  // the item cooldown
		
		public var itemCatCooldowns:Vector.<Number>;
		
		public const pathUtil:SaboteurPathUtil =SaboteurPathUtil.getInstance() ;
		public const numPathCards:int = SaboteurPathUtil.getInstance().combinations.length;
		

		
		
		public function PlayerInventory() 
		{
			
		
			itemSlots = new Vector.<int>();
			itemSlotCategories = new Vector.<int>();
			//itemSlotCatCooldowns = new Vector.<Number>();
			
			itemCatCooldowns = new Vector.<Number>(6, true);  // 1st index unused
			
			
			setCapacity(6);
			
		//	assignRandomPaths();
		}
		
		public function assignRandomPaths():void {
			var len:int = getCapacity();
			for (var i:int = 0; i < len; i++) {
				addItemAtSlot(i,  int(Math.random() * numPathCards)  );
			}
		}
		
		public function setCapacity(amt:int):void {
			
			itemSlots.length = amt;
			itemSlotCategories.length = amt;
			// TODO: rearrange/discard items if needed...
		}
		
		
		public function getPathValueAtSlot(slot:int):int {
			
			return  itemSlotCategories[slot] == CATEGORY_PATH ?   pathUtil.getValueByIndex(itemSlots[slot]) : -1;
		}
		
		public function addItem(value:int, category:int = -1):int {  // CATEGORY_PATH
			if (numItems == itemSlots.length) return -1;
		
			numItems++;
			// find first availalbe slot
			
			category = category > 0 ? category : CATEGORY_PATH;
			return 0;  // please return first available slot
			
		}
		
		public function addItemAtSlot(slot:int, value:int, category:int = -1):void {
			itemSlots[slot] = value;
			numItems++;
			category = category > 0 ? category : CATEGORY_PATH;
			itemSlotCategories[slot] = category;
		}
		
		public function removeItemAtSlot(slot:int):Boolean {
			if (numItems == 0) return false;
			itemSlots[slot] = 0;
			itemSlotCategories[slot] = 0;

			return false;
		}
		
		
		
		public function getCapacity():int {
			return itemSlots.length;
		}
		
	}

}