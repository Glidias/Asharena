package saboteur.systems 
{
	import ash.core.System;
	import input.KeyPoll;
	import saboteur.models.IBuildModel;
	import saboteur.models.PlayerInventory;
	/**
	 * Responsible for binding of controls to inventory model, and any related action systems/models such as a build system/model or action system/model.
	 * @author Glenn Ko
	 */
	public class PlayerInventoryControls extends System
	{
		
		public function PlayerInventoryControls(keypoll:KeyPoll, inventory:PlayerInventory, buildModel:IBuildModel) 
		{
			
		}
		
	}

}