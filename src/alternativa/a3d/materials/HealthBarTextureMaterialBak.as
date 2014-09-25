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
	public class HealthBarTextureMaterial extends Material {
		
		private static var caches:Dictionary = new Dictionary(true);
		private var cachedContext3D:Context3D;
		private var programsCache:Dictionary;
		
	

		private static var outColorProcedure:Procedure = new Procedure(["#v0=vColor", "mov o0, v0"], "outColorProcedure");
		/**
		 * @private
		 * Pass health color to the fragment shader procedure
		 */
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
		"mul t1.w, t1.w, c2.z",  //  power * Math.PI / 2
		
		"sin t2.x, t1.w", // red
		"sqt t2.x, t2.x", 
		"cos t2.y, t1.w", // green
		"sqt t2.y, t2.y",  
		"mov t2.z, c2.y",  // blue = 0
		
		
		"mov t0, c1",  // get rgba of default color
		"mul t0.xyz, t0.xyz, t1.xxx",
		
		"sub t1.x, c2.w, t1.x",  // get complement of flag
		"mul t2.xyz, t2.xyz, t1.xxx",
		
		"add t0.xyz, t0.xyz, t2.xyz",
		
		//"nrm t0.xyz, t0.xyz",  // this might make color look better

		"mov t0.w, c1.w",  // default alpha
		
		"mov v0, t0"], "passColorProcedure");
		

		[Embed(source="healthmeter.png")]
		private var DEFAULT_RAMP:Class;
		
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
		 * Creates a new HealthBarTextureMaterial instance.
		 * @param color Color .
		 * @param alpha Transparency.
		 */
		public function HealthBarTextureMaterial(color:uint = 0xFFFFFF, alpha:Number = 1, colorRampResource:BitmapTextureResource=null) {
			this.colorRampResource = colorRampResource || ( new BitmapTextureResource( new DEFAULT_RAMP().bitmapData ) );
			this.color = color;
			this.alpha = alpha;

		}

		private function setupProgram(object:Object3D):HealthBarTextureMaterialProgram {
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
			return new HealthBarTextureMaterialProgram(vertexLinker, fragmentLinker);
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

			var program:HealthBarTextureMaterialProgram = programsCache[object.transformProcedure];
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
			drawUnit.setVertexConstantsFromNumbers(program.cPreCalc, 0, 0, rampMultiplier, 1);

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
			var res:HealthBarTextureMaterial = new HealthBarTextureMaterial(color, alpha);
			res.clonePropertiesFrom(this);
			return res;
		}

	}
}

import alternativa.engine3d.materials.ShaderProgram;
import alternativa.engine3d.materials.compiler.Linker;

import flash.display3D.Context3D;

class HealthBarTextureMaterialProgram extends ShaderProgram {

	public var aPosition:int = -1;
	public var aUV:int = -1;
	public var cProjMatrix:int = -1;
	public var cColor:int = -1;
	public var cPreCalc:int = -1;
	public var joint:int = -1;
	
	public function HealthBarTextureMaterialProgram(vertex:Linker, fragment:Linker) {
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
