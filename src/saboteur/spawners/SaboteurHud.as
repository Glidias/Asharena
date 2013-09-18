package saboteur.spawners 
{
	import alternativa.a3d.cullers.CircleRadiusCuller;
	import alternativa.a3d.systems.text.FontSettings;
	import alternativa.a3d.systems.text.StringLog;
	import alternativa.a3d.systems.text.TextBoxChannel;
	import alternativa.a3d.systems.text.TextSpawner;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.VertexAttributes;
	import alternativa.engine3d.materials.FillCircleMaterial;
	import alternativa.engine3d.materials.FillHudMaterial;
	import alternativa.engine3d.materials.FillMaterial;
	import alternativa.engine3d.materials.Grid2DMaterial;
	import alternativa.engine3d.materials.Material;
	import alternativa.engine3d.materials.RadarGrid2DMaterial;
	import alternativa.engine3d.materials.TextureMaterial;
	import alternativa.engine3d.objects.Mesh;
	import alternativa.engine3d.objects.MeshSet;
	import alternativa.engine3d.objects.Sprite3D;
	import alternativa.engine3d.primitives.Plane;
	import alternativa.engine3d.resources.Geometry;
	import alternativa.engine3d.spriteset.materials.MaskColorAtlasMaterial;
	import alternativa.engine3d.spriteset.materials.TextureAtlasMaterial;
	import alternativa.engine3d.spriteset.SpriteSet;
	import alternativa.engine3d.spriteset.util.SpriteGeometryUtil;
	import ash.core.Engine;
	import assets.fonts.ConsoleFont;
	import de.polygonal.core.event._Observable.Bind; 
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	import flash.geom.Vector3D;
	import flash.ui.Keyboard;
	import input.KeyPoll;
	import saboteur.ui.SaboteurHUDLayout;
	import saboteur.views.SaboteurMinimap;
	import views.ui.hud.BindLayoutObjCenterScale;
	import views.ui.hud.BindLayoutTextBox;
	import views.ui.text.TextLineInputter;
	import alternativa.engine3d.alternativa3d;
	use namespace alternativa3d;
	
	import util.SpawnerBundle;
	/**
	 * Consolidating all stuff for HuD and determining number of draw calls used for it
	 * @author Glenn Ko
	 */
	public class SaboteurHud extends SpawnerBundle
	{
		// Radar and minimap stuff
		public var minimapMaterial:TextureMaterial;  // minimap texture
		public var radarMaterial:TextureMaterial;  // circle masked
		public var radarGridMaterial:RadarGrid2DMaterial; 
		private var radarBgMaterial:FillCircleMaterial; 
		private var radarGridSprite:Object3D;
		
		//public var bgOverlayFillMaterial:FillMaterial= new FillMaterial(0x666666, .4);
		public var radar_endPointDead:FillMaterial= new FillMaterial(0xFF0000, 1);
		public var radar_endPointAvailable:FillMaterial= new FillMaterial(0xFF0000, 1);
		
		private var material_icon_canBuild:FillMaterial = new FillMaterial(0xFF0000, 1);
		public function setBuildState(state:int):void {
			
		}
		
		// Possible to combine both texture atlases....for single Spriteset, for now, keep it seperate for easy development
		
		// Skin textures for HuD  (for now, leave this out)
		public var skinsSpriteSet:SpriteSet;
		public var skins:TextureAtlasMaterial;  // a texture atlas for the entire skinned UI 
		
		// Icons for HuD
		public var toolsSpriteSet:SpriteSet;
		public var tools:TextureAtlasMaterial; //
	
		// The overlays
		
		public var overlays:MeshSet;
		private var overlayRoot:Object3D = new Object3D();
		
		public var circleRadarCuller:CircleRadiusCuller;
		
		// The differnet font settings
		public var txt_numpad:FontSettings;  // these can be baked 1-10, or even put to skin!
		public var txt_chat:FontSettings;	// dynamic text
		public var txt_tips:FontSettings;
		
		public var txt_chatChannel:TextBoxChannel;
		private var layout_chatChannel:BindLayoutTextBox;
		private var overlay_chatChannel:BindLayoutObjCenterScale;
		
		public var txt_tipsChannel:TextBoxChannel;
		private var overlay_tipsChannel:BindLayoutObjCenterScale;
		//private var layout_tipsChannel:BindLayoutTextBox;
		
		private var txt_chatInput:FontSettings;
		private var chatTextInput:TextLineInputter;
		private var keypollToDisable:KeyPoll;
		private var chatInputWidth:Number = 300;
		
		static public const MAX_CHARS:int = 60;
		private var consoleFont:ConsoleFont = new ConsoleFont();
		
		private var txtSpawner:TextSpawner;
		private var _stage:Stage;
		public var playerName:String = "Player";
		public var playerColor:uint = 2;
		
		private var layout:SaboteurHUDLayout;
		
	
		
		public function SaboteurHud(engine:Engine, stage:Stage, keypollToDisable:KeyPoll=null) 
		{
			chatTextInput = new TextLineInputter(stage);
			this.keypollToDisable = keypollToDisable;
			normPlane.rotationX = Math.PI;
			
			layout = new SaboteurHUDLayout(stage);
			//stage.addChild(layout);
			txtSpawner = new TextSpawner(engine);
			_stage = stage;
			stage.addEventListener(KeyboardEvent.KEY_DOWN, checkEnter);
			
			super();
		}
		
		private function checkEnter(e:KeyboardEvent):void 
		{
			if (e.keyCode === Keyboard.ENTER && !chatTextInput.activated) {
				
				activateChatInput();
			}
		}
		
		
		override protected function init():void {
			setupTools(); 
			
			setupText();
			setupMinimapAndRadar();
			spriteGeometry.upload(context3D);
			
			normPlane.geometry.upload(context3D);
			overlays = new MeshSet(overlayRoot);  // TODO: use MeshSetClonesContainer instead
			overlays.setMaterialToAllSurfaces( overlayMaterial);
			//throw new Error(overlays._surfaces.length);
			overlays.geometry.upload(context3D);
			
			super.init();
		}
		
		private function setupMinimapAndRadar():void 
		{
			radarHolder = new Object3D();
			radarGridHolder = new Object3D();
			radarHolder.addChild(radarGridHolder);
			radarGridMaterial = new RadarGrid2DMaterial(0x000000, .99999, 32, JettySpawner.H );
			
			radarGridMaterial.gridCoordinates.width =  12;
			radarGridMaterial.gridCoordinates.height = radarGridMaterial.gridSquareWidth/radarGridMaterial.gridSquareHeight * (radarGridMaterial.gridCoordinates.width);
				
			
			
			radarGridMaterial.lineThickness = 1.0;
			var rw:Number;
			var rh:Number;
			radarGridSprite = getNormalSpritePlane(radarGridMaterial, rw=radarGridMaterial.gridCoordinates.width * radarGridMaterial.gridSquareWidth, rh=radarGridMaterial.gridCoordinates.height * radarGridMaterial.gridSquareHeight); // new Sprite3D(radarGridMaterial.gridCoordinates.width * radarGridMaterial.gridSquareWidth, radarGridMaterial.gridCoordinates.height * radarGridMaterial.gridSquareHeight, radarGridMaterial);
		
			//	uploadResources(radarGridSprite.getResources());
			radarGridSprite.z = -.01;
		//	radarGridHolder.addChild( new Sprite3D(rw, rh, radarGridMaterial));
		
			
			//var layouterRadar:BindLayoutObjCenterScale;
			//layout.onLayoutUpdate.add(new BindLayoutObjCenterScale(layout.contTopRight.validateAABB, radarGridSprite, false).update);
			//new BindLayoutObjCenterScale(, radarGridSprite, false)
			
			
			
			radarBgMaterial = new FillCircleMaterial(0xFFFFFF, 1);
			radarGridBg = getNormalSpritePlane(radarBgMaterial, rw, rh);
			
			radarGridBg.z = 0;

			
			radarHolder.scaleX = .5;
			radarHolder.scaleY = .5;
			
			

			radarHolder.addChild(radarGridBg);
			radarHolder.addChild(radarGridSprite);
			radarHolder.rotationX = Math.PI;
			layout.onLayoutUpdate.add(new BindLayoutObjCenterScale(layout.contTopRight.validateAABB, radarHolder, false).update);
			
			circleRadarCuller = new CircleRadiusCuller(rw*.5, radarGridHolder);
			
			
			radarBlueprintOverlay = getNormalSpritePlane(new FillHudMaterial(0xFF0000, 1), radarGridMaterial.gridSquareWidth, radarGridMaterial.gridSquareHeight);
			radarBlueprintOverlay.z = 0;
			radarBlueprintOverlay.visible = true;
			radarGridHolder.addChild(radarBlueprintOverlay);
			//minimap = new SaboteurMinimap(
		}
		
		private function getNormalPlane(mat:Material, scaleX:Number,scaleY:Number):Mesh {
			var mesh:Mesh = normPlane.clone() as Mesh;
			mesh.setMaterialToAllSurfaces(mat);
			mesh.scaleX = scaleX;
			mesh.scaleY = scaleY;
			return mesh;
		}
		
		
		private var spriteGeometry:Geometry = SpriteGeometryUtil.createNormalizedSpriteGeometry(1, 0, 1, .5);
		private function getNormalSpritePlane(mat:Material, scaleX:Number, scaleY:Number):Mesh {
			var mesh:Mesh = new Mesh();
			mesh.geometry = spriteGeometry;
			mesh.scaleX = scaleX;
			mesh.scaleY = scaleY;
			//mesh.rotationX = Math.PI;
			mesh.addSurface(mat, 0, 2);
			return mesh;
		}
		
		public var overlayMaterial:FillMaterial = new FillMaterial(0x000000, .25);
		private var normPlane:Plane = new Plane(1,1,1,1,false,false,overlayMaterial, overlayMaterial);
		private var radarGridBg:Mesh;
		public var radarBlueprintOverlay:Mesh;
		public var radarHolder:Object3D;
		public var radarGridHolder:Object3D;
		
		private function getOverlay():Object3D {
			return overlayRoot.addChild( normPlane.clone() );
		}
		
	
		
		private function activateChatInput():void {
					if (keypollToDisable != null) {
				keypollToDisable.disable();
			}
			chatTextInput.activate();
	
			
			//  this will automaticlaly write
			txt_chatInput.writeFinalData("|", 0, 0, chatInputWidth, false, 0);
		}
		private function deactivateChatInput():void {
			chatTextInput.deactivate();
			if (keypollToDisable != null) {
				keypollToDisable.enable();
			}
		}
		
		// Utility to bind layout AABBs against Object3D position or (Start Index position on SpriteData, with optional layouting sceheme with range or custom method ). 
		public function layoutItems():void {
			
		}
		
		public function addToHud3D(obj:Object3D):void {
			
			// overlays
			
			obj.addChild(overlays);
			// tools
			
			// minimap and radar
		//	obj.addChild(radarGridSprite);
			obj.addChild(radarHolder);
			//obj.addChild(radarGridSprite);
			
			// text
			obj.addChild(txt_tips.spriteSet);
			obj.addChild(txt_numpad.spriteSet);
			obj.addChild(txt_chat.spriteSet);
			obj.addChild(txt_chatInput.spriteSet);
			
		}
		
		public function writeChatText(text:String):void {
			txt_chatChannel.appendMessage(text);
		}
		public function writeTipText(text:String):void {
			txt_tipsChannel.appendMessage(text);
		}
		
		/*
		public function refreshChatText():void {
			txt_chatChannel.refresh();
		}
		public function refreshTipText():void {
			txt_tipsChannel.refresh();
		}
		*/
		
		
		
		private function setupText():void 
		{
			consoleFont.bmpResource.upload(context3D);
			chatTextInput.glyphRange = consoleFont.fontV._glyphRange;
			
			var geom:Geometry  = SpriteGeometryUtil.createNormalizedSpriteGeometry(MAX_CHARS, 0, 1, 1, 0, 0, 2);
			geom.upload(context3D);
			
			
			var mat:Material;
			
			mat = getNewDefaultFontMaterial(0xDDEEAA);
			txt_numpad = new FontSettings(consoleFont, mat , getNewTextSpriteSet(10, mat, geom) );
			
			mat = getNewDefaultFontMaterial(0xDDEEAA);
			txt_tips = new FontSettings(consoleFont, mat , getNewTextSpriteSet(MAX_CHARS, mat, geom) );
			txt_tipsChannel = new TextBoxChannel(new <FontSettings>[txt_tips], 5, 10, 3);
			//overlay_tipsChannel = new BindLayoutObjCenterScale(layout.contLeft.validateAABB, getOverlay());
			//layout.onLayoutUpdate.add(overlay_tipsChannel.update);
			
			//layout.onLayoutUpdate.add(new BindLayoutObjCenterScale(layout.contMiddleLeft.validateAABB, getOverlay()).update);
			//layout.onLayoutUpdate.add(new BindLayoutObjCenterScale(layout.contTopLeft.validateAABB, getOverlay()).update);
			//layout.onLayoutUpdate.add(new BindLayoutObjCenterScale(layout.contTopRight.validateAABB, getOverlay()).update);
			//layout.onLayoutUpdate.add(new BindLayoutObjCenterScale(layout.contRight.validateAABB, getOverlay()).update);
			//layout.onLayoutUpdate.add(new BindLayoutObjCenterScale(layout.contLeft.validateAABB, getOverlay()).update);
			
			mat = getNewDefaultFontMaterial(0xDDEEAA);
			txt_chat = new FontSettings(consoleFont, mat , getNewTextSpriteSet(MAX_CHARS, mat, geom) );
			txt_chatChannel = new TextBoxChannel(new <FontSettings>[txt_chat], 5, 10, 3);
			txt_chatChannel.timeout = -1;
			txt_chatChannel.history = new StringLog();
			txt_chatChannel.lineSpacing = 10.2;
			txt_chatChannel.vSpacing = 4;
			layout_chatChannel = new BindLayoutTextBox(layout.contTop.validateAABB, txt_chatChannel.styles[0].spriteSet, txt_chatChannel, 8, 4, 0, 0);
			layout.onLayoutUpdate.add(layout_chatChannel.update);
		//	overlay_chatChannel = new BindLayoutObjCenterScale(layout.contTop.validateAABB, getOverlay());
		//	layout.onLayoutUpdate.add(overlay_chatChannel.update);
			
			txt_chatInput = new FontSettings(consoleFont, mat , getNewTextSpriteSet(MAX_CHARS, mat, geom) );
			
			chatTextInput.onTextChange.add( onChatTextChange);
			chatTextInput.onTextCommit.add( onChatTextCommit);
			chatTextInput.onTextEscape.add( onChatTextESC);
			
			txtSpawner.addTextBoxChannel( txt_chatChannel);
			txtSpawner.addTextBoxChannel( txt_tipsChannel);
			
		}
		
		private function onChatTextCommit(str:String):void 
		{
			if (str != "" ) { 
				
				txt_chatChannel.appendSpanTagMessage('<span u="'+playerColor+'">'+ playerName+': </span><![CDATA['+str+']]>');
			//	txt_chatChannel.refresh();
			}
			txt_chatInput.writeFinalData("", 0, 0, chatInputWidth, false, 0);
			deactivateChatInput();
		}
		
		private function onChatTextESC(str:String):void 
		{	
			txt_chatInput.writeFinalData("", 0, 0, chatInputWidth, false, 0);
			deactivateChatInput();
		}
		
		private function onChatTextChange(str:String):void 
		{
			// todo: bind width to layout
			txt_chatInput.writeFinalData(str+"|", 0, 0, chatInputWidth, false, 0);
		}
		
		private function getNewFontMaterial(color:uint):MaskColorAtlasMaterial {
			var mat:MaskColorAtlasMaterial =  new MaskColorAtlasMaterial(consoleFont.bmpResource);
			mat.transparentPass = false;
			mat.color = color;
			mat.alphaThreshold = .8;
			mat.flags = (MaskColorAtlasMaterial.FLAG_MIPNONE | MaskColorAtlasMaterial.FLAG_PIXEL_NEAREST);
			return mat;
		}
		private function getNewDefaultFontMaterial(color:uint):TextureAtlasMaterial {
			var mat:TextureAtlasMaterial =  new TextureAtlasMaterial(consoleFont.bmpResource);
			//mat.transparentPass = false;
			mat.alphaThreshold =.8;
			mat.flags = (TextureAtlasMaterial.FLAG_MIPNONE | TextureAtlasMaterial.FLAG_PIXEL_NEAREST);
			return mat;
		}
		
		private function getNewTextSpriteSet(estimatedMaxChars:int, material:Material, geom:Geometry):SpriteSet {
			var spr:SpriteSet = new SpriteSet(0, true, material, consoleFont.bmpResource.data.width, consoleFont.bmpResource.data.height, estimatedMaxChars, 2 );
			
			return spr;
		}
		
		private function setupTools():void 
		{
			
		}

		
	}

}