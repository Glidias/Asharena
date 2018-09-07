package altern.terrain.macro;

/**
 * TerrainLOD Scene Editor Workflow: 
--------------------------------------------------------------
(Reccomended for handling of scene object placements on up to 1024x1024 subdivision terrain scene within eEditor)

Mainly targeted for Playcanvas..

Outside the Playcanvas editor:
---------------------

A Haxe compile-time macro script is used to process:
- Given HeightMap (+ Moisture Map) of bytes/image, etc. from sys.io files on hard drive.
 
The macro will can be set up to generate files out to hard-drive for uploading to Playcanvas project scene with the following:
- Normalmap
- HeightMap - (Use current .Bin of Bytes with attached JSON Settings file) or (.Bin of Shorts)
- Splatmap (If got Mositure Map) to determine RGB scheme
- JSON Model previews of terrain based off the Heightmap (low-res and high res)'

with proper file naming conventions/folder stricture.

Inside the Playcanvas editor:
------------------

Drag all required files up to editor files to upload.
Mesh terrain preview chunks jsons are all 128x128 based models. Low res and full detail lod versions available to make ediing more managable. The boilerpalte scene templates have low res entity nodes enabled by default, while the high res ones are disabled.
Quick dev preview mode available within current scene as well during runtime .

_______________________________________

 * @author Glidias
 */
class GenerateFilesMain 
{

	public function new() 
	{
		
	}
	
}