package de.popforge.revive.forces 
{
	import de.popforge.revive.display.IDrawAble;
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
		
		public function solve():void 
		{
			movable.velocity.x = 0;
			movable.velocity.y = 0;
			if (PopKeys.isDown(Keyboard.UP)) {
				movable.velocity.y -= 1;
				
			}
			if (PopKeys.isDown(Keyboard.DOWN)) {
				movable.velocity.y += 1;
			}
			if (PopKeys.isDown(Keyboard.LEFT)) {
				movable.velocity.x -= 1;
				
			}
			if (PopKeys.isDown(Keyboard.RIGHT)) {
				movable.velocity.x += 1;
				
			}
			movable.velocity.normalize();
			movable.velocity.x *= speed;
			movable.velocity.y *= speed;
		}
		
		/* INTERFACE de.popforge.revive.display.IDrawAble */
		
		public function draw(g:Graphics):void 
		{
			
		}
		
		
		
	}

}