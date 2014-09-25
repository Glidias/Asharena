package alternativa.a3d.objects 
{
	import alternativa.a3d.materials.HealthBarFillMaterial;
	import alternativa.engine3d.alternativa3d;
	import alternativa.engine3d.core.Camera3D;
	import alternativa.engine3d.core.DrawUnit;
	import alternativa.engine3d.core.VertexAttributes;
	import alternativa.engine3d.materials.compiler.Linker;
	import alternativa.engine3d.materials.compiler.Procedure;
	import alternativa.engine3d.materials.FillMaterial;
	import alternativa.engine3d.materials.Material;
	import alternativa.engine3d.objects.Surface;
	import alternativa.engine3d.resources.Geometry;
	import alternativa.engine3d.spriteset.SpriteSet;
	import alternativa.engine3d.spriteset.util.SpriteGeometryUtil;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.geom.Vector3D;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	use namespace alternativa3d;
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class HealthBarSet extends SpriteSet
	{
		static private var GEOMETRY:Geometry;
		static private var NUM_SPRITES:int;
		
		public var maxWidth:Number = Number.MAX_VALUE;
		public var borderThickness:Number = 1;
	
		static public const POSITIONS:Vector.<Number> = new <Number>[-1,1,0,-1,1,1,1,1,1,1,1,0,-1,-1,0,-1,-1,1,-1,1,1,-1,-1,1,1,-1,0,1,-1,1,1,1,1,1,-1,1    ,-1,1,-1,  -1,1,1,  -1,-1,1,  -1,-1,-1];
		static public const INDICES:Vector.<uint> = new <uint>[7,8,9,7,4,8,10,8,3,10,11,8,0,2,3,0,1,2,0,5,6,0,4,5  ,12,13,15, 13,14,15];
		public var fillMaterial:Material;
		
		public function HealthBarSet(numSprites:int, outlineMaterial:Material, width:Number, maxWidth:Number, height:Number,  geometry:Geometry=null ) 
		{


			super(numSprites, true, outlineMaterial, width, height, 110, 1, (geometry != null ? geometry : getGeometry(120)) );
			this.maxWidth = maxWidth;
				 NUM_VERTICES_PER_SPRITE = POSITIONS.length /3;
					NUM_TRIANGLES_PER_SPRITE = INDICES.length / 3;
					
		}
		
		
		 alternativa3d override function setTransformConstants(drawUnit:DrawUnit, surface:Surface, vertexShader:Linker, camera:Camera3D):void {
			drawUnit.setVertexBufferAt(vertexShader.getVariableIndex("joint"), geometry.getVertexBuffer(SpriteGeometryUtil.ATTRIBUTE), geometry._attributesOffsets[SpriteGeometryUtil.ATTRIBUTE], Context3DVertexBufferFormat.FLOAT_1);
			
			drawUnit.setVertexConstantsFromNumbers(vertexShader.getVariableIndex("cameraPos"), cameraToLocalTransform.d, cameraToLocalTransform.h, cameraToLocalTransform.l, camera.focalLength);	
			drawUnit.setVertexConstantsFromNumbers(vertexShader.getVariableIndex("up"), -cameraToLocalTransform.b, -cameraToLocalTransform.f, -cameraToLocalTransform.j, 0)
				
			drawUnit.setVertexConstantsFromNumbers(vertexShader.getVariableIndex("right"), cameraToLocalTransform.a, cameraToLocalTransform.e, cameraToLocalTransform.i, 2);  
			
			drawUnit.setVertexConstantsFromNumbers(vertexShader.getVariableIndex("spriteSet"), width*.5, height*.5, maxWidth*.5, borderThickness);  
			drawUnit.setVertexConstantsFromVector(0, toUploadSpriteData, toUploadNumSprites*NUM_REGISTERS_PER_SPR ); 
		}
		
		/**
		 *  Randomise positions of sprites of spriteData, assuming 1st register of each sprite refers to it's x,y,z position. Good for previewing spriteset.
		 * @param	mask		A bitmask to PREVENT randomisation, and assign maskValue instead. Mask bit for 1,2,4 for x,y,z respectively.
		 * @param	maskValue	If mask hits, what value to set
		 * @param	range		The diameter width range of random spread
		 * @param	offsetX		
		 * @param	offsetY
		 * @param	offsetZ
		 */
		override public function randomisePositions(mask:int = 0, maskValue:Number = 0, range:Number = 1200, offsetX:Number = 0, offsetY:Number = 0, offsetZ:Number = 0 ):void {
			var multiplier:int = NUM_REGISTERS_PER_SPR * 4;
			var hRange:Number = range * .5;
			for (var i:int = 0; i < _numSprites; i++ ) {
				var baseI:int = i * multiplier;
				spriteData[baseI] = (mask & 1) ? maskValue :  -hRange + Math.random() * range  +offsetX;
				spriteData[baseI + 1] = (mask & 2) ? maskValue : -hRange + Math.random() * range+offsetY;
				spriteData[baseI + 2] = (mask & 4) ? maskValue : -hRange +  Math.random() * range +offsetZ;
				spriteData[baseI + 3] = 20;// width * .5;
			}
		}
		
		 public function testPositions( mask:int=0):void {
			var multiplier:int = NUM_REGISTERS_PER_SPR * 4;

			for (var i:int = 0; i < _numSprites; i++ ) {
				var baseI:int = i * multiplier;
				//spriteData[baseI] = 20*i;
				//spriteData[baseI + 1] =20*i;
				spriteData[baseI + 2] = 20*i;
				spriteData[baseI + 3] = 20;// width * .5;
			}
		}
		
		public static function getGeometry(numSprites:int = 120):Geometry {
			if (GEOMETRY != null && NUM_SPRITES >= numSprites) return GEOMETRY;
			
			NUM_SPRITES = numSprites;
			
			
			var geometry:Geometry = new Geometry();
			 var attributes:Array = [];
			 var ATTRIBUTE:uint =  SpriteGeometryUtil.ATTRIBUTE;
			 
			  attributes[0] = VertexAttributes.POSITION;
			  attributes[1] = VertexAttributes.POSITION;
			  attributes[2] = VertexAttributes.POSITION;
			  attributes[3] = VertexAttributes.TEXCOORDS[0];
			  attributes[4] = VertexAttributes.TEXCOORDS[0];
			  attributes[5] = ATTRIBUTE;
			  
			
			  var vertices:ByteArray = new ByteArray();
			  vertices.endian = Endian.LITTLE_ENDIAN;
			
			  var pos:Vector.<Number> = POSITIONS;
			   var uvs:Vector.<Number> =  new <Number>[ 0,0,0.25,0.25,0.75,0.25,1,0,0,1,0.25,0.75,0.25,0.25,0.25,0.75,1,1,0.75,0.75,0.75,0.25,0.75,0.75,  -1,-1, -1,-1, -1,-1, -1,-1];
			  var indices:Vector.<uint> = INDICES;
			  

			  var numGeomVertices:int =  pos.length / 3;			
				
			  var i:int;
			  var v:int;
			  for (i = 0; i<numSprites;i++) {
				 for (v= 0; v < numGeomVertices; v++) {
					vertices.writeFloat(pos[v*3]);
					vertices.writeFloat(pos[v*3+1]);
					vertices.writeFloat(pos[v*3+2]);
					
					vertices.writeFloat(uvs[v*2]);
					vertices.writeFloat(uvs[v * 2 + 1]);
					
					vertices.writeFloat(i);

				 }
			}
			
			var count:int = 0;
			var dupIndices:Vector.<uint> = new Vector.<uint>();
			for (i = 0; i < numSprites; i++ ) {
				var baseI:int =  numGeomVertices * i;
				 for (v = 0; v < indices.length; v++) {
					dupIndices[count++] =baseI + indices[v];
				 }
			}
		
			geometry._indices = dupIndices;
			
			geometry.addVertexStream(attributes);
			geometry._vertexStreams[0].data = vertices;
			geometry._numVertices = numSprites * numGeomVertices;
			
		//	throw new Error(geometry.getAttributeValues(ATTRIBUTE));
	
			 GEOMETRY  = geometry;
			 return geometry;
		}
		
		override protected function getViewAlignedTransformProcedure(maxSprites:int):Procedure {
			var key:String = maxSprites + "_" + (maxSprites * NUM_REGISTERS_PER_SPR) + "_view";
			var res:Procedure = _transformProcedures[key];
			if (res != null) return res;
			res = _transformProcedures[key] = new Procedure(null, "HealthBarSetTransformProcedure");
			
			
			res.compileFromArray([
				"mov t2, c[a0.x].xyzw",  // origin position in local coordinate space
				
				//"mov t1, t2",  //dummy declaration // not needed later change
				"sub t1.xyz, t2.xyz, c4.xyz",  // diff vector from camera to targetPosition
				"nrm t0.xyz, t1.xyz", // normalize it
				"dp3 t1.w, t0.xyz, t1.xyz",    // dp3 of normalized vector against diff vector  (should yeield postivie dist)
				//"abs t1.w, t1.w", // distance from camera
				"div t1.w, c4.w, t1.w",
				"rcp t1.w, t1.w",  // 1/ (focalLength/cz)  = amout of units per pixel 
				"mov t1.xyz, c3.xyz", // width, height, maxWidth
				"mov t1.x, c3.z",	// move constraint c3.z maxWidth   // remove this to fixWidth
				
				"mul t1.xyz, t1.xyz, t1.www",  // convert pixel space to unit space  // to get constraints
	
				"frc t0.w, t2.w",	
				"sub t2.w, t2.w, t0.w",  // get whole portion
				
				"min t1.x, t2.w, t1.x",   // apply maxWidth constraint x onto actual t2.spriteWidth   // remove this to fixWidth
				"mul t1.z, c3.x, t1.w",  // set minWidth constraint to unit space
				
				
				"max t1.x, t1.x, t1.z", // apply minWidth constraint   // remove this to fixWidth
				//"sge t1.z, t1.x, t1.z",		// or hide vis
				//"mul t1.x, t1.x, t1.z",
				
				"mul t0.w, t0.w, t1.x",  // apply health ratio width onto target display width to get actual health width
				"sub t0.w, t0.w, t1.w",  // remove off thickness padding
			
				"mul t0.w, t0.w, c2.w",  // double up width to fill fullbar 
			
				
				"mul t0.xyz, c2.xyz, i0.xxx",
				"mul t0.xyz, t0.xyz, t1.xxx", // scale according to spriteset setting (right vector)
				"add t2.xyz, t2.xyz, t0.xyz",
				
				//"add t2.w, i0.z, c2.w",
				"abs t2.w, i0.z",  // convert i0.z=-1 to 1 if required...
				
				// move inner border
				"mul t0.xyz, t0.xyz, t2.www",
				"nrm t0.xyz, t0.xyz",
				"mul t0.xyz, t0.xyz, t1.www",
				"mul t0.xyz, t0.xyz, c3.www",
				"sub t2.xyz, t2.xyz, t0.xyz",
				
				// move up health guage along right vector
				"mul t0.xyz, c2.xyz, t0.www",
				"slt t0.w, i0.z, c1.w",
				"mul t0.xyz, t0.xyz, t0.www",  
				"add t2.xyz, t2.xyz, t0.xyz",
				
				
				// ------------------------
				
				"mul t0.xyz, c1.xyz, i0.yyy",
				"mul t0.xyz, t0.xyz, t1.yyy",  // scale according to spriteset setting  (up vector)
				"add t2.xyz, t2.xyz, t0.xyz",
				
				// move inner border
				"mul t0.xyz, t0.xyz, t2.www",
				"nrm t0.xyz, t0.xyz",
				"mul t0.xyz, t0.xyz, t1.www",
				"mul t0.xyz, t0.xyz, c3.www",
				"sub t2.xyz, t2.xyz, t0.xyz",
				
				
				// DONE!
				"mov t2.w, i0.w",	
				"mov o0, t2",
				
				"#a0=joint",
				//"#c0=array",
				"#c1=up", 
				"#c2=right",
				"#c3=spriteSet", 
				"#c4=cameraPos"
			]);
		
			res.assignConstantsArray(maxSprites*NUM_REGISTERS_PER_SPR);
		
			return res;
		}
		
		
		
		
		
	}

}