package tests.flocking 
{
import flash.display.Loader;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import flash.system.LoaderContext;
import flash.utils.describeType;
import flash.utils.getDefinitionByName;

	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class Assets extends Sprite
	{
		//[Embed(source = "../../../bin/skins/mech/animations.ani", mimeType = "application/octet-stream")]
		[Embed(source="../../../bin/skins/animations.ani", mimeType="application/octet-stream")]
		public var MECH_ANIMS:Class;
		
		//[Embed(source = "../../../bin/skins/mech/mech_kayrath.a3d", mimeType = "application/octet-stream")]
		[Embed(source="../../../bin/skins/samnite_skinned.a3d", mimeType="application/octet-stream")]
		public var MECH_KAYRATH:Class;
		
		//[Embed(source = "../../../bin/skins/mech/skin.jpg")]
		[Embed(source="../../../bin/skins/textures/samnite_skin.png")]
		public var MECH_SKIN:Class;
		
		public function Assets() 
		{
			
		}
		
		private var _loader:ClassLoader; 
		private var packagePrefix:String;
		
		public function load(url:String, packagePath:String, context:LoaderContext):void {
			_loader = new ClassLoader();
			if (packagePath != "") {
				packagePrefix = packagePath+ "::";
			}
			else packagePrefix = null;
			_loader.addEventListener(ClassLoader.CLASS_LOADED, onLoadComplete);
			_loader.load(url, context);
		}
		
		private function onLoadComplete(e:Event):void {
			(e.currentTarget as IEventDispatcher).removeEventListener(e.type, onLoadComplete);
			
			var me:Object = Object(this);
			var variables : XMLList = describeType( me.constructor ).factory.variable;

			var classe:Class = _loader.getClass( packagePrefix + "Assets");
			var refer:Object = new classe();
			
			  for each ( var atom:XML in variables )
				{		
					var componentClass : Class = refer[atom.@name.toString()];			
					me[atom.@name.toString()] = componentClass;
					
				}

				dispatchEvent( new Event(Event.COMPLETE));
			}
		}
	
}


// written by @9re
// MIT License, see http://www.opensource.org/licenses/mit-license.php

    import flash.display.Loader;
    import flash.errors.IllegalOperationError;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.events.IOErrorEvent;
    import flash.events.ProgressEvent;
    import flash.events.SecurityErrorEvent;
    import flash.net.URLRequest;
    import flash.system.ApplicationDomain;
    import flash.system.LoaderContext;

    class ClassLoader extends EventDispatcher {
        public static var CLASS_LOADED:String = "classLoaded";
        public static var LOAD_ERROR:String = "loadError";
        private var loader:Loader;
        private var swfLib:String;
        private var request:URLRequest;
        private var loadedClass:Class;
        
        public function ClassLoader() {
            loader = new Loader();
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler);
            loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
            loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, securityErrorHandler);
        }
        
        public function load(lib:String, context:LoaderContext):void {
            swfLib = lib;
            request = new URLRequest(swfLib);
            loader.load(request, context);
        }
            
        public function getClass(className:String):Class {
            try {
                var c:Class = loader.contentLoaderInfo.applicationDomain.getDefinition(className) as Class;
                return c;
            }
            catch(e:Error) {
                throw new IllegalOperationError(e + className + " definition not found in " + swfLib);
            }
            return null;
        }
        
        private function completeHandler(e:Event):void {
            dispatchEvent(new Event(ClassLoader.CLASS_LOADED));
        }
        
        private function ioErrorHandler(e:Event):void {
            dispatchEvent(new Event(ClassLoader.LOAD_ERROR));
        }
        
        private function securityErrorHandler(e:Event):void {
            dispatchEvent(new Event(ClassLoader.LOAD_ERROR));
        }

    }

