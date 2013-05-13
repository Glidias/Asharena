package systems.player.a3d 
{
	import alternativa.engine3d.animation.AnimationClip;
	import alternativa.engine3d.animation.AnimationNotify;
	import alternativa.engine3d.animation.events.NotifyEvent;
	import flash.events.Event;
	/**
	 * ...
	 * @author Glidias
	 */
	public class AnimEndLoop 
	{
		private var anim:AnimationClip;
		private var notifier:AnimationNotify;
		
		public function AnimEndLoop(anim:AnimationClip) 
		{
			this.anim = anim;
			anim.loop = false;
			notifier = anim.addNotifyAtEnd();
			notifier.addEventListener(NotifyEvent.NOTIFY, resetAnimTime);
		}
		
		private function resetAnimTime(e:NotifyEvent):void {
			anim.time = 0;
		}
		
		public function destroy():void {
			notifier.removeEventListener(NotifyEvent.NOTIFY, resetAnimTime);
		}
		
		
		
	}

}