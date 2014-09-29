/**
 * This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.
 * If it is not possible or desirable to put the notice in a particular file, then You may include the notice in a location (such as a LICENSE file in a relevant directory) where a recipient would be likely to look for such a notice.
 * You may add additional accurate notices of copyright ownership.
 *
 * It is desirable to notify that Covered Software was "Powered by AlternativaPlatform" with link to http://www.alternativaplatform.com/ 
 * */

package alternativa.a3d.materials {

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
	import alternativa.engine3d.materials.Material;
	import alternativa.engine3d.objects.Surface;
	import alternativa.engine3d.resources.BitmapTextureResource;
	import alternativa.engine3d.resources.Geometry;
	import alternativa.engine3d.spriteset.util.SpriteGeometryUtil;
	import flash.display3D.Context3DVertexBufferFormat;

	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.VertexBuffer3D;
	import flash.utils.Dictionary;

	use namespace alternativa3d;

	/**
	 * The materiall fills HP with solid color in light-independent manner by batches, so it's a vertex shader that calculates 
	 * HP meter color per unit. 
	 *
	 * @see alternativa.engine3d.objects.Skin#divide()
	 */
	public class HealthBarFillMaterial extends Material {
		
		private static var caches:Dictionary = new Dictionary(true);
		private var cachedContext3D:Context3D;
		private var programsCache:Dictionary;
		
	

		private static var outColorProcedure:Procedure = new Procedure(["#v0=vColor", "mov o0, v0"], "outColorProcedure");
		/**
		 * @private
		 * Pass health color to the fragment shader procedure
		 */
		/*
		static alternativa3d const _passColorProcedure:Procedure = new Procedure([
		"#a0=aUV", "#a1=joint", "#c1=cColor", "#v0=vColor", "#c2=cPreCalc",
		//"#c0=
		//"mov t0, a0", 
		
		"sge t1.x, a0.y, c2.y",  // if uv y is lower than zero, it means Healthbar will be colored proecdurally according to HP. This is the flag for it!
		
		 // get health fraction
		"mov t1.w, c[a1.x].w",
		"frc t1.w, t1.w",	
		
		
		
		// get health color t2
		"sub t1.w, c2.w, t1.w", // get complement of health for power
		
		"sge t2.x, t1.w, c2.x",  // >=0.5  // flag sge
		"div t2.z, t1.w, c2.x", // 2*power
		
		"sub t2.y, t2.z, c2.w,",  // 2*power - 2*.05
		"sub t2.y, c2.w, t2.y",  // 1 - (2*power - 2*0.5) 
		"mul t2.y, t2.y, t2.x",  // negate y if not needed (due to t2.x flag)
		
		
		"sub t2.w, c2.w, t2.x", // get complement of flag sge
		
		"mul t0.x, t2.z, t2.w",  //2*power * flagslt
		"add t2.x, t2.x, t0.x", // red += aboveLine
		"add t2.y, t2.y, t2.w", // green += flagslt
		
		//"mov t2.xy, c2.yy",
		"mov t2.z, c2.y",  // blue = 0
		
		
		"mov t0, c1",  // get rgba of default color
		"mul t0.xyz, t0.xyz, t1.xxx",
		
		"sub t1.x, c2.w, t1.x",  // get complement of flag
		"mul t2.xyz, t2.xyz, t1.xxx",
		
		"add t0.xyz, t0.xyz, t2.xyz",
		

		"mov t0.w, c1.w",  // default alpha
		
		"mov v0, t0"], "passColorProcedure");
		
		*/
		
		
		/*
		 *   var sin:Number = Math.sin (power * Math.PI);
            
            var green:Number = (power < 0.5) ?  sin : 255;
            var red:Number = (power > 0.5) ?  sin : 255; 
            return (red << 16) | (green << 8);
			*/
		
	//	/*
		static alternativa3d const _passColorProcedure:Procedure = new Procedure([
		"#a0=aUV", "#a1=joint", "#c1=cColor", "#v0=vColor", "#c2=cPreCalc",
		//"#c0=
		//"mov t0, a0", 
		
		"sge t1.x, a0.y, c2.y",  // if uv y is lower than zero, it means Healthbar will be colored proecdurally according to HP. This is the flag for it!
		
		 // get health fraction
		"mov t1.w, c[a1.x].w",
		"frc t1.w, t1.w",	
		
		
		// get health color t2
	//	"sub t1.w, c2.w, t1.w", // get complement of health for power
		
		"sge t2.z, t1.w, c2.x",  // >=0.5  // flag sge
		
		"mul t2.w, t1.w, c2.z",	 // power * Math.PI
		"sin t2.w, t2.w",		// sin of above
		
		"mul t2.x, t2.w, t2.z",  // 
		
		"mov t1.z, t2.z",  // save out flag
		"sub t2.z, c2.w, t2.z", // get complement of flag sge
		
		"mul t2.z, t2.z, c2.w",
		"add t2.x, t2.x, t2.z",  // add 1  if required
		
		"mul t2.y, t2.w, t2.z",
		"mul t2.z, t1.z, c2.w",
		"add t2.y, t2.y, t2.z", // add 1  if required
		
		"mov t2.z, c2.y",  // blue = 0
		
		
		"mov t0, c1",  // get rgba of default color
		"mul t0.xyz, t0.xyz, t1.xxx",
		
		"sub t1.x, c2.w, t1.x",  // get complement of flag
		"mul t2.xyz, t2.xyz, t1.xxx",
		
		"add t0.xyz, t0.xyz, t2.xyz",
		

		"mov t0.w, c1.w",  // default alpha
		
		"mov v0, t0"], "passColorProcedure");
	//	*/

		
		
		/**
		 * Transparency
		 */
		public var alpha:Number = 1;
		
		private var red:Number;
		private var green:Number;
		private var blue:Number;
		
		private var healthColorMeterResource:BitmapTextureResource;
		private var colorRampResource:BitmapTextureResource;
		
		
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
		 * Creates a new HealthBarFillMaterial instance.
		 * @param color Color .
		 * @param alpha Transparency.
		 */
		public function HealthBarFillMaterial(color:uint = 0xFFFFFF, alpha:Number = 1) {
		
			this.color = color;
			this.alpha = alpha;

		}

		private function setupProgram(object:Object3D):HealthBarFillMaterialProgram {
			var vertexLinker:Linker = new Linker(Context3DProgramType.VERTEX);
			var positionVar:String = "aPosition";
			vertexLinker.declareVariable(positionVar, VariableType.ATTRIBUTE);
			if (object.transformProcedure != null) {
				positionVar = appendPositionTransformProcedure(object.transformProcedure, vertexLinker);
			}
			vertexLinker.addProcedure(_projectProcedure);
			vertexLinker.setInputParams(_projectProcedure, positionVar);
		
			vertexLinker.addProcedure(_passColorProcedure);
			vertexLinker.setInputParams(_passColorProcedure, positionVar);


			var fragmentLinker:Linker = new Linker(Context3DProgramType.FRAGMENT);
			fragmentLinker.addProcedure(outColorProcedure);
			fragmentLinker.varyings = vertexLinker.varyings;
			return new HealthBarFillMaterialProgram(vertexLinker, fragmentLinker);
		}

		/**
		 * @private 
		 */
		override alternativa3d function collectDraws(camera:Camera3D, surface:Surface, geometry:Geometry, lights:Vector.<Light3D>, lightsLength:int, useShadow:Boolean, objectRenderPriority:int = -1):void {
			var object:Object3D = surface.object;
			// Strams
			var positionBuffer:VertexBuffer3D = geometry.getVertexBuffer(VertexAttributes.POSITION);
			var uvBuffer:VertexBuffer3D = geometry.getVertexBuffer(VertexAttributes.TEXCOORDS[0]);
			// Check validity
			if (positionBuffer == null || uvBuffer==null) return;
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

			var program:HealthBarFillMaterialProgram = programsCache[object.transformProcedure];
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
			drawUnit.setVertexBufferAt(program.joint, geometry.getVertexBuffer(SpriteGeometryUtil.ATTRIBUTE), geometry._attributesOffsets[SpriteGeometryUtil.ATTRIBUTE], Context3DVertexBufferFormat.FLOAT_1);
			// Constants
	
			object.setTransformConstants(drawUnit, surface, program.vertexShader, camera);
			drawUnit.setProjectionConstants(camera, program.cProjMatrix, object.localToCameraTransform);
			drawUnit.setVertexConstantsFromNumbers(program.cColor, red, green, blue, alpha);
			//drawUnit.setVertexConstantsFromNumbers(program.cPreCalc, 0.5, 0, .2, 1);
			drawUnit.setVertexConstantsFromNumbers(program.cPreCalc, 0.5, 0, Math.PI, 1);
			
			// Send to render
			if (alpha < 1) {
				drawUnit.blendSource = Context3DBlendFactor.SOURCE_ALPHA;
				drawUnit.blendDestination = Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
				camera.renderer.addDrawUnit(drawUnit, objectRenderPriority >= 0 ? objectRenderPriority : Renderer.TRANSPARENT_SORT);
			} else {
				camera.renderer.addDrawUnit(drawUnit, objectRenderPriority >= 0 ? objectRenderPriority : Renderer.OPAQUE);
			}
		}

		/**
		 * @inheritDoc 
		 */
		override public function clone():Material {
			var res:HealthBarFillMaterial = new HealthBarFillMaterial(color, alpha);
			res.clonePropertiesFrom(this);
			return res;
		}

	}
}

import alternativa.engine3d.materials.ShaderProgram;
import alternativa.engine3d.materials.compiler.Linker;

import flash.display3D.Context3D;

class HealthBarFillMaterialProgram extends ShaderProgram {

	public var aPosition:int = -1;
	public var aUV:int = -1;
	public var cProjMatrix:int = -1;
	public var cColor:int = -1;
	public var cPreCalc:int = -1;
	public var joint:int = -1;
	
	public function HealthBarFillMaterialProgram(vertex:Linker, fragment:Linker) {
		super(vertex, fragment);
	}

	override public function upload(context3D:Context3D):void {
		super.upload(context3D);

		aPosition =  vertexShader.findVariable("aPosition");
		aUV =  vertexShader.findVariable("aUV");
		joint =  vertexShader.findVariable("joint");
	
		cProjMatrix = vertexShader.findVariable("cProjMatrix");
		cColor = vertexShader.findVariable("cColor");
		cPreCalc = vertexShader.findVariable("cPreCalc");

	}
}
