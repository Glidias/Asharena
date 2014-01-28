package de.popforge.revive.resolve
{
	import de.popforge.revive.member.MovableCircle;
	import de.popforge.revive.member.MovableParticle;
	import de.popforge.revive.member.MovableSegment;
	
	public interface IDynamicIntersectionTestAble
	{
		function dIntersectMovableParticle( particle: MovableParticle, remainingFrameTime: Number ): DynamicIntersection;
		function dIntersectMovableCircle( circle: MovableCircle, remainingFrameTime: Number ): DynamicIntersection;
		function dIntersectMovableSegment( segment: MovableSegment, remainingFrameTime: Number ): DynamicIntersection;
	}
}