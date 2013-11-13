package hashds;

import de.polygonal.ds.mem.BitMemory;
import de.polygonal.ds.mem.MemoryManager;
import hashds.ds.alchemy.AlchemyUtil;
import hashds.ds.alchemy.ColorMap;
import hashds.ds.alchemy.FullColorMap;
import hashds.ds.alchemy.GrayscaleMap;
import hashds.ds.alchemy.ShortHeightMap;


/**
 * Compiles with Haxe v3
 * @author Glenn Ko
 */
class HashDSMainAlchemy
{
	public function new() 
	{
	
		GrayscaleMap;
		FullColorMap;
		ShortHeightMap;
		ColorMap;
		AlchemyUtil;
		BitMemory;
		
		#if alchemy
		MemoryManager;
		#end

	}
	
	public static function main():Void {
		
		
	}
	
	
	
}