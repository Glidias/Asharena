package arena.systems.islands 
{
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class KDNode
	{
		public var positive:KDNode;
		public var negative:KDNode;
		public var boundMinX:Number;
		public var boundMaxX:Number;
		
		public var boundMinY:Number;
		public var boundMaxY:Number;
		
		
		
		
		
		public var seed:uint;
		public var flags:int;
		public static const FLAG_SEEDED:int = 1;
		public static const FLAG_VERTICAL:int = 2;
		public static const FLAG_CONSIDERSEED:int = 4;
		public static const FLAG_SLAVE:int = 8;   
		
		public var offset:int;
		
		public function setSeed(val:uint):void {
			flags |= FLAG_SEEDED;
			seed = val;
		}
		public function isSeeded():Boolean {
			return flags & FLAG_SEEDED;
		}
		public function get vertical():Boolean {
			return flags & FLAG_VERTICAL;
		}
		public function set vertical(val:Boolean):void {
			if (val) flags |= FLAG_VERTICAL
			else flags &= ~FLAG_VERTICAL;
		}
		
			
		
		
		
		public function getMeasuredShortSide():Number {
			return isRectangle() === 1 ? boundMaxY - boundMinY :  boundMaxX - boundMinX; 
		}
		
		public function splitDownLevel():Boolean {
			return flags & FLAG_VERTICAL;
		}
		
		
		
		public function isRectangle():int {  
			return boundMaxY - boundMinY == boundMaxX - boundMinX ? 0 : boundMaxY - boundMinY < boundMaxX - boundMinX ? 1 : 2;
		}
		
		public function KDNode() {
			flags  = 0;
			offset = 0;
		}
		
		public function transferSeedTo(node:KDNode):uint 
		{
			
			node.setSeed(seed);
			flags &= ~FLAG_SEEDED;
			flags &= ~FLAG_CONSIDERSEED;
			
			return seed;
		}
		
		
	}
}