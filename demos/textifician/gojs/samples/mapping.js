(function() {
	var myDiagramDivs;
	
	var TEXTLABEL_BASEWIDTH = 80;
	var MAX_SHAPE_SIZE = 512;
	var POINT_SIZE = 5;
	var POINT_PLAY_SIZE = window["POINT_PLAY_SIZE"] != null ? window["POINT_PLAY_SIZE"] : 3;  
	var CHAR_SIZE = window["MAP_CHARACTER_SIZE"] != null ? window["MAP_CHARACTER_SIZE"] : 10;
	var INFLUENCE_SIZE_SCALE = window["INFLUENCE_SIZE_SCALE"] != null ? window["INFLUENCE_SIZE_SCALE"] : 1; 


	function getUrlVars()
	{
		var vars = [], hash;
		var hashes = window.location.href.slice(window.location.href.indexOf('?') + 1).split('&');
		for(var i = 0; i < hashes.length; i++)
		{
			hash = hashes[i].split('=');
			vars.push(hash[0]);
			vars[hash[0]] =decodeURIComponent( hash[1]);
		}
		return vars;
	}
	var initQueryParams = getUrlVars();

	var initedMapDomain = initQueryParams.domain ? initQueryParams.domain : "iedaw6";
	var initedSelfDomain = initQueryParams.self || false;
	var showArcsInit = initQueryParams.arcs || false;
	var initedWithDashboard = initQueryParams.dashboard && initQueryParams.dashboard != '0' ? true : false;

	var VIEW_MODE_EDIT = 1;
	var VIEW_MODE_PLAY = 2;

	var VIEWFLAG_VIS = 1;
	var VIEWFLAG_FULL_SIZE = 2;
	var VIEWFLAG_ENFORCE_ALL_LABELS = 4;
	var VIEWFLAG_SHOW_ARCS = 8;

	var vuePanel;

	var hashPosition = new hashids.Hashids("salt", 0, "abcdefghijkLmnopqrstuvwxyz1234567890ABCDEFGHJKMNPQRSTUVWXYZ" );

	

	function onUIDragStart() {
		myDiagramDivs.css("pointer-events", "none");
	}
	function onUIDragStop() {
		myDiagramDivs.css("pointer-events", "auto");
	}
	
	function getCategoryStringFromType(newValue) {
	
		if (typeof(newValue) != 'number') {
			alert("Wrong type assigned for:"+newValue + "::" +typeof(newValue) + ", "+(newValue===null));
			return;
		}
		return newValue === LocationDefinition.TYPE_POINT ? "point" : newValue=== LocationDefinition.TYPE_PATH ? "path" : "region";
	}
	function getUniformSize(size) {
		if (typeof(size) != 'number') return;
		if (size < 0) size = 999999999;
		return new go.Size(size,size);
	}
	function getScaledUniformSize(size,scale) {
		if (typeof(size) != 'number') return;
		if (size < 0){
			return new go.Size(999999999,999999999);
		} 
		return new go.Size(size*scale,size*scale);
	}
	
	function updateAllControllers(newTarget) {
		// method to update all object targets of:
	  var i =  this._controllers.length;
	  var c;
	 
	  while(--i > -1) {
		c = this._controllers[i];
		c.object = newTarget;
		c.updateDisplay();
	  }
	  
	   // and all sub-leaf proxies:
	   if (this["_subProxies"]) {
		 i = this._subProxies.length;
		  while(--i > -1) {
			this._subProxies[i]._target = newTarget;
			
		 }
	   }
	}
	
	var targetProxyHandler = {
		set: function(t, prop, value, receiver) {
			if (prop.charAt(0) != "_") {
				t._target[prop] = value;
			 
			}
			else  {
				t[prop]= value;
				if (prop === "_target" && t["_onTargetChanged"]) {
					t._onTargetChanged.apply(t, [value]);
				}
			}
		}
		,get: function(t, prop, receiver) {

			return (prop.charAt(0) != "_" ? t._target : t )[prop];
		}
	};
	


	function exposeHxMappingClassesToGlobalNamespace() {
		var p;
		var arr = [];
		for (p in textifician.mapping) {
			window[p] = textifician.mapping[p];
		}
	}
	exposeHxMappingClassesToGlobalNamespace();
	var TJSON = tjson.TJSON;

	
	var DatUtil = dat.gui.DatUtil;
	//DatUtil.DEFAULT_FLOAT_STEP = .001;
	
	var DEFAULT_PICTURE_OPACITY = .75;
	var DEFAULT_LOADED_ARC_OPACITY = 0.8;
	var DEFAULT_ARC_OPACITY =  1; //0.3;
	var NON_WALKABLE_ARC_OPACITY = 0.7;

	var world = new TextificianWorld();
	world.setupDefaultNew();
	var CHAR_LOC_DEF = LocationDefinition.create(LocationDefinition.TYPE_REGION, "CharPlay", "CharPlay");
	var REGIONPLAY_LOC_DEF = LocationDefinition.create(LocationDefinition.TYPE_REGION, "RegionPlay", "RegionPlay");
	var POINTPLAY_LOC_DEF = LocationDefinition.create(LocationDefinition.TYPE_POINT, "PointPlay", "PointPlay");
	REGIONPLAY_LOC_DEF.gameplayCategory = "regionPlay";
	CHAR_LOC_DEF.gameplayCategory = "char";
	POINTPLAY_LOC_DEF.gameplayCategory = "pointPlay";
  
	world.addLocationDef( CHAR_LOC_DEF );
	world.addLocationDef( REGIONPLAY_LOC_DEF );
	world.addLocationDef( POINTPLAY_LOC_DEF );
	var worldProtoLocIds = world.getDefaultLocationDefIdHash();

	
	window.init = init;
	
	var allLocationGUIDom = $("");
	
	
	function getGuiControllerLi(gui, controllerName) {
		return $( $(gui.getControllerByName(controllerName).domElement).parents("li")[0] );
	}
	
	function guiFunction(obj, labelProp, func) {
		var labelToUse =obj[labelProp];
		obj[labelToUse] = func;
		return labelToUse;
	}

  function init() {
  
	//DATGUI
	var specsLocationDefinition = DatUtil.setup( new LocationDefinition() );
	specsLocationDefinition.size.step = .001;
	

	var gui = setupGUIGeneric( guiGlueRender(specsLocationDefinition, null, {}) );
	gui.domElement.setAttribute("id", "locationDefGUI");
	gui.getControllerByName("size").__input.setAttribute("step", "any");
	
	
	function loadWorld(mapStream) {
		world.loadWorld(mapStream);
		world.addLocationDef( CHAR_LOC_DEF, true );
		world.addLocationDef( REGIONPLAY_LOC_DEF, true );
		world.addLocationDef( POINTPLAY_LOC_DEF, true);
		vueModelData.locationDefIds = world.getLocationDefinitionIds(world.getDefaultLocationDefIdHash());
		var goData = world.getGOGraphData(GO_SIZES, DEFAULT_PICTURE_OPACITY);
		//var newModel = new go.GraphLinksModel(goData.nodes, goData.links);
		myDiagram.model.nodeDataArray = goData.nodes;
		myDiagram.model.linkDataArray = goData.links;

		var arr = myDiagram.model.nodeDataArray;
		var i = arr.length;
		while(--i > -1) {
			if (arr[i].zoneid != null)  {
				Object.defineProperty(arr[i],"text",zoneTextProxy);
				INFLUENCE_SIZE_SCALE = arr[i]._node.val.scale;
			}
			else Object.defineProperty(arr[i],"text",textProxy);
			//e.model.updateTargetBindings(o, "text");
		}
		
			/*
			world.loadSites().add( function(testData, zoneInfo) {
				var W = zoneInfo.width;
				var H = zoneInfo.height;

			
				console.log(testData);
				console.log(zoneInfo);
		
				
				
				var i;
				var gStrAtr = [];
				var weightedVoronoi = d3.weightedVoronoi().weight(function(d){ return d.value; }).clip( [[0,0], [0,H], [W, H], [W,0]]);
				var data = testData.children;
				var ADJUST_FACTOR = 148;
				for (i=0; i< data.length; i++) {
					data[i].value *= ADJUST_FACTOR;  // adjustment 
				}
				var cells = weightedVoronoi(data);    
				for (i=0; i< cells.length; i++) {
					var p = cells[i];
					
					gStrAtr.push( "M"+p[0][0] +" " + p[0][1]);
					for (b = 0; b < p.length; b++) {
						gStrAtr.push( "L"+p[b][0] + " "+p[b][1]  + (b==p.length -1? "z" : "") );
					}
				}
				
					
					myDiagram.add(
				  GO(go.Node, { position: new go.Point(zoneInfo.x-zoneInfo.width*.5,zoneInfo.y-zoneInfo.height*.5), selectable:false, pickable:false, movable:false },
					GO(go.Shape,
					  { geometryString: "F "+gStrAtr.join(" "), 
						fill: "transparent" })));
				
				
			});
			
			*/
			
				
			
		}

	// Vuemodel for minimal selected LocationPacket containing LocationDefinition only
	var vueModelData;
	function setupNewVueModelData() {  // Default vueModel template
		return (vueModelData= {  
			gotLocation:false, 
			isProto:false,
			multiSelectedLocations:false,
			selectedArc: null,
			viewOptions: {
				viewMode: (initQueryParams.play != null && initQueryParams.play!="0" ? VIEW_MODE_PLAY : VIEW_MODE_EDIT),
				visLabels:false,
				fullSizes:false,
				enforceAllLabels:false,
				showArcs:showArcsInit
			},
			goSelectionCount: true,
			ignoreAutoSync:false,
			selectedArcOptions: {
				autoSyncMutual:false,
				alwaysResetAutoSyncOnUnselect:false
			},
			selected: { x:0, y:0, z:0, key:"", def: $.extend(true, {}, gui._guiGlueParams) }, 
			locationDefIds:world.getLocationDefinitionIds(world.getDefaultLocationDefIdHash())	
		});
	}
	setupNewVueModelData();
	

	var guiArcMethods = {
		selectMutualArc: function() {
			// warning: gui vis assumptions assumed
			var goArcData = myDiagram.model.findLinkDataForKey(vueModelData.selectedArc.mutualGoArc);
			myDiagram.select( myDiagram.findLinkForData(goArcData) );
		}
		,selectConnectingArc: function() {
			// warning: gui vis assumptions assumed
			var multiSelectedLocations=  vueModel.multiSelectedLocations;
			var from = myDiagram.model.findNodeDataForKey( multiSelectedLocations[0]); 
			from = from._node;
			var to = myDiagram.model.findNodeDataForKey( multiSelectedLocations[1]);
			to = to._node;
			
			var arc = from.getArc(to);
			if (arc !=null) {
				var goJsArcData = world.getHashEditable(arc);
				if (goJsArcData == null) {
					alert("selectConnectingArc:: goJsArcData hash search  null exception found!");
					return;
				}
			
				myDiagram.select( myDiagram.findPartForData(goJsArcData) );
			}
		}
	}
	
	var guiOverwriter = setupGUIGeneric( guiGlueRender(specsLocationDefinition, null, {}) );
	guiOverwriter.domElement.setAttribute("id", "locationDefGUIOverwriter");
	
	
	//var guiStater = setupGUIGeneric( guiGlueRender( DatUtil.setup( new LocationState() ), null, {}) );
	//guiStater.domElement.setAttribute("id", "locationStateGUI");
	
	
	var guiZoner = new dat.GUI();
	guiZoner  = setupGUIGeneric( guiGlueRender( DatUtil.setup(new Zone()),  null, {}, guiZoner) );
	guiZoner.domElement.setAttribute("id", "guiZoner");
	guiZoner.domElement.setAttribute("v-show", "selected.reflectType === 'Zone'");
	guiZoner.add({"Load Image URL": function() { vueModel.loadZoneImageURL(); } }, "Load Image URL");
	guiZoner.add({pictureOpacity:DEFAULT_PICTURE_OPACITY}, "pictureOpacity", 0, 1, 0.01).onChange( function(val) {
		myDiagram.model.updateTargetBindings(_selectedGoNodeData, "pictureOpacity");
		pictureOpacityNumberObj.pictureOpacity = val;
	});
	guiZoner.add({influenceScale:1}, "influenceScale").onChange( function(val) {
	
		if (_selectedGoNodeData._node) {  // for this purpose, we store the value in zone data's scale.
			_selectedGoNodeData._node.val.scale = val;
			guiZoner.getControllerByName("scale").object.scale = val;
	
			guiZoner.getControllerByName("scale").updateDisplay();
			INFLUENCE_SIZE_SCALE = val;
		}
		else {
			alert("Zone exception no node found for selected!")
		}
	});

	var pictureOpacityController = guiZoner.getControllerByName("pictureOpacity");
	var pictureOpacityNumberObj = pictureOpacityController.object;
		
	var guiPacketer = new dat.GUI();
	
	guiPacketer.addFolder( "position");
	guiPacketer.add(guiArcMethods, "selectConnectingArc");
	 getGuiControllerLi(guiPacketer, "selectConnectingArc").attr("v-show", "gotLocation && goSelectionCount==2 && multiSelectedLocations && multiSelectedLocations.length==2 && hasConnectingArcBetween()").find(".property-name").html("Select Connecting Arc");
	guiPacketer = setupGUIGeneric( guiGlueRender( DatUtil.setup(new LocationPacket()), null, {}, guiPacketer) );
	guiPacketer.domElement.setAttribute("id", "guiPacketer");
	$( guiPacketer.getFolderByName("state").domElement.firstChild ).children("li.title").html("Location state{{selected.state ? ':' : '?' }}");

	//&nbsp;&nbsp;&nbsp;id:<span class='keyer'> {{ selected.key }}</span>
	$( guiPacketer.getFolderByName("position").domElement.firstChild ).children("li.title").html("position: {{ (selected && selected.x!== undefined ? '('+selected.x.toFixed(2) + ', ' + selected.y.toFixed(2) + ', ' + selected.z.toFixed(2)+')' : '') }}&nbsp;&nbsp;<span class='keyer'> {{ hashposId }}</span>").append( $(guiPacketer.domElement).find("li.position") );
	

	$("span.keyer").click( function(e) {
		e.preventDefault();
		e.stopPropagation();
	});
	
	var guiArc = new dat.GUI();
	guiArc.domElement.setAttribute("id", "arcGUI");
	$(guiArc.domElement).attr("v-show", "selectedArc!=null" );
	
	guiArc.add(guiArcMethods, "selectMutualArc");
		
	guiArc.add(vueModelData.selectedArcOptions, "autoSyncMutual");
	getGuiControllerLi(guiArc, "autoSyncMutual").find("input").attr("v-model", "selectedArcOptions.autoSyncMutual");  //.attr("v-show", "selectedArc.mutualGoArc != null")
	getGuiControllerLi(guiArc, "autoSyncMutual").find(".property-name").html("Auto-sync~mutual");
	 setupGUIGeneric( guiGlueRender( DatUtil.setup( new ArcNodeVM() ) , null, {}, guiArc  ) );
	$(guiArc.getFolderByName("val").domElement.firstChild).children("li.title").html("<span>Arc state{{selectedArc && selectedArc.val ? ':' : '?' }}</span> <span v-show='selectedArc'>d=<span style='color:yellow'>{{ selectedArcDistances }}</span></span>");

	 
	 getGuiControllerLi(guiArc, "selectMutualArc").attr("v-show", "selectedArc.mutualGoArc != null").find(".property-name").html("Select Mutual Arc");
	
	 var guiArcFolder;
	 
	 guiArcFolder = guiArc;
	 $(guiArcFolder.domElement).children("ul").children("li.instance").append('<span class="overwritetrigger">~</span>');
	 guiArcFolder = guiArc.getFolderByName("val");
	 $(guiArcFolder.domElement).children("ul").children("li").children().children(".property-name").append('<span class="overwritetrigger">~</span>');
	$(guiArcFolder.domElement).children("ul").children("li.bitmask").append('<span class="overwritetrigger">~</span>');
	guiArcFolder = guiArcFolder.getFolderByName("pathArcInfo");
	$(guiArcFolder.domElement).children("ul").children("li").children().children(".property-name").append('<span class="overwritetrigger">~</span>');
//	$(guiArc.getFolderByName("val").domElement).children("ul").children("li.bitmask").append('<span class="overwritetrigger">~</span>');
	
	//alert( $(guiArc.getControllerByName("selectMutualArc").domElement).children().html() );
	//$(guiArc.getControllerByName("selectMutualArc").domElement).find(".property-name").html("Select Mutual Arc");
	
	
	var guiMainMenu = new dat.GUI();
	guiMainMenu.domElement.setAttribute("id", "guiMainMenu");
	var guiMainMenuData  = {
		copyToClipboard: "",
		loadMap: function() {
			loadWorld(this.copyToClipboard);
			this.copyToClipboard = "";
			guiMainMenu.getControllerByName("copyToClipboard").updateDisplay();
			alert("New map loaded successfully.");
			
		},
		saveMap: function() {
			this.copyToClipboard = world.saveWorld();
			guiMainMenu.getControllerByName("copyToClipboard").updateDisplay();
		},
		"Open Dashboard": function() {
			vueDashboard.isShowingDashboard = true;
		},
	}
	guiMainMenu.addTextArea(guiMainMenuData, "copyToClipboard");
	guiMainMenu.add(guiMainMenuData, "saveMap");
	guiMainMenu.add(guiMainMenuData, "loadMap");
	guiMainMenu.add(guiMainMenuData, "Open Dashboard");
	guiMainMenu.closed = true;
	
	function executeLocDefMethodHandler() {
		if (_inspectedNodeVal == null || _inspectedNodeVal.def==null) return;
		
		
		DatUtil.callInstanceMethodWithPacket(_inspectedNodeVal.def, this);
		var jsonStr = TJSON.encode(_inspectedNodeVal.def);  
	
		vueModel.selected.def = TJSON.parse(jsonStr);
		
		closeGuiModal();
	}
	
	dat.GUI.prototype.removeFolder = function(name) {  // consier todo: add this to main branch
	  var folder = this.__folders[name];
	  if (!folder) {
		return;
	  }
	 // folder.close();
	  this.__ul.removeChild(folder.domElement.parentNode);
	  delete this.__folders[name];
	  this.onResize();
	}

	var guiModal;
	function createGUIMethodModalHandler() {
		if (_inspectedNodeVal == null || _inspectedNodeVal.def==null) return;
	
		if (guiModal != null) {
			$(guiModal.domElement).remove();
			guiModal = null;
		}
		
		guiModal = new dat.GUI();  
		$(gui.domElement).after(guiModal.domElement);
		var existingFolder = guiModal.getFolderByName(this.name);
		if (existingFolder != null) {
			guiModal.removeFolder(this.name);
		}
		
		var folder = guiModal.addFolder(this.name);
		
		DatUtil.setupGUIForFunctionCall(folder, this.name, executeLocDefMethodHandler, this.func, new LocationDefinition() );
		folder.open();
		
		///*
		guiModal.onClosedChange( function(val) {
			
			if (val) {
				$(guiModal.domElement).remove();
				guiModal = null;
			}
		});
		//*/

	}
	function closeGuiModal() {
		if (guiModal != null) {
			$(guiModal.domElement).remove();
			guiModal = null;
		}
	}

	
	//var guiLocationDefMethods = new dat.GUI();
	/*
	DatUtil.createFunctionLibraryForGUI(gui.addFolder("functions()"), gui._guiGlue._functions, new LocationDefinition(), null, {
		handler: executeLocDefMethodHandler
	});
	*/
	///*
	DatUtil.createFunctionButtonsForGUI(gui.addFolder("functions()"), gui._guiGlue._functions, new LocationDefinition(), null, {
		handler: createGUIMethodModalHandler
	});
//*/
	
	// some mods for filtering
	var liNumberRows = $(gui.domElement).add($(guiOverwriter.domElement).add($(guiArc.domElement))).find("li.number");	
	liNumberRows.find("input").each( function(index, item) {
		item = $(item);
		item.attr( "number", "");
	});

	liNumberRows.find("select").each( function(index, item) {
		item = $(item);
		item.attr( "number", "");
	});
	
	
	Vue.directive('arc-sync',  {   // syncs mutual arc
		params:['arcSync'],
		deep:true,
		update:function(newValue, oldValue) {

			if (_inspectedArc == null || vueModelData.ignoreAutoSync || !vueModelData.selectedArcOptions.autoSyncMutual || !vueModelData.selectedArc || vueModelData.selectedArc.mutualGoArc == null) return;
			if (newValue === undefined) return;
			if (newValue === oldValue) {
				
				return;
			}
			var flipValue;
			
			if (  newValue != null && typeof(newValue) === "object") {
	
				if (oldValue == null) {
					//console.log("Creating:"+this.expression);
					newValue = TJSON.parse(TJSON.encode(newValue));
					flipValue = newValue;
				}
				else {
					return;
				}
			}
			else flipValue= ArcPacket[this.params.arcSync](newValue);
			//*/
			
			
			//alert(flipValue);
			var goArcData = myDiagram.model.findLinkDataForKey(vueModelData.selectedArc.mutualGoArc);
	
			var splitExp  = this.expression.split(".");
			splitExp.shift();  // remove off selectedArc prefix in expression

			inspectPropertyChainLookup.setupProperty( goArcData._arc,  splitExp.join(".") );	
			//	alert("before SYNC:"+flipValue + "::"+splitExp);
			var result = inspectPropertyChainLookup.setPropertyChainValue(flipValue);
			//	console.log(this.expression + "="+result, result);
			//alert("after SYNC");

			myDiagram.model.updateTargetBindings(goArcData);
			
		}
	});

	Vue.directive('dat-instance', {  // Binds to Dat.gui folders's domElement.firstChild => UL element
		bind: function(val) {
			var self = this;
			this._datGui = $(this.el).data("dat-gui");
			 this._datGui.onClosedChange( function(isClosed) {
				self.vm.$set( self.expression, (isClosed ? null : self._datGui._guiGlueParams ) );
			 });
		},
		update: function(val, lastVal) {
	
			this._datGui.closed = val == null;
		
			
		},
		unbind: function() {
			this._datGui.onClosedChanged(null);
		}
	});

	
	Vue.directive('dat-numeric-input',{  // Binds to Dat.gui controller's domElement.firstChild => Div input element
		bind: function() {
			var self = this;
			this._datController = $(this.el).data("dat-controller");
			 this._datController.onChange( function(val) {
				self.vm.$set( self.expression, val );
			 });
		},
		update: function(val) {
			if ( isNaN(val)) return;
			this._datController.setValue(val);//(val);
			this._datController.updateDisplay();
		},
		unbind: function() {
			 this._datController.onChange(null);
		}
	});


	Vue.directive('dat-slider',{  // Binds to Dat.gui controller's domElement.firstChild => Div wrapper element
		bind: function() {
			var self = this;
			this._datController = $(this.el).data("dat-controller");
				this._datController.onChange( function(val) {
				//var precision = self._datController.__precision;
				//val =val.toFixed(precision);
				//console.log("Setting val:"+val);
				self.vm.$set( self.expression, val );
			 });
		},
		update: function(val, oldVal) {
			val = parseFloat(val);
			//console.log("Getting val and updating:"+val);  
			if ( isNaN(val)) return;

			
			if (val === oldVal) return;
			
			this._datController.setValue(val);
		},
		unbind: function() {
			 this._datController.onChange(null);
		}
	});
	
	Vue.directive('dat-bitmask',{  // Binds to Dat.gui folder's domElement.firstChild => UL element
		bind: function() {
			var self = this;
			//var liBoolList = $(this.el).children("li.boolean");
			var el = $(this.el);
			var folder = el.data("dat-gui");
			var controllers = folder.__controllers;
			var p;
			var c;
			var len = controllers.length;
			var initialValue = 0;
			
			var titleCheck = el.children("li.title");
			titleCheck.html( titleCheck.html() + ": ");
			var labelListCheck = titleCheck.children("span.labellist");
			if (labelListCheck.length ==0 ) {
				labelListCheck = $('<span class="labellist"></span>');
				titleCheck.append(labelListCheck);
			}
			
			
			this.labelList = labelListCheck;
			this.controllers = controllers;
			this._folder = folder;
			
			
			for (i=0; i< len; i++) {
				c = controllers[i];
				initialValue |= c.getValue() ? c._guiGlue._bit : 0;
				c.onChange(function(val) {
					if (val) {
						self.bitmaskValue |= this._guiGlue._bit;
					}
					else {
						self.bitmaskValue &= ~(this._guiGlue._bit);
					}
					
					if (self.vm.$get(self.expression) !== undefined) self.vm.$set( self.expression, self.bitmaskValue );
					
					//console.log( self.expression + "=" + self.bitmaskValue);
				});
			}
			
			this.bitmaskValue = initialValue;
		//	console.log( self.expression + "=" + this.bitmaskValue);
		
		},
		update: function(val, lastVal) {	
			//alert(val); 
			if (val === undefined) {
				val = this._folder._guiGlue._value;
				
			}
			else if (!val) {
				val = 0;
			}
			this.bitmaskValue = val;
			
			var i;
			var c;
			var controllers= this.controllers;
			var len = controllers.length;
			var arr = [];
			var v;
			for (i=0; i< len; i++) {
				c = controllers[i];
				c.setValue( v=(val & c._guiGlue._bit)!=0 );
				if (v) arr.push('<span class="prop">'+c.property+'</span>');
			}
			
			this.labelList.html( ""+arr.join(", ") );
		},
		unbind: function() {
			var i;
			var controllers= this.controllers;
			var len = controllers.length;
			for (i=0; i< len; i++) {
				controllers[i].onChange( null );
			}
		}
	});


	
	var p;
	var g;
	var c;
	var f;
	
	var guiSubInstances = [];
	
	function resetAllGUISubInstances() {   
		var i  = guiSubInstances.length;
		while(--i > -1) {
			guiGlueApplyDefaults(guiSubInstances[i]._guiGlue, guiSubInstances[i]._guiGlueParams);
		}
	}
	
	//$(guiOverwriter.domElement).data("dat-gui", guiOverwriter).attr("v-if", "selected.defOverwrites != undefined");
	
//	$(guiOverwriter.domElement)

	var ARC_SYNCPROP_METHODS = {};
	
	function setupGUIForVue(gui, expressionPrefix, ifSuffix, overwriteMethod, dataModelDirective) {
		var guiFolders = gui.getAllGUIs();
		var gotIf = ifSuffix != null;
		if (overwriteMethod == null) overwriteMethod = "addLocationDefOverwrite";
		if ( !dataModelDirective) dataModelDirective = "node";
		dataModelDirective = "v-"+dataModelDirective;

	
		for (p in guiFolders) {
			g= guiFolders[p];
			if (!g._guiGlue) continue;
			
			if (g._guiGlue._dotPath != undefined) {
				if (g._guiGlue._dotPath != "") {
					$(g.domElement.firstChild).data("dat-gui", g).attr("v-dat-instance", expressionPrefix+ g._guiGlue._dotPath).attr(dataModelDirective, expressionPrefix+ g._guiGlue._dotPath);
				
					if (g._guiGlue._sync) {
						g.domElement.firstChild.setAttribute("arc-sync", g._guiGlue._sync  );
						g.domElement.firstChild.setAttribute("v-arc-sync", (expressionPrefix+ g._guiGlue._dotPath) );
						
					}
					var overwriteTrigger = jQuery(jQuery(g.domElement).parents("li")[0]).find(".overwritetrigger").data("dat-gui", g);
					overwriteTrigger.attr("v-on:click", overwriteMethod+"('"+g._guiGlue._dotPath+"', $event)");
					//selected && selected.defOverwrites && 
					if ( expressionPrefix === "selected.def.") overwriteTrigger.attr("v-show", "$get('selected.defOverwrites."+g._guiGlue._dotPath+ "') == null");
					else if (dataModelDirective === "v-arc" && g._guiGlue._sync) {
						overwriteTrigger.attr("v-show", "isOffSyncedWithMutual('"+g._guiGlue._dotPath+"', selectedArc."+g._guiGlue._dotPath+")");
						ARC_SYNCPROP_METHODS[g._guiGlue._dotPath] = ArcPacket[g._guiGlue._sync];
					}
					if (gotIf) {
						$( $(g.domElement).parents("li")[0]).attr("v-show", expressionPrefix +g._guiGlue._dotPath +  ifSuffix);
					}
					guiSubInstances.push(g);
					
				}
				

				
				for (c in g.__controllers) {
					var cn = g.__controllers[c];
					if (!cn._guiGlue) continue;
					
					var dotPath =( g._guiGlue._dotPath!= "" ?  g._guiGlue._dotPath + "." : "")+ cn.property;
					
					
					var nodeName = cn.domElement.firstChild.nodeName.toLowerCase();
					if (nodeName != "div") {  // assumed input
						jQuery(cn.domElement.firstChild).data("dat-controller", cn);
						//if (jQuery(cn.domElement.firstChild).parents("li.number").length) {
						//	cn.domElement.firstChild.setAttribute("lazy", "");
						//}
						if (jQuery(cn.domElement.firstChild).parents("li.number").length && nodeName === "input") {
							cn.domElement.firstChild.setAttribute("v-dat-numeric-input", expressionPrefix+dotPath);
						}
						else {
							cn.domElement.firstChild.setAttribute("v-model", expressionPrefix+dotPath);
						}
					}
					else {
						if (jQuery(cn.domElement.firstChild).parents("li.has-slider").length) {
							jQuery(cn.domElement.firstChild).data("dat-controller", cn).attr("v-dat-slider", expressionPrefix+dotPath);
						}
						else alert("TODO: NEED TO resolve controller directive for:"+cn.property);
						
					}
					
					var overwriteTrigger = jQuery(jQuery(cn.domElement).parents("li")[0]).find(".overwritetrigger").data("dat-gui", cn);
					if (overwriteTrigger.length) {
						if (!cn._guiGlue._readonly) {
							overwriteTrigger.attr("v-on:click", overwriteMethod+"('"+dotPath+"', $event)");
							//selected && selected.defOverwrites && 
							if ( expressionPrefix === "selected.def.") overwriteTrigger.attr("v-show", "$get('selected.defOverwrites."+dotPath+ "') == null");
							else if (dataModelDirective === "v-arc" && cn._guiGlue._sync) {
								overwriteTrigger.attr("v-show", "isOffSyncedWithMutual('"+dotPath+"', selectedArc."+dotPath+")");
								ARC_SYNCPROP_METHODS[dotPath] = ArcPacket[cn._guiGlue._sync];
							
								
							}
						}
						else {
							overwriteTrigger.css("display", 'none').css("visibility", "hidden");
						}
					}
					
					cn.domElement.firstChild.setAttribute(dataModelDirective, expressionPrefix+dotPath);
					if (cn._guiGlue._sync) {
						cn.domElement.firstChild.setAttribute("arc-sync", cn._guiGlue._sync );
						cn.domElement.firstChild.setAttribute("v-arc-sync", (expressionPrefix+dotPath) );
					}
					if (gotIf) $( $(cn.domElement).parents("li")[0]).attr("v-show", expressionPrefix + dotPath  +  ifSuffix);
				}
				
				for (f in g.__folders) {
					var folder = g.__folders[f];
					if (!folder._guiGlue) continue;
					if (folder._guiGlue._dotPath == undefined) {
						var parentLI = jQuery( jQuery(folder.domElement).parents("li")[0] );
						if (parentLI.hasClass("bitmask")) {
							var dotPath =( g._guiGlue._dotPath!= "" ?  g._guiGlue._dotPath + "." : "")+ f;
							$(folder.domElement.firstChild).data("dat-gui", folder).attr("v-dat-bitmask", expressionPrefix+dotPath ).attr(dataModelDirective, expressionPrefix+dotPath);
							if (folder._guiGlue._sync) {
								folder.domElement.firstChild.setAttribute("arc-sync", folder._guiGlue._sync );
								folder.domElement.firstChild.setAttribute("v-arc-sync", (expressionPrefix+dotPath) );
							}
							var folderLi =  $( $(folder.domElement).parents("li")[0]);
							if (gotIf) folderLi.attr("v-show", expressionPrefix + dotPath  +  ifSuffix);
							var overwriteTrigger = folderLi.children(".overwritetrigger").data("dat-gui", f);
							
							overwriteTrigger.attr("v-on:click", overwriteMethod+"('"+dotPath+"', $event)");
							//selected && selected.defOverwrites && 
							if ( expressionPrefix === "selected.def.") overwriteTrigger.attr("v-show", "$get('selected.defOverwrites."+dotPath+ "') == null");
							else if (dataModelDirective === "v-arc" && folder._guiGlue._sync) {
								overwriteTrigger.attr("v-show", "isOffSyncedWithMutual('"+dotPath+"', selectedArc."+dotPath+")");
								ARC_SYNCPROP_METHODS[dotPath] = ArcPacket[folder._guiGlue._sync];
							}
							
						}
						else {
							//alert("TODO: need to resolve folder directive for:"+f );<br/>
						}
					}
				}
			}
		}
	}
	
	$(gui.domElement).children("ul").children("li").children().children(".property-name").append('<span class="overwritetrigger">+</span>');
	$(gui.domElement).children("ul").children("li.instance, li.bitmask").append('<span class="overwritetrigger">+</span>');
	
	$(guiOverwriter.domElement).children("ul").children("li").children().children(".property-name").append('<span class="overwritetrigger">-</span>');
	$(guiOverwriter.domElement).children("ul").children("li.instance, li.bitmask").append('<span class="overwritetrigger">-</span>');
	
	setupGUIForVue(gui,  "selected.def.");
	setupGUIForVue(guiOverwriter,  "selected.defOverwrites.", "!==undefined", "removeLocationDefOverwrite");
	setupGUIForVue(guiPacketer,  "selected.");
	setupGUIForVue(guiZoner,  "selected.");
	setupGUIForVue(guiArc, "selectedArc.", null,"syncWithMutual", "arc");
	guiPacketer.domElement.setAttribute("v-show", "gotLocation");
	//setupGUIForVue(guiStater,  "selected.state.");
	gui.domElement.setAttribute("v-show", "selected.def");
	gui.domElement.setAttribute("v-bind:class", "{ 'disabled': isProto && gotLocation }");
	guiOverwriter.domElement.setAttribute("v-show", "gotLocation &&  selected.defOverwrites");
	guiOverwriter.domElement.setAttribute("v-node", "selected.defOverwrites");
	
	//guiStater.domElement.setAttribute("v-show", "selected.state");
	//guiStater.domElement.setAttribute("v-node", "selected.state");
	
	$(guiOverwriter.domElement).add($(guiPacketer.domElement)).css("float", "none").css("margin-bottom", "28px").wrapAll($('<div style="float:right"></div>'));
	

	// App specific setup
	
	var inspectPropertyChainLookup = TextificianUtil.getPropertyChainObj({}, "");
	var _inspectedNodeVal=null;
	var _inspectedArc = null;
	var _inspectedGoNodeData = null;
	var _selectedGoNodeData = null;
	var _selectedGoArcData = null;
	var leafBindingHash = { size:"desiredSize", description:"text", label:"text", type:"category" };
	
	
	Vue.directive('arc', function(newValue, oldValue) {
	
		if (_inspectedArc == null) return;
		
		if (newValue === oldValue) return;  // newly added

		var splitExp  = this.expression.split(".");
		splitExp.shift();  // remove off selectedArc prefix in expression

		if (newValue != null && typeof(newValue) === "object") {
			newValue = TJSON.parse(TJSON.encode(newValue));
		}
	
		inspectPropertyChainLookup.setupProperty( _inspectedArc,  splitExp.join(".") );
	
		var result = inspectPropertyChainLookup.setPropertyChainValue(newValue);
		
		//console.log( splitExp.join(".")+" = ", ""+result);
	
		/*  // todo: update arc appearance if required
		var leafProp = splitExp[splitExp.length - 1];
		
		if ( vueModel.gotLocation && leafBindingHash[leafProp] ) {
			updateRelatedNodesOfModel(myDiagram.model, _inspectedNodeVal.def, leafBindingHash[leafProp]);
		}
		*/


		
		myDiagram.model.updateTargetBindings(_selectedGoArcData);
	
	
	});
	
	
	Vue.directive('node', function(newValue, oldValue) {
		if (_inspectedNodeVal == null) return;
		
		if (newValue === oldValue) return;  // newly added
	//	if (newValue === undefined) return;  // if value is strictly undefined, can process be skipped?
		
		
		var splitExp  = this.expression.split(".");
		splitExp.shift();  // remove off selected prefix in expression
		/*
		if (newValue === undefined) {
			splitExp[0] === defO
		}
		*/
		if (newValue != null && typeof(newValue) === "object") {
			newValue = TJSON.parse(TJSON.encode(newValue));
		}
		
		inspectPropertyChainLookup.setupProperty( _inspectedNodeVal,  splitExp.join(".") );
		 
		var result = newValue !== undefined ? inspectPropertyChainLookup.setPropertyChainValue(newValue) : inspectPropertyChainLookup.deletePropertyChainValue(newValue);  // result purely for checking, may not reflect newVal
		
		var leafProp = splitExp[splitExp.length - 1];
		
		if ( leafBindingHash[leafProp] ) {
			if (vueModel.gotLocation) updateRelatedNodesOfModel(myDiagram.model, _inspectedNodeVal.def, leafBindingHash[leafProp])
			else {
				myDiagram.model.updateTargetBindings(_inspectedGoNodeData, leafBindingHash[leafProp]);
			}
		}
	});
	
	

	function encodeNumber(num) {
		num = Math.floor(num);
		var isNegative = num < 0;
		num = isNegative ? -num : num;
		num |= isNegative ? 1073741824 : 0;
		return num;
	}

	function decodeNumber(num) {
		return (num & 1073741824) != 0 ? (num&(~1073741824)) * -1 : num;
	}

	
	var vueModel = new Vue({
		el:".dg.ac",
		data: vueModelData,
		computed: {
			hashposId: function() {
				return this.getPosHashId();
			},
			selectedArcDistances: function() {
				
				return this.selectedArc ? Math.round(this.selectedArc.dist) + (this.selectedArc.dist != this.selectedArc.dist3D ? " ("+Math.round(this.selectedArc.dist3D)+")" : "")  : 0;
			}
		},
		methods: {
			getPosHashId: function() {
				return this.selected ? hashPosition.encode(null, [encodeNumber(this.selected.x), encodeNumber(this.selected.y), encodeNumber(this.selected.z)]) : "";
			},
			addLocationDefOverwrite: function(prop, e) {
				var result = this.$get("selected.def."+prop);
				if (result != null && typeof result === "object") {
					result = $.extend(true, {}, result);
					
				}
				if (result == null) {
					var datGui =$(e.target).data("dat-gui");
					if (datGui._guiGlueParams) {
					
						result = $.extend(true, {}, datGui._guiGlueParams);
					}
					else {
						result = datGui._guiGlue.value;
					}
					//alert();
					
					//result = 
				
				}
				//alert("adding: selected.defOverwrites."+prop+"="+result);
				this.$set("selected.defOverwrites."+prop, result );
			}
			,removeLocationDefOverwrite: function(prop) {
				var overwrites = this.$get("selected.defOverwrites");
				//alert("adding: selected.defOverwrites."+prop+"="+result);
				var propArr = prop.split(".");
				var leafProp = propArr.pop();
				
				if (propArr.length) {
					alert("THis should not happen under this our case!");
					
					Vue.delete( this.$get("selected.defOverwrites."+propArr.join(".")), leafProp);
				}
				else {
					Vue.delete( overwrites, leafProp );
				}
				
				var p;
				for (p in overwrites) {
					if (p!= null) return;
				}
				Vue.delete(this.selected, "defOverwrites");
				
				
				//
			}
			,hasConnectingArcBetween: function() {
				// warning: gui vis assumptions assumed
				var multiSelectedLocations=  vueModel.multiSelectedLocations;
				var from = myDiagram.model.findNodeDataForKey( multiSelectedLocations[0]); 
				from = from._node;
				var to = myDiagram.model.findNodeDataForKey( multiSelectedLocations[1]);
				to = to._node;
				
				var arc = from.getArc(to);
				return arc != null;
			}
			,isOffSyncedWithMutual: function(prop, valueToSync) {
				
			
				var predicate =  this.selectedArc && this.selectedArc.mutualGoArc;
				
				if (!predicate) return false;
				
				var goArcData = myDiagram.model.findLinkDataForKey(vueModelData.selectedArc.mutualGoArc);
				var mutualArc = goArcData._arc;
				
				inspectPropertyChainLookup.setupProperty( mutualArc,  prop);
				
				var curVal = inspectPropertyChainLookup.getPropertyChainValue();
				if (curVal == null && valueToSync == null) {
					return false;
				}
				
				if (valueToSync != null && typeof(valueToSync) === "object") {
					if (curVal == null) {
						return true;
					}
					else {
						return false;
					}
				}
				var lastValueToSync = valueToSync;
				valueToSync = ARC_SYNCPROP_METHODS[prop](valueToSync, curVal);
			//	console.log(prop, " COMPARE:", lastValueToSync, valueToSync, curVal);
				return curVal != valueToSync;
			}
			,syncWithMutual: function(prop, e) {
				var valueToSync = this.$get("selectedArc."+prop);
				var refValue = valueToSync;
				var goArcData = myDiagram.model.findLinkDataForKey(vueModelData.selectedArc.mutualGoArc);
				var mutualArc = goArcData._arc;
				
				inspectPropertyChainLookup.setupProperty( mutualArc,  prop);
				var curVal = inspectPropertyChainLookup.getPropertyChainValue();
				/*
				if (valueToSync != null && typeof valueToSync === "object") {
					if (curVal == null) {
					
					}
				}
				*/
			
				
				//(okoko,curVal)
				
				valueToSync = ARC_SYNCPROP_METHODS[prop](valueToSync, curVal);
				if (curVal !=valueToSync) {
					inspectPropertyChainLookup.setPropertyChainValue(valueToSync);
				}
				inspectGoArc( _selectedGoArcData );
				
			}
			,loadZoneImageURL: function() {
			
				if (!vueModel.selected || !_selectedGoNodeData) {
					alert("nothing selected");
					return;
				}
				//_selectedGoNodeData._selectedGoNodeData
				myDiagram.model.setDataProperty(_selectedGoNodeData, "pictureSrc",vueModel.selected.imageURL );
				
			}
		}
	});
	
	vueModel.$watch("selected.def", function(val) {
		if (!val) closeGuiModal();
	});
	
	/*
	function inspectGoZoneNode(goZoneNode) { 
		var zone = goZoneNode._node.val;
	
	}
	*/
	
	function inspectGoArc(goArc) { 
		var arc = goArc._arc;
		_inspectedArc = arc;
		
		vueModelData.ignoreAutoSync = true;  // timeout hack, bleh, temp disable directive for v-arc-sync
		//vueModel.selectedArcOptions.autoSyncMutual = false;

		var newVueModelData;
		if (arc.val != null) {
			var jsonStr = TJSON.encode(arc.val);
			newVueModelData = TJSON.parse(jsonStr);  // consider todo: should this be a plain JSON parse?
		}
		else {
			newVueModelData  = null;
		}
		
		var fromGoNodeData = myDiagram.model.findNodeDataForKey(goArc.from); 
		//var fromGoNodeData = myDiagram.model.findNodeDataForKey(goArc.from); 
		var fromGoNodule = fromGoNodeData._node;
		if (fromGoNodule ==null) {
			alert("inspectGoArc:: _Node  null exception found!");
			return;
		}
		var mutualArc = arc.node.getArc(fromGoNodule);
		if (mutualArc != null) {
			mutualArc = world.getHashEditable(mutualArc);
			if (mutualArc == null) {
				alert("inspectGoArc:: mutualArc hash search  null exception found!");
				return;
			}
			mutualArc = mutualArc.key;
			
		}

		
		var ax = fromGoNodule.val.x;
		var ay = fromGoNodule.val.y;
		var az = fromGoNodule.val.z;

		var bx = arc.node.val.x;
		var by = arc.node.val.y;
		var bz = arc.node.val.z;
	
		var dx;
		var dy;
		var dz;
		
		dx = ax - bx;
		dy = ay - by;
		dz = az - bz;



		//console.log("New vue model:"+ newVueModelData);
		vueModel.selectedArc = { val:newVueModelData, mutualGoArc:mutualArc, dist:Math.sqrt(dx*dx + dy*dy), dist3D:Math.sqrt(dx*dx + dy*dy  + dz*dz) }; //, cost:arc.cost
		
		 // timeout hack, bleh, re-enable autosync directive after temp disable directive for v-arc-sync
		setTimeout( function() {
			vueModelData.ignoreAutoSync = false;
		}, 0);
	}
	
	function isGameplayArc(arc, goArc) {
		var tryThis = arc.node.val.def.gameplayCategory; 
		if (tryThis) return true;
		
		var mutualNode = myDiagram.model.findNodeDataForKey(goArc.from);
		//console.log("AFAWAW");
		//console.log( );
		if (mutualNode) mutualNode =mutualNode._node;
		/*
		if (mutualNode) {
		
			arc = mutualNode.getArc(arc.node);
		//	console.log("DONE:?"+arc);
		}
		*/
		//if (mutualNode) {
		//	console.log(mutualNode.val);
		//}
		return mutualNode ? mutualNode.val.def.gameplayCategory != null: false;
	}

	var lastInspectedLocDef = null;
	function inspectGoNode(goNode) {
		
		//allLocationGUIDom.removeAttr("hidden");
		vueModel.isProto = goNode.isProto;
	
		vueModel.gotLocation = goNode._node.val.reflectType === "LocationPacket";
		//guiOverwriter.domElement.removeAttribute("hidden");
		
		var node = goNode._node;
		var lastNodeData = null;
		if (_inspectedGoNodeData && _inspectedGoNodeData !== goNode) {
			lastNodeData = _inspectedGoNodeData;
		}

		_inspectedGoNodeData = goNode;
		
		var nodeVal = node.val;
		_inspectedNodeVal = nodeVal;
		
		if (goNode.pictureOpacity != null) {
			pictureOpacityController.object = goNode;
			pictureOpacityNumberObj.pictureOpacity = goNode.pictureOpacity;
			pictureOpacityController.updateDisplay();
		
			
			
			//console.log("INSPECT:", pictureOpacityController.__gui);
			//	pictureOpacityController.__label.value = 20;
			//console.log(pictureOpacityController.__label.value);
		}
		

		
		// consider todo: check if locDef is changed, if not changed no need to update
		var locDef = nodeVal.def;
		
		
		if (lastInspectedLocDef != locDef) {
			// reset temporary view-cache UI state values when location definition inspection-target changes
			resetAllGUISubInstances(); 
		}
		lastInspectedLocDef = locDef;
		// lazy JSON approach to convert a Model to vueModel
	
		//console.log("Inspecting", locDef);
	
		// setup new location def
		var jsonStr = TJSON.encode(nodeVal);  
	
		var newVueModelData = TJSON.parse(jsonStr);  // consider todo: should this be a plain JSON parse?
		if (locDef && locDef.gameplayCategory) newVueModelData.def.gameplayCategory = locDef.gameplayCategory;
		vueModel.selected = newVueModelData;
		vueModel.selected.key = goNode.key;

		
	
	}

	function setupGUIGeneric(gui) {
		gui.domElement.addEventListener('dragstart', onUIDragStart);
		gui.domElement.addEventListener('dragstop', onUIDragStop);
		allLocationGUIDom = allLocationGUIDom.add($(gui.domElement));
		return gui;
	}
  
	// GOJS
	if (window.goSamples) goSamples();  // init for these samples -- you don't need to call this

	// Note that we do not use $ here as an alias for go.GraphObject.make because we are using $ for jQuery
	var GO = go.GraphObject.make;  // for conciseness in defining templates

	myDiagram =
	  GO(go.Diagram, "myDiagramDiv",  // must name or refer to the DIV HTML element
		 { allowDrop: true,
			
		 	"undoManager.isEnabled": true,
					"toolManager.hoverDelay": 100  // how quickly tooltips are shown
		 
		 }
		 
		);  // must be true to accept drops from the Palette
	myDiagram.mouseDrop = function(e, node) {

		  var it = myDiagram.toolManager.draggingTool.copiedParts;
		  if (it == null) {
			return;
		  }
		  it = it.iterator;
		  while (it.next()) {
				if (it.key instanceof go.Node) { 
					scaleNode(it.key, myDiagram.scale);
				}
				else if (it.key instanceof go.Link) {
					scaleLink(it.key, myDiagram.scale);
				}
		  }
		  

	}
	

	myDiagram.commandHandler.copyToClipboard = function(coll) {
		var toRemove = [];
		
		  coll.each(function(p) {
		
			if (p instanceof go.Link && (p.fromNode === null || !p.fromNode.isSelected || p.toNode === null || !p.toNode.isSelected )) toRemove.push(p);
		  });
		  for (var i = 0; i < toRemove.length; i++) {
			toRemove[i].isSelected = false;
			coll.remove(toRemove[i]);
		  }
		
		go.CommandHandler.prototype.copyToClipboard.call(this, coll);
	}
	

	//myDiagram.linkTemplate.curve = go.Link.Bezier;
	 myDiagram.linkTemplate = GO(go.Link,
	  { routing: go.Link.Normal, toShortLength: 4, selectable: true },
		GO(go.Shape,
			{ isPanelMain: true, stroke: "black", strokeWidth: 0.25 },
			// the Shape.stroke color depends on whether Link.isHighlighted is true
			new go.Binding("stroke", "isHighlighted", function(h) { return h ? "red" : "black"; })
				.ofObject(),

			new go.Binding("strokeDashArray", "", function(h) { return  h._arc ?  ( h._arc.val && (h._arc.val.flags & ArcPacket.FLAG_VISIBILITY_ONLY) ?   [4,4] :  null  )
			: null;	
			}),

			new go.Binding("opacity", "", function(h) { return  h._arc ?  ( h._arc.val && (h._arc.val.flags & (ArcPacket.FLAG_VISIBILITY_ONLY | ArcPacket.FLAG_TELEPORT ) )  ?   NON_WALKABLE_ARC_OPACITY :  (myDiagram.nodeTemplateMap !== NODE_TEMPLATE_DEFAULT && h._arc.isLoaded ?  DEFAULT_LOADED_ARC_OPACITY : DEFAULT_ARC_OPACITY ) )
			: 1;	
			}),
		),

		GO(go.Shape,
			{ toArrow: "standard", stroke: null, strokeWidth: 0, name:"arrow", opacity:.5 },
			// the Shape.fill color depends on whether Link.isHighlighted is true
			new go.Binding("fill", "isHighlighted", function(h) { return h ? "red" : "black"; }).ofObject()
		),
		new go.Binding("visible", "", function(h) {  return (h._arc && isGameplayArc(h._arc, h)) || (vuePanel.viewFlags & VIEWFLAG_SHOW_ARCS)!=0; } ), 
		new go.Binding("copyable", "", function(h) { return vuePanel.viewMode == VIEW_MODE_EDIT || isGameplayArc(h._arc, h);  }),
		new go.Binding("deletable", "", function(h) { return vuePanel.viewMode == VIEW_MODE_EDIT || isGameplayArc(h._arc, h); })
		/*
		GO(go.TextBlock,
			{ 
			maxSize: new go.Size(TEXTLABEL_BASEWIDTH, NaN),
			//wrap: go.TextBlock.WrapFit,
			//textAlign: "center",
			editable: false,
			pickable: false,
		//	portId:"",
			//stroke:"gray",
			font: "bold 7pt Arial, sans-serif",
			name: "TEXT" 
			},
			new go.Binding("text", "", function(h)  { return  h._arc ?  ( h._arc.val && h._arc.val.label != null ?  h._arc.val.label  :  "" ) : "" })		
		)
		*/
		
	);
	myDiagram.linkTemplate.curviness = 1;
	
	//myDiagram.linkTemplate.bind(new go.Binding("curviness", "curviness"));

	
	myDiagram.addLayerBefore(GO(go.Layer, {name:"Regions"}), myDiagram.findLayer(""));
	myDiagram.addLayerBefore(GO(go.Layer, {name:"RegionsPlay"}), myDiagram.findLayer(""));
	myDiagram.addLayerAfter(GO(go.Layer, {name:"Points"}), myDiagram.findLayer(""));
	myDiagram.addLayerAfter(GO(go.Layer, {name:"Characters"}), myDiagram.findLayer(""));
	myDiagram.addLayerAfter(GO(go.Layer, {name:"PointsPlay"}), myDiagram.findLayer(""));
	
	// define several shared Brushes
	var fill1 = "rgb(243,134,48)"
	var fill1play = "rgb(243,244,48)"
	var brush1 = "rgb(203,84,08)";
	var fill1fade = "rgba(243,134,48,0.5)"
	var brush1fade = "rgba(203,84,08,0.35)";
	

	var fill2 = "rgba(167,219,216, .65)"
	var brush2 = "rgb(127,179,176)";

	var fill3 = "rgba(224,228,204, .5)"
	var brush3 = "rgb(184,188,164)";

	var fill4 = "rgba(138,43,226, .65)"
	var brush4 = "rgb(138,43,226)";

	var fillPlay = "rgba(255,255,0, .15)"
	var brushPlay = "rgba(222,128,144,.4)";

	var influenceFill = "rgba(255,134,48, 0.1)"
	var influenceStroke = "rgba(255,134,48, 0.5)"
	
	//  var fill1 = "rgb(243,210,231)"
//   var brush1 = "rgb(65,180,181)";
 //  var fill2 = "rgba(167,219,216, .85)"
 //   var brush2 = "rgb(127,179,176)";


   // var fill4 = "rgb(243,134,48)"
 //   var brush4 = "rgb(203,84,08)";
	



	
	function getNodeTemplate(figure, fill, stroke, maxSize, layout, layerName, addedParams, imgSrc) {
	
		var panelLayout = layout ? layout :  go.Panel.Vertical;

		//panelLayout = go.Panel.Spot;
		var gotLayerName = layerName != null;
		if (!layerName) layerName = "";
		
		var fontSizePx = 9;
		
		var textBlockParams = [go.TextBlock,
			{ 
			maxSize: new go.Size(TEXTLABEL_BASEWIDTH, NaN),
			wrap: go.TextBlock.WrapFit,
			textAlign: "center",
			editable: false,
			pickable: false,
			
			portId:"",
			font: "bold "+fontSizePx+"px Arial, sans-serif",
			name: "TEXT" , portId:""
			},
			new go.Binding("text", "text" ).makeTwoWay()
		
		];
		
		textBlockParams.push(
				   new go.Binding("pickable", "", function(data) {
			
						return myDiagram.scale < 1;
				  })
		  );
			
		///*
		//if (panelLayout === go.Panel.Spot) {
			textBlockParams.push(
				   new go.Binding("fromLinkable", "", function(v) {
					  // alert(v._node.val.def.gameplayCategory);
						return myDiagram.model.modelData.linkable  && (vuePanel.viewMode == VIEW_MODE_EDIT  || (v._node && v._node.val.def.gameplayCategory!=null));
				  }),
					new go.Binding("toLinkable", "", function(v) {
						return myDiagram.model.modelData.linkable;
						// && (vuePanel.viewMode == VIEW_MODE_EDIT  || (v._node && v._node.val.def.gameplayCategory!=null))
				  })
		  );
		//}
		//*/
		var textBlock  =  GO.apply(null, textBlockParams);

		
		var influenceShape =   GO(go.Panel, go.Panel.Position,  GO(go.Shape,  // position offset hack..
			{ strokeWidth: 1,  name: "SHAPE_INFLUENCE"
			
			//,position: new go.Point(0,9)
			, desiredSize: new go.Size(116, 116)
			,minSize:  new go.Size(0,0)
			//,maxSize:  new go.Size(maxSize ? maxSize : NaN, maxSize  ? maxSize : NaN)
			,figure:"circle"
			,fill:influenceFill
			,position: new go.Point(0, panelLayout===go.Panel.Spot ? 0 : fontSizePx )  // position offset hack..
			//,alignment
			,alignment:go.Spot.Center
			//,alignmentFocus:go.Spot.Center
			,stroke:influenceStroke
			//,portId: "none" 
			
			//,cursor: "pointer"  // the Shape is the port, not the whole Node
		  	,pickable:false,
			fromLinkableSelfNode: false, fromLinkableDuplicates: false,
			toLinkableSelfNode: false, toLinkableDuplicates: false
			,fromLinkable:false, toLinkable:false,
			},
			
			// new go.Binding("figure", "figure"),
			
			//new go.Binding("fill", "fill"),
			// new go.Binding("stroke", "stroke"),
			
			new go.Binding("desiredSize", "", function(v) { return (v._node ? getScaledUniformSize(v._node.val.defOverwrites && v._node.val.defOverwrites.size ? v._node.val.defOverwrites.size : v._node.val.def.size, INFLUENCE_SIZE_SCALE) : v.size*INFLUENCE_SIZE_SCALE); } )
			,
			new go.Binding("visible", "", function(v) { var foundNode = myDiagram.findNodeForKey(v.key); return (foundNode ? foundNode.isSelected : false)  ||  (vuePanel.viewFlags & VIEWFLAG_FULL_SIZE)!=0; } )
			
		));


				
		var shape = GO(go.Shape,
			{ strokeWidth: 2, name: "SHAPE"
			, desiredSize: new go.Size(16, 16)
			,minSize:  new go.Size(1,1)
			,maxSize:  new go.Size(maxSize ? maxSize : NaN, maxSize  ? maxSize : NaN)
			,figure:figure
			,fill:fill
			,stroke:stroke
			,portId: "", cursor: "pointer",  // the Shape is the port, not the whole Node
			// allow all kinds of links from and to this port
			fromLinkableSelfNode: false, fromLinkableDuplicates: false,
			toLinkableSelfNode: false, toLinkableDuplicates: false
			
			},
			
			// new go.Binding("figure", "figure"),
			
			//new go.Binding("fill", "fill"),
			// new go.Binding("stroke", "stroke"),
			
			new go.Binding("desiredSize", "", function(v) { return v._node ? getUniformSize(v._node.val.defOverwrites && v._node.val.defOverwrites.size ?v._node.val.defOverwrites.size : v._node.val.def.size) : v.size; } )
			,
			new go.Binding("fromLinkable", "", function(v) {
				return myDiagram.model.modelData.linkable && (vuePanel.viewMode == VIEW_MODE_EDIT  || (v._node && v._node.val.def.gameplayCategory!=null));
			}),
			new go.Binding("toLinkable", "", function(v) {
				return myDiagram.model.modelData.linkable;
				//  && (vuePanel.viewMode == VIEW_MODE_EDIT  || (v._node && v._node.val.def.gameplayCategory!=null))
			})
			
			);
			  
		if (imgSrc != null) {
			var img = GO(go.Picture, imgSrc, { pickable: false }, new go.Binding("opacity", "pictureOpacity"), new go.Binding("source", "pictureSrc"));
		
		}

		

		var goParams = [go.Node, go.Panel.Spot, {locationSpot: go.Spot.Center,  locationObjectName:"SHAPE",  selectionObjectName:"MyContent" },
		new go.Binding("location", "loc").makeTwoWay(), new go.Binding("category", "", function(v) {  return v._node ? v._node.val.def.gameplayCategory!=null  ? v._node.val.def.gameplayCategory :  getCategoryStringFromType(v._node.val.defOverwrites && v._node.val.defOverwrites.type!=null ? v._node.val.defOverwrites.type : v._node.val.def.type) : v.category; }  ) ];
		
		

		if (gotLayerName && layerName != "Background" && layerName != "Characters" && layerName != "RegionsPlay" && layerName != "PointsPlay")  { // imply 'layerName' has influecne radius
	
			goParams.push(influenceShape);
		
		}


		if (imgSrc != null) {
			goParams.push(img );
		}


		var goParams2 = [go.Panel, panelLayout, { name:"MyContent" } ];

	
		if (panelLayout == go.Panel.Spot)  {
			goParams2.push(shape, textBlock);
		}
		else {
			goParams2.push(textBlock, shape);
		}

		goParams.push(GO.apply(null, goParams2));

		

		
		goParams.push({layerName:layerName});
		
		if (addedParams) {
			if (!Array.isArray(addedParams)) goParams.push(addedParams);
			else {
				var i;
				for (i=0;i<addedParams.length;i++) {
					goParams.push(addedParams);
				}
			}
		}
		
		
		return GO.apply(null, goParams);
	}
	

	var NODE_TEMPLATE_DEFAULT = myDiagram.nodeTemplateMap;


	myDiagram.nodeTemplateMap.add("point", getNodeTemplate("Square",fill1,brush1, POINT_SIZE, null, "Points"));
	myDiagram.nodeTemplateMap.add("path", getNodeTemplate("Diamond",fill2,brush2, MAX_SHAPE_SIZE, null, ""));
	myDiagram.nodeTemplateMap.add("region",getNodeTemplate("Circle",fill3,brush3, MAX_SHAPE_SIZE, go.Panel.Spot, "Regions"));
	myDiagram.nodeTemplateMap.add("char", getNodeTemplate("Circle",fill4,brush4, MAX_SHAPE_SIZE, null, "Characters"));
	myDiagram.nodeTemplateMap.add("regionPlay", getNodeTemplate("Circle",fillPlay,brushPlay, MAX_SHAPE_SIZE,  go.Panel.Spot, "RegionsPlay"));
	myDiagram.nodeTemplateMap.add("pointPlay", getNodeTemplate("Square",fill1play,brush1, POINT_SIZE, null, "PointsPlay"));
	myDiagram.nodeTemplateMap.add("zone",getNodeTemplate("Circle",fill1,brush1, POINT_SIZE, go.Panel.Spot, "Background", {copyable:false}, ""));

	var NODE_TEMPLATE_VIS = new go.Map();
	NODE_TEMPLATE_VIS.add("point", getNodeTemplate("Square",fill1fade,brush1fade, POINT_PLAY_SIZE, null, "Points", {movable:false, copyable:false, deletable:false } ));
	NODE_TEMPLATE_VIS.add("path", getNodeTemplate("Square",fill1fade,brush1fade, POINT_PLAY_SIZE, null, "Points", {movable:false, copyable:false, deletable:false}));
	NODE_TEMPLATE_VIS.add("region", getNodeTemplate("Square",fill1fade,brush1fade, POINT_PLAY_SIZE, null, "Points", {movable:false, copyable:false, deletable:false}));
	NODE_TEMPLATE_VIS.add("char", getNodeTemplate("Circle",fill4, brush4, MAX_SHAPE_SIZE, null, "Characters"));
	NODE_TEMPLATE_VIS.add("regionPlay", getNodeTemplate("Circle",fillPlay,brushPlay, MAX_SHAPE_SIZE,  go.Panel.Spot, "RegionsPlay"));
	NODE_TEMPLATE_VIS.add("pointPlay", getNodeTemplate("Square",fill1play,brush1, POINT_PLAY_SIZE, null, "PointsPlay"));
	NODE_TEMPLATE_VIS.add("zone",getNodeTemplate("Circle",fill1fade,brush1fade, POINT_SIZE, go.Panel.Spot, "Background", {movable:false, copyable:false, deletable:false}, ""));
	  

	if (initQueryParams.play != null && initQueryParams.play!="0") {
		myDiagram.nodeTemplateMap = NODE_TEMPLATE_VIS;
	}

	  function scaleLink(link, newscale) {
		link.curviness = 1 * origscale/newscale;
	  }
	  function scaleNode(node, newscale) {
	  	//origscale / newscale;
			
			var text = node.findObject("TEXT");
			if (text == null) return;
			text.scale =  origscale / newscale;//newscale < .5 ? origscale / newscale*.5 : 1;
			text.visible = newscale >= .1 ? true : false; 
			text.maxSize.width = TEXTLABEL_BASEWIDTH * origscale / newscale;
			if (node.category === "point") {
				var shape = node.findObject("SHAPE");
				shape.scale =  newscale >= .3 ? 1 :  origscale / newscale * .3;
			}
			else if (node.category === "path") {
				var shape = node.findObject("SHAPE");
				var curSize = shape.desiredSize.width >= MAX_SHAPE_SIZE ? MAX_SHAPE_SIZE : shape.desiredSize.width;
				curSize *=newscale;
				shape.scale =  curSize >= 3 ? 1 : 3/curSize;
			}
	  }
	  
	  // This code keeps all nodes at a constant size in the viewport,
	  // by adjusting for any scaling done by zooming in or out.
	  // This code ignores simple Parts;
	  // Links will automatically be rerouted as Nodes change size.
	  var origscale = NaN;
	  var oldscale = NaN;
	  myDiagram.addDiagramListener("InitialLayoutCompleted", function(e) { origscale = oldscale = myDiagram.scale; });
	  myDiagram.addDiagramListener("ViewportBoundsChanged", function(e) {
		if (isNaN(origscale)) return;
		var newscale = myDiagram.scale;
		if (oldscale === newscale) return;  // optimization: don't scale Nodes when just scrolling/panning
		oldscale = newscale; 
		myDiagram.skipsUndoManager = true;
		myDiagram.startTransaction("scale Nodes");
		
		//myDiagram.linkTemplate = myDiagram.linkTemplate;
		
		myDiagram.nodes.each(function(node) {  // consider todo: only perform for nodes within visibility set? need to form visibilty set per scroll though.
		
			scaleNode(node, newscale);
			
		  });
		  
		   myDiagram.links.each(function(link) {  // consider todo: only perform for nodes within visibility set? need to form visibilty set per scroll though.
		
			scaleLink(link, newscale);
			
		  });
		  
		  
		 // myDiagram.model.updateTargetBindings("
		myDiagram.commitTransaction("scale Nodes");
		myDiagram.skipsUndoManager = false;
		
	  });
	  
	  
	
	function writePropertiesOver(obj, src) {
		var p;
		if (src == null) return obj;
		for(p in src) {
		
			obj[p] = src[p];
		}
		return obj;
	}
	
	var zoneTextProxy = {
		 get : function() {
			return this._node.val.label;
	   },
	   set: function(val) {
			this._node.val.label = val;
			inspectGoNode(this);
	   }
	}

	function extractVisNotation(nodeVal) {
		var desc = nodeVal.defOverwrites != null && nodeVal.defOverwrites.description  ? nodeVal.defOverwrites.description : nodeVal.def.description;
		var label = nodeVal.defOverwrites != null && nodeVal.defOverwrites.label  ? nodeVal.defOverwrites.label : nodeVal.def.label;
		var visDesc = "";
		if (desc.charAt(0)=== "~") {
			 visDesc = desc.split("\n")[0].slice(1);
		}
		else {
			visDesc =  "0";
		}
		return (vuePanel.viewFlags & VIEWFLAG_ENFORCE_ALL_LABELS) !=0 ? label + " ~"+visDesc : visDesc;
	}
		  
	var textProxy = {
	   get : function() {
			return ((vuePanel.viewFlags & VIEWFLAG_VIS)!=0) && this._node && this._node.val.def.gameplayCategory==null  ? this._node ? extractVisNotation(this._node.val) : "null node" :  
			this._node && this._node.val.defOverwrites != null && this._node.val.defOverwrites.label  ? this._node.val.defOverwrites.label : (this._node ? this._node.val.def.label : "null node");
	   },
	   set : function(val) {
			var prefix = val.charAt(0);
			if (prefix=== "#") {	// lookup location definition
				val = val.slice(1);
				var tryDef = world.getLocationDef( val );
				if (tryDef != null) {
					this._node.val.def = tryDef;
					this._node.val.defOverwrites = null;
					this.isProto =  val =="Point" || val ==="Path" || val === "Region";
					inspectGoNode(this);
				}
				else {
					alert("Failed to find location definition: "+val);
				}
			}
			else if (prefix === "~") {  // write label directly into location definition
				if (this.isProto || val =="Point" || val ==="Path" || val === "Region") {
					alert("Sorry, cannot write label directly into prototype location definition id! Save it first with * prefix!");
					return;
				}
				val = val.slice(1);
				if (val === "" ) val = this._node.val.def.label;
				if (this._node.val.defOverwrites != null) {
					delete this._node.val.defOverwrites["label"];
				}
				this._node.val.def.label = val;
			}
			else if (prefix === "*") { // save location definition
				val = val.slice(1);
				//
				var dupLoc;
				
				if (val.charAt(0) === "#") {
					val = val.slice(1);
					if (val === "") {
						if (this.isProto || this._node.val.def.id =="Point" || this._node.val.def.id ==="Path" || this._node.val.def.id === "Region") {
							alert("Sorry, cannot write directly into prototype location definition! Save it first with * prefix!");
							return;
						}
						else writePropertiesOver(this._node.val.def , this._node.val.defOverwrites);
						this._node.val.defOverwrites = null;
						return;
					}
					dupLoc = writePropertiesOver( world.getDuplicationLocationDef(this._node.val.def, val) , this._node.val.defOverwrites);
				}
				else {
					if (val === "") {
						if (this.isProto || this._node.val.def.id =="Point" || this._node.val.def.id ==="Path" || this._node.val.def.id === "Region") {
							alert("Sorry, cannot write directly into prototype location definition! Save it first with * prefix!");
							return;
						}
						else writePropertiesOver(this._node.val.def , this._node.val.defOverwrites);
						this._node.val.defOverwrites = null;
						inspectGoNode(this);
						
						return;
					}
					
					
					if (this._node.val.defOverwrites == null) {
						//this._node.val.defOverwrites = {};
					
						this._node.val.setEmptyDefOverwrites();

					}
					this._node.val.defOverwrites.label = val;
					dupLoc = writePropertiesOver( world.getDuplicationLocationDef(this._node.val.def, val) , this._node.val.defOverwrites);
				}
			
				try {
					world.addLocationDef(dupLoc);
					vueModel.locationDefIds.push(dupLoc.id);
					this._node.val.defOverwrites = null;
					this._node.val.def = dupLoc;
					
					this.isProto = false;
					inspectGoNode(this);
				}
				catch(err) {
					alert(err);
				}
				
			}
			else if (prefix === "^") {
			
				if (this.isProto || this._node.val.def.id =="Point" || this._node.val.def.id ==="Path" || this._node.val.def.id === "Region") {
					alert("Sorry, cannot rename directly into prototype location definition! Save it first with * prefix!");
					return;
				}
						
						
				val = val.slice(1);
				
				if (val.charAt(0) === "#") {  
					val = val.slice(1);
					if (val ===this._node.val.def.id) {
						return;
					}
					
					if (val === "") {  // TODO: delete
						alert("TODO: deletion of location definition");
						return;
					}
					else {
					
						if ( world.getLocationDef(val) == null ) {  // rename
							world.removeLocationDef(this._node.val.def);
							vueModel.locationDefIds.$set( vueModel.locationDefIds.indexOf(this._node.val.def.id), val);
							this._node.val.def.id = val;
							world.addLocationDef(this._node.val.def);
						}
						else { // consider todo: check trashed definition
							return;
						}
						inspectGoNode(this);
						return;
					}
				}
				else {
					return;
				}
			}
			else {  // write label overwrite
				if (val =="Point" || val ==="Path" || val === "Region") {
					alert("Sorry, prototype id value reserved");
					return;
				}
				if (val === "") {
					if (this._node.val.defOverwrites != null) {
						delete this._node.val.defOverwrites["label"];
						
						
					}
					val = this._node.val.def.label;
					this.isProto =  val =="Point" || val ==="Path" || val === "Region";
					return;
				}
				if (this._node.val.defOverwrites == null) {
					//	this._node.val.defOverwrites = { label: val };
					this._node.val.setEmptyDefOverwrites();
					this._node.val.defOverwrites.label = val;
				}
				else this._node.val.defOverwrites.label = val;
				//this._node.val.def.label = val;
			
			}
	   }
	};
	
	
					
	function updateRelatedNodesOfModel(model, def, prop) {
		var nodeDataArr = model.nodeDataArray;
		var i = nodeDataArr.length;
		var o;
		while(--i > -1) {
			o = nodeDataArr[i];
			if (o._node && o._node.val.def === def) model.updateTargetBindings(nodeDataArr[i], prop);
		}
	}
	
	function vueNullifyPropertyOnInstanceChain(expression) {
		var exprSplit = expression.split(".");
		if (exprSplit.length >= 3) {
		
			var leaf = exprSplit.pop();
			
			nullifyPropertyOnInstanceChain(  vueModel.$get(exprSplit.join(".")), leaf, vueModel.$get(exprSplit.slice(0, exprSplit.length-1).join(".") ), exprSplit[exprSplit.length-1] );
		}
		else {
			nullifyPropertyOnInstanceChain( vueModel.$get(exprSplit[0].toString()),  exprSplit[1].toString());
		}
	}
	
	function nullifyPropertyOnInstanceChain(instance, prop, parentObj, instanceProp) {
		if (instance == null) return true;
		if (instance[prop] !== undefined) instance[prop] = null;
		
		if (parentObj != null) {
			var p;
			for (p in instance) {
				if (instance[p] != null) {
					return true;
				}
			}
			parentObj[instanceProp] = null;
			return false;
		}
		
		return true;
	}
	
	
	function addDiagramLink(params) {
		var fromNode = myDiagram.findNodeForKey(params.from).data._node;
		fromNode.addArc(myDiagram.findNodeForKey(params.to).data._node);
		params._arc = fromNode.arcList;
		
		return fromNode.arcList;
	
	}
	function removeDiagramLink(params) {
		var fromTest =  myDiagram.findNodeForKey(params.from);
		var targTest = myDiagram.findNodeForKey(params.to);
		if (fromTest ===null || targTest == null) {  // hmm..GOJS, is this intended? WHy is it null?
			//alert("TARGEST NULL FOUND:"+[params.from, params.to]);
			return;
		}
		
		var resultTest =fromTest.data._node.removeArc( 	targTest.data._node  );
		//alert(resultTest + ", <- removeDiagramLink");
		if (!resultTest) alert("removeDiagramLink de.polygonal operation failed exception!");
		return resultTest;
	}
	
	
	function testResultAssert(testResult, str) {
		if (!testResult) {
			alert("testResultAssert failed:"+str);
		}
		//else alert("SUCCESS:"+str);
		return testResult;
	}
	
  myDiagram.model.linkKeyProperty = "key";
  myDiagram.model.addChangedListener(function(e) {
	if (e.isTransactionFinished) {
	  var tx = e.object;
	  
	  if (tx instanceof go.Transaction && console && e.model) {
	   // console.log(tx.toString());
		
		if ( tx.name != "Move") {
		
			var methodToCalls = [];
			var nodesToAdd = [];
			var arcsToAdd = [];
			var zonesToAdd = [];
			tx.changes.each(function(c) {
			
			  if (c.model) {
				if ( c.model === c.object ) { // deemed insertion or removal
					if (c.newValue != null && c.oldValue == null) {  // insertion infered
					
						if (c.propertyName == "nodeDataArray") {  // insert node
							if (c.newValue.locid) nodesToAdd.push( c.newValue );
							else if (c.newValue.zoneid!=null) zonesToAdd.push(c.newValue);
						}
						else if (c.propertyName == "linkDataArray") {  // create link
							if (c.newValue.from != null) {
								arcsToAdd.push(c.newValue);
								
							}
							else {
								alert("Isolated arc copy Exception found. This should be prevented.");
							}
							
							//console.log("LINK CREATED:", c.newValue);
							
						}
					}
					else if (c.newValue == null && c.oldValue != null) { // removal infered
						if (c.propertyName == "nodeDataArray") {  // remove node
							//console.log("REMOVE NODE:", c.oldValue);
							//myDiagram.findNodeForKey(c.
							world.graph.removeNode( c.oldValue._node );
							testResultAssert(  world.removeHashEditable(c.oldValue._node), "Remove node" );
						}
						else if (c.propertyName == "linkDataArray") {  // remove link
							removeDiagramLink(c.oldValue);
							testResultAssert(  world.removeHashEditable(c.oldValue._arc), "Remove arc" );
						}
					}
					else {
						console.log	("Could not resolve this transaction case: "+tx);
					}
				}
				else {  // deemed modifying of data within model
					if (c.propertyName === "loc") {   // moving 
						var n = c.object._node;
						if (n != null) {
							n.val.x = c.newValue.x;
							n.val.y = c.newValue.y;
							if (_selectedGoNodeData === c.object && vueModel.selected) {  // sync location with vue gui
								vueModel.selected.x = c.newValue.x;
								vueModel.selected.y = c.newValue.y;
							}
							///vueModel.val.x = c.newValue.x;

							//vueModel.val.y = 
						}
					}
					else if (c.propertyName === "linkable") {
						// irreleavant. do nothing
					}
					else if (c.propertyName === "text") {
						var n = c.object._node;
						if (n!=null && n.val.def) {
							methodToCalls.push(updateRelatedNodesOfModel, [e.model, c.object._node.val.def, "text"]);
							methodToCalls.push(updateRelatedNodesOfModel, [myPalette.model, c.object._node.val.def, "text"]);
						}
						
						if (n != null && n.val=== _inspectedNodeVal  ) {
							if(n.val.defOverwrites && n.val.defOverwrites.label!=null) {
								vueModel.$set("selected.defOverwrites.label", n.val.defOverwrites.label);
							}
							else {
								vueNullifyPropertyOnInstanceChain("selected.defOverwrites.label");
							}
							vueModel.$set("selected.def.label", n.val.def.label);
							
						}
					}
					else if (c.propertyName === "from") {
						//alert("TODO: arc 'from' change case");
						//console.log("from", c.newValue, c.oldValue);
					}
					else if (c.propertyName === "to") {
						//alert("TODO: arc 'to' change case");
						//console.log("to", c.newValue, c.oldValue);
					}
					else if (c.propertyName === "size") {

					}
					else if (c.propertyName === "_node") {
						// irrelavant
						alert("_node :: UNderscored property should not detect");
					}
					else if (c.propertyName === "category") {
						// irrelavant
					}
					else if (c.propertyName ==="pictureSrc") {
					
						if (vueModel.selected && vueModel.selected.pictureSrc !== undefined) {
						
							vueModel.selected.imageURL = "pictureSrc";
						}
					}
					else { //
					  alert("could not resolve:"+c.propertyName);
					}
				}

				console.log( c.object," " +c.modelChange + ","+c.propertyName+","+c.oldParam +", "+c.newParam );
				//console.log("OldValue:", c.oldValue);
				//console.log("NewValue:", c.newValue);
				
				//console.log( model.toIncrementalJson(e) );
			  }
			});
			
			var i;
			for(i=0; i< methodToCalls.length; i+=2) {
				methodToCalls[i].apply(null, methodToCalls[i+1]);
			
			}
			
			// creation of nodes
				i = 0;
					var v;
				var o;
				for (i=0; i<nodesToAdd.length; i++) {
					o =nodesToAdd[i];
					if (o._node != null) {  // DUPLICATE NODE CASE
						//alert(flagDownKeys );
						//e.model.setDataProperty(o,"_node",v= world.addLocationNode(world.getLocationDef(o._node.val.def.id), o.loc.x, o.loc.y, 0, null, ( false ? o._node.val.cloneOverwritesDynamic() : o._node.val.defOverwrites) ));
						o._node = v = world.addLocationNode(world.getLocationDef(o._node.val.def.id), o.loc.x, o.loc.y, 0, null, ( false ? o._node.val.cloneOverwritesDynamic() : o._node.val.defOverwrites) );
						
						world.registerHashEditable(v, o);
					}
					else {  // NEW NODE CASE
						
						//e.model.setDataProperty(o,"_node",v= world.addLocationNode(world.getLocationDef(o.locid).setSize(o.size.width), o.loc.x, o.loc.y, 0, null, null ));
						o._node = v = world.addLocationNode(world.getLocationDef(o.locid).setSize(o.size.width), o.loc.x, o.loc.y, 0, null, null );
						if (o.defOverwrites != null) {
							o._node.val.setupNewDefOverwrites(o.defOverwrites);
						}
						world.registerHashEditable(v, o);
					}
					
					
					if (_selectedGoNodeData === o) {
						//alert("A");
						inspectGoNode(o);
					}
					
					if (o.text != textProxy) {
						Object.defineProperty(o,"text",textProxy);
						e.model.updateTargetBindings(o, "text");
					}
			
				}
				
				for (i=0; i<zonesToAdd.length; i++) {
					o =zonesToAdd[i];
					if (o._node != null) { 
						alert("Exception! Zones aren't duplicable or copyable!");
					}
					else {  // NEW ZONE CASE
						var zone;
						var zoneNewKey;
						if (o.zoneid === false) {
							zoneNewKey = world.getUniqueHashKey();
							o.zoneid = "~zone"+zoneNewKey;
							zone = Zone.create("~Zone"+zoneNewKey, o.zoneid);
							zone.x = o.loc.x;
							zone.y = o.loc.y;
						}
						else {
							zone = world.getZone(o.zoneid);
							if (zone == null) {
								alert("Error!! Could not find zone by id!: "+o.zoneid);
								continue;
							}
							
							zone.x = o.loc.x;
							zone.y = o.loc.y;
						}
						
						if (zone.imageURL) {
							o.pictureSrc = zone.imageURL;

						}
						else if (o.pictureSrc) {
							zone.imageURL = o.pictureSrc	;
							
						}
						
					
						
						e.model.setDataProperty(o,"_node",v= world.addZoneNode(zone));
						world.registerHashEditable(v, o);
						
						if (o.text != zoneTextProxy) {
							Object.defineProperty(o,"text",zoneTextProxy);
							e.model.updateTargetBindings(o, "text");
							e.model.updateTargetBindings(o, "pictureSrc");
						}
						
						if (_selectedGoNodeData === o) {
							inspectGoNode(o);
						}
					}
				}
				
				
				// creation of arcs
				i = 0;
				for (i = 0; i < arcsToAdd.length; i++) {
					o =arcsToAdd[i];
					world.registerHashEditable( addDiagramLink(o), o);
					if (_selectedGoArcData === o) {
						inspectGoArc(o);
					}
				}
	
		  }
		//  /*
		  else  {   // handle move case via incremental json
			//	/*
				
				var moveJson = e.model.toIncrementalJson(e);
				moveJson = JSON.parse(moveJson);
				var modData = moveJson.modifiedNodeData;
				var keyProp = moveJson.linkKeyProperty;
				
				var i =modData ?  modData.length : 0;
				var o;
				
				while(--i > -1) { // readonly
					o = modData[i];
					//= o.loc.x;
					//= o.loc.y;
					var cObject = myDiagram.model.findNodeDataForKey(o[keyProp]);
					
					var n = cObject._node;
					if (n != null) {
						n.val.x = o.loc.x;
						n.val.y =o.loc.y;
						if (_selectedGoNodeData === cObject) {  // sync location with vue gui
							vueModel.selected.x = o.loc.x;
							vueModel.selected.y = o.loc.y;
						}
						
					}
				}
				//*/
	
				
				
		  }
		//  */
	  }
	  
	}
  });



  	var vueDashboard = new Vue({
			el: "#dashboard-app",
			data: {
				isShowingDashboard:initedWithDashboard,
				mapDomain:initedMapDomain,
				mapDomainLoading:false,
				loadedMaps: [],
				mapLoadingError:false,
				currentMapIndex: -1,
				queryParams: initQueryParams,
				resumed:false,
			},
			created: function() {
				if (this.isShowingDashboard && !this.mapDomainLoading) {
					this.loadMaps();
				}
			},
			methods: {
				openLoadedMap: function(index, dontExit) {

					try {
					loadWorld(this.loadedMaps[index].stream);
					}
					catch(err) {
						alert("Oops, something went wrong couldn't load map stream! See console for details.")
						console.log("Failed to load map stream:", this.loadedMaps[index].stream);
						return;	
					}
					if (!dontExit) this.isShowingDashboard = false;


				},
				returnToCurrentMap: function(index ) {
					this.isShowingDashboard = false;
				},
				loadMaps: function() {
					this.loadedMaps = [];
					this.currentMapIndex = -1;
					this.mapDomainLoading = true;
					var self = this;
					$.ajax({url:(initedSelfDomain ? "" : "https://effuse-church.000webhostapp.com")+"/curlgink.php", dataType:"json", data:{id:this.mapDomain} } ).done( function(e) {
						self.mapLoadingError = false;

						var newMaps = [];
						var i;
						if (!Array.isArray(e)) {
							alert("Failed to load maps..Data format not array!")
							return;
						}
						var len = e.length;
						var obj;
						for(i=0;i<len; i++) {
							obj = e[i];
							
							if (obj.content === "" ) continue; // this case is due to accounting for Gingko bug with uncleaned deleted items
							if (!obj.children || obj.children.length == 0 ) { 
								alert(i+": Failed to load obj children stream of:!"+obj.content)
								continue;
							}
							
							var trimedTitle = obj.content.trim();
							newMaps.push({ name:trimedTitle, credit:(obj.children.length > 1 ? obj.children[1].content : ""), stream:obj.children[0].content });
							
							if (trimedTitle == self.queryParams.current) {
								self.currentMapIndex = newMaps.length-1;
								
							}
							
						}

						
						self.loadedMaps = newMaps;
						
					
						self.mapDomainLoading = false;

						//!this.resumed && 
						if (self.currentMapIndex >= 0) {
							
							self.openLoadedMap(self.currentMapIndex, true);

						
							if (self.queryParams.dashboard == "skip") {
								self.returnToCurrentMap();
								
							}
							
							
							self.queryParams.current = null;
						}

					

						
					}).error( function() {
						self.mapLoadingError = true;

						self.mapDomainLoading = false;
					});  
				},
				reloadMapDomain: function() {
					this.loadMaps();
				},
			},
			watch: {
				isShowingDashboard: function(newValue, oldValue) {
					if (!newValue) {  // no longer showing..
						// CleanUp:
						//this.loadedMaps =[];
						this.currentMapIndex = -1;
						this.queryParams.current = null;
						this.resumed = true;
					}
					else {
						if (this.loadedMaps.length == 0 && !this.mapDomainLoading) {
							this.loadMaps();
						}
					}
				}
			},
			computed: {
			  baseurl: function() {
				  return window.location.href.split("?")[0];
			  }
		  }
	  });
		  
	function classify(instance) {
		instance["class"] = "awawaawtwaaw";
		return instance;
	}


	// initialize the Palette that is in a floating, draggable HTML container
	myPalette = new go.Palette("myPaletteDiv");  // must name or refer to the DIV HTML element
	myPalette.allowZoom = false;
	
//	palTemplate.findObject("SHAPE").maxSize = new go.Size(20,20);
	myPalette.nodeTemplateMap.add("point", getNodeTemplate("Square",fill1,brush1,20,undefined,undefined, [new go.Binding("opacity", "", function(h) { return vuePanel.viewMode == VIEW_MODE_EDIT ? 1 : 0.25; } ), new go.Binding("selectable", "", function(h) { return vuePanel.viewMode == VIEW_MODE_EDIT; } )]));
	myPalette.nodeTemplateMap.add("path", getNodeTemplate("Diamond",fill2,brush2,20,undefined,undefined, [new go.Binding("opacity", "", function(h) { return vuePanel.viewMode == VIEW_MODE_EDIT ? 1 : 0.25; } ),new go.Binding("selectable", "", function(h) { return vuePanel.viewMode == VIEW_MODE_EDIT; } )]));
	myPalette.nodeTemplateMap.add("region",getNodeTemplate("Circle",fill3,brush3,20,undefined,undefined, [new go.Binding("opacity", "", function(h) { return vuePanel.viewMode == VIEW_MODE_EDIT ? 1 : 0.25; } ),new go.Binding("selectable", "", function(h) { return vuePanel.viewMode == VIEW_MODE_EDIT; } )]));
	myPalette.nodeTemplateMap.add("regionPlay",getNodeTemplate("Circle",fillPlay,brushPlay,20));
	myPalette.nodeTemplateMap.add("char", getNodeTemplate("Circle",fill4,brush4,20));
	myPalette.nodeTemplateMap.add("pointPlay", getNodeTemplate("Square",fill1play,brush1,20));
	
	

	myPalette.nodeTemplateMap.add("zone",getNodeTemplate("Circle",fill1,brush1, POINT_SIZE,undefined,undefined, [new go.Binding("opacity", "", function(h) { return vuePanel.viewMode == VIEW_MODE_EDIT ? 1 : 0.25; } ),new go.Binding("selectable", "", function(h) { return vuePanel.viewMode == VIEW_MODE_EDIT; } )]));


  	
	var GO_SIZES = [new go.Size(POINT_SIZE,POINT_SIZE), new go.Size(12,12), new go.Size(30,30), new go.Size(CHAR_SIZE, CHAR_SIZE) ];
	 
	myPalette.model = new go.GraphLinksModel([
	  { locid:"Point", isProto:true, text:"Point", category:"point",  size:GO_SIZES[0]   },
	  { locid:"Path", isProto:true, text:"Path",  category:"path",  size:GO_SIZES[1] },
	  { locid:"Region", isProto:true,  text:"Region",  category:"region", size:GO_SIZES[2] },
	{ locid:"RegionPlay", isProto:true,  text:"RegionPlay",  category:"regionPlay", size:GO_SIZES[2] },
	  { locid:"CharPlay", isProto:true,  text:"CharPlay",  category:"char", size:GO_SIZES[3] },
	{ locid:"PointPlay", isProto:true,  text:"PointPlay",  category:"pointPlay", size:GO_SIZES[0] },
	  { locid:"", zoneid:false, isProto:true,  text:"Zone",  pictureOpacity:DEFAULT_PICTURE_OPACITY, pictureSrc:"http://ingridwu.dmmdmcfatter.com/wp-content/uploads/2015/01/placeholder.png", category:"zone", size:new go.Size(POINT_SIZE,POINT_SIZE) }
	]);
	
	var FLAG_SHIFT_DOWN = 1;
	var flagDownKeys = 0;
	
	jQuery(window).keydown( function(e) {
		if (e.keyCode === 16) {	 // shift
			flagDownKeys |= FLAG_SHIFT_DOWN;
			myDiagram.model.setDataProperty(myDiagram.model.modelData, "linkable", true);
			
		}
		//console.log(flagDownKeys);
	});
	jQuery(window).keyup( function(e) {
		if (e.keyCode === 16) {  // shift
			flagDownKeys &= ~FLAG_SHIFT_DOWN;
			myDiagram.model.setDataProperty(myDiagram.model.modelData, "linkable", false);
		}
	//	console.log(flagDownKeys);
		
		 
	});

	myPalette.addDiagramListener("InitialLayoutCompleted", function(diagramEvent) {
	  var pdrag = document.getElementById("paletteDraggable");
	  var palette = diagramEvent.diagram;
	  var paddingHorizontal = palette.padding.left + palette.padding.right;
	  var paddingVertical = palette.padding.top + palette.padding.bottom;
	  pdrag.style.top = 8  + "px";
	  pdrag.style.left = 270  + "px";
	  pdrag.style.width = palette.documentBounds.width + 20  + "px";
	  pdrag.style.height = palette.documentBounds.height + 40 + "px";
	});
	
	$("#infoDraggable").focus( function() {
		
	});
	
	myDiagramDivs = $("#myDiagramDiv").add($("#myPaletteDiv"));
	
	function getMultiSelectedLocations(diagramSelection) {
		var arr = [];
		 var it = diagramSelection.iterator;
		 var selection;
		  while (it.next()) {
			selection = it.value;
			if ( (selection instanceof go.Node) && selection.data && selection.data._node ) {
				arr.push(selection.data.key);
			}
		  }
		return arr.length > 1 ? arr : false;
	}
	
	var lastDiagramSelection;
	// handles either node or arc selection (<- bleh this method is badly  contructed)...
	myDiagram.addDiagramListener("ChangedSelection", function(e) {
		var selection = myDiagram.selection.first();
		var iter;
		if (lastDiagramSelection) {
			iter = lastDiagramSelection.iterator;
			while(iter.next()) {
				if (iter.value instanceof go.Node) {
					// myDiagram.model.updateTargetBindings(iter.value.data, "visible");
					if (!myDiagram.selection.contains(iter.value)) myDiagram.model.updateTargetBindings(iter.value.data, "visible");
				}
			}
		}
		iter = myDiagram.selection.iterator;
		while(iter.next()) {
			if (iter.value instanceof go.Node) {
				// myDiagram.model.updateTargetBindings(iter.value.data, "visible");
				myDiagram.model.updateTargetBindings(iter.value.data, "visible");
			}
		}
		lastDiagramSelection = myDiagram.selection.copy();

		myDiagram.clearHighlighteds();
		vueModel.goSelectionCount = myDiagram.selection.count;
		
		if (selection instanceof go.Link) {
			
			
			_inspectedNodeVal = null;
			_selectedGoNodeData = null;
			vueModel.gotLocation = false;
			vueModel.selected = null; 
			_selectedGoArcData = selection.data;
			
			selection.isHighlighted  = true;
			
			if (selection.data._arc == null) {
				vueModel.selectedArc = null;
				return;
			}
			inspectGoArc(selection.data);
			
			return;
		}

		_inspectedArc = null;
		_selectedGoArcData = null;
		vueModel.selectedArc = null;
		if (vueModel.selectedArcOptions.alwaysResetAutoSyncOnUnselect) {
			vueModel.selectedArcOptions.autoSyncMutual = false;
		}
		
		if (selection != null) {
			vueModel.multiSelectedLocations = getMultiSelectedLocations(myDiagram.selection);
		}
		else {
			vueModel.multiSelectedLocations = false;
		}
		
		
		
		
		  if (selection === null || !(selection instanceof go.Node) || !selection.data || !selection.data._node ) {  // hide UIs
			_inspectedNodeVal = null;
			if (selection && selection.data != null) _selectedGoNodeData = selection.data;
			vueModel.gotLocation = false;
			vueModel.selected = null; 
			 
			return;
		}



		
		
		
		
		_selectedGoNodeData = selection.data;
	
		inspectGoNode(selection.data);

	
	});
	
	
	
	myPalette.addDiagramListener("ChangedSelection", function(e) {
		var selection = myPalette.selection.first();
		
		if (selection != null) {

			vuePalette.gotNonProtoSelection = !worldProtoLocIds[selection.data.text];
		}
	
	});
	
	

	var vuePalette;

	$(function() {
		$("#paletteDraggable").draggable({handle: "#paletteDraggableHandle", start:onUIDragStart, stop:onUIDragStop}).resizable({
		  // After resizing, perform another layout to fit everything in the palette's viewport
		  start: onUIDragStart,
		  stop: function(){ myPalette.layoutDiagram(true); onUIDragStop(); }
		});

		
		var inspector = new Inspector('infoDraggable', myDiagram,
		  {
			
		  acceptButton: true,
			resetButton: true
		  // /*
			, propertyNames: {
		//		"Node": ["category"],
			  //"Node": ["location", "background", "scale", "angle", "isShadowed", "resizable"],
			  //"#SHAPE": ["fill", "stroke", "strokeWidth", "figure"],
			  "#TEXT": ["text"]
			}
			//*/
		  });
		  
		 
		  var inspectorBtnContainer = $("#infoDraggable .inspector-button-container");
		  inspectorBtnContainer.after($('<div id="prefix-btn-container"></div>'));
		  var prefixBtnContainer = $("#prefix-btn-container");
		  prefixBtnContainer.append($('<button>~</button>').attr("v-on:click", "addTextPrefix('~')"));
		  prefixBtnContainer.append($('<button>*</button>').attr("v-on:click", "addTextPrefix('*')") );
		  prefixBtnContainer.append($('<button>*#</button>').attr("v-on:click", "addTextPrefix('*#')") );
		  prefixBtnContainer.append($('<button>^#</button>').attr("v-on:click", "addTextPrefix('^#')") );
		  prefixBtnContainer.attr("v-show", "gotLocation");
		  prefixBtnContainer.after('<div style="clear:both"></div><hr/>');
		  
		 inspectorBtnContainer =  $("#infoDraggable");
		  inspectorBtnContainer.append('<div class="formelem" v-show="viewMode == 1"><label>#</label><select style="width:70%" v-on:change="loadSelectedLocationDef" v-model="selectedLocationDefId"><option v-for="id in locationDefIds" value="{{id}}">{{id}}</option></select><button v-show="gotLocation" v-on:click="loadSelectedLocationDef">Load</button><button v-show="gotLocation && selectedLocationDefId!=null" v-on:click="applySelectedLocationDef">Apply{{ multiSelectedLocations ? " to all" : ""}}</button><button v-show="!gotLocation" v-on:click="editSelectedLocationDef">Edit</button></div><hr/>'); 
		
		 inspectorBtnContainer.append(prefixBtnContainer = $('<div v-show="gotLocation"></div>'));
		 var inputOptions ='<label><input type="checkbox" v-model="viewOptions.visLabels"></input>Visibility notation</label><label><input type="checkbox" v-model="viewOptions.fullSizes"></input>All Sizes</label><br/><label><input type="checkbox" v-model="viewOptions.enforceAllLabels" :disabled="viewOptions.viewMode ==1"></input>Enforce All Labels</label><label><input type="checkbox" v-model="viewOptions.showArcs" :disabled="viewOptions.viewMode ==1"></input>Show Arcs</label>';
		 inspectorBtnContainer.append($('<hr/><div id="view-options"><label>Viewing Mode:</label><select number v-model="viewOptions.viewMode"><option value="1">Edit Mode</option><option value="2">Play Mode</option></select><label>Options:</label>'+inputOptions+'</div>'));

		 prefixBtnContainer.append('<div class="formelem"><label style="">Query</label><select number style="min-width:60%"></select><button>Go</button></div>'); 
		 
		
		  vuePalette = new Vue({ 
			el:"#paletteDraggable",
			data: {
				vueData: vueModelData,
				palHash: {},
				gotNonProtoSelection:false
			},
			methods: {
				addToPalette: function() {
					//
					if (!this.vueData.gotLocation) {
						 alert("No location selected!");
						 return;
					}
					if (!this.vueData.isProto) {
						// ok
					}
					else {
						if (this.vueData.selected.defOverwrites && this.vueData.selected.defOverwrites.label && !worldProtoLocIds[this.vueData.selected.defOverwrites.label] ) {
							// ok
						}
						else {
							alert("Can't add to pallette, use a different overwrite text label first!");
							return;
						}
					}



					var type = this.$get("vueData.selected.defOverwrites.type");
					if (type == null) type = this.vueData.selected.def.type;
					var catType;
					type = catType= LocationDefinition.getLocationDefinitionTypeLabel(type);
					var texter = (this.$get("vueData.selected.defOverwrites.label") || this.vueData.selected.def.label) ;
					var key =  texter + type;
					if (this.palHash[key]) {
						//myPalette.model.removeNodeData(this.palHash[key]);
						alert("Already registered to palette something similar..");
						return;
					}
					
					var gameplayCategory = this.$get("vueData.selected.def.gameplayCategory");
				
					if ( vuePanel.viewMode === VIEW_MODE_PLAY && !gameplayCategory) {
						alert("Cannot add to pallette editing token in play mode")
						return;
					}
					
					
					if (vuePanel.viewMode === VIEW_MODE_EDIT && !gameplayCategory ) {
				
						alert("Sorry, this feature is currently disabled at the moment for editing tokens. Use Copy+Paste instead.")
						return;
					}
					
					var selFirst = myDiagram.selection.first();
					
					var clonedSelection = selFirst.copy();
					var nodeToClone = clonedSelection.data._node;
					
					var copyData =$.extend(false, {text:texter}, clonedSelection.data);
	
						
					copyData._node = null;
					copyData.category = catType.toLowerCase();
					copyData.text = texter;
					copyData.defOverwrites = nodeToClone.val.defOverwrites ?  $.extend(true, {}, nodeToClone.val.defOverwrites) : null; 
					copyData.locid = nodeToClone.val.def.id;
					clonedSelection.data = copyData;
					
		
					//delete copyData["key"];// = null;
					//alert( myPalette.model.getKeyForNodeData(copyData) );
					
					this.palHash[key] =  copyData;
					//	myPalette.add(copy);
			
					myPalette.add(clonedSelection);
					//myPalette.model.addNodeData(copyData);
					
					
				}
			},
			removeFromPalette: function() {
				
			}
		 });
		 
		 vuePanel = new Vue({
			el:"#infoDraggable",
			data: vueModelData,
			computed: {
				viewFlags: function() {
					var viewMode = this.viewOptions.viewMode;
					var flags = 0;
					console.log("UPDATING");
					flags |= this.viewOptions.visLabels ? VIEWFLAG_VIS : 0;
					flags |= this.viewOptions.fullSizes ? VIEWFLAG_FULL_SIZE : 0;
					flags |= this.viewOptions.enforceAllLabels && viewMode != VIEW_MODE_EDIT   ? VIEWFLAG_ENFORCE_ALL_LABELS : 0;
					flags |= this.viewOptions.showArcs  || viewMode === VIEW_MODE_EDIT ? VIEWFLAG_SHOW_ARCS : 0;

					return flags;
				},
				viewMode: function(newValue, oldValue) {
					return this.viewOptions.viewMode;
				}
			},
			watch: {
				viewMode: function(newValue, oldValue) {
					myDiagram.nodeTemplateMap = newValue == VIEW_MODE_PLAY ? NODE_TEMPLATE_VIS : NODE_TEMPLATE_DEFAULT;
				},
				viewFlags: function(newValue, oldValue) {
					
					myDiagram.updateAllTargetBindings("visible");
					myDiagram.updateAllTargetBindings("copyable");
					myDiagram.updateAllTargetBindings("pastable");
					myDiagram.updateAllTargetBindings("text");

					myPalette.updateAllTargetBindings("selectable");
					//myDiagram.updateAllTargetBindings();
				}
			},
			methods: {
				addTextPrefix: function(prefix) {
					var inputText = jQuery("#infoDraggable > .inspector >  .inspector-section input[type='text']");
					if (!inputText.length) 
					{
						alert("addTextPrefix() Exception:: Could not find inputText");
						return;
					}
					var curVal = inputText.val();
					var sect2;
					
					sect2 = curVal.slice(2);
					curVal = curVal.slice(0,2);
					curVal = curVal.replace(/\*|\#|\^|\~/g, "");
					curVal = prefix + curVal+sect2;
					inputText.val(curVal);
				},
				editSelectedLocationDef: function(e) {
					if (this.gotLocation) {
						alert("UI Exception: editSelectedLocationDef :: This should not be available! Only available without selected node location");
						return false;
					}
					if ( this.selectedLocationDefId ) {
						var locDef = world.getLocationDef(this.selectedLocationDefId);
						if (locDef == null) {
							alert("editSelectedLocationDef:: Location definition id not found exception: "+this.selectedLocationDefId);
							return;
						}
						if (this.selected && this.selected.def && this.selected.def.id === this.selectedLocationDefId) {   // toggle off instead
							this.selected  = null;
							_inspectedNodeVal = null;
						}
						else {   // regular case edit
							var jsonStr = TJSON.encode(locDef);
							var vueModelSelectedDef = TJSON.parse(jsonStr);
							if (locDef && locDef.gameplayCategory) vueModelSelectedDef.gameplayCategory = locDef.gameplayCategory;
							_inspectedNodeVal = { def:locDef };
							
							this.selected =  { def:vueModelSelectedDef };
						}
	
					}
				}
				,loadSelectedLocationDef: function(e) {
					///*
					if (!this.gotLocation) {
						//alert("UI Exception: loadSelectedLocationDef :: This should not be available! Only available with selected node location");
						return false;
					}
					//*/
					if ( this.selectedLocationDefId ) {
						var inputText = jQuery("#infoDraggable > .inspector >  .inspector-section input[type='text']");
						inputText.val("#"+this.selectedLocationDefId);
					}
				}
				,applySelectedLocationDef: function(e) {
					///*
					if (!this.gotLocation) {
						alert("UI Exception: applyLocationDefinition :: This should not be available! Only available with selected node location");
						return false;
					}
					//*/
					if ( this.selectedLocationDefId ) {
						var locDef = world.getLocationDef(this.selectedLocationDefId);
						if (locDef == null) {
							alert("applyLocationDefinition:: Location definition id not found exception: "+this.selectedLocationDefId);
							return;
						}
						var nodeId;
						var nodeData;
						if (!this.multiSelectedLocations) {
						
							nodeData = _selectedGoNodeData; //myDiagram.model.findNodeDataForKey(nodeId);
							if (nodeData == null) {
								alert("applySelectedLocationDef():: _selectedGoNodeData data not found exception:: "+nodeId);
								return;
							}
							if (nodeData._node == null) {
								alert("applySelectedLocationDef():: Node data's de.polygonal node not found exception:: "+nodeId);
								return;
							}
							nodeData._node.val.def = locDef;
							nodeData.isProto = false;
							myDiagram.model.updateTargetBindings(nodeData, "text");
							inspectGoNode(nodeData);
						}
						else {
							var multiSelectedLocations = this.multiSelectedLocations;
							var i = multiSelectedLocations.length;
							if (i ==0) {
								alert("applySelectedLocationDef():: Exception empty array!");
								return;
							}
							while(--i > -1) {
								nodeId = multiSelectedLocations[i];
								nodeData = myDiagram.model.findNodeDataForKey(nodeId);
								if (nodeData == null) {
									alert("applySelectedLocationDef():: Node data not found exception:: "+nodeId);
									continue;
								}
								if (nodeData._node == null) {
									alert("applySelectedLocationDef():: Node data's de.polygonal node not found exception:: "+nodeId);
									continue;
								}
								nodeData._node.val.def = locDef;
								nodeData.isProto = false;
								myDiagram.model.updateTargetBindings(nodeData, "text");
							}
							//alert(multiSelectedLocations);
							
							inspectGoNode(nodeData);
						}
						
						
						
						
						
					}
				}
				
			}
		});
	
  
  
		  
		});
		
		

  }
  
})();