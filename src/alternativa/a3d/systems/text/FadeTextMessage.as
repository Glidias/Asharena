package alternativa.a3d.systems.text 
{
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class FadeTextMessage 
	{
		public var fontSetting:FontSettings;
		public var life:Number;
		public var fadeOutTime:Number;
		
		public function FadeTextMessage(fontSetting:FontSettings, life:Number=5, fadeOutTime:Number=1) 
		{
			this.fadeOutTime = fadeOutTime;
			this.life = life;
			this.fontSetting = fontSetting;
			
		}
		
	}

}