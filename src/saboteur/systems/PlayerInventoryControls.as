package saboteur.systems 
{
	import ash.core.Engine;
	import ash.core.System;
	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import input.KeyPoll;
	import saboteur.models.IBuildModel;
	import saboteur.models.PlayerInventory;
	import saboteur.spawners.SaboteurHud;
	import saboteur.views.SaboteurMinimap;
	/**
	 * Responsible for binding of controls to inventory model, and any related action systems/models such as a build system/model or action system/model.
	 * Also responsible for cooldown stuff... Basically, most of the client side view/input controller code lies here.
	 * @author Glenn Ko
	 */
	public class PlayerInventoryControls extends System
	{
		private var hud:SaboteurHud;
		private var inventory:PlayerInventory;
		private var keypoll:KeyPoll;
		private var buildModel:IBuildModel;
		private var stage:Stage;
		private var minimap:SaboteurMinimap;
		private var equipedSlot:int = -1;
		
		public function PlayerInventoryControls(keypoll:KeyPoll, inventory:PlayerInventory, hud:SaboteurHud,  buildModel:IBuildModel, minimap:SaboteurMinimap, stage:Stage) 
		{
			this.minimap = minimap;
			this.stage = stage;
			this.buildModel = buildModel;
			this.keypoll = keypoll;
			this.inventory = inventory;
			this.hud = hud;
			hud.setupItemTextureSet( minimap.jettyMaterial, minimap );
		}
		
		override public function addToEngine (engine:Engine) : void {
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown, false,1);
			// could consider syncing in contructor
			hud.syncWithInventory(inventory);
		}
		
		private function onKeyDown(e:KeyboardEvent):void 
		{
			var cc:uint = e.charCode;
			var kc:uint = e.keyCode;
			//if (cc < 
			if (  cc >= 49 && cc < 58 && !keypoll.isDown(kc) ) {  // temp
				trySetSlot(cc - 49); 
					
			}
			else if (equipedSlot >=0) {
				if (kc === Keyboard.F && !keypoll.isDown(Keyboard.F) ) {
					executeEquipSlot();
				}
				else if (kc === Keyboard.R && !keypoll.isDown(Keyboard.R) ) {
					executeSwitch();
				}
			}
			else if (kc === Keyboard.J && !keypoll.isDown(Keyboard.J)) {
				inventory.assignRandomPaths();
				hud.syncWithInventory(inventory);
			}
		}
		
		private function executeSwitch():void 
		{
			if (inventory.itemSlotCategories[equipedSlot] === PlayerInventory.CATEGORY_PATH) {
				
			}
			else {
				
			}
		}
		
		private function executeEquipSlot():void 
		{
			if (inventory.itemSlotCategories[equipedSlot] === PlayerInventory.CATEGORY_PATH) {
				if (buildModel.attemptBuild()) {
					inventory.removeItemAtSlot(equipedSlot);
					hud.syncWithInventory(inventory);
					buildModel.setBuildId( -1);
				}
			}
			else {
				unequip();
			}
			
			
			
		}
		
		
		
		private function trySetSlot(slotIndex:int):void 
		{
			if (slotIndex === equipedSlot) {
				unequip();
				return;
			}
			if (slotIndex >= inventory.getCapacity()) {
				unequip();
				return;
			}
			var category:int = inventory.itemSlotCategories[slotIndex]
			if (category == 0) {
				unequip();
				return;
			}
			unequip();
			equipedSlot = slotIndex;
			hud.setSlot(slotIndex, true, category);
			
			var buildValue:uint = inventory.getPathValueAtSlot(slotIndex);
			if (buildValue >= 0) {
				buildModel.setBuildId(buildValue);
			}
		}

		override public function removeFromEngine (engine:Engine) : void {
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			unequip();
		}
		
		private function unequip():void 
		{
			if (equipedSlot >= 0) {
				hud.setSlot(equipedSlot, false, inventory.itemSlotCategories[equipedSlot]);
				equipedSlot = -1;
				buildModel.setBuildId(-1);
			}
		}
		
		override public function update(time:Number):void {
			
		}
		
	}

}