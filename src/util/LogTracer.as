package util 
{
	/**
	 * Allows one to replace logging methods to something else..
	 * @author Glenn Ko
	 */
	public class LogTracer 
	{
		public static var log:Function = trace;
		
		public function LogTracer() 
		{
			
		}
		
	}

}