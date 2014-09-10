package alternativa.engine3d.primitives 
{
	import alternativa.engine3d.alternativa3d;
	import alternativa.engine3d.core.Camera3D;
	import alternativa.engine3d.core.DrawUnit;
	import alternativa.engine3d.core.RayIntersectionData;
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
		public  var windDir:Vector3D = new Vector3D(3,2);
		private var  roughness:Number = 2;
		*/
		
		// 128, .25
		//private var waveHeight:Number = 44;
		//public  var windDir:Vector3D = new Vector3D(3,2);
		//private var  roughness:Number = 2;
		
		private var waveHeight:Number = 24;
		public  var windDir:Vector3D = new Vector3D(-2,-2);
		private var  roughness:Number = 2;
		
		/*
		private var threeSixtyRads:Number = 360 * (Math.PI / 180);
		private var _frequency:Number = 100 * (Math.PI / 180);
		private var _frequencyY:Number =70 * (Math.PI / 180);
		private var _amplitudeY:Number = 42;
		private var _amplitude:Number = 22;
		private var _speed:Number = .3;
*/
		
		private var threeSixtyRads:Number = 360 * (Math.PI / 180);
		private var _frequency:Number = 10 * (Math.PI / 180);
		private var _frequencyY:Number = 6 * (Math.PI / 180);
		private var _amplitude:Number = 20;
		private var _amplitudeY:Number = 40;
		
		private var _speed:Number = 1;
		
		private static var TRANSFORM_PROCEDURE:Procedure;
		
		
		

		
		
		public function PlaneWavy(width:Number=100, length:Number=100, widthSegments:uint=1, lengthSegments:uint=1, twoSided:Boolean=true, reverse:Boolean=false, bottom:Material=null, top:Material=null) 
		{
			_widthSeg = width / widthSegments;
			_heightSeg = length / lengthSegments;
			_widthSeg_i = 1 / _widthSeg;
			_heightSeg_i = 1 / _heightSeg;
			
			super(width, length, widthSegments, lengthSegments, twoSided, reverse, bottom, top);
			//throw new Error("A");
			transformProcedure = getTransformProcedure();
						
			windDir.normalize();
			windDir.scaleBy(2)
			
			fortyFiveDegree = new Vector3D(1, 1, 0);
			fortyFiveDegree.normalize();
			//randomiseVertices();
		}
		
	
		
		public function getHeightAndNormalAtSpot(spot:Vector3D):Vector3D {
			var scaler:Number;
			var result:Vector3D;
			var gridX:int = Math.floor(spot.x * _widthSeg_i);
			var gridY:int = Math.floor(spot.y * _heightSeg_i);
	
			
			dummyVec.x = gridX * _widthSeg + _widthSeg;
			dummyVec.y  = gridY * _heightSeg;
			dummyVec.z = 0;
			
			//throw new Error(dummyVec.x);
			
			dummyVec3.x = spot.x - dummyVec.x;
			dummyVec3.y = spot.y - dummyVec.y;
			dummyVec3.z =  0;
			
			if ( dummyVec3.dotProduct(fortyFiveDegree) > 0 ) {  // bottom right
				dummyVec2.x = dummyVec.x - _widthSeg;
				dummyVec2.y = dummyVec.y - _heightSeg;  // leftward
				dummyVec2.z = dummyVec.z;
				
				dummyVec3.x = dummyVec.x;			// rightward
				dummyVec3.y = dummyVec.y - _heightSeg;
				dummyVec3.z = dummyVec.z;
				
				
				
				
			}
			else {  // top left 
				dummyVec2.x = dummyVec.x - _widthSeg;
				dummyVec2.y = dummyVec.y;  // leftward
				dummyVec2.z = dummyVec.z;
				
				dummyVec3.x = dummyVec.x - _widthSeg;			// rightward
				dummyVec3.y = dummyVec.y - _heightSeg;
				dummyVec3.z = dummyVec.z;
			}
			
			updatePosition(dummyVec);
			updatePosition(dummyVec2);
			updatePosition(dummyVec3);
			
			
			dummyVec2.x -= dummyVec.x;
			dummyVec2.y -= dummyVec.y;
			dummyVec2.z -= dummyVec.z;
			
			dummyVec3.x -= dummyVec.x;
			dummyVec3.y -= dummyVec.y;
			dummyVec3.z -= dummyVec.z;
				
			result = dummyVec.crossProduct(dummyVec3);
		//	result = new Vector3D(0, 0, 1);
			result.normalize();
			
		
			dummyVec2.x = spot.x - dummyVec.x;
			dummyVec2.y = spot.y - dummyVec.y;
			dummyVec2.z = 0; // spot.z - dummyVec.z;
				
			scaler = dummyVec2.dotProduct(result);
			//spot.x = dummyVec.x + scaler * result.x;
			//spot.y = dummyVec.y + scaler * result.y;
			spot.z = dummyVec.z + scaler * result.z;
			//throw new Error(spot);
			
			
			return result;
		}
		
		private var dummyVec:Vector3D = new Vector3D();
		private var dummyVec2:Vector3D = new Vector3D();
		private var dummyVec3:Vector3D = new Vector3D();
		private var dummyVerts:Vector.<Number>
		private var _widthSeg:Number;
		private var _heightSeg:Number;
			private var _widthSeg_i:Number;
		private var _heightSeg_i:Number;
		private var fortyFiveDegree:Vector3D;
		private var waveCycle:Number=0;
		
		///*
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
	//	*/
		
	/*
		public function updatePosition(v:Vector3D):void {
			// multiply by the sine of the x coordinate, plus offset for animation (normalized to be 0-360 degrees)
				v.z= Math.sin(((v.x + waveCycle) / 100) * (threeSixtyRads * _frequency) )  * _amplitude;
				// add harmonic from Y frequency
				v.z += Math.sin(((v.y + waveCycle) / 100) * (threeSixtyRads * _frequencyY) )  * _amplitudeY;
		}
		*/
		
		
			
			
		public function getHeightAt(x:Number, y:Number):Number {
			dummyVec.x = x;
			dummyVec.y = y;
			updatePosition(dummyVec);
			return dummyVec.z;
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
			//geometry.calculateNormals();
			//geometry.calculateTangents(0);
			geometry.upload( SpawnerBundle.context3D);
			
		}
		
		public function update(time:Number):void {
			fTime0_X += time;
			waveCycle += _speed;
			//randomiseVertices();
		}
		
		
		alternativa3d override function setTransformConstants(drawUnit:DrawUnit, surface:Surface, vertexShader:Linker, camera:Camera3D):void {
			
			
		
			drawUnit.setVertexConstantsFromNumbers( vertexShader.getVariableIndex("cVars"), waveHeight, roughness, 0.01, 1);
			drawUnit.setVertexConstantsFromNumbers( vertexShader.getVariableIndex("cWindDir"), windDir.x*fTime0_X, windDir.y*fTime0_X, .5, 0);
	
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