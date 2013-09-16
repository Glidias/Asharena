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

                import alternativa.engine3d.materials.Material;

                import alternativa.engine3d.materials.TextureMaterial;

                import alternativa.engine3d.objects.Surface;

                import alternativa.engine3d.resources.Geometry;

 

                import flash.display3D.Context3D;

                import flash.display3D.Context3DBlendFactor;

                import flash.display3D.Context3DProgramType;

                import flash.display3D.VertexBuffer3D;

                import flash.utils.Dictionary;

 

                use namespace alternativa3d;

 

                /**

                * The material fills surface with solid color in light-independent manner within a circle radius.

                * @see alternativa.engine3d.objects.Skin#divide()

                */

              public class FillCircleMaterial extends Material {

                               

                                private static var caches:Dictionary = new Dictionary(true);

                                private var cachedContext3D:Context3D;

                                private var programsCache:Dictionary;

                               

                               

                                static alternativa3d const _passUVProcedure:Procedure = new Procedure(["#v0=vUV", "#a0=aUV", "mov v0, a0"], "passUVProcedure");

 

 

                               

                               

                                private static const outColorProcedure:Procedure = new Procedure([

                                                "#v0=vUV",

                                                "#c0=cColor",                                                                                        // -- CIRCLE MASKING

                                                "#c1=cHalf",                                                                                       // 0.5

                                                "sub ft0, v0, c1",                                                                               // subtract uv coordinates from center point to get difference vector

                                                "dp3 ft0, ft0 ft0",                                                                              // get dot product of difference vector (just dump scalar value in x register)

                                                "sqt ft0.x, ft0.x",                                                                              // get square root of self-applied dot product to find actual magnitude distance

                                                "sub ft0.x, c1.x, ft0.x",                                   // scalar value = 0.5 - actual magnitude distance

												"sge ft0.x, ft0.x, c1.z",      // use this to avoid shading    
												
												//"mul t1.w, t1.w, t0.x",
                                                //"kil ft0.x",                                                                                            // if value less than 0, do not draw anything!
												"mov t1, c0",
												
												"mul t1.w, c0.w, ft0.x",
                                               "mov o0, t1"

                                                ],

                                                "outColorProcedure");

                               

                               

 

                                /**

                                * Transparency

                                */

                                public var alpha:Number = 1;

                               

                                private var red:Number;

                                private var green:Number;

                                private var blue:Number;

                               

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

                                * Creates a new FillCircleMaterial instance.

                                * @param color Color .

                                * @param alpha Transparency.

                                */

                                public function FillCircleMaterial(color:uint = 0x7F7F7F, alpha:Number = 1) {

                                                this.color = color;

                                                this.alpha = alpha;

                               

                                }

 

                                private function setupProgram(object:Object3D):FillCircleMaterialProgram {

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

                                                return new FillCircleMaterialProgram(vertexLinker, fragmentLinker);

                                               

                                               

                                               

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

                                                if (positionBuffer == null || uvBuffer == null) return;

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

 

                                                var program:FillCircleMaterialProgram = programsCache[object.transformProcedure];

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

                                                if (program.cHalf >=0) drawUnit.setFragmentConstantsFromNumbers(program.cHalf, 0.5, 0.5, 0, 1);

                                               

                                               

                                                // Send to render

                                            // if (alpha < 1) {

                                                                drawUnit.blendSource = Context3DBlendFactor.SOURCE_ALPHA;

                                                                drawUnit.blendDestination = Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;

                                                                camera.renderer.addDrawUnit(drawUnit, objectRenderPriority >= 0 ? objectRenderPriority : Renderer.TRANSPARENT_SORT);

                                             //   } else {

												//		drawUnit.blendSource = Context3DBlendFactor.SOURCE_ALPHA;
											//drawUnit.blendDestination = Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA;
                                                       //       camera.renderer.addDrawUnit(drawUnit, objectRenderPriority >= 0 ? objectRenderPriority : Renderer.OPAQUE);

                                            //  }

                                }

 

                                /**

                                * @inheritDoc

                                 */

                                override public function clone():Material {

                                                var res:FillCircleMaterial = new FillCircleMaterial(color, alpha);

                                                res.clonePropertiesFrom(this);

                                                return res;

                                }

 

                }
				
  }
  
  
  
import alternativa.engine3d.materials.ShaderProgram;

import alternativa.engine3d.materials.compiler.Linker;

 

import flash.display3D.Context3D;

 

class FillCircleMaterialProgram extends ShaderProgram {

 

                public var aPosition:int = -1;

                public var cProjMatrix:int = -1;

                public var cColor:int = -1;

                public var cHalf:int = -1;

                public var aUV:int = -1;

               

 

               

                public function FillCircleMaterialProgram(vertex:Linker, fragment:Linker) {

                                super(vertex, fragment);

                }

 

                override public function upload(context3D:Context3D):void {

                                super.upload(context3D);

 

               

                                aPosition =  vertexShader.findVariable("aPosition");

                                aUV = vertexShader.findVariable("aUV");

                                cProjMatrix = vertexShader.findVariable("cProjMatrix");

                                cColor = fragmentShader.findVariable("cColor");

                                cHalf = fragmentShader.findVariable("cHalf");

                }

}
