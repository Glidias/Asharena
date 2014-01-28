package de.popforge.revive.resolve
{
	import de.popforge.revive.member.MovableCircle;
	import de.popforge.revive.member.MovableParticle;
	import de.popforge.revive.member.MovableSegment;
	
	public interface IResolvable
	{
		function resolveMovableParticle( particle: MovableParticle ): void;
		function resolveMovableCircle( circle: MovableCircle ): void;
		function resolveMovableSegment( segment: MovableSegment ): void;
	}
}