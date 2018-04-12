package alternativa.engine3d.controllers 
{
  import altern.ray.Raycaster;
  import alternativa.engine3d.core.Object3D;
  import alternativa.engine3d.core.RayIntersectionData;
  import alternativa.engine3d.core.Camera3D;
	import alternativa.engine3d.materials.TextureMaterial;
	import components.Rot;
	import flash.display.InteractiveObject;
    import flash.events.Event;
	import flash.events.IEventDispatcher;
    import flash.events.MouseEvent;
    import flash.geom.Vector3D;
    import flash.utils.Dictionary;
    import alternativa.engine3d.alternativa3d;
    use namespace alternativa3d;
    
    /**
     * Does adjustments to orbit controller for chase-cams/follow target in relation to entire environment
     * and various game-types.
     * 
     * @author Glidias
     */
     public class OrbitCameraMan 
    {

        alternativa3d var _followTarget:Object3D;
		public var rot:Rot;
        public var controller:OrbitCameraController;
        
        protected var _preferedZoom:Number;
		public var preferedMinDistance:Number;
        public var maxFadeAlpha:Number = .8;
        public var minFadeAlpha:Number = .2;
        protected var _fadeDistance:Number = 200;
        public var useFadeDistance:Boolean = true;
        
        public var visBufferLength:Number = 0;
        public var preferedAlpha:Number = 1;
        
        public var followAzimuth:Boolean = false;
        public var followPitch:Boolean = false;
        protected static const ORIGIN:Vector3D = new Vector3D();
        public var scene:Object3D;
		
		
		public function get rayOrigin():Vector3D {
			return ORIGIN;
		}
		public function get rayDirection():Vector3D {
			return cameraForward;
		}
        //x:  -45 * (Math.PI / 180)  
        
        public var cameraForward:Vector3D = new Vector3D();
        public var cameraReverse:Vector3D = new Vector3D();
        public var ignoreDict:Dictionary = new Dictionary();
        public var collideOffset:Number = 24;
		
        
        public var threshold:Number = 0.01;
        
		public var alphaSetter:*;
		
		private static const DEG_TO_RAD:Number = Math.PI / 180;
		private static const RAD_TO_DEG:Number = 180 / Math.PI;

        
        public var instant:Boolean = false;
        public var mouseWheelSensitivity:Number = 30;
		
		public var offsetX:Number = 0;
		public var offsetY:Number = 0;
		public var offsetZ:Number = 0;
		
		public var raycaster:Raycaster;
        
        public function OrbitCameraMan(camera:Camera3D,  cameraTarget:Object3D, stager:InteractiveObject, scene:Object3D, followTarget:Object3D=null, rot:Rot=null, useMouseWheel:Boolean=false) 
        {
			this.rot = rot;
			
			var controller:OrbitCameraController = new OrbitCameraController(camera, new Object3D(), stager, stager, stager, false, useMouseWheel, mouseWheelHandler);
            this._followTarget = followTarget || (controller._followTarget);
			alphaSetter =  new DummyAlpha();
            this.scene = scene;
            this.controller = controller;
            _preferedZoom = controller.getDistance();
            ignoreDict[controller._followTarget] = true;
            controller.minPitch = Math.PI * .5;
			preferedMinDistance = 0;
			
		
        }
		
		
        
        /*
             _object.x += -Math.sin(_object.rotationZ) * 120;
            _object.y += Math.cos(_object.rotationZ) * 120;
        
            _object.x += forward.x * 120;
            _object.y += forward.y * 120;
            _object.z += forward.z * 120;
        */
        
        public function mouseWheelHandler(e:MouseEvent, delta:Number = 0):void {
		
            var _lastLength:Number = controller.getDistance();
            _lastLength -= e!= null ? e.delta * mouseWheelSensitivity : delta;
			var minDist:Number = (preferedMinDistance > 0 ? preferedMinDistance : controller.minDistance);
            if (_lastLength < minDist )
            {
                _lastLength = minDist;
            }
            else if (_lastLength > controller.maxDistance)
            {
                _lastLength = controller.maxDistance
            }
            
            preferedZoom = _lastLength;
            
        }
		
		public function validateFollowTarget():void {
			var follower:Object3D = controller._followTarget;
			follower._x = _followTarget.x + offsetX;
			follower._y = _followTarget.y + offsetY;
			follower._z = _followTarget.z  + offsetZ;	
			
		}
		
        public function update(time:Number):void {
			var follower:Object3D = controller._followTarget;
			follower._x = _followTarget.x + offsetX;
			follower._y = _followTarget.y + offsetY;
			follower._z = _followTarget.z  + offsetZ;
			
	
			
            controller.update(time); 

            var camera:Camera3D = controller._target;
        
            var camLookAtTarget:Object3D = controller._followTarget;
            if (followAzimuth) {
				_followTarget.rotationZ = rot.z = camera.rotationZ;
			}
            if (followPitch) {
				_followTarget.rotationX =  rot.x= camera.rotationX + Math.PI * .5;
			}
            
        
            
            camera.calculateRay(ORIGIN, cameraForward, camera.view._width*.5, camera.view._height*.5);            
        
            cameraReverse.x = -cameraForward.x;
            cameraReverse.y = -cameraForward.y;
            cameraReverse.z = -cameraForward.z;
			cameraReverse.w = _preferedZoom;
            
			var dataPoint:Vector3D = null;
			if (raycaster == null) {
				var rayData:RayIntersectionData = getBackRayIntersectionData( new Vector3D(camLookAtTarget.x + cameraForward.x *-threshold, camLookAtTarget.y + cameraForward.y *-threshold, camLookAtTarget.z + cameraForward.z *-threshold) );
				if (rayData != null) {
					//dataPoint = rayData.point;
					dataPoint = rayData.object.localToGlobal(rayData.point);
				}
			}
			else {
				//raycaster.setIgnoreDistance(_preferedZoom);
				dataPoint = raycaster.positionAndDirection(camLookAtTarget.x + cameraForward.x *-threshold, camLookAtTarget.y + cameraForward.y *-threshold, camLookAtTarget.z + cameraForward.z *-threshold, cameraReverse.x, cameraReverse.y, cameraReverse.z ).gotHit();
				
			}
			
                _followTarget.visible = true;
            var tarDist:Number = _preferedZoom;
            if (dataPoint != null) {
                
                //cameraReverse.normalize();
               
                tarDist = dataPoint.subtract( new Vector3D(camLookAtTarget.x, camLookAtTarget.y, camLookAtTarget.z) ).length - collideOffset;
            
                if (tarDist > _preferedZoom) tarDist = _preferedZoom;
                if (tarDist < controller.minDistance) tarDist =  controller.minDistance;
                    
                var limit:Number = (controller.minDistance + visBufferLength);
                _followTarget.visible = tarDist >= limit;
                
                if (useFadeDistance) {
                    limit = (tarDist - limit) / (_preferedZoom - _fadeDistance);
                    if (limit < 1) {
                        limit  = limit < 0 ? 0 : limit;
                        limit = minFadeAlpha + limit * (maxFadeAlpha - minFadeAlpha);
                       alphaSetter.alpha = limit;
					   
                    }
                    else alphaSetter.alpha = preferedAlpha;
                }
                controller.setDistance(tarDist, instant);
                controller.setObjectPosXYZ(camera.x = camLookAtTarget.x +  cameraReverse.x * tarDist,
                camera.y= camLookAtTarget.y +  cameraReverse.y * tarDist,
                camera.z = camLookAtTarget.z +  cameraReverse.z * tarDist);
            
            }
            else  {
                
                controller.setDistance(tarDist, instant);
                if (useFadeDistance) alphaSetter.alpha = preferedAlpha;
            }
            
            
            //*/
            
        }
        
        public function get sceneCollidable():Object3D {
            return scene;
        }
        protected function getBackRayIntersectionData(objPosition:Vector3D):RayIntersectionData 
        {
            return scene.intersectRay( objPosition, cameraReverse);
        }
        
        public function get preferedZoom():Number 
        {
            return _preferedZoom;
        }
        
        public function set preferedZoom(value:Number):void 
        {
            _preferedZoom = value;
            controller.setDistance(value);
            
        }
		
		public function set instantZoom(value:Number):void {
			_preferedZoom = value;
			controller.setDistance(value, true);
		}
		
		public function get instanceZoom():Number {
			return _preferedZoom;
		}
        
        public function get fadeDistance():Number 
        {
            return _fadeDistance;
        }
        
        public function set fadeDistance(value:Number):void 
        {
            _fadeDistance = value;

        }
		
		public function get followTarget():Object3D 
		{
			return _followTarget;
		}
		
		public function set followTarget(value:Object3D):void 
		{
			_followTarget = value;
		
			delete ignoreDict[value];
			ignoreDict[value] = true;
		}
		
		public function setFollowComponents(object:Object3D, rot:Rot, alphaSetter:*=null):void {
			followTarget = object;
			this.rot = rot;
			if (alphaSetter) this.alphaSetter = alphaSetter;
			if (followAzimuth || followPitch) {
				if (followAzimuth) {
					//_followTarget.rotationZ = rot.z = camera.rotationZ;
					controller.setLongitude( rot.z * RAD_TO_DEG, true);
					
				}
				if (followPitch) {
					controller.setLatitude( Math.PI * .5 - rot.x, true);  // Hmm...not too sure about this..need to test
					//_followTarget.rotationX =  rot.x= camera.rotationX + Math.PI * .5;
				}
			controller.update(0);
			}
		}
		
		public function setVisAlphaInstance(ob:Object3D, threshold:Number=.1):void {
			var instance:VisAlpha = (alphaSetter as VisAlpha || (alphaSetter = new VisAlpha(ob) ) );
			instance.obj = ob;
			instance.threshold = threshold;
			//return instance;
		}
        
    }

}
import alternativa.engine3d.core.Object3D;

class DummyAlpha {
	
	public var alpha:Number;
	public function DummyAlpha() {
		alpha = 1;
	}
}

class VisAlpha {
	public var obj:Object3D;
	private var _alpha:Number;
	public var threshold:Number = 0;
	public function VisAlpha(obj:Object3D):void {
		this.obj = obj;
		
	}
	
	public function get alpha():Number 
	{
		return _alpha;
	}
	
	public function set alpha(value:Number):void 
	{
		_alpha = value;
		 obj.visible = value > threshold;
	}
}