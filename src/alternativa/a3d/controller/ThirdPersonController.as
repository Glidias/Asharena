package alternativa.a3d.controller 
{
	import alternativa.engine3d.controllers.OrbitCameraMan;
	import alternativa.engine3d.core.Camera3D;
	import alternativa.engine3d.core.Object3D;
	import ash.core.Engine;
	import ash.core.Entity;
	import ash.core.System;
	import components.Pos;
	import components.Rot;
	import flash.display.Stage;
	
	
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class ThirdPersonController extends System
	{
		public var thirdPerson:OrbitCameraMan;
		
		public function ThirdPersonController(stage:Stage, camera:Camera3D, raycastScene:Object3D, followTarget:Object3D, cameraTarget:Object3D, playerEnt:Entity, playerPos:Pos=null, playerRot:Rot=null, useMouseWheel:Boolean=true ) 
		{
		
			
			//if (playerPos == null) playerPos = playerEnt.get(Pos) as Pos;
			if (playerRot == null) playerRot =playerEnt!= null ?  playerEnt.get(Rot) as Rot || new Rot() : new Rot();
			
		
		
			 // -- Player-Specific stuff for Client	 
			 // TODO: look at object could be higher!
            thirdPerson = new OrbitCameraMan(camera, cameraTarget, stage, raycastScene, followTarget, playerRot, useMouseWheel); 
			
            //thirdPerson.controller.easingSeparator  = 12;
            thirdPerson.preferedZoom = 160;
            thirdPerson.controller.minDistance = 30;
			thirdPerson.preferedMinDistance = 60;
			thirdPerson.fadeDistance = thirdPerson.preferedMinDistance-1;
			thirdPerson.minFadeAlpha = 0;
            thirdPerson.controller.maxDistance =256*32;
            //thirdPerson.controller.minAngleLatitude = 5;  // LEFT HANDED SYSTEM with thumb being latitude
            thirdPerson.controller.minAngleLatitude = -85;  // pitch up
            thirdPerson.controller.maxAngleLatidude = 75;  // pitch down
            thirdPerson.followAzimuth = true;
		
			
			     thirdPerson.useFadeDistance = true;
            thirdPerson.maxFadeAlpha = 1;
			//stage.addEventListener(Event.ENTER_FRAME, think);
			
			//thirdPerson.controller.disable();
		
			thirdPerson.controller.disable();
		}
		
		override public function addToEngine(engine:Engine):void {
			thirdPerson.controller.enable();
		}
		
		override public function removeFromEngine(engine:Engine):void {
			thirdPerson.controller.disable();
		}
		
		override public function update(time:Number):void {
			thirdPerson.update(time);
		}
		
		
		
		
		
	}

}