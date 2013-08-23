package alternativa.engine3d.spriteset.util 
{
	import alternativa.engine3d.core.VertexAttributes;
	import alternativa.engine3d.resources.Geometry;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.Endian;
	import alternativa.engine3d.alternativa3d;
	import flash.utils.getQualifiedClassName;
	use namespace alternativa3d;
	
	/**
	 * Utility to help work with Sprite3DSet and your own custom sprite materials!
	 * @author Glenn Ko
	 */
	public class SpriteGeometryUtil 
	{
		
		public static const REQUIRE_UVs:uint = 1;
		public static const REQUIRE_NORMAL:uint = 2;
		public static const REQUIRE_TANGENT:uint = 4;
		
		public static const ATTRIBUTE:uint = 20;  // same attribute as used in MeshSet
		
		public static var MATERIAL_REQUIREMENTS:Dictionary = new Dictionary();
		
		public static function guessRequirementsAccordingToMaterial(material:*):int {
			if (MATERIAL_REQUIREMENTS && MATERIAL_REQUIREMENTS[material.constructor]) return MATERIAL_REQUIREMENTS[material.constructor];
			var classeName:String = getQualifiedClassName(material).split("::").pop();
			if (MATERIAL_REQUIREMENTS && MATERIAL_REQUIREMENTS[classeName]) return MATERIAL_REQUIREMENTS[classeName];
			
			switch (classeName) {
				case "Material":
				case "FillMaterial": 
						return 0;  
				case "TextureMaterial": return ( REQUIRE_UVs );
				case "StandardMaterial": return ( REQUIRE_UVs ); return ( REQUIRE_UVs | REQUIRE_NORMAL | REQUIRE_TANGENT );
				default: return (  REQUIRE_UVs | REQUIRE_NORMAL | REQUIRE_TANGENT );
			}
		}
		
		public static function createNormalizedSpriteGeometry(numSprites:int, indexOffset:int, requirements:uint = 1, scale:Number=1, originX:Number=0, originY:Number=0, indexMultiplier:int=1):Geometry 
		{
			var geometry:Geometry = new Geometry();
			var attributes:Array = [];
			var i:int = 0;
			
			originX *= scale;
			originY *= scale;
			
			var indices:Vector.<uint> = new Vector.<uint>();
			var vertices:ByteArray = new ByteArray();
			vertices.endian = Endian.LITTLE_ENDIAN;
			
			var requireUV:Boolean = (requirements & REQUIRE_UVs)!=0;
			var requireNormal:Boolean = (requirements & REQUIRE_NORMAL)!=0;
			var requireTangent:Boolean = (requirements & REQUIRE_TANGENT)!=0;
			
			attributes[i++] = VertexAttributes.POSITION;
			attributes[i++] = VertexAttributes.POSITION;
			attributes[i++] = VertexAttributes.POSITION;
			if ( requireUV) {
				attributes[i++] = VertexAttributes.TEXCOORDS[0];
				attributes[i++] = VertexAttributes.TEXCOORDS[0];
			}
			if (requireNormal) {
				attributes[i++] = VertexAttributes.NORMAL;
				attributes[i++] = VertexAttributes.NORMAL;
				attributes[i++] = VertexAttributes.NORMAL;
			}
			if ( requireTangent) {
				attributes[i++] = VertexAttributes.TANGENT4;
				attributes[i++] = VertexAttributes.TANGENT4;
				attributes[i++] = VertexAttributes.TANGENT4;
				attributes[i++] = VertexAttributes.TANGENT4;
			}
			attributes[i++] = ATTRIBUTE;
			
			
			
		
			for (i = 0; i<numSprites;i++) {
				vertices.writeFloat(-1*scale - originX);
				vertices.writeFloat(-1*scale - originY);
				vertices.writeFloat(0);
				if ( requireUV) {
					vertices.writeFloat(0);
					vertices.writeFloat(1);
				}
				if ( requireNormal) {
					vertices.writeFloat(0);
					vertices.writeFloat(0);
					vertices.writeFloat(1);
				}
				if ( requireTangent) {
					vertices.writeFloat(1);
					vertices.writeFloat(0);
					vertices.writeFloat(0);
					vertices.writeFloat(-1);
				}
				vertices.writeFloat(i*indexMultiplier+indexOffset);
				
				vertices.writeFloat(1*scale - originX);
				vertices.writeFloat(-1*scale - originY);
				vertices.writeFloat(0);
				if ( requireUV) {
					vertices.writeFloat(1);
					vertices.writeFloat(1);
				}
				if ( requireNormal) {
					vertices.writeFloat(0);
					vertices.writeFloat(0);
					vertices.writeFloat(1);
				}
				if ( requireTangent) {
					vertices.writeFloat(1);
					vertices.writeFloat(0);
					vertices.writeFloat(0);
					vertices.writeFloat(-1);
				}
				vertices.writeFloat(i*indexMultiplier+indexOffset);
				
				vertices.writeFloat(1*scale - originX);
				vertices.writeFloat(1*scale - originY);
				vertices.writeFloat(0);
				if ( requireUV) {
					vertices.writeFloat(1);
					vertices.writeFloat(0);
				}
				if ( requireNormal) {
					vertices.writeFloat(0);
					vertices.writeFloat(0);
					vertices.writeFloat(1);
				}
				if ( requireTangent) {
					vertices.writeFloat(1);
					vertices.writeFloat(0);
					vertices.writeFloat(0);
					vertices.writeFloat(-1);
				}
				vertices.writeFloat(i*indexMultiplier+indexOffset);
				
				vertices.writeFloat(-1*scale - originX);
				vertices.writeFloat(1*scale - originY);
				vertices.writeFloat(0);	
				if ( requireUV) {
					vertices.writeFloat(0);
					vertices.writeFloat(0);
				}
				if (requireNormal) {
					vertices.writeFloat(0);
					vertices.writeFloat(0);
					vertices.writeFloat(1);
				}
				if ( requireTangent) {
					vertices.writeFloat(1);
					vertices.writeFloat(0);
					vertices.writeFloat(0);
					vertices.writeFloat(-1);
				}
				vertices.writeFloat(i*indexMultiplier+indexOffset);
				
				var baseI:int = i * 4;
				indices.push(baseI, baseI+1, baseI+3,  baseI+1, baseI+2, baseI+3);
			}
			
		
			geometry._indices = indices;
			
			geometry.addVertexStream(attributes);
			geometry._vertexStreams[0].data = vertices;
			geometry._numVertices = numSprites * 4;
			
			
			return geometry;
		}
		
	}

}