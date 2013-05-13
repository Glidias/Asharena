Asharena
==========
	
A WIP 3d gladiatorial/sandbox/open-world rpg game example using the Ash framework ( http://github.com/nadako/Ash-HaXe ) and Ash3D boiler-plate( http://github.com/Glidias/ash3d ). 
	
Basic core component/system & boilerplate game logic are all coded in Haxe (which can act as a base for other target platforms..), but any engine/platform-dependant implementations (rendering, particles, etc.) are still coded in pure Flash/AS3, currently targetting Alternativa3D engine. It's possible to use externs in Haxe, but accessing alternativa3d namespaced items for Alternativa3D isn't easy to do, and so having a means to deliver the final output through Flash/AIR is still the best option. After all, I already have a LOD terrain engine in Alternativa3D ( http://github.com/Glidias/alternterrain ) that is to be integrated into the sandbox.
	
Some files to take note:
	
1) Arena_HaxeSWC.hxproj - This is used to test-run the core component/system game logic for Flash under Haxe. 

2) src/compileswc.hxml  - Run this file to immediatley compile Haxe source code from anywhere into a SWC that can be used in  AS3 projects.

3) Arena_AS3.as3proj -  AS3 Project. This is for performing the final compile to deliver under Flash/ Alternativa3D.

Any models and animations are from Gladiator HL mod http://www.moddb.com/mods/gladiator1 . Used with permission.