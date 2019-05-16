package altern.collisions.dbvt;
import components.BoundBox;

/**
 * An abstract AbstractAABB used by saharan's OimoHX to help link to existing altern.BoundBox
 * @author saharan
 * @author Glidias
 */
abstract AbstractAABB(BoundBox)
{
	public var minX(get, never):Float;
	inline function get_minX():Float
	{
		return this.minX;
	}
	public var minY(get, never):Float;
	inline function get_minY():Float 
	{
		return this.minY;
	}
	public var minZ(get, never):Float;
	inline function get_minZ():Float
	{
		return this.minZ;
	}
	public var maxX(get, never):Float;
	inline function get_maxX():Float
	{
		return this.maxX;
	}
	public var maxY(get, never):Float;
	inline function get_maxY():Float 
	{
		return this.maxY;
	}
	public var maxZ(get, never):Float;
	inline function get_maxZ():Float 
	{
		return this.maxZ;
	}

	public function new(minX:Float = 0, maxX:Float = 0, minY:Float = 0, maxY:Float = 0, minZ:Float = 0, maxZ:Float = 0) 
	{
		var b = new BoundBox();
		b.minX = minX;
		b.maxX = maxX;
		b.minY = minY;
		b.maxY = maxY;
		b.minZ = minZ;
		b.maxZ = maxZ;
		this = b;
	}
	
	public function init(minX:Float = 0, maxX:Float = 0, minY:Float = 0, maxY:Float = 0, minZ:Float = 0, maxZ:Float = 0) {
        this.minX = minX;
        this.maxX = maxX;
        this.minY = minY;
        this.maxY = maxY;
        this.minZ = minZ;
        this.maxZ = maxZ;
    }

	/**
	 * Set this AbstractAABB to the combined AbstractAABB of aabb1 and aabb2.
	 * @param	aabb1
	 * @param	aabb2
	 */
    inline public function combine(aabb1:AbstractAABB, aabb2:AbstractAABB) {
        if (aabb1.minX < aabb2.minX) {
            this.minX = aabb1.minX;
        }
        else {
            this.minX = aabb2.minX;
        }
        if (aabb1.maxX > aabb2.maxX) {
            this.maxX = aabb1.maxX;
        }
        else {
            this.maxX = aabb2.maxX;
        }
        if (aabb1.minY < aabb2.minY) {
            this.minY = aabb1.minY;
        }
        else {
            this.minY = aabb2.minY;
        }
        if (aabb1.maxY > aabb2.maxY) {
            this.maxY = aabb1.maxY;
        }
        else {
            this.maxY = aabb2.maxY;
        }
        if (aabb1.minZ < aabb2.minZ) {
            this.minZ = aabb1.minZ;
        }
        else {
            this.minZ = aabb2.minZ;
        }
        if (aabb1.maxZ > aabb2.maxZ) {
            this.maxZ = aabb1.maxZ;
        }
        else {
            this.maxZ = aabb2.maxZ;
        }
        var margin:Float = 0;
        this.minX -= margin;
        this.minY -= margin;
        this.minZ -= margin;
        this.maxX += margin;
        this.maxY += margin;
        this.maxZ += margin;
    }
	
	inline public function matchWith(aabb:AbstractAABB):Void {
		this.minX = aabb.minX;
		this.minY = aabb.minY;
		this.minZ = aabb.minZ;
		
		this.maxX = aabb.maxX;
		this.maxY = aabb.maxY;
		this.maxZ = aabb.maxZ;
		
	}
    
    /**
	 * Get the surface area.
	 * @return
	 */
    inline public function surfaceArea():Float {
        var h:Float = this.maxY - this.minY;
        var d:Float = this.maxZ - this.minZ;
        return 2 * ((this.maxX - this.minX) * (h + d) + h * d);
    }

	 
    inline public function intersectsWithPoint(x:Float, y:Float, z:Float):Bool {
        return x >= this.minX && x <= this.maxX && y >= this.minY && y <= this.maxY && z >= this.minZ && z <= this.maxZ;
	}
	
}