package altern.terrain;

/**
 * ...
 * @author Glidias
 */
class TerrainChunkState 
{

	public function new() 
	{
		
	}
	
	//	public var vertexBuffer:VertexBuffer3D;

	public var index:Int; 
	public var enabledFlags:Int;
	public var square:QuadSquareChunk;
	public var next:TerrainChunkState;
	public var prev:TerrainChunkState;
	public var parent:TerrainChunkStateList;
	public var head : TerrainChunkState;
	public var tail : TerrainChunkState;

		
	
}