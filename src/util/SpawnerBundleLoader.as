package util 
{
	import ash.signals.Signal1;
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.system.Security;
	import flash.system.SecurityDomain;
	import flash.utils.describeType;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	import flash.utils.setTimeout;
	import hx.Xml;
	/**
	 * ...
	 * @author Glenn Ko
	 */
	public class SpawnerBundleLoader 
	{
		private var completeHandler:Function;
		
		private var _totalLoads:int = 0;
		private var _curLoaded:int = 0;
	
	
		private var loadList:Vector.<LoadItem>;
		public var baseUrlPrefix:String = "bundle/";
		private var context:LoaderContext;
		private static const CROSS_DOMAIN_POLICY:String = "http://glidias.uphero.com/crossdomain.xml";
		private var LOADED_DOMAIN:ApplicationDomain = new ApplicationDomain();
		private var currentLoadItem:LoadItem;
		public var progressSignal:Signal1 = new Signal1();
		public var loadBeginSignal:Signal1 = new Signal1();
		
		public function SpawnerBundleLoader(stage:Stage, completeHandler:Function, bundleList:Vector.<SpawnerBundle>) 
		{
			this.completeHandler = completeHandler;
			loadList = new Vector.<LoadItem>();
			
			var domain:SecurityDomain = stage.loaderInfo.url.indexOf("file://") >= 0 ? null : SecurityDomain.currentDomain;
			if (domain != null) {
				Security.loadPolicyFile(CROSS_DOMAIN_POLICY);	
			}
				
			context = new LoaderContext( domain != null, new ApplicationDomain( LOADED_DOMAIN), domain);
			
			var i:int = bundleList.length;
			_totalLoads = 0;
			while (--i > -1) {
				var considerAsset:SpawnerBundle = bundleList[i];
				if (considerAsset.ASSETS != null) {
					var u:int = considerAsset.ASSETS.length;
					while (--u > -1) {
						loadList.push( new LoadItem(baseUrlPrefix+getQualifiedClassName(considerAsset.ASSETS[u]).split(".").join("/").replace("::", "/") + ".swf", considerAsset.ASSETS[u], getQualifiedClassName(considerAsset.ASSETS[u]), considerAsset)  );
					}
					_totalLoads++;
				}
			}
			
			setTimeout(checkNext,1);
		}
		
		private function checkNext():void {
			
			if (loadList.length == 0) {
				currentLoadItem = null;
				completeHandler();
				return;
			}
			currentLoadItem = loadList.pop()
			
			loadSpawnerBundle(currentLoadItem  );
		}
		
		private function loadSpawnerBundle(loadItem:LoadItem):void 
		{
			var loader:ClassLoader = new ClassLoader();
			loadBeginSignal.dispatch(loadItem.targetInstance.toString());
			var filename:String = loadItem.url;
		//	throw new Error(filename);
			loader.addEventListener(ClassLoader.CLASS_LOADED, handleLoadComplete);
			loader.load(filename, context);
			//throw new Error(filename);
			
				
		}
		
		private function handleLoadComplete(e:Event):void {
			var atom:XML;
		
			
			(e.currentTarget as IEventDispatcher).removeEventListener(e.type, handleLoadComplete);
			
			var me:Object = currentLoadItem.targetInstance;
			var xmler:XML = describeType( me );
			var getSubClasses:XMLList = xmler.method.(@name == "$getSubClasses");
			
			var variables : XMLList = xmler.variable;
			
			
			var loader:ClassLoader = (e.currentTarget as ClassLoader);
			var classe:Class = loader.getClass( currentLoadItem.className );
			
			
			
		
			  for each ( atom in variables )
				{		
					var componentClass : * = classe[atom.@name.toString()];			
					if (componentClass != null) {
						var prop:String = atom.@name.toString();
						if (me[prop] == null) me[prop] = componentClass;
					}
					else {
						// throw new Error("COuld not find classe!" + currentLoadItem.targetInstance);
					}
				}
				
				//TODO: get internal classes
				//if (loader.loader.contentLoaderInfo.applicationDomain.hasDefinition("private::ElementalFire")) {
				//	throw new Error("TES");
				//}
				if (getSubClasses.length()) {
					var subClassList:Array = me["$getSubClasses"]();
					var i:int = subClassList.length;
					while (--i > -1 ) {
						var subClass:Object = subClassList[i];
						var subClassXML:XML = describeType(subClass);
						variables = subClassXML.variable;
						var str:String = subClass.toString();
						str = str.slice(7, str.length - 1);
						
					  for each ( atom in variables )
						{	
							
							prop = atom.@name.toString();
							componentClass = loader.getClass(str+"_"+prop);
							if (subClass[prop] == null) {
								subClass[prop] = componentClass;
								//throw new Error("injecting:" + componentClass);
							}
							//else {
							//	throw new Error(subClass[prop]);
							//}
						}

						//var subClass:Class = loader.getClass();
					}
				}
				
			//	currentLoadItem.doInit();
				
					_curLoaded++;
					
					progressSignal.dispatch(_curLoaded/_totalLoads);
					
					currentLoadItem.popCheck();
					
					checkNext();
			}
			
			public function get curLoaded():int 
			{
				return _curLoaded;
			}
			
			public function get totalLoads():int 
			{
				return _totalLoads;
			}
			
			public function get curLoadItem():* 
			{
				return currentLoadItem ? currentLoadItem.targetInstance : null;
			}
			
			public function get curLoadItemString():String
			{
				return currentLoadItem ? String(currentLoadItem.targetInstance) : "";
			}
			
		
		}
		
}

import util.SpawnerBundle;

class LoadItem {
	public var url:String;
	public var targetInstance:*;
	public var className:String;
	public var bundle:SpawnerBundle;
	
	public function LoadItem(url:String, targetInstance:*, className:String, bundle:SpawnerBundle):void {
		this.url = url;
		this.targetInstance = targetInstance;
		this.className = className;
		this.bundle = bundle;
	}
	
	public function popCheck():void {
		bundle.ASSETS.pop();
		if (bundle.ASSETS.length == 0) bundle._doInit()
	
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
        public var loader:Loader;
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