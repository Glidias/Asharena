package ashpc;


// -- usually core (though Scale can usually be omitted as it's rather uncommon)
import components.Pos;
import components.Rot;
import components.Vel;
import components.Scale;

// -- This can be omitted if you aren't coding any IAnimatable stuff of your own.
import systems.animation.IAnimatable;

// -- all required for player movement + on surface clamping (usually with Gravity) + KeyPoll/Keyindings
import components.Ellipsoid;
import components.CollisionResult;
import components.MoveResult;

import components.controller.SurfaceMovement;
import components.DirectionVectors;

// import input.KeyPoll;  // TODO: cross-platform version @:pcSingleton

// -- jumping/jetting ability
import components.Jump;

// -- physic effects
import components.Gravity;
import components.Damp;
import components.Bounce;
import components.Sticky;

// -- signals
import components.ActionSignal;
import components.ActionIntSignal; 
import components.ActionUIntSignal;


// -- dynamic collisions
import components.MovableCollidable;
import components.ImmovableCollidable;

// -- health tracking
import components.Health;

// -- for tweening
import components.tweening.Tween;

/**
 * ...
 * @author Glidias
 */
class Components
{

	public function new() 
	{
		
	}
	
}