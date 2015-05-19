package systems.movement;
import ash.core.Engine;
import ash.core.Node;
import ash.core.NodeList;
import ash.core.System;
import components.flocking.Flocking;
import components.Pos;
import components.Rot;
import components.Vel;
import util.geom.Vec3;
import util.geom.Vec3Utils;

/**
 * Random flocking behaviour with  collision avoidance/speed-limit adjustmenet support
 * @author Glenn Ko
 */
class FlockingSystem extends System
{

	private var nodeList:NodeList<FlockingNode>;
	
	//private static inline function get_myr() { return 2 / 3 * Math.PI; }
	private static inline var myr:Float = 2.0943951023931954923084289221863;
	private static inline var scalerSpeed:Float = 1. / 12;
	//private static inline var minTime:Float = 10.0 / 3;
	
	// variables to help do calculations
	 private var relP:Vec3;
     private var relV:Vec3;
	 private var dist:Vec3;
	 private var hispos:Vec3;
	 private var mypos:Vec3;
	 private var collision:Vec3;
	 
	  // force:
	  /*
    private var 
                dist:Vector3,
                 time:Number = 0,            
                mypos:Vector3,
                hispos:Vector3,
                collision:Vector3,
                collisionLen:Number;
		*/
	
	public function new() 
	{
		super();
		relP = new Vec3();
		relV = new Vec3();
		dist = new Vec3();
		hispos = new Vec3();
		mypos = new Vec3();
		hispos = new Vec3();
		collision = new Vec3();
	}
	
	
	override public function addToEngine(engine:Engine):Void {
		nodeList = engine.getNodeList(FlockingNode);
	}
	
	
	override public function update(sec:Float):Void {
		var count:Int;
		var count2:Int;
		var cur:FlockingNode = nodeList.head;
		 var time:Float;
		 var collisionLen:Float;
		 var curF:Flocking;
		 var curS:FlockSettings;
		 
		while (cur != null) {
			count = 0;
			count2 = 0;
			
				
			curF = cur.f;
			curS = curF.settings;
			var minTime:Float = curF.minTime;
			var other:FlockingNode;
			
			// tmp.reset();
			curF.separation.reset();
			curF.alignment.reset();
			curF.cohesion.reset();
			curF._aold.copyFrom(curF._a);
			curF._a.reset();
					
			
			
			// check all other nodes in both directions  (foregoes the "if (!=self)" check)
			other = cur.previous;
			while ( other != null) {   
				
				//start routine
			    Vec3Utils.writeSubtract( dist, other.pos, cur.pos);
				time = predictTime(cur, other);
				// Neighborhood seleted by angle i dist
				if (dist.lengthSqr() < curS.mydistSquared) {
				 
					// Collision!
					//if (dist.lengthSqr() < curS.mindistSquared*4) {
						// draw collision
					//}
					curF.angle = Math.abs(angleBetween(cur.vel,dist));
					if (curF.angle < myr) {
						// Separation
						dist.scale( curS.mydist / dist.lengthSqr());
						/*_a*/
						curF.separation.subtract(dist);
						curF.alignment.add(other.vel);
						
						++count;
						//g.lineStyle(1, 0xFF0000, 0.25);
						curF.angle = Math.abs(angleBetween(cur.vel,other.vel));
						if (curF.angle < (Math.PI/2) ) {
							curF.cohesion.add(other.pos);//.decrementBy(b.v);
							++count2;
						}
					}
				}
				///*
				if ( !((time < 0.) || (time >= minTime)) ) {  
					
					mypos.copyFrom(cur.vel);
					mypos.scale(time);
					mypos.add(cur.pos);
					
					hispos.copyFrom(other.vel);
					hispos.scale(time);
					hispos.add(other.pos);
				

					//mypos = v.scaleBy(time).incrementBy(p);
					//hispos = b.v.scaleBy(time).incrementBy(b.p);
				
					
					Vec3Utils.writeSubtract(collision, mypos, hispos);
					collisionLen = collision.lengthSqr();
					if ( !(collisionLen >= curS.mindistSquared) )  {   //*6.25
						minTime = time;
						collisionLen = (1/Math.sqrt(collisionLen));
						collision.scale(collisionLen);
						//_a.incrementBy(collision);
						curF._a.copyFrom(collision);
						//text.text = "C";
					}
				}
				//*/
					
				// end routine
				
				other = other.previous;
			}
			
			
			other = cur.next;
			///*
			while ( other != null) {
				
				//start routine
				  Vec3Utils.writeSubtract( dist, other.pos, cur.pos);
				time = predictTime(cur, other);
				// Neighborhood seleted by angle i dist
				if (dist.lengthSqr() <curS.mindistSquared) {
				 
					// Collision!
					//if (dist.lengthSqr() < curS.mindistSquared*4) {
					 // draw collision
					//}
					curF.angle = Math.abs(angleBetween(cur.vel,dist));
					if (curF.angle < myr) {
						// Separation
						dist.scale( curS.mydist / dist.lengthSqr());
						/*_a*/
						curF.separation.subtract(dist);
						curF.alignment.add(other.vel);
						
						++count;
						//g.lineStyle(1, 0xFF0000, 0.25);
						curF.angle = Math.abs(angleBetween(cur.vel,other.vel));
						if (curF.angle < Math.PI/2) {
							curF.cohesion.add(other.pos);//.decrementBy(b.v);
							++count2;
						}
					}
				}
			///*
				if ( !((time < 0.) || (time >= minTime)) ) {  
					
					mypos.copyFrom(cur.vel);
					mypos.scale(time);
					mypos.add(cur.pos);
					
					hispos.copyFrom(other.vel);
					hispos.scale(time);
					hispos.add(other.pos);
				
					//mypos = v.scaleBy(time).incrementBy(p);
					//hispos = b.v.scaleBy(time).incrementBy(b.p);
					
					Vec3Utils.writeSubtract(collision, mypos, hispos);
					collisionLen = collision.lengthSqr();
					if ( !(collisionLen >= curS.mindistSquared) )  {   //*6.25
						minTime = time;
						collisionLen = (1/Math.sqrt(collisionLen));
						collision.scale(collisionLen);
						//_a.incrementBy(collision);
						curF._a.copyFrom(collision);
					}
				}
				//*/
				// end routine
				
				other = other.next;
			}
			
			
		//	*/
			var _a:Vec3 = curF._a;
		        if (isAlmostZero(_a)) {
          //  text.text = "F";
            //trace(separation.length);
			curF.separation.scale(curS.seperationScale);
			_a.add(curF.separation);
		
            // Alignment
			// /*
           if (count > 0) {
                curF.alignment.scale(1 / count);
				curF.alignment.subtract(cur.vel);
				curF.alignment.scale(1 / (curS.maxspeed * 2));
				curF.alignment.scale(curS.alignmentScale);
                _a.add(curF.alignment);
            }
            // Cohesion
            if (count2 > 0) {
                curF.cohesion.scale(1 / count2);
				curF.cohesion.subtract(cur.pos);
				curF.cohesion.scale(1 / (curS.mydist));
				curF.cohesion.scale(curS.cohesionScale);
                _a.add(curF.cohesion);
            }
			//*/
        }
        
			if (isAlmostZero(_a) && count == 0) {  // NOTE: using rotation z convention for this!
				//text.text = "W"; // GUI
				// Wandering
				curF.rangle += sign(Math.random() - 0.5) * Math.PI / 36;
				
				_a.addScaled(0.44/Vec3Utils.getLength(cur.vel),cur.vel);
				_a.x += 0.45*Math.sin(curF.rangle);
				_a.y += 0.45*Math.cos(curF.rangle);
			} else {
				curF.rangle = getAngle(_a);
			}
				// Boundaries
				if (cur.pos.x < curS.minx)
					_a.x += 0.4;//0.5*(minx-_p.x)/minx;
				else if (cur.pos.x > curS.maxx)
					_a.x -= 0.4;//0.5*(_p.x-maxx)/minx;
				if (cur.pos.y < curS.miny)
					_a.y += 0.4;//0.5*(miny-_p.y)/miny;
				else if (cur.pos.y > curS.maxy)
					_a.y -= 0.4;//0.5*(_p.y-maxy)/miny;
			// smooth acceleration
			//	/*
			if (curS.turnAccelRatio > 0) {
				_a.subtract(curF._aold);
				var t:Float = _a.length();
				if (t > 0.0001)
					_a.scale(curS.turnAccelRatio);
				if (t >= curS.turnAccelRatio) _a.scale(curS.turnAccelRatio/t);
				_a.add(curF._aold);
			}
			//*/
		
			// Next current entity to update
			cur = cur.next;
		}
		
		
		cur = nodeList.head;
	
		while (cur != null) {
			curF = cur.f;
			curS = curF.settings;
			Vec3Utils.add(cur.vel, curF._a);
			Vec3Utils.scale(cur.vel,scalerSpeed );
			

			cur.rot.z = getAngle( cur.vel);  // this may be done by another system
			Vec3Utils.add(cur.pos, cur.vel);  // tbd by MovementSystem
		
			Vec3Utils.scale(cur.vel, 12.);
	
			
			// speed limit
			var v:Float = Vec3Utils.getLength(cur.vel);
			if (v > curS.maxspeed) {
				Vec3Utils.scale(cur.vel, curS.maxspeed/v);
			} else if (v < curS.minspeed) {
				Vec3Utils.scale(cur.vel,curS.minspeed/v);
			} else {
				Vec3Utils.scale(cur.vel,0.99);
			}
			
			cur = cur.next;
		}
		
	}
	
	private inline function sign(arg:Float):Float {
		return (arg > 0) ? 1 : ((arg < 0) ? -1 : 0);
	}
	
	private inline function getAngle(vec:Vec3):Float { return Math.atan2(vec.y, vec.x); }
	
	private inline function isAlmostZero(a:Vec3, min:Float = 0.15999) 
	{
		 return (a.lengthSqr() < min);
	}
	

	
	private inline function angleBetween(me:Vec3, v:Vec3):Float {
        var result:Float = Math.atan2(me.y, me.x) - Math.atan2(v.y, v.x);
        if (result < -Math.PI) result += Math.PI*2;
        if (result > Math.PI) result -= Math.PI*2;
        return result;
    }
	
	private inline function predictTime(cur:FlockingNode, other:FlockingNode) : Float {
		Vec3Utils.writeSubtract(relP, cur.pos, other.pos);
		Vec3Utils.writeSubtract(relV, other.vel, cur.vel);
        return relV.dotProduct(relP) / relV.lengthSqr();
    }
	
}

class FlockingNode extends Node<FlockingNode> {
	public var f:Flocking;
	public var pos:Pos;
	public var rot:Rot;
	public var vel:Vel;
	
}