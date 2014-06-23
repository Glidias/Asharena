package spawners.arena.skybox 
{
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.materials.TextureMaterial;
	import alternativa.engine3d.objects.SkyBox;
	import alternativa.engine3d.resources.BitmapTextureResource;
	import flash.display.Scene;
	import util.SpawnerBundle;
	import alternativa.engine3d.alternativa3d;
	use namespace alternativa3d;
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class SkyboxBase extends SpawnerBundle
	{
		private var assetClasse:Object;
		private var size:Number;
		public var skybox:SkyBox;
		
		
		public function SkyboxBase(assetClasse:Class, size:Number=4194304) 
		{
			this.size = size;
			this.assetClasse = assetClasse;
			ASSETS = [assetClasse];
			super();
		}
		
		
		override protected function init():void {
			// Skybox
			// create skybox textures
			
			var topres:BitmapTextureResource = new BitmapTextureResource(new assetClasse.SBTop().bitmapData);			
			var top:TextureMaterial = new TextureMaterial(topres);
			var bottomres:BitmapTextureResource = new BitmapTextureResource(new assetClasse.SBBottom().bitmapData);
			var bottom:TextureMaterial = new TextureMaterial(bottomres);
			var frontres:BitmapTextureResource = new BitmapTextureResource(new assetClasse.SBFront().bitmapData);
			var front:TextureMaterial = new TextureMaterial(frontres);
			var backres:BitmapTextureResource = new BitmapTextureResource(new assetClasse.SBBack().bitmapData);
			var back:TextureMaterial = new TextureMaterial(backres);
			var leftres:BitmapTextureResource = new BitmapTextureResource(new assetClasse.SBLeft().bitmapData);
			var left:TextureMaterial = new TextureMaterial(leftres);
			var rightres:BitmapTextureResource = new BitmapTextureResource(new assetClasse.SBRight().bitmapData);
			var right:TextureMaterial = new TextureMaterial(rightres);			
			topres.upload(context3D);
			bottomres.upload(context3D);
			leftres.upload(context3D);
			rightres.upload(context3D);
			frontres.upload(context3D);
			backres.upload(context3D);		
	
			skybox = new SkyBox(size, left,right,front,back,bottom,top,0.005);
			skybox.geometry.upload(context3D);
	
			
			super.init();
		}
		
		public function addToScene(scene:Object, distance:Number = 0):void {
			
			scene.addChild(skybox);
		}
		
		public function update(camera:Object3D):void 
		{
			if (camera.transformChanged) {
				skybox._x = camera._x;
				skybox._y = camera._y;
				skybox.transformChanged = true;
			}
		}
		
		
	}

}