package views.ui.indicators 
{
	import saboteur.util.SaboteurPathUtil;
	import views.ui.ColorShape;
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class CanBuildIndicator extends ColorShape
	{
		//private var _pathUtil:SaboteurPathUtil;
		
		public function CanBuildIndicator() 
		{
			//_pathUtil = SaboteurPathUtil.getInstance();
		}
		
		public function setCanBuild(endPts:int):void {
			//endPts & SaboteurPathUtil.NORRTH
		//	if (endPts == 0) throw new Error("no end points deteceted along valid path!");
			color = endPts >= 0 ? endPts != 0 ? 0x00FF00  : 0x33AA33  :    0xFF0000 ;
		}
		
	}

}