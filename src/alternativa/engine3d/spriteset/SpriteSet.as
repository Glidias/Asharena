package alternativa.engine3d.spriteset 
{
	import alternativa.engine3d.core.Camera3D;
	import alternativa.engine3d.core.DrawUnit;
	import alternativa.engine3d.core.Light3D;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.materials.compiler.Linker;
	import alternativa.engine3d.materials.compiler.Procedure;
	import alternativa.engine3d.materials.compiler.VariableType;
	import alternativa.engine3d.materials.Material;
	import alternativa.engine3d.materials.TextureMaterial;
	import alternativa.engine3d.alternativa3d;
	import alternativa.engine3d.objects.Mesh;
	import alternativa.engine3d.objects.Surface;
	import alternativa.engine3d.resources.Geometry;
	import alternativa.engine3d.spriteset.util.SpriteGeometryUtil;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;
	use namespace alternativa3d;
	
	/**
	 * A 3d object to support batch rendering of sprites.
	 * 
	 * @author Glenn Ko
	 */
	public class SpriteSet extends Object3D
	{
		/**
		 * Raw sprite data to upload to GPU if number of renderable sprites is lower than batch
		 */
		public var spriteData:Vector.<Number>;
		/**
		 * Raw sprite data to upload to GPU in batches if number of renderable sprite is higher than batch amount. (If you called bakeSpriteData(), this is automatically created)
		 */
		public var staticBatches:Vector.<Vector.<Number>>;
		
		alternativa3d var uploadSpriteData:Vector.<Number>;
		private var toUploadSpriteData:Vector.<Number>;
		private var toUploadNumSprites:int;
		alternativa3d var maxSprites:int;
		alternativa3d var _numSprites:int;
		
		public var height:Number;
		public var width:Number;

	
		
		private var material:Material;
		private var surface:Surface;
		public function setMaterial(mat:Material):void {
			this.material = mat;
			surface.material = mat;
		}
		
		private static var _transformProcedures:Dictionary = new Dictionary();
		public var geometry:Geometry;
		
		/**
		 * Default maximum batch setting (number of uploadable sprites) per batch.
		 */
		public static var MAX:int = 80;	
		
		private var NUM_REGISTERS_PER_SPR:int = 1;
		
		private var viewAligned:Boolean = false;
		/**
		 * An alternative to "z-locking", if viewAligned is enabled, this flag can be used to lock axis along the local up (z) direction, but still keep the rightward-aligned orientation to camera view.
		 */
		public var viewAlignedLockUp:Boolean = false;
	
		private static var UP:Vector3D = new Vector3D(0, 0, 1);
		
		alternativa3d var axis:Vector3D;

		/**
		 *  Sets an arbituary normalized axis direction vector along a given direction for non-viewAligned option. The default setting is z-locked (0,0,1), but using
		 * this option will allow alignemnt of sprites along a specific editable axis vector.
		 * This method automatically disables viewAligned option. and updates the transform procedure to ensure arbituary axis alignment works.
		 * @param	x
		 * @param	y
		 * @param	z
		 * @return The axis reference which you can change at runtime
		 */
		public function setupAxisAlignment(x:Number, y:Number, z:Number):Vector3D {
			viewAligned = false;
			axis =  new Vector3D(x, y, z);
			if (transformProcedure != null) validateTransformProcedure();
			return axis;
		}
	
		  // TODO:
		 // create specialised material that uses smallest possible vertex buffer data (2 tuple, quad-corner index and sprite index and spritesheet-animation support) that works with this class.
		
		  
		/**
		 * Constructor
		 * @param	numSprites	The total number of sprites to render in this set
		 * @param   viewAligned (Boolean) Whether to fully align sprites to camera screen orienation, or align to a locked axis (up - z) facing towards camera.
		 * @param	material	Material to use for all sprites
		 * @param	width		Default width (or scaling factor) of each sprite to use in world coordinate 
		 * @param	height		Default height (or scaling factor) of each sprite to use in world coordinate
		 * @param	maxSprites  (Optional) Default 0 will use static MAX setting. Defines the maximum uploadable batch amount of sprites that can upload at once to GPU for this instance.
		 * @param	numRegistersPerSprite  (Optional) Default 1 will only use 1 constant register per sprite (which is the first register assumed to contain xyz position of each sprite). 
		 * 									Specify more registers if needed depending on material type.
		 * @param	geometry   (Optional)   Specific custom geometry layout for the spriteset if needed, else, it'll try to create a normalized (1x1 sized geometry sprite batch geometry) to fit according to available material types in Alternativa3D. 
		 */
		public function SpriteSet(numSprites:int, viewAligned:Boolean, material:TextureMaterial, width:Number, height:Number,maxSprites:int=0, numRegistersPerSprite:int=1, geometry:Geometry=null) 
		{
			super();
			
			this.geometry = geometry;
			this.viewAligned = viewAligned;
			
			NUM_REGISTERS_PER_SPR = numRegistersPerSprite;
			if (maxSprites <= 0) maxSprites = MAX;
			
			
			uploadSpriteData = new Vector.<Number>(((maxSprites*NUM_REGISTERS_PER_SPR) << 2),true);

			this.material = material;
			surface = new Surface();
			surface.material = material;
			surface.object = this;
			surface.indexBegin = 0;
		
			this.width = width;
			this.height = height;
			
			this.maxSprites = maxSprites;
			
			
			_numSprites = numSprites;
			spriteData = new Vector.<Number>(((numSprites * NUM_REGISTERS_PER_SPR) << 2), true);
		}
		
		/*
		alternativa3d override function calculateVisibility(camera:Camera3D):void {
			
		}
		*/
		
		alternativa3d override function setTransformConstants(drawUnit:DrawUnit, surface:Surface, vertexShader:Linker, camera:Camera3D):void {
			drawUnit.setVertexBufferAt(vertexShader.getVariableIndex("joint"), geometry.getVertexBuffer(SpriteGeometryUtil.ATTRIBUTE), geometry._attributesOffsets[SpriteGeometryUtil.ATTRIBUTE], Context3DVertexBufferFormat.FLOAT_1);
			
			if (!viewAligned) {
				drawUnit.setVertexConstantsFromNumbers(vertexShader.getVariableIndex("cameraPos"), cameraToLocalTransform.d, cameraToLocalTransform.h, cameraToLocalTransform.l, 0);
				var axis:Vector3D = this.axis || UP;
				drawUnit.setVertexConstantsFromNumbers(vertexShader.getVariableIndex("up"), axis.x, axis.y, axis.z, 0);  
			}
			else {				
				if (!viewAlignedLockUp) drawUnit.setVertexConstantsFromNumbers(vertexShader.getVariableIndex("up"), -cameraToLocalTransform.b, -cameraToLocalTransform.f, -cameraToLocalTransform.j, 0)
				else  drawUnit.setVertexConstantsFromNumbers(vertexShader.getVariableIndex("up"), 0, 0, 1, 0);
				drawUnit.setVertexConstantsFromNumbers(vertexShader.getVariableIndex("right"), cameraToLocalTransform.a, cameraToLocalTransform.e, cameraToLocalTransform.i, 0);  
			}
			drawUnit.setVertexConstantsFromNumbers(vertexShader.getVariableIndex("spriteSet"), width*.5, height*.5, 0, 0);  
			drawUnit.setVertexConstantsFromVector(0, toUploadSpriteData, toUploadNumSprites*NUM_REGISTERS_PER_SPR ); 
		}
		
		override alternativa3d function collectDraws(camera:Camera3D, lights:Vector.<Light3D>, lightsLength:int, useShadow:Boolean):void {
		
			var spriteDataSize:int;
			var i:int;
			var numSprites:int = _numSprites;
		
			// setup defaults if required
			if (geometry == null) {
				geometry = SpriteGeometryUtil.createNormalizedSpriteGeometry(maxSprites, 0, SpriteGeometryUtil.guessRequirementsAccordingToMaterial(material), 1);
				geometry.upload( camera.context3D );
			}
			if (transformProcedure == null) validateTransformProcedure();
		

				if (_numSprites  <= maxSprites) {
					toUploadSpriteData = spriteData;
					toUploadNumSprites = _numSprites;
					surface.numTriangles = (toUploadNumSprites << 1);
					 surface.material.collectDraws(camera, surface, geometry, lights, lightsLength, useShadow);
				}
				else if (staticBatches) {
					spriteDataSize = NUM_REGISTERS_PER_SPR * 4;
					for (i = 0; i < staticBatches.length; i++) {
						toUploadSpriteData = staticBatches[i];
						toUploadNumSprites = toUploadSpriteData.length / spriteDataSize;
						surface.numTriangles = (toUploadNumSprites << 1);
						surface.material.collectDraws(camera, surface, geometry, lights, lightsLength, useShadow);
					}
				}
				else { 
				
					spriteDataSize = (NUM_REGISTERS_PER_SPR << 2);
					toUploadSpriteData = uploadSpriteData;
					for (i = 0; i < _numSprites;  i += maxSprites) {
						var limit:int = _numSprites - i;  // remaining sprites left to iterate
						
						if (limit > maxSprites) limit = maxSprites;
						toUploadNumSprites = limit;
						limit += i;
					
						var count:int = 0;
						for (var u:int = i; u < limit; u++ ) {   // start sprite index to ending sprite index
							var bu:int = u * spriteDataSize; 
							var d:int = spriteDataSize;
							while (--d > -1) toUploadSpriteData[count++] = spriteData[bu++];
						}
						surface.numTriangles = (toUploadNumSprites << 1);
					
						surface.material.collectDraws(camera, surface, geometry, lights, lightsLength, useShadow);
					
					}
				}
			
				// Mouse events
				//if (listening) camera.view.addSurfaceToMouseEvents(surface, geometry, transformProcedure);
				//	}
			
				// Debug
				/*
				if (camera.debug) {
					var debug:int = camera.checkInDebug(this);
					if ((debug & Debug.BOUNDS) && boundBox != null) Debug.drawBoundBox(camera, boundBox, localToCameraTransform);
				}
				*/
		}
		

		/**
		 * Sets up geometry according to settings found in this instance.
		 * @param	context3D
		 */
		public function setupDefaultGeometry(context3D:Context3D = null):void {	
			if (geometry != null) {
				geometry.dispose();
			}
			geometry = SpriteGeometryUtil.createNormalizedSpriteGeometry(maxSprites, 0, SpriteGeometryUtil.guessRequirementsAccordingToMaterial(material), 1);
			if (context3D) geometry.upload(context3D);
		}
		
		/**
		 * Sets up transform procedure according to settings found in this instance.
		 */
		public function validateTransformProcedure():void {
			transformProcedure = viewAligned ? getViewAlignedTransformProcedure(maxSprites) : axis!= null ? getAxisAlignedTransformProcedure(maxSprites) :  getTransformProcedure(maxSprites);
		}
		
	
		/**
		 * Randomise positions of sprites of spriteData, assuming 1st register of each sprite refers to it's x,y,z position. Good for previewing spriteset.
		 * @param   mask  (Optional) bitmask of x,y,z (1st,2nd and 3rd value) to set value to zero if mask hits.
		 */
		public function randomisePositions(mask:int = 0, maskValue:Number = 0, range:Number = 1200, offsetX:Number = 0, offsetY:Number = 0, offsetZ:Number = 0 ):void {
			var multiplier:int = NUM_REGISTERS_PER_SPR * 4;
			var hRange:Number = range * .5;
			for (var i:int = 0; i < _numSprites; i++ ) {
				var baseI:int = i * multiplier;
				spriteData[baseI] = (mask & 1) ? maskValue :  -hRange + Math.random() * range  +offsetX;
				spriteData[baseI + 1] = (mask & 2) ? maskValue : -hRange + Math.random() * range+offsetY;
				spriteData[baseI + 2] = (mask & 4) ? maskValue : -hRange +  Math.random() * range +offsetZ;
			}
		}
		
		/**
		 * Adjust number of sprites in spriteData. This would truncate sprites or add more to the list that can be editable.
		 */
		public function set numSprites(value:int):void 
		{
			spriteData.fixed = false;
			spriteData.length  = ((value * NUM_REGISTERS_PER_SPR) << 2);
			spriteData.fixed = true;
			_numSprites = value;
				
		}
		
		/**
		 * Will permanently render baked static sprite data information into a set of static batches, if total number of sprites to be drawn exceeds the batch size.
		 * This can improve performance a bit for larger sets since you don't need to re-read data one-by-one from existing spriteData, if spriteData isn't changing,
		 * or you might wish to use the static batches for your own direct manual editing.
		 * @param 	flushOldSpriteDataIfPossible (Boolean) Optional. Whether to null away spriteData reference if it exceeds batch size.
		 * @return  The baked staticBatches reference for the current instance.
		 */
		public function bakeSpriteData(flushOldSpriteDataIfPossible:Boolean = false):Vector.<Vector.<Number>> {
			
			// setup defaults if required
			if (geometry == null) geometry = SpriteGeometryUtil.createNormalizedSpriteGeometry(maxSprites, 0, SpriteGeometryUtil.guessRequirementsAccordingToMaterial(material), 1);
			if (transformProcedure == null) validateTransformProcedure();
			
			staticBatches = new Vector.<Vector.<Number>>();
			
			if (_numSprites <= maxSprites) {
				staticBatches.push(spriteData);
				return staticBatches;
			}
			
			var batch:Vector.<Number>;
			var i:int;

			var spriteDataSize:int = NUM_REGISTERS_PER_SPR * 4;
					
					for (i = 0; i < _numSprites;  i += maxSprites) {
						var limit:int = _numSprites - i;  // remaining sprites left to iterate	
						if (limit > maxSprites) limit = maxSprites;
						limit += i;
			
						var count:int = 0;
						batch = new Vector.<Number>();
						for (var u:int = i; u < limit; u++ ) {   // start sprite index to ending sprite index
							var bu:int = u * spriteDataSize; 
							var d:int = spriteDataSize;
							while (--d > -1) batch[count++] = spriteData[bu++];
						}
						batch.fixed = true;
						staticBatches.push(batch);
					}
			
			staticBatches.fixed = true;
			
			if (flushOldSpriteDataIfPossible) spriteData = null;
			return staticBatches;
		}
		
		public function getMaxSprites():int 
		{
			return maxSprites;
		}
		
		
		
		alternativa3d override function fillResources(resources:Dictionary, hierarchy:Boolean = false, resourceType:Class = null):void {
			if (geometry != null && (resourceType == null || geometry is resourceType)) resources[geometry] = true;
			material.fillResources(resources, resourceType);
			
			super.fillResources(resources, hierarchy, resourceType);
		}
		
		
		private function getTransformProcedure(maxSprites:int):Procedure {
			var key:String = maxSprites + "_" + (maxSprites * NUM_REGISTERS_PER_SPR) + "_z";
			var res:Procedure = _transformProcedures[key];
			if (res != null) return res;
			res = _transformProcedures[key] = new Procedure(null, "SpriteSetTransformProcedure");
			res.compileFromArray([
				"mov t2, c[a0.x].xyz",  // origin position in local coordinate space
				
				"sub t0, c3.xyz, t2.xyz",
				"mov t0.z, c1.w",  // #if zAxis
				"nrm t0.xyz, t0",  // look  (no longer needed after cross products)
				
				"crs t1.xyz, c1.xyz, t0.xyz",  // right      // cross product vs perp dot product for z case
						
				/* #if !zAxis  // (doesn't work to face camera, it seems only axis locking works)
				"crs t0.xyz, t0.xyz, t1.xyz",  // get (non-z) up vector based on  look cross with right
				"mul t0.xyz, t0.xyz, i0.yyy",   // multiple up vector by normalized xyz coodinates
				"mul t0.xyz, t0.xyz, c2.yyy",
				
				"add t2.xyz, t2.xyz, t0.xyz",
				*/
				
				"mul t0.xyz, i0.xxx, t1.xyz",   // multiple right vector by normalized xyz coodinates
				"mul t0.xyz, t0.xyz, c2.xxx",   // scale according to spriteset setting (right vector)
				"add t2.xyz, t2.xyz, t0.xyz",
			
				
				///*  // #if zAxis
				"mul t0.z, c2.y, i0.y",  // scale according to spriteset setting (fixed axis direction)
				"add t2.z, t2.z, t0.z",
				//*/
				
				"mov t2.w, i0.w",	
				"mov o0, t2",
				
				"#a0=joint",
				//"#c0=array",
				"#c1=up",  // up
				"#c2=spriteSet",
				"#c3=cameraPos"
			]);
		
			res.assignConstantsArray(maxSprites*NUM_REGISTERS_PER_SPR);
		
			return res;
		}
		
		private function getAxisAlignedTransformProcedure(maxSprites:int):Procedure {
			var key:String = maxSprites + "_" + (maxSprites * NUM_REGISTERS_PER_SPR) + "_axis";
			var res:Procedure = _transformProcedures[key];
			if (res != null) return res;
			res = _transformProcedures[key] = new Procedure(null, "SpriteSetTransformProcedure");
			res.compileFromArray([
				"mov t2, c[a0.x].xyz",  // origin position in local coordinate space
				
				"sub t0, c3.xyz, t2.xyz",
				//"mov t0.z, c1.w",  // #if zAxis
				"nrm t0.xyz, t0",  // look  (no longer needed after cross products)
				
				"crs t1.xyz, c1.xyz, t0.xyz",  // right      // cross product vs perp dot product for z case
						
				///* #if !zAxis  // (doesn't work to face camera, it seems only axis locking works)
				"crs t0.xyz, t0.xyz, t1.xyz",  // get (non-z) up vector based on  look cross with right
				"mul t0.xyz, t0.xyz, i0.yyy",   // multiple up vector by normalized xyz coodinates
				"mul t0.xyz, t0.xyz, c2.yyy",
				
				"add t2.xyz, t2.xyz, t0.xyz",
				//*/
				
				"mul t0.xyz, i0.xxx, t1.xyz",   // multiple right vector by normalized xyz coodinates
				"mul t0.xyz, t0.xyz, c2.xxx",   // scale according to spriteset setting (right vector)
				"add t2.xyz, t2.xyz, t0.xyz",
				
				/*  // #if zAxis
				"mul t0.z, c2.y, i0.y",  // scale according to spriteset setting (fixed axis direction)
				"add t2.z, t2.z, t0.z",
				*/
				
				"mov t2.w, i0.w",	
				"mov o0, t2",
				
				"#a0=joint",
				//"#c0=array",
				"#c1=up",  // up
				"#c2=spriteSet",
				"#c3=cameraPos"
			]);
		
			res.assignConstantsArray(maxSprites*NUM_REGISTERS_PER_SPR);
		
			return res;
		}
		
		private function getViewAlignedTransformProcedure(maxSprites:int):Procedure {
			var key:String = maxSprites + "_" + (maxSprites * NUM_REGISTERS_PER_SPR) + "_view";
			var res:Procedure = _transformProcedures[key];
			if (res != null) return res;
			res = _transformProcedures[key] = new Procedure(null, "SpriteSetTransformProcedure");
			
			
			res.compileFromArray([
				"mov t2, c[a0.x].xyz",  // origin position in local coordinate space
				
				"mov t1, t2",  //dummy not needed later change
		
				"mul t0.xyz, c2.xyz, i0.xxx",
				"mul t0.xyz, t0.xyz, c3.xxx", // scale according to spriteset setting (right vector)
				"add t2.xyz, t2.xyz, t0.xyz",
				
				"mul t0.xyz, c1.xyz, i0.yyy",
				"mul t0.xyz, t0.xyz, c3.yyy",  // scale according to spriteset setting  (up vector)
				"add t2.xyz, t2.xyz, t0.xyz",
				
				"mov t2.w, i0.w",	
				"mov o0, t2",
				
				"#a0=joint",
				//"#c0=array",
				"#c1=up", 
				"#c2=right",
				"#c3=spriteSet"
			]);
		
			res.assignConstantsArray(maxSprites*NUM_REGISTERS_PER_SPR);
		
			return res;
		}
		

	
	
		   
	}

}