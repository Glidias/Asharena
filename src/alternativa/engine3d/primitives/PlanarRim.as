package alternativa.engine3d.primitives 
{
	import alternativa.engine3d.alternativa3d;
	import alternativa.engine3d.core.Camera3D;
	import alternativa.engine3d.core.DrawUnit;
	import alternativa.engine3d.core.VertexAttributes;
	import alternativa.engine3d.materials.compiler.Linker;
	import alternativa.engine3d.materials.compiler.Procedure;
	import alternativa.engine3d.materials.Material;
	import alternativa.engine3d.objects.Mesh;
	import alternativa.engine3d.objects.Surface;
	import alternativa.engine3d.resources.Geometry;
	import alternativa.engine3d.utils.GeometryUtil;
	import alternativa.engine3d.alternativa3d;
	import flash.display3D.Context3DVertexBufferFormat;
	use namespace alternativa3d;
	/**
	 * ...
	 * @author Glidias
	 */
	public class PlanarRim extends Mesh
	{	
		private  var _material : Material 
		public var thickness:Number;
		public var radius:Number;
		public static const ATTRIBUTE:uint = GeometryUtil.ATTRIBUTE;
		private static var TRANSFORM_PROCEDURE:Procedure;
		
		
		public function PlanarRim(sides:int=6, radius:Number=128, thickness:Number=24, semi:Boolean=true, material:Material=null, doubleSided:Boolean=true, angleOffset:Number=0, heightOffset:Number=0) 
		{
			this.radius = radius;
			this.thickness = thickness;
			buildGeometry(sides, radius, thickness, semi, doubleSided, angleOffset, heightOffset); 
			addSurface(material, 0, geometry.numTriangles);
			transformProcedure = getTransformProcedure();
			
		}
		
			alternativa3d override function setTransformConstants(drawUnit:DrawUnit, surface:Surface, vertexShader:Linker, camera:Camera3D):void {
			
			
			drawUnit.setVertexBufferAt(vertexShader.getVariableIndex("joint"), geometry.getVertexBuffer(ATTRIBUTE), geometry._attributesOffsets[ATTRIBUTE], Context3DVertexBufferFormat.FLOAT_1);
	
			drawUnit.setVertexConstantsFromNumbers( vertexShader.getVariableIndex("cVars"), radius, radius, radius, thickness);
			
		}
		
		private  function buildGeometry(circleSides:int, origRadius:Number, thickness:Number, semi:Boolean, doubleSided:Boolean,angleOffset:Number, heightOffset:Number) : void  { 
			var len:int;
			var tanLen:Number;
			var normLen:Number;
			var radius:Number;
			var y:Number;
			var x:Number;
			var z:Number;
			var verangle:Number;
			
			if (semi) circleSides++;
			
			var attributes:Array = [ 
						  VertexAttributes . POSITION , 
						  VertexAttributes . POSITION , 
						  VertexAttributes . POSITION , 
						  VertexAttributes . TEXCOORDS [ 0 ] , 
						  VertexAttributes . TEXCOORDS [ 0 ] , 
						  VertexAttributes . NORMAL , 
						  VertexAttributes . NORMAL , 
						  VertexAttributes . NORMAL , 
						  VertexAttributes . TANGENT4 , 
						  VertexAttributes . TANGENT4 , 
						  VertexAttributes . TANGENT4 , 
						  VertexAttributes . TANGENT4,
						  ATTRIBUTE
						 ] ; 
						 
			var vertices:Vector.<Number>; 
			var vertexNormals:Vector.<Number>; 
			var vertexTangents:Vector .<Number>; 
			var vertexUvs:Vector.<Number>;
			var indices:Vector.<uint>; 
			var i:uint, triIndex:uint = 0; 
			var numVerts: uint = 0; 
			var numTangents:uint = 0;
			var doubleSidedMult:int = doubleSided ? 2 : 1;
			
			if (semi) angleOffset += Math.PI / circleSides * .5;
			
			
			vertices = new Vector.<Number>( circleSides * 3*2 *doubleSidedMult,  true ) ; 
			vertexNormals = new Vector.<Number>( circleSides * 3 * 2 *doubleSidedMult,  true ) ; 
			vertexTangents = new Vector.<Number>( circleSides * 4 * 2 *doubleSidedMult,  true ) ; 
			vertexUvs = new Vector.<Number>(circleSides * 2 * 2 *doubleSidedMult, true);
			indices = new Vector.<uint>();
			
			var numUvs:int = 0;
			
			var diameterMult:Number = origRadius * 2;
			var yDiameterMult:Number = semi ? -origRadius : -origRadius * 2;
			
			diameterMult = 1 / diameterMult;
			yDiameterMult = 1 / yDiameterMult;
		
			
			var ox:Number = -origRadius;
			var oy:Number = !semi ? -origRadius : 0;
			
			var joints:Vector.<Number> = new Vector.<Number>();
			var numJoints:int = 0;
			
			var coverage:Number = (semi ? 1 : 2) * Math.PI;
			
			var nx:Number = 0;
			var ny:Number = 0;
			var nz:Number = -1;
			var at:Number = -1;
			var bt:Number = 0;
			var ct:Number = 0;
			var dt:Number = -1;
			
			
			/*
				0, 0, -1, -1, 0, 0, -1,
				var temp:int;
				if (reverse) {
					nx = -nx;
					ny = -ny;
					nz = -nz;
					tw = -tw;
					temp = a;
					at = dt;
					dt = temp;
					temp = bt;
					bt = ct;
					ct = temp;
				}
				*/
		
			
			// outer rim of vertices	
			z = 0;
			radius = origRadius;
			for(i = 0; i < circleSides; i++) {
				verangle = coverage * i / circleSides + angleOffset;
				
				x = radius*Math.cos(verangle);
				y = radius * Math.sin(verangle);
				
				normLen = 1/Math.sqrt(x*x + y*y);
				//tanLen = Math.sqrt(y * y + x * x);

				// per vertex
				vertexNormals[numVerts] = nx; //x * normLen;
				vertexTangents[numTangents++] = at;// tanLen > .007 ? -y / tanLen : 1;
				vertices[numVerts++] = x * normLen;
				vertexNormals[numVerts] = ny; //y * normLen;
				vertexTangents[numTangents++] = bt;// tanLen > .007 ? x / tanLen : 0;
				vertices[numVerts++] = y * normLen;
				vertexNormals[numVerts] = nz; // z * normLen;
				vertexTangents[numTangents++] = ct;
				vertexTangents[numTangents++] = dt;
				vertices[numVerts++] = z;
				vertexUvs[numUvs++] = (x - ox) * diameterMult;
				vertexUvs[numUvs++] = (y - oy) * yDiameterMult;
				joints[numJoints++] = 0;
			}
			
			// inner rim of vertices
			radius = origRadius - thickness;
			z = heightOffset;
			for(i = 0; i < circleSides; i++) {
				verangle = coverage * i / circleSides +  angleOffset;

				x = radius*Math.cos(verangle);
				y = radius * Math.sin(verangle);
				
				normLen = 1/Math.sqrt(x*x + y*y);
				//tanLen = Math.sqrt(y * y + x * x);

				// per vertex
				vertexNormals[numVerts] = nx; //x * normLen;
				vertexTangents[numTangents++] = at;// tanLen > .007 ? -y / tanLen : 1;
				vertices[numVerts++] = x * normLen;
				vertexNormals[numVerts] = ny; //y * normLen;
				vertexTangents[numTangents++] = bt;// tanLen > .007 ? x / tanLen : 0;
				vertices[numVerts++] = y * normLen;
				vertexNormals[numVerts] = nz; // z * normLen;
				vertexTangents[numTangents++] = ct;
				vertexTangents[numTangents++] = dt;
				vertices[numVerts++] = z;
				vertexUvs[numUvs++] = (x - ox) * diameterMult;
				vertexUvs[numUvs++] = (y - oy) * yDiameterMult;
				joints[numJoints++] = 1;
			}
			
			// write indices
			len =circleSides-1;
			for (i = 0; i < len; i++) {
				indices[triIndex++] = i;
				indices[triIndex++] = i + 1;
				indices[triIndex++] = i + circleSides;
				
				indices[triIndex++] = i + 1;
				indices[triIndex++] = i + 1 + circleSides;
				indices[triIndex++] = i + circleSides;
			}
			
			if (!semi) {
				indices[triIndex++] = i;
				indices[triIndex++] = i + 1;
				indices[triIndex++] = i + circleSides;
					
				indices[triIndex++] =  circleSides-1;
				indices[triIndex++] =  0;
				indices[triIndex++] = circleSides;
			}
			
			
			// DOUBLE SIDED
			
			if (doubleSided) {  // repeat above process
				
			
				
					nx = -nx;
					ny = -ny;
					nz = -nz;
					dt = -dt;
				
			// outer rim of vertices	
			z = 0;
			radius = origRadius;
			for(i = 0; i < circleSides; i++) {
				verangle = coverage * i / circleSides + angleOffset;
				
				x = radius*Math.cos(verangle);
				y = radius * Math.sin(verangle);
				
				normLen = 1/Math.sqrt(x*x + y*y);
				//tanLen = Math.sqrt(y * y + x * x);

				// per vertex
				vertexNormals[numVerts] = nx; //x * normLen;
				vertexTangents[numTangents++] = at;// tanLen > .007 ? -y / tanLen : 1;
				vertices[numVerts++] = x * normLen;
				vertexNormals[numVerts] = ny; //y * normLen;
				vertexTangents[numTangents++] = bt;// tanLen > .007 ? x / tanLen : 0;
				vertices[numVerts++] = y * normLen;
				vertexNormals[numVerts] = nz; // z * normLen;
				vertexTangents[numTangents++] = ct;
				vertexTangents[numTangents++] = dt;
				vertices[numVerts++] = z;
				vertexUvs[numUvs++] = (x - ox) * diameterMult;
				vertexUvs[numUvs++] = (y - oy) * diameterMult;
				joints[numJoints++] = 0;
			}
			
			// inner rim of vertices
			radius = origRadius - thickness;
			z = 0;
			for(i = 0; i < circleSides; i++) {
				verangle = coverage * i / circleSides +  angleOffset;

				x = radius*Math.cos(verangle);
				y = radius * Math.sin(verangle);
				
				normLen = 1/Math.sqrt(x*x + y*y);
				//tanLen = Math.sqrt(y * y + x * x);

				// per vertex
				vertexNormals[numVerts] = nx; //x * normLen;
				vertexTangents[numTangents++] = at;// tanLen > .007 ? -y / tanLen : 1;
				vertices[numVerts++] = x*normLen;
				vertexNormals[numVerts] = ny; //y * normLen;
				vertexTangents[numTangents++] = bt;// tanLen > .007 ? x / tanLen : 0;
				vertices[numVerts++] = y*normLen;
				vertexNormals[numVerts] = nz; // z * normLen;
				vertexTangents[numTangents++] = ct;
				vertexTangents[numTangents++] = dt;
				vertices[numVerts++] = z;
				vertexUvs[numUvs++] = (x - ox) * diameterMult;
				vertexUvs[numUvs++] = (y - oy) * diameterMult;
				joints[numJoints++] = 1;
			}
			
			// write indices
			len =circleSides-1;
			for (i = 0; i < len; i++) {
				indices[triIndex++] = i + circleSides;
				indices[triIndex++] = i + 1;
				indices[triIndex++] = i;
				
				
				indices[triIndex++] = i + circleSides;
				indices[triIndex++] = i + 1 + circleSides;
				indices[triIndex++] = i + 1;
				
			}
			
			if (!semi) {
				indices[triIndex++] = i + circleSides;
				indices[triIndex++] = i + 1;
				indices[triIndex++] = i;
				
					
				indices[triIndex++] = circleSides;
				indices[triIndex++] =  0;
				indices[triIndex++] =  circleSides-1;
				
			}	
				
			}

 
			geometry = new Geometry();
			geometry.numVertices = circleSides*2*doubleSidedMult;
			geometry.indices = indices;
			geometry.addVertexStream(attributes);
			geometry.setAttributeValues(VertexAttributes.POSITION, vertices);
			geometry.setAttributeValues(VertexAttributes.NORMAL, vertexNormals);
			geometry.setAttributeValues(VertexAttributes.TANGENT4, vertexTangents);
			geometry.setAttributeValues(VertexAttributes.TEXCOORDS[0], vertexUvs);
			geometry.setAttributeValues(ATTRIBUTE, joints);
			//throw new Error(vertexUvs);
			
		
		
		}
		
		private function getTransformProcedure():Procedure {
			if (TRANSFORM_PROCEDURE) return TRANSFORM_PROCEDURE;
			
			var res:Procedure;
			
			res =  new Procedure(null, "PlanarRimTransformProcedure");
			res.compileFromArray(["#a0=joint", "#c1=cVars", 
			"mov t0.xyz, i0.xyz",
			"mul t0.xy, t0.xy, c1.xy",
			"mul t1.xy, i0.xy, c1.ww",
			"mul t1.xy, t1.xy, a0.xx",
			"sub t0.xy, t0.xy, t1.xy",				
			"mov t0.w, i0.w",	
			"mov o0, t0"
			]);
			TRANSFORM_PROCEDURE = res;
			return res;
		}
	}

}