package tests.flocking 
{
	import alternativa.types.Float;
	import ash.core.Engine;
	import ash.core.Entity;
	import ash.tick.FrameTickProvider;
	import components.flocking.Flocking;
	import components.flocking.FlockSettings;
	import components.Pos;
	import components.Rot;
	import components.Vel;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import systems.movement.FlockingSystem;

	import flash.display.DisplayObject;	
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Vector3D;

	/**
	 * ...
	 * @author Glenn Ko
	 */
	[SWF(width="1920", height="1080", frameRate="40", backgroundColor="0xddddff")]
	public class TestFlocking extends MovieClip
	{
		public var engine:Engine;
		public var ticker:FrameTickProvider;
		
      
        private static const NUMBOIDS:int = 26;
        private var WEIGHTS_DEFAULTED:Array;
        private var WEIGHTS_TOTAL:Number;
        static public const MIN_SPEED:Number = 1;
        static public const MAX_SPEED:Number = 4;
        static public const TURN_RATIO:Number = .1;
        static public const MIN_DIST:Number = 100;
        static public const SENSE_DIST:Number = 340;
		
		public function TestFlocking() 
		{
			super();
			
			if (stage != null) {
				stage.align = StageAlign.TOP_LEFT;
				stage.scaleMode = StageScaleMode.SHOW_ALL;
			}

			engine = new Engine();
			
			engine.addSystem( new FlockingSystem(), 0 );
			engine.addSystem( new DisplayObjectRenderingSystem(this), 1);
			
			ticker = new FrameTickProvider(stage);
			ticker.add(tick);
			
			
			createRandomBoids();
		
          
			
			ticker.start();
		}
		
		
		private function tick(time:Number):void 
		{
			engine.update(time);
		}
		
		      
        private function recalculateWeights():void {
            var weight:Number;
            var i:int;
            var numUndeclaredWeights:Number = 0;
            var totalDeclaredWeight:Number = 0;
            var len:int = WEIGHTS_DEFAULTED.length;
            for (i = 0; i < len; i++) {
                weight = WEIGHTS_DEFAULTED[i];
               
                 totalDeclaredWeight += weight;
                
            }
            
            WEIGHTS_TOTAL = totalDeclaredWeight;
        }
        
           private function getRaceID(floatRatio:Number):int {
           // return floatRatio * raceNum + 1;
           floatRatio *= WEIGHTS_TOTAL;
           
           
            var accum:Number = 0;
            var result:int = 0;
            var len:int = WEIGHTS_DEFAULTED.length;
            for (var i:int = 0; i < len; i++) {    
                if (floatRatio < accum) {  // did not meet requirement
                    break;
                }
                accum += WEIGHTS_DEFAULTED[i];
                result = i;
            }
            
            return result;
        
        }
        
        private function getRandomRaceIndex():int {
            return getRaceID(Math.random());
        }
		
		
		
		private function createRandomBoids():void 
		{
			
			  var tmp:Number = 2.0 * Math.PI / NUMBOIDS;
             

                var tmpw:int = stage.stageWidth / 2, tmph:int = stage.stageHeight / 2;
                var flockSettings:FlockSettings = Flocking.createFlockSettings(MIN_DIST, SENSE_DIST, 0, 0, tmpw * 2, tmph * 2, MIN_SPEED, MAX_SPEED*2    , TURN_RATIO);
                var nonMovingFlockSettings:FlockSettings = Flocking.createFlockSettings(MIN_DIST, SENSE_DIST, 0, 0, tmpw * 2, tmph * 2, 0.000000001, 0.000000001, 1);
                var wanderingFlockSettings:FlockSettings = Flocking.createFlockSettings(MIN_DIST, SENSE_DIST, 0, 0, tmpw * 2, tmph * 2, MIN_SPEED, MAX_SPEED * 2    , TURN_RATIO);
                
                flockSettings.seperationScale = .65;
                flockSettings.cohesionScale = 12;
                flockSettings.alignmentScale = 4;
                
                nonMovingFlockSettings.seperationScale =1;
                nonMovingFlockSettings.alignmentScale = 0;
                nonMovingFlockSettings.cohesionScale = 0;
                
                wanderingFlockSettings.cohesionScale = 0;
                wanderingFlockSettings.alignmentScale = 0;
                wanderingFlockSettings.seperationScale = .5;
                
                var flockSettingsArr:Array = [flockSettings, nonMovingFlockSettings, wanderingFlockSettings];
                WEIGHTS_DEFAULTED = [.7, .8, .4];
            //    WEIGHTS_DEFAULTED = [1, 0, 0];
                recalculateWeights();
                
                
            for (var i:int = 0; i < NUMBOIDS; ++i) {
                 const ph:Number = i * tmp;
                var pos:Pos = new Pos(  tmpw + ((i % 4) * 0.2 + 0.3) * tmpw * Math.cos(ph), tmph + ((i % 4) * 0.2 + 0.3) * tmph * Math.sin(ph));
                var vel:Vel = new Vel( ((i%4)*(-4) + 16) * Math.cos(ph + Math.PI / 6 * (1+i%4) * (Math.random() - 0.5)),  ((i%4)*(-4) + 16) * Math.sin(ph + Math.PI / 6 * (1+i%4) * (Math.random() - 0.5)));
                var rot:Rot = new Rot(0, 0, Math.random() * 2 * Math.PI);

                var useFlockSetting:FlockSettings = flockSettingsArr[ getRandomRaceIndex() ] ;
                var graphicer:BoidGraphic;
                var entity:Entity = new Entity().add(pos).add(rot).add(vel).add( graphicer=new BoidGraphic(), DisplayObject).add( new Flocking().setup(useFlockSetting )) ;
                if (useFlockSetting === wanderingFlockSettings ) graphicer.drawDirPointer()
                else if (useFlockSetting === flockSettings) graphicer.drawDirPointer(.5);
                engine.addEntity(entity);
            }
		}
		
	
	}
		

}
import ash.ClassMap;
import ash.core.Engine;
import ash.core.Node;
import ash.core.NodeList;
import ash.core.System;
import ash.ClassMap;
import components.Pos;
import components.Rot;
import flash.display.Graphics;
import flash.display.Shape;
import flash.display.Sprite;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.events.Event;



