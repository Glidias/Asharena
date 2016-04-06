package saboteur.systems 
{
	import ash.core.Engine;
	import ash.core.System;
	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import haxe.Log;
	import input.KeyPoll;
	import saboteur.util.SaboteurDeck;

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
		private var buildAttempter:IBuildAttempter;
		
		public function PlayerInventoryControls(keypoll:KeyPoll, inventory:PlayerInventory, hud:SaboteurHud,  buildModel:IBuildModel, minimap:SaboteurMinimap, stage:Stage, buildAttempter:IBuildAttempter) 
		{
			this.buildAttempter = buildAttempter;
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
		
		public function updateCards(cards:Array, usabilityMask:uint):void {
			inventory.updateCards(cards);
		//	Log.trace("A");
		//	throw new Error(cards + ">>>>" + usabilityMask);
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
					unequip();
				}
				else if (kc === Keyboard.BACKSPACE && !keypoll.isDown(Keyboard.BACKSPACE) ) {
					unequip();
				}
				else if (kc === Keyboard.J && !keypoll.isDown(Keyboard.J) ) {
				//	unequip();
				//	inventory.assignRandomPaths();
				//	hud.syncWithInventory(inventory);
				}
			}
			else if (kc === Keyboard.J && !keypoll.isDown(Keyboard.J)) {
				
			//	inventory.assignRandomPaths();
				//inventory.assignFixedPaths();
				//hud.syncWithInventory(inventory);
			}
			
		}
		
		private function executeSwitch():void 
		{
			if (!SaboteurDeck.cardIsAction(equipedSlot) ) {
				attemptPathCardFlip();
			}
			else {
				
			}
		}
		
		private function attemptPathCardFlip():void 
		{
			var lastIndex:uint =  inventory.itemSlots[equipedSlot];
			var val:uint = inventory.pathUtil.getFlipValue( inventory.pathUtil.getValueByIndex(lastIndex) );
			buildModel.setBuildId( val );
			var index:int = inventory.pathUtil.getIndexByValue(val);
			if (index < 0) {
			
				throw new Error("SHOUld not be!");
				
			}
			inventory.itemSlots[equipedSlot] = index;
		}
		
		private function executeEquipSlot():void 
		{
			if ( !SaboteurDeck.cardIsAction(equipedSlot) ) {
				if (buildAttempter.attemptBuild()) {
					//inventory.removeItemAtSlot(equipedSlot);
				//	hud.syncWithInventory(inventory);
					buildModel.setBuildId( -1);
				}
			}
			else { // todo: properly handle this with game rules
				unequip();
			}
		}
		
		
		
		private function trySetSlot(slotIndex:int):void 
		{
			if (slotIndex === equipedSlot) {
				executeSwitch();
				return;
			}
			if (slotIndex >= inventory.getCapacity()) {
				unequip();
				return;
			}
			var category:int = PlayerInventory.getCategoryIndexer(inventory.itemSlots[equipedSlot]);// inventory.itemSlotCategories[slotIndex]
			/*
			if (category == 0) {
				unequip();
				return;
			}
			*/
			unequip();
			equipedSlot = slotIndex;
			hud.setSlot(slotIndex, true, category);
			
			if ( !SaboteurDeck.cardIsAction(inventory.itemSlots[equipedSlot])) {
				var buildValue:uint = inventory.getPathValueAtSlot(slotIndex);
				if (buildValue >= 0) {
					buildModel.setBuildId(buildValue);
				}
			}
		}

		override public function removeFromEngine (engine:Engine) : void {
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			unequip();
		}
		
		private function unequip():void 
		{
			if (equipedSlot >= 0) {
				hud.setSlot(equipedSlot, false, PlayerInventory.getCategoryIndexer(inventory.itemSlots[equipedSlot]) );
				equipedSlot = -1;
				buildModel.setBuildId(-1);
			}
		}
		
		override public function update(time:Number):void {
			
		}
		
	}

}