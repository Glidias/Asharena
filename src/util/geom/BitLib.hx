/**
 * ...
 * @author Glenn Ko
 */

package util.geom;

class BitLib 
{
	/** 1 << 00 (0x00000001) */ inline public static var BIT_01 = 1 << 00;
	/** 1 << 01 (0x00000002) */ inline public static var BIT_02 = 1 << 01;
	/** 1 << 02 (0x00000004) */ inline public static var BIT_03 = 1 << 02;
	/** 1 << 03 (0x00000008) */ inline public static var BIT_04 = 1 << 03;
	/** 1 << 04 (0x00000010) */ inline public static var BIT_05 = 1 << 04;
	/** 1 << 05 (0x00000020) */ inline public static var BIT_06 = 1 << 05;
	/** 1 << 06 (0x00000040) */ inline public static var BIT_07 = 1 << 06;
	/** 1 << 07 (0x00000080) */ inline public static var BIT_08 = 1 << 07;
	/** 1 << 08 (0x00000100) */ inline public static var BIT_09 = 1 << 08;
	/** 1 << 09 (0x00000200) */ inline public static var BIT_10 = 1 << 09;
	/** 1 << 10 (0x00000400) */ inline public static var BIT_11 = 1 << 10;
	/** 1 << 11 (0x00000800) */ inline public static var BIT_12 = 1 << 11;
	/** 1 << 12 (0x00001000) */ inline public static var BIT_13 = 1 << 12;
	/** 1 << 13 (0x00002000) */ inline public static var BIT_14 = 1 << 13;
	/** 1 << 14 (0x00004000) */ inline public static var BIT_15 = 1 << 14;
	/** 1 << 15 (0x00008000) */ inline public static var BIT_16 = 1 << 15;
	/** 1 << 16 (0x00010000) */ inline public static var BIT_17 = 1 << 16;
	/** 1 << 17 (0x00020000) */ inline public static var BIT_18 = 1 << 17;
	/** 1 << 18 (0x00040000) */ inline public static var BIT_19 = 1 << 18;
	/** 1 << 19 (0x00080000) */ inline public static var BIT_20 = 1 << 19;
	/** 1 << 20 (0x00100000) */ inline public static var BIT_21 = 1 << 20;
	/** 1 << 21 (0x00200000) */ inline public static var BIT_22 = 1 << 21;
	/** 1 << 22 (0x00400000) */ inline public static var BIT_23 = 1 << 22;
	/** 1 << 23 (0x00800000) */ inline public static var BIT_24 = 1 << 23;
	/** 1 << 24 (0x01000000) */ inline public static var BIT_25 = 1 << 24;
	/** 1 << 25 (0x02000000) */ inline public static var BIT_26 = 1 << 25;
	/** 1 << 26 (0x04000000) */ inline public static var BIT_27 = 1 << 26;
	/** 1 << 27 (0x08000000) */ inline public static var BIT_28 = 1 << 27;
	/** 1 << 28 (0x10000000) */ inline public static var BIT_29 = 1 << 28;
	/** 1 << 29 (0x20000000) */ inline public static var BIT_30 = 1 << 29;
	/** 1 << 30 (0x40000000) */ inline public static var BIT_31 = 1 << 30;
	
	#if neko
	/** 0x7FFFFFFF */ 			inline public static var ALL = -1;
	#else
	/** 1 << 31 (0x80000000) */ inline public static var BIT_32 = 1 << 31;
	/** 0xFFFFFFFF */ 			inline public static var ALL = -1;
	#end
	
	/** Returns true if at least one bit of <i>bits</i> in <i>x</i> is 1. */
	inline public static function hasBits(x:Int, bits:Int):Bool { return (x & bits) != 0; }
	
	/** Returns true if all <i>bits</i> in <i>x</i> are 1. */
	inline public static function hasAllBits(x:Int, bits:Int):Bool { return (x & bits) == bits; }
	
	/** Sets all <i>bits</i> in <i>x</i> to 1. */
	inline public static function setBits(x:Int, bits:Int):Int { return x | bits; }
	
	/** Sets all <i>bits</i> in <i>x</i> to 0. */
	inline public static function clrBits(x:Int, bits:Int):Int
	{
		#if neko
		return x.ofInt().and(bits.ofInt().complement()).toInt();
		#else
		return x & ~bits;
		#end
	}
	
	/** Flips all <i>bits</i> in <i>x</i>. */
	inline public static function invBits(x:Int, bits:Int):Int { return x ^ bits; }


}