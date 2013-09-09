/**
 * This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
 * If it is not possible or desirable to put the notice in a particular file, then You may include the notice in a location (such as a LICENSE file in a relevant directory) where a recipient would be likely to look for such a notice.
 * You may add additional accurate notices of copyright ownership.
 *
 * It is desirable to notify that Covered Software was "Powered by AlternativaPlatform" with link to http://www.alternativaplatform.com/ 
 * */

package alternativa.engine3d.materials {

	import alternativa.engine3d.alternativa3d;
	import alternativa.engine3d.core.Camera3D;
	import alternativa.engine3d.core.DrawUnit;
	import alternativa.engine3d.core.Light3D;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.Renderer;
	import alternativa.engine3d.core.VertexAttributes;
	import alternativa.engine3d.materials.compiler.Linker;
	import alternativa.engine3d.materials.compiler.Procedure;
	import alternativa.engine3d.materials.compiler.VariableType;
	import alternativa.engine3d.objects.Surface;
	import alternativa.engine3d.resources.Geometry;
	import flash.geom.Rectangle;

	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.VertexBuffer3D;
	import flash.utils.Dictionary;

	use namespace alternativa3d;

	/**
	 * The materiall fills a 2d surface with grid lines in a resolution/light-independent manner.
	 * It also supports circle masking of gridlines which is good for 2d radar displays!
	 *
	 * @see alternativa.engine3d.objects.Skin#divide()
	 */
	public class RadarGrid2DMaterial extends Material {
		
		private static var caches:Dictionary = new Dictionary(true);
		private var cachedContext3D:Context3D;
		private var programsCache:Dictionary;

		private static var outColorProcedure:Procedure = new Procedure([
			"#v0=vUV",
			"#c0=cColor", 
			"#c1=cGridUV",
			"#c2=cGridPx",
			"#c3=cHalf",  
			
			// dummy
			//"mov t0 c1",
			//"mov t0 c2",
			//"mov t0 c3",
			//"mov t0 v0",
			
			"mov t1.w, c2.z",
    
			
			///*
			"mul t0.x, v0.x, c1.z",
			"mul t0.y, v0.y, c1.w",
			
			"add t0.xy, t0.xy, c1.xy",
			
			"frc t0.z, t0.x",
			"sub t0.w, c2.w, t0.z",
			
			//"sge t1.x, t0.z, c2.x", "sub t1.x, c2.w, t1.x",
			"slt t1.x, t0.z, c2.x",
			//"sge t1.y, t0.w, c2.x", "sub t1.y, c2.w, t1.y",
			"slt t1.y, t0.w, c2.x",
			"add t1.w, t1.w, t1.x",
			//"add t1.w, t1.w, t1.y",		//TODO: remove unnecessary complement
			
			"frc t0.z, t0.y",
			"sub t0.w, c2.w, t0.z",
			
			//"sge t1.x, t0.z, c2.y", "sub t1.x, c2.w, t1.x",
			"slt t1.x, t0.z, c2.y",
			//"sge t1.y, t0.w, c2.y", "sub t1.y, c2.w, t1.y",
			"slt t1.y, t0.w, c2.y",
			"add t1.w, t1.w, t1.x",
			//"add t1.w, t1.w, t1.y", 	//TODO: remove unnecessary complement
			
			"sat t1.w, t1.w",
			//"mov t1.w, c2.w",	
			
						
			"sub t0, v0, c3",                                                                               // subtract uv coordinates from center point to get difference vector

                 "dp3 t0, t0, t0",                                                                              // get dot product of difference vector (just dump scalar value in x register)

                  "sqt t0.x, t0.x",                                                                              // get square root of self-applied dot product to find actual magnitude distance

                    "sub t0.x, c3.x, t0.x",                                   // scalar value = 0.5 - actual magnitude distance
					
					//"sat t0.x, t0.x",
					
                     // "sge t0.x, t0.x, c2.z",      // use this to avoid shading    
					  
					  "mul t1.w, t1.w, t0.x",
					 
			//*/
			
			
			"mul o0.xyzw, c0.xyzw, t1.wwww",
		
			
			//"mov o0, t0"
		], 
		"outColorProcedure");
		
		static alternativa3d const _passUVProcedure:Procedure = new Procedure(["#v0=vUV", "#a0=aUV", "mov v0, a0"], "passUVProcedure");

		/**
		 * Transparency
		 */
		public var alpha:Number = 1;
		//public var alphaTest:Boolean = true;
		
		private var red:Number;
		private var green:Number;
		private var blue:Number;
		
		// Values in pixel coordinates
		 // grid width and height is multipled by scaleX and scaleY of currently drawn object accordingly,
		 // to determine UV threshold (lineThickness/gridSquareWidth or gridSquareHeight respectively)
		public var lineThickness:Number = 1;
		public var gridSquareWidth:Number; 
		public var gridSquareHeight:Number;
		public var threshold:Number=0.0001;  // pixel threshold
		public var clipRadius:Number =Number.MAX_VALUE;
		
		
		// Values in grid/UV coordinates to determine how many repeats the grid squares have, and any offset of UV.
		public var gridCoordinates:Rectangle = new Rectangle(0, 0, 4, 4);  // in normalized grid square coordinates, x,y,width,height
		
		
		
		/**
		 * Color.
		 */
		public function get color():uint {
			return (red*0xFF << 16) + (green*0xFF << 8) + blue*0xFF;
		}

		/**
		 * @private
		 */
		public function set color(value:uint):void {
			red = ((value >> 16) & 0xFF)/0xFF;
			green = ((value >> 8) & 0xFF)/0xFF;
			blue = (value & 0xff)/0xFF;
		}

		/**
		 * Creates a new RadarGrid2DMaterial instance.
		 * @param color Color .
		 * @param alpha Transparency.
		 */
		public function RadarGrid2DMaterial(color:uint = 0x7F7F7F, alpha:Number = .99, gridSquareWidth:Number=32, gridSquareHeight:Number=32) {
			this.color = color;
			this.alpha = alpha;
			this.gridSquareWidth = gridSquareWidth;
			this.gridSquareHeight = gridSquareHeight;
		}

		private function setupProgram(object:Object3D):RadarGrid2DMaterialProgram {
			var vertexLinker:Linker = new Linker(Context3DProgramType.VERTEX);
			var positionVar:String = "aPosition";
			vertexLinker.declareVariable(positionVar, VariableType.ATTRIBUTE);
			if (object.transformProcedure != null) {
				positionVar = appendPositionTransformProcedure(object.transformProcedure, vertexLinker);
			}
			vertexLinker.addProcedure(_projectProcedure);
			vertexLinker.setInputParams(_projectProcedure, positionVar);
			
			 vertexLinker.addProcedure(_passUVProcedure);

			var fragmentLinker:Linker = new Linker(Context3DProgramType.FRAGMENT);
			fragmentLinker.addProcedure(outColorProcedure);
			fragmentLinker.varyings = vertexLinker.varyings;
			return new RadarGrid2DMaterialProgram(vertexLinker, fragmentLinker);
		}

		/**
		 * @private 
		 */
		override alternativa3d function collectDraws(camera:Camera3D, surface:Surface, geometry:Geometry, lights:Vector.<Light3D>, lightsLength:int, useShadow:Boolean, objectRenderPriority:int = -1):void {
			var object:Object3D = surface.object;
			// Strams
			var positionBuffer:VertexBuffer3D = geometry.getVertexBuffer(VertexAttributes.POSITION);
			// Check validity
			if (positionBuffer == null) return;
			
			var uvBuffer:VertexBuffer3D = geometry.getVertexBuffer(VertexAttributes.TEXCOORDS[0]);
			// Program

			// Renew program cache for this context
			if (camera.context3D != cachedContext3D) {
				cachedContext3D = camera.context3D;
				programsCache = caches[cachedContext3D];
				if (programsCache == null) {
					programsCache = new Dictionary();
					caches[cachedContext3D] = programsCache;
				}
			}

			var program:RadarGrid2DMaterialProgram = programsCache[object.transformProcedure];
			if (program == null) {
				program = setupProgram(object);
				program.upload(camera.context3D);
				programsCache[object.transformProcedure] = program;
			}
			// Drawcall
			var drawUnit:DrawUnit = camera.renderer.createDrawUnit(object, program.program, geometry._indexBuffer, surface.indexBegin, surface.numTriangles, program);
			// Streams
			drawUnit.setVertexBufferAt(program.aPosition, positionBuffer, geometry._attributesOffsets[VertexAttributes.POSITION], VertexAttributes.FORMATS[VertexAttributes.POSITION]);
			drawUnit.setVertexBufferAt(program.aUV, uvBuffer, geometry._attributesOffsets[VertexAttributes.TEXCOORDS[0]], VertexAttributes.FORMATS[VertexAttributes.TEXCOORDS[0]]);
			// Constants
			object.setTransformConstants(drawUnit, surface, program.vertexShader, camera);
			drawUnit.setProjectionConstants(camera, program.cProjMatrix, object.localToCameraTransform);
			drawUnit.setFragmentConstantsFromNumbers(program.cColor, red, green, blue, alpha);
			drawUnit.setFragmentConstantsFromNumbers(program.cGridUV, gridCoordinates.x, gridCoordinates.y, gridCoordinates.width, gridCoordinates.height);
			drawUnit.setFragmentConstantsFromNumbers(program.cGridPx,  (lineThickness*2+threshold)/(gridSquareWidth), (lineThickness*2+threshold)/(gridSquareHeight), 0, 1);
			//drawUnit.setFragmentConstantsFromNumbers(program.cHalf, gridCoordinates.x + .5 * gridCoordinates.width, gridCoordinates.y + .5 * gridCoordinates.height, clipRadius/gridSquareWidth*gridCoordinates.width, clipRadius/gridSquareHeight*gridCoordinates.height);
			//throw 
			drawUnit.setFragmentConstantsFromNumbers(program.cHalf,  .5 ,  .5, 0, 1);
			//gridCoordinates.width * gridSquareWidth;
			//gridCoordinates.height * gridSquareHeight;
			
			objectRenderPriority = Renderer.NEXT_LAYER;  // enforce always on top?
			
			// Send to render
			if (alpha < 1) {
				
				drawUnit.blendSource = Context3DBlendFactor.SOURCE_ALPHA;
				drawUnit.blendDestination = Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
				
				camera.renderer.addDrawUnit(drawUnit, objectRenderPriority >= 0 ? objectRenderPriority : Renderer.TRANSPARENT_SORT);
			} else {
				
				drawUnit.blendSource = Context3DBlendFactor.SOURCE_ALPHA;
				drawUnit.blendDestination = Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
				
				camera.renderer.addDrawUnit(drawUnit, objectRenderPriority >= 0 ? objectRenderPriority : Renderer.OPAQUE);
			}
		}

		/**
		 * @inheritDoc 
		 */
		override public function clone():Material {
			var res:RadarGrid2DMaterial = new RadarGrid2DMaterial(color, alpha);
			res.clonePropertiesFrom(this);
			return res;
		}

	}
}

import alternativa.engine3d.materials.ShaderProgram;
import alternativa.engine3d.materials.compiler.Linker;

import flash.display3D.Context3D;

class RadarGrid2DMaterialProgram extends ShaderProgram {

	public var aPosition:int = -1;
	public var cProjMatrix:int = -1;
	public var cColor:int = -1;
	
	public var cGridUV:int = -1;
	public var cGridPx:int = -1;
	
	 public var aUV:int = -1;
	
            public var cHalf:int = -1;
	

	public function RadarGrid2DMaterialProgram(vertex:Linker, fragment:Linker) {
		super(vertex, fragment);
	}

	override public function upload(context3D:Context3D):void {
		super.upload(context3D);

		aPosition =  vertexShader.findVariable("aPosition");
		aUV =  vertexShader.findVariable("aUV");
		cProjMatrix = vertexShader.findVariable("cProjMatrix");
		cColor = fragmentShader.findVariable("cColor");
		cGridPx = fragmentShader.findVariable("cGridPx");
		cGridUV = fragmentShader.findVariable("cGridUV");
		cHalf = fragmentShader.findVariable("cHalf");
	}
}