// vue boilerplate
function setupGUIForVue(gui, expressionPrefix, dataModelDirective) {
	var guiFolders = gui.getAllGUIs();
	if (dataModelDirective == null) dataModelDirective = "vuedatgui";
	dataModelDirective = dataModelDirective ?  "v-"+dataModelDirective : "";
	var mer;
	
	for (p in guiFolders) {
		g= guiFolders[p];
		if (!g._guiGlue) continue;
		
		if (g._guiGlue._dotPath != undefined) {
			if (g._guiGlue._dotPath != "") {
				 mer = $(g.domElement.firstChild).data("dat-gui", g).attr("v-dat-instance", expressionPrefix+ g._guiGlue._dotPath);
				
				if (dataModelDirective) mer.attr(dataModelDirective, expressionPrefix+ g._guiGlue._dotPath);
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
				
				if (dataModelDirective) cn.domElement.firstChild.setAttribute(dataModelDirective, expressionPrefix+dotPath);
			}
			
			for (f in g.__folders) {
				var folder = g.__folders[f];
				if (!folder._guiGlue) continue;
				if (folder._guiGlue._dotPath == undefined) {
					var parentLI = jQuery( jQuery(folder.domElement).parents("li")[0] );
					if (parentLI.hasClass("bitmask")) {
					
						var dotPath =( g._guiGlue._dotPath!= "" ?  g._guiGlue._dotPath + "." : "")+ f;
						mer = $(folder.domElement.firstChild).data("dat-gui", folder).attr("v-dat-bitmask", expressionPrefix+dotPath );
						
						if (dataModelDirective) mer.attr(dataModelDirective, expressionPrefix+dotPath);		
					}
					else {
						//alert("TODO: need to resolve folder directive for:"+f );<br/>
					}
				}
			}
		}
	}
	
	var liNumberRows = jQuery(gui.domElement).find("li.number");	
	liNumberRows.find("input").each( function(index, item) {
		item = jQuery(item);
		item.attr( "number", "");
	});

	liNumberRows.find("select").each( function(index, item) {
		item = jQuery(item);
		item.attr( "number", "");
	});
	return gui;
}
	
Vue.directive('vuedatgui', {
	bind: function() {
		console.log("VUEDAT Gui sample bind", this.expression);
	},
	update: function(val, lastVal) {
		console.log("VUEDAT Gui sample update at:"+this.expression, val, lastVal);
	
	},
	unbind: function() {
		console.log("VUEDAT Gui sample unbind:"+this.expression);
	}
});

Vue.directive('dat-instance', {  // Binds to Dat.gui folders's domElement.firstChild => UL element
	bind: function(val) {
		var self = this;
		
		this._datGui = $(this.el).data("dat-gui");
		 this._datGui.onClosedChange( function(isClosed) {
			self.vm.$set( self.expression, (isClosed ? null : self._datGui._guiGlueParams ) );
		 });
		 self.vm.$set( self.expression, (this._datGui.closed ? null : self._datGui._guiGlueParams ) );
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
			var precision = self._datController.__precision;
			val =val.toFixed(precision);
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
		if (self.vm.$get(self.expression) !== undefined) self.vm.$set( self.expression, self.bitmaskValue );
		
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