class DisplayObjectRenderingSystem extends System {
	private var scene:DisplayObjectContainer;
	private var nodeList:NodeList;
	
	
	public function DisplayObjectRenderingSystem(scene:DisplayObjectContainer):void {
		this.scene = scene;
	}
	 public function onAddedNode(node:DisplayNode):void {
			scene.addChild( node.object );
	}
	
	override public function addToEngine(engine:Engine ):void {
		super.addToEngine(engine);
		nodeList = engine.getNodeList(DisplayNode);
		nodeList.nodeAdded.add(onAddedNode);
		nodeList.nodeRemoved.add(onRemovedNode);
	}
	
		
		 public function onRemovedNode(node:DisplayNode):void {
			scene.removeChild( node.object);
		}
	
		override public function update(time:Number):void {
			const RAD_TO_DEG:Number = 180 / Math.PI;
			for (var r:DisplayNode = nodeList.head as DisplayNode; r != null; r = r.next as DisplayNode) {
				r.object.x = r.pos.x;
				r.object.y = r.pos.y;
				r.object.rotation = r.rot.z * RAD_TO_DEG;
			}
			//if (renderEngine != null) renderEngine.render();
		}
	
}

class DisplayNode extends Node {
	public var object:DisplayObject;
	public var pos:Pos;
	public var rot:Rot;
	
	

	public function DisplayNode() {
		
	}
	
	private static var _components:ClassMap;
	public static function _getComponents():ClassMap {
		if(_components == null) {
				_components = new ash.ClassMap();
				_components.set(DisplayObject, "object");
				_components.set(Pos, "pos");
				_components.set(Rot, "rot");
			}
			return _components;
	}
}


class BoidGraphic extends Shape {
	public function BoidGraphic() {
         
                var g:Graphics = graphics;
                // Draw view range
                /*g.lineStyle(1, 0xffffff);
                g.moveTo(0,0);
                for (var j:Number = -1; j <= 1; j += 0.01) {
                    g.lineTo(Math.cos(j * b.myr)*b.mydist, Math.sin(j * b.myr)*b.mydist);
                }
                g.lineTo(0,0);*/
                //g.drawCircle(0, 0, b.mindist);

				/* Arrow
                g.lineStyle(0.1, 0x0055ff);
                g.beginFill(0x0055ff);
                g.moveTo(4, 0);
                g.lineTo(-3, -3);
                g.lineTo(-1, 0);
                g.lineTo(-3, 3);
                g.lineTo(4, 0);
                g.endFill();
                */
                
                ///*  Circle
                g.beginFill(0x0055ff);
                g.drawCircle(0, 0, 23*2);
                
         /*
            drawer = new Sprite();
            this.addChild(drawer);
*/
        

	}
	
	  public function drawDirPointer(scaler:Number=1):void {
        var g:Graphics = graphics;
            g.lineStyle(0.1, 0);
                g.moveTo(0, 0);
                g.lineTo(23*2*scaler, 0);
    }
	
}