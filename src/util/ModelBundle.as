package util 
{
	import alternativa.engine3d.core.VertexAttributes;
	import alternativa.engine3d.loaders.ParserA3D;
	import alternativa.engine3d.materials.Material;
	import alternativa.engine3d.materials.TextureMaterial;
	import alternativa.engine3d.objects.Mesh;
	import alternativa.engine3d.objects.Surface;
	import alternativa.engine3d.resources.BitmapTextureResource;
	import flash.display.BitmapData;
	import flash.utils.describeType;
	import flash.utils.Dictionary;
	import alternativa.engine3d.alternativa3d;
	use namespace alternativa3d;
	/**
	 * ...
	 * @author Glidias
	 */
	public class ModelBundle extends SpawnerBundle
	{
		protected var savedAssets:Array;
		public var modelHash:Object = { };
		
		public function ModelBundle(assets:Array) 
		{
			savedAssets = assets.concat();
			ASSETS = assets;
			
			super();
		}
		
		override protected function init():void {
			var mesh:Mesh;
			var type:String;
			var n:XML;
			var ider:String;
			var nameSpl:Array;
			var namer:String;
			var len:int = savedAssets.length;
			var xml:XML;
			var parser:ParserA3D = new ParserA3D();
			
			for (var i:int = 0; i < len; i++) {
				var classe:Object = savedAssets[i];
				xml = describeType(classe);
				var variables : XMLList = xml.variable;
				
				for each(n in variables) { 
					
					namer = n.@name;
					nameSpl = namer.split("_");
					type = nameSpl[0];
					if (type === "MODEL") {
						ider = nameSpl[nameSpl.length - 1];
						
						
						parser.parse(new (classe[namer])());
						mesh = parser.objects[1] as Mesh || parser.objects[0] as Mesh;
						
						//throw new Error(mesh.geometry.numTriangles
					
						modelHash[ider] = mesh;
						
					}
				}
				
				for each(n in variables) { 
					
					namer = n.@name;
					nameSpl = namer.split("_");
					type = nameSpl[0];
					if (type === "TEXTURE") {
						ider = nameSpl[nameSpl.length - 1];
						mesh = modelHash[ider];
						var data:BitmapData = new (classe[namer])().bitmapData;
						var material:Material = new TextureMaterial( new BitmapTextureResource(data) );
						mesh.setMaterialToAllSurfaces( material );
					}
				}
						
			}
			
			uploadAll();
			super.init();
		}
		
		public function getModel(id:String):Mesh {
			return modelHash[id];
		}
		
		public function getMaterial(id:String, surfaceIndex:int = 0):Material {
			return ((modelHash[id] as Mesh).getSurface(surfaceIndex) as Surface).material;
		}
		
		///*
		private function uploadAll():void {
			for (var id:String in modelHash) {
				
				uploadResources( (modelHash[id] as Mesh).getResources() );
				//	if ((modelHash[id] as Mesh).geometry.getVertexBuffer(VertexAttributes.POSITION) == null) throw new Error("Missing");
				
			}
		}
		///*/
		
		
		
	}

}