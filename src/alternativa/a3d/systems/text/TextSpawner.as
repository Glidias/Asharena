package alternativa.a3d.systems.text 
{
	import ash.core.Engine;
	import ash.core.Entity;
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class TextSpawner 
	{
		private var engine:Engine;
		
		public function TextSpawner(engine:Engine) 
		{
			this.engine = engine;
		}
		
		public function addFadeTextMessage(fadeTxtMessage:FadeTextMessage):void {
			var ent:Entity = new Entity();
			ent.add(fadeTxtMessage);
			engine.addEntity(ent);
		}
		
		public function addTextBoxChannel(textBoxChannel:TextBoxChannel):void {
			var ent:Entity = new Entity();
			ent.add(textBoxChannel);
			engine.addEntity(ent);
		}
		
	}

}