package hashds;

import de.polygonal.core.math.random.ParkMiller31;
import de.polygonal.ds.mem.BitMemory;
import de.polygonal.ds.mem.MemoryManager;
import flash.system.ApplicationDomain;
import flash.utils.ByteArray;
import flash.utils.Endian;
import hashds.ds.alchemy.AlchemyUtil;
import hashds.ds.alchemy.ColorMap;
import hashds.ds.alchemy.FullColorMap;
import hashds.ds.alchemy.GrayscaleMap;
import hashds.ds.alchemy.ShortHeightMap;
import hashds.ds.FractalNoise;


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
		ParkMiller31;
		FractalNoise;
		
		#if alchemy
		MemoryManager;
		#end

	}
	
	public static function main():Void {
		
	}
	
	
	
}