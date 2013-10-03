package saboteur.systems 
{
	import ash.core.Engine;
	import ash.core.System;
	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	import input.KeyPoll;
	import saboteur.models.IBuildModel;
	import saboteur.models.PlayerInventory;
	import saboteur.spawners.SaboteurHud;
	/**
	 * Responsible for binding of controls to inventory model, and any related action systems/models such as a build system/model or action system/model.
	 * Also responsible for cooldown stuff...
	 * @author Glenn Ko
	 */
	public class PlayerInventoryControls extends System
	{
		private var hud:SaboteurHud;
		private var inventory:PlayerInventory;
		private var keypoll:KeyPoll;
		private var buildModel:IBuildModel;
		private var stage:Stage;
		
		public function PlayerInventoryControls(keypoll:KeyPoll, inventory:PlayerInventory, hud:SaboteurHud,  buildModel:IBuildModel, stage:Stage) 
		{
			this.stage = stage;
			this.buildModel = buildModel;
			this.keypoll = keypoll;
			this.inventory = inventory;
			this.hud = hud;
			
		}
		
		override public function addToEngine (engine:Engine) : void {
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		}
		
		private function onKeyDown(e:KeyboardEvent):void 
		{
			var cc:uint = e.charCode;
			//if (cc < 
			if (  cc >= 49 && cc < 58 && !keypoll.isDown(e.keyCode) ) {  // temp
				setSlot(cc - 49);
			}
		}
		
		private function setSlot(slotIndex:int):void 
		{
			//hud.setSlot(slotIndex, true, 0);
		}

		override public function removeFromEngine (engine:Engine) : void {
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		}
		
		override public function update(time:Number):void {
			
		}
		
	}

}