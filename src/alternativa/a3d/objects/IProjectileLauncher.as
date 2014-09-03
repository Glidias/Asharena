package alternativa.a3d.objects 
{
	import flash.geom.Vector3D;
	
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public interface IProjectileLauncher 
	{
		
		function launchNewProjectile(startPosition:Vector3D, endPosition:Vector3D, speed:Number = 1044):Number;
		
		function update(time:Number):void;
		
		function getLastLaunchedIndex():int;
		
		function getIndexSize():int;
		
		function getDataVector():Vector.<Number>;
		
		function getTimeStampOffset():int;
		
		function getTotalTimeOffset():int;
		
		function getTime():Number;
		
		function getEndPositionOffset():int;
		
	}
	
}