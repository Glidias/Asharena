package alternativa.engine3d.primitives 
{
	import alternativa.engine3d.alternativa3d;
	import alternativa.engine3d.core.Camera3D;
	import alternativa.engine3d.core.DrawUnit;
	import alternativa.engine3d.core.VertexAttributes;
	import alternativa.engine3d.materials.compiler.Linker;
	import alternativa.engine3d.materials.compiler.Procedure;
	import alternativa.engine3d.materials.Material;
	import alternativa.engine3d.objects.Surface;
	import alternativa.types.Float;
	import flash.geom.Vector3D;
	import util.SpawnerBundle;
	use namespace alternativa3d;
	
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class PlaneWavy extends Plane 
	{
		private var fTime0_X:Number = 0;
		/*
		private var waveHeight:Number = 20;
		private  var windDir:Vector3D = new Vector3D(3,2);
		private var  roughness:Number = 2;
		*/
		
		// 128, .25
		//private var waveHeight:Number = 44;
		//private  var windDir:Vector3D = new Vector3D(3,2);
		//private var  roughness:Number = 2;
		
		private var waveHeight:Number = 14;
		private  var windDir:Vector3D = new Vector3D(3,2);
		private var  roughness:Number = 2;

		private static var TRANSFORM_PROCEDURE:Procedure;
		
		
		
		alternativa3d override function setTransformConstants(drawUnit:DrawUnit, surface:Surface, vertexShader:Linker, camera:Camera3D):void {
			
			
		
			drawUnit.setVertexConstantsFromNumbers( vertexShader.getVariableIndex("cVars"), waveHeight, roughness, 0.01, 1);
			drawUnit.setVertexConstantsFromNumbers( vertexShader.getVariableIndex("cWindDir"), windDir.x*fTime0_X, windDir.y*fTime0_X, .5, 0);
	
		}
		
		
		public function PlaneWavy(width:Number=100, length:Number=100, widthSegments:uint=1, lengthSegments:uint=1, twoSided:Boolean=true, reverse:Boolean=false, bottom:Material=null, top:Material=null) 
		{
			super(width, length, widthSegments, lengthSegments, twoSided, reverse, bottom, top);
			//throw new Error("A");
						transformProcedure = getTransformProcedure();
						
			windDir.normalize();
			windDir.scaleBy(2)
			//randomiseVertices();
		}
		
		private var dummyVec:Vector3D = new Vector3D();
		private var dummyVerts:Vector.<Number>
		 public function updatePosition(v:Vector3D):void
		{
			
				 var height:Number = Math.sin( 1.0 * (v.x + (windDir.x * fTime0_X)));
			   height += 1.0;
			   height = Math.pow( Math.max(0.0, height), roughness);
			   
			   var height2:Number = Math.sin( 0.01 * (v.y + (windDir.y * fTime0_X)));
			   height2 += 1.0;
			   height2 = Math.pow( Math.max(0.0, height2), roughness);

			  // vec4 pos = gl_Vertex;
			   v.z = waveHeight * ((height + height2) * .5);
		
		}
		
		private function randomiseVertices():void 
		{
			var vPosition:Vector.<Number> = dummyVerts || (dummyVerts=geometry.getAttributeValues(VertexAttributes.POSITION));
			for (var i:int = 0; i < vPosition.length; i += 3) {
				dummyVec.x = vPosition[i];
				dummyVec.y = vPosition[i+1];
				dummyVec.z = vPosition[i + 2]
				updatePosition(dummyVec);
				vPosition[i + 2] = dummyVec.z;
			}
			
			geometry.setAttributeValues(VertexAttributes.POSITION, vPosition);
			geometry.calculateNormals();
			geometry.calculateTangents(0);
			geometry.upload( SpawnerBundle.context3D);
			
		}
		
		public function update(time:Number):void {
			fTime0_X += time;
			
			//randomiseVertices();
		}
		
		private static function getTransformProcedure():Procedure {
			if (TRANSFORM_PROCEDURE) return TRANSFORM_PROCEDURE;
			
			var res:Procedure;
			
			res =  new Procedure(null, "PlaneWavyTransformProcedure");
			res.compileFromArray(["#c0=cVars", "#c1=cWindDir",
		//	"mov t0, c0",
			//"mov t0, c1",
			//"mov t0, i0",
			
		//	/*
			"mov t0.xyz, i0.xyz",
			
			"add t0.w, c1.x, t0.x",  // = Math.sin( 1.0 * (v.x + (windDir.x * fTime0_X)));
			"sin t0.w, t0.w",  
			"add t0.w, t0.w, c0.w",  //  height += 1.0;
			"max t0.w, t0.w, c1.w",			//  Math.max(0.0, height)
			"pow t0.w, t0.w, c0.y",  //  height = Math.pow( Math.max(0.0, height), roughness);
			
			//Math.sin( 0.01 * (v.y + (windDir.y * fTime0_X)));
			"add t0.z, c1.y, t0.y",	// (v.y + (windDir.y * fTime0_X)
			"mul t0.z, t0.z, c0.z",  // 0.01 * above
			"sin t0.z, t0.z",
			"add t0.z, t0.z, c0.w",  //  height2 += 1.0;
			"max t0.z, t0.z, c1.w",			//  Math.max(0.0, height2)
			"pow t0.z, t0.z, c0.y",  //  height = Math.pow( Math.max(0.0, height2), roughness);
			
			"add t0.z, t0.z, t0.w",
			"mul t0.z, t0.z, c1.z",
			"mul t0.z, t0.z, c0.x",
		//	*/
		
			"mov t0.w, i0.w",  // restore idiots
			"mov t0.y, i0.y",
			
			//"mov t0, i0",
			//"add t0.z, t0.z, c1.x",
			
			"mov o0, t0"
			]);
			TRANSFORM_PROCEDURE = res;
			return res;
		}
		
		
		
		
	}

}

/*
void main(void)
{
   float height = sin( 1.0 * (gl_Vertex.x + (windDir.x * fTime0_X)));
   height += 1.0;
   height = pow( max(0.0, height), roughness);
   
   float height2 = sin( 0.01 * (gl_Vertex.y + (windDir.y * fTime0_X)));
   height2 += 1.0;
   height2 = pow( max(0.0, height2), roughness);

   
   vec4 pos = gl_Vertex;
   pos.z = waveHeight * ((height + height2) / 2.0);
   
   gl_Position = gl_ModelViewProjectionMatrix * pos.xzyw;
   
   
   
   vec4 ref = normalize(reflect( (vViewPosition - pos.xzyw), vec4(0.0, 0.0, 1.0, 1.0)));
   ref += vec4(1.0,1.0,1.0,1.0);
   ref *= 0.5;
   
   gl_TexCoord[1] = ref;
   
   gl_TexCoord[0].xy = 4.0 * (gl_MultiTexCoord0.yx + vec2(0.0, fTime0_X * 0.01));
   
   //
   //   Find Surface Normal
   vec3 binormal = normalize(vec3( cos(1.0 * (gl_Vertex.x + (windDir.x * fTime0_X))),
                         1.0,
                         0.0));
                         
   vec3 tangent = normalize( 
                              vec3( 0.0,
                                    1.0,
                                     0.01 * cos(0.01 * (gl_Vertex.y + (windDir.y * fTime0_X))))
                         );
   vec3 normal = cross(binormal, tangent);
   normal += vec3(1.0,1.0,1.0);
   normal *= 0.5;
   
   tanSpace = mat3( vec3(1.0, 0.0, 0.0)
                     , normal,
                     vec3(0.0, 0.0, 1.0));
					
		*/