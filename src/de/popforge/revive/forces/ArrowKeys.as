package de.popforge.revive.forces 
{

	import de.popforge.revive.display.IDrawAble;
	import de.popforge.revive.geom.Vec2D;
	import de.popforge.revive.member.Movable;
	import de.popforge.revive.member.MovableParticle;
	import de.popforge.surface.io.PopKeys;
	import flash.display.Graphics;
	import flash.ui.Keyboard;
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class ArrowKeys implements IForce, IDrawAble
	{
		private var movable:MovableParticle;
		public var speed:Number;
		public function ArrowKeys(movable:MovableParticle, speed:Number=.5) 
		{
			this.movable = movable;
			this.speed = speed;
			
			
		}
		
		/* INTERFACE de.popforge.revive.forces.IForce */
		private var force:Vec2D = new Vec2D(0,0);
		public function solve():void 
		{
			force.x = 0;
			force.y = 0;
			if (PopKeys.isDown(Keyboard.UP)) {
				force.y -= 1;
				
			}
			if (PopKeys.isDown(Keyboard.DOWN)) {
				force.y += 1;
			}
			if (PopKeys.isDown(Keyboard.LEFT)) {
				force.x -= 1;
				
			}
			if (PopKeys.isDown(Keyboard.RIGHT)) {
				force.x += 1;
				
			}
			force.normalize();
			force.x *= speed;
			force.y *= speed;
			
			movable.velocity.x += force.x;
			movable.velocity.y += force.y;
		}
		
		public function gotMovement():Boolean {
			return PopKeys.isDown(Keyboard.UP) || PopKeys.isDown(Keyboard.DOWN)  || PopKeys.isDown(Keyboard.LEFT) || PopKeys.isDown(Keyboard.RIGHT);
		}
		
		/* INTERFACE de.popforge.revive.display.IDrawAble */
		
		public function draw(g:Graphics):void 
		{
			
		}
		
		
		
	}

}