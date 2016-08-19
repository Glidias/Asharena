/*
*	Legacy function to render a brand new GUI to returns data parameters 
*	@param paramsGUI	The parameter definition for GUI construction
*	@param optionsGUI	Any custom setup options for GUI render/instance
* 	@return params, a stripped version of paramsGUI, without all the GUI fluff
*/
function guiGlue(paramsGUI, optionsGUI){


    //pass options to GUI e.g., { autoPlace: false }
    optionsGUI = optionsGUI || {};

    //extra parameter whether you want folders open or closed
    optionsGUI.folded = optionsGUI.folded || false;

    // params is a stripped version of paramsGUI, where everything
    // but its default attributes have been removed
    var params = {};
    var gui = guiGlueRender(paramsGUI, optionsGUI, params);
	

    //return stripped parameter object
    return params;
}


/*
*	Re-apply back default settings from paramsGUI
*	@param paramsGUI	The parameter definition used for GUI construction
*	@param params		The target object which hold/receives striped down parameters with actual values. 
*/
function guiGlueApplyDefaults(paramsGUI, params) {
	var key;
	for (var key in paramsGUI){
		if (key.charAt(0) === "_") continue;  // ignore all underscored properties
		if (paramsGUI[key]) {
			if (paramsGUI[key].value != undefined) {  // assumed leaf,  value null should be also be considered a valid settable value
				params[key] = paramsGUI[key].value;
			}
			else if (!paramsGUI[key]._isLeaf && !paramsGUI[key]._subProxy) {   // assumed nested object
				if (params[key] != null ) {
					if (typeof params[key] != "object") {
						alert( "is object assertion failed for key:"+key);  // There might be an exception here..track it just in case.
						continue;
					}
				}
				else {  // dynamically recreate params again
					params[key] = {};
					if (paramsGUI._hxclass) params[key]._hxcls = paramsGUI._hxclass;
				}
				guiGlueApplyDefaults( paramsGUI[key], params[key]); // = value;
			}
		}
	}
}

/*
*	Basic function to render a GUI
*	@param paramsGUI	The parameter definition for GUI construction
*	@param optionsGUI	Any custom setup options for GUI render/instance
*	@param params		The target object to hold/receive striped down parameters with actual values. 
*	@param existingGUI	(Optional) Any existing dat.GUI instance if any
* 	@return The dat.GUI instance
*/
function guiGlueRender(paramsGUI, optionsGUI, params, existingGUI) {

	if (optionsGUI == null) optionsGUI = {};
	if (params ==null) params = {};
	
	//initial creation    
	var gui = existingGUI ? existingGUI : new dat.GUI(optionsGUI);
	gui["_guiGlueParams"] = params;
	if (paramsGUI._hxclass) params._hxcls = paramsGUI._hxclass;

	//walk the parameter tree
	unfurl(paramsGUI, gui, params);

	function unfurl(obj, folder, params){

		for (var key in obj){
			
			//if (key === "_isLeaf" || key === "_classes") continue; // consider: ignore all properties that start with underscores?
			if (key.charAt(0) === "_") continue;  // ignore all underscores
			
			var subObj = obj[key];
	
			var leaf = isLeaf(subObj);
		
			if (leaf){
				addToFolder(key, obj, subObj, folder, params);
			}
			else{ 
				//is folder
				var subfolder = folder.addFolder(key);
				params[key] = {};
				subfolder["_guiGlue"] = obj[key];
				subfolder["_guiGlueParams"] = params[key];
				if ( obj[key]._hxclass)  params[key]._hxcls =  obj[key]._hxclass;
				
				// style parent LI with custom classes
				if (obj[key]["_classes"]) {
					var a = subfolder.domElement.parentNode;  // warning, hack to get parent LI 
					if (a.classList) {
						a.classList.add.apply(a.classList, obj[key]._classes);
						
					} else {
						a.className += ' '+obj[key]._classes.join(" ");
					}
				}
				
				if ( (obj[key]._folded!=undefined ? !obj[key]._folded : !optionsGUI.folded) )
					subfolder.open();
					
				unfurl(obj[key], subfolder, params[key]);
			}

		}

		//a leaf object is one that contains no other objects
		//it is critical that none of the tracked parameters is itself an object
		function isLeaf(obj){

			var Leaf = true;
			var gotKeys = false;
			if (obj._isLeaf) return true;  // enforce hack using _isLeaf flag if available
			for (var key in obj){
				gotKeys = true;
				if ( (key === 'choices' && obj.display === 'selector') ) continue;

				if (Leaf){
					var notObj = (Object.prototype.toString.call( obj[key] ) != '[object Object]');
					Leaf = Leaf && notObj;
		
				}
				else
					continue;
			}

			return Leaf && gotKeys;

		}

	}

	function addToFolder(key, obj, options, folder, params){

		var handle;
		params[key] = options.value;

		var display = options.display || '';

		switch (display){
			case 'range':
				handle = folder.add(params, key, options.min, options.max, options.step, options.enumeration);
				break;
			case 'selector':
				handle = folder.add(params, key, options.choices);
				break;
			case 'color':
				handle = folder.addColor(params, key);
				break;
			case 'textarea':
				handle = folder.addTextArea(params, key);
				break;
			case 'none':
				break;
			default:
				handle = folder.add(params, key, options.min, options.max, options.step);
				break;
		}
		if (handle) {
			
			if ( options.onChange)
				handle.onChange(options.onChange);

			if ( options.onFinishChange)
				handle.onChange(options.onFinishChange);

			if (  options.listen)
				handle.listen();
				
			// style parent LI with custom classes
			if (  options._classes) {
				// warning: hackish way to get LI tag
				var a = handle.domElement.parentNode.parentNode;
				if (a.classList) {
					a.classList.add.apply(a.classList, options._classes);
					
				} else {
					a.className += ' '+options._classes.join(" ");
				}
			}
			if  (options._readonly && handle["__input"]) {
				
				handle.__input.setAttribute("readonly", "readonly")
			}
			handle["_guiGlue"] = options;
		
			
		}
	}
	
	
	gui["_guiGlue"] = paramsGUI;
	return gui;

}