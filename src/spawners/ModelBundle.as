package spawners 
{
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.materials.Material;
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	import systems.player.a3d.AnimationManager;
	import util.SpawnerBundle;
	/**
	 * Basic utility bundle package to load in a 3d model class and any other assosiated assets with it (include sub 3d-models)
	 * @author Glenn Ko
	 */
	public class ModelBundle extends SpawnerBundle
	{
		private var rootClasse:Class;
		public var root:ModelPacket;
		public var subModels:Object;
		
		public function ModelBundle(classe:Class) 
		{
			this.rootClasse = classe;
			ASSETS = [classe];
			var xml:XML = describeType(classe);
			
			// look for static function of possible private classes to instantaite...use getDefinitionByName || toString() to be able to retrieve private class names?
			// If have, create subModels object...linking to each class
			throw new Error(xml);
			
			// check if rootClasse has anything useful, if have, place it in...
			//	modelBundle.
			//Object(classe)[""];
			
			//throw new Error( getDefinitionByName("::ElementalEarth") );
		//	throw new Error(xml);
		// does class need to be isntantaited to describe,,

		}
		
		override protected function init():void {
			super.init();
			
			// based off class, assign model, material, animManager 
			
			// if got root modelPacket
			
			// if got subModels....do so for each
		}
		
		
		
	}

}
