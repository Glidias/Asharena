package alternativa.engine3d.utils {
import alternativa.engine3d.alternativa3d;
import alternativa.engine3d.core.Object3D;
import alternativa.engine3d.core.VertexAttributes;
import alternativa.engine3d.loaders.ParserMaterial;
import alternativa.engine3d.materials.LightMapMaterial;
import alternativa.engine3d.materials.StandardMaterial;
import alternativa.engine3d.materials.TextureMaterial;
import alternativa.engine3d.materials.VertexLightTextureMaterial;
import alternativa.engine3d.objects.Mesh;
import alternativa.engine3d.objects.Surface;
import alternativa.engine3d.resources.BitmapTextureResource;
import alternativa.engine3d.resources.ExternalTextureResource;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display3D.Context3D;
import flash.display3D.Context3DTextureFormat;
import flash.display3D.textures.CubeTexture;
import flash.display3D.textures.Texture;
import flash.display3D.textures.TextureBase;
import flash.geom.Matrix;
import flash.utils.ByteArray;
import flash.utils.Endian;

use namespace alternativa3d;

/**
 * Utility to process materials and setup external textures
 */
public class MaterialProcessor {

	public function MaterialProcessor(context3D:Context3D) {
		context = context3D;
		//bumpResources = new Vector.<ExternalTextureResource>();
	}

	private static const BUMP:String = "bump";
	private static const EMISSION:String = "emission";
	private static const DIFFUSE:String = "diffuse";
	private static const SPECULAR:String = "specular";
	private static const GLOSSINESS:String = "glossiness";
	private static const TRANSPARENT:String = "transparent";

	private static const DEFAULT_BUMP:BitmapData = new BitmapData(1, 1, false, 0x7F7FFF);
	private static const DEFAULT_DIFFUSE:BitmapData = new BitmapData(1, 1, false, 0x888888);

	private var context:Context3D;
//	private var bumpResources:Vector.<ExternalTextureResource>;

	/**
	 * Iterate through input objects and setup needed materials
	 * @param objects - vector of Object3D to iterate through
	 * @param simpleTextureMaterial - Enforce basic TextureMaterial or LightMapMaterial only.
	 */
	public function setupMaterials(objects:Vector.<Object3D>, simpleTextureMaterial:Boolean=false):void {
		var objectsQuantity:uint = objects.length;
		for (var objInd:uint = 0; objInd < objectsQuantity; objInd++) {
			//try to process object as Mesh
			var processedMesh:Mesh = objects[objInd] as Mesh;
			if (processedMesh != null) {
				//read and store geometry flags
				var meshHasNormals:Boolean = simpleTextureMaterial ? false : processedMesh.geometry && processedMesh.geometry.hasAttribute(VertexAttributes.NORMAL);
				var meshHashTangent:Boolean = simpleTextureMaterial ? false : processedMesh.geometry && processedMesh.geometry.hasAttribute(VertexAttributes.TANGENT4);
				var meshHashTexCoord:Boolean = processedMesh.geometry && processedMesh.geometry.hasAttribute(VertexAttributes.TEXCOORDS[1]);

				//iterate through mesh surfaces
				var meshSurfacesQuantity:uint = processedMesh.numSurfaces;
				for (var surfaceInd:uint = 0; surfaceInd < meshSurfacesQuantity; surfaceInd++) {
					var surface:Surface = processedMesh.getSurface(surfaceInd);
					//get surface material textures or create default
					var materialTextures:Object;
					if (surface.material) {
						materialTextures = (surface.material as ParserMaterial).textures;
					}
					else {
						materialTextures = createDefaultMaterialTextures();
					}

					//if no diffuse texture - create default diffuse
					if (!materialTextures[DIFFUSE]) {
						materialTextures[DIFFUSE] = new BitmapTextureResource(DEFAULT_DIFFUSE);
					}

					//check different cases to figure out what materials must be created
					if (materialTextures[BUMP] && meshHashTangent) {
						surface.material = createStandardMaterial(materialTextures);
						//if (materialTextures[BUMP] is ExternalTextureResource) {
						//	bumpResources.push(materialTextures[BUMP]);
						//}
					}
					else if (materialTextures[EMISSION]) {
						surface.material = createLightMapMaterial(materialTextures,
								meshHashTexCoord);
					}
					else if (meshHasNormals) {
						surface.material = createVertexLightMaterial(materialTextures);
					}
					else {
						surface.material = createTextureMaterial(materialTextures);
					}
				}
			}
		}
	}

	/**
	 * Apply external data to texture
	 * @param texture - target texture
	 * @param source - data to apply
	 * @param isATF - flag indicating whether interpret data as image (isATF == false) or as compressed texture format (Adobe Texture Format)
	 */
	public function setupExternalTexture(texture:ExternalTextureResource, source:Object, isATF:Boolean):void {
		if (source) {
			//if not atf - process like image
			if (!isATF) {
				setupExternalTextureFromBitmap(texture, (source is Bitmap ? (source as Bitmap).bitmapData : source as BitmapData) );
			}
			// otherwise process like atf data
			else {
				setupCompressedTexture(texture, source as ByteArray);
			}
		}
		//if no source data specified - setup default bitmap to target texture
		else {
		//	setupExternalTextureFromBitmap(texture, (bumpResources.indexOf(texture) == -1) ? DEFAULT_DIFFUSE : DEFAULT_BUMP);
			setupExternalTextureFromBitmap(texture, DEFAULT_DIFFUSE);
		}
	}

	private function setupExternalTextureFromBitmap(textureResource:ExternalTextureResource, resourceData:BitmapData):void {
		//size of bitmap must be power of 2
		resourceData = fitTextureToSizeLimits(resourceData);

		//create texture and upload bitmap data
		var texture:Texture = context.createTexture(resourceData.width, resourceData.height, Context3DTextureFormat.BGRA, false);
		texture.uploadFromBitmapData(resourceData, 0);

		//create mips and link texture and resource
		BitmapTextureResource.createMips(texture, resourceData);
		textureResource.data = texture;
	}

	private function setupCompressedTexture(texture:ExternalTextureResource, byteArray:ByteArray):void {
		byteArray.endian = Endian.LITTLE_ENDIAN;
		byteArray.position = 6;

		var type:uint = byteArray.readByte();
		var format:String;
		//read format
		switch (type & 0x7F) {
			case 0:
				format = Context3DTextureFormat.BGRA;
				break;
			case 1:
				format = Context3DTextureFormat.BGRA;
				break;
			case 2:
				format = Context3DTextureFormat.COMPRESSED;
				break;
		}

		var textureBase:TextureBase;
		//create texture data depending on format
		if ((type & ~0x7F) == 0) {
			textureBase = context.createTexture(1 << byteArray.readByte(), 1 << byteArray.readByte(), format, false);
			Texture(textureBase).uploadCompressedTextureFromByteArray(byteArray, 0);
		}
		else {
			textureBase = context.createCubeTexture(1 << byteArray.readByte(), format, false);
			CubeTexture(textureBase).uploadCompressedTextureFromByteArray(byteArray, 0)
		}

		//apply data to texture
		texture.data = textureBase;
	}

	private function createDefaultMaterialTextures():Object {
		var textures:Object = new Object();
		textures[DIFFUSE] = new BitmapTextureResource(DEFAULT_DIFFUSE);
		return textures;
	}

	private function createStandardMaterial(materialTextures:Object):StandardMaterial {
		var material:StandardMaterial;
		material = new StandardMaterial(materialTextures[DIFFUSE],
				materialTextures[BUMP],
				materialTextures[SPECULAR],
				materialTextures[GLOSSINESS],
				materialTextures[TRANSPARENT]);

		if (materialTextures[SPECULAR] == null){
			material.specularPower = 0;
		}

		return material;
	}

	private function createLightMapMaterial(materialTextures:Object, meshHashTexCoord:Boolean):LightMapMaterial {
		var material:LightMapMaterial;
		var lightMapChannel:uint = meshHashTexCoord ? 1 : 0;
		material = new LightMapMaterial(materialTextures[DIFFUSE],
				materialTextures[EMISSION],
				lightMapChannel,
				materialTextures[TRANSPARENT]);

		return material;
	}

	private function createTextureMaterial(materialTextures:Object):TextureMaterial {
		var material:TextureMaterial;
		material = new TextureMaterial(materialTextures[DIFFUSE], materialTextures[TRANSPARENT]);
		return material;
	}

	private function createVertexLightMaterial(materialTextures:Object):VertexLightTextureMaterial {
		var material:VertexLightTextureMaterial;
		material = new VertexLightTextureMaterial(materialTextures[DIFFUSE], materialTextures[TRANSPARENT]);
		return material;
	}

	private function fitTextureToSizeLimits(textureData:BitmapData):BitmapData {
		var fittedTextureData:BitmapData = textureData;
		var width:Number = getNearPowerOf2For(fittedTextureData.width);
		var height:Number = getNearPowerOf2For(fittedTextureData.height);

		if (width != fittedTextureData.width || height != fittedTextureData.height) {
			var newBitmap:BitmapData = new BitmapData(width, height, fittedTextureData.transparent);
			var matrix:Matrix = new Matrix(width/fittedTextureData.width, 0, 0, height/fittedTextureData.height);
			newBitmap.draw(fittedTextureData, matrix);
			fittedTextureData = newBitmap;
		}

		return fittedTextureData;
	}

	private function getNearPowerOf2For(size:Number):Number {
		if (size && (size - 1)) {
			for (var i:int = 11; i > 0; i--) {
				if (size >= (1 << i)) {
					return 1 << i;
				}
			}
			return 0;
		} else {
			return size;
		}
	}
}
}