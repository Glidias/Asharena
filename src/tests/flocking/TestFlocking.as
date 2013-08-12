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
	[SWF(width="600", height="400", frameRate="40", backgroundColor="0xddddff")]
	public class TestFlocking extends MovieClip
	{
		public var engine:Engine;
		public var ticker:FrameTickProvider;
		
		private static const NUMBOIDS:int = 44;
		static public const MIN_SPEED:Number = 1;
		static public const MAX_SPEED:Number = 4;
		static public const TURN_RATIO:Number = .1;
		static public const MIN_DIST:Number = 32;
		static public const SENSE_DIST:Number = 200;
		
		public function TestFlocking() 
		{
			super();

			engine = new Engine();
			
			engine.addSystem( new FlockingSystem(), 0 );
			engine.addSystem( new DisplayObjectRenderingSystem(this), 1);
			
			ticker = new FrameTickProvider(stage);
			ticker.add(tick);
			
			
			createBoids();
		
          
			
			ticker.start();
		}
		
		
		private function tick(time:Number):void 
		{
			engine.update(time);
		}
		
		
		private function createBoids():void 
		{
			
			 var tmp:Number = 2.0 * Math.PI / NUMBOIDS;
			 
				var tmpw:int = stage.stageWidth / 2, tmph:int = stage.stageHeight / 2;
				var flockSettings:FlockSettings = Flocking.createFlockSettings(MIN_DIST,SENSE_DIST,0,0,tmpw*2, tmph*2, MIN_SPEED, MAX_SPEED, TURN_RATIO);
			  
			for (var i:int = 0; i < NUMBOIDS; ++i) {
				 const ph:Number = i * tmp;
				var pos:Pos = new Pos(  tmpw + ((i % 4) * 0.2 + 0.3) * tmpw * Math.cos(ph), tmph + ((i % 4) * 0.2 + 0.3) * tmph * Math.sin(ph));
				var vel:Vel = new Vel( ((i%4)*(-4) + 16) * Math.cos(ph + Math.PI / 6 * (1+i%4) * (Math.random() - 0.5)),  ((i%4)*(-4) + 16) * Math.sin(ph + Math.PI / 6 * (1+i%4) * (Math.random() - 0.5)));
				var rot:Rot = new Rot(0, 0, Math.random() * 2 * Math.PI);

				
				var entity:Entity = new Entity().add(pos).add(rot).add(vel).add( new BoidGraphic(), DisplayObject).add( new Flocking().setup(flockSettings )) ;
				
				engine.addEntity(entity);
			}
		}
		
	
	}
		

}
import ash.core.Engine;
import ash.core.Node;
import ash.core.NodeList;
import ash.core.System;
import ash.ObjectMap;
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
	
	private static var _components:ObjectMap;

	public function DisplayNode() {
		
	}
	
	public static function _getComponents():ObjectMap {
		if(_components == null) {
				_components = new ash.ObjectMap();
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

                g.lineStyle(0.1, 0x0055ff);
                g.beginFill(0x0055ff);
                g.moveTo(4, 0);
                g.lineTo(-3, -3);
                g.lineTo(-1, 0);
                g.lineTo(-3, 3);
                g.lineTo(4, 0);
                g.endFill();
                
         /*
            drawer = new Sprite();
            this.addChild(drawer);
*/
        
	}
	
